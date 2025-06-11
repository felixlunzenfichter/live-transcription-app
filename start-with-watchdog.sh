#!/bin/bash

# Start script that ensures both server and watchdog are running

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Starting voice transcription with watchdog..."

# Kill any existing instances
echo "Cleaning up old processes..."
pkill -f "watchdog.sh"
pkill -f "node server.js"
sleep 2

# Start the watchdog (which will start the server)
echo "Starting watchdog..."
"$SCRIPT_DIR/watchdog.sh" &

echo "System started. The watchdog will:"
echo "- Monitor the transcription server"
echo "- Type alerts if server crashes"
echo "- Automatically restart the server"
echo ""
echo "Press Ctrl+C to stop everything"

# Wait for interrupt
wait