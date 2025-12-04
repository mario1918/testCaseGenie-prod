Set WshShell = CreateObject("WScript.Shell")
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")

' Monitor for Chrome/Edge processes with localhost:4200
Function IsBrowserRunning()
    On Error Resume Next
    ' Check for Chrome processes
    Set colProcesses = objWMIService.ExecQuery("SELECT * FROM Win32_Process WHERE Name = 'chrome.exe' OR Name = 'msedge.exe'")
    
    For Each objProcess In colProcesses
        ' Check if command line contains localhost:4200
        If Not IsNull(objProcess.CommandLine) Then
            If InStr(objProcess.CommandLine, "localhost:4200") > 0 Then
                IsBrowserRunning = True
                Exit Function
            End If
        End If
    Next
    
    IsBrowserRunning = False
    On Error Goto 0
End Function

' Wait for browser to navigate to localhost:4200 (app is fully loaded)
WScript.Sleep 5000
waitCount = 0
Do Until IsBrowserRunning()
    WScript.Sleep 2000
    waitCount = waitCount + 1
    ' If waiting too long (60 seconds), exit to prevent infinite loop
    If waitCount > 30 Then
        WScript.Quit
    End If
Loop

' Now monitor - wait while browser is still running
Do While IsBrowserRunning()
    WScript.Sleep 2000
Loop

' Browser closed, kill all server processes
WScript.Sleep 1000

' Kill Node.js processes
On Error Resume Next
WshShell.Run "taskkill /F /IM node.exe", 0, True

' Kill Python processes (uvicorn)
WshShell.Run "taskkill /F /IM python.exe", 0, True
WshShell.Run "taskkill /F /IM py.exe", 0, True

' Kill any remaining npm processes
WshShell.Run "taskkill /F /IM npm.cmd", 0, True

On Error Goto 0

WScript.Quit
