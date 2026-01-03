param([string]$Type)

switch ($Type) {
    "ClearCache" {
        $paths = @("$env:LocalAppData\NVIDIA\DXCache", "$env:LocalAppData\NVIDIA\GLCache", "$env:LocalAppData\D3DSCache")
        $totalDeleted = 0
        $totalRemaining = 0
        
        foreach ($path in $paths) {
            if (Test-Path $path) {
                $items = @(Get-ChildItem -Path $path -Force -Recurse -ErrorAction SilentlyContinue)
                $itemCount = $items.Count
                if ($itemCount -gt 0) {
                    Get-ChildItem -Path $path -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                    $remaining = @(Get-ChildItem -Path $path -Force -Recurse -ErrorAction SilentlyContinue)
                    $deleted = $itemCount - $remaining.Count
                    $totalDeleted += $deleted
                    $totalRemaining += $remaining.Count
                }
            }
        }
        
        # Output structured result for parsing
        Write-Output "NVIDIA_CACHE|$totalDeleted|$totalRemaining"
    }
}

Write-Output "OPERATION_COMPLETE"
