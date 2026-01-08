param([string]$Type)

# League of Legends Optimization Script
# Optimizes LoL for competitive gameplay

switch ($Type) {
    "Launch" {
        # League of Legends launches through Riot Client
        Write-Host "League of Legends launches through Riot Client."
        Write-Host "Optimizations will be applied to game config files."
    }
    "Config" {
        # Optimize League of Legends config
        $lolConfigPath = Join-Path $env:USERPROFILE "Riot Games\League of Legends\Config"
        
        if (Test-Path $lolConfigPath) {
            $gameConfigPath = Join-Path $lolConfigPath "game.cfg"
            
            $configContent = @"
[General]
WindowMode=0
RelativeTeamColors=1
EnableGrassSwaying=0
EnableHUDAnimations=0
EnableLineMissileVis=0

[Performance]
ShadowQuality=0
CharacterQuality=0
EffectsQuality=0
EnvironmentQuality=0
CharacterInking=0
EnableParticleOptimization=1
DisableScreenShake=1

[Display]
AutomaticAcquisitionRange=1
EnableTargetedAttackMove=1
ShowTimestamps=1
"@
            
            Set-Content -Path $gameConfigPath -Value $configContent
            Write-Host "League of Legends config optimized!"
        } else {
            Write-Host "League of Legends config folder not found."
        }
    }
    "Registry" {
        # LoL-specific registry optimizations
        Write-Host "Applying League of Legends registry optimizations..."
        
        $lolRegPath = "HKCU:\Software\Riot Games\League of Legends"
        if (!(Test-Path $lolRegPath)) {
            New-Item -Path $lolRegPath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $lolRegPath -Name "DisableFullscreenOptimizations" -Value 1 -Type DWord
        
        Write-Host "LoL registry optimizations applied!"
    }
}
