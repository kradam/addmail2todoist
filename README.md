# addmail2todoist
Apple Script adding selected message in Apple Mail to Todoist.

This script if for people who use Apple Mail and Todoist Premium. 

##Features:

* Creating Todoist taks based on selected Apple Mail message.
* Using subject of the message as a task name.
* Adding link to the message as task note. You can open email by one click in Todoist.
* Removing prefixes like "Re: " from subject.
* Possibility of changing task name in dialog window.
* Moving processed message to e.g. "Archive folder.

##Installing:

* Copy applescript to folder ~/Library/Scripts/Applications/Mail. Create this folder if it doesn't exist.
* Create in the same directory file todoist-token.txt containing Todoist API token. You can find it in Todoist settings. 
* Activate script menu in menubar, e.g. http://www.twdesigns.com/how_to/how_to_reveal_applescript_menu.php.
* You can set token file hidden to unclutter script menu.
* Using Mail select any message, click script menu and pick the script name. 


![Screenshot](/Apple.Mail.script.png)


There is similar script for MS Outlook: http://mhorner.blogspot.com/2015/01/create-new-todoist-task-from-mac-outlook.html
