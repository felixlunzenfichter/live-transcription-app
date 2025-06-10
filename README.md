# Voice Transcription Auto-Type System

Real-time speech transcription that automatically types into any active text field on macOS.

## Features

- Live voice transcription using Google Speech-to-Text API
- Auto-typing into any active text field using AppleScript
- Automatic Enter key press after each completed sentence
- Web interface to monitor transcription status
- Simple toggle to enable/disable auto-typing
- Continuous streaming recognition with automatic restarts

## Quick Start

```bash
# Start the voice transcription system
./start-voice-control.sh

# Or use the simpler version
./run-voice.sh
```

## How It Works

1. The system continuously transcribes your voice using Google's Speech API
2. Shows interim results in orange as you speak
3. When you finish speaking (detected by silence), it shows final text in green
4. With auto-type enabled, it automatically types the final text into whatever text field has focus
5. After typing, it presses Enter to submit the text

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Set up Google Cloud credentials:
   - Create a Google Cloud project
   - Enable the Speech-to-Text API
   - Create a service account and download the JSON key
   - Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable or use `.env`

3. Test the auto-typing functionality:
   ```bash
   ./test-auto-type.sh
   ```

## Usage

1. Run the start script
2. A browser window will open at http://localhost:3000
3. Click "Enable Auto-Type" to activate automatic typing
4. Click in any text field (Terminal, text editor, browser, chat app, etc.)
5. Start speaking - your words will be typed automatically when you pause
6. Each sentence completion triggers the Enter key

## Files

- `server.js` - Main transcription server with WebSocket support
- `type-text.applescript` - AppleScript for typing text into active field
- `public/index.html` - Web interface with live transcription display
- `start-voice-control.sh` - Main startup script
- `run-voice.sh` - Simple startup script
- `test-auto-type.sh` - Test script for AppleScript functionality

## Requirements

- Node.js 14+
- Google Cloud account with Speech-to-Text API enabled
- macOS (for AppleScript functionality)
- Microphone access
- SoX (for audio recording) - install with `brew install sox` on macOS

## Troubleshooting

- If you get permission errors, you may need to grant Terminal/your app accessibility permissions in System Preferences > Security & Privacy > Privacy > Accessibility
- Make sure no other process is using port 3000
- Check that your Google Cloud credentials are properly configured