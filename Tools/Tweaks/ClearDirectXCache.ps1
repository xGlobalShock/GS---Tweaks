param([string]$Type)

switch ($Type) {
    "ClearDirectXCache" {
        $d3dCachePath = "$env:LOCALAPPDATA\D3DSCache"
        $totalDeleted = 0
        $totalRemaining = 0
        
        if (Test-Path $d3dCachePath) {
            try {
                $items = @(Get-ChildItem -Path $d3dCachePath -Force -Recurse -ErrorAction SilentlyContinue)
                $itemCount = $items.Count
                
                if ($itemCount -gt 0) {
                    Get-ChildItem -Path $d3dCachePath -Force -Recurse -ErrorAction SilentlyContinue | 
                        Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                    
                    $remaining = @(Get-ChildItem -Path $d3dCachePath -Force -Recurse -ErrorAction SilentlyContinue)
                    $deleted = $itemCount - $remaining.Count
                    $totalDeleted = $deleted
                    $totalRemaining = $remaining.Count
                }
            } catch {
                $totalRemaining = 0
            }
        }
        
        Write-Output "DIRECTX_CACHE|$totalDeleted|$totalRemaining"
    }
}

Write-Output "OPERATION_COMPLETE"
