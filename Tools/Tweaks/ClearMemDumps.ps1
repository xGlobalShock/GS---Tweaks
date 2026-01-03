param([string]$Type)

switch ($Type) {
    "ClearMemDumps" {
        $dumpPath = "C:\Windows\Minidump"
        $totalDeleted = 0
        $totalRemaining = 0
        
        if (Test-Path $dumpPath) {
            try {
                $items = @(Get-ChildItem -Path $dumpPath -Force -Recurse -ErrorAction SilentlyContinue)
                $itemCount = $items.Count
                
                if ($itemCount -gt 0) {
                    Get-ChildItem -Path $dumpPath -Force -Recurse -ErrorAction SilentlyContinue | 
                        Remove-Item -Force -ErrorAction SilentlyContinue
                    
                    $remaining = @(Get-ChildItem -Path $dumpPath -Force -Recurse -ErrorAction SilentlyContinue)
                    $deleted = $itemCount - $remaining.Count
                    $totalDeleted = $deleted
                    $totalRemaining = $remaining.Count
                }
            } catch {
                $totalRemaining = 0
            }
        }
        
        Write-Output "MEMORY_DUMPS|$totalDeleted|$totalRemaining"
    }
}

Write-Output "OPERATION_COMPLETE"
