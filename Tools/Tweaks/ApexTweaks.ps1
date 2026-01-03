param([string]$Type)

$videoconfig = Join-Path $env:USERPROFILE "Saved Games\Respawn\Apex\Local\videoconfig.txt"

switch ($Type) {
    "Launch" {
        $gameAppID = 1172470
        $launchOptions = "+lobby_max_fps 0 -dev -novid +fps_max 240 -render_on_input_thread +mat_wide_pillarbox 0 +mat_minimize_on_alt_tab 1"
        $steamRegistryPath = "HKCU:\Software\Valve\Steam\Apps\$gameAppID"
        if (!(Test-Path $steamRegistryPath)) { New-Item -Path $steamRegistryPath -Force | Out-Null }
        Set-ItemProperty -Path $steamRegistryPath -Name "LaunchOptions" -Value $launchOptions
    }
    "Config" {
        if (Test-Path $videoconfig) {
            attrib -R $videoconfig
            $content = Get-Content $videoconfig
            $quote = [char]34
            $tab = [char]9
            $settings = @(
                @{ key = $quote + 'setting.csm_enabled' + $quote; value = '0' },
                @{ key = $quote + 'setting.csm_coverage' + $quote; value = '0' },
                @{ key = $quote + 'setting.csm_cascade_res' + $quote; value = '0' }
            )
            foreach ($setting in $settings) {
                $found = $false
                for ($i = 0; $i -lt $content.Count; $i++) {
                    if ($content[$i] -like "*$($setting.key)*") {
                        $content[$i] = $setting.key + $tab + $quote + $setting.value + $quote
                        $found = $true
                        break
                    }
                }
                if (-not $found) {
                    $content += $setting.key + $tab + $quote + $setting.value + $quote
                }
            }
            Set-Content $videoconfig $content
            attrib +R $videoconfig
        }
    }
    "Config" {