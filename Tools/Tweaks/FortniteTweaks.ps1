param([string]$Type)

# Fortnite Optimization Script
# Optimizes Fortnite for competitive gameplay

switch ($Type) {
    "Launch" {
        # Fortnite Epic Games Launcher optimizations
        Write-Host "Fortnite launches through Epic Games Launcher."
        Write-Host "Apply the following launch arguments in Epic Games Launcher:"
        Write-Host "-USEALLAVAILABLECORES -high -nomansky -notexturestreaming"
    }
    "Config" {
        # Optimize Fortnite GameUserSettings.ini
        $fortniteConfig = Join-Path $env:LOCALAPPDATA "FortniteGame\Saved\Config\WindowsClient\GameUserSettings.ini"
        
        if (Test-Path $fortniteConfig) {
            attrib -R $fortniteConfig
            $content = Get-Content $fortniteConfig
            
            $settings = @{
                "FrameRateLimit" = "999.000000"
                "ResolutionSizeX" = "1920"
                "ResolutionSizeY" = "1080"
                "sg.ResolutionQuality" = "100.000000"
                "sg.ViewDistanceQuality" = "0"
                "sg.AntiAliasingQuality" = "0"
                "sg.ShadowQuality" = "0"
                "sg.PostProcessQuality" = "0"
                "sg.TextureQuality" = "0"
                "sg.EffectsQuality" = "0"
                "sg.FoliageQuality" = "0"
                "bMotionBlur" = "False"
                "bShowFPS" = "True"
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
            
            Set-Content -Path $fortniteConfig -Value $content
            attrib +R $fortniteConfig
            Write-Host "Fortnite settings optimized successfully!"
            Write-Host "Config location: $fortniteConfig"
        } else {
            Write-Host "Fortnite config file not found. Please launch Fortnite at least once."
        }
    }
    "Registry" {
        # Fortnite-specific registry optimizations
        Write-Host "Applying Fortnite registry optimizations..."
        
        # Optimize GPU scheduling
        $gpuSchedulingPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
        if (Test-Path $gpuSchedulingPath) {
            Set-ItemProperty -Path $gpuSchedulingPath -Name "HwSchMode" -Value 2 -Type DWord
            Write-Host "Hardware-accelerated GPU scheduling enabled."
        }
        
        Write-Host "Fortnite registry optimizations applied!"
    }
}
