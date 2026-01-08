param([string]$Type)

# Valorant Optimization Script
# Optimizes Valorant for competitive gameplay

switch ($Type) {
    "Launch" {
        # Valorant is launched through Riot Client, but we can optimize the game config
        $valorantConfig = Join-Path $env:LOCALAPPDATA "VALORANT\Saved\Config"
        
        if (Test-Path $valorantConfig) {
            Write-Host "Valorant config folder found: $valorantConfig"
            # Additional optimizations can be added here
        } else {
            Write-Host "Valorant config folder not found. Please launch Valorant at least once."
        }
    }
    "Config" {
        # Optimize Valorant GameUserSettings.ini
        $gameUserSettings = Join-Path $env:LOCALAPPDATA "VALORANT\Saved\Config\Windows\GameUserSettings.ini"
        
        if (Test-Path $gameUserSettings) {
            $content = Get-Content $gameUserSettings
            
            # Performance optimizations
            $settings = @{
                "FrameRateLimitInGame" = "300"
                "FrameRateLimitInMenu" = "144"
                "GraphicsQualityPreset" = "1"  # Low
            }
            
            foreach ($key in $settings.Keys) {
                $found = $false
                for ($i = 0; $i -lt $content.Count; $i++) {
                    if ($content[$i] -like "*$key=*") {
                        $content[$i] = "$key=$($settings[$key])"
                        $found = $true
                        break
                    }
                }
                if (-not $found) {
                    $content += "$key=$($settings[$key])"
                }
            }
            
            Set-Content -Path $gameUserSettings -Value $content
            Write-Host "Valorant settings optimized successfully!"
        } else {
            Write-Host "Valorant settings file not found."
        }
    }
    "Registry" {
        # Valorant-specific registry optimizations
        $valorantRegPath = "HKCU:\Software\Riot Games\VALORANT"
        
        if (!(Test-Path $valorantRegPath)) {
            New-Item -Path $valorantRegPath -Force | Out-Null
        }
        
        # Disable fullscreen optimizations
        Set-ItemProperty -Path $valorantRegPath -Name "DisableFullscreenOptimizations" -Value 1 -Type DWord
        
        Write-Host "Valorant registry optimizations applied!"
    }
}
