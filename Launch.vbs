' VBScript to run Launch.ps1 as Administrator
' This script requests elevation and then runs Launch.ps1 (hidden)

Set objShell = CreateObject("Shell.Application")
Set objFSO = CreateObject("Scripting.FileSystemObject")
strPath = objFSO.GetParentFolderName(WScript.ScriptFullName)
strLaunchScript = objFSO.BuildPath(strPath, "Settings\Launch.ps1")

objShell.ShellExecute "powershell.exe", "-NoProfile -ExecutionPolicy Bypass -File """ & strLaunchScript & """", strPath, "runas", 0

' Close this script window
WScript.Quit 0
