# Transcription Watchdog Context

## What we just implemented:
1. Created MCP watchdog server at `/Users/felixlunzenfichter/Documents/ClaudeCode/live-transcription-app/mcp-watchdog/`
2. Added it to Claude's MCP config as "transcription-watchdog"
3. The watchdog monitors the transcription server and auto-restarts if it crashes
4. Provides tools: get_transcription_status and restart_transcription

## Next steps after restart:
1. Test the MCP watchdog tools
2. Verify auto-restart works when server crashes
3. The watchdog should provide reliable status communication to Claude Code

## Current issue:
- Transcription server was disconnecting without Claude Code knowing
- MCP watchdog will solve this by providing reliable status updates