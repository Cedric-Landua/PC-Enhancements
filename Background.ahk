; Minimize all windows when clicking the desktop (no untoggle)

~LButton::
    MouseGetPos,,, targetWindow
    WinGetClass, winClass, ahk_id %targetWindow%
    
    if (winClass = "Progman" || winClass = "WorkerW") {
        Send #d
        KeyWait, LButton ; Wait for release to prevent repeated triggers
    }
return