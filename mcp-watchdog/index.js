#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { exec } from 'child_process';
import { promisify } from 'util';
import path from 'path';
import { fileURLToPath } from 'url';

const execAsync = promisify(exec);
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const TRANSCRIPTION_DIR = path.join(__dirname, '..');

// Check intervals
const CHECK_INTERVAL = 3000; // 3 seconds
const SERVER_PORT = 3000;

// State tracking
let lastStatus = {
  serverRunning: false,
  serverResponding: false,
  message: 'Watchdog starting...'
};

// Helper to check if server process is running
async function isServerRunning() {
  try {
    const { stdout } = await execAsync("pgrep -f 'node.*server\\.js'");
    return stdout.trim().length > 0;
  } catch {
    return false;
  }
}

// Helper to check if server is responding
async function isServerResponding() {
  try {
    const { stdout } = await execAsync(`curl -s -o /dev/null -w "%{http_code}" http://localhost:${SERVER_PORT}`);
    return stdout.trim() === '200';
  } catch {
    return false;
  }
}

// Start the transcription server
async function startServer() {
  try {
    // Kill any existing processes first
    await execAsync("pkill -f 'node.*server\\.js'").catch(() => {});
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Start the server
    exec(`cd "${TRANSCRIPTION_DIR}" && ./run-voice.sh`, (error, stdout, stderr) => {
      if (error) {
        console.error('Server start error:', error);
      }
    });
    
    // Give it time to start
    await new Promise(resolve => setTimeout(resolve, 5000));
    
    return await isServerResponding();
  } catch (error) {
    console.error('Failed to start server:', error);
    return false;
  }
}

// Monitor the server
async function checkServerStatus() {
  const running = await isServerRunning();
  const responding = running ? await isServerResponding() : false;
  
  let statusChanged = false;
  let newMessage = '';
  
  if (!running) {
    newMessage = 'Transcription server not running';
    statusChanged = lastStatus.serverRunning !== running;
  } else if (!responding) {
    newMessage = 'Transcription server not responding';
    statusChanged = lastStatus.serverResponding !== responding;
  } else {
    newMessage = 'Transcription server is running normally';
    statusChanged = !lastStatus.serverRunning || !lastStatus.serverResponding;
  }
  
  if (statusChanged) {
    lastStatus = {
      serverRunning: running,
      serverResponding: responding,
      message: newMessage
    };
  }
  
  return lastStatus;
}

// Create MCP server
const server = new Server(
  {
    name: 'mcp-watchdog',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Tool to get current status
server.setRequestHandler('tools/list', async () => ({
  tools: [
    {
      name: 'get_transcription_status',
      description: 'Get the current status of the transcription server',
      inputSchema: {
        type: 'object',
        properties: {},
      },
    },
    {
      name: 'restart_transcription',
      description: 'Force restart the transcription server',
      inputSchema: {
        type: 'object',
        properties: {},
      },
    },
  ],
}));

// Handle tool calls
server.setRequestHandler('tools/call', async (request) => {
  const { name } = request.params;
  
  if (name === 'get_transcription_status') {
    const status = await checkServerStatus();
    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(status, null, 2),
        },
      ],
    };
  }
  
  if (name === 'restart_transcription') {
    const started = await startServer();
    return {
      content: [
        {
          type: 'text',
          text: started 
            ? 'Transcription server restarted successfully' 
            : 'Failed to restart transcription server',
        },
      ],
    };
  }
  
  throw new Error(`Unknown tool: ${name}`);
});

// Start monitoring loop
setInterval(async () => {
  const status = await checkServerStatus();
  if (status.message !== lastStatus.message) {
    console.error(`[WATCHDOG] ${status.message}`);
  }
}, CHECK_INTERVAL);

// Start the server
const transport = new StdioServerTransport();
await server.connect(transport);
console.error('MCP Watchdog server started');

// Initial check
checkServerStatus();