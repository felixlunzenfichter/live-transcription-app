on run argv
    if (count of argv) > 0 then
        set textToType to item 1 of argv
        
        -- Type the text into the currently active text field
        tell application "System Events"
            keystroke textToType
        end tell
        
        -- If a second argument is provided and is "enter", press Enter
        if (count of argv) > 1 and item 2 of argv is "enter" then
            tell application "System Events"
                key code 36 -- Enter key
            end tell
        end if
    end if
end run