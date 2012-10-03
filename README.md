ro-autosavechat
===============
I am not responsible for you getting banned.
To be sure, ask explicit permission from the server's GM you're in.
This isn't a macro to help you spam skills, it's for saving chat
logs when you're asleep, afk, or for those usually disconnected.
If your GM doesn't allow it, then sorry.

I"m not sure either if rRO GMs will allow it. lol.

Rename $CLIENT_NAME if it's not RebirthRO.
It has to match the title of the client window for it to be put to focus.

[Settings]
Chat Folder
 The folder where rRO stores /savechat output.
 If you have Open 1:1 Chat ____ on in Friends Setup:
  Those will save on the Whipser folder.
 If you have a /chat room on:
  Those will save on the same folder as Regular chat
 Both 1:1 Chat and /chat rooms:
  It will only save if /savechat is entered on the respective window
  Other chats will not be saved if /savechat is entered on the respective window
  It will not save if a macro (Alt+m) is used with the command /savechat
   using the macro will save Regular chats
Save Folder
 This is where the script stores the running chat logs
 It will name it {Year}-{Month}-{Day}-Chat_{LOG_NAME}.txt
Save Frequency/Every
 How long between /savechat's in seconds.
 Positive integers only.
Time Frequency
 What nTH save will "TIME: HH:MM:SS Adding x lines." be added.
 Ex. If Time Frequency is 6, then it will add that line every 6th save.
Use Alt Commands
 A value from -1 to 9.
 If it's -1, then it will send /savechat{ENTER}
  This will put you to login window 
Using Alt+[0-9] option is better than the /savechat{ENTER} option.
But you have the option to /savechat /chat rooms, but not whisper boxes.
If you do autosavechat /chat a chat room, the caret has to be in its
input field. It will not save your regular chats. Whisper boxes wont work
because it saves in another folder "Whisper", and I'm done with this
script. You can uncheck all (default) in the Friends Setup and have a
regular chat with "Whisper Display" on.