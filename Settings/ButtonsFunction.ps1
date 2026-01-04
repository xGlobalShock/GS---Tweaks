# ButtonsFunction.ps1
# This script checks which tweaks are selected and calls the appropriate scripts with parameters.

param(
    [bool]$IRQ = $false,
    [bool]$NET = $false,
    [bool]$GPU = $false,
    [bool]$CPU = $false,
    [bool]$USB = $false,
    [bool]$HPET = $false,
    [bool]$GameDVR = $false,
    [bool]$FullscreenOpt = $false,
    [bool]$USBSuspend = $false,
    [bool]$ApexConfig = $false,
    [bool]$ApexShader = $false
)

# Check if running as admin, if not, re-run as admin
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `\"$PSCommandPath`\""
    foreach ($param in $PSBoundParameters.GetEnumerator()) {
        $argList += " -$($param.Key) `\$$($param.Value)"
    }
    Start-Process powershell -Verb RunAs -ArgumentList $argList -Wait
    exit
}

$scriptRoot = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "..\Tools\Tweaks"

if ($IRQ) { & "$scriptRoot\GamingTweaks.ps1" -Type IRQ }
if ($NET) { & "$scriptRoot\GamingTweaks.ps1" -Type NET }
if ($GPU) { & "$scriptRoot\GamingTweaks.ps1" -Type GPU }
if ($CPU) { & "$scriptRoot\GamingTweaks.ps1" -Type CPU }
if ($USB) { & "$scriptRoot\GamingTweaks.ps1" -Type USB }
if ($HPET) { & "$scriptRoot\GamingTweaks.ps1" -Type HPET }
if ($GameDVR) { & "$scriptRoot\GamingTweaks.ps1" -Type GameDVR }
if ($FullscreenOpt) { & "$scriptRoot\GamingTweaks.ps1" -Type FullscreenOpt }
if ($USBSuspend) { & "$scriptRoot\GamingTweaks.ps1" -Type USBSuspend }

if ($ApexConfig) { & powershell -NoProfile -ExecutionPolicy Bypass -File "$scriptRoot\ApexTweaks.ps1" -Type Config }
if ($ApexShader) { & powershell -NoProfile -ExecutionPolicy Bypass -File "$scriptRoot\ApexShaders.ps1" -Type ClearShaders }

Write-Host "Selected tweaks applied."
