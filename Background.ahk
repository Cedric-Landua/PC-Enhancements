; Minimize windows when clicking desktop

~LButton::
    MouseGetPos,,, targetWindow
    WinGetClass, winClass, ahk_id %targetWindow%
    
    if (winClass = "Progman" || winClass = "WorkerW") {
        WinMinimizeAll
        KeyWait, LButton
    }
return
