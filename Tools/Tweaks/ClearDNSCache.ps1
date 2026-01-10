# ClearDNSCache.ps1
# Clears the Windows DNS resolver cache with detailed logging

param([string]$Type = "ClearCache")

function Get-DNSCacheEntryCount {
    <#
    .SYNOPSIS
    Counts the number of entries in the DNS resolver cache
    
    .DESCRIPTION
    Uses ipconfig /displaydns to get all cached DNS entries and counts them.
    #>
    try {
        $output = & ipconfig /displaydns 2>$null
        # Count lines that contain "Record Name" which indicates a cached entry
        $count = ($output | Select-String -Pattern "Record Name" -ErrorAction SilentlyContinue | Measure-Object).Count
        return $count
    } catch {
        return 0
    }
}

function Get-DNSCacheEntries {
    <#
    .SYNOPSIS
    Gets detailed list of DNS cache entries
    
    .DESCRIPTION
    Returns an array of DNS cache entries with their names and values
    #>
    try {
        $output = & ipconfig /displaydns 2>$null
        $entries = @()
        $currentEntry = $null
        
        foreach ($line in $output) {
            if ($line -match "Record Name\s+:\s+(.+)") {
                $currentEntry = $matches[1].Trim()
                $entries += $currentEntry
            }
        }
        return $entries
    } catch {
        return @()
    }
}

switch ($Type) {
    "ClearCache" {
        # Get count before flush
        $countBefore = Get-DNSCacheEntryCount
        Write-Output "STATUS|DNS Cache Entries: $countBefore"
        
        # Get list of entries before
        if ($countBefore -gt 0) {
            $entriesBefore = Get-DNSCacheEntries
            $entryNum = 1
            foreach ($entry in $entriesBefore) {
                Write-Output "ENTRY|$entry"
                $entryNum++
                if ($entryNum -gt 20) {
                    $remaining = $countBefore - 20
                    Write-Output "ENTRY|... and $remaining more entries"
                    break
                }
            }
        }
        
        # Flush DNS cache
        try {
            Write-Output "ACTION|Flushing DNS resolver cache..."
            $flushOutput = & ipconfig /flushdns 2>&1
            
            if ($flushOutput -match "successfully|flushed") {
                Write-Output "SUCCESS|DNS cache flushed successfully!"
                
                # Small delay to ensure cache is flushed
                Start-Sleep -Milliseconds 500
                
                # Get count after flush
                $countAfter = Get-DNSCacheEntryCount
                
                # Calculate deleted count
                $deleted = [Math]::Max(0, $countBefore - $countAfter)
                
                Write-Output "RESULT|Entries Deleted: $deleted"
                Write-Output "RESULT|Entries Remaining: $countAfter"
                
                # Output format: "DNS_CACHE|deleted|remaining"
                Write-Output "DNS_CACHE|$deleted|$countAfter"
            } else {
                Write-Output "ERROR|DNS flush operation failed"
                Write-Output "DNS_CACHE|0|0"
            }
        } catch {
            Write-Output "ERROR|Exception during DNS flush: $($_.Exception.Message)"
            Write-Output "DNS_CACHE|0|0"
        }
    }
    
    default {
        Write-Host "Unknown operation: $Type" -ForegroundColor Red
    }
}
