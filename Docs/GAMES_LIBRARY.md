# Games Library - Documentation

## Overview
The Games Library is a comprehensive game optimization hub that provides performance tweaks and competitive configurations for popular multiplayer games.

## Supported Games

### 1. Apex Legends
- **Optimizations**: Launch options, videoconfig tweaks, shader cache management
- **Script**: `ApexTweaks.ps1`
- **Features**:
  - Steam launch options optimization
  - Video config for maximum FPS
  - CSM shadow optimization
  - Shader cache clearing

### 2. Valorant
- **Optimizations**: Config file tweaks, registry optimizations
- **Script**: `ValorantTweaks.ps1`
- **Features**:
  - Frame rate limit optimization
  - Graphics quality presets
  - Registry tweaks for performance

### 3. Counter-Strike 2 (CS2)
- **Optimizations**: Launch options, autoexec config, registry tweaks
- **Script**: `CS2Tweaks.ps1`
- **Features**:
  - Steam launch options
  - Network settings optimization
  - FPS maximization config
  - Mouse and sound settings

### 4. Fortnite
- **Optimizations**: GameUserSettings.ini tweaks, GPU scheduling
- **Script**: `FortniteTweaks.ps1`
- **Features**:
  - Frame rate unlock
  - Low graphics settings for performance
  - Motion blur disabled
  - FPS counter enabled

### 5. Call of Duty (Modern Warfare/Warzone)
- **Optimizations**: Config file tweaks, registry optimizations
- **Script**: `CODTweaks.ps1`
- **Features**:
  - FPS maximization
  - Network optimization
  - Visual effects reduction
  - V-Sync disabled

### 6. League of Legends
- **Optimizations**: Game config tweaks, registry settings
- **Script**: `LoLTweaks.ps1`
- **Features**:
  - Performance mode settings
  - Shadow and effects optimization
  - Particle optimization
  - Screen shake disabled

### 7. Overwatch 2
- **Optimizations**: Settings.ini tweaks, reduced buffering
- **Script**: `OW2Tweaks.ps1`
- **Features**:
  - Frame rate cap removal
  - Low graphics quality presets
  - Ambient occlusion disabled
  - V-Sync disabled

### 8. Rainbow Six Siege
- **Optimizations**: GameSettings.ini tweaks
- **Script**: `R6Tweaks.ps1`
- **Features**:
  - FPS limit removal
  - Render scaling optimization
  - Shadow and texture quality reduction
  - Lens effects disabled

### 9. Rocket League
- **Optimizations**: Launch options, TASystemSettings.ini tweaks
- **Script**: `RLTweaks.ps1`
- **Features**:
  - Steam launch options
  - Dynamic shadows disabled
  - Motion blur and bloom disabled
  - V-Sync disabled

## UI Structure

### Navigation
- New sidebar button: **Games Library** (Controller icon)
- Located between "Apex Optimization" and "OBS Presets"

### Layout
- 3x3 grid of game cards
- Each card includes:
  - Game icon/logo
  - Game name
  - Genre/category
  - "Optimize" button
  - Color-coded borders

### Information Section
- "What's Included" panel explaining optimization types:
  - **Launch Options**: Optimized launch parameters
  - **Config Files**: Pro-level configuration files
  - **Registry Tweaks**: Game-specific registry optimizations

## Script Architecture

All game optimization scripts follow the same pattern:
```powershell
param([string]$Type)

switch ($Type) {
    "Launch" {
        # Steam/launcher launch options
    }
    "Config" {
        # Game configuration file tweaks
    }
    "Registry" {
        # Windows registry optimizations
    }
}
```

## Integration with Launch.ps1

To integrate the Games Library buttons with the main application:

1. **Add event handlers** in `Settings/Launch.ps1` for each game button:
```powershell
$BtnOptimizeApex = $UserControl.FindName("BtnOptimizeApex")
$BtnOptimizeValorant = $UserControl.FindName("BtnOptimizeValorant")
# ... etc
```

2. **Create optimization handlers** that call the respective scripts:
```powershell
$BtnOptimizeApex.Add_Click({
    $scriptPath = "$PSScriptRoot\..\Tools\Tweaks\ApexTweaks.ps1"
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Launch"
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Config"
})
```

3. **Add navigation handler** for the Games Library button:
```powershell
$BtnNavGamesLibrary = $UserControl.FindName("BtnNavGamesLibrary")
$BtnNavGamesLibrary.Add_Click({
    Hide-AllSections
    $SectionGamesLibrary.Visibility = "Visible"
    Update-NavButtons -ActiveButton $BtnNavGamesLibrary
})
```

## File Locations

- **UI**: `UI/UI.xaml` (lines ~328 and ~1172)
- **Scripts**: `Tools/Tweaks/[Game]Tweaks.ps1`
- **Documentation**: `GAMES_LIBRARY.md`

## Future Enhancements

Potential additions to the Games Library:
- Game detection (check if game is installed)
- Backup/restore original settings
- Per-game optimization profiles (Pro, Balanced, Max FPS)
- Game-specific performance benchmarking
- More games: Battlefield, R6 Extraction, The Finals, etc.
- Integration with existing Apex optimization page

## Color Scheme

Each game card uses a unique accent color:
- **Apex Legends**: #DF3F3F (Red)
- **Valorant**: #FF4655 (Pink-Red)
- **CS2**: #F89C31 (Orange)
- **Fortnite**: #00D1FF (Cyan)
- **Call of Duty**: #5BBF21 (Green)
- **League of Legends**: #D4AF37 (Gold)
- **Overwatch 2**: #F99E1A (Orange-Yellow)
- **Rainbow Six Siege**: #9147FF (Purple)
- **Rocket League**: #0095DA (Blue)
