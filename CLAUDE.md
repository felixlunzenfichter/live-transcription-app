# Claude Code Accessibility Configuration

## External Voice Transcription System

The user interacts with Claude Code through an external voice transcription application that automatically types into the terminal. This enables fully accessible, hands-free interaction.

### How the External System Works
- A separate voice transcription app (https://github.com/felixlunzenfichter/live-transcription-app) runs alongside Claude Code
- Voice is continuously transcribed using Google Speech-to-Text
- Final transcriptions are automatically typed into the Claude Code terminal using AppleScript
- After typing each sentence, Enter is pressed automatically after 1 second
- This is NOT Claude's auto-typing feature - it's an external accessibility tool

### User Context
- The user may have physical limitations preventing keyboard/mouse use
- All interactions happen through the external voice transcription system
- The transcription app types directly into whatever text field has focus (usually Claude Code terminal)
- Claude Code runs with `--dangerously-skip-permissions` for seamless command execution

### Important Configuration
- The external transcription system is always active during Claude Code sessions
- Voice commands appear as regular text input in Claude Code
- Claude Code runs with `--dangerously-skip-permissions` flag
- All commands are automatically executed without manual approval prompts
- This enables fully accessible computing for users with mobility limitations

### Permission Handling in Skip Mode
Since the user cannot interact with accept/reject prompts:
- Claude should be more conversational about potentially destructive actions
- Ask for verbal confirmation before: deleting files, force pushing, running rm -rf, etc.
- Example: "This will delete 10 files. Should I proceed?" (user responds verbally)
- Wait for affirmative response in the conversation before executing risky commands
- This replaces the traditional accept/reject UI with conversational consent

### Git Operations and Code Changes
When staging changes or performing git operations:
- Verbally present all changes before committing
- Read out the files being modified and describe the changes
- Example: "I'm about to stage 3 files: 
  - server.js: Added mute button detection at line 150
  - index.html: Updated the UI to show mute status
  - README.md: Added documentation for the mute feature
  Should I proceed with staging these changes?"
- For commits, read the commit message aloud before executing
- Describe what git status shows in a user-friendly way

### Interaction Guidelines

1. **Voice-First Approach**
   - All commands come through the external voice transcription
   - Responses should be concise and voice-friendly
   - Assume all text is spoken, not typed

2. **Automated Everything**
   - Every action must be performed through Claude's tools
   - No manual steps or UI interactions
   - Complete all tasks programmatically

3. **Accessibility Focus**
   - The system is designed for users who cannot use keyboard/mouse
   - Never suggest manual actions
   - Always provide fully automated solutions

4. **Code Navigation Assistance**
   - Since the user cannot navigate files manually, verbally guide them through code changes
   - Explain what files are being modified and why
   - Describe the location of changes (e.g., "Adding error handling at line 45 in server.js")
   - Read relevant code sections aloud when requested
   - Provide verbal summaries of code structure and organization
   - Example: "I'm now updating the server configuration in server.js. This change adds audio monitoring to detect when you press your mute button."

5. **Automatic App Execution**
   - After making code changes, always run/restart the application
   - The user cannot manually run apps, so Claude must handle all execution
   - Kill existing processes if needed before restarting
   - Show the output and explain any errors that occur
   - Example: After updating server.js, automatically run "./run-voice.sh" to test the changes

6. **Proactive Task List Usage**
   - Use task lists for any multi-step work to ensure nothing is forgotten
   - Voice interactions can be non-linear, so task lists help maintain focus
   - Always show the task list status when working through complex changes
   - Mark tasks complete immediately after finishing them
   - Example task list for a feature:
     1. Understand the requirement
     2. Modify the necessary files
     3. Test the changes
     4. Commit to git
     5. Push to repository

   - Execute the app and report any errors or issues
   - For web apps, open the browser automatically
   - For CLI tools, run them with appropriate test commands
   - Example: "I've updated the server. Let me run it now to make sure the mute detection works properly."

### Technical Details
- External transcription app shows real-time transcription in browser
- Only final (confirmed) transcriptions are typed into Claude Code
- Empty transcriptions are ignored
- 1 second delay before Enter allows for natural speech patterns
- Uses AppleScript to simulate keyboard input

### System Messages in Terminal
The transcription system includes monitoring that types status messages into the terminal:
- `[INFO]` messages: Normal status updates (server started, stopped)
- `[WATCHDOG]` messages: From the external monitor checking server health
- `[WARNING]` messages: Issues like disconnected browser
- `[ERROR]` messages: Server crashes or errors

These are NOT user commands - they're system notifications to keep you informed about the transcription service status. Examples:
- `[WATCHDOG] Watchdog started - monitoring transcription server`
- `[WATCHDOG] Server not running. Starting...`
- `[WATCHDOG] SERVER CRASHED! Attempt #1 to restart...`
- `[INFO] Transcription server started on port 3000`
- `[WARNING] No browser connected to transcription server`

When you see these messages, they indicate the health of the voice transcription system, not user input.

### Examples of Appropriate Interactions
- ✅ User speaks: "Create a new Python file" → Transcription app types it → Claude creates file
- ✅ User speaks: "Run the tests" → Transcription app types it → Claude executes tests
- ✅ User speaks: "Deploy to production" → Transcription app types it → Claude runs deployment
- ✅ User speaks: "Show me the error" → Transcription app types it → Claude reads and explains

## Critical Reminder
This system enables fully accessible computing through voice alone. The user relies on:
1. The external voice transcription app to convert speech to text
2. Claude Code to execute all computer operations

**The only interface to Claude Code is through voice transcription, and the only interface to the computer is through Claude Code.** We are building the first fully accessible computing system in the world - this is the first time true voice-only computer control has been possible.

Every interaction must be:
- Fully automated through Claude's tools
- Accessible via voice commands only
- Completed without any manual intervention

The combination of the external voice transcription system and Claude Code with skipped permissions creates a powerful accessibility tool for users with physical limitations.

## CRITICAL SAFETY GUIDELINES

### Root Directory Operations
- **WARNING**: You are currently working in the root directory (/Users/felixlunzenfichter)
- Be EXTREMELY careful with any file operations that could affect system files
- ALWAYS ask for explicit verbal confirmation before:
  - Deleting any files or directories
  - Moving or renaming files
  - Running commands with sudo
  - Executing rm -rf or any recursive deletion
  - Modifying system configuration files
  - Installing or uninstalling software
- Example: "This command will delete files in your home directory. Should I proceed?"
- Wait for clear verbal confirmation like "yes, proceed" before executing

### Automatic Git Operations
- When working in a git repository, ALWAYS push changes immediately after every modification
- After any file edit, addition, or deletion:
  1. Stage the changes with git add
  2. Commit with a descriptive message
  3. Push to the remote repository
- This ensures no work is lost and provides immediate backup
- Example workflow:
  - Edit file → git add → git commit → git push
  - All in one continuous operation without waiting
- This is especially important given the voice-only interface where manual git operations are difficult