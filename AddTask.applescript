(*
	Create Todoist task from Apple Mail
	
	Github:
	https://github.com/kradam/addmail2todoist
	Todoist API:
	https://www.apichangelog.com/changes/51a11c78-3ca8-47c6-b03f-8d830b6e0485
	The idea based on: 
	http://mhorner.blogspot.com/2015/01/create-new-todoist-task-from-mac-outlook.html
*)

--
-- SOME CONFIG DATA
--
-- The name of the mailbox in the message account, to move message after creating task. Put "" to avoid moving. 
set destinationMailbox to "Archive"
-- Some prefixes to remove from the beginning of message subject. Feel free to add prefixes in your language.
set prefixesToRemove to {"re: ", "odp: ", "fw: ", "fwd: "}
-- Decide if you want to confirm name of created task. Defaut is message subject.
set askForTheName to true
-- Set the Todist API Token
set todoistToken to ""

-- END OF CONFIG DATA

on urlEncode(str)
	local str
	try
		return (do shell script "/bin/echo " & quoted form of str & " | perl -MURI::Escape -lne 'print uri_escape($_)'")
	on error eMsg number eNum
		error "Can't urlEncode: " & eMsg number eNum
	end try
end urlEncode

tell application "Mail"
	
	set selectedMessages to get selection
	
	if (count of selectedMessages) is not 1 then
		display dialog "Please select the single message and then run this script." with icon 1
		return
	end if
	
	-- repeat isn't neccessay for the single message, but it is here for future purposes	
	repeat with theMessage in selectedMessages
		
		set theName to subject of theMessage -- subject is the name of the task
		set theBody to content of theMessage -- body is for context in the task's note
		
		repeat with prefix in prefixesToRemove
			if theName starts with prefix then
				set theName to rich text (1 + (length of prefix)) thru -1 of theName
				exit repeat -- removing one prefix is enough
			end if
		end repeat
		
		if askForTheName then
			set result to display dialog "Enter task name" default answer theName
			if button returned of result is "OK" then
				set theName to text returned of result
				-- display dialog "name: " & theName
			else
				return
			end if
		end if
		
		-- URL for Apple Mail Message, adding to the task note. Click in Todoist to open message in Mail.
		set theURL to "message://%3c" & theMessage's message id & "%3e"
		set theTitle to "[" & my urlEncode(theName) & "](" & theURL & ")"
		set theReference to my urlEncode(theBody)
		
		set myUUID1 to do shell script "uuidgen"
		set myUUID2 to do shell script "uuidgen"
		set myUUID3 to do shell script "uuidgen"
		set tempUUID1 to do shell script "uuidgen"
		set tempUUID2 to do shell script "uuidgen"
		set tempUUID3 to do shell script "uuidgen"
		
		-- crazy, no string interpolation in AS; see todoist doc
		-- use tempUUID of create task call as reference to it for adding note there. 
		set curl to "curl https://todoist.com/API/v7/sync -d token=" & todoistToken & " -d commands='[{\"type\": \"item_add\", \"temp_id\": \"" & tempUUID1 & "\", \"uuid\": \"" & myUUID1 & "\", \"args\": {\"content\": \"" & theTitle & "\"}}, " & "{\"type\": \"note_add\", \"temp_id\": \"" & tempUUID2 & "\", \"uuid\": \"" & myUUID2 & "\", \"args\": {\"content\": \"" & theURL & "\", \"item_id\": \"" & tempUUID1 & "\"}}, " & "{\"type\": \"note_add\", \"temp_id\": \"" & tempUUID3 & "\", \"uuid\": \"" & myUUID3 & "\", \"args\": {\"content\": \"" & theReference & "\", \"item_id\": \"" & tempUUID1 & "\"}}" & "]'"
		
		-- display dialog curl
		
		set response to do shell script curl
		
		if response does not start with "{\"seq_no_global\":" then
			display alert "Adding task failed" message response as critical
		else
			if destinationMailbox is not equal to "" then
				move theMessage to mailbox destinationMailbox of account (name of (account of (mailbox of theMessage)))
			end if
		end if
		
		-- display dialog "ok!"
		
	end repeat
	
end tell
