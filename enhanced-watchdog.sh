#!/bin/bash

# Enhanced watchdog that monitors multiple aspects of the transcription system

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SERVER_PORT=3000
CHECK_INTERVAL=3
RESTART_DELAY=5
BROWSER_CHECK_DELAY=15  # Give browser time to connect after restart

# Function to type text into Terminal window
type_alert() {
    local message="$1"
    osascript "$SCRIPT_DIR/type-text.applescript" "[WATCHDOG] $message" "enter"
}

# Check if server process is running
is_server_running() {
    pgrep -f "node server.js" > /dev/null || pgrep -f "node.*server\.js" > /dev/null
}

# Check if server HTTP endpoint responds
is_server_responding() {
    curl -s -f -m 2 http://localhost:$SERVER_PORT > /dev/null 2>&1
}

# Check if browser is connected (by checking server log)
is_browser_connected() {
    # Look for recent "Client connected" in server output
    if [ -f "$SCRIPT_DIR/server.log" ]; then
        # Check if there was a connection in the last 30 seconds
        local last_connect=$(grep "Client connected" "$SCRIPT_DIR/server.log" 2>/dev/null | tail -1)
        if [ -n "$last_connect" ]; then
            return 0
        fi
    fi
    return 1
}

# Kill all related processes
kill_all_processes() {
    type_alert "Killing all transcription processes..."
    pkill -f "node.*server\.js"
    pkill -f "run-voice.sh"
    sleep 2
}

# Start the server with logging
start_server() {
    cd "$SCRIPT_DIR"
    type_alert "Starting transcription server..."
    
    # Start with output logged for monitoring
    ./run-voice.sh > server.log 2>&1 &
    
    sleep $RESTART_DELAY
    
    # Check if it actually started
    if is_server_running && is_server_responding; then
        type_alert "Server started successfully"
        return 0
    else
        type_alert "Server failed to start properly!"
        return 1
    fi
}

# Main monitoring loop
echo "Starting enhanced transcription watchdog..."
type_alert "Enhanced watchdog active - monitoring all components"

# Clear old log
rm -f "$SCRIPT_DIR/server.log"

# State tracking
server_was_up=false
browser_was_connected=false
restart_count=0
last_browser_check=0
consecutive_failures=0

while true; do
    current_time=$(date +%s)
    
    # Check server status
    server_running=false
    server_responding=false
    browser_connected=false
    
    if is_server_running; then
        server_running=true
        if is_server_responding; then
            server_responding=true
            
            # Only check browser connection periodically
            if [ $((current_time - last_browser_check)) -gt 10 ]; then
                if is_browser_connected; then
                    browser_connected=true
                fi
                last_browser_check=$current_time
            else
                # Use previous state
                browser_connected=$browser_was_connected
            fi
        fi
    fi
    
    # Determine what action to take
    needs_restart=false
    reason=""
    
    if ! $server_running; then
        needs_restart=true
        reason="Server process not running"
    elif ! $server_responding; then
        needs_restart=true
        reason="Server not responding to HTTP"
    elif $server_was_up && ! $browser_connected && [ $restart_count -gt 0 ]; then
        # Only worry about browser after we've had at least one successful start
        if [ $((current_time - last_browser_check)) -gt $BROWSER_CHECK_DELAY ]; then
            type_alert "WARNING: No browser connected for extended time"
            # Don't restart just for browser, but alert user
        fi
    fi
    
    # Handle restart if needed
    if $needs_restart; then
        consecutive_failures=$((consecutive_failures + 1))
        
        if [ $consecutive_failures -gt 3 ]; then
            type_alert "Multiple failures detected - performing full cleanup"
            kill_all_processes
            consecutive_failures=0
        fi
        
        restart_count=$((restart_count + 1))
        type_alert "$reason - Restart attempt #$restart_count"
        
        if $server_running; then
            # Process exists but not working
            kill_all_processes
        fi
        
        if start_server; then
            type_alert "Restart successful"
            consecutive_failures=0
        else
            type_alert "Restart failed - will retry"
        fi
        
        # Give extra time after restart
        sleep $BROWSER_CHECK_DELAY
    else
        # Everything is running fine
        if ! $server_was_up && $server_responding; then
            type_alert "All systems operational"
            restart_count=0
            consecutive_failures=0
        fi
    fi
    
    # Update state
    server_was_up=$server_responding
    browser_was_connected=$browser_connected
    
    sleep $CHECK_INTERVAL
done