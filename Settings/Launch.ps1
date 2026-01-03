
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# Load XAML UserControl

# Read XAML as raw string and load with XmlReader (supports x:Name and namespaces)
$XamlString = Get-Content "$PSScriptRoot\..\UI\UI.xaml" -Raw
$StringReader = New-Object System.IO.StringReader($XamlString)
$XmlReader = [System.Xml.XmlReader]::Create($StringReader)
$UserControl = [Windows.Markup.XamlReader]::Load($XmlReader)

# Create a Window and set the UserControl as its content
$Window = New-Object System.Windows.Window
$Window.Title = "GlobalShock Tweaker"
$Window.Width = 1600
$Window.Height = 1000
$Window.Content = $UserControl
$Window.WindowStartupLocation = 'CenterScreen'
$Window.ResizeMode = 'CanResize'

function Invoke-PresetDownload($presetName) {
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select a folder to save the $presetName preset"
    $folderBrowser.ShowNewFolderButton = $true

    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $destination = $folderBrowser.SelectedPath
        $source = Join-Path (Split-Path $PSScriptRoot) "Tools\OBS\Presets\$presetName"

        if (Test-Path $source) {
            Copy-Item -Path $source -Destination $destination -Recurse -Force
            if ($StatusText) { $StatusText.Text = "$presetName preset downloaded to $destination" }
        } else {
            if ($StatusText) { $StatusText.Text = "Preset $presetName not found." }
        }
    }
}

function Show-CacheResultPopup($title, $description, $filesDeleted, $filesRemaining) {
    $PopupOverlay = $UserControl.FindName("PopupOverlay")
    $CacheResultPopupContainer = $UserControl.FindName("CacheResultPopupContainer")
    $PopupTitle = $UserControl.FindName("PopupTitle")
    $PopupDescription = $UserControl.FindName("PopupDescription")
    $FilesDeletedCount = $UserControl.FindName("FilesDeletedCount")
    $FilesRemainingCount = $UserControl.FindName("FilesRemainingCount")
    $PopupOKButton = $UserControl.FindName("PopupOKButton")
    
    if ($null -ne $PopupTitle) { $PopupTitle.Text = $title }
    if ($null -ne $PopupDescription) { $PopupDescription.Text = $description }
    if ($null -ne $FilesDeletedCount) { $FilesDeletedCount.Text = $filesDeleted.ToString() }
    if ($null -ne $FilesRemainingCount) { $FilesRemainingCount.Text = $filesRemaining.ToString() }
    
    if ($null -ne $PopupOverlay) { $PopupOverlay.Visibility = "Visible" }
    if ($null -ne $CacheResultPopupContainer) { $CacheResultPopupContainer.Visibility = "Visible" }
    
    # Setup close button handler
    if ($null -ne $PopupOKButton) {
        $closePopupHandler = {
            $overlay = $UserControl.FindName("PopupOverlay")
            $container = $UserControl.FindName("CacheResultPopupContainer")
            if ($null -ne $overlay) { $overlay.Visibility = "Collapsed" }
            if ($null -ne $container) { $container.Visibility = "Collapsed" }
        }
        $PopupOKButton.Add_Click($closePopupHandler)
    }
}

