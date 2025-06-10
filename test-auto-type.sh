#!/bin/bash

echo "Testing AppleScript auto-typing..."
echo "================================="
echo ""
echo "This will type some test text in 3 seconds."
echo "Please click in a text field where you want the text to appear!"
echo ""
echo "3..."
sleep 1
echo "2..."
sleep 1
echo "1..."
sleep 1

# Test the AppleScript
osascript type-text.applescript "Hello, this is a test of the voice transcription auto-typing system!" enter

echo ""
echo "Done! The text should have been typed and Enter pressed."