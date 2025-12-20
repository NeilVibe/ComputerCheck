# WSL Watchdog v2 - NO WINDOW FLASH
# Uses process check instead of wsl --exec

$distro = "Ubuntu2"
$logFile = "$env:USERPROFILE\wsl-watchdog.log"

# Check if WSL is running by looking for wsl.exe process with our distro
# This does NOT create any window
$wslProcesses = Get-Process -Name "wsl" -ErrorAction SilentlyContinue

if (-not $wslProcesses) {
    # No WSL process at all, start it
    Start-Process "wt.exe" -ArgumentList "-p", $distro
    Add-Content -Path $logFile -Value "$(Get-Date): WSL was down - opened terminal"
}