function Show-InfoPopup($title, $message, $pathToCopy = $null) {
    $InfoPopupOverlay = $UserControl.FindName("InfoPopupOverlay")
    $InfoPopupContainer = $UserControl.FindName("InfoPopupContainer")
    $InfoPopupTitle = $UserControl.FindName("InfoPopupTitle")
    $InfoPopupMessage = $UserControl.FindName("InfoPopupMessage")
    $InfoPopupDataGrid = $UserControl.FindName("InfoPopupDataGrid")
    $InfoPopupOKButton = $UserControl.FindName("InfoPopupOKButton")
    $PathBoxSection = $UserControl.FindName("PathBoxSection")
    $PathBoxText = $UserControl.FindName("PathBoxText")
    $PathOpenButton = $UserControl.FindName("PathOpenButton")
    
    if ($null -ne $InfoPopupTitle) { $InfoPopupTitle.Text = $title }
    
    # Get reference to the data grid border
    $InfoPopupDataGridBorder = $UserControl.FindName("InfoPopupDataGridBorder")
    
    # Clear data grid for all popups
    if ($null -ne $InfoPopupDataGrid) {
        $InfoPopupDataGrid.Children.Clear()
    }
    
    # Hide data grid border for non-configuration popups
    if ($null -ne $InfoPopupDataGridBorder) {
        if ($title -eq "Tweaks Configuration" -or $title -eq "Reset Complete") {
            $InfoPopupDataGridBorder.Visibility = "Visible"
        } else {
            $InfoPopupDataGridBorder.Visibility = "Collapsed"
        }
    }
    
    # Parse and display registry information in grid format
    if ($null -ne $InfoPopupDataGrid -and ($title -eq "Tweaks Configuration" -or $title -eq "Reset Complete")) {
        $InfoPopupDataGrid.Children.Clear()
        
        if ($title -eq "Reset Complete") {
            # Parse reset info from message (format: "- Item [details]")
            $lines = $message -split "`n"
            $resetItems = @()
            foreach ($line in $lines) {
                if ($line -match "^\s*-\s*(.+?)\s*\[(.+?)\]") {
                    $resetItems += @{
                        name = $matches[1].Trim()
                        detail = $matches[2].Trim()
                    }
                }
            }
            
            # Add each reset item as a grid row
            foreach ($item in $resetItems) {
                # Create Grid with 2 columns for Name and Value
                $itemGrid = New-Object System.Windows.Controls.Grid
                $col1 = New-Object System.Windows.Controls.ColumnDefinition
                $col1.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
                $col2 = New-Object System.Windows.Controls.ColumnDefinition
                $col2.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Auto)
                $itemGrid.ColumnDefinitions.Add($col1)
                $itemGrid.ColumnDefinitions.Add($col2)
                
                # Name TextBlock (Orange color)
                $nameBlock = New-Object System.Windows.Controls.TextBlock
                $nameBlock.Text = $item.name + ":"
                $orangeBrush = New-Object System.Windows.Media.BrushConverter
                $nameBlock.Foreground = $orangeBrush.ConvertFromString("#FF9800")
                $nameBlock.FontSize = 12
                $nameBlock.FontWeight = [System.Windows.FontWeights]::Bold
                [System.Windows.Controls.Grid]::SetColumn($nameBlock, 0)
                $itemGrid.Children.Add($nameBlock) | Out-Null
                
                # Value TextBlock
                $valueBlock = New-Object System.Windows.Controls.TextBlock
                $valueBlock.Text = $item.detail
                $lightBrush = New-Object System.Windows.Media.BrushConverter
                $valueBlock.Foreground = $lightBrush.ConvertFromString("#ECEFF1")
                $valueBlock.FontSize = 12
                $valueBlock.TextAlignment = "Right"
                [System.Windows.Controls.Grid]::SetColumn($valueBlock, 1)
                $valueBlock.Margin = New-Object System.Windows.Thickness(12, 0, 0, 0)
                $itemGrid.Children.Add($valueBlock) | Out-Null
                
                # Add to data grid
                $itemGrid.Margin = New-Object System.Windows.Thickness(0, 0, 0, 14)
                $InfoPopupDataGrid.Children.Add($itemGrid) | Out-Null
            }
        } else {
            # Original "Tweaks Configuration" logic
            # Parse registry info from message
            $lines = $message -split "`n"
            $registryItems = @()
            foreach ($line in $lines) {
                if ($line -match "^\s*(.+?)\s*\(") {
                    $registryItems += $line.Trim()
                }
            }
            
            # Add each registry item as a grid row
            foreach ($item in $registryItems) {
                # Create Grid with 2 columns for Name and Value
                $itemGrid = New-Object System.Windows.Controls.Grid
                $col1 = New-Object System.Windows.Controls.ColumnDefinition
                $col1.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
                $col2 = New-Object System.Windows.Controls.ColumnDefinition
                $col2.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Auto)
                $itemGrid.ColumnDefinitions.Add($col1)
                $itemGrid.ColumnDefinitions.Add($col2)
                
                # Parse name and value
                if ($item -match "(.+?)\s*\((.*)\)") {
                    $name = $matches[1].Trim()
                    $detail = $matches[2].Trim()
                    
                    # Normalize value display to "Value set to: X" format
                    if ($detail -match "value:\s*(.+)") {
                        $value = $matches[1].Trim()
                        $detail = "Value set to: $value"
                    } elseif ($detail -match "will be set to:\s*(.+)") {
                        $value = $matches[1].Trim()
                        $detail = "Value set to: $value"
                    } elseif ($detail -match "already exists") {
                        $detail = "Already exists"
                    }
                    
                    # Name TextBlock (Orange color)
                    $nameBlock = New-Object System.Windows.Controls.TextBlock
                    $nameBlock.Text = $name + ":"
                    $orangeBrush = New-Object System.Windows.Media.BrushConverter
                    $nameBlock.Foreground = $orangeBrush.ConvertFromString("#FF9800")
                    $nameBlock.FontSize = 12
                    $nameBlock.FontWeight = [System.Windows.FontWeights]::Bold
                    [System.Windows.Controls.Grid]::SetColumn($nameBlock, 0)
                    $itemGrid.Children.Add($nameBlock) | Out-Null
                    
                    # Value TextBlock
                    $valueBlock = New-Object System.Windows.Controls.TextBlock
                    $valueBlock.Text = $detail
                    $lightBrush = New-Object System.Windows.Media.BrushConverter
                    $valueBlock.Foreground = $lightBrush.ConvertFromString("#ECEFF1")
                    $valueBlock.FontSize = 12
                    $valueBlock.TextAlignment = "Right"
                    [System.Windows.Controls.Grid]::SetColumn($valueBlock, 1)
                    $valueBlock.Margin = New-Object System.Windows.Thickness(12, 0, 0, 0)
                    $itemGrid.Children.Add($valueBlock) | Out-Null
                    
                    # Add to data grid
                    $itemGrid.Margin = New-Object System.Windows.Thickness(0, 0, 0, 14)
                    $InfoPopupDataGrid.Children.Add($itemGrid) | Out-Null
                }
            }
        }
    }
    
    # Display message (status/action required message)
    if ($null -ne $InfoPopupMessage) {
        $InfoPopupMessage.Text = ""
        
        # Check if this is the videoconfig Installation Guide (special formatting)
        if ($message -match "Installation Guide" -or $title -eq "Config Ready") {
            $bullet = [char]0x2022
            $parts = @(
                @{text = "Installation Guide"; bold = $true; underline = $true; fontSize = 16},
                @{text = "`n`nBackup: "; bold = $true; underline = $true; fontSize = 12},
                @{text = "`n    $bullet Use the [Open] button to jump to the file path and find videoconfig.`n    $bullet Rename it to 'videoconfig_backup' so you can revert if needed.`n`n"; bold = $false; underline = $false; fontSize = 12},
                @{text = "Installation: "; bold = $true; underline = $true; fontSize = 12},
                @{text = "`n   $bullet First make sure that Apex Legends is closed"; bold = $false; underline = $false; fontSize = 12},
                @{text = "`n   $bullet Copy the downloaded 'videoconfig' and paste it into that same folder.`n`n"; bold = $false; underline = $false; fontSize = 12},
                @{text = "Restart: "; bold = $true; underline = $true; fontSize = 12},
                @{text = "`n    $bullet Close and relaunch Apex Legends to apply the new settings.`n`n"; bold = $false; underline = $false; fontSize = 12},
                @{text = "Note: "; bold = $true; underline = $true; fontSize = 12},
                @{text = "`n    $bullet To restore your old settings, delete the new videoconfig file and rename videoconfig_backup back to 'videoconfig'."; bold = $false; underline = $false; fontSize = 12}
            )
            
            # For installation guide, extract just the status message
            if ($message -match "A restart is required|No action required") {
                $statusMsg = $message -replace ".*?(A restart is required|No action required).*", '$1'
                $InfoPopupMessage.Text = $statusMsg
            }
        } elseif ($title -eq "Reset Complete") {
            # For reset complete, extract and show only the status message
            if ($message -match "(A restart is recommended|system restart recommended)") {
                $statusMsg = [regex]::Match($message, "(A restart is recommended|system restart recommended)").Value
                $InfoPopupMessage.Text = $statusMsg
            }
        } else {
            # For tweaks configuration, extract just the status message (last part after tweaks list)
            if ($title -eq "Tweaks Configuration") {
                if ($message -match "(A restart is required|No action required).*") {
                    $statusMsg = [regex]::Match($message, "(A restart is required|No action required)").Value
                    $InfoPopupMessage.Text = $statusMsg
                }
            } else {
                # Generic message display (for errors)
                $InfoPopupMessage.Text = $message
            }
        }
    }
    
    # Show/hide path box based on parameter
    if ($null -ne $PathBoxSection) {
        if ($null -ne $pathToCopy) {
            $PathBoxSection.Visibility = "Visible"
            if ($null -ne $PathBoxText) { $PathBoxText.Text = $pathToCopy }
            
            # Setup open button handler
            if ($null -ne $PathOpenButton) {
                $openHandler = {
                    $fullPath = Join-Path $env:USERPROFILE "Saved Games\Respawn\Apex\Local\"
                    if (Test-Path $fullPath) {
                        Invoke-Item $fullPath
                    } else {
                        [System.Windows.MessageBox]::Show("Path does not exist: $fullPath", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning) | Out-Null
                    }
                }
                $PathOpenButton.Add_Click($openHandler)
            }
        } else {
            $PathBoxSection.Visibility = "Collapsed"
        }
    }
    
    if ($null -ne $InfoPopupOverlay) { $InfoPopupOverlay.Visibility = "Visible" }
    if ($null -ne $InfoPopupContainer) { $InfoPopupContainer.Visibility = "Visible" }
    
    # Setup close button handler
    if ($null -ne $InfoPopupOKButton) {
        $closePopupHandler = {
            $overlay = $UserControl.FindName("InfoPopupOverlay")
            $container = $UserControl.FindName("InfoPopupContainer")
            if ($null -ne $overlay) { $overlay.Visibility = "Collapsed" }
            if ($null -ne $container) { $container.Visibility = "Collapsed" }
        }
        $InfoPopupOKButton.Add_Click($closePopupHandler)
    }
}

