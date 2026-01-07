param([string]$DownloadPath = "$env:USERPROFILE\Downloads")

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Continue'

# Write to a fixed temp file location
$outputFile = "$env:TEMP\nvidia_download.txt"
@() | Out-File -FilePath $outputFile -Encoding UTF8 -Force

$fileStreamWriter = [System.IO.StreamWriter]::new($outputFile, $true, [System.Text.Encoding]::UTF8)
$fileStreamWriter.AutoFlush = $true

function Write-Progress-Output {
    param([string]$Message)
    Write-Output $Message
    try {
        $fileStreamWriter.WriteLine($Message)
    } catch {}
}

Write-Progress-Output "NVIDIA App Downloader"
Write-Progress-Output "=====================" 

function Download-File {
    param([string]$Url, [string]$OutputPath)
    
    try {
        Write-Progress-Output "Downloading from NVIDIA..."
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        $request = [System.Net.HttpWebRequest]::Create($Url)
        $request.Method = "GET"
        $request.Timeout = 300000
        $request.AllowAutoRedirect = $true
        
        $response = $null
        $stream = $null
        $fileStream = $null
        
        try {
            $response = $request.GetResponse()
            $totalBytes = $response.ContentLength
            
            if ($totalBytes -le 0) {
                Write-Progress-Output "NVIDIA_APP_DOWNLOAD_ERROR|Invalid content length: $totalBytes"
                return $false
            }
            
            $stream = $response.GetResponseStream()
            $fileStream = New-Object System.IO.FileStream($OutputPath, 'Create')
            $buffer = New-Object byte[] 65536
            $totalRead = 0
            $startTick = [System.Environment]::TickCount64
            $lastChunkTick = $startTick
            
            while ($true) {
                $bytesRead = $stream.Read($buffer, 0, $buffer.Length)
                if ($bytesRead -eq 0) { break }
                
                $fileStream.Write($buffer, 0, $bytesRead)
                $totalRead += $bytesRead
                
                # Calculate speed from current chunk
                $currentTick = [System.Environment]::TickCount64
                $chunkTimeMs = [Math]::Max(1, $currentTick - $lastChunkTick)
                $chunkSpeedMBps = ($bytesRead / 1MB) / ($chunkTimeMs / 1000.0)
                
                $percentage = [Math]::Round(($totalRead / $totalBytes) * 100, 2)
                $downloadedMB = [Math]::Round($totalRead / 1MB, 2)
                $totalMB = [Math]::Round($totalBytes / 1MB, 2)
                $eta = if ($chunkSpeedMBps -gt 0) { [Math]::Round(($totalBytes - $totalRead) / ($chunkSpeedMBps * 1MB)) } else { 0 }
                
                Write-Progress-Output "NVIDIA_APP_PROGRESS|$percentage|$downloadedMB|$totalMB|$([Math]::Round($chunkSpeedMBps, 2))|$eta"
                
                $lastChunkTick = $currentTick
            }
            
            Write-Progress-Output "NVIDIA_APP_DOWNLOAD_COMPLETE|$OutputPath"
            return $true
        }
        finally {
            if ($null -ne $fileStream) { $fileStream.Close() }
            if ($null -ne $stream) { $stream.Close() }
            if ($null -ne $response) { $response.Close() }
        }
    }
    catch {
        $errorMsg = $_.Exception.Message
        if ($null -ne $_.Exception.InnerException) {
            $errorMsg = "$errorMsg | Inner: $($_.Exception.InnerException.Message)"
        }
        Write-Progress-Output "NVIDIA_APP_DOWNLOAD_ERROR|$errorMsg"
        return $false
    }
}

if (-not (Test-Path $DownloadPath)) {
    New-Item -ItemType Directory -Path $DownloadPath -Force | Out-Null
}

# NVIDIA app direct download URL
$appUrl = "https://uk.download.nvidia.com/nvapp/client/11.0.5.420/NVIDIA_app_v11.0.5.420.exe"
$outputFile = Join-Path $DownloadPath "NVIDIA_App_Latest.exe"

Write-Progress-Output "Downloading NVIDIA App..."
Write-Progress-Output ""

$success = Download-File -Url $appUrl -OutputPath $outputFile

if ($success) {
    Write-Progress-Output ""
    Write-Progress-Output "Download complete!"
    Write-Progress-Output "Location: $outputFile"
}
else {
    Write-Progress-Output ""
    Write-Progress-Output "Download failed. Please visit:"
    Write-Progress-Output "https://www.nvidia.com/en-us/geforce/geforce-experience/"
}

# Close file writer
$fileStreamWriter.Close()
$fileStreamWriter.Dispose()

