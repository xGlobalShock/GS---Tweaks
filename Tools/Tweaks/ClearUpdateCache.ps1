param([string]$Type)

switch ($Type) {
    "ClearUpdateCache" {
        $updatePath = "C:\Windows\SoftwareDistribution\Download"
        $totalDeleted = 0
        $totalRemaining = 0
        
        if (Test-Path $updatePath) {
            try {
                $items = @(Get-ChildItem -Path $updatePath -Force -Recurse -ErrorAction SilentlyContinue)
                $itemCount = $items.Count
                
                if ($itemCount -gt 0) {
                    Get-ChildItem -Path $updatePath -Force -Recurse -ErrorAction SilentlyContinue | 
                        Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                    
                    $remaining = @(Get-ChildItem -Path $updatePath -Force -Recurse -ErrorAction SilentlyContinue)
                    $deleted = $itemCount - $remaining.Count
                    $totalDeleted = $deleted
                    $totalRemaining = $remaining.Count
                }
            } catch {
                $totalRemaining = 0
            }
        }
        
        Write-Output "UPDATE_CACHE|$totalDeleted|$totalRemaining"
    }
}

Write-Output "OPERATION_COMPLETE"
