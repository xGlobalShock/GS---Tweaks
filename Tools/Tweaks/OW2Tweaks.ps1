param([string]$Type)

# Overwatch 2 Optimization Script
# Optimizes Overwatch 2 for competitive gameplay

switch ($Type) {
    "Launch" {
        # Overwatch 2 launches through Battle.net
        Write-Host "Overwatch 2 launches through Battle.net launcher."
        Write-Host "No additional launch options available."
    }
    "Config" {
        # Optimize Overwatch 2 settings
        $ow2SettingsPath = Join-Path $env:USERPROFILE "Documents\Overwatch\Settings\Settings_v0.ini"
        
        if (Test-Path $ow2SettingsPath) {
            $content = Get-Content $ow2SettingsPath
            
            $settings = @{
                "FrameRateCap" = "300"
                "GFXSettings.23" = "1"  # Render Scale
                "GFXSettings.1" = "1"   # Graphics Quality - Low
                "GFXSettings.3" = "1"   # Texture Quality - Low
                "GFXSettings.5" = "0"   # Shadows - Off
                "GFXSettings.9" = "0"   # Ambient Occlusion - Off
                "GFXSettings.17" = "0"  # Refraction Quality - Off
                "ReduceBuffering" = "1"
                "VSync" = "0"
            }
            
            foreach ($key in $settings.Keys) {
                $found = $false
                for ($i = 0; $i -lt $content.Count; $i++) {
                    if ($content[$i] -like "*$key*=*") {
                        $content[$i] = "$key = `"$($settings[$key])`""
                        $found = $true
                        break
                    }
                }
                if (-not $found) {
                    $content += "$key = `"$($settings[$key])`""
                }
            }
            
            Set-Content -Path $ow2SettingsPath -Value $content
            Write-Host "Overwatch 2 settings optimized!"
        } else {
            Write-Host "Overwatch 2 settings file not found. Please launch the game first."
        }
    }
    "Registry" {
        # OW2-specific registry optimizations
        Write-Host "Applying Overwatch 2 registry optimizations..."
        
        # Optimize for low latency
        $gameDVRPath = "HKCU:\System\GameConfigStore"
        if (!(Test-Path $gameDVRPath)) {
            New-Item -Path $gameDVRPath -Force | Out-Null
        }
        Set-ItemProperty -Path $gameDVRPath -Name "GameDVR_Enabled" -Value 0 -Type DWord
        
        Write-Host "Overwatch 2 registry optimizations applied!"
    }
}