# UI Elements
$BtnNavGaming = $UserControl.FindName("BtnNavGaming")
$BtnNavApex = $UserControl.FindName("BtnNavApex")
$BtnNavCache = $UserControl.FindName("BtnNavCache")
$BtnNavDebloating = $UserControl.FindName("BtnNavDebloating")
$BtnNavOBS = $UserControl.FindName("BtnNavOBS")
$BtnNavAbout = $UserControl.FindName("BtnNavAbout")
$SectionGaming = $UserControl.FindName("SectionGaming")
$SectionApex = $UserControl.FindName("SectionApex")
$SectionCache = $UserControl.FindName("SectionCache")
$SectionDebloating = $UserControl.FindName("SectionDebloating")
$SectionOBS = $UserControl.FindName("SectionOBS")
$SectionAbout = $UserControl.FindName("SectionAbout")

function Show-Section($section) {
    $SectionGaming.Visibility = "Collapsed"
    $SectionApex.Visibility = "Collapsed"
    $SectionCache.Visibility = "Collapsed"
    $SectionDebloating.Visibility = "Collapsed"
    $SectionOBS.Visibility = "Collapsed"
    $SectionAbout.Visibility = "Collapsed"
    $section.Visibility = "Visible"
}

$BtnNavGaming.Add_Click({ Show-Section $SectionGaming })
$BtnNavApex.Add_Click({ Show-Section $SectionApex })
$BtnNavCache.Add_Click({ Show-Section $SectionCache })
$BtnNavDebloating.Add_Click({ Show-Section $SectionDebloating })
$BtnNavOBS.Add_Click({ Show-Section $SectionOBS })
$BtnNavAbout.Add_Click({ Show-Section $SectionAbout })

# Additional UI Elements
$ChkIRQ    = $UserControl.FindName("ChkIRQ")
$ChkNet    = $UserControl.FindName("ChkNet")
$ChkGPU    = $UserControl.FindName("ChkGPU")
$ChkCPU    = $UserControl.FindName("ChkCPU")
$ChkUSB    = $UserControl.FindName("ChkUSB")
$ChkHPET   = $UserControl.FindName("ChkHPET")
$ChkGameDVR = $UserControl.FindName("ChkGameDVR")
$ChkFullscreenOpt = $UserControl.FindName("ChkFullscreenOpt")
$ChkUSBSuspend = $UserControl.FindName("ChkUSBSuspend")
$ChkApexConfig = $UserControl.FindName("ChkApexConfig")
$ChkApexShader = $UserControl.FindName("ChkApexShader")
$ChkOBS    = $UserControl.FindName("ChkOBS")
$BtnApply  = $UserControl.FindName("BtnApply")
$BtnSelectAll = $UserControl.FindName("BtnSelectAll")
$BtnResetTweaks = $UserControl.FindName("BtnResetTweaks")
$BtnRefreshStatus = $UserControl.FindName("BtnRefreshStatus")
$StatusText = $UserControl.FindName("StatusText")
$BtnCopyLaunchOptions = $UserControl.FindName("BtnCopyLaunchOptions")
$ApexLaunchOptions = $UserControl.FindName("ApexLaunchOptions")

# Apex Tab Buttons
$TabLaunchOpts = $UserControl.FindName("TabLaunchOpts")
$TabVideoSettings = $UserControl.FindName("TabVideoSettings")
$TabCSMOptimization = $UserControl.FindName("TabCSMOptimization")
$TabNvidiaPanel = $UserControl.FindName("TabNvidiaPanel")

# Apex Content Sections
$ContentLaunchOpts = $UserControl.FindName("ContentLaunchOpts")
$ContentVideoSettings = $UserControl.FindName("ContentVideoSettings")
$ContentCSMOptimization = $UserControl.FindName("ContentCSMOptimization")
$ContentNvidiaPanel = $UserControl.FindName("ContentNvidiaPanel")

# OBS Preset Buttons
$BtnDownloadOBSOnly = $UserControl.FindName("BtnDownloadOBSOnly")
$BtnDownloadOBSSE = $UserControl.FindName("BtnDownloadOBSSE")
$BtnDownloadOBSMulti = $UserControl.FindName("BtnDownloadOBSMulti")
$BtnDownloadOBSPro = $UserControl.FindName("BtnDownloadOBSPro")
$BtnDownloadOBSCustom = $UserControl.FindName("BtnDownloadOBSCustom")

# Clear NVIDIA Cache Button
$BtnClearNVIDIACache = $UserControl.FindName("BtnClearNVIDIACache")

# Clear Apex Shaders Button
$BtnClearApexShaders = $UserControl.FindName("BtnClearApexShaders")

# Clear Temp Files Button
$BtnClearTemp = $UserControl.FindName("BtnClearTemp")

# Clear Prefetch Button
$BtnClearPrefetch = $UserControl.FindName("BtnClearPrefetch")

# Clear Memory Dumps Button
$BtnClearMemDumps = $UserControl.FindName("BtnClearMemDumps")

# Clear Windows Update Cache Button
$BtnClearUpdateCache = $UserControl.FindName("BtnClearUpdateCache")

$BtnApplyApexConfig = $UserControl.FindName("BtnApplyApexConfig")
$BtnViewSupportedCommands = $UserControl.FindName("BtnViewSupportedCommands")
$BtnCopyApexLaunchOpts = $UserControl.FindName("BtnCopyApexLaunchOpts")

# Set Services to Manual Button
$BtnSetServicesManual = $UserControl.FindName("BtnSetServicesManual")

# Apex Tab click handlers - Setup after finding all elements
if ($null -ne $TabLaunchOpts) {
    $TabLaunchOpts.Add_Click({
        $ContentLaunchOpts.Visibility = "Visible"
        $ContentVideoSettings.Visibility = "Collapsed"
        $ContentCSMOptimization.Visibility = "Collapsed"
        $ContentNvidiaPanel.Visibility = "Collapsed"
        $TabLaunchOpts.Tag = "Active"
        $TabVideoSettings.Tag = ""
        $TabCSMOptimization.Tag = ""
        $TabNvidiaPanel.Tag = ""
    })
}
if ($null -ne $TabVideoSettings) {
    $TabVideoSettings.Add_Click({
        $ContentLaunchOpts.Visibility = "Collapsed"
        $ContentVideoSettings.Visibility = "Visible"
        $ContentCSMOptimization.Visibility = "Collapsed"
        $ContentNvidiaPanel.Visibility = "Collapsed"
        $TabLaunchOpts.Tag = ""
        $TabVideoSettings.Tag = "Active"
        $TabCSMOptimization.Tag = ""
        $TabNvidiaPanel.Tag = ""
    })
}
if ($null -ne $TabCSMOptimization) {
    $TabCSMOptimization.Add_Click({
        $ContentLaunchOpts.Visibility = "Collapsed"
        $ContentVideoSettings.Visibility = "Collapsed"
        $ContentCSMOptimization.Visibility = "Visible"
        $ContentNvidiaPanel.Visibility = "Collapsed"
        $TabLaunchOpts.Tag = ""
        $TabVideoSettings.Tag = ""
        $TabCSMOptimization.Tag = "Active"
        $TabNvidiaPanel.Tag = ""
    })
}
if ($null -ne $TabNvidiaPanel) {
    $TabNvidiaPanel.Add_Click({
        $ContentLaunchOpts.Visibility = "Collapsed"
        $ContentVideoSettings.Visibility = "Collapsed"
        $ContentCSMOptimization.Visibility = "Collapsed"
        $ContentNvidiaPanel.Visibility = "Visible"
        $TabLaunchOpts.Tag = ""
        $TabVideoSettings.Tag = ""
        $TabCSMOptimization.Tag = ""
        $TabNvidiaPanel.Tag = "Active"
    })
}

