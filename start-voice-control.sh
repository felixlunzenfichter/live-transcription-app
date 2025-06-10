#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Starting Voice Transcription System..."
echo "======================================"
echo ""

# Check if server is already running
if lsof -i :3000 > /dev/null 2>&1; then
    echo "⚠️  Port 3000 is already in use. Stopping existing process..."
    pkill -f "node server.js" || true
    sleep 2
fi

# Start the transcription server
echo "1. Starting transcription server..."
cd "$SCRIPT_DIR"
npm start &
SERVER_PID=$!

# Wait for server to start
echo "   Waiting for server to start..."
sleep 3

# Open browser
echo "2. Opening browser at http://localhost:3000..."
open http://localhost:3000

echo ""
echo "✅ Voice Transcription System Started!"
echo "======================================"
echo ""
echo "🎤 TRANSCRIPTION IS ACTIVE"
echo ""
echo "- Click 'Enable Auto-Type' in the browser to start auto-typing"
echo "- Position your cursor in any text field"
echo "- Speak naturally and your words will be typed automatically"
echo "- A period of silence will trigger the Enter key"
echo ""
echo "To stop: Press Ctrl+C"
echo ""

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "Shutting down transcription system..."
    kill $SERVER_PID 2>/dev/null || true
    pkill -f "node server.js" || true
    echo "Done."
    exit 0
}

# Set trap for cleanup
trap cleanup INT TERM

# Keep the script running
while true; do
    sleep 1
done