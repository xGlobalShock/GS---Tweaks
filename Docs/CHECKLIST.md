# Games Library - Implementation Checklist

## ✅ Completed

### UI Components
- [x] Added "Games Library" navigation button to sidebar
- [x] Created SectionGamesLibrary with proper styling
- [x] Designed 9 game cards with unique colors
- [x] Added "What's Included" information section
- [x] Implemented scrollable container for game cards
- [x] Applied consistent styling matching existing UI

### PowerShell Scripts
- [x] ValorantTweaks.ps1 - Config and registry optimizations
- [x] CS2Tweaks.ps1 - Launch, config, and registry tweaks
- [x] FortniteTweaks.ps1 - GameUserSettings and GPU scheduling
- [x] CODTweaks.ps1 - Config file and registry optimizations
- [x] LoLTweaks.ps1 - Game config and registry settings
- [x] OW2Tweaks.ps1 - Settings file and registry tweaks
- [x] R6Tweaks.ps1 - GameSettings.ini optimizations
- [x] RLTweaks.ps1 - Launch options and config tweaks

### Documentation
- [x] GAMES_LIBRARY.md - Feature overview and game details
- [x] INTEGRATION_GUIDE.md - Launch.ps1 integration instructions
- [x] SUMMARY.md - Complete project summary
- [x] VISUAL_GUIDE.md - Visual layout and design reference
- [x] CHECKLIST.md - This implementation checklist

## 🔲 To Be Completed

### Launch.ps1 Integration
- [ ] Add FindName() calls for all UI elements
  - [ ] $BtnNavGamesLibrary
  - [ ] $SectionGamesLibrary
  - [ ] $BtnOptimizeApex (and 8 other game buttons)

- [ ] Add navigation handler for $BtnNavGamesLibrary
  - [ ] Hide all sections
  - [ ] Show $SectionGamesLibrary
  - [ ] Update button states

- [ ] Add click handlers for each game button
  - [ ] $BtnOptimizeApex.Add_Click({...})
  - [ ] $BtnOptimizeValorant.Add_Click({...})
  - [ ] $BtnOptimizeCS2.Add_Click({...})
  - [ ] $BtnOptimizeFortnite.Add_Click({...})
  - [ ] $BtnOptimizeCOD.Add_Click({...})
  - [ ] $BtnOptimizeLoL.Add_Click({...})
  - [ ] $BtnOptimizeOW2.Add_Click({...})
  - [ ] $BtnOptimizeR6.Add_Click({...})
  - [ ] $BtnOptimizeRL.Add_Click({...})

- [ ] Update Hide-AllSections function
  - [ ] Add $SectionGamesLibrary.Visibility = "Collapsed"

### Testing
- [ ] Test navigation to Games Library section
- [ ] Verify all game cards display correctly
- [ ] Test Apex Legends optimization
- [ ] Test Valorant optimization
- [ ] Test CS2 optimization
- [ ] Test Fortnite optimization
- [ ] Test Call of Duty optimization
- [ ] Test League of Legends optimization
- [ ] Test Overwatch 2 optimization
- [ ] Test Rainbow Six Siege optimization
- [ ] Test Rocket League optimization
- [ ] Verify error handling when game not installed
- [ ] Test popup displays for success/error messages

### Future Enhancements
- [ ] Game detection logic
  - [ ] Check if game is installed before optimization
  - [ ] Display "Not Installed" badge on game cards
  - [ ] Disable optimize button for uninstalled games

- [ ] Backup system
  - [ ] Create backup of original config files
  - [ ] Add "Restore Defaults" button
  - [ ] Store backups in Config/Backups/ folder

- [ ] Multiple profiles
  - [ ] Pro Profile (maximum performance)
  - [ ] Balanced Profile (performance + quality)
  - [ ] Max FPS Profile (absolute lowest settings)

- [ ] Additional games
  - [ ] Battlefield series
  - [ ] The Finals
  - [ ] Escape from Tarkov
  - [ ] PUBG
  - [ ] Destiny 2
  - [ ] Warframe

- [ ] Performance benchmarking
  - [ ] Before/after FPS comparison
  - [ ] Launch time measurement
  - [ ] System resource usage tracking

## Quick Integration Steps

### Step 1: Open Settings/Launch.ps1
Location: `e:\Dev\GS - Tweaks\Settings\Launch.ps1`

### Step 2: Add UI Element References (around line 100-200)
Copy the code from INTEGRATION_GUIDE.md section "Step 1: Find UI Elements"

### Step 3: Add Navigation Handler (with other nav handlers)
Copy the code from INTEGRATION_GUIDE.md section "Step 2: Add Navigation Handler"

### Step 4: Add Game Optimization Handlers (after existing handlers)
Copy all 9 game handlers from INTEGRATION_GUIDE.md section "Step 3: Add Game Optimization Handlers"

### Step 5: Update Hide-AllSections Function
Add the line: `$SectionGamesLibrary.Visibility = "Collapsed"`

### Step 6: Test
Run `Launch.vbs` and verify all functionality works

## Files Modified

```
Modified:
  UI/UI.xaml (lines ~328 and ~1179)

Created:
  Tools/Tweaks/ValorantTweaks.ps1
  Tools/Tweaks/CS2Tweaks.ps1
  Tools/Tweaks/FortniteTweaks.ps1
  Tools/Tweaks/CODTweaks.ps1
  Tools/Tweaks/LoLTweaks.ps1
  Tools/Tweaks/OW2Tweaks.ps1
  Tools/Tweaks/R6Tweaks.ps1
  Tools/Tweaks/RLTweaks.ps1
  GAMES_LIBRARY.md
  INTEGRATION_GUIDE.md
  SUMMARY.md
  VISUAL_GUIDE.md
  CHECKLIST.md (this file)

To Be Modified:
  Settings/Launch.ps1 (integration needed)
```

## Verification Commands

### Check if navigation button exists
```powershell
Select-String -Path "UI\UI.xaml" -Pattern "BtnNavGamesLibrary"
```

### Check if section exists
```powershell
Select-String -Path "UI\UI.xaml" -Pattern "SectionGamesLibrary"
```

### Check if all game buttons exist
```powershell
Select-String -Path "UI\UI.xaml" -Pattern "BtnOptimize"
```

### Check if all scripts exist
```powershell
Get-ChildItem "Tools\Tweaks\*Tweaks.ps1" | Where-Object { $_.Name -match "Valorant|CS2|Fortnite|COD|LoL|OW2|R6|RL" }
```

## Support & Troubleshooting

### Common Issues

**Issue**: Game optimization doesn't work
- **Solution**: Check if game is installed in default location
- **Solution**: Run PowerShell scripts manually to see error messages
- **Solution**: Verify admin privileges are granted

**Issue**: Popup doesn't display
- **Solution**: Check Show-InfoPopup function is defined
- **Solution**: Verify popup overlay elements exist in XAML
- **Solution**: Check for PowerShell execution errors

**Issue**: Navigation button doesn't work
- **Solution**: Verify FindName() returns non-null object
- **Solution**: Check if Add_Click handler is attached
- **Solution**: Verify section visibility is being toggled

**Issue**: Config file not found
- **Solution**: Game needs to be launched at least once
- **Solution**: Check default installation paths
- **Solution**: Add manual path selection option

## Notes

- All scripts require elevated privileges (admin rights)
- Config file paths vary by game and may need adjustment
- Steam launch options work for Steam games only
- Battle.net and Epic Games launcher games have limited launch options
- Some games may require restart for changes to take effect
- Always backup original config files before optimization
- Registry changes should be reversible

## Resources

- Game-specific optimization guides: See GAMES_LIBRARY.md
- Integration instructions: See INTEGRATION_GUIDE.md
- Visual reference: See VISUAL_GUIDE.md
- Project overview: See SUMMARY.md