# Select All Button Logic
if ($BtnSelectAll) {
    $BtnSelectAll.Add_Click({
        $ChkIRQ.IsChecked = $true
        $ChkNet.IsChecked = $true
        $ChkGPU.IsChecked = $true
        $ChkGameDVR.IsChecked = $true
        $ChkFullscreenOpt.IsChecked = $true
        $ChkUSBSuspend.IsChecked = $true
    })
}

# Refresh Status Button Logic
if ($BtnRefreshStatus) {
    $BtnRefreshStatus.Add_Click({
        $status = Get-RegistryTweakStatus
        Update-StatusBadge "BadgeIRQ" "BadgeIRQText" $status.IRQ
        Update-StatusBadge "BadgeNET" "BadgeNETText" $status.NET
        Update-StatusBadge "BadgeGPU" "BadgeGPUText" $status.GPU
        Update-StatusBadge "BadgeUSB" "BadgeUSBText" $status.USB
        Update-StatusBadge "BadgeGameDVR" "BadgeGameDVRText" $status.GameDVR
        Update-StatusBadge "BadgeFullscreenOpt" "BadgeFullscreenOptText" $status.FullscreenOpt
    })
}

# Reset Tweaks Button Logic
if ($BtnResetTweaks) {
    $BtnResetTweaks.Add_Click({
        # Show confirmation
        $result = [System.Windows.MessageBox]::Show("This will revert all system tweaks back to default. Continue?", "Reset All Tweaks", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Warning)
        
        if ($result -eq [System.Windows.MessageBoxResult]::Yes) {
            # Reset all tweaks in elevated session
            try {
                $gamingTweaksPath = "$(Split-Path $PSScriptRoot)\Tools\Tweaks\GamingTweaks.ps1"
                $tempScriptPath = "$env:TEMP\ApexTweaksReset_Temp_$(Get-Random).ps1"
                
                # Build reset script
                $scriptContent = @"
& "$gamingTweaksPath" -Type ResetAll 2>&1
"@
                
                Set-Content -Path $tempScriptPath -Value $scriptContent -Encoding UTF8
                
                # Execute with elevation and wait for completion
                Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$tempScriptPath`"" -Wait
                Start-Sleep -Milliseconds 1000
                Remove-Item -Path $tempScriptPath -Force -ErrorAction SilentlyContinue
                
                # Build the reset info list manually (all 7 tweaks)
                $resetInfo = @(
                    "IRQ8 Priority [deleted]",
                    "Network Interrupts [deleted]",
                    "GPU Scheduling [deleted]",
                    "Game DVR [GameDVR_Enabled = 1]",
                    "Fullscreen Optimizations [GameDVR_FSEBehaviorMonitorEnabled = 1]",
                    "USB Suspend [deleted]",
                    "Mouse Acceleration [MouseSpeed=1, Threshold1=6, Threshold2=10]"
                )
                $hasErrors = $false
                
                # Uncheck all boxes - access through UserControl to ensure proper scope
                $chkIRQ = $UserControl.FindName("ChkIRQ")
                $chkNet = $UserControl.FindName("ChkNet")
                $chkGPU = $UserControl.FindName("ChkGPU")
                $chkCPU = $UserControl.FindName("ChkCPU")
                $chkUSB = $UserControl.FindName("ChkUSB")
                $chkHPET = $UserControl.FindName("ChkHPET")
                $chkGameDVR = $UserControl.FindName("ChkGameDVR")
                $chkFullscreenOpt = $UserControl.FindName("ChkFullscreenOpt")
                $chkUSBSuspend = $UserControl.FindName("ChkUSBSuspend")
                
                if ($chkIRQ) { $chkIRQ.IsChecked = $false }
                if ($chkNet) { $chkNet.IsChecked = $false }
                if ($chkGPU) { $chkGPU.IsChecked = $false }
                if ($chkCPU) { $chkCPU.IsChecked = $false }
                if ($chkUSB) { $chkUSB.IsChecked = $false }
                if ($chkHPET) { $chkHPET.IsChecked = $false }
                if ($chkGameDVR) { $chkGameDVR.IsChecked = $false }
                if ($chkFullscreenOpt) { $chkFullscreenOpt.IsChecked = $false }
                if ($chkUSBSuspend) { $chkUSBSuspend.IsChecked = $false }
                
                # Refresh status badges with extended wait for registry propagation
                Start-Sleep -Milliseconds 2000
                $status = Get-RegistryTweakStatus
                Update-StatusBadge "BadgeIRQ" "BadgeIRQText" $status.IRQ
                Update-StatusBadge "BadgeNET" "BadgeNETText" $status.NET
                Update-StatusBadge "BadgeGPU" "BadgeGPUText" $status.GPU
                Update-StatusBadge "BadgeUSB" "BadgeUSBText" $status.USB
                Update-StatusBadge "BadgeGameDVR" "BadgeGameDVRText" $status.GameDVR
                Update-StatusBadge "BadgeFullscreenOpt" "BadgeFullscreenOptText" $status.FullscreenOpt
                
                # Show results popup
                $statusMessage = if ($hasErrors) { "Some tweaks had errors. Check details below." } else { "A restart is recommended for changes to take effect." }
                
                # Build formatted message with all reset items
                if ($resetInfo.Count -gt 0) {
                    # Create nicely formatted message
                    $formattedItems = @()
                    foreach ($item in $resetInfo) {
                        if ($item -like "ERROR:*") {
                            $formattedItems += "  ! $item"
                        } else {
                            $formattedItems += "  - $item"
                        }
                    }
                    
                    $message = "Reset Tweaks:`n`n" + ($formattedItems -join "`n") + "`n`n$statusMessage"
                } else {
                    $message = "Tweaks reset operation completed.`n`n$statusMessage"
                }
                Show-InfoPopup "Reset Complete" $message
                if ($StatusText) { $StatusText.Text = "Tweaks reset to default. System restart recommended." }
            } catch {
                $errorMsg = $_.Exception.Message
                Show-InfoPopup "Error" "Failed to reset tweaks: $errorMsg"
            }
        }
    })
}

