param([string]$Type)

# Rocket League Optimization Script
# Optimizes Rocket League for competitive gameplay

switch ($Type) {
    "Launch" {
        # Rocket League Steam Launch Options
        $gameAppID = 252950
        $launchOptions = "-high -NOTEXTURESTREAMING -refresh 240 -useallavailablecores -nomansky"
        $steamRegistryPath = "HKCU:\Software\Valve\Steam\Apps\$gameAppID"
        
        if (!(Test-Path $steamRegistryPath)) {
            New-Item -Path $steamRegistryPath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $steamRegistryPath -Name "LaunchOptions" -Value $launchOptions
        Write-Host "Rocket League launch options applied!"
    }
    "Config" {
        # Optimize Rocket League TASystemSettings.ini
        $rlConfigPath = Join-Path $env:USERPROFILE "Documents\My Games\Rocket League\TAGame\Config\TASystemSettings.ini"
        
        if (Test-Path $rlConfigPath) {
            attrib -R $rlConfigPath
            $content = Get-Content $rlConfigPath
            
            $settings = @{
                "bSmoothFrameRate" = "False"
                "MaxSmoothedFrameRate" = "300"
                "MinSmoothedFrameRate" = "60"
                "DynamicShadows" = "False"
                "LightQuality" = "0"
                "MotionBlur" = "False"
                "DepthOfField" = "False"
                "Bloom" = "False"
                "bEnableVsync" = "False"
                "PoolSize" = "0"
                "TextureQuality" = "1"
                "AntiAlias" = "0"
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
            
            Set-Content -Path $rlConfigPath -Value $content
            attrib +R $rlConfigPath
            Write-Host "Rocket League settings optimized!"
        } else {
            Write-Host "Rocket League config file not found."
        }
    }
    "Registry" {
        # Rocket League-specific registry optimizations
        Write-Host "Applying Rocket League registry optimizations..."
        
        # Disable Game DVR
        $gameDVRPath = "HKCU:\System\GameConfigStore"
        if (!(Test-Path $gameDVRPath)) {
            New-Item -Path $gameDVRPath -Force | Out-Null
        }
        Set-ItemProperty -Path $gameDVRPath -Name "GameDVR_Enabled" -Value 0 -Type DWord
        
        Write-Host "Rocket League registry optimizations applied!"
    }
}
