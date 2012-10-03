ro-autosavechat
-------------
My IGN on rRO is merchantmanyie Loki. Email me at admin@hamanyie.com if  
you want to ask something about the script.  
This is an **Autoit** script to /savechat every x seconds.  
I took some of the code from Rahul's @jump script at forums.rebirthro.com  
This script must be ran as an Administrator.  

**Disclaimer: I am not responsible for you getting banned.**  
To be sure, ask explicit permission from the server's GM you're in.  
This isn't a macro to help you spam skills, it's for saving chat  
logs when you're asleep, afk, or for those usually disconnected.  
Even though that's the case, your GM may still not allow it. :(  

I"m not sure either if rRO GMs will allow it. lol.

Rename $CLIENT_NAME if it's not RebirthRO.  
It has to match the title of the client window for it to be put to focus.  

**[Settings]**  are saved as AutoSaveChat.ini in the same directory.  
Chat Folder, Default = "C:\Program Files (x86)\RebirthRO\Chat"  
* The folder where rRO stores /savechat output.
* If you have Open 1:1 Chat ____ on in Friends Setup:
 * Those will save on the Whipser folder.
* If you have a /chat room on:
 * Those will save on the same folder as Regular chat
* Both 1:1 Chat and /chat rooms:
 * It will only save if /savechat is entered on the respective window
 * Other chats will not be saved if /savechat is entered on the respective window
 * It will not save if a macro (Alt+m) is used with the command /savechat
   using the macro will save Regular chats  

Save Folder, Default = "C:\Program Files (x86)\RebirthRO\Chat"  
* This is where the script stores the running chat logs
* It will name it {Year}-{Month}-{Day}-Chat_{LOG_NAME}.txt

Save Frequency/Every, Default = 20  
* How long between /savechat's in seconds.
* Positive integers only.

Time Frequency, Default = 3 (Every 60 seconds)  
* What nTH save will "TIME: HH:MM:SS Adding x lines." be added.
* Ex. If Time Frequency is 6, then it will add that line every 6th save.

Use Alt Commands, Default = -1  
* A value from -1 to 9.
* If it's -1, then it will send /savechat{ENTER}
 * This will put you to login window if you're disconnected
 * You can save /chat rooms by using this option, but regular chat won't be saved.

Using Alt+[0-9] option is better than the /savechat{ENTER} option.  
In that it doesn't exit you to the login window if you do get disconnected.  

However, with the /savechat{ENTER} option you save /chat rooms.  
If you do autosavechat /chat a chat room, the caret has to be in its  
input field.

**[Other stuff]**  
Logs will appear on the script's main window and appended to *AutoSaveChat.log*  
file in the same directory as the script.  

**[Technical stuff??]**  
When it starts, it learns what files are on the Chat Folder.  
That way, the existing files are not read or deleted.  

When ran, sends /savechat{ENTER} or Alt+[0-9].  
Sometimes, it fails to send those input and the client won't savechat.  
It will recheck a maximum of `$MAX_CHECK_SAVED_CHAT_COUNT`.  
I conclude you have been disconnected if max is reached.  
If not, email me and tell me the details.  

It will delete the last saved chats after a new /savechat.  
That way matching what line is the last copied will be more accurate.  
Example scenario:
* Script runs
* Press Run
* /savechat
* Created Chat_All.txt
* Deletes nothing
* Read and append that, wait x seconds
* /savechat
* Created Chat_All_001.txt
* Delete Chat_All.txt
* Read and append that, wait x seconds
* /savechat
* Create Chat_All.txt
* Delete Chat_All_001.txt
* Read and append that, wait x seconds

If you exit, it will cleanup and delete the last file(s) supposedly deleted.