param([string]$DownloadPath = "$env:USERPROFILE\Downloads")

Write-Host "NVIDIA Driver Download Manager"
Write-Host "===============================" 

function Get-NvidiaGPUInfo {
    Write-Host "Detecting NVIDIA GPU..."
    
    try {
        $gpuInfo = & nvidia-smi --query-gpu=name,driver_version --format=csv,noheader,nounits 2>$null
        
        if ($gpuInfo) {
            $parts = $gpuInfo -split ','
            $gpuName = $parts[0].Trim()
            $currentDriver = $parts[1].Trim()
            Write-Host "GPU: $gpuName (Driver: $currentDriver)"
            return @{
                GPU = $gpuName
                CurrentDriver = $currentDriver
                Found = $true
            }
        }
    } catch {
    }
    
    try {
        $gpu = Get-WmiObject Win32_VideoController | Where-Object { $_.Name -like "*NVIDIA*" } | Select-Object -First 1
        
        if ($gpu) {
            Write-Host "GPU: $($gpu.Name)"
            return @{
                GPU = $gpu.Name
                CurrentDriver = $gpu.DriverVersion
                Found = $true
            }
        }
    } catch {
    }
    
    return @{
        GPU = "Unknown"
        CurrentDriver = "Unknown"
        Found = $false
    }
}

function Download-File {
    param([string]$Url, [string]$OutputPath)
    
    try {
        Write-Host "Downloading from NVIDIA..."
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        $request = [System.Net.HttpWebRequest]::Create($Url)
        $request.Method = "GET"
        $request.Timeout = 60000
        $request.AllowAutoRedirect = $true
        
        $response = $request.GetResponse()
        $totalBytes = $response.ContentLength
        
        if ($totalBytes -le 0) {
            return $false
        }
        
        $stream = $response.GetResponseStream()
        $fileStream = New-Object System.IO.FileStream($OutputPath, 'Create')
        $buffer = New-Object byte[] 65536
        $totalRead = 0
        $startTime = Get-Date
        
        while ($true) {
            $bytesRead = $stream.Read($buffer, 0, $buffer.Length)
            if ($bytesRead -eq 0) { break }
            
            $fileStream.Write($buffer, 0, $bytesRead)
            $totalRead += $bytesRead
            
            $percentage = [Math]::Round(($totalRead / $totalBytes) * 100, 2)
            $elapsed = [Math]::Max(1, (Get-Date - $startTime).TotalSeconds)
            $speed = ($totalRead / 1MB) / $elapsed
            $downloadedMB = [Math]::Round($totalRead / 1MB, 2)
            $totalMB = [Math]::Round($totalBytes / 1MB, 2)
            $eta = if ($speed -gt 0) { [Math]::Round(($totalBytes - $totalRead) / ($speed * 1MB)) } else { 0 }
            
            Write-Host "NVIDIA_APP_PROGRESS|$percentage|$downloadedMB|$totalMB|$([Math]::Round($speed, 2))|$eta"
        }
        
        $fileStream.Close()
        $stream.Close()
        $response.Close()
        
        Write-Host "NVIDIA_APP_DOWNLOAD_COMPLETE|$OutputPath"
        return $true
    }
    catch {
        Write-Host "NVIDIA_APP_DOWNLOAD_ERROR|$($_.Exception.Message)"
        return $false
    }
}

if (-not (Test-Path $DownloadPath)) {
    New-Item -ItemType Directory -Path $DownloadPath -Force | Out-Null
}

$gpuInfo = Get-NvidiaGPUInfo

if ($gpuInfo.Found) {
    Write-Host ""
    $driverUrl = "https://us.download.nvidia.com/Windows/Latest/NVIDIA_Driver_Latest.exe"
    $outputFile = Join-Path $DownloadPath "NVIDIA_Driver_Latest.exe"
    
    Write-Host "Attempting download..."
    $success = Download-File -Url $driverUrl -OutputPath $outputFile
    
    if ($success -and (Test-Path $outputFile)) {
        $fileSize = (Get-Item $outputFile).Length
        
        if ($fileSize -lt 50MB) {
            Remove-Item $outputFile -Force -ErrorAction SilentlyContinue
            $success = $false
        }
    }
    
    if (-not $success) {
        Write-Host "Direct download failed."
        Write-Host "Visit: https://www.nvidia.com/Download/index.aspx"
    }
}
else {
    Write-Host "No NVIDIA GPU detected."
}
        
        Write-Host "NVIDIA_APP_DOWNLOAD_COMPLETE|$OutputPath"
        return $true
        
    } catch {
        Write-Host "NVIDIA_APP_DOWNLOAD_ERROR|$($_.Exception.Message)"
        return $false
    }
}

# Main execution
$gpuInfo = Get-NvidiaGPUInfo

if ($gpuInfo.Found) {
    Write-Host "NVIDIA_DRIVER_DETECTED|$($gpuInfo.GPU)|$($gpuInfo.CurrentDriver)"
    
    # Ensure downloads folder exists
    if (-not (Test-Path $DownloadPath)) {
        New-Item -ItemType Directory -Path $DownloadPath -Force | Out-Null
    }
    
    # Try to find a working NVIDIA driver download URL
    # NVIDIA's driver server URLs follow patterns, though they change frequently
    $driverUrls = @(
        # Try the latest endpoint
        "https://us.download.nvidia.com/Windows/Latest/NVIDIA_Driver_Latest.exe",
        "https://us.download.nvidia.com/Windows/Latest/nvdia_driver_latest.exe"
    )
    
    $outputFile = Join-Path $DownloadPath "NVIDIA_Driver_Latest.exe"
    
    Write-Host "Attempting to download NVIDIA Driver for detected GPU..."
    Write-Host "GPU: $($gpuInfo.GPU)"
    Write-Host "Current Driver: $($gpuInfo.CurrentDriver)`n"
    
    $success = $false
    foreach ($driverUrl in $driverUrls) {
        Write-Host "Trying: $driverUrl"
        $testSuccess = Download-File -Url $driverUrl -OutputPath $outputFile
        
        if ($testSuccess) {
            # Verify we got a real executable, not HTML
            if (Test-Path $outputFile) {
                $fileSize = (Get-Item $outputFile).Length
                
                # Real drivers are typically 400+ MB
                if ($fileSize -gt 50MB) {
                    Write-Host "✓ Successfully downloaded driver ($([Math]::Round($fileSize / 1MB, 0)) MB)`n"
                    $success = $true
                    break
                } else {
                    # Likely an HTML page, not a real driver
                    Remove-Item $outputFile -Force -ErrorAction SilentlyContinue
                }
            }
        }
    }
    
    if ($success) {
        Write-Host "Driver downloaded successfully to: $outputFile"
        Write-Host "NVIDIA_APP_DOWNLOAD_COMPLETE|$outputFile"
    } else {
        Write-Host "Unable to download driver directly from NVIDIA servers."
        Write-Host "`nTo get the latest driver for your $($gpuInfo.GPU):"
        Write-Host "Visit: https://www.nvidia.com/Download/index.aspx"
        Write-Host "`nThe website will automatically detect your GPU and provide the correct driver."
    }
} else {
    Write-Host "ERROR|GPU_NOT_DETECTED"
    Write-Host "NVIDIA drivers don't appear to be installed."
}
