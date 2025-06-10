#!/bin/bash

echo "Installing Voice Control as startup item..."
echo "=========================================="
echo ""

# Copy the plist to LaunchAgents
cp com.claude.voicecontrol.plist ~/Library/LaunchAgents/

# Load the launch agent
launchctl load ~/Library/LaunchAgents/com.claude.voicecontrol.plist

echo "✅ Voice Control will now start automatically at login!"
echo ""
echo "To uninstall:"
echo "launchctl unload ~/Library/LaunchAgents/com.claude.voicecontrol.plist"
echo "rm ~/Library/LaunchAgents/com.claude.voicecontrol.plist"