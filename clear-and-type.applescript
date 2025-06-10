on run argv
    if (count of argv) > 0 then
        set textToType to item 1 of argv
        
        tell application "System Events"
            -- Select all text with Cmd+A
            keystroke "a" using command down
            -- Small delay
            delay 0.05
            -- Type the new text (this replaces the selection)
            keystroke textToType
        end tell
    end if
end run