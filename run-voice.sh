#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "Starting Voice Transcription..."
echo "=============================="

# Kill any existing server
pkill -f "node server.js" || true
sleep 1

# Start transcription server in background
echo "Starting transcription server..."
npm start &
SERVER_PID=$!
sleep 3

# Open browser
echo "Opening browser..."
open http://localhost:3000

echo ""
echo "✅ VOICE TRANSCRIPTION ACTIVE"
echo ""
echo "1. Click 'Enable Auto-Type' in the browser"
echo "2. Click in any text field where you want to type"
echo "3. Start speaking - your words will be typed automatically!"
echo ""
echo "Press Ctrl+C to stop"

# Cleanup on exit
cleanup() {
    echo "Stopping..."
    kill $SERVER_PID 2>/dev/null
    exit 0
}

trap cleanup INT TERM

# Wait
wait $SERVER_PID