# RegistryStatusChecker.ps1
# Checks the status of all registry tweaks applied by the tweaker

<#
Registry Tweaks Status Checker
This script checks if each registry tweak has been applied or is in the default state.
Returns an object with the status of each tweak.
#>

function Get-RegistryTweakStatus {
    <#
    .SYNOPSIS
    Gets the current status of all registry tweaks
    
    .DESCRIPTION
    Checks the Windows registry to determine if each tweak is applied (modified from default)
    or in the default state (not tweaked).
    
    .OUTPUTS
    PSObject with properties for each tweak indicating "Applied" or "Default"
    #>
    
    $tweakStatus = @{
        IRQ = "Default"
        NET = "Default"
        GPU = "Default"
        USB = "Default"
        GameDVR = "Default"
        FullscreenOpt = "Default"
        USBSuspend = "Default"
        CPU = "Default"
        HPET = "Default"
    }
    
    # Check IRQ8Priority
    try {
        $irqValue = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "IRQ8Priority" -ErrorAction SilentlyContinue
        if ($irqValue -and $irqValue.IRQ8Priority -eq 1) {
            $tweakStatus.IRQ = "Applied"
        }
    } catch { }
    
    # Check Network Throttle Mode
    try {
        $netValue = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NDIS\Parameters" -Name "ProcessorThrottleMode" -ErrorAction SilentlyContinue
        if ($netValue -and $netValue.ProcessorThrottleMode -eq 1) {
            $tweakStatus.NET = "Applied"
        }
    } catch { }
    
    # Check GPU Hardware Scheduling
    try {
        $gpuValue = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -ErrorAction SilentlyContinue
        if ($gpuValue -and $gpuValue.HwSchMode -eq 2) {
            $tweakStatus.GPU = "Applied"
        }
    } catch { }
    
    # Check USB Suspend
    try {
        $usbValue = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB" -Name "DisableSelectiveSuspend" -ErrorAction SilentlyContinue
        if ($usbValue -and $usbValue.DisableSelectiveSuspend -eq 1) {
            $tweakStatus.USB = "Applied"
        }
    } catch { }
    
    # Check Game DVR
    try {
        $gameDvrValue = Get-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -ErrorAction SilentlyContinue
        if ($gameDvrValue -and $gameDvrValue.GameDVR_Enabled -eq 0) {
            $tweakStatus.GameDVR = "Applied"
        }
    } catch { }
    
    # Check Fullscreen Optimizations
    try {
        $fseValue = Get-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMonitorEnabled" -ErrorAction SilentlyContinue
        if ($fseValue -and $fseValue.GameDVR_FSEBehaviorMonitorEnabled -eq 0) {
            $tweakStatus.FullscreenOpt = "Applied"
        }
    } catch { }
    
    # Check CPU Power Plan (Maximum Performance)
    try {
        $powerCfgOutput = & powercfg -getactivescheme 2>$null
        if ($powerCfgOutput -match "8c5e7fda-e8bf-45a6-a6cc-4b3c3f7be83d") {
            $tweakStatus.CPU = "Applied"
        }
    } catch { }
    
    # Return as PSObject
    return [PSCustomObject]$tweakStatus
}

# Export function
Export-ModuleMember -Function Get-RegistryTweakStatus

# If called directly, return status as JSON for easy parsing
if ($MyInvocation.CommandName -eq $MyInvocation.ScriptName) {
    $status = Get-RegistryTweakStatus
    $status | ConvertTo-Json
}
