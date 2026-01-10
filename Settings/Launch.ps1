
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

# ==========================================
# PROFESSIONAL POPUP SYSTEM
# Clean, extensible, and maintainable
# ==========================================

# Display info popup with two sections: grid items and status message
function Show-InfoPopup {
    param(
        [string]$title,
        [array]$gridItems = @(),      # Array of hashtables with 'name' and 'value' keys
        [string]$statusMessage = "",  # Status message for second box
        [string]$pathToCopy = $null   # Path to display in path box (for Config Ready)
    )
    
    $InfoPopupOverlay = $UserControl.FindName("InfoPopupOverlay")
    $InfoPopupContainer = $UserControl.FindName("InfoPopupContainer")
    $InfoPopupTitle = $UserControl.FindName("InfoPopupTitle")
    $InfoPopupMessage = $UserControl.FindName("InfoPopupMessage")
    $InfoPopupDataGrid = $UserControl.FindName("InfoPopupDataGrid")
    $InfoPopupDataGridBorder = $UserControl.FindName("InfoPopupDataGridBorder")
    $InfoPopupOKButton = $UserControl.FindName("InfoPopupOKButton")
    $PathBoxSection = $UserControl.FindName("PathBoxSection")
    $PathBoxText = $UserControl.FindName("PathBoxText")
    
    # Set title
    if ($null -ne $InfoPopupTitle) { $InfoPopupTitle.Text = $title }
    
    # Clear existing content
    if ($null -ne $InfoPopupDataGrid) { $InfoPopupDataGrid.Children.Clear() }
    if ($null -ne $InfoPopupMessage) {
        if ($InfoPopupMessage.GetType().Name -eq "RichTextBox") {
            $InfoPopupMessage.Document.Blocks.Clear()
        } else {
            $InfoPopupMessage.Text = ""
        }
    }
    
    # Handle "Config Ready" special case - display full installation guide
    if ($title -eq "Config Ready") {
        if ($null -ne $InfoPopupDataGridBorder) { $InfoPopupDataGridBorder.Visibility = "Collapsed" }
        
        if ($null -ne $InfoPopupMessage) {
            $isRichTextBox = $InfoPopupMessage.GetType().Name -eq "RichTextBox"
            if ($isRichTextBox) {
                $bullet = [char]0x2022
                
                # Title
                $para = New-Object System.Windows.Documents.Paragraph
                $run = New-Object System.Windows.Documents.Run
                $run.Text = "Installation Guide"
                $run.FontWeight = [System.Windows.FontWeights]::Bold
                $run.FontSize = 14
                $run.Foreground = [System.Windows.Media.Brushes]::Cyan
                $para.Inlines.Add($run)
                $para.Margin = New-Object System.Windows.Thickness(0, 0, 0, 12)
                $InfoPopupMessage.Document.Blocks.Add($para)
                
                # Backup section
                $para = New-Object System.Windows.Documents.Paragraph
                $run = New-Object System.Windows.Documents.Run
                $run.Text = "Backup:"
                $run.FontWeight = [System.Windows.FontWeights]::Bold
                $run.Foreground = [System.Windows.Media.Brushes]::LightGray
                $para.Inlines.Add($run)
                $para.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
                $run = New-Object System.Windows.Documents.Run
                $run.Text = "$bullet Use the [Open] button to jump to the file path and find videoconfig.`n$bullet Rename it to 'videoconfig_backup' so you can revert if needed."
                $run.Foreground = [System.Windows.Media.Brushes]::LightGray
                $para.Inlines.Add($run)
                $para.Margin = New-Object System.Windows.Thickness(0, 0, 0, 12)
                $InfoPopupMessage.Document.Blocks.Add($para)
                
                # Installation section
                $para = New-Object System.Windows.Documents.Paragraph
                $run = New-Object System.Windows.Documents.Run
                $run.Text = "Installation:"
                $run.FontWeight = [System.Windows.FontWeights]::Bold
                $run.Foreground = [System.Windows.Media.Brushes]::LightGray
                $para.Inlines.Add($run)
                $para.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
                $run = New-Object System.Windows.Documents.Run
                $run.Text = "$bullet First make sure that Apex Legends is closed`n$bullet Copy the downloaded 'videoconfig' and paste it into that same folder."
                $run.Foreground = [System.Windows.Media.Brushes]::LightGray
                $para.Inlines.Add($run)
                $para.Margin = New-Object System.Windows.Thickness(0, 0, 0, 12)
                $InfoPopupMessage.Document.Blocks.Add($para)
                
                # Restart section
                $para = New-Object System.Windows.Documents.Paragraph
                $run = New-Object System.Windows.Documents.Run
                $run.Text = "Restart:"
                $run.FontWeight = [System.Windows.FontWeights]::Bold
                $run.Foreground = [System.Windows.Media.Brushes]::LightGray
                $para.Inlines.Add($run)
                $para.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
                $run = New-Object System.Windows.Documents.Run
                $run.Text = "$bullet Close and relaunch Apex Legends to apply the new settings."
                $run.Foreground = [System.Windows.Media.Brushes]::LightGray
                $para.Inlines.Add($run)
                $para.Margin = New-Object System.Windows.Thickness(0, 0, 0, 12)
                $InfoPopupMessage.Document.Blocks.Add($para)
                
                # Note section
                $para = New-Object System.Windows.Documents.Paragraph
                $run = New-Object System.Windows.Documents.Run
                $run.Text = "Note:"
                $run.FontWeight = [System.Windows.FontWeights]::Bold
                $run.Foreground = [System.Windows.Media.Brushes]::LightGray
                $para.Inlines.Add($run)
                $para.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
                $run = New-Object System.Windows.Documents.Run
                $run.Text = "$bullet To restore your old settings, delete the new videoconfig file and rename videoconfig_backup back to 'videoconfig'."
                $run.Foreground = [System.Windows.Media.Brushes]::LightGray
                $para.Inlines.Add($run)
                $InfoPopupMessage.Document.Blocks.Add($para)
            }
        }
        
        # Show path box
        if ($null -ne $PathBoxSection) {
            if ($null -ne $pathToCopy) {
                $PathBoxSection.Visibility = "Visible"
                if ($null -ne $PathBoxText) { $PathBoxText.Text = $pathToCopy }
            } else {
                $PathBoxSection.Visibility = "Collapsed"
            }
        }
    } else {
        # Normal grid + message display
        
        # Display grid items in first box
        if ($null -ne $InfoPopupDataGridBorder -and $gridItems.Count -gt 0) {
            $InfoPopupDataGridBorder.Visibility = "Visible"
            
            foreach ($item in $gridItems) {
                $itemGrid = New-Object System.Windows.Controls.Grid
                $col1 = New-Object System.Windows.Controls.ColumnDefinition
                $col1.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
                $col2 = New-Object System.Windows.Controls.ColumnDefinition
                $col2.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Auto)
                $itemGrid.ColumnDefinitions.Add($col1)
                $itemGrid.ColumnDefinitions.Add($col2)
                
                # Name (Orange)
                $nameBlock = New-Object System.Windows.Controls.TextBlock
                $nameBlock.Text = $item.name
                $orangeBrush = New-Object System.Windows.Media.BrushConverter
                $nameBlock.Foreground = $orangeBrush.ConvertFromString("#FF9800")
                $nameBlock.FontSize = 12
                $nameBlock.FontWeight = [System.Windows.FontWeights]::Bold
                [System.Windows.Controls.Grid]::SetColumn($nameBlock, 0)
                $itemGrid.Children.Add($nameBlock) | Out-Null
                
                # Value (Light Gray)
                $valueBlock = New-Object System.Windows.Controls.TextBlock
                $valueBlock.Text = $item.value
                $lightBrush = New-Object System.Windows.Media.BrushConverter
                $valueBlock.Foreground = $lightBrush.ConvertFromString("#ECEFF1")
                $valueBlock.FontSize = 12
                $valueBlock.TextAlignment = "Right"
                [System.Windows.Controls.Grid]::SetColumn($valueBlock, 1)
                $valueBlock.Margin = New-Object System.Windows.Thickness(12, 0, 0, 0)
                $itemGrid.Children.Add($valueBlock) | Out-Null
                
                $itemGrid.Margin = New-Object System.Windows.Thickness(0, 0, 0, 14)
                $InfoPopupDataGrid.Children.Add($itemGrid) | Out-Null
            }
        } else {
            if ($null -ne $InfoPopupDataGridBorder) { $InfoPopupDataGridBorder.Visibility = "Collapsed" }
        }
        
        # Display status message in second box
        if ($null -ne $InfoPopupMessage -and $statusMessage -ne "") {
            $isRichTextBox = $InfoPopupMessage.GetType().Name -eq "RichTextBox"
            
            if ($isRichTextBox) {
                $para = New-Object System.Windows.Documents.Paragraph
                $run = New-Object System.Windows.Documents.Run
                $run.Text = $statusMessage
                $run.Foreground = [System.Windows.Media.Brushes]::LightGray
                $para.Inlines.Add($run)
                $InfoPopupMessage.Document.Blocks.Add($para)
            } else {
                $InfoPopupMessage.Text = $statusMessage
            }
        }
        
        # Hide path box for normal popups
        if ($null -ne $PathBoxSection) {
            $PathBoxSection.Visibility = "Collapsed"
        }
    }
    
    # Show popup
    if ($null -ne $InfoPopupOverlay) { $InfoPopupOverlay.Visibility = "Visible" }
    if ($null -ne $InfoPopupContainer) { $InfoPopupContainer.Visibility = "Visible" }
    
    # Setup close button - use script block with UserControl in scope
    if ($null -ne $InfoPopupOKButton) {
        $closeHandler = {
            param($snd, $e)
            $overlay = $UserControl.FindName("InfoPopupOverlay")
            $container = $UserControl.FindName("InfoPopupContainer")
            if ($null -ne $overlay) { $overlay.Visibility = "Collapsed" }
            if ($null -ne $container) { $container.Visibility = "Collapsed" }
        }
        
        $InfoPopupOKButton.Add_Click($closeHandler)
    }
    
    # Setup path open button (only set once during initialization)
    if ($null -eq $script:PathOpenButtonInitialized) {
        $PathOpenButton = $UserControl.FindName("PathOpenButton")
        if ($null -ne $PathOpenButton) {
            $openHandler = {
                param($snd, $e)
                $pathBoxText = $UserControl.FindName("PathBoxText")
                if ($null -ne $pathBoxText) {
                    $fullPath = "$env:USERPROFILE\$($pathBoxText.Text)"
                    if (Test-Path $fullPath) {
                        explorer.exe $fullPath
                    } else {
                        [System.Windows.MessageBox]::Show("Path not found: $fullPath", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
                    }
                }
            }
            
            $PathOpenButton.Add_Click($openHandler)
            $script:PathOpenButtonInitialized = $true
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

# Show Styled Information Popup
function Show-StyledInfoPopup {
    param(
        [string]$Title = "Information",
        [string]$Message = "",
        [string]$IconType = "Info"
    )
    
    $popup = New-Object System.Windows.Window
    $popup.Title = $Title
    $popup.Width = 450
    $popup.Height = 200
    $popup.Background = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(15, 17, 26))
    $popup.Foreground = [System.Windows.Media.Brushes]::White
    $popup.WindowStartupLocation = 'CenterScreen'
    $popup.ResizeMode = 'NoResize'
    $popup.Topmost = $true
    
    $mainPanel = New-Object System.Windows.Controls.Grid
    $mainPanel.Background = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(15, 17, 26))
    
    # Create row definitions
    $row1 = New-Object System.Windows.Controls.RowDefinition
    $row1.Height = [System.Windows.GridLength]::Auto
    $mainPanel.RowDefinitions.Add($row1)
    
    $row2 = New-Object System.Windows.Controls.RowDefinition
    $row2.Height = [System.Windows.GridLength]::Auto
    $mainPanel.RowDefinitions.Add($row2)
    
    # Content Panel with Icon and Message
    $contentPanel = New-Object System.Windows.Controls.StackPanel
    $contentPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $contentPanel.Margin = New-Object System.Windows.Thickness(20, 20, 20, 20)
    [System.Windows.Controls.Grid]::SetRow($contentPanel, 0)
    
    # Icon (Info circle)
    if ($IconType -eq "Info") {
        $iconBlock = New-Object System.Windows.Controls.TextBlock
        $iconBlock.Text = "i"
        $iconBlock.FontSize = 50
        $iconBlock.FontWeight = [System.Windows.FontWeights]::Bold
        $iconBlock.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0, 163, 255))
        $iconBlock.Margin = New-Object System.Windows.Thickness(0, 0, 15, 0)
        $iconBlock.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
        [void]$contentPanel.Children.Add($iconBlock)
    }
    
    # Message
    $messageBlock = New-Object System.Windows.Controls.TextBlock
    $messageBlock.Text = $Message
    $messageBlock.FontSize = 13
    $messageBlock.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $messageBlock.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(200, 200, 200))
    $messageBlock.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
    [void]$contentPanel.Children.Add($messageBlock)
    
    [void]$mainPanel.Children.Add($contentPanel)
    
    # Button Panel
    $buttonPanel = New-Object System.Windows.Controls.StackPanel
    $buttonPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $buttonPanel.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
    $buttonPanel.Margin = New-Object System.Windows.Thickness(20, 0, 20, 20)
    [System.Windows.Controls.Grid]::SetRow($buttonPanel, 1)
    
    $okButton = New-Object System.Windows.Controls.Button
    $okButton.Content = "OK"
    $okButton.Width = 80
    $okButton.Height = 35
    $okButton.Margin = New-Object System.Windows.Thickness(5)
    $okButton.Background = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0, 163, 255))
    $okButton.Foreground = [System.Windows.Media.Brushes]::White
    $okButton.FontSize = 12
    $okButton.Cursor = [System.Windows.Input.Cursors]::Hand
    $okButton.Add_Click({ $popup.Close() })
    
    [void]$buttonPanel.Children.Add($okButton)
    [void]$mainPanel.Children.Add($buttonPanel)
    
    $popup.Content = $mainPanel
    $popup.ShowDialog() | Out-Null
}

# Show Download Progress Window
function Show-DownloadProgressWindow {
    param(
        [string]$Title = "Downloading",
        [string]$ScriptPath,
        [bool]$LaunchInstaller = $false
    )
    
    # Create progress window
    $progressWindow = New-Object System.Windows.Window
    $progressWindow.Title = $Title
    $progressWindow.Width = 500
    $progressWindow.Height = 300
    $progressWindow.Background = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(15, 17, 26))
    $progressWindow.Foreground = [System.Windows.Media.Brushes]::White
    $progressWindow.WindowStartupLocation = 'CenterScreen'
    $progressWindow.ResizeMode = 'NoResize'
    $progressWindow.Topmost = $true
    
    # Create main stack panel
    $mainPanel = New-Object System.Windows.Controls.StackPanel
    $mainPanel.Margin = New-Object System.Windows.Thickness(20)
    $mainPanel.Background = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(15, 17, 26))
    
    # Title
    $titleBlock = New-Object System.Windows.Controls.TextBlock
    $titleBlock.Text = $Title
    $titleBlock.FontSize = 16
    $titleBlock.FontWeight = [System.Windows.FontWeights]::Bold
    $titleBlock.Margin = New-Object System.Windows.Thickness(0, 0, 0, 20)
    $titleBlock.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0, 163, 255))
    $mainPanel.Children.Add($titleBlock)
    
    # Progress bar
    $progressBar = New-Object System.Windows.Controls.ProgressBar
    $progressBar.Height = 20
    $progressBar.Margin = New-Object System.Windows.Thickness(0, 0, 0, 15)
    $progressBar.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0, 163, 255))
    $progressBar.Background = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(30, 34, 45))
    $progressBar.Minimum = 0
    $progressBar.Maximum = 100
    $progressBar.Value = 0
    $mainPanel.Children.Add($progressBar)
    
    # Statistics panel
    $statsPanel = New-Object System.Windows.Controls.StackPanel
    $statsPanel.Margin = New-Object System.Windows.Thickness(0, 0, 0, 15)
    
    # Percentage text
    $percentageBlock = New-Object System.Windows.Controls.TextBlock
    $percentageBlock.FontSize = 13
    $percentageBlock.Margin = New-Object System.Windows.Thickness(0, 0, 0, 8)
    $percentageBlock.Foreground = [System.Windows.Media.Brushes]::White
    $percentageBlock.Text = "Starting download..."
    $statsPanel.Children.Add($percentageBlock)
    
    # File size text
    $sizeBlock = New-Object System.Windows.Controls.TextBlock
    $sizeBlock.FontSize = 12
    $sizeBlock.Margin = New-Object System.Windows.Thickness(0, 0, 0, 8)
    $sizeBlock.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(148, 163, 184))
    $sizeBlock.Text = "Initializing..."
    $statsPanel.Children.Add($sizeBlock)
    
    # Speed text
    $speedBlock = New-Object System.Windows.Controls.TextBlock
    $speedBlock.FontSize = 12
    $speedBlock.Margin = New-Object System.Windows.Thickness(0, 0, 0, 8)
    $speedBlock.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(148, 163, 184))
    $speedBlock.Text = "Speed: 0 MB/s"
    $statsPanel.Children.Add($speedBlock)
    
    # ETA text
    $etaBlock = New-Object System.Windows.Controls.TextBlock
    $etaBlock.FontSize = 12
    $etaBlock.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(148, 163, 184))
    $etaBlock.Text = "Time Remaining: Calculating..."
    $statsPanel.Children.Add($etaBlock)
    
    $mainPanel.Children.Add($statsPanel)
    
    # Status message
    $statusBlock = New-Object System.Windows.Controls.TextBlock
    $statusBlock.FontSize = 11
    $statusBlock.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $statusBlock.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(76, 175, 80))
    $statusBlock.Margin = New-Object System.Windows.Thickness(0, 15, 0, 0)
    $statusBlock.Text = "Initializing..."
    $mainPanel.Children.Add($statusBlock)
    
    $progressWindow.Content = $mainPanel
    
    # Use fixed temp file for output
    $outputFile = "$env:TEMP\nvidia_download.txt"
    
    # Run download script 
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = "powershell.exe"
    $processInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
    $processInfo.RedirectStandardOutput = $true
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $true
    
    $process = [System.Diagnostics.Process]::Start($processInfo)
    
    if ($null -eq $process) {
        [System.Windows.MessageBox]::Show("Failed to start download process.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
        return
    }
    
    # Timer to read output file
    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromMilliseconds(80)
    $lastLineCount = 0
    
    $tickAction = {
        # Read output file if it exists
        $lines = @()
        if (Test-Path $outputFile) {
            try {
                $lines = @(Get-Content -Path $outputFile -Encoding UTF8 -ErrorAction SilentlyContinue)
            }
            catch {
                # File might be locked, skip this read
            }
        }
        
        if ($null -eq $lines) { $lines = @() }
        if ($lines -isnot [array]) { $lines = @($lines) }
        
        # Process new lines only
        if ($lines.Count -gt $lastLineCount) {
            for ($i = $lastLineCount; $i -lt $lines.Count; $i++) {
                $line = $lines[$i]
                $lineStr = $line.ToString().Trim()
                
                if ([string]::IsNullOrWhiteSpace($lineStr)) { continue }
                
                # Parse different output types
                if ($lineStr -match "^NVIDIA_APP_PROGRESS\|([0-9.]+)\|([0-9.]+)\|([0-9.]+)\|([0-9.]+)\|([0-9]+)") {
                    $percentage = [double]::Parse($matches[1])
                    $downloaded = [double]::Parse($matches[2])
                    $total = [double]::Parse($matches[3])
                    $speed = [double]::Parse($matches[4])
                    $eta = [int]::Parse($matches[5])
                    
                    # Update UI - check if window is still valid
                    try {
                        $progressWindow.Dispatcher.Invoke([action]{
                            if ($progressWindow.IsVisible) {
                                $progressBar.Value = $percentage
                                $percentageBlock.Text = "$percentage% Complete"
                                $sizeBlock.Text = "Downloaded: $downloaded MB / $total MB"
                                $speedBlock.Text = "Speed: $speed MB/s"
                                
                                if ($eta -gt 0) {
                                    $etaMinutes = [Math]::Floor($eta / 60)
                                    $etaSeconds = $eta % 60
                                    $etaBlock.Text = "Time Remaining: ${etaMinutes}m ${etaSeconds}s"
                                }
                                $statusBlock.Text = "Downloading..."
                            }
                        }, [System.Windows.Threading.DispatcherPriority]::Normal)
                    }
                    catch {
                        # Window was closed, stop processing
                        return
                    }
                }
                elseif ($lineStr -match "^NVIDIA_APP_DOWNLOAD_COMPLETE\|(.+)$") {
                    $downloadPath = $matches[1]
                    try {
                        $progressWindow.Dispatcher.Invoke([action]{
                            if ($progressWindow.IsVisible) {
                                $progressBar.Value = 100
                                $percentageBlock.Text = "100% Complete"
                                $statusBlock.Text = "Download completed successfully!"
                                $statusBlock.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(76, 175, 80))
                                
                                # Launch installer if requested, file exists, AND window wasn't closed
                                if ($LaunchInstaller -and (Test-Path $downloadPath)) {
                                    Start-Sleep -Seconds 2
                                    Start-Process $downloadPath
                                    $statusBlock.Text = "Launching installer..."
                                }
                            }
                        }, [System.Windows.Threading.DispatcherPriority]::Normal)
                    }
                    catch {}
                    
                    # Schedule window close after 2 seconds (non-blocking)
                    Start-Sleep -Seconds 2
                    $progressWindow.Dispatcher.Invoke([action]{ $progressWindow.Close() })
                }
                elseif ($lineStr -match "^NVIDIA_APP_DOWNLOAD_ERROR\|(.+)$") {
                    $errorMsg = $matches[1]
                    try {
                        $progressWindow.Dispatcher.Invoke([action]{
                            if ($progressWindow.IsVisible) {
                                $statusBlock.Text = "Error: $errorMsg"
                                $statusBlock.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(244, 67, 54))
                            }
                        }, [System.Windows.Threading.DispatcherPriority]::Normal)
                    }
                    catch {}
                }
            }
            $lastLineCount = $lines.Count
        }
        
        # Check if process has exited and file still exists
        if ($null -ne $process -and $process.HasExited) {
            # Try one last read
            if (Test-Path $outputFile) {
                try {
                    $finalLines = @(Get-Content -Path $outputFile -Encoding UTF8 -ErrorAction SilentlyContinue)
                    if ($null -ne $finalLines -and $finalLines.Count -gt $lastLineCount) {
                        for ($i = $lastLineCount; $i -lt $finalLines.Count; $i++) {
                            $line = $finalLines[$i].ToString().Trim()
                            if (-not [string]::IsNullOrWhiteSpace($line)) {
                                # Process final lines if needed
                            }
                        }
                    }
                }
                catch {}
            }
        }
        
        # Don't auto-close, let user close manually when ready
    }
    
    $timer.Add_Tick($tickAction)
    
    $timer.Start()
    $progressWindow.ShowDialog() | Out-Null
    
    # Cleanup
    if ($null -ne $timer) { $timer.Stop() }
    if ($null -ne $process) { 
        if (-not $process.HasExited) { $process.Kill() }
        $process.Dispose() 
    }
    if (Test-Path $outputFile) { Remove-Item -Path $outputFile -Force -ErrorAction SilentlyContinue }
}



# UI Elements
$BtnNavGaming = $UserControl.FindName("BtnNavGaming")
$BtnNavApex = $UserControl.FindName("BtnNavApex")
$BtnNavGamesLibrary = $UserControl.FindName("BtnNavGamesLibrary")
$BtnNavOBS = $UserControl.FindName("BtnNavOBS")
$SectionGaming = $UserControl.FindName("SectionGaming")
$SectionApex = $UserControl.FindName("SectionApex")
$SectionGamesLibrary = $UserControl.FindName("SectionGamesLibrary")
$SectionValorant = $UserControl.FindName("SectionValorant")
$SectionCS2 = $UserControl.FindName("SectionCS2")
$SectionFortnite = $UserControl.FindName("SectionFortnite")
$SectionCOD = $UserControl.FindName("SectionCOD")
$SectionLoL = $UserControl.FindName("SectionLoL")
$SectionOW2 = $UserControl.FindName("SectionOW2")
$SectionR6 = $UserControl.FindName("SectionR6")
$SectionRL = $UserControl.FindName("SectionRL")
$SectionOBS = $UserControl.FindName("SectionOBS")

# System Tweaks tabs
$TabPerfTweaks = $UserControl.FindName("TabPerfTweaks")
$TabPerfCleanup = $UserControl.FindName("TabPerfCleanup")
$TabNvidiaControl = $UserControl.FindName("TabNvidiaControl")
$ContentPerfTweaks = $UserControl.FindName("ContentPerfTweaks")
$ContentPerfCleanup = $UserControl.FindName("ContentPerfCleanup")
$ContentNvidiaControl = $UserControl.FindName("ContentNvidiaControl")

function Show-Section($section) {
    $SectionGaming.Visibility = "Collapsed"
    $SectionApex.Visibility = "Collapsed"
    $SectionGamesLibrary.Visibility = "Collapsed"
    $SectionValorant.Visibility = "Collapsed"
    $SectionCS2.Visibility = "Collapsed"
    $SectionFortnite.Visibility = "Collapsed"
    $SectionCOD.Visibility = "Collapsed"
    $SectionLoL.Visibility = "Collapsed"
    $SectionOW2.Visibility = "Collapsed"
    $SectionR6.Visibility = "Collapsed"
    $SectionRL.Visibility = "Collapsed"
    $SectionOBS.Visibility = "Collapsed"
    $section.Visibility = "Visible"
}

function Show-SystemTweaksTab($tabIndex) {
    # Hide all content
    $ContentPerfTweaks.Visibility = "Collapsed"
    $ContentPerfCleanup.Visibility = "Collapsed"
    $ContentNvidiaControl.Visibility = "Collapsed"
    
    # Reset all tab styles
    $darkBrush = New-Object System.Windows.Media.SolidColorBrush
    $darkBrush.Color = [System.Windows.Media.Color]::FromRgb(37, 42, 55)
    $grayForeground = New-Object System.Windows.Media.SolidColorBrush
    $grayForeground.Color = [System.Windows.Media.Color]::FromRgb(153, 153, 153)
    
    $TabPerfTweaks.Background = $darkBrush
    $TabPerfTweaks.Foreground = $grayForeground
    $TabPerfTweaks.Tag = ""
    
    $TabPerfCleanup.Background = $darkBrush
    $TabPerfCleanup.Foreground = $grayForeground
    $TabPerfCleanup.Tag = ""
    
    $TabNvidiaControl.Background = $darkBrush
    $TabNvidiaControl.Foreground = $grayForeground
    $TabNvidiaControl.Tag = ""
    
    # Activate selected tab
    $blueBrush = New-Object System.Windows.Media.SolidColorBrush
    $blueBrush.Color = [System.Windows.Media.Color]::FromRgb(0, 163, 255)
    
    switch($tabIndex) {
        0 {
            $ContentPerfTweaks.Visibility = "Visible"
            $TabPerfTweaks.Background = $blueBrush
            $TabPerfTweaks.Foreground = [System.Windows.Media.Brushes]::White
            $TabPerfTweaks.Tag = "Active"
        }
        1 {
            $ContentPerfCleanup.Visibility = "Visible"
            $TabPerfCleanup.Background = $blueBrush
            $TabPerfCleanup.Foreground = [System.Windows.Media.Brushes]::White
            $TabPerfCleanup.Tag = "Active"
        }
        2 {
            $ContentNvidiaControl.Visibility = "Visible"
            $TabNvidiaControl.Background = $blueBrush
            $TabNvidiaControl.Foreground = [System.Windows.Media.Brushes]::White
            $TabNvidiaControl.Tag = "Active"
        }
    }
}

$BtnNavGaming.Add_Click({ Show-Section $SectionGaming })
$BtnNavApex.Add_Click({ Show-Section $SectionApex })
$BtnNavGamesLibrary.Add_Click({ Show-Section $SectionGamesLibrary })
$BtnNavOBS.Add_Click({ Show-Section $SectionOBS })

# System Tweaks tab handlers
if ($TabPerfTweaks) { $TabPerfTweaks.Add_Click({ Show-SystemTweaksTab 0 }) }
if ($TabPerfCleanup) { $TabPerfCleanup.Add_Click({ Show-SystemTweaksTab 1 }) }
if ($TabNvidiaControl) { $TabNvidiaControl.Add_Click({ Show-SystemTweaksTab 2 }) }

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

# Apex Content Sections
$ContentLaunchOpts = $UserControl.FindName("ContentLaunchOpts")
$ContentVideoSettings = $UserControl.FindName("ContentVideoSettings")
$ContentCSMOptimization = $UserControl.FindName("ContentCSMOptimization")

# OBS Preset Buttons
$BtnDownloadOBSOnly = $UserControl.FindName("BtnDownloadOBSOnly")
$BtnDownloadOBSSE = $UserControl.FindName("BtnDownloadOBSSE")
$BtnDownloadOBSMulti = $UserControl.FindName("BtnDownloadOBSMulti")
$BtnDownloadOBSPro = $UserControl.FindName("BtnDownloadOBSPro")
$BtnDownloadOBSCustom = $UserControl.FindName("BtnDownloadOBSCustom")

# Clear NVIDIA Cache Button
$BtnClearNVIDIACache = $UserControl.FindName("BtnClearNVIDIACache")

# NVIDIA Control Panel Buttons
$BtnInstallNvidiaApp = $UserControl.FindName("BtnInstallNvidiaApp")
$BtnDownloadNvidiaDriver = $UserControl.FindName("BtnDownloadNvidiaDriver")

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

# CS2 Tab Buttons
$TabCS2LaunchOpts = $UserControl.FindName("TabCS2LaunchOpts")
$TabCS2VideoSettings = $UserControl.FindName("TabCS2VideoSettings")
$TabCS2ConfigCommands = $UserControl.FindName("TabCS2ConfigCommands")

# CS2 Content Sections
$ContentCS2LaunchOpts = $UserControl.FindName("ContentCS2LaunchOpts")
$ContentCS2VideoSettings = $UserControl.FindName("ContentCS2VideoSettings")
$ContentCS2ConfigCommands = $UserControl.FindName("ContentCS2ConfigCommands")

# Set Services to Manual Button
$BtnSetServicesManual = $UserControl.FindName("BtnSetServicesManual")

# Apex Tab click handlers - Setup after finding all elements
if ($null -ne $TabLaunchOpts) {
    $TabLaunchOpts.Add_Click({
        $ContentLaunchOpts.Visibility = "Visible"
        $ContentVideoSettings.Visibility = "Collapsed"
        $ContentCSMOptimization.Visibility = "Collapsed"
        $TabLaunchOpts.Tag = "Active"
        $TabVideoSettings.Tag = ""
        $TabCSMOptimization.Tag = ""
    })
}
if ($null -ne $TabVideoSettings) {
    $TabVideoSettings.Add_Click({
        $ContentLaunchOpts.Visibility = "Collapsed"
        $ContentVideoSettings.Visibility = "Visible"
        $ContentCSMOptimization.Visibility = "Collapsed"
        $TabLaunchOpts.Tag = ""
        $TabVideoSettings.Tag = "Active"
        $TabCSMOptimization.Tag = ""
    })
}
if ($null -ne $TabCSMOptimization) {
    $TabCSMOptimization.Add_Click({
        $ContentLaunchOpts.Visibility = "Collapsed"
        $ContentVideoSettings.Visibility = "Collapsed"
        $ContentCSMOptimization.Visibility = "Visible"
        $TabLaunchOpts.Tag = ""
        $TabVideoSettings.Tag = ""
        $TabCSMOptimization.Tag = "Active"
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
            # Check current registry status BEFORE resetting
            $resetInfo = @()
            $alreadyDefaultCount = 0
            $needsResetCount = 0
            
            # Check IRQ8Priority
            $irqPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
            if ((Test-Path $irqPath) -and ($null -ne (Get-ItemProperty -Path $irqPath -Name "IRQ8Priority" -ErrorAction SilentlyContinue).IRQ8Priority)) {
                $resetInfo += "IRQ8Priority: Registry deleted"
                $needsResetCount++
            } else {
                $resetInfo += "IRQ8Priority: Registry not found"
                $alreadyDefaultCount++
            }
            
            # Check ProcessorThrottleMode
            $netPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NDIS\Parameters"
            if ((Test-Path $netPath) -and ($null -ne (Get-ItemProperty -Path $netPath -Name "ProcessorThrottleMode" -ErrorAction SilentlyContinue).ProcessorThrottleMode)) {
                $resetInfo += "ProcessorThrottleMode: Registry deleted"
                $needsResetCount++
            } else {
                $resetInfo += "ProcessorThrottleMode: Registry not found"
                $alreadyDefaultCount++
            }
            
            # Check HwSchMode
            $gpuPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
            if ((Test-Path $gpuPath) -and ($null -ne (Get-ItemProperty -Path $gpuPath -Name "HwSchMode" -ErrorAction SilentlyContinue).HwSchMode)) {
                $resetInfo += "HwSchMode: Registry deleted"
                $needsResetCount++
            } else {
                $resetInfo += "HwSchMode: Registry not found"
                $alreadyDefaultCount++
            }
            
            # Check GameDVR_Enabled (set to default value 1)
            $gameDVRPath = "HKCU:\System\GameConfigStore"
            $gameDVRValue = (Get-ItemProperty -Path $gameDVRPath -Name "GameDVR_Enabled" -ErrorAction SilentlyContinue).GameDVR_Enabled
            if ($gameDVRValue -eq 0) {
                $resetInfo += "GameDVR_Enabled: Value set to default"
                $needsResetCount++
            } else {
                $resetInfo += "GameDVR_Enabled: Set at default"
                $alreadyDefaultCount++
            }
            
            # Check GameDVR_FSEBehaviorMonitorEnabled (set to default value 1)
            $fullscreenValue = (Get-ItemProperty -Path $gameDVRPath -Name "GameDVR_FSEBehaviorMonitorEnabled" -ErrorAction SilentlyContinue).GameDVR_FSEBehaviorMonitorEnabled
            if ($fullscreenValue -eq 0) {
                $resetInfo += "GameDVR_FSEBehaviorMonitorEnabled: Value set to default"
                $needsResetCount++
            } else {
                $resetInfo += "GameDVR_FSEBehaviorMonitorEnabled: Set at default"
                $alreadyDefaultCount++
            }
            
            # Check DisableSelectiveSuspend
            $usbPath = "HKLM:\SYSTEM\CurrentControlSet\Services\USB"
            if ((Test-Path $usbPath) -and ($null -ne (Get-ItemProperty -Path $usbPath -Name "DisableSelectiveSuspend" -ErrorAction SilentlyContinue).DisableSelectiveSuspend)) {
                $resetInfo += "DisableSelectiveSuspend: Registry deleted"
                $needsResetCount++
            } else {
                $resetInfo += "DisableSelectiveSuspend: Registry not found"
                $alreadyDefaultCount++
            }
            
            # Determine if all tweaks are already at default
            $allAlreadyDefault = ($alreadyDefaultCount -eq 6)
            
            # Convert resetInfo to gridItems
            $gridItems = @()
            foreach ($item in $resetInfo) {
                $parts = $item -split ": "
                $gridItems += @{ name = "$($parts[0]):"; value = $parts[1] }
            }
            
            # Show appropriate popup
            if ($allAlreadyDefault) {
                # All tweaks already at default - show "No action required"
                Show-InfoPopup "Reset Already Default" -gridItems $gridItems -statusMessage "No action is required"
            } else {
                # Some tweaks need resetting - show "Restart is required"
                Show-InfoPopup "Reset Complete" -gridItems $gridItems -statusMessage "Restart is required to apply changes."
                
                # Now execute the actual reset
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
                } catch {
                    $errorMsg = $_.Exception.Message
                    Show-InfoPopup "Error" -statusMessage "Failed to reset tweaks: $errorMsg"
                }
            }
            
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
            
            if ($StatusText) { $StatusText.Text = "Tweaks reset to default. System restart recommended." }
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
            $newTweakInfo = @()
            $alreadyAppliedCount = 0
            
            if ($ChkIRQ -and $ChkIRQ.IsChecked) {
                $irqPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
                if (Test-Path $irqPath) {
                    $irqValue = (Get-ItemProperty -Path $irqPath -Name "IRQ8Priority" -ErrorAction SilentlyContinue).IRQ8Priority
                    if ($null -ne $irqValue) {
                        $alreadyAppliedCount++
                    } else {
                        $newTweakInfo += "IRQ8Priority: 1"
                    }
                } else {
                    $newTweakInfo += "IRQ8Priority: 1"
                }
            }
            
            if ($ChkNet -and $ChkNet.IsChecked) {
                $netPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NDIS\Parameters"
                if (Test-Path $netPath) {
                    $netValue = (Get-ItemProperty -Path $netPath -Name "ProcessorThrottleMode" -ErrorAction SilentlyContinue).ProcessorThrottleMode
                    if ($null -ne $netValue) {
                        $alreadyAppliedCount++
                    } else {
                        $newTweakInfo += "ProcessorThrottleMode: 1"
                    }
                } else {
                    $newTweakInfo += "ProcessorThrottleMode: 1"
                }
            }
            
            if ($ChkGPU -and $ChkGPU.IsChecked) {
                $gpuPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
                if (Test-Path $gpuPath) {
                    $gpuValue = (Get-ItemProperty -Path $gpuPath -Name "HwSchMode" -ErrorAction SilentlyContinue).HwSchMode
                    if ($null -ne $gpuValue) {
                        $alreadyAppliedCount++
                    } else {
                        $newTweakInfo += "HwSchMode: 2"
                    }
                } else {
                    $newTweakInfo += "HwSchMode: 2"
                }
            }

            if ($ChkGameDVR -and $ChkGameDVR.IsChecked) {
                $gameDVRPath = "HKCU:\System\GameConfigStore"
                $gameDVRValue = (Get-ItemProperty -Path $gameDVRPath -Name "GameDVR_Enabled" -ErrorAction SilentlyContinue).GameDVR_Enabled
                if ($gameDVRValue -eq 0) {
                    # Already disabled (already applied)
                    $alreadyAppliedCount++
                } else {
                    # Either doesn't exist or is set to 1 (enabled) - needs to be disabled
                    $newTweakInfo += "GameDVR_Enabled: 0"
                }
            }

            if ($ChkFullscreenOpt -and $ChkFullscreenOpt.IsChecked) {
                $fullscreenPath = "HKCU:\System\GameConfigStore"
                $fullscreenValue = (Get-ItemProperty -Path $fullscreenPath -Name "GameDVR_FSEBehaviorMonitorEnabled" -ErrorAction SilentlyContinue).GameDVR_FSEBehaviorMonitorEnabled
                if ($fullscreenValue -eq 0) {
                    # Already disabled (already applied)
                    $alreadyAppliedCount++
                } else {
                    # Either doesn't exist or is set to 1 (enabled) - needs to be disabled
                    $newTweakInfo += "GameDVR_FSEBehaviorMonitorEnabled: 0"
                }
            }

            if ($ChkUSBSuspend -and $ChkUSBSuspend.IsChecked) {
                # Try to read from registry
                $usbPath = "HKLM:\SYSTEM\CurrentControlSet\Services\USB"
                $usbValue = (Get-ItemProperty -Path $usbPath -Name "DisableSelectiveSuspend" -ErrorAction SilentlyContinue).DisableSelectiveSuspend
                if ($null -ne $usbValue) {
                    $alreadyAppliedCount++
                } else {
                    $newTweakInfo += "DisableSelectiveSuspend: 1"
                }
            }

            # Determine if all tweaks are already applied
            $totalSelectedTweaks = ($params.Count)
            $allAlreadyApplied = ($alreadyAppliedCount -eq $totalSelectedTweaks)
            
            # Show appropriate popup message
            if ($allAlreadyApplied) {
                # All tweaks already applied - show "Already Applied" message
                $gridItems = @()
                foreach ($tweak in $newTweakInfo) {
                    $name, $value = $tweak -split ": "
                    $gridItems += @{ name = "${name}:"; value = "Registry not found" }
                }
                Show-InfoPopup "Already Applied" -gridItems $gridItems -statusMessage "No action is required"
            } else {
                # Show new tweaks being applied
                $gridItems = @()
                foreach ($tweak in $newTweakInfo) {
                    $name, $value = $tweak -split ": "
                    if ($name -match "GameDVR|FSEBehavior") {
                        $gridItems += @{ name = "${name}:"; value = "Registry Modified" }
                    } else {
                        $gridItems += @{ name = "${name}:"; value = "Registry Created" }
                    }
                }
                Show-InfoPopup "Tweaks Configuration" -gridItems $gridItems -statusMessage "Restart is required to apply changes."
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

# Install Latest NVIDIA App Button Logic
if ($BtnInstallNvidiaApp) {
    $BtnInstallNvidiaApp.Add_Click({
        try {
            # Check if already installed
            $nvidiaAppPath = "C:\Program Files\NVIDIA Corporation\NVIDIA GFXExperience\NVIDIA GeForce Experience.exe"
            
            if (Test-Path $nvidiaAppPath) {
                # App already exists, just launch it
                Start-Process $nvidiaAppPath
                [System.Windows.MessageBox]::Show("NVIDIA App is starting.", "NVIDIA App", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
                if ($StatusText) { $StatusText.Text = "NVIDIA App launched." }
            } else {
                # Download the app
                $scriptPath = Join-Path (Split-Path $PSScriptRoot) "Tools\Tweaks\DownloadNvidiaApp.ps1"
                
                if (-not (Test-Path $scriptPath)) {
                    [System.Windows.MessageBox]::Show("Download script not found.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
                    return
                }
                
                Show-DownloadProgressWindow -Title "Downloading NVIDIA App" -ScriptPath $scriptPath -LaunchInstaller $true
                
                if ($StatusText) { $StatusText.Text = "NVIDIA App downloaded." }
            }
        } catch {
            [System.Windows.MessageBox]::Show("Error: $_", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
            if ($StatusText) { $StatusText.Text = "Error with NVIDIA App." }
        }
    })
}

# Download Latest NVIDIA Driver Button Logic
if ($BtnDownloadNvidiaDriver) {
    $BtnDownloadNvidiaDriver.Add_Click({
        try {
            Show-StyledInfoPopup "NVIDIA Driver" "Opening NVIDIA Driver download page.`n`nNVIDIA will auto-detect your GPU." "Info"
            Start-Process "https://www.nvidia.com/Download/index.aspx"
            if ($StatusText) { $StatusText.Text = "Opening NVIDIA Driver page." }
        } catch {
            [System.Windows.MessageBox]::Show("Error: $_", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
            if ($StatusText) { $StatusText.Text = "Error opening NVIDIA Driver page." }
        }
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
                $path = "Saved Games\Respawn\Apex\Local\"
                Show-InfoPopup "Config Ready" @() "" $path
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
        $InfoPopupDataGridBorder = $UserControl.FindName("InfoPopupDataGridBorder")
        $PathBoxSection = $UserControl.FindName("PathBoxSection")
        
        if ($null -ne $InfoPopupTitle) { $InfoPopupTitle.Text = "Apex Legends Supported Commands" }
        if ($null -ne $PathBoxSection) { $PathBoxSection.Visibility = "Collapsed" }
        if ($null -ne $InfoPopupDataGridBorder) { $InfoPopupDataGridBorder.Visibility = "Collapsed" }
        
        if ($null -ne $InfoPopupMessage) {
            $commands = @(
                @{cmd = "+lobby_max_fps"; desc = "Uncaps frame rate in lobby/menus."},
                @{cmd = "-dev"; desc = "Enables developer mode."},
                @{cmd = "+fps_max"; desc = "Sets maximum FPS limit in-game."},
                @{cmd = "-render_on_input_thread"; desc = "Optimizes rendering for input responsiveness."},
                @{cmd = "-freq"; desc = "Sets monitor refresh rate (e.g., -freq 144, -freq 240)."},
                @{cmd = "+cl_showfps"; desc = "Displays FPS counter on screen."},
                @{cmd = "+cl_fovScale 1.7"; desc = "Expands field of view scale to 120."},
                @{cmd = "+mat_queue_mode"; desc = "Optimizes GPU material queue."},
                @{cmd = "+mat_wide_pillarbox 0"; desc = "Disable pillarboxing on ultrawide monitors."},
                @{cmd = "+mat_minimize_on_alt_tab 1"; desc = "Make the game minimize when you alt-tab (like DX11 behavior)."}
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

# ==========================================
# CS2 EVENT HANDLERS
# ==========================================

# CS2 Tab Switching Logic
if ($null -ne $TabCS2LaunchOpts) {
    $TabCS2LaunchOpts.Add_Click({
        $ContentCS2LaunchOpts.Visibility = "Visible"
        $ContentCS2VideoSettings.Visibility = "Collapsed"
        $ContentCS2ConfigCommands.Visibility = "Collapsed"
        $TabCS2LaunchOpts.Tag = "Active"
        $TabCS2VideoSettings.Tag = ""
        $TabCS2ConfigCommands.Tag = ""
    })
}
if ($null -ne $TabCS2VideoSettings) {
    $TabCS2VideoSettings.Add_Click({
        $ContentCS2LaunchOpts.Visibility = "Collapsed"
        $ContentCS2VideoSettings.Visibility = "Visible"
        $ContentCS2ConfigCommands.Visibility = "Collapsed"
        $TabCS2LaunchOpts.Tag = ""
        $TabCS2VideoSettings.Tag = "Active"
        $TabCS2ConfigCommands.Tag = ""
    })
}
if ($null -ne $TabCS2ConfigCommands) {
    $TabCS2ConfigCommands.Add_Click({
        $ContentCS2LaunchOpts.Visibility = "Collapsed"
        $ContentCS2VideoSettings.Visibility = "Collapsed"
        $ContentCS2ConfigCommands.Visibility = "Visible"
        $TabCS2LaunchOpts.Tag = ""
        $TabCS2VideoSettings.Tag = ""
        $TabCS2ConfigCommands.Tag = "Active"
    })
}

# CS2 Copy Launch Options Button
$BtnCopyCS2LaunchOpts = $UserControl.FindName("BtnCopyCS2LaunchOpts")
if ($BtnCopyCS2LaunchOpts) {
    $BtnCopyCS2LaunchOpts.Add_Click({
        $CS2LaunchOptions = $UserControl.FindName("CS2LaunchOptions")
        if ($CS2LaunchOptions) {
            Add-Type -AssemblyName PresentationCore
            [Windows.Clipboard]::SetText($CS2LaunchOptions.Text)
            [System.Windows.MessageBox]::Show("CS2 launch options copied to clipboard!", "Copied", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
            if ($StatusText) { $StatusText.Text = "CS2 launch options copied to clipboard." }
        }
    })
}

# CS2 View Commands Button
$BtnViewCS2Commands = $UserControl.FindName("BtnViewCS2Commands")
if ($BtnViewCS2Commands) {
    $BtnViewCS2Commands.Add_Click({
        $InfoPopupOverlay = $UserControl.FindName("InfoPopupOverlay")
        $InfoPopupContainer = $UserControl.FindName("InfoPopupContainer")
        $InfoPopupTitle = $UserControl.FindName("InfoPopupTitle")
        $InfoPopupMessage = $UserControl.FindName("InfoPopupMessage")
        $InfoPopupOKButton = $UserControl.FindName("InfoPopupOKButton")
        $InfoPopupDataGridBorder = $UserControl.FindName("InfoPopupDataGridBorder")
        $PathBoxSection = $UserControl.FindName("PathBoxSection")
        
        if ($null -ne $InfoPopupTitle) { $InfoPopupTitle.Text = "CS2 Launch Commands Explained" }
        if ($null -ne $PathBoxSection) { $PathBoxSection.Visibility = "Collapsed" }
        if ($null -ne $InfoPopupDataGridBorder) { $InfoPopupDataGridBorder.Visibility = "Collapsed" }
        
        if ($null -ne $InfoPopupMessage) {
            $commands = @(
                @{cmd = "-high"; desc = "Sets CS2 to high CPU priority for better performance."},
                @{cmd = "-novid"; desc = "Skips the intro video on startup."},
                @{cmd = "-nojoy"; desc = "Disables joystick support to free up resources."},
                @{cmd = "-freq [rate]"; desc = "Sets monitor refresh rate (e.g., -freq 144, -freq 240)."},
                @{cmd = "+fps_max 0"; desc = "Uncaps frame rate for maximum FPS."},
                @{cmd = "-tickrate 128"; desc = "Sets tickrate to 128 for practice servers."},
                @{cmd = "+cl_forcepreload 1"; desc = "Preloads map textures to reduce stuttering."}
            )
            
            # Clear the RichTextBox
            $InfoPopupMessage.Document.Blocks.Clear()
            
            # Add commands
            foreach ($item in $commands) {
                $para = New-Object System.Windows.Documents.Paragraph
                $para.Margin = New-Object System.Windows.Thickness(0, 0, 0, 12)
                
                # Command name (orange + bold)
                $cmdRun = New-Object System.Windows.Documents.Run
                $cmdRun.Text = "$($item.cmd)"
                $brush = New-Object System.Windows.Media.SolidColorBrush
                $brush.Color = [System.Windows.Media.Color]::FromRgb(255, 152, 0)
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

# CS2 Download Config Button
$BtnDownloadCS2Config = $UserControl.FindName("BtnDownloadCS2Config")
if ($BtnDownloadCS2Config) {
    $BtnDownloadCS2Config.Add_Click({
        try {
            $cs2TweaksScript = "$(Split-Path $PSScriptRoot)\Tools\Tweaks\CS2Tweaks.ps1"
            
            if (Test-Path $cs2TweaksScript) {
                # Execute script to generate autoexec.cfg
                $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $cs2TweaksScript -Type GenerateAutoexec 2>&1 | Out-String
                
                # Parse output for success
                if ($output -match "CS2_CONFIG_SUCCESS\|(.+)") {
                    $configPath = $matches[1]
                    $pathParts = $configPath -split '\\'
                    $fileName = $pathParts[-1]
                    
                    Show-InfoPopup "Config Ready" @() "Installation Guide:`n`n1. Locate your CS2 cfg folder:`n   steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg`n`n2. Copy '$fileName' to the cfg folder`n`n3. Launch CS2 - the config will auto-load`n`n4. To verify, open console (~) and look for 'Config Loaded!' message" ""
                    
                    if ($StatusText) { $StatusText.Text = "CS2 autoexec.cfg saved successfully." }
                } else {
                    [System.Windows.MessageBox]::Show("Failed to generate CS2 config file.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
                }
            } else {
                [System.Windows.MessageBox]::Show("CS2Tweaks.ps1 not found.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
            }
        } catch {
            [System.Windows.MessageBox]::Show("Error generating CS2 config: $($_.Exception.Message)", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
        }
    })
}

# Set Services to Manual Button Logic
if ($BtnSetServicesManual) {
    $BtnSetServicesManual.Add_Click({
        $script = "$(Split-Path $PSScriptRoot)\Tools\Tweaks\GamingTweaks.ps1"
        
        # Check if running as administrator
        $isAdmin = ([System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
        
        if ($isAdmin) {
            # Show confirmation dialog with restore point option
            $confirmResult = [System.Windows.MessageBox]::Show(
                "This will set multiple Windows services to Manual startup.`n`nA system restore point will be created automatically before applying changes.`n`nDo you want to continue?",
                "Set Services to Manual",
                [System.Windows.MessageBoxButton]::YesNo,
                [System.Windows.MessageBoxImage]::Question
            )
            
            if ($confirmResult -eq [System.Windows.MessageBoxResult]::Yes) {
                # Create restore point and run script
                $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $script -Type SetServicesManual 2>&1 | Out-String
            } else {
                $output = "Operation cancelled by user."
            }
        } else {
            # If not admin, show message
            $output = "This operation requires Administrator privileges.`n`nPlease close this application and run Launch.bat as Administrator to set services to manual."
        }
        
        # Create a text box to display results
        $resultWindow = New-Object System.Windows.Window
        $resultWindow.Title = "Services Configuration Results"
        $resultWindow.Width = 600
        $resultWindow.Height = 500
        $resultWindow.Background = [System.Windows.Media.Brushes]::Black
        $resultWindow.Foreground = [System.Windows.Media.Brushes]::White
        $resultWindow.WindowStartupLocation = "CenterScreen"
        $resultWindow.FontFamily = "Consolas"
        $resultWindow.FontSize = 11
        
        $textBox = New-Object System.Windows.Controls.TextBox
        $textBox.Text = if ($output) { $output } else { "Services have been set to manual. Restart your system for changes to take effect." }
        $textBox.IsReadOnly = $true
        $textBox.Background = "#0F111A"
        $textBox.Foreground = "#00A3FF"
        $textBox.VerticalScrollBarVisibility = "Auto"
        $textBox.HorizontalScrollBarVisibility = "Auto"
        $textBox.Margin = "10,10,10,50"
        
        $buttonPanel = New-Object System.Windows.Controls.StackPanel
        $buttonPanel.Orientation = "Horizontal"
        $buttonPanel.HorizontalAlignment = "Right"
        $buttonPanel.Margin = "10,0,10,10"
        
        $okButton = New-Object System.Windows.Controls.Button
        $okButton.Content = "Close"
        $okButton.Width = 80
        $okButton.Height = 32
        $okButton.Background = "#00A3FF"
        $okButton.Foreground = "White"
        $okButton.Add_Click({ $resultWindow.Close() })
        
        $buttonPanel.Children.Add($okButton)
        
        $grid = New-Object System.Windows.Controls.Grid
        $grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition -Property @{ Height = "*" }))
        $grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition -Property @{ Height = "Auto" }))
        
        [System.Windows.Controls.Grid]::SetRow($textBox, 0)
        [System.Windows.Controls.Grid]::SetRow($buttonPanel, 1)
        
        $grid.Children.Add($textBox)
        $grid.Children.Add($buttonPanel)
        
        $resultWindow.Content = $grid
        $resultWindow.ShowDialog()
        
        if ($StatusText) { $StatusText.Text = "Services set to manual. Restart recommended." }
    })
}

# Reset Services Button Logic
$BtnResetServices = $UserControl.FindName("BtnResetServices")
if ($BtnResetServices) {
    $BtnResetServices.Add_Click({
        $script = "$(Split-Path $PSScriptRoot)\Tools\Tweaks\GamingTweaks.ps1"
        
        # Check if running as administrator
        $isAdmin = ([System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
        
        if ($isAdmin) {
            # If already admin, run directly
            $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $script -Type ResetServices 2>&1 | Out-String
        } else {
            # If not admin, show message
            $output = "This operation requires Administrator privileges.`n`nPlease close this application and run Launch.vbs as Administrator to reset services."
        }
        
        # Create a text box to display results
        $resultWindow = New-Object System.Windows.Window
        $resultWindow.Title = "Services Reset Results"
        $resultWindow.Width = 600
        $resultWindow.Height = 500
        $resultWindow.Background = [System.Windows.Media.Brushes]::Black
        $resultWindow.Foreground = [System.Windows.Media.Brushes]::White
        $resultWindow.WindowStartupLocation = "CenterScreen"
        $resultWindow.FontFamily = "Consolas"
        $resultWindow.FontSize = 11
        
        $textBox = New-Object System.Windows.Controls.TextBox
        $textBox.Text = if ($output) { $output } else { "Services have been reset to default. Restart your system for changes to take effect." }
        $textBox.IsReadOnly = $true
        $textBox.Background = "#0F111A"
        $textBox.Foreground = "#00A3FF"
        $textBox.VerticalScrollBarVisibility = "Auto"
        $textBox.HorizontalScrollBarVisibility = "Auto"
        $textBox.Margin = "10,10,10,50"
        
        $buttonPanel = New-Object System.Windows.Controls.StackPanel
        $buttonPanel.Orientation = "Horizontal"
        $buttonPanel.HorizontalAlignment = "Right"
        $buttonPanel.Margin = "10,0,10,10"
        
        $okButton = New-Object System.Windows.Controls.Button
        $okButton.Content = "Close"
        $okButton.Width = 80
        $okButton.Height = 32
        $okButton.Background = "#00A3FF"
        $okButton.Foreground = "White"
        $okButton.Add_Click({ $resultWindow.Close() })
        
        $buttonPanel.Children.Add($okButton)
        
        $grid = New-Object System.Windows.Controls.Grid
        $grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition -Property @{ Height = "*" }))
        $grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition -Property @{ Height = "Auto" }))
        
        [System.Windows.Controls.Grid]::SetRow($textBox, 0)
        [System.Windows.Controls.Grid]::SetRow($buttonPanel, 1)
        
        $grid.Children.Add($textBox)
        $grid.Children.Add($buttonPanel)
        
        $resultWindow.Content = $grid
        $resultWindow.ShowDialog()
        
        if ($StatusText) { $StatusText.Text = "Services reset to default. Restart recommended." }
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
$ContentLaunchOpts = $UserControl.FindName("ContentLaunchOpts")
$ContentVideoSettings = $UserControl.FindName("ContentVideoSettings")
$ContentCSMOptimization = $UserControl.FindName("ContentCSMOptimization")

$apexTabs = @($TabLaunchOpts, $TabVideoSettings, $TabCSMOptimization)
$apexContents = @($ContentLaunchOpts, $ContentVideoSettings, $ContentCSMOptimization)

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

# Games Library - Game Optimization Button Handlers
$BtnOptimizeApex = $UserControl.FindName("BtnOptimizeApex")
$BtnOptimizeValorant = $UserControl.FindName("BtnOptimizeValorant")
$BtnOptimizeCS2 = $UserControl.FindName("BtnOptimizeCS2")
$BtnOptimizeFortnite = $UserControl.FindName("BtnOptimizeFortnite")
$BtnOptimizeCOD = $UserControl.FindName("BtnOptimizeCOD")
$BtnOptimizeLoL = $UserControl.FindName("BtnOptimizeLoL")
$BtnOptimizeOW2 = $UserControl.FindName("BtnOptimizeOW2")
$BtnOptimizeR6 = $UserControl.FindName("BtnOptimizeR6")
$BtnOptimizeRL = $UserControl.FindName("BtnOptimizeRL")
$BtnBackFromApex = $UserControl.FindName("BtnBackFromApex")
$BtnBackFromValorant = $UserControl.FindName("BtnBackFromValorant")
$BtnBackFromCS2 = $UserControl.FindName("BtnBackFromCS2")
$BtnBackFromFortnite = $UserControl.FindName("BtnBackFromFortnite")
$BtnBackFromCOD = $UserControl.FindName("BtnBackFromCOD")
$BtnBackFromLoL = $UserControl.FindName("BtnBackFromLoL")
$BtnBackFromOW2 = $UserControl.FindName("BtnBackFromOW2")
$BtnBackFromR6 = $UserControl.FindName("BtnBackFromR6")
$BtnBackFromRL = $UserControl.FindName("BtnBackFromRL")

if ($BtnOptimizeApex) {
    $BtnOptimizeApex.Add_Click({ Show-Section $SectionApex })
}

if ($BtnBackFromApex) {
    $BtnBackFromApex.Add_Click({ Show-Section $SectionGamesLibrary })
}

if ($BtnOptimizeValorant) {
    $BtnOptimizeValorant.Add_Click({ Show-Section $SectionValorant })
}

if ($BtnOptimizeCS2) {
    $BtnOptimizeCS2.Add_Click({ Show-Section $SectionCS2 })
}

if ($BtnOptimizeFortnite) {
    $BtnOptimizeFortnite.Add_Click({ Show-Section $SectionFortnite })
}

if ($BtnOptimizeCOD) {
    $BtnOptimizeCOD.Add_Click({ Show-Section $SectionCOD })
}

if ($BtnOptimizeLoL) {
    $BtnOptimizeLoL.Add_Click({ Show-Section $SectionLoL })
}

if ($BtnOptimizeOW2) {
    $BtnOptimizeOW2.Add_Click({ Show-Section $SectionOW2 })
}

if ($BtnOptimizeR6) {
    $BtnOptimizeR6.Add_Click({ Show-Section $SectionR6 })
}

if ($BtnOptimizeRL) {
    $BtnOptimizeRL.Add_Click({ Show-Section $SectionRL })
}

if ($BtnBackFromValorant) {
    $BtnBackFromValorant.Add_Click({ Show-Section $SectionGamesLibrary })
}

if ($BtnBackFromCS2) {
    $BtnBackFromCS2.Add_Click({ Show-Section $SectionGamesLibrary })
}

if ($BtnBackFromFortnite) {
    $BtnBackFromFortnite.Add_Click({ Show-Section $SectionGamesLibrary })
}

if ($BtnBackFromCOD) {
    $BtnBackFromCOD.Add_Click({ Show-Section $SectionGamesLibrary })
}

if ($BtnBackFromLoL) {
    $BtnBackFromLoL.Add_Click({ Show-Section $SectionGamesLibrary })
}

if ($BtnBackFromOW2) {
    $BtnBackFromOW2.Add_Click({ Show-Section $SectionGamesLibrary })
}

if ($BtnBackFromR6) {
    $BtnBackFromR6.Add_Click({ Show-Section $SectionGamesLibrary })
}

if ($BtnBackFromRL) {
    $BtnBackFromRL.Add_Click({ Show-Section $SectionGamesLibrary })
}

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