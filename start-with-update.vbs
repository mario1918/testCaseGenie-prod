Set WshShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get the script directory
strScriptPath = objFSO.GetParentFolderName(WScript.ScriptFullName)
strStatusFile = strScriptPath & "\bin\front\status.txt"

' Helper function to update status
Sub UpdateStatus(message)
    Set objFile = objFSO.CreateTextFile(strStatusFile, True)
    objFile.WriteLine message
    objFile.Close
End Sub

' Update status: Checking for updates
UpdateStatus "Checking for updates..."
WScript.Sleep 500

' Check for git updates (hidden)
gitFetchCmd = "cmd /c cd /d """ & strScriptPath & """ && git fetch origin 2>&1"
gitFetchExitCode = WshShell.Run(gitFetchCmd, 0, True)

' Check if there are differences (hidden)
gitDiffCmd = "cmd /c cd /d """ & strScriptPath & """ && git diff --quiet HEAD origin/main"
gitDiffExitCode = WshShell.Run(gitDiffCmd, 0, True)

' If there are changes (exit code not 0), pull them
If gitDiffExitCode <> 0 Then
    UpdateStatus "Installing updates..."
    gitPullCmd = "cmd /c cd /d """ & strScriptPath & """ && git pull origin main 2>&1"
    gitPullExitCode = WshShell.Run(gitPullCmd, 0, True)
    
    If gitPullExitCode <> 0 Then
        MsgBox "Failed to pull latest changes from repository." & vbCrLf & vbCrLf & _
               "Please check for merge conflicts and try again.", vbCritical, "TestCaseGenie - Update Error"
        WScript.Quit 1
    End If
Else
    UpdateStatus "App is up to date."
    WScript.Sleep 1000
End If

' Install npm dependencies for Angular frontend (hidden)
npmInstallCmd = "cmd /c cd /d """ & strScriptPath & "\bin\front\angular-frontend"" && npm install"
npmExitCode = WshShell.Run(npmInstallCmd, 0, True)

' Check if npm install succeeded
If npmExitCode <> 0 Then
    MsgBox "ERROR: Failed to install npm dependencies." & vbCrLf & vbCrLf & _
           "Please check your internet connection and try again.", vbCritical, "TestCaseGenie Error"
    WScript.Quit 1
End If

' Update status: Starting servers
UpdateStatus "Waiting for servers to be ready..."

' Start Backend (Node.js) - Hidden
WshShell.Run "cmd /c cd /d """ & strScriptPath & "\bin\system\model\Backend"" && node server.js", 0, False

' Start Angular Frontend - Hidden
WshShell.Run "cmd /c cd /d """ & strScriptPath & "\bin\front\angular-frontend"" && npm start", 0, False

' Start Python Backend - Hidden
WshShell.Run "cmd /c cd /d """ & strScriptPath & "\bin\system\jira\TestGenie-BE"" && call venv\Scripts\activate && py -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload", 0, False

' Wait for servers to start
WScript.Sleep 10000
UpdateStatus "Almost ready..."
WScript.Sleep 5000

' Clean up status file
If objFSO.FileExists(strStatusFile) Then
    objFSO.DeleteFile strStatusFile
End If

' Start monitoring script to auto-cleanup when browser closes
WshShell.Run "wscript """ & strScriptPath & "\monitor-and-cleanup.vbs""", 0, False
