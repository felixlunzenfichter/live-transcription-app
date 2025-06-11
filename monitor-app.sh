#!/bin/bash

# Monitor script for live transcription app
# Checks if the server is running and types status messages into Terminal

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_FILE="$SCRIPT_DIR/monitor.log"
SERVER_PORT=3000
CHECK_INTERVAL=5  # Check every 5 seconds

# Function to type text into Terminal window
type_to_terminal() {
    local message="$1"
    osascript "$SCRIPT_DIR/type-text.applescript" "[MONITOR] $message" "enter"
}

# Function to check if server is running
check_server() {
    # Check if process is running
    if pgrep -f "node server.js" > /dev/null; then
        # Check if server is responding
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:$SERVER_PORT | grep -q "200"; then
            return 0  # Server is running and responding
        else
            return 2  # Process exists but not responding
        fi
    else
        return 1  # Process not running
    fi
}

# Main monitoring loop
echo "Starting transcription app monitor..." | tee -a "$LOG_FILE"
type_to_terminal "Transcription monitor started"

last_status=0
error_count=0

while true; do
    check_server
    current_status=$?
    
    if [ $current_status -ne 0 ]; then
        error_count=$((error_count + 1))
        
        if [ $current_status -eq 1 ]; then
            error_msg="Transcription server process not running! (Check #$error_count)"
        else
            error_msg="Transcription server not responding on port $SERVER_PORT! (Check #$error_count)"
        fi
        
        echo "$(date): $error_msg" | tee -a "$LOG_FILE"
        
        # Only type error message if status changed or every 5th error
        if [ $current_status -ne $last_status ] || [ $((error_count % 5)) -eq 0 ]; then
            type_to_terminal "$error_msg"
            
            # Try to restart the server
            type_to_terminal "Attempting to restart transcription server..."
            cd "$SCRIPT_DIR"
            ./run-voice.sh &
            sleep 5  # Give server time to start
        fi
    else
        # Server is running fine
        if [ $last_status -ne 0 ]; then
            success_msg="Transcription server is now running normally"
            echo "$(date): $success_msg" | tee -a "$LOG_FILE"
            type_to_terminal "$success_msg"
            error_count=0
        fi
    fi
    
    last_status=$current_status
    sleep $CHECK_INTERVAL
done