param([string]$Type)

switch ($Type) {
    "ClearTemp" {
        $tempPath = $env:TEMP
        $totalDeleted = 0
        $totalRemaining = 0
        
        if (Test-Path $tempPath) {
            try {
                $items = @(Get-ChildItem -Path $tempPath -Force -Recurse -ErrorAction SilentlyContinue)
                $itemCount = $items.Count
                
                if ($itemCount -gt 0) {
                    # Try to remove items
                    Get-ChildItem -Path $tempPath -Force -Recurse -ErrorAction SilentlyContinue | 
                        Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                    
                    # Count remaining items
                    $remaining = @(Get-ChildItem -Path $tempPath -Force -Recurse -ErrorAction SilentlyContinue)
                    $deleted = $itemCount - $remaining.Count
                    $totalDeleted += $deleted
                    $totalRemaining += $remaining.Count
                } else {
                    $totalRemaining = 0
                }
            } catch {
                $totalRemaining = 0
            }
        }
        
        # Output structured result for parsing
        Write-Output "TEMP_CACHE|$totalDeleted|$totalRemaining"
    }
}

Write-Output "OPERATION_COMPLETE"
