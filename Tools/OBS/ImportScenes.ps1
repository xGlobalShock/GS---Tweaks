$obsPath = "$env:APPDATA\obs-studio\basic\scenes"
if (!(Test-Path $obsPath)) { Write-Host "OBS not found!"; exit }
Copy-Item ".\OBS\Scenes\*" $obsPath -Recurse -Force
Write-Host "OBS scenes and audio setup applied!"
