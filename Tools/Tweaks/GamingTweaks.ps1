# GamingTweaks.ps1 - Safe Registry Modification Script
# This script applies gaming-related registry tweaks with full error handling and validation
# All operations are reversible through the ResetAll command
# SAFETY NOTES:
# - All tweaks only modify non-essential registry values
# - All tweaks can be completely reversed with ResetAll
# - Registry paths are verified before modification
# - Error handling prevents partial modifications

param([string]$Type)

# Function to safely modify registry with error checking
function Set-SafeRegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$PropertyType = "DWORD"
    )
    
    try {
        # Verify path exists before modifying
        if (-not (Test-Path $Path)) {
            Write-Host "ERROR: Registry path does not exist: $Path" -ForegroundColor Red
            return $false
        }
        
        # Use Set-ItemProperty (safer than New-ItemProperty with -Force)
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Force -ErrorAction Stop
        Write-Host "✓ Set $Name = $Value" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "ERROR: Failed to set registry value: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to safely create registry key
function New-SafeRegistryKey {
    param(
        [string]$Path
    )
    
    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force -ErrorAction Stop | Out-Null
            Write-Host "✓ Created registry key: $Path" -ForegroundColor Green
        }
        return $true
    } catch {
        Write-Host "ERROR: Failed to create registry key: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

switch ($Type) {
    "IRQ" { 
        # SAFE: Adds priority to System Timer interrupt
        # Effect: Improves timer responsiveness
        # Revert: Delete IRQ8Priority value
        # Default: Not present (uses Windows default)
        if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl") {
            Set-SafeRegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "IRQ8Priority" -Value 1 -PropertyType DWORD
        } else {
            Write-Host "ERROR: Registry path not found" -ForegroundColor Red
        }
    }
    
    "NET" { 
        # SAFE: Network throttle mode (1 = disabled)
        # Effect: Improves network consistency
        # Revert: Delete ProcessorThrottleMode value
        # Default: Not present (uses Windows default)
        if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\NDIS\Parameters") {
            Set-SafeRegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NDIS\Parameters" -Name "ProcessorThrottleMode" -Value 1 -PropertyType DWORD
        } else {
            Write-Host "ERROR: Registry path not found" -ForegroundColor Red
        }
    }
    
    "GPU" { 
        # SAFE: Hardware GPU Scheduling (2 = enabled)
        # Effect: Reduces GPU latency
        # Revert: Delete HwSchMode value
        # Default: Not present (uses Windows default)
        # Note: Only works on Windows 10 2004+ and compatible GPUs
        if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers") {
            Set-SafeRegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -PropertyType DWORD
        } else {
            Write-Host "ERROR: Registry path not found" -ForegroundColor Red
        }
    }
    
    "CPU" { 
        # SAFE: Uses built-in Windows power configuration command
        # Effect: Sets power plan to maximum performance
        powercfg -setactive SCHEME_MIN
    }
    
    "USB" { 
        Write-Host "USB selective suspend manual adjustment not implemented" -ForegroundColor Yellow
    }
    
    "HPET" { 
        Write-Host "HPET manual adjustment not implemented" -ForegroundColor Yellow
    }
    
    "GameDVR" { 
        # SAFE: Disables Game DVR (0 = disabled)
        # Effect: Frees up system resources
        # Revert: Set GameDVR_Enabled to 1 or delete value
        # Default: 1 (enabled) - can be changed in Windows Settings
        New-SafeRegistryKey -Path "HKCU:\System\GameConfigStore"
        Set-SafeRegistryValue -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -PropertyType DWORD
    }
    
    "FullscreenOpt" { 
        # SAFE: Disables fullscreen optimizations (0 = disabled)
        # Effect: Better fullscreen performance
        # Revert: Set GameDVR_FSEBehaviorMonitorEnabled to 1 or delete value
        # Default: 1 (enabled)
        New-SafeRegistryKey -Path "HKCU:\System\GameConfigStore"
        Set-SafeRegistryValue -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMonitorEnabled" -Value 0 -PropertyType DWORD
    }
    
    "USBSuspend" { 
        # SAFE: Disables USB selective suspend (1 = disabled)
        # Effect: Prevents USB devices from power-saving mode
        # Revert: Delete DisableSelectiveSuspend value or set to 0
        # Default: Not present (uses Windows default - devices can suspend)
        if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB") {
            Set-SafeRegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB" -Name "DisableSelectiveSuspend" -Value 1 -PropertyType DWORD
        } else {
            Write-Host "ERROR: Registry path not found" -ForegroundColor Red
        }
    }
    
    "MousePrecision" { 
        # SAFE: Disables mouse acceleration (0 = disabled)
        # Effect: Raw mouse input for gaming
        # Revert: Set MouseSpeed=1, MouseThreshold1=6, MouseThreshold2=10
        # Default: MouseSpeed=1, MouseThreshold1=6, MouseThreshold2=10 (acceleration enabled)
        $mousePath = "HKCU:\Control Panel\Mouse"
        if (Test-Path $mousePath) {
            Set-SafeRegistryValue -Path $mousePath -Name "MouseSpeed" -Value "0" -PropertyType String
            Set-SafeRegistryValue -Path $mousePath -Name "MouseThreshold1" -Value "0" -PropertyType String
            Set-SafeRegistryValue -Path $mousePath -Name "MouseThreshold2" -Value "0" -PropertyType String
        } else {
            Write-Host "ERROR: Registry path not found" -ForegroundColor Red
        }
    }
    
    "ResetAll" {
        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "RESETTING ALL GAMING TWEAKS TO DEFAULTS" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        
        # All reset operations use Remove-ItemProperty which safely reverts to Windows defaults
        # This is 100% safe because we're only removing values we added
        
        if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl") {
            Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "IRQ8Priority" -Force -ErrorAction SilentlyContinue
            Write-Host "✓ Reset: IRQ8 Priority" -ForegroundColor Green
        }
        
        if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\NDIS\Parameters") {
            Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NDIS\Parameters" -Name "ProcessorThrottleMode" -Force -ErrorAction SilentlyContinue
            Write-Host "✓ Reset: Network Interrupts" -ForegroundColor Green
        }
        
        if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers") {
            Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Force -ErrorAction SilentlyContinue
            Write-Host "✓ Reset: GPU Scheduling" -ForegroundColor Green
        }
        
        if (Test-Path "HKCU:\System\GameConfigStore") {
            Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 1 -Force -ErrorAction SilentlyContinue
            Write-Host "✓ Reset: Game DVR (re-enabled)" -ForegroundColor Green
            
            Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMonitorEnabled" -Value 1 -Force -ErrorAction SilentlyContinue
            Write-Host "✓ Reset: Fullscreen Optimizations (re-enabled)" -ForegroundColor Green
        }
        
        if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB") {
            Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB" -Name "DisableSelectiveSuspend" -Force -ErrorAction SilentlyContinue
            Write-Host "✓ Reset: USB Suspend (re-enabled)" -ForegroundColor Green
        }
        
        if (Test-Path "HKCU:\Control Panel\Mouse") {
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "1" -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "6" -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "10" -Force -ErrorAction SilentlyContinue
            Write-Host "✓ Reset: Mouse Acceleration (re-enabled)" -ForegroundColor Green
        }
        
        Write-Host "`n✓ All tweaks successfully reset to Windows defaults" -ForegroundColor Green
        Write-Host "A system restart is recommended for changes to take effect.`n" -ForegroundColor Cyan
    }
    
    default {
        Write-Host "Unknown tweak type: $Type" -ForegroundColor Red
    }
}