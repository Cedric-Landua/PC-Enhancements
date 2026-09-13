; Minimize windows only on the monitor that was clicked

~LButton::
    MouseGetPos, mouseX, mouseY, targetWindow
    WinGetClass, winClass, ahk_id %targetWindow%
    
    if (winClass = "Progman" || winClass = "WorkerW") {
        ; Monitor clicked?
        targetMonitor := GetMonitorAt(mouseX, mouseY)
        
        WinGet, windowList, List
        
        Loop, %windowList%
        {
            thisHWND := windowList%A_Index%
            
            ; Skips weirdo windows
            WinGetTitle, title, ahk_id %thisHWND%
            WinGet, style, Style, ahk_id %thisHWND%
            if (!title || !(style & 0x10000000)) ; WS_VISIBLE check
                continue
                
            WinGetPos, wx, wy, ww, wh, ahk_id %thisHWND%
            wCenterX := wx + (ww / 2)
            wCenterY := wy + (wh / 2)
            
            if (GetMonitorAt(wCenterX, wCenterY) = targetMonitor) {
                WinMinimize, ahk_id %thisHWND%
            }
        }
        
        KeyWait, LButton
    }
return

; Helper func.
GetMonitorAt(x, y) {
    SysGet, monitorCount, MonitorCount
    Loop, %monitorCount% {
        SysGet, mon, Monitor, %A_Index%
        if (x >= monLeft && x < monRight && y >= monTop && y < monBottom)
            return A_Index
    }
    return 1
}
