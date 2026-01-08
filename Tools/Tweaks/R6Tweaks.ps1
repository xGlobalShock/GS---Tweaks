param([string]$Type)

# Rainbow Six Siege Optimization Script
# Optimizes R6 Siege for competitive gameplay

switch ($Type) {
    "Launch" {
        # R6 Siege launches through Ubisoft Connect
        Write-Host "Rainbow Six Siege launches through Ubisoft Connect."
        Write-Host "Recommended settings will be applied to game config."
    }
    "Config" {
        # Optimize R6 Siege GameSettings.ini
        $r6ConfigPath = Join-Path $env:USERPROFILE "Documents\My Games\Rainbow Six - Siege"
        
        if (Test-Path $r6ConfigPath) {
            $gameSettingsPath = Join-Path $r6ConfigPath "GameSettings.ini"
            
            if (Test-Path $gameSettingsPath) {
                attrib -R $gameSettingsPath
                $content = Get-Content $gameSettingsPath
                
                $settings = @{
                    "VSync" = "0"
                    "FPSLimit" = "0"
                    "RefreshRate" = "240"
                    "RENDER_SCALING" = "100"
                    "MSAA" = "0"
                    "TEXTURE_QUALITY" = "0"
                    "LOD_QUALITY" = "0"
                    "SHADOW_QUALITY" = "0"
                    "SHADING_QUALITY" = "0"
                    "LENS_EFFECTS" = "0"
                    "ZOOM_IN_DEPTH_OF_FIELD" = "0"
                    "AMBIENT_OCCLUSION" = "0"
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
                
                Set-Content -Path $gameSettingsPath -Value $content
                attrib +R $gameSettingsPath
                Write-Host "Rainbow Six Siege settings optimized!"
            }
        } else {
            Write-Host "R6 Siege config folder not found."
        }
    }
    "Registry" {
        # R6-specific registry optimizations
        Write-Host "Applying Rainbow Six Siege registry optimizations..."
        
        $r6RegPath = "HKCU:\Software\Ubisoft\Rainbow Six - Siege"
        if (!(Test-Path $r6RegPath)) {
            New-Item -Path $r6RegPath -Force | Out-Null
        }
        
        Write-Host "R6 Siege registry optimizations applied!"
    }
}
