param([string]$Type)

switch ($Type) {
    "ClearPrefetch" {
        $prefetchPath = "C:\Windows\Prefetch"
        $totalDeleted = 0
        $totalRemaining = 0
        
        if (Test-Path $prefetchPath) {
            try {
                $items = @(Get-ChildItem -Path $prefetchPath -Force -ErrorAction SilentlyContinue | Where-Object { $_.Extension -eq ".pf" })
                $itemCount = $items.Count
                
                if ($itemCount -gt 0) {
                    Get-ChildItem -Path $prefetchPath -Force -ErrorAction SilentlyContinue | 
                        Where-Object { $_.Extension -eq ".pf" } | 
                        Remove-Item -Force -ErrorAction SilentlyContinue
                    
                    $remaining = @(Get-ChildItem -Path $prefetchPath -Force -ErrorAction SilentlyContinue | Where-Object { $_.Extension -eq ".pf" })
                    $deleted = $itemCount - $remaining.Count
                    $totalDeleted = $deleted
                    $totalRemaining = $remaining.Count
                }
            } catch {
                $totalRemaining = 0
            }
        }
        
        Write-Output "PREFETCH_CACHE|$totalDeleted|$totalRemaining"
    }
}

Write-Output "OPERATION_COMPLETE"
