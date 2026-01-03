param([string]$Type)

switch ($Type) {
    "ClearShaders" {
        $apexPath = Join-Path $env:USERPROFILE "Saved Games\Respawn\Apex\local\psoCache.pso"
        $totalDeleted = 0
        $totalRemaining = 0
        
        if (Test-Path $apexPath) {
            try {
                Remove-Item $apexPath -Force -ErrorAction Stop
                $totalDeleted = 1
            } catch {
                $totalRemaining = 1
            }
        }
        
        # Output structured result for parsing
        Write-Output "APEX_SHADERS|$totalDeleted|$totalRemaining"
    }
}

Write-Output "OPERATION_COMPLETE"
