#!/bin/bash

# Watchdog script that monitors the transcription server
# Runs separately and types alerts into Terminal if server dies

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SERVER_PORT=3000
CHECK_INTERVAL=3  # Check every 3 seconds
RESTART_DELAY=5   # Wait 5 seconds before restart

# Function to type text into Terminal window
type_alert() {
    local message="$1"
    osascript "$SCRIPT_DIR/type-text.applescript" "[WATCHDOG] $message" "enter"
}

# Function to check if server process is running
is_server_running() {
    pgrep -f "node server.js" > /dev/null
    return $?
}

# Function to check if server is responding
is_server_responding() {
    curl -s -f -m 2 http://localhost:$SERVER_PORT > /dev/null 2>&1
    return $?
}

# Function to start the server
start_server() {
    cd "$SCRIPT_DIR"
    ./run-voice.sh &
    sleep $RESTART_DELAY
}

# Main watchdog loop
echo "Starting transcription server watchdog..."
type_alert "Watchdog started - monitoring transcription server"

# Track server state
was_running=false
was_responding=false
restart_count=0

while true; do
    is_running=false
    is_responding=false
    
    # Check if process exists
    if is_server_running; then
        is_running=true
        
        # Check if it's actually responding
        if is_server_responding; then
            is_responding=true
        fi
    fi
    
    # Detect state changes and act accordingly
    if ! $is_running && $was_running; then
        # Server just crashed!
        restart_count=$((restart_count + 1))
        type_alert "SERVER CRASHED! Attempt #$restart_count to restart..."
        start_server
        
    elif $is_running && ! $is_responding && $was_responding; then
        # Server is hung (process exists but not responding)
        type_alert "Server not responding! Killing and restarting..."
        pkill -f "node server.js"
        sleep 2
        restart_count=$((restart_count + 1))
        start_server
        
    elif ! $is_running && ! $was_running; then
        # Server isn't running at all (first start or persistent failure)
        if [ $restart_count -eq 0 ]; then
            type_alert "Server not running. Starting..."
        else
            type_alert "Server still down. Retrying..."
        fi
        restart_count=$((restart_count + 1))
        start_server
        
    elif $is_running && $is_responding && ! $was_responding; then
        # Server just came back online
        type_alert "Server is now responding normally"
        restart_count=0
    fi
    
    # Update state
    was_running=$is_running
    was_responding=$is_responding
    
    sleep $CHECK_INTERVAL
done