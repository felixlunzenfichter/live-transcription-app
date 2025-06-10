# Voice Transcription Auto-Type Usage Guide

## How the System Works

1. **Live Transcription**: The system continuously listens to your voice and shows:
   - **Orange text**: Interim results (what it thinks you're saying)
   - **Green text**: Final results (what it confirmed you said)

2. **Auto-Typing**: When enabled, the system will:
   - Wait for you to finish speaking (detected by a pause)
   - Type the final transcription into whatever text field has focus
   - Wait 1 second
   - Press Enter to submit

## Best Practices

1. **Clear Speech**: Speak clearly and at a moderate pace
2. **Natural Pauses**: Pause naturally between sentences to trigger completion
3. **Text Field Focus**: Make sure your cursor is in the text field where you want to type
4. **One Sentence at a Time**: The system works best with single sentences or short phrases

## What You'll See

- The web interface shows interim results in orange as you speak
- When you pause, it shows the final text in green
- If auto-typing is enabled, that final text is typed into your active field
- After 1 second, Enter is pressed automatically

## Tips

- Click "Disable Auto-Type" if you just want to see transcriptions without typing
- The system only types the final (green) text, not the interim (orange) text
- Empty transcriptions are ignored (won't type or press Enter)