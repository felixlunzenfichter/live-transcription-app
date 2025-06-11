on run argv
    if (count of argv) > 0 then
        set textToType to item 1 of argv
        
        -- Bring Terminal to the foreground
        tell application "Terminal"
            activate
        end tell
        
        -- Small delay to ensure Terminal is active
        delay 0.1
        
        -- Type the text into Terminal
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