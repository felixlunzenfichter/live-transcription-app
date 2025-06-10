require('dotenv').config();
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const recorder = require('node-record-lpcm16');
const speech = require('@google-cloud/speech');
const path = require('path');
const { exec } = require('child_process');

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

// Serve static files
app.use(express.static('public'));

// Serve the main page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Google Speech client
const client = new speech.SpeechClient();

const encoding = 'LINEAR16';
const sampleRateHertz = 16000;
const languageCode = 'en-US';

const request = {
  config: {
    encoding: encoding,
    sampleRateHertz: sampleRateHertz,
    languageCode: languageCode,
    enableAutomaticPunctuation: true,
  },
  interimResults: true,
};

// Handle socket connections
io.on('connection', (socket) => {
  console.log('Client connected');
  
  socket.on('disconnect', () => {
    console.log('Client disconnected');
  });
});

// Start recording and transcription
console.log('Starting transcription service...');

let recognizeStream;
let recordingStream;
let silenceTimer;
let lastActivity = Date.now();
const SILENCE_TIMEOUT = 5000; // 5 seconds

function createRecognizeStream() {
  recognizeStream = client
    .streamingRecognize(request)
    .on('error', (error) => {
      console.error('Error:', error);
      io.emit('error', error.message);
      
      // Attempt to restart on any error
      setTimeout(restartStream, 1000);
    })
    .on('data', data => {
      if (data.results[0] && data.results[0].alternatives[0]) {
        const transcript = data.results[0].alternatives[0].transcript;
        const isFinal = data.results[0].isFinal;
        
        // Update last activity time
        lastActivity = Date.now();
        
        // Emit to all connected clients
        io.emit('transcription', {
          text: transcript,
          isFinal: isFinal,
          timestamp: new Date().toISOString()
        });
        
        if (isFinal) {
          console.log('Final:', transcript);
          
          // Always inject non-empty final transcriptions
          if (transcript.trim()) {
            injectTextToActiveField(transcript, true);
          }
        } else {
          console.log('Interim:', transcript);
        }
      }
    });

  return recognizeStream;
}

function restartStream() {
  console.log('Restarting transcription stream...');
  
  // End the current recognize stream
  if (recognizeStream) {
    recognizeStream.end();
  }
  
  // Create new recognize stream
  const newRecognizeStream = createRecognizeStream();
  
  // Reconnect the recording stream to the new recognize stream
  if (recordingStream) {
    recordingStream.unpipe();
    recordingStream.pipe(newRecognizeStream);
  }
  
  console.log('Stream restarted successfully');
}

// Create initial recognize stream
createRecognizeStream();

// Start recording
recordingStream = recorder
  .record({
    sampleRateHertz: sampleRateHertz,
    threshold: 0,
    verbose: false,
    recordProgram: 'rec',
    silence: '10.0',
  })
  .stream()
  .on('error', console.error);

recordingStream.pipe(recognizeStream);

// Check for silence periodically
setInterval(() => {
  const timeSinceLastActivity = Date.now() - lastActivity;
  
  if (timeSinceLastActivity > SILENCE_TIMEOUT) {
    console.log('No activity for 5 seconds - cost saving mode');
    io.emit('status', { message: 'Paused - will resume when you speak', isPaused: true });
  } else {
    io.emit('status', { message: 'Active', isPaused: false });
  }
}, 1000);

// Handle uncaught exceptions to prevent server crashes
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  setTimeout(restartStream, 1000);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  setTimeout(restartStream, 1000);
});

// Function to inject text into the active text field using AppleScript
function injectTextToActiveField(text, pressEnter = true) {
  const scriptPath = path.join(__dirname, 'type-text.applescript');
  const escapedText = text.replace(/"/g, '\\"').replace(/'/g, "\\'");
  
  // Type the text
  const typeCommand = `osascript ${scriptPath} "${escapedText}"`;
  
  exec(typeCommand, (error) => {
    if (error) {
      console.error('Error injecting text:', error);
      io.emit('injection_error', { error: error.message });
    } else {
      console.log('Text injected successfully');
      io.emit('injection_success', { text });
      
      // Wait 1 second then press Enter if requested
      if (pressEnter) {
        setTimeout(() => {
          const enterCommand = `osascript -e 'tell application "System Events" to key code 36'`;
          exec(enterCommand, (error) => {
            if (error) {
              console.error('Error pressing Enter:', error);
            } else {
              console.log('Enter pressed');
            }
          });
        }, 1000);
      }
    }
  });
}

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
  console.log('Open this URL in your browser to see live transcriptions');
});

// Handle shutdown
process.on('SIGINT', () => {
  console.log('\nStopping transcription server...');
  
  // End streams
  if (recognizeStream) {
    recognizeStream.end();
  }
  if (recordingStream) {
    recordingStream.destroy();
  }
  
  server.close();
  process.exit();
});