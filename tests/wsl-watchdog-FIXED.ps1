# WSL Watchdog - Opens terminal if WSL is down
# Runs every 5 minutes via scheduled task

$distro = "Ubuntu2"
$logFile = "$env:USERPROFILE\wsl-watchdog.log"

# Check if WSL is running by trying to execute a command
$null = wsl.exe -d $distro --exec /bin/true 2>$null
$isRunning = ($LASTEXITCODE -eq 0)

if (-not $isRunning) {
    # WSL is not running, open a terminal
    Start-Process "wt.exe" -ArgumentList "-p", $distro
    Add-Content -Path $logFile -Value "$(Get-Date): WSL was down - opened terminal"
}
