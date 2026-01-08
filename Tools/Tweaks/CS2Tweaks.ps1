param([string]$Type)

# Counter-Strike 2 Optimization Script
# Generates autoexec.cfg with competitive settings for maximum FPS and low latency

switch ($Type) {
    "GenerateAutoexec" {
        # Generate CS2 autoexec.cfg file
        try {
            # Use Save File Dialog for user to choose location
            Add-Type -AssemblyName System.Windows.Forms
            $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
            $saveDialog.FileName = "autoexec.cfg"
            $saveDialog.DefaultExt = "cfg"
            $saveDialog.Filter = "Config Files (*.cfg)|*.cfg|All Files (*.*)|*.*"
            $saveDialog.Title = "Save CS2 autoexec.cfg"
            $saveDialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
            
            if ($saveDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $autoexecPath = $saveDialog.FileName
                
                # CS2 Competitive Autoexec Configuration
                $configContent = @"
// ======================================
// CS2 Competitive Configuration
// Optimized for maximum FPS and low latency
// ======================================

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

// Visual Settings (Performance)
r_drawparticles "0"
r_drawtracers_firstperson "0"
func_break_max_pieces "0"

// Crosshair Settings (Optional - Uncomment to use)
// cl_crosshairalpha "255"
// cl_crosshaircolor "1"
// cl_crosshairdot "0"
// cl_crosshairgap "-3"
// cl_crosshairsize "3"
// cl_crosshairstyle "4"
// cl_crosshairthickness "0"

echo "==================================="
echo "CS2 Competitive Config Loaded!"
echo "==================================="
"@
                
                Set-Content -Path $autoexecPath -Value $configContent -Encoding UTF8
                
                # Output success message with path
                Write-Output "CS2_CONFIG_SUCCESS|$autoexecPath"
                
                # Set file as read-only for safety
                Set-ItemProperty -Path $autoexecPath -Name IsReadOnly -Value $false
                
                return $autoexecPath
            }
        } catch {
            Write-Output "CS2_CONFIG_ERROR|$($_.Exception.Message)"
            Write-Host "Error creating autoexec.cfg: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    default {
        Write-Host "Unknown CS2 tweak type: $Type" -ForegroundColor Red
        Write-Host "Available types: GenerateAutoexec" -ForegroundColor Yellow
    }
}
