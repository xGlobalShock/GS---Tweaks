# Games Library Integration Guide for Launch.ps1

## Overview
This guide explains how to integrate the Games Library section with the main application logic in `Settings/Launch.ps1`.

## Step 1: Find UI Elements

Add these lines after the existing `FindName()` calls (around line 100-200):

```powershell
# Games Library Navigation
$BtnNavGamesLibrary = $UserControl.FindName("BtnNavGamesLibrary")
$SectionGamesLibrary = $UserControl.FindName("SectionGamesLibrary")

# Game Optimization Buttons
$BtnOptimizeApex = $UserControl.FindName("BtnOptimizeApex")
$BtnOptimizeValorant = $UserControl.FindName("BtnOptimizeValorant")
$BtnOptimizeCS2 = $UserControl.FindName("BtnOptimizeCS2")
$BtnOptimizeFortnite = $UserControl.FindName("BtnOptimizeFortnite")
$BtnOptimizeCOD = $UserControl.FindName("BtnOptimizeCOD")
$BtnOptimizeLoL = $UserControl.FindName("BtnOptimizeLoL")
$BtnOptimizeOW2 = $UserControl.FindName("BtnOptimizeOW2")
$BtnOptimizeR6 = $UserControl.FindName("BtnOptimizeR6")
$BtnOptimizeRL = $UserControl.FindName("BtnOptimizeRL")
```

## Step 2: Add Navigation Handler

Add this navigation handler with the other navigation handlers:

```powershell
# Games Library Navigation
$BtnNavGamesLibrary.Add_Click({
    # Hide all sections
    $SectionGaming.Visibility = "Collapsed"
    $SectionApex.Visibility = "Collapsed"
    $SectionOBS.Visibility = "Collapsed"
    $SectionNvidia.Visibility = "Collapsed"
    $SectionAbout.Visibility = "Collapsed"
    $SectionGamesLibrary.Visibility = "Visible"
    
    # Update button states
    $BtnNavGaming.Tag = ""
    $BtnNavApex.Tag = ""
    $BtnNavGamesLibrary.Tag = "Active"
    $BtnNavOBS.Tag = ""
    $BtnNavNvidia.Tag = ""
})
```

## Step 3: Add Game Optimization Handlers

Add these click handlers for each game. You can place them after the existing button handlers:

### Apex Legends
```powershell
$BtnOptimizeApex.Add_Click({
    try {
        $scriptPath = Join-Path $PSScriptRoot "..\Tools\Tweaks\ApexTweaks.ps1"
        
        # Show info popup
        Show-InfoPopup -title "Applying Apex Optimizations" -statusMessage "Optimizing Apex Legends for competitive gameplay..." -gridItems @()
        
        # Apply Launch Options
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Launch" -Wait -WindowStyle Hidden
        
        # Apply Config
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Config" -Wait -WindowStyle Hidden
        
        # Show completion popup
        Show-InfoPopup -title "Optimization Complete" -statusMessage "Apex Legends has been optimized!" -gridItems @(
            @{ name = "Launch Options"; value = "Applied" },
            @{ name = "Video Config"; value = "Optimized" }
        )
    }
    catch {
        [System.Windows.MessageBox]::Show("Error optimizing Apex Legends: $_", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
})
```

### Valorant
```powershell
$BtnOptimizeValorant.Add_Click({
    try {
        $scriptPath = Join-Path $PSScriptRoot "..\Tools\Tweaks\ValorantTweaks.ps1"
        
        # Apply Config
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Config" -Wait -WindowStyle Hidden
        
        # Apply Registry
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Registry" -Wait -WindowStyle Hidden
        
        Show-InfoPopup -title "Optimization Complete" -statusMessage "Valorant has been optimized for competitive play!" -gridItems @(
            @{ name = "Game Config"; value = "Optimized" },
            @{ name = "Registry"; value = "Applied" }
        )
    }
    catch {
        [System.Windows.MessageBox]::Show("Error optimizing Valorant: $_", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
})
```

### Counter-Strike 2
```powershell
$BtnOptimizeCS2.Add_Click({
    try {
        $scriptPath = Join-Path $PSScriptRoot "..\Tools\Tweaks\CS2Tweaks.ps1"
        
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Launch" -Wait -WindowStyle Hidden
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Config" -Wait -WindowStyle Hidden
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Registry" -Wait -WindowStyle Hidden
        
        Show-InfoPopup -title "Optimization Complete" -statusMessage "CS2 has been optimized!" -gridItems @(
            @{ name = "Launch Options"; value = "Applied" },
            @{ name = "Autoexec Config"; value = "Created" },
            @{ name = "Registry"; value = "Applied" }
        )
    }
    catch {
        [System.Windows.MessageBox]::Show("Error optimizing CS2: $_", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
})
```

### Fortnite
```powershell
$BtnOptimizeFortnite.Add_Click({
    try {
        $scriptPath = Join-Path $PSScriptRoot "..\Tools\Tweaks\FortniteTweaks.ps1"
        
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Config" -Wait -WindowStyle Hidden
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Registry" -Wait -WindowStyle Hidden
        
        Show-InfoPopup -title "Optimization Complete" -statusMessage "Fortnite has been optimized for maximum FPS!" -gridItems @(
            @{ name = "Game Settings"; value = "Optimized" },
            @{ name = "GPU Scheduling"; value = "Enabled" }
        )
    }
    catch {
        [System.Windows.MessageBox]::Show("Error optimizing Fortnite: $_", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
})
```

### Call of Duty
```powershell
$BtnOptimizeCOD.Add_Click({
    try {
        $scriptPath = Join-Path $PSScriptRoot "..\Tools\Tweaks\CODTweaks.ps1"
        
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Config" -Wait -WindowStyle Hidden
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Registry" -Wait -WindowStyle Hidden
        
        Show-InfoPopup -title "Optimization Complete" -statusMessage "Call of Duty has been optimized!" -gridItems @(
            @{ name = "Config File"; value = "Created/Updated" },
            @{ name = "Registry"; value = "Applied" }
        )
    }
    catch {
        [System.Windows.MessageBox]::Show("Error optimizing COD: $_", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
})
```

### League of Legends
```powershell
$BtnOptimizeLoL.Add_Click({
    try {
        $scriptPath = Join-Path $PSScriptRoot "..\Tools\Tweaks\LoLTweaks.ps1"
        
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Config" -Wait -WindowStyle Hidden
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Registry" -Wait -WindowStyle Hidden
        
        Show-InfoPopup -title "Optimization Complete" -statusMessage "League of Legends has been optimized!" -gridItems @(
            @{ name = "Game Config"; value = "Optimized" },
            @{ name = "Registry"; value = "Applied" }
        )
    }
    catch {
        [System.Windows.MessageBox]::Show("Error optimizing LoL: $_", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
})
```

### Overwatch 2
```powershell
$BtnOptimizeOW2.Add_Click({
    try {
        $scriptPath = Join-Path $PSScriptRoot "..\Tools\Tweaks\OW2Tweaks.ps1"
        
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Config" -Wait -WindowStyle Hidden
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Registry" -Wait -WindowStyle Hidden
        
        Show-InfoPopup -title "Optimization Complete" -statusMessage "Overwatch 2 has been optimized!" -gridItems @(
            @{ name = "Settings File"; value = "Optimized" },
            @{ name = "Registry"; value = "Applied" }
        )
    }
    catch {
        [System.Windows.MessageBox]::Show("Error optimizing OW2: $_", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
})
```

### Rainbow Six Siege
```powershell
$BtnOptimizeR6.Add_Click({
    try {
        $scriptPath = Join-Path $PSScriptRoot "..\Tools\Tweaks\R6Tweaks.ps1"
        
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Config" -Wait -WindowStyle Hidden
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Registry" -Wait -WindowStyle Hidden
        
        Show-InfoPopup -title "Optimization Complete" -statusMessage "Rainbow Six Siege has been optimized!" -gridItems @(
            @{ name = "Game Settings"; value = "Optimized" },
            @{ name = "Registry"; value = "Applied" }
        )
    }
    catch {
        [System.Windows.MessageBox]::Show("Error optimizing R6: $_", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
})
```

### Rocket League
```powershell
$BtnOptimizeRL.Add_Click({
    try {
        $scriptPath = Join-Path $PSScriptRoot "..\Tools\Tweaks\RLTweaks.ps1"
        
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Launch" -Wait -WindowStyle Hidden
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Config" -Wait -WindowStyle Hidden
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Type Registry" -Wait -WindowStyle Hidden
        
        Show-InfoPopup -title "Optimization Complete" -statusMessage "Rocket League has been optimized!" -gridItems @(
            @{ name = "Launch Options"; value = "Applied" },
            @{ name = "System Settings"; value = "Optimized" },
            @{ name = "Registry"; value = "Applied" }
        )
    }
    catch {
        [System.Windows.MessageBox]::Show("Error optimizing Rocket League: $_", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
})
```

## Step 4: Update Section Hiding

Make sure to update the section hiding function to include the new Games Library section:

```powershell
function Hide-AllSections {
    $SectionGaming.Visibility = "Collapsed"
    $SectionApex.Visibility = "Collapsed"
    $SectionGamesLibrary.Visibility = "Collapsed"  # Add this line
    $SectionOBS.Visibility = "Collapsed"
    $SectionNvidia.Visibility = "Collapsed"
    $SectionAbout.Visibility = "Collapsed"
}
```

## Notes

1. All optimization scripts are executed with elevated privileges using `-Verb RunAs`
2. The `-WindowStyle Hidden` parameter hides the PowerShell window during execution
3. Each game has multiple optimization types: Launch, Config, and Registry
4. Error handling is included with try-catch blocks
5. Success messages are displayed using the `Show-InfoPopup` function

## Testing

To test the integration:

1. Run `Launch.vbs` to start the application
2. Click on "Games Library" in the sidebar
3. Click "Optimize" on any game card
4. Verify that the optimization completes successfully
5. Check the game's config folder to confirm changes were applied