# Apply Button Logic
if ($BtnApply) {
    $BtnApply.Add_Click({
        $params = @()
        if ($ChkIRQ -and $ChkIRQ.IsChecked)      { $params += '-IRQ' }
        if ($ChkNet -and $ChkNet.IsChecked)      { $params += '-NET' }
        if ($ChkGPU -and $ChkGPU.IsChecked)      { $params += '-GPU' }
        if ($ChkCPU -and $ChkCPU.IsChecked)      { $params += '-CPU' }
        if ($ChkUSB -and $ChkUSB.IsChecked)      { $params += '-USB' }
        if ($ChkHPET -and $ChkHPET.IsChecked)    { $params += '-HPET' }
        if ($ChkGameDVR -and $ChkGameDVR.IsChecked) { $params += '-GameDVR' }
        if ($ChkFullscreenOpt -and $ChkFullscreenOpt.IsChecked) { $params += '-FullscreenOpt' }
        if ($ChkUSBSuspend -and $ChkUSBSuspend.IsChecked) { $params += '-USBSuspend' }
        if ($ChkApexConfig -and $ChkApexConfig.IsChecked) { $params += '-ApexConfig' }
        if ($ChkApexShader -and $ChkApexShader.IsChecked) { $params += '-ApexShader' }

        if ($params.Count -gt 0) {
            # Check for existing registry entries before applying tweaks
            $registryInfo = @()
            $hasNewTweaks = $false
            
            if ($ChkIRQ -and $ChkIRQ.IsChecked) {
                $irqPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
                if (Test-Path $irqPath) {
                    $irqValue = (Get-ItemProperty -Path $irqPath -Name "IRQ8Priority" -ErrorAction SilentlyContinue).IRQ8Priority
                    if ($null -ne $irqValue) {
                        $registryInfo += "IRQ8 Priority (already exists, value: $irqValue)"
                    } else {
                        $registryInfo += "IRQ8 Priority (will be set to: 1)"
                        $hasNewTweaks = $true
                    }
                } else {
                    $registryInfo += "IRQ8 Priority (will be set to: 1)"
                    $hasNewTweaks = $true
                }
            }
            
            if ($ChkNet -and $ChkNet.IsChecked) {
                $netPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NDIS\Parameters"
                if (Test-Path $netPath) {
                    $netValue = (Get-ItemProperty -Path $netPath -Name "ProcessorThrottleMode" -ErrorAction SilentlyContinue).ProcessorThrottleMode
                    if ($null -ne $netValue) {
                        $registryInfo += "Network Interrupts (already exists, value: $netValue)"
                    } else {
                        $registryInfo += "Network Interrupts (will be set to: 1)"
                        $hasNewTweaks = $true
                    }
                } else {
                    $registryInfo += "Network Interrupts (will be set to: 1)"
                    $hasNewTweaks = $true
                }
            }
            
            if ($ChkGPU -and $ChkGPU.IsChecked) {
                $gpuPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
                if (Test-Path $gpuPath) {
                    $gpuValue = (Get-ItemProperty -Path $gpuPath -Name "HwSchMode" -ErrorAction SilentlyContinue).HwSchMode
                    if ($null -ne $gpuValue) {
                        $registryInfo += "Hardware GPU Scheduling (already exists, value: $gpuValue)"
                    } else {
                        $registryInfo += "Hardware GPU Scheduling (will be set to: 2)"
                        $hasNewTweaks = $true
                    }
                } else {
                    $registryInfo += "Hardware GPU Scheduling (will be set to: 2)"
                    $hasNewTweaks = $true
                }
            }

            if ($ChkGameDVR -and $ChkGameDVR.IsChecked) {
                $gameDVRPath = "HKCU:\System\GameConfigStore"
                if (Test-Path $gameDVRPath) {
                    $gameDVRValue = (Get-ItemProperty -Path $gameDVRPath -Name "GameDVR_Enabled" -ErrorAction SilentlyContinue).GameDVR_Enabled
                    if ($null -ne $gameDVRValue) {
                        $registryInfo += "Disable Game DVR (already exists, value: $gameDVRValue)"
                    } else {
                        $registryInfo += "Disable Game DVR (will be set to: 0)"
                        $hasNewTweaks = $true
                    }
                } else {
                    $registryInfo += "Disable Game DVR (will be set to: 0)"
                    $hasNewTweaks = $true
                }
            }

            if ($ChkFullscreenOpt -and $ChkFullscreenOpt.IsChecked) {
                $fullscreenPath = "HKCU:\System\GameConfigStore"
                $fullscreenValue = (Get-ItemProperty -Path $fullscreenPath -Name "GameDVR_FSEBehaviorMonitorEnabled" -ErrorAction SilentlyContinue).GameDVR_FSEBehaviorMonitorEnabled
                if ($null -ne $fullscreenValue) {
                    $registryInfo += "Fullscreen Optimizations (already exists, value: $fullscreenValue)"
                } else {
                    $registryInfo += "Fullscreen Optimizations (will be set to: 0)"
                    $hasNewTweaks = $true
                }
            }

            if ($ChkUSBSuspend -and $ChkUSBSuspend.IsChecked) {
                # Try to read from registry - will fail in non-elevated context, so we show what will be set
                $usbPath = "HKLM:\SYSTEM\CurrentControlSet\Services\USB"
                $usbValue = (Get-ItemProperty -Path $usbPath -Name "DisableSelectiveSuspend" -ErrorAction SilentlyContinue).DisableSelectiveSuspend
                if ($null -ne $usbValue) {
                    $registryInfo += "Disable USB Suspend (already exists, value: $usbValue)"
                } else {
                    $registryInfo += "Disable USB Suspend (already exists, value: 1)"
                    # Don't set hasNewTweaks to true since this runs in elevated context
                }
            }

            # Show what will be applied with appropriate message
            if ($registryInfo.Count -gt 0) {
                $statusMessage = if ($hasNewTweaks) { "A restart is required for changes to take effect." } else { "No action required since all tweaks already exist." }
                $message = "Applying tweaks:`n`n" + ($registryInfo -join "`n") + "`n`n$statusMessage"
                Show-InfoPopup "Tweaks Configuration" $message
            }
            
            # Apply tweaks with a single elevated session using temp file
            try {
                $gamingTweaksPath = "$(Split-Path $PSScriptRoot)\Tools\Tweaks\GamingTweaks.ps1"
                $tempScriptPath = "$env:TEMP\ApexTweaks_Temp_$(Get-Random).ps1"
                
                # Build script content
                $scriptContent = ""
                if ($ChkIRQ -and $ChkIRQ.IsChecked)      { $scriptContent += "& `"$gamingTweaksPath`" -Type IRQ`r`n" }
                if ($ChkNet -and $ChkNet.IsChecked)      { $scriptContent += "& `"$gamingTweaksPath`" -Type NET`r`n" }
                if ($ChkGPU -and $ChkGPU.IsChecked)      { $scriptContent += "& `"$gamingTweaksPath`" -Type GPU`r`n" }
                if ($ChkCPU -and $ChkCPU.IsChecked)      { $scriptContent += "& `"$gamingTweaksPath`" -Type CPU`r`n" }
                if ($ChkUSB -and $ChkUSB.IsChecked)      { $scriptContent += "& `"$gamingTweaksPath`" -Type USB`r`n" }
                if ($ChkHPET -and $ChkHPET.IsChecked)    { $scriptContent += "& `"$gamingTweaksPath`" -Type HPET`r`n" }
                if ($ChkGameDVR -and $ChkGameDVR.IsChecked) { $scriptContent += "& `"$gamingTweaksPath`" -Type GameDVR`r`n" }
                if ($ChkFullscreenOpt -and $ChkFullscreenOpt.IsChecked) { $scriptContent += "& `"$gamingTweaksPath`" -Type FullscreenOpt`r`n" }
                if ($ChkUSBSuspend -and $ChkUSBSuspend.IsChecked) { $scriptContent += "& `"$gamingTweaksPath`" -Type USBSuspend`r`n" }
                
                # Write temp script
                if ($scriptContent.Length -gt 0) {
                    Set-Content -Path $tempScriptPath -Value $scriptContent -Encoding UTF8
                    
                    # Run with elevation
                    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempScriptPath`"" -Wait
                    
                    # Clean up
                    Remove-Item -Path $tempScriptPath -Force -ErrorAction SilentlyContinue
                    
                    # Refresh status badges with extended wait for registry propagation
                    Start-Sleep -Milliseconds 2000
                    $status = Get-RegistryTweakStatus
                    Update-StatusBadge "BadgeIRQ" "BadgeIRQText" $status.IRQ
                    Update-StatusBadge "BadgeNET" "BadgeNETText" $status.NET
                    Update-StatusBadge "BadgeGPU" "BadgeGPUText" $status.GPU
                    Update-StatusBadge "BadgeUSB" "BadgeUSBText" $status.USB
                    Update-StatusBadge "BadgeGameDVR" "BadgeGameDVRText" $status.GameDVR
                    Update-StatusBadge "BadgeFullscreenOpt" "BadgeFullscreenOptText" $status.FullscreenOpt
                }
            } catch {
                $errorMsg = $_.Exception.Message
                Show-InfoPopup "Error" "Failed to apply tweaks: $errorMsg"
            }
        }

        if ($ChkOBS -and $ChkOBS.IsChecked -eq $true) {
            Start-Process powershell `
                -Verb RunAs `
                -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$(Split-Path $PSScriptRoot)\Tools\OBS\SetupOBS.ps1`""
        }

        if ($StatusText) { $StatusText.Text = "Tweaks applied. System restart required for changes to take effect." }
    })
}

# Clear NVIDIA Cache Button Logic
if ($BtnClearNVIDIACache) {
    $BtnClearNVIDIACache.Add_Click({
        $script = "$(Split-Path $PSScriptRoot)\Tools\Tweaks\NvidiaCache.ps1"
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $script -Type ClearCache 2>&1 | Where-Object { $_ -match "NVIDIA_CACHE" }
        
        if ($output -match "NVIDIA_CACHE\|(\d+)\|(\d+)") {
            $deleted = [int]$matches[1]
            $remaining = [int]$matches[2]
            $desc = "Cache cleared successfully."
            Show-CacheResultPopup "NVIDIA Cache Cleared" $desc $deleted $remaining
        } else {
            [System.Windows.MessageBox]::Show("NVIDIA cache has been cleared!", "Cache Cleared", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
        }
        
        if ($StatusText) { $StatusText.Text = "NVIDIA cache cleared successfully." }
    })
}

# Clear Apex Shaders Button Logic
if ($BtnClearApexShaders) {
    $BtnClearApexShaders.Add_Click({
        $script = "$(Split-Path $PSScriptRoot)\Tools\Tweaks\ApexShaders.ps1"
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $script -Type ClearShaders 2>&1 | Where-Object { $_ -match "APEX_SHADERS" }
        
        if ($output -match "APEX_SHADERS\|(\d+)\|(\d+)") {
            $deleted = [int]$matches[1]
            $remaining = [int]$matches[2]
            $desc = "Shaders cleared successfully."
            Show-CacheResultPopup "Apex Shaders Cleared" $desc $deleted $remaining
        } else {
            [System.Windows.MessageBox]::Show("Apex shaders have been cleared!", "Shaders Cleared", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
        }
        
        if ($StatusText) { $StatusText.Text = "Apex shaders cleared successfully." }
    })
}

# Clear Temp Files Button Logic
if ($BtnClearTemp) {
    $BtnClearTemp.Add_Click({
        $script = "$(Split-Path $PSScriptRoot)\Tools\Tweaks\ClearTemp.ps1"
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $script -Type ClearTemp 2>&1 | Where-Object { $_ -match "TEMP_CACHE" }
        
        if ($output -match "TEMP_CACHE\|(\d+)\|(\d+)") {
            $deleted = [int]$matches[1]
            $remaining = [int]$matches[2]
            $desc = "Temporary files cleared successfully."
            Show-CacheResultPopup "Temp Files Cleared" $desc $deleted $remaining
        } else {
            [System.Windows.MessageBox]::Show("Temporary files have been cleared!", "Temp Files Cleared", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
        }
        
        if ($StatusText) { $StatusText.Text = "Temporary files cleared successfully." }
    })
}

# Clear Windows Prefetch Button Logic
if ($BtnClearPrefetch) {
    $BtnClearPrefetch.Add_Click({
        $script = "$(Split-Path $PSScriptRoot)\Tools\Tweaks\ClearPrefetch.ps1"
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $script -Type ClearPrefetch 2>&1 | Where-Object { $_ -match "PREFETCH_CACHE" }
        
        if ($output -match "PREFETCH_CACHE\|(\d+)\|(\d+)") {
            $deleted = [int]$matches[1]
            $remaining = [int]$matches[2]
            $desc = "Prefetch cache cleared successfully."
            Show-CacheResultPopup "Prefetch Cache Cleared" $desc $deleted $remaining
        } else {
            [System.Windows.MessageBox]::Show("Prefetch cache has been cleared!", "Cache Cleared", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
        }
        
        if ($StatusText) { $StatusText.Text = "Prefetch cache cleared successfully." }
    })
}

# Clear Memory Dumps Button Logic
if ($BtnClearMemDumps) {
    $BtnClearMemDumps.Add_Click({
        $script = "$(Split-Path $PSScriptRoot)\Tools\Tweaks\ClearMemDumps.ps1"
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $script -Type ClearMemDumps 2>&1 | Where-Object { $_ -match "MEMORY_DUMPS" }
        
        if ($output -match "MEMORY_DUMPS\|(\d+)\|(\d+)") {
            $deleted = [int]$matches[1]
            $remaining = [int]$matches[2]
            $desc = "Memory dumps cleared successfully."
            Show-CacheResultPopup "Memory Dumps Cleared" $desc $deleted $remaining
        } else {
            [System.Windows.MessageBox]::Show("Memory dumps have been cleared!", "Dumps Cleared", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
        }
        
        if ($StatusText) { $StatusText.Text = "Memory dumps cleared successfully." }
    })
}

# Clear Windows Update Cache Button Logic
if ($BtnClearUpdateCache) {
    $BtnClearUpdateCache.Add_Click({
        $script = "$(Split-Path $PSScriptRoot)\Tools\Tweaks\ClearUpdateCache.ps1"
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $script -Type ClearUpdateCache 2>&1 | Where-Object { $_ -match "UPDATE_CACHE" }
        
        if ($output -match "UPDATE_CACHE\|(\d+)\|(\d+)") {
            $deleted = [int]$matches[1]
            $remaining = [int]$matches[2]
            $desc = "Windows update cache cleared successfully."
            Show-CacheResultPopup "Update Cache Cleared" $desc $deleted $remaining
        } else {
            [System.Windows.MessageBox]::Show("Windows update cache has been cleared!", "Cache Cleared", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
        }
        
        if ($StatusText) { $StatusText.Text = "Windows update cache cleared successfully." }
    })
}

# Apply Apex Config Button Logic
if ($BtnApplyApexConfig) {
    $BtnApplyApexConfig.Add_Click({
        $templateFile = "$(Split-Path $PSScriptRoot)\Config\videoconfig.txt"
        
        if (Test-Path $templateFile) {
            # Show Save File Dialog
            Add-Type -AssemblyName System.Windows.Forms
            $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
            $saveDialog.FileName = "videoconfig.txt"
            $saveDialog.DefaultExt = "txt"
            $saveDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
            $saveDialog.Title = "Save videoconfig.txt"
            $saveDialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
            
            if ($saveDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $destFile = $saveDialog.FileName
                Copy-Item -Path $templateFile -Destination $destFile -Force
                Set-ItemProperty -Path $destFile -Name IsReadOnly -Value $true
               $message = "Installation Guide`n`n" +
"Backup: 
    - Click 'Open' to find your 'videoconfig.txt'. 
    - Rename it to 'videoconfig_backup.txt' so you can revert if needed.`n`n" +
"Installation: 
    - Copy the downloaded 'videoconfig.txt' and paste it into that same folder.`n`n" +
"Restart: 
    - Close and relaunch Apex Legends to apply the new settings.`n`n" +
"Note: If issues occur, delete the new file and restore your backup."
                $path = "Saved Games\Respawn\Apex\Local\"
                Show-InfoPopup "Config Ready" $message $path
                if ($StatusText) { $StatusText.Text = "videoconfig.txt saved. Manual installation required." }
            }
        } else {
            Show-InfoPopup "Error" "Template file not found at: $templateFile"
        }
    })
}

# View Supported Commands Button Logic
if ($BtnViewSupportedCommands) {
    $BtnViewSupportedCommands.Add_Click({
        $InfoPopupOverlay = $UserControl.FindName("InfoPopupOverlay")
        $InfoPopupContainer = $UserControl.FindName("InfoPopupContainer")
        $InfoPopupTitle = $UserControl.FindName("InfoPopupTitle")
        $InfoPopupMessage = $UserControl.FindName("InfoPopupMessage")
        $InfoPopupOKButton = $UserControl.FindName("InfoPopupOKButton")
        $PathBoxSection = $UserControl.FindName("PathBoxSection")
        
        if ($null -ne $InfoPopupTitle) { $InfoPopupTitle.Text = "Apex Legends Supported Commands" }
        if ($null -ne $PathBoxSection) { $PathBoxSection.Visibility = "Collapsed" }
        
        if ($null -ne $InfoPopupMessage) {
            $commands = @(
                @{cmd = "+lobby_max_fps"; desc = "Uncaps frame rate in lobby/menus."},
                @{cmd = "-dev"; desc = "Enables developer mode."},
                @{cmd = "+fps_max"; desc = "Sets maximum FPS limit in-game."},
                @{cmd = "-render_on_input_thread"; desc = "Optimizes rendering for input responsiveness."},
                @{cmd = "-freq"; desc = "Sets monitor refresh rate (e.g., -freq 144, -freq 240)."},
                @{cmd = "+cl_showfps"; desc = "Displays FPS counter on screen."},
                @{cmd = "+cl_fovScale 1.7"; desc = "Expands field of view scale to 120."},
                @{cmd = "+mat_queue_mode"; desc = "Optimizes GPU material queue."}
            )
            
            # Clear the RichTextBox
            $InfoPopupMessage.Document.Blocks.Clear()
            
            # Add commands
            $counter = 1
            foreach ($item in $commands) {
                $para = New-Object System.Windows.Documents.Paragraph
                $para.Margin = New-Object System.Windows.Thickness(0, 0, 0, 12)
                
                # Command name (blue + bold)
                $cmdRun = New-Object System.Windows.Documents.Run
                $cmdRun.Text = "$($item.cmd)"
                $brush = New-Object System.Windows.Media.SolidColorBrush
                $brush.Color = [System.Windows.Media.Color]::FromRgb(0, 163, 255)
                $cmdRun.Foreground = $brush
                $cmdRun.FontWeight = [System.Windows.FontWeights]::Bold
                $para.Inlines.Add($cmdRun)
                
                # New line
                $para.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
                
                # Description (gray + italic)
                $descRun = New-Object System.Windows.Documents.Run
                $descRun.Text = "$($item.desc)"
                $descRun.Foreground = [System.Windows.Media.Brushes]::LightGray
                $descRun.FontStyle = [System.Windows.FontStyles]::Italic
                $para.Inlines.Add($descRun)
                
                $InfoPopupMessage.Document.Blocks.Add($para)
                $counter++
            }
        }
        
        if ($null -ne $InfoPopupOverlay) { $InfoPopupOverlay.Visibility = "Visible" }
        if ($null -ne $InfoPopupContainer) { $InfoPopupContainer.Visibility = "Visible" }
        
        # Setup close button handler
        if ($null -ne $InfoPopupOKButton) {
            $closePopupHandler = {
                $overlay = $UserControl.FindName("InfoPopupOverlay")
                $container = $UserControl.FindName("InfoPopupContainer")
                if ($null -ne $overlay) { $overlay.Visibility = "Collapsed" }
                if ($null -ne $container) { $container.Visibility = "Collapsed" }
            }
            $InfoPopupOKButton.Add_Click($closePopupHandler)
        }
    })
}

# Copy Apex Launch Options Button Logic
if ($BtnCopyApexLaunchOpts) {
    $BtnCopyApexLaunchOpts.Add_Click({
        Add-Type -AssemblyName PresentationCore
        [Windows.Clipboard]::SetText($ApexLaunchOptions.Text)
        
        [System.Windows.MessageBox]::Show("Launch options copied to clipboard!", "Copied", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
        
        if ($StatusText) { $StatusText.Text = "Launch options copied to clipboard." }
    })
}

# Set Services to Manual Button Logic
if ($BtnSetServicesManual) {
    $BtnSetServicesManual.Add_Click({
        $script = "$(Split-Path $PSScriptRoot)\Tools\Tweaks\GamingTweaks.ps1"
        & powershell -NoProfile -ExecutionPolicy Bypass -File $script -Type SetServicesManual
        
        [System.Windows.MessageBox]::Show("Services have been set to manual! A system restart is recommended for changes to take effect.", "Services Updated", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
        
        if ($StatusText) { $StatusText.Text = "Services set to manual. Restart recommended." }
    })
}

# Copy Button Logic
if ($BtnCopyLaunchOptions -and $ApexLaunchOptions) {
    $BtnCopyLaunchOptions.Add_Click({
        Add-Type -AssemblyName PresentationCore
        [Windows.Clipboard]::SetText($ApexLaunchOptions.Text)
        if ($StatusText) { $StatusText.Text = "Launch options copied to clipboard." }
    })
}

# Apex Tab Switching Logic
$TabLaunchOpts = $UserControl.FindName("TabLaunchOpts")
$TabVideoSettings = $UserControl.FindName("TabVideoSettings")
$TabCSMOptimization = $UserControl.FindName("TabCSMOptimization")
$TabNvidiaPanel = $UserControl.FindName("TabNvidiaPanel")
$ContentLaunchOpts = $UserControl.FindName("ContentLaunchOpts")
$ContentVideoSettings = $UserControl.FindName("ContentVideoSettings")
$ContentCSMOptimization = $UserControl.FindName("ContentCSMOptimization")
$ContentNvidiaPanel = $UserControl.FindName("ContentNvidiaPanel")

$apexTabs = @($TabLaunchOpts, $TabVideoSettings, $TabCSMOptimization, $TabNvidiaPanel)
$apexContents = @($ContentLaunchOpts, $ContentVideoSettings, $ContentCSMOptimization, $ContentNvidiaPanel)

function Show-ApexTab($tabIndex) {
    for ($i = 0; $i -lt $apexTabs.Count; $i++) {
        if ($i -eq $tabIndex) {
            $blueBrush = New-Object System.Windows.Media.SolidColorBrush
            $blueBrush.Color = [System.Windows.Media.Color]::FromRgb(0, 163, 255)
            $apexTabs[$i].Background = $blueBrush
            $apexTabs[$i].Foreground = [System.Windows.Media.Brushes]::White
            $apexTabs[$i].BorderBrush = [System.Windows.Media.Brushes]::Transparent
            $apexContents[$i].Visibility = "Visible"
        } else {
            $darkBrush = New-Object System.Windows.Media.SolidColorBrush
            $darkBrush.Color = [System.Windows.Media.Color]::FromRgb(37, 42, 55)
            $apexTabs[$i].Background = $darkBrush
            $grayBrush = New-Object System.Windows.Media.SolidColorBrush
            $grayBrush.Color = [System.Windows.Media.Color]::FromRgb(153, 153, 153)
            $apexTabs[$i].Foreground = $grayBrush
            $apexTabs[$i].BorderBrush = $darkBrush
            $apexContents[$i].Visibility = "Collapsed"
        }
    }
}

if ($TabLaunchOpts) { $TabLaunchOpts.Add_Click({ Show-ApexTab 0 }) }
if ($TabVideoSettings) { $TabVideoSettings.Add_Click({ Show-ApexTab 1 }) }
if ($TabCSMOptimization) { $TabCSMOptimization.Add_Click({ Show-ApexTab 2 }) }
if ($TabNvidiaPanel) { $TabNvidiaPanel.Add_Click({ Show-ApexTab 3 }) }

# Function to get registry tweak status - uses direct registry access
function Get-RegistryTweakStatus {
    $tweakStatus = @{
        IRQ = "Default"
        NET = "Default"
        GPU = "Default"
        USB = "Default"
        GameDVR = "Default"
        FullscreenOpt = "Default"
    }
    
    # Clear registry cache by touching each hive
    try {
        $null = Get-Item "HKLM:\" -ErrorAction SilentlyContinue
        $null = Get-Item "HKCU:\" -ErrorAction SilentlyContinue
    } catch { }
    
    # Check IRQ8Priority
    try {
        $irqPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
        if (Test-Path $irqPath) {
            $irqValue = (Get-ItemProperty -Path $irqPath -Name "IRQ8Priority" -ErrorAction SilentlyContinue)."IRQ8Priority"
            if ($irqValue -eq 1) {
                $tweakStatus.IRQ = "Applied"
            }
        }
    } catch { }
    
    # Check Network Throttle Mode
    try {
        $netPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NDIS\Parameters"
        if (Test-Path $netPath) {
            $netValue = (Get-ItemProperty -Path $netPath -Name "ProcessorThrottleMode" -ErrorAction SilentlyContinue)."ProcessorThrottleMode"
            if ($netValue -eq 1) {
                $tweakStatus.NET = "Applied"
            }
        }
    } catch { }
    
    # Check GPU Hardware Scheduling
    try {
        $gpuPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
        if (Test-Path $gpuPath) {
            $gpuValue = (Get-ItemProperty -Path $gpuPath -Name "HwSchMode" -ErrorAction SilentlyContinue)."HwSchMode"
            if ($gpuValue -eq 2) {
                $tweakStatus.GPU = "Applied"
            }
        }
    } catch { }
    
    # Check USB Suspend - might need to create the key first
    try {
        $usbPath = "HKLM:\SYSTEM\CurrentControlSet\Services\USB"
        if (-not (Test-Path $usbPath)) {
            # Try to create it if it doesn't exist
            $null = New-Item -Path $usbPath -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path $usbPath) {
            $usbValue = (Get-ItemProperty -Path $usbPath -Name "DisableSelectiveSuspend" -ErrorAction SilentlyContinue)."DisableSelectiveSuspend"
            if ($usbValue -eq 1) {
                $tweakStatus.USB = "Applied"
            }
        }
    } catch { }
    
    # Check Game DVR
    try {
        $gameDvrPath = "HKCU:\System\GameConfigStore"
        if (Test-Path $gameDvrPath) {
            $gameDvrValue = (Get-ItemProperty -Path $gameDvrPath -Name "GameDVR_Enabled" -ErrorAction SilentlyContinue)."GameDVR_Enabled"
            if ($gameDvrValue -eq 0) {
                $tweakStatus.GameDVR = "Applied"
            }
        }
    } catch { }
    
    # Check Fullscreen Optimizations
    try {
        $fsePath = "HKCU:\System\GameConfigStore"
        if (Test-Path $fsePath) {
            $fseValue = (Get-ItemProperty -Path $fsePath -Name "GameDVR_FSEBehaviorMonitorEnabled" -ErrorAction SilentlyContinue)."GameDVR_FSEBehaviorMonitorEnabled"
            if ($fseValue -eq 0) {
                $tweakStatus.FullscreenOpt = "Applied"
            }
        }
    } catch { }
    
    return $tweakStatus
}

# Function to update badge in UI - simple circle indicator
function Update-StatusBadge($badgeName, $badgeTextName, $status) {
    try {
        $badge = $UserControl.FindName($badgeName)
        
        if ($badge) {
            if ($status -eq "Applied") {
                # Applied - Green circle
                $appliedBrush = $UserControl.Resources["BadgeAppliedColor"]
                $badge.Background = $appliedBrush
            } else {
                # Default - Gray circle
                $defaultBrush = $UserControl.Resources["BadgeDefaultColor"]
                $badge.Background = $defaultBrush
            }
        }
    } catch {
        Write-Host "Error updating badge: $_"
    }
}

# Update all status badges on window load
$Window.Add_ContentRendered({
    $status = Get-RegistryTweakStatus
    
    Update-StatusBadge "BadgeIRQ" "BadgeIRQText" $status.IRQ
    Update-StatusBadge "BadgeNET" "BadgeNETText" $status.NET
    Update-StatusBadge "BadgeGPU" "BadgeGPUText" $status.GPU
    Update-StatusBadge "BadgeUSB" "BadgeUSBText" $status.USB
    Update-StatusBadge "BadgeGameDVR" "BadgeGameDVRText" $status.GameDVR
    Update-StatusBadge "BadgeFullscreenOpt" "BadgeFullscreenOptText" $status.FullscreenOpt
})

# OBS Preset Download Buttons
if ($BtnDownloadOBSOnly) {
    $BtnDownloadOBSOnly.Add_Click({ Invoke-PresetDownload "OBS_Only" })
}
if ($BtnDownloadOBSSE) {
    $BtnDownloadOBSSE.Add_Click({ Invoke-PresetDownload "OBS_Streamelements" })
}
if ($BtnDownloadOBSMulti) {
    $BtnDownloadOBSMulti.Add_Click({ Invoke-PresetDownload "OBS_Streamelements_Multistream" })
}
if ($BtnDownloadOBSPro) {
    $BtnDownloadOBSPro.Add_Click({ Invoke-PresetDownload "OBS_Fully_Setup" })
}
if ($BtnDownloadOBSCustom) {
    $BtnDownloadOBSCustom.Add_Click({ Invoke-PresetDownload "Custom" })
}

# Show UI
$Window.ShowDialog() | Out-Null