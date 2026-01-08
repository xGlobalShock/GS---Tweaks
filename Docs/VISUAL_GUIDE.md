# Games Library - Visual Guide

## Navigation Sidebar

```
┌─────────────────────────────┐
│  GS Tweaker                 │
│                             │
│  🎮 System Tweaks          │
│  🎯 Apex Optimization      │
│  🎮 Games Library    ← NEW! │
│  📹 OBS Presets            │
│  🟢 Nvidia Control         │
└─────────────────────────────┘
```

## Games Library Section Layout

```
╔═══════════════════════════════════════════════════════════╗
║                      Games Library                         ║
║  Optimize your favorite games for maximum performance     ║
╠═══════════════════════════════════════════════════════════╣
║                                                            ║
║  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   ║
║  │   [APEX]     │  │      V       │  │     CS       │   ║
║  │              │  │              │  │              │   ║
║  │ Apex Legends │  │  Valorant    │  │Counter-Strike│   ║
║  │Battle Royale │  │Tactical FPS  │  │Competitive   │   ║
║  │ [Optimize]   │  │ [Optimize]   │  │ [Optimize]   │   ║
║  └──────────────┘  └──────────────┘  └──────────────┘   ║
║                                                            ║
║  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   ║
║  │   [🎮]       │  │     COD      │  │     LoL      │   ║
║  │              │  │              │  │              │   ║
║  │  Fortnite    │  │Call of Duty  │  │  League of   │   ║
║  │Battle Royale │  │Modern Warfare│  │   Legends    │   ║
║  │ [Optimize]   │  │ [Optimize]   │  │ [Optimize]   │   ║
║  └──────────────┘  └──────────────┘  └──────────────┘   ║
║                                                            ║
║  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   ║
║  │     OW       │  │      R6      │  │   [⚽]       │   ║
║  │              │  │              │  │              │   ║
║  │ Overwatch 2  │  │Rainbow Six   │  │Rocket League │   ║
║  │Team Shooter  │  │Tactical FPS  │  │Vehicular     │   ║
║  │ [Optimize]   │  │ [Optimize]   │  │ [Optimize]   │   ║
║  └──────────────┘  └──────────────┘  └──────────────┘   ║
║                                                            ║
║  ╔════════════════════════════════════════════════════╗  ║
║  ║              What's Included                        ║  ║
║  ╠════════════════════════════════════════════════════╣  ║
║  ║  ┌────────────┐  ┌────────────┐  ┌────────────┐  ║  ║
║  ║  │🎮 Launch   │  │📄 Config   │  │⚙️ Registry │  ║  ║
║  ║  │  Options   │  │   Files    │  │   Tweaks   │  ║  ║
║  ║  └────────────┘  └────────────┘  └────────────┘  ║  ║
║  ╚════════════════════════════════════════════════════╝  ║
╚═══════════════════════════════════════════════════════════╝
```

## Game Card Colors

```
┌─────────────────────────────────────────────┐
│ Apex Legends       │ Red      │ #DF3F3F    │
│ Valorant           │ Pink-Red │ #FF4655    │
│ Counter-Strike 2   │ Orange   │ #F89C31    │
│ Fortnite           │ Cyan     │ #00D1FF    │
│ Call of Duty       │ Green    │ #5BBF21    │
│ League of Legends  │ Gold     │ #D4AF37    │
│ Overwatch 2        │ Orange   │ #F99E1A    │
│ Rainbow Six Siege  │ Purple   │ #9147FF    │
│ Rocket League      │ Blue     │ #0095DA    │
└─────────────────────────────────────────────┘
```

## Interaction Flow

```
1. User clicks "Games Library" in sidebar
   └─> Section displays with 9 game cards

2. User clicks "Optimize" on a game card (e.g., Valorant)
   └─> PowerShell script executes with admin privileges
       ├─> Apply Launch Options (if applicable)
       ├─> Modify Config Files
       └─> Apply Registry Tweaks

3. Popup displays optimization results
   └─> Shows what was changed
       └─> User clicks "OK" to close
```

## Script Execution Flow

```
User clicks [Optimize] button
         │
         ├─> FindName("BtnOptimizeValorant")
         │
         ├─> Add_Click event fires
         │
         ├─> Build script path
         │   └─> Tools/Tweaks/ValorantTweaks.ps1
         │
         ├─> Execute with elevated privileges
         │   ├─> -Type Launch  (Steam launch options)
         │   ├─> -Type Config  (Game config files)
         │   └─> -Type Registry (Registry tweaks)
         │
         └─> Show completion popup
             └─> Display results to user
```

## Optimization Types by Game

```
┌──────────────────┬─────────┬────────┬──────────┐
│ Game             │ Launch  │ Config │ Registry │
├──────────────────┼─────────┼────────┼──────────┤
│ Apex Legends     │    ✓    │   ✓    │    ✓     │
│ Valorant         │         │   ✓    │    ✓     │
│ CS2              │    ✓    │   ✓    │    ✓     │
│ Fortnite         │         │   ✓    │    ✓     │
│ Call of Duty     │         │   ✓    │    ✓     │
│ League of Legends│         │   ✓    │    ✓     │
│ Overwatch 2      │         │   ✓    │    ✓     │
│ Rainbow Six      │         │   ✓    │    ✓     │
│ Rocket League    │    ✓    │   ✓    │    ✓     │
└──────────────────┴─────────┴────────┴──────────┘
```

## File Locations Modified

### Game Config Files
```
Valorant:
  %LOCALAPPDATA%\VALORANT\Saved\Config\Windows\GameUserSettings.ini

CS2:
  %USERPROFILE%\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg\autoexec.cfg

Fortnite:
  %LOCALAPPDATA%\FortniteGame\Saved\Config\WindowsClient\GameUserSettings.ini

Call of Duty:
  %USERPROFILE%\Documents\Call of Duty\players\config.cfg

League of Legends:
  %USERPROFILE%\Riot Games\League of Legends\Config\game.cfg

Overwatch 2:
  %USERPROFILE%\Documents\Overwatch\Settings\Settings_v0.ini

Rainbow Six Siege:
  %USERPROFILE%\Documents\My Games\Rainbow Six - Siege\GameSettings.ini

Rocket League:
  %USERPROFILE%\Documents\My Games\Rocket League\TAGame\Config\TASystemSettings.ini
```

### Registry Keys Modified
```
HKCU:\Software\Valve\Steam\Apps\[AppID]       (Launch options)
HKCU:\Software\Riot Games\VALORANT           (Valorant settings)
HKCU:\System\GameConfigStore                 (Game DVR settings)
HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers (GPU scheduling)
```

## Quick Reference - Button Names

```
Navigation:
  $BtnNavGamesLibrary

Game Cards:
  $BtnOptimizeApex
  $BtnOptimizeValorant
  $BtnOptimizeCS2
  $BtnOptimizeFortnite
  $BtnOptimizeCOD
  $BtnOptimizeLoL
  $BtnOptimizeOW2
  $BtnOptimizeR6
  $BtnOptimizeRL

Section:
  $SectionGamesLibrary
```

## Design Details

### Card Dimensions
- Width: Auto (1/3 of grid)
- Padding: 20px
- Border: 2px solid (game-specific color)
- Border Radius: 16px

### Icon/Logo Area
- Height: 120px
- Background: #1E222D
- Border Radius: 12px

### Typography
- Title: 16px, Bold
- Subtitle: 10px, Secondary Color (#94A3B8)
- Button: 11px

### Spacing
- Card margins: 10px between cards
- Section margin: 30px below header
- Button height: 32px
```
