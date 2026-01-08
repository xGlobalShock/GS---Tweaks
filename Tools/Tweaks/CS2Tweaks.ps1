param([string]$Type)

# Counter-Strike 2 Optimization Script
# Optimizes CS2 for competitive gameplay

switch ($Type) {
    "Launch" {
        # CS2 Steam Launch Options
        $gameAppID = 730
        $launchOptions = "-high -threads 8 -novid -nojoy -freq 240 +fps_max 0 +mat_queue_mode 2 +cl_forcepreload 1"
        $steamRegistryPath = "HKCU:\Software\Valve\Steam\Apps\$gameAppID"
        
        if (!(Test-Path $steamRegistryPath)) {
            New-Item -Path $steamRegistryPath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $steamRegistryPath -Name "LaunchOptions" -Value $launchOptions
        Write-Host "CS2 launch options applied: $launchOptions"
    }
    "Config" {
        # Optimize CS2 video settings through config file
        $cs2ConfigPath = Join-Path $env:USERPROFILE "steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg"
        
        if (Test-Path $cs2ConfigPath) {
            $autoexecPath = Join-Path $cs2ConfigPath "autoexec.cfg"
            
            $configContent = @"
// CS2 Performance Config
// Network Settings
rate "786432"
cl_updaterate "128"
cl_cmdrate "128"
cl_interp "0"
cl_interp_ratio "1"

// FPS Optimization
fps_max "0"
fps_max_menu "240"
mat_queue_mode "2"
cl_forcepreload "1"

// Mouse Settings
m_rawinput "1"
m_mouseaccel1 "0"
m_mouseaccel2 "0"

// Visual Settings
r_drawparticles "0"
r_drawtracers_firstperson "0"
func_break_max_pieces "0"

// Sound Settings
snd_mixahead "0.05"
snd_headphone_pan_exponent "1"

echo "CS2 Performance Config Loaded!"
"@
            
            Set-Content -Path $autoexecPath -Value $configContent
            Write-Host "CS2 autoexec.cfg created successfully at: $autoexecPath"
        } else {
            Write-Host "CS2 config folder not found. Please verify game installation."
        }
    }
    "Registry" {
        # CS2-specific registry optimizations
        Write-Host "Applying CS2 registry optimizations..."
        
        # Disable Game DVR for CS2
        $gameDVRPath = "HKCU:\System\GameConfigStore"
        if (!(Test-Path $gameDVRPath)) {
            New-Item -Path $gameDVRPath -Force | Out-Null
        }
        Set-ItemProperty -Path $gameDVRPath -Name "GameDVR_Enabled" -Value 0 -Type DWord
        
        Write-Host "CS2 registry optimizations applied!"
    }
}
