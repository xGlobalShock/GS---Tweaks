param([string]$Type)

# Call of Duty Optimization Script
# Optimizes COD (Modern Warfare / Warzone) for competitive gameplay

switch ($Type) {
    "Launch" {
        # COD launches through Battle.net
        Write-Host "Call of Duty launches through Battle.net launcher."
        Write-Host "Recommended: Enable high priority in Windows Task Manager when game is running."
    }
    "Config" {
        # Optimize COD config file
        $codConfigPath = Join-Path $env:USERPROFILE "Documents\Call of Duty\players\config.cfg"
        
        if (Test-Path $codConfigPath) {
            $configContent = @"
// Call of Duty Performance Config
seta com_maxfps "0"
seta r_vsync "0"
seta r_displayRefresh "240"
seta cg_brass "0"
seta fx_draw "0"
seta fx_marks "0"
seta sm_enable "0"
seta r_distortion "0"
seta r_dlightLimit "0"
seta cg_drawFPS "1"

// Network Optimizations
seta cl_maxpackets "125"
seta rate "25000"
seta snaps "30"
"@
            
            Add-Content -Path $codConfigPath -Value $configContent
            Write-Host "COD config optimized successfully!"
        } else {
            Write-Host "COD config file not found. Creating new config..."
            $docsPath = Join-Path $env:USERPROFILE "Documents\Call of Duty\players"
            if (!(Test-Path $docsPath)) {
                New-Item -Path $docsPath -ItemType Directory -Force | Out-Null
            }
        }
    }
    "Registry" {
        # COD-specific registry optimizations
        Write-Host "Applying Call of Duty registry optimizations..."
        
        # Disable fullscreen optimizations
        $dwmPath = "HKCU:\Software\Microsoft\Windows\DWM"
        if (!(Test-Path $dwmPath)) {
            New-Item -Path $dwmPath -Force | Out-Null
        }
        Set-ItemProperty -Path $dwmPath -Name "CompositionPolicy" -Value 0 -Type DWord
        
        Write-Host "COD registry optimizations applied!"
    }
}
