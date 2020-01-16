;---------------------------
;Installation
#SingleInstance, Force
#NoEnv

ListLines, Off
SetTitleMatchMode, RegEx

SplitPath, A_ScriptName,,,, ScriptName

If A_IsCompiled	{
    IfNotExist, %A_MyDocuments%\%ScriptName%.exe 
    {
        MsgBox, 4, , Would you like to install it?
        IfMsgBox, No
            ExitApp
        IfMsgBox, Yes
            FileMove, %A_ScriptFullPath%, %A_MyDocuments%\
            FileCreateShortcut, %A_MyDocuments%\%ScriptName%.exe, %A_Startup%\%ScriptName%.lnk, %A_MyDocuments%\%ScriptName%.exe
        Run, %A_MyDocuments%\%ScriptName%.exe
        ExitApp
    }
}

;---------------------------
;Initializing
TrayMenu:
Menu, Tray, NoStandard
Menu, Tray, Add, Open GUI, ShowGui
Menu, Tray, Add, Run On Startup, RunOnStart
    IfExist, %A_Startup%\%ScriptName%.lnk
        Menu, Tray, Check, Run On Startup
Menu, Tray, Add, Reload Script (Ctrl+F5), ReloadScript
Menu, Tray, Add, Uninstall, Remove
Menu, Tray, Add, Exit, CloseButton
Menu, Tray, Default, Exit

If A_IsCompiled	{
    If !GetKeyState("Numlock", "T") 
    {
        Menu, Tray, Icon, %A_ScriptFullPath%, , 1
    }
    Else Menu, Tray, Icon, Shell32.dll, 295, 1
}
;No Return yet, need to create GUI first

;----------------
;GUI



Return  ; End of auto-execute section. The script is idle until the user does something.


#F1:

"`\w+\.*?\:"
"^.*:?:.*$"

FileRead, FileContent, %ScriptName%

Return



;---------------------------
;Tray Menu Options
~Numlock:: ;<-Lock Workstation
KeyWait, Numlock, T1.5
If ErrorLevel
    DllCall("LockWorkStation")
If A_IsCompiled	{
    If !GetKeyState("Numlock", "T") 
    {
        Menu, Tray, Icon, %A_ScriptFullPath%, , 1
    }
    Else Menu, Tray, Icon, Shell32.dll, 295, 1
}
Return

ShowGui:
Gui, Show,, GUI
Return

RunOnStart:
Menu, Tray, ToggleCheck, Run On Startup
IfExist, %A_Startup%\%ScriptName%.lnk
    FileDelete, %A_Startup%\%ScriptName%.lnk
Else FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\%ScriptName%.lnk, %A_ScriptFullPath%
Return

ReloadScript:
Reload
Return

Remove:
MsgBox, 4, , Would you like to Uninstall AHK?
IfMsgBox, No, Exit
FileDelete, %A_Startup%\%ScriptName%.lnk
Run, %comspec% /c del /q "%A_ScriptFullPath%" ,,hide
Exitapp
Return

CloseButton:
Exitapp
Return

;---------------------------
;F Keys
#Media_Prev::Send {F7} ;<-Send F7
#Media_Play_Pause::Send {F8} ;<-Send F8
#Media_Next::Send {F9} ;<-Send F9
#Volume_Mute::Send {F10} ;<-Send F10
#Volume_Down::Send {F11} ;<-Send F11
#Volume_Up::Send {F12} ;<-Send F12

;---------------------------
;Discord
NumpadEnd:: ;<-Discord
IfWinActive ahk_exe Discord.exe
    Send ^{Tab}
Else
    WinActivate ahk_exe Discord.exe
IfWinNotExist ahk_exe Discord.exe
    Run, C:\Users\%A_UserName%\AppData\Local\Discord\Update.exe --processStart Discord.exe
Return

^!NumpadEnd:: ;<-Close Discord
WinClose, ahk_exe Discord.exe
Return

;---------------------------
;Sound Volume
^Volume_Mute:: ;<-Set Default Audio Device
Run, mmsys.cpl
WinWaitActive, Sound
WinSet, AlwaysOnTop, On, Sound
Send, {Down}
ControlGet, MyState, Enabled, , Button2
If (MyState = 1)
    ControlClick, &Set Default, A
Return

;---------------------------
;Spotify
NumpadDown:: ;<-Spotify
IfWinExist ahk_exe Spotify.exe
    IfWinActive ahk_exe Spotify.exe
    {
        Sleep 50
        WinMinimize, Spotify
    }
    Else WinActivate, Spotify
Else Run, %A_AppData%\Spotify\spotify.exe
Return

^!NumpadDown:: ;<-Close Spotify
WinClose, ahk_exe Spotify.exe
Return

#IfWinExist ahk_exe Spotify.exe
Volume_Up:: ;<-Spotify Volume Up
    IfWinActive ahk_exe Spotify.exe
    {
        Send ^{Up}
    }
    Else SpotifyKey("^{Up}")
Return
Volume_Down:: ;<-Spotify Volume Down
    IfWinActive ahk_exe Spotify.exe
    {
        Send ^{Down}
    }
    Else SpotifyKey("^{Down}")
Return
#If

;----------------
;Get the HWND of the Spotify main window.
getSpotifyHwnd()
{
    WinGet, SpotifyHwnd, ID, ahk_exe Spotify.exe
    ; We need the app's third top level window, so get next twice.
    SpotifyHwnd := DllCall("GetWindow", "uint", SpotifyHwnd, "uint", 2)
    SpotifyHwnd := DllCall("GetWindow", "uint", SpotifyHwnd, "uint", 2)
    Return SpotifyHwnd
}
;Send a key to Spotify.
SpotifyKey(key)
{
    SpotifyHwnd := getSpotifyHwnd()
    ; Chromium ignores keys when it isn't focused.
    ; Focus the document window without bringing the app to the foreground.
    ControlFocus, Chrome_RenderWidgetHostHWND1, ahk_id %SpotifyHwnd%
    ControlSend, , %key%, ahk_id %SpotifyHwnd%
Return
}

;---------------------------
;Steam
NumpadPgDn:: ;<-Steam
IfWinExist, ahk_exe Steam.exe
    IfWinActive
    {
        Sleep 50
        WinMinimize, A
    }
    Else WinActivate, ahk_exe Steam.exe
Else Run, C:\Program Files (x86)\Steam\Steam.exe
Return

^!NumpadPgDn:: ;<-Close Steam
WinClose, ahk_exe Steam.
Return

#NumpadPgDn:: ;<-Steam Friends
IfWinExist, Friends List
    IfWinActive
    {
        Sleep 50
        WinMinimize, A
    }
    Else WinActivate, Friends List
Else Run Steam://open/friends
Return

;---------------------------
;Twitch
NumpadLeft:: ;<-Twitch
IfWinExist, Twitch
    IfWinActive
    {
        Sleep 50
        WinMinimize, A
    }
    Else WinActivate, Twitch
Else Run, chrome.exe --app=https://www.twitch.tv/directory/following
Return

^!NumpadLeft:: ;<-Close Twitch
WinClose, Twitch
Return

Return
!NumpadLeft:: ;<-Open Twitch Stream on Chrome
Send ^l
Sleep 50
Send ^c
Send ^w
Run, chrome.exe --app=%Clipboard%
Return

;---------------------------
;Chrome
NumpadClear:: ;<-Chrome
IfWinActive Google Chrome
    Send ^{Tab}
Else
    WinActivate Google Chrome
IfWinNotExist Google Chrome
    Run, chrome.exe
Return

^!NumpadClear:: ;<-Close Chrome
WinClose, Google Chrome
Return

#NumpadClear:: ;<-Web Search From Clipboard
Send ^c
Run, % "http://www.google.com/search?q=" . RegExReplace(Clipboard,"\[|\]")
Return

;---------------------------
;YouTube
NumpadRight:: ;<-Youtube
IfWinExist, YouTube
    IfWinActive
    {
        Sleep 50
        WinMinimize, A
    }
    Else WinActivate, YouTube
Else Run, chrome.exe --app=https://www.youtube.com/
Return

^!NumpadRight:: ;<-Close Youtube
WinClose, YouTube
Return

#NumpadRight:: ;<-Open Twitch Stream on Chrome
Send ^l
Sleep 50
Send ^c
Send ^w
Run, chrome.exe --app=%Clipboard%
Return

;---------------------------
;Windows Explorer
NumpadHome:: ;<-Windows Explorer
IfWinNotExist ahk_class CabinetWClass
    Run, explorer.exe
    GroupAdd, ExplorerGroup, ahk_class CabinetWClass
IfWinActive ahk_exe explorer.exe
    GroupActivate, ExplorerGroup, R
Else
    WinActivate ahk_class CabinetWClass
Return

^!NumpadHome:: ;<-Close Windows Explorer
WinClose, ahk_group ExplorerGroup
Return

;---------------------------
;Desktop
NumpadUp:: ;<-Show Desktop
Send #d
Return

;---------------------------
;Window & Monitor
NumpadPgUp:: ;<-Move Window
Send #+{Right}
Return

!NumpadPgUp:: ;<-Change Monitor Input Source
SetMonitorInputSource(18)
Return

#NumpadPgUp:: ;<-Set Window to Always On Top
Winset, AlwaysOnTop, , A
Return

;----------------
;Monitor Function
GetMonitorHandle()
{
    hMon := DllCall("MonitorFromPoint", "int64", 0, "uint", 1)
    VarSetCapacity(Physical_Monitor, 8 + 256, 0)
    DllCall("dxva2\GetPhysicalMonitorsFromHMONITOR", "int", hMon, "uint", 1, "int", &Physical_Monitor)
    Return hPhysMon := NumGet(Physical_Monitor)
}
DestroyMonitorHandle(handle)
{
    DllCall("dxva2\DestroyPhysicalMonitor", "int", handle)
}
SetMonitorInputSource(source)
{
    handle := GetMonitorHandle()
    DllCall("dxva2\SetVCPFeature", "int", handle, "char", 0x60, "uint", source)
    DestroyMonitorHandle(handle)
}
GetMonitorInputSource()
{
    handle := getMonitorHandle()
    DllCall("dxva2\GetVCPFeatureAndVCPFeatureReply", "int", handle, "char", 0x60, "Ptr", 0, "uint*", currentValue, "uint*", maximumValue)
    DestroyMonitorHandle(handle)
    Return currentValue
}
Return