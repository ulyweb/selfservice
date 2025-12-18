-- Personal Print Manager (PPM) REMOVAL TOOL - V6 (Shell Based)
-- REWRITTEN TO BYPASS FINDER ERRORS COMPLETELY
-- This version uses direct system commands to verify and delete files.

-- 1. Setup Paths (Using pure POSIX paths to avoid Finder conflicts)
set userHome to POSIX path of (path to home folder)
-- Handle potential trailing slash in home path
if userHome ends with "/" then set userHome to text 1 thru -2 of userHome

-- Define Targets
set appPath to "/Applications/Personal Print Manager.app"
set configFolder to userHome & "/Library/Application Support/lrs.personalprint.manager"
set plistFile to userHome & "/Library/Preferences/com.lrs.personalprint.manager.plist"

-- 2. Verify Existence (Using System Shell 'test' command, not Finder)
set foundItems to {}

-- Check App
if (do shell script "[ -e " & quoted form of appPath & " ] && echo 'true' || echo 'false'") is "true" then
	set end of foundItems to appPath
end if

-- Check Config Folder
if (do shell script "[ -e " & quoted form of configFolder & " ] && echo 'true' || echo 'false'") is "true" then
	set end of foundItems to configFolder
end if

-- Check Plist File
if (do shell script "[ -e " & quoted form of plistFile & " ] && echo 'true' || echo 'false'") is "true" then
	set end of foundItems to plistFile
end if

-- 3. Exit if nothing found
if (count of foundItems) is 0 then
	display dialog "No Personal Print Manager files were found on this system." buttons {"OK"} default button "OK" with icon note
	return
end if

-- 4. Confirm Deletion
set listText to ""
repeat with i in foundItems
	set listText to listText & "• " & i & return
end repeat

display dialog "CONFIRM DELETION" & return & return & "The following files were found and will be PERMANENTLY DELETED:" & return & return & listText & return & "You must enter your Admin Password to authorize this." buttons {"Cancel", "Delete"} default button "Delete" with icon caution

if button returned of result is "Delete" then
	
	-- 5. Construct the Master Command
	-- This runs as a single atomic operation with Admin privileges.
	set shellCmd to ""
	
	-- Force Quit commands (fail silently if app isn't running)
	set shellCmd to shellCmd & "killall 'Personal Print Manager' 2>/dev/null; "
	set shellCmd to shellCmd & "killall 'com.lrs.personalprint.manager' 2>/dev/null; "
	
	-- Delete commands (rm -rf forces deletion of folders and files)
	repeat with i in foundItems
		set shellCmd to shellCmd & "rm -rf " & quoted form of i & "; "
	end repeat
	
	try
		-- 6. Execute (Prompts for Password)
		do shell script shellCmd with administrator privileges
		
		display dialog "SUCCESS" & return & return & "All Personal Print Manager files have been successfully removed." & return & "Please restart your Mac before reinstalling." buttons {"OK"} default button "OK" with icon note
		
	on error errMsg
		if errMsg contains "User canceled" then
			return
		else
			display alert "Error During Deletion" message "The system returned this error: " & errMsg
		end if
	end try
end if
