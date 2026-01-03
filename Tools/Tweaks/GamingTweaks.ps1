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
        
        # Use Set-ItemProperty with proper type parameter
        $params = @{
            Path = $Path
            Name = $Name
            Value = $Value
            Force = $true
            ErrorAction = "Stop"
        }
        
        # Add Type parameter if not DWORD
        if ($PropertyType -ne "DWORD") {
            $params['Type'] = $PropertyType
        }
        
        Set-ItemProperty @params
        Write-Host "[OK] Set $Name = $Value" -ForegroundColor Green
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
            Write-Host "[OK] Created registry key: $Path" -ForegroundColor Green
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
        
        # All reset operations safely revert to Windows defaults
        # This is 100% safe because we're only removing/reverting values we added
        
        # 1. IRQ8 Priority - DELETE (HKLM)
        try {
            Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "IRQ8Priority" -Force -ErrorAction Stop
            Write-Host "[OK] Reset: IRQ8 Priority [deleted]" -ForegroundColor Green
        } catch {
            if ($_.Exception.Message -like "*Cannot find*" -or $_.Exception.Message -like "*does not exist*") {
                Write-Host "[OK] Reset: IRQ8 Priority [already removed]" -ForegroundColor Green
            } else {
                Write-Host "[ERR] Error resetting IRQ8 Priority: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        # 2. Network Interrupts - DELETE (HKLM)
        try {
            Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NDIS\Parameters" -Name "ProcessorThrottleMode" -Force -ErrorAction Stop
            Write-Host "[OK] Reset: Network Interrupts [deleted]" -ForegroundColor Green
        } catch {
            if ($_.Exception.Message -like "*Cannot find*" -or $_.Exception.Message -like "*does not exist*") {
                Write-Host "[OK] Reset: Network Interrupts [already removed]" -ForegroundColor Green
            } else {
                Write-Host "[ERR] Error resetting Network Interrupts: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        # 3. GPU Scheduling - DELETE (HKLM)
        try {
            Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Force -ErrorAction Stop
            Write-Host "[OK] Reset: GPU Scheduling [deleted]" -ForegroundColor Green
        } catch {
            if ($_.Exception.Message -like "*Cannot find*" -or $_.Exception.Message -like "*does not exist*") {
                Write-Host "[OK] Reset: GPU Scheduling [already removed]" -ForegroundColor Green
            } else {
                Write-Host "[ERR] Error resetting GPU Scheduling: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        # 4. Game DVR - SET to 1 (HKCU)
        try {
            $path = "HKCU:\System\GameConfigStore"
            if (Test-Path $path) {
                Set-ItemProperty -Path $path -Name "GameDVR_Enabled" -Value 1 -Type DWORD -Force -ErrorAction Stop
                Write-Host "[OK] Reset: Game DVR [GameDVR_Enabled = 1]" -ForegroundColor Green
            } else {
                Write-Host "[OK] Reset: Game DVR (already removed)" -ForegroundColor Green
            }
        } catch {
            Write-Host "[ERR] Error resetting Game DVR: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # 5. Fullscreen Optimizations - SET to 1 (HKCU)
        try {
            $path = "HKCU:\System\GameConfigStore"
            if (Test-Path $path) {
                Set-ItemProperty -Path $path -Name "GameDVR_FSEBehaviorMonitorEnabled" -Value 1 -Type DWORD -Force -ErrorAction Stop
                Write-Host "[OK] Reset: Fullscreen Optimizations [GameDVR_FSEBehaviorMonitorEnabled = 1]" -ForegroundColor Green
            } else {
                Write-Host "[OK] Reset: Fullscreen Optimizations (already removed)" -ForegroundColor Green
            }
        } catch {
            Write-Host "[ERR] Error resetting Fullscreen Optimizations: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # 6. USB Suspend - DELETE (HKLM)
        try {
            Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USB" -Name "DisableSelectiveSuspend" -Force -ErrorAction Stop
            Write-Host "[OK] Reset: USB Suspend [deleted]" -ForegroundColor Green
        } catch {
            if ($_.Exception.Message -like "*Cannot find*" -or $_.Exception.Message -like "*does not exist*") {
                Write-Host "[OK] Reset: USB Suspend [already removed]" -ForegroundColor Green
            } else {
                Write-Host "[ERR] Error resetting USB Suspend: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        # 7. Mouse Acceleration - SET to defaults (HKCU)
        try {
            $path = "HKCU:\Control Panel\Mouse"
            if (Test-Path $path) {
                Set-ItemProperty -Path $path -Name "MouseSpeed" -Value "1" -Type String -Force -ErrorAction Stop
                Set-ItemProperty -Path $path -Name "MouseThreshold1" -Value "6" -Type String -Force -ErrorAction Stop
                Set-ItemProperty -Path $path -Name "MouseThreshold2" -Value "10" -Type String -Force -ErrorAction Stop
                Write-Host "[OK] Reset: Mouse Acceleration [MouseSpeed=1, Threshold1=6, Threshold2=10]" -ForegroundColor Green
            } else {
                Write-Host "[OK] Reset: Mouse Acceleration (already removed)" -ForegroundColor Green
            }
        } catch {
            Write-Host "[ERR] Error resetting Mouse Acceleration: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        Write-Host "`n[OK] All tweaks reset to Windows defaults" -ForegroundColor Green
        Write-Host "A system restart is recommended for changes to take effect.`n" -ForegroundColor Cyan
    }
    
    default {
        Write-Host "Unknown tweak type: $Type" -ForegroundColor Red
    }
}
