; Script to /savechat every x seconds
; and add time every x*y seconds (Not servertime, because it will not appear in chat if you didn't check the green log)
; Got pieces of code from Rahul's @jump script at the forums. Thank you very much.
; Also got code from examples on Autoit documentation
; New to Autoit and don't have much time.
; IGN merchantmanyie Loki
#include <File.au3>
#include <Date.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
#include "GUIYashied.au3" ; From a post by Yashied at autoitscript.com, user function
#RequireAdmin
Opt("GUIResizeMode", $GUI_DOCKAUTO)
#Region ### START Koda GUI section ### Form=C:\Users\jerielmari\Documents\Ragnarok\Form1.kxf
Opt("GUIOnEventMode", 1)  ; Change to OnEvent mode
$Form1_1 = GUICreate("Autosavechat hamanyie", 749, 699, 245, 210)
GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEClicked")
GUICtrlSetResizing(-1, $GUI_DOCKAUTO+$GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$EditInformation = GUICtrlCreateEdit("", 152, 2, 445, 110, BitOR($ES_CENTER,$ES_READONLY,$ES_WANTRETURN), 0)
GUICtrlSetFont(-1, 9, 800, 0, "MS Sans Serif")
GUICtrlSetResizing(-1, $GUI_DOCKAUTO)
$EditLog = GUICtrlCreateEdit("", 2, 114, 745, 575, BitOR($GUI_SS_DEFAULT_EDIT,$ES_READONLY))
$ButtonRun = GUICtrlCreateButton("Run", 648, 16, 81, 25)
$ButtonSetup = GUICtrlCreateButton("Setup", 648, 48, 81, 25)
$LabelStatus = GUICtrlCreateLabel("", 8, 16, 83, 28)
GUICtrlSetFont(-1, 16, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x008000)
$ProgressSave = GUICtrlCreateProgress(8, 48, 89, 17)
GUICtrlCreateTabItem("")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Func CLOSEClicked()
  ;Note: at this point @GUI_CTRLID would equal $GUI_EVENT_CLOSE,
  ;and @GUI_WINHANDLE would equal $mainwindow
  DeleteSetDeleteFiles() ; Tidy up, delete those files last made by /savechat, if any.
  Exit
EndFunc

#region Constants and Globals
Const $SAVE_FREQ_DEFAULT = 20, $TIME_FREQ_DEFAULT = 3,$CHAT_FOLDER_DEFAULT = "C:\Program Files (x86)\RebirthRO\Chat"
Const $CLIENT_NAME = "RebirthRO", $ERROR_MESSAGE = "Please email details to admin@hamanyie.com", $MSG_TIMEOUT = 90, $CHAT_MAX_COMPARE_LINES = 10
Const $USE_ALT_DEFAULT = -1, $MAX_CHECK_SAVED_CHAT_COUNT = 10
Global $iniFile, $chatFolder = $CHAT_FOLDER_DEFAULT, $saveFolder = $CHAT_FOLDER_DEFAULT, $saveFreq = $SAVE_FREQ_DEFAULT, $timeFreq = $TIME_FREQ_DEFAULT, $useAlt = $USE_ALT_DEFAULT
Global $deleteChatFiles[1], $existingChatFiles[1]
#endregion
; Initialize array
$deleteChatFiles[0] = 0
$existingChatFiles[0] = 0
#region Initializing the script
$iniFile = StringLeft(@ScriptFullPath, StringLen(@ScriptFullPath) - 3) & "ini"
If FileExists($iniFile) = 1 Then
	GetLoadedConfig()
Else
	While 1
		$choice = MsgBox(35, "Initial Setup", "No configuration found." & @CRLF & "Would you like to set it? Otherwise, it will use default configuration.")
		Switch $choice
			Case 6 ; Yes
				If ChangeIniSetup() = 1 Then
					ExitLoop
				EndIf
			Case 7 ; No
				SetDefaultIniSetup()
				ExitLoop
			Case Else ; Cancel
				CLOSEClicked()
		EndSwitch
	WEnd
EndIf
SetExistingFiles() ; Initialize it so we know what files existed before and we won't touch those
SetGUIMessagesAndEvents()
Func ChangeIniSetup()
	$chatFolder = FileSelectFolder("Select your RebirthRO chat folder.", "", 0, $chatFolder)
	If CheckErrorAdminRights(@error) = 0 Then
		GetLoadedConfig()
		Return
	EndIf
	$saveFolder = FileSelectFolder("Select your script's save folder. Please select a different folder from chat folder.", "", 0, $saveFolder)
	If CheckErrorAdminRights(@error) = 0 Then
		GetLoadedConfig()
		Return
	EndIf
	$saveFreq = InputBox("Save Frequency", "How long in seconds would you want for the script to wait to savechat? Integers only please.", $saveFreq, "", 270, 140)
	If CheckErrorInputBox(@error) = 0 Then
		GetLoadedConfig()
		Return
	EndIf
	If StringIsInt($saveFreq) Then
		$saveFreq = Int($saveFreq)
		If $saveFreq < 1 Then
			MsgBox(64, "Save Frequency", "Put default of " & $SAVE_FREQ_DEFAULT & " since you put lesser than 1. Should be atleast 1.")
			$saveFreq = $SAVE_FREQ_DEFAULT
		EndIf
	Else
		MsgBox(64, "Save Frequency", "Put default of " & $SAVE_FREQ_DEFAULT & " since you messed up with the input. Should have been only integers and no spaces.")
		$saveFreq = $SAVE_FREQ_DEFAULT
	EndIf
	$timeFreq = InputBox("Time Frequency", "How many saves you want before pushing current local time? 0 for none and integers only please. " & @CRLF & @CRLF & "Ex. If save frequency is 20, and time frequency is 3, then time will be added every 60 seconds.", $timeFreq, "", 280, 180)
	If CheckErrorInputBox(@error) = 0 Then
		GetLoadedConfig()
		Return
	EndIf
	If StringIsInt($timeFreq) Then
		$timeFreq = Int($timeFreq)
		If $timeFreq < 1 Then
			MsgBox(64, "Time Frequency", "Put default of " & $TIME_FREQ_DEFAULT & " since you put lesser than 1. Should be atleast 1.")
			$timeFreq = $TIME_FREQ_DEFAULT
		EndIf
	Else
		MsgBox(64, "Time Frequency", "Put default of " & $TIME_FREQ_DEFAULT & " since you messed up with the input. Should have been only integers and no spaces.")
		$timeFreq = $TIME_FREQ_DEFAULT
	EndIf
  	$useAlt = InputBox("Using Alt Commands", "Would you like to use Alt+[0-9] for /savechat?. " & @CRLF & "Please make sure it's setup in the client properly (Alt+m)." & @CRLF & @CRLF & "Enter -1 if you don't. (default)" & @CRLF & "Using -1 means it will type /savechat ENTER, outright DC you if you're disconnected", $useAlt, "", 350, 200)
	If CheckErrorInputBox(@error) = 0 Then
		GetLoadedConfig()
		Return
	EndIf
	If StringIsInt($useAlt) Then
		$useAlt = Int($useAlt)
 		If $useAlt < -1 Or $useAlt > 9 Then
			MsgBox(64, "Using Alt Commands", "Put default of " & $USE_ALT_DEFAULT & " since you put lesser than -1 or higher than 9.")
			$useAlt = $USE_ALT_DEFAULT
		EndIf
	Else
		MsgBox(64, "Using Alt Commands", "Put default of " & $USE_ALT_DEFAULT & " since you messed up with the input. Should have been only integers and no spaces.")
		$useAlt = $USE_ALT_DEFAULT
	EndIf
	WriteIniSetup()
	Return 1
EndFunc

Func WriteIniSetup()
	IniWrite($iniFile, "default", "chatfolder", $chatFolder)
	IniWrite($iniFile, "default", "savefolder", $saveFolder)
	IniWrite($iniFile, "default", "savefreq", $saveFreq)
	IniWrite($iniFile, "default", "timefreq", $timeFreq)
	Iniwrite($iniFile, "default", "usealt", $useAlt)
	SetLog("Saved setup.")
	GetLoadedConfig()
EndFunc

Func SetDefaultIniSetup()
	$chatFolder = $CHAT_FOLDER_DEFAULT
	$saveFolder = $CHAT_FOLDER_DEFAULT
	$saveFreq = $SAVE_FREQ_DEFAULT
	$timeFreq = $TIME_FREQ_DEFAULT
	$useAlt = $USE_ALT_DEFAULT
	WriteIniSetup()
EndFunc

Func GetLoadedConfig()
	$chatFolder = IniRead($iniFile, "default", "chatfolder", "")
	$saveFolder = IniRead($iniFile, "default", "savefolder", "")
	$saveFreq = Int(IniRead($iniFile, "default", "savefreq", $SAVE_FREQ_DEFAULT))
	$timeFreq = Int(IniRead($iniFile, "default", "timefreq", $TIME_FREQ_DEFAULT))
	$useAlt = Int(IniRead($iniFile, "default", "usealt", $USE_ALT_DEFAULT))
	Local $useAltMessage = "Use alt: No (Will type /savechat ENTER and outright DC you if you're disconnected.)"

	If $useAlt >= 0 Then
		$useAltMessage = "Using Alt+" & $useAlt & " to command savechat. Make sure this is correct on your client (Alt+m to check)."
	EndIf
	SetLog("Loaded setup:" & @CRLF & "Chat Folder: " & $chatFolder & @CRLF & "Save Folder: " & $saveFolder & @CRLF & "Save Every: " & $saveFreq & " second(s)" & @CRLF & "Time Frequency: " & $timeFreq & " (" & $timeFreq * $saveFreq & " seconds)" & @CRLF & $useAltMessage)
EndFunc
#endregion Region End initializing

HotKeySet("+!r", "StartAutoSave") ; Shift+Alt+r
HotKeySet("+!s", "ChangeIniSetup") ; Shift+Alt+s
;~ HotKeySet("+!h", "ShowHelp") ; Shift+Alt+h

#region Code from http://www.autoitscript.com/autoit3/docs/functions/HotKeySet.htm - I modified it a lot now.
Global $Paused = True, $Quitting
HotKeySet("{ESC}", "ToggleQuit")
;;;; Body of program would go here ;;;;
StartAutoSave()
;;;;;;;; Changed to quitting, instead of the examples pause
Func ToggleQuit()
    $Quitting = Not $Quitting
	If $Quitting Then
		SetLog("Script quitting. Press ESC to exit. Bye!")
		SetLabelStatus(2)
	Else
		CLOSEClicked()
	EndIf
    While $Quitting
        Sleep(100)
        ToolTip('Script is quitting. Press PAUSE/BREAK to exit.', 0, 0)
    WEnd
    ToolTip("")
EndFunc   ;==>ToggleQuit ToggleQuit
#endregion End Code from http://www.autoitscript.com/autoit3/docs/functions/HotKeySet.htm

#region Main part
Func ToggleRunStop()
	$Paused = Not $Paused
	If $Paused Then
		SetLabelStatus(3)
	Else
		SetLabelStatus(1)
	EndIf
EndFunc

Func StartAutoSave() ; make this the main body, since Closing event doesn't work if something else is main and this is ran.
	While $Paused
        Sleep(100)
    WEnd
    ToolTip("")
	Local $startTime = NowDateDiffFormat(), $timeCounter = $timeFreq ; So it would run initially
	SetLog("Autosave started.")
	If WinExists($CLIENT_NAME) = 0 Then
		MsgBox(48, "Error", "Please run " & $CLIENT_NAME & ". If using another client, " & $ERROR_MESSAGE, $MSG_TIMEOUT)
		SetLog("Error! Please run " & $CLIENT_NAME & ". If using another client, " & $ERROR_MESSAGE)
	Else
		SetLabelStatus(1)
		DoSaveChat($timeCounter)
		While 1
			While $Paused
				Sleep(100)
			WEnd
			Sleep(100)
			Local $timeDiff = _DateDiff("s", $startTime, NowDateDiffFormat())
			GUICtrlSetData($ProgressSave, ($timeDiff / $saveFreq) * 100)
			If  $timeDiff >= $saveFreq Then
				DoSaveChat($timeCounter)
				$startTime = NowDateDiffFormat()
			EndIf
		Wend
	EndIf
EndFunc

Func DoSaveChat(ByRef $timeCounter)
	$timeCounter += 1
	Local $addTime = False
	SetLog("Saving..")
	If $timeFreq > 0 And ($timeCounter >= $timeFreq) Then
		$timeCounter = 0
		$addTime = True
		SetLog("Time also added.")
	EndIf
	SaveChat($addTime)
EndFunc

Func SaveChat($addTime)
	Local $newChatFiles[1], $currentDate = @YEAR & "-" & @MON & "-" & @MDAY
	Local $checkSavedChatExistsCount = 0
	While 1
		; Make sure that the client is activated
		If WinActive($CLIENT_NAME) = 0 Then WinActivate($CLIENT_NAME)
		WinWaitActive($CLIENT_NAME)
		; Check if we're using Alt+[0-9] commands or manually entering /savechat
		If $useAlt > -1 Then
			SetLog("Sending: " & "Alt+" & $useAlt)
			Send("{ALTDOWN}" & $useAlt & "{ALTUP}")
		Else
			ToggleEnterOn()
			SetLog("Sending: " & "/savechat{ENTER}")
			Send("/savechat{ENTER}")
		EndIf
		Sleep(400) ; wait before checking
		$newChatFiles = GetSavedFiles()
		If $newChatFiles[0] = 0 Then
			$checkSavedChatExistsCount += 1
			If $checkSavedChatExistsCount >= $MAX_CHECK_SAVED_CHAT_COUNT Then
				MsgBox(48, "Error", "The " & $CLIENT_NAME & " Client most likely has been disconnected. Or autoscript can't send keys, rerun the script. If this is not the case, " & $ERROR_MESSAGE, $MSG_TIMEOUT)
				SetLog("Error! The " & $CLIENT_NAME & " Client most likely has been disconnected. Or autoscript can't send keys, rerun the script. If is still does not work, " & $ERROR_MESSAGE)
				ToggleQuit()
			Else
				SetLog("Failed to /savechat or you don't have any chat logs! Will try again.")
			EndIf
		Else
			ExitLoop
		EndIf
	WEnd
	For $i = 1 To $newChatFiles[0]
		If FileExists($newChatFiles[$i]) Then
			; Check if newChatFile is atleast 1 line. No point doing this if it's empty right
			Local $newChatLineCount = _FileCountLines($newChatFiles[$i])
			If $newChatLineCount > 0 Then
 				SubSaveChat($addTime, $newChatFiles[$i], $newChatLineCount, $currentDate) ; Lot's of nesting, so put I it in another function
			EndIf
		EndIf
	Next
EndFunc

Func SubSaveChat($addTime, $newChatFile, $newChatLineCount, $currentDate)
	Local $oldChatFile, $charsToRemoveRight = 4, $oldChatCompareLines[1]

	If StringRegExp(StringRight($newChatFile, 8), ".*_\d{3}\.txt") Then
		$charsToRemoveRight = 8
	EndIf
	$oldChatFile = $saveFolder & "\" & $currentDate & "-" & StringTrimRight(StringTrimLeft($newChatFile, StringLen($chatFolder) + 1), $charsToRemoveRight) & ".txt"

	If FileExists($oldChatFile) Then
		Local $oldChatLineCount = _FileCountLines($oldChatFile)
		; Read those last lines to compare with the newChatFile
		ReDim $oldChatCompareLines[$CHAT_MAX_COMPARE_LINES]
		Local $oldChatFileHandle = FileOpen($oldChatFile) ; Write mode, append to end of file
		CheckErrorFileOpen($oldChatFile, $oldChatFileHandle)
		$y = 0
		For $x = $oldChatLineCount To 1 Step -1
			If $y + 1 > $CHAT_MAX_COMPARE_LINES Then
				ExitLoop
			EndIf
			$oldChatCompareLines[$y] = FileReadLine($oldChatFileHandle, $x)
			CheckErrorFileRead($oldChatFile, @error)
			If  Not(StringLeft($oldChatCompareLines[$y], 5) == "TIME:") Then
				$y += 1
			EndIf
		Next
		Local $oldChatCompareCount = $y
		Local $newChatFileHandle = FileOpen($newChatFile)
		CheckErrorFileOpen($newChatFile, $newChatFileHandle)
		Local $newChatLineToStartCopy = 1
		Local $newChatLinesAdded = $newChatLineCount
		For $z = $newChatLineCount To 1 Step -1
			$newChatLine = FileReadLine($newChatFileHandle, $z)
			CheckErrorFileRead($newChatFile, @error)
			; Compare last line from old chat's last line to new chat's line.
			; Usually more efficient to compare last line to up.
			$isMatching = False
			If $oldChatCompareLines[0] == $newChatLine Then
				$isMatching = True
				; Found a match ^, so compare the rest.
  				For $zy = 1 To $oldChatCompareCount - 1
					If $z - $zy < 1 Then ; There's nothing to read and it's a match, so just stop, best case it's the actual last line to the old. Worse case, someone spammed chat.
						ExitLoop
					EndIf
					$newChatLine = FileReadLine($newChatFileHandle, $z - $zy)
					CheckErrorFileRead($newChatFile, @error)
					If NOT($newChatLine == $oldChatCompareLines[$zy]) Then
						$isMatching = False
						ExitLoop
					EndIf
				Next
			EndIf

			; Match, set newChatLineToStartCopy and ExitLoop
			If $isMatching Then
				$newChatLineToStartCopy = $z + 1
				$newChatLinesAdded = $newChatLineCount - $z
				ExitLoop
			EndIf
		Next
		Local $newChatLinesCopied = ($newChatLineCount - $newChatLineToStartCopy) + 1
		FileClose($oldChatFileHandle) ; Close it from read mode
		FileOpen($oldChatFile, 1) ; Open in write append mode
		; Add the lines to the old chat, starting from newChatLineToStartCopy
		If $addTime Then
			$isWriteSuccess = FileWriteLine($oldChatFileHandle, "TIME: " & @HOUR & ":" & @MIN & ":" & @SEC & " Adding " & $newChatLinesAdded & " lines." & @CRLF)
			CheckErrorFileWrite($oldChatFile, $isWriteSuccess)
		EndIf
		For $xyz = $newChatLineToStartCopy To $newChatLineCount
			$newChatLine = FileReadLine($newChatFileHandle, $xyz)
			CheckErrorFileRead($newChatFile, @error)
			$isWriteSuccess =FileWriteLine($oldChatFileHandle, $newChatLine & @CRLF)
			CheckErrorFileWrite($oldChatFile, $isWriteSuccess)
		Next
		; Close files
		FileClose($oldChatFileHandle)
		FileClose($newChatFileHandle)
		SetLog($oldChatFile & " exist." & @CRLF & $newChatLinesCopied & " lines copied from " & $newChatFile)
	Else
		SetLog($oldChatFile & " doesn't exist." & @CRLF & "Copying " & $newChatFile)
		CheckErrorFileCopy($newChatFile, FileCopy($newChatFile, $oldChatFile))
	EndIf
EndFunc
#endregion Main part

Func SetGUIMessagesAndEvents()
	GUICtrlSetData($EditInformation, @CRLF & "Auto savechat by hamanyie. Check my site hamanyie.com/ro (in progress)" & @CRLF & @CRLF & "Shift+Alt+R to start the saving or -->" & @CRLF & "Shift+Alt+S to change the setup or -->" & @CRLF & @CRLF & "Thank you Rahul, I copied some of your code from your @jump script.")
 	GUICtrlSetOnEvent($ButtonRun, "ToggleRunStop")
	GUICtrlSetOnEvent($ButtonSetup, "ChangeIniSetup")
	SetLabelStatus(3)
EndFunc

#region Get functions
Func GetSavedFiles()
	Local $tChatFiles[1], $savedChatFiles[1], $sChatFiles, $sDelim = "|", $newFile
	$tChatFiles = _FileListToArray($chatFolder, "*", 1)
	If @error > 0 Then
		ReDim $tChatFiles[1]
		$tChatFiles[0] = 0
	EndIf
	For $i = 1 To $tChatFiles[0]
		$newFile = True
		$tChatFiles[$i] = $chatFolder & "\" & $tChatFiles[$i] ; append the folder path
		For $x = 1 To $existingChatFiles[0] ; Check if it's a previously existing file when script was first ran.
			If $existingChatFiles[$x] = $tChatFiles[$i]Then
				$newFile = False
				ExitLoop
			EndIf
		Next
		If $newFile Then ; If it's not an existing file when script was ran.
			For $xx = 1 To $deleteChatFiles[0] ; Check if it's in the queue for deletion.
				If $deleteChatFiles[$xx] = $tChatFiles[$i]Then
					$newFile = False
					ExitLoop
				EndIf
			Next
		EndIf
		If $newFile Then
			$sChatFiles &= $sDelim & $tChatFiles[$i]
		EndIf
	Next
	If StringLen($sChatFiles) > 1 Then
		$savedChatFiles = StringSplit(StringTrimLeft($sChatFiles, 1), $sDelim)
		DeleteSetDeleteFiles() ; Delete previous queue of files to be deleted
		SetDeleteFiles($savedChatFiles) ; Set what will be deleted next
	Else
		$savedChatFiles[0] = 0
	EndIf
	Return $savedChatFiles
EndFunc
#endregion Get functions

#region Set functions
; Files that will be deleted next
; Don't delete files immediatelly after /savechat
; This way the next /savechat will have a different number suffix
; That will be handy during comparison on which line was saved last.
Func SetDeleteFiles($sChatFiles)
	ReDim $deleteChatFiles[$sChatFiles[0] + 1]
	$deleteChatFiles[0] = $sChatFiles[0]
	For $i = 1 To $deleteChatFiles[0]
		$deleteChatFiles[$i] = $sChatFiles[$i]
	Next
	Local $stringids
	For $bla In $deleteChatFiles
		$stringids &= $bla & @CRLF
	Next
EndFunc

Func SetExistingFiles()
	$existingChatFiles = _FileListToArray($chatFolder, "*", 1)
	If @error > 0 Then
		Global $existingChatFiles[1]
		$existingChatFiles[0] = 0
	Else
		; Append folder path
		For $i = 1 To $existingChatFiles[0]
			$existingChatFiles[$i] = $chatFolder & "\" & $existingChatFiles[$i]
		Next
	EndIf
EndFunc

Func SetLog($logMessage)
	_GUICtrlEdit_SetPos($EditLog, -1, -1)
	Local $logMessageWithTime = _Now() & ": " & $logMessage & @CRLF
	GUICtrlSetData($EditLog, $logMessageWithTime, "append")
	Local $logFileHandle = FileOpen(@ScriptDir & "\" & "AutoSaveChat.log", 1) ; append mode
	Local $success = FileWriteLine($logFileHandle, $logMessageWithTime)
	FileClose($logFileHandle)
EndFunc

Func SetLabelStatus($switchCase)
	Switch $switchCase
		Case 1
			GUICtrlSetData($LabelStatus, "Running")
			GUICtrlSetColor($LabelStatus, 0x008000)
			GUICtrlSetData($ButtonRun, "Stop")
		Case 2
			GUICtrlSetData($LabelStatus, "Quitting")
			GUICtrlSetColor($LabelStatus, 0xFF0000)
		Case 3
			GUICtrlSetData($LabelStatus, "Stopped")
 			GUICtrlSetColor($LabelStatus, 0xCCCCCC)
			GUICtrlSetData($ButtonRun, "Run")
		Case Else
			GUICtrlSetData($LabelStatus, "")
	EndSwitch
EndFunc
#endregion Set functions

Func ToggleEnterOn()
	SetLog("Toggling input field to be inputtable. Not my fault if caret is in whisper box, pm box, or /chat box.")
	ClipPut("")
	; Clear the input field, type test, copy it, clear it
	; Check if it's a match, therefore you can type.
	Send("{END}{SHIFTDOWN}{HOME}{SHIFTUP}{BACKSPACE}test{END}{SHIFTDOWN}{HOME}{SHIFTUP}{CTRLDOWN}c{CTRLUP}{BACKSPACE}")
	If ClipGet() <> "test" Then
		Send("{ENTER}")
	EndIf
EndFunc

#region Error functions
Func CheckErrorAdminRights($atError)
	If $atError = 1 Then
		SetLog("Check if you're running the script as administrator or if you have access to that folder. Or you probably cancelled. Otherwise, " & $ERROR_MESSAGE)
		SetLog("Setup not saved.")
	EndIf
	Return Not $atError
EndFunc

Func CheckErrorInputBox($atError)
	If $atError = 1 Then
		SetLog("You probably cancelled. Otherwise, " & $ERROR_MESSAGE)
		SetLog("Setup not saved.")
	EndIf
	Return Not $atError
EndFunc

Func CheckErrorFileOpen($fileName, $returnValue)
	If $returnValue = -1 Then
		SetLog("Failed to open the file " & $fileName & ". If you think there's something wrong with the script " & $ERROR_MESSAGE)
		ToggleQuit()
	EndIf
EndFunc

Func CheckErrorFileRead($fileName, $atError)
	If $atError = 1 Then
		SetLog("Failed to read the file " & $fileName & ". If you think there's something wrong with the script " & $ERROR_MESSAGE)
		ToggleQuit()
	EndIf
EndFunc

Func CheckErrorFileWrite($fileName, $returnValue)
	If $returnValue = 0 Then
		SetLog("Failed to write to the file " & $fileName & ". If you think there's something wrong with the script " & $ERROR_MESSAGE)
		ToggleQuit()
	EndIf
EndFunc

Func CheckErrorFileDelete($fileName, $returnValue)
	If $returnValue = 0 Then
		SetLog("Failed to delete the file " & $fileName & ". If you think there's something wrong with the script " & $ERROR_MESSAGE)
;~ 		ToggleQuit() ; No toggle, it will still work even if we don't delete them.
	EndIf
EndFunc

Func CheckErrorFileCopy($fileName, $returnValue)
	If $returnValue = 0 Then
		SetLog("Failed to copy the file " & $fileName & ". If you think there's something wrong with the script " & $ERROR_MESSAGE)
		ToggleQuit()
	EndIf
EndFunc
#endregion Error functions

Func NowDateDiffFormat()
	return (@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC)
EndFunc

Func DeleteSetDeleteFiles()
	For $i = 1 To $deleteChatFiles[0]
		CheckErrorFileDelete($deleteChatFiles[$i], FileDelete($deleteChatFiles[$i]))
	Next
EndFunc
