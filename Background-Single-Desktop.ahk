#Requires AutoHotkey v2.0
#SingleInstance Force

CoordMode "Mouse", "Screen"

; Variables for tracking desktop clicks per monitor
global DesktopClickCount := 0
global WindowToMinimize := 0
global ClickedMonitor := 1

; --- Track when the background is clicked ---
~LButton:: {
    global DesktopClickCount, WindowToMinimize, ClickedMonitor
    MouseGetPos &startX, &startY, &winID
    winClass := WinGetClass(winID)
    
    ; --- Handle Background/Desktop Clicks ---
    ; "WorkerW" and "Progman" are the window classes for the Windows desktop background
    if (winClass = "WorkerW" || winClass = "Progman") {
        ClickedMonitor := GetMonitorAt(startX, startY)
        
        if (DesktopClickCount > 0) {
            ; DOUBLE CLICK DETECTED: Minimize only the top window
            DesktopClickCount += 1
            SetTimer DesktopClickAction, 0 ; Cancel the single-click timer
            
            if (WindowToMinimize) {
                Try WinMinimize(WindowToMinimize)
            }
            DesktopClickCount := 0
        } else {
            ; FIRST CLICK DETECTED: Wait to see if it becomes a double click
            DesktopClickCount := 1
            ; Pre-calculate the top window just in case they click a second time
            WindowToMinimize := GetTopNormalWindowOnMonitor(ClickedMonitor)
            SetTimer DesktopClickAction, -400 ; Wait 400ms to see if a second click occurs
        }
        return
    }
    
    ; If clicking anywhere else, resolve the pending desktop single-click immediately
    if (DesktopClickCount > 0) {
        SetTimer DesktopClickAction, 0
        DesktopClickAction()
    }
}

; --- Desktop Click Action Resolvers ---

; SINGLE CLICK TRIGGER: Fires if 400ms passes without a second click
DesktopClickAction() {
    global DesktopClickCount, ClickedMonitor
    DesktopClickCount := 0
    
    ; Minimize ALL windows on the monitor
    MinimizeWindowsOnMonitor(ClickedMonitor)
}

; Finds the highest Z-order visible window on the specified monitor
GetTopNormalWindowOnMonitor(targetMonIndex) {
    hwndList := WinGetList()
    for hwnd in hwndList {
        title := WinGetTitle(hwnd)
        class := WinGetClass(hwnd)
        style := WinGetStyle(hwnd)
        
        ; Needs to be a visible window, have a title, and not be a shell/desktop component
        if ((style & 0x10000000) && title != "" && class != "Progman" && class != "WorkerW" && class != "Shell_TrayWnd" && class != "Shell_SecondaryTrayWnd") {
            Try {
                WinGetPos &wX, &wY, &wW, &wH, hwnd
                winMonIndex := GetMonitorAt(wX + (wW / 2), wY + (wH / 2)) ; Check center of window
                if (winMonIndex == targetMonIndex) {
                    return hwnd
                }
            }
        }
    }
    return 0
}

; Minimizes all standard windows located on the specified monitor
MinimizeWindowsOnMonitor(targetMonIndex) {
    hwndList := WinGetList()
    for hwnd in hwndList {
        title := WinGetTitle(hwnd)
        class := WinGetClass(hwnd)
        style := WinGetStyle(hwnd)
        
        ; Target visible windows excluding the desktop and taskbars
        if ((style & 0x10000000) && title != "" && class != "Progman" && class != "WorkerW" && class != "Shell_TrayWnd" && class != "Shell_SecondaryTrayWnd") {
            Try {
                WinGetPos &wX, &wY, &wW, &wH, hwnd
                winMonIndex := GetMonitorAt(wX + (wW / 2), wY + (wH / 2)) ; Check center of window
                if (winMonIndex == targetMonIndex) {
                    WinMinimize(hwnd) 
                }
            }
        }
    }
}

; --- Helper: Find which monitor the mouse is on ---
GetMonitorAt(x, y) {
    Loop MonitorGetCount() {
        MonitorGet A_Index, &Left, &Top, &Right, &Bottom
        if (x >= Left && x <= Right && y >= Top && y <= Bottom)
            return A_Index
    }
    return 1
}
