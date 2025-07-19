# Hunt for Kings Online Security remnants
Write-Host "=== Hunting for Kings Online Security (KOS) remnants ===" -ForegroundColor Yellow

# Check processes
Write-Host "`n[1] Checking for KOS-related processes..." -ForegroundColor Cyan
$kosProcesses = Get-Process | Where-Object {
    $_.Name -like '*KOS*' -or 
    $_.ProcessName -like '*Kings*' -or 
    $_.Path -like '*Kings Online Security*' -or
    $_.Company -like '*Kings Information*'
}
if ($kosProcesses) {
    Write-Host "FOUND KOS PROCESSES:" -ForegroundColor Red
    $kosProcesses | Format-Table Name, Id, Path, Company -AutoSize
} else {
    Write-Host "No KOS processes found" -ForegroundColor Green
}

# Check services
Write-Host "`n[2] Checking for KOS services..." -ForegroundColor Cyan
$kosServices = Get-Service | Where-Object {
    $_.Name -like '*KOS*' -or 
    $_.DisplayName -like '*Kings*' -or
    $_.DisplayName -like '*KOS*'
}
if ($kosServices) {
    Write-Host "FOUND KOS SERVICES:" -ForegroundColor Red
    $kosServices | Format-Table Name, Status, DisplayName -AutoSize
} else {
    Write-Host "No KOS services found" -ForegroundColor Green
}

# Check file system remnants
Write-Host "`n[3] Checking file system for KOS artifacts..." -ForegroundColor Cyan
$locations = @(
    "C:\Program Files\Kings Online Security",
    "C:\Program Files (x86)\Kings Online Security",
    "C:\ProgramData\Kings*",
    "C:\ProgramData\KOS*",
    "$env:APPDATA\Kings*",
    "$env:APPDATA\KOS*",
    "$env:LOCALAPPDATA\Kings*",
    "$env:LOCALAPPDATA\KOS*"
)

$foundFiles = @()
foreach ($loc in $locations) {
    if (Test-Path $loc) {
        Write-Host "FOUND: $loc" -ForegroundColor Red
        $foundFiles += Get-ChildItem -Path $loc -Recurse -ErrorAction SilentlyContinue
    }
}

# Search for KOS files anywhere
Write-Host "`n[4] Deep search for KOS files..." -ForegroundColor Cyan
$drives = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -eq 'C'}
foreach ($drive in $drives) {
    Write-Host "Searching $($drive.Name):\ drive..."
    $kosFiles = Get-ChildItem -Path "$($drive.Name):\" -Include "*KOS*", "*Kings Online*" -Recurse -ErrorAction SilentlyContinue | 
                Where-Object {$_.FullName -notlike "*CheckComputer*" -and $_.FullName -notlike "*hunt-kos*"}
    if ($kosFiles) {
        Write-Host "FOUND KOS FILES:" -ForegroundColor Red
        $kosFiles | Select-Object FullName, Length, LastWriteTime | Format-Table -AutoSize
    }
}

# Check registry
Write-Host "`n[5] Checking registry for KOS entries..." -ForegroundColor Cyan
$regPaths = @(
    "HKLM:\SOFTWARE\Kings Online Security",
    "HKLM:\SOFTWARE\WOW6432Node\Kings Online Security",
    "HKLM:\SYSTEM\CurrentControlSet\Services\KOS*",
    "HKCU:\SOFTWARE\Kings Online Security",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($path in $regPaths) {
    if (Test-Path $path) {
        $items = Get-ItemProperty $path -ErrorAction SilentlyContinue | 
                 Where-Object {$_ -match "KOS|Kings Online"}
        if ($items) {
            Write-Host "FOUND REGISTRY ENTRIES at ${path}:" -ForegroundColor Red
            $items
        }
    }
}

# Check scheduled tasks
Write-Host "`n[6] Checking scheduled tasks..." -ForegroundColor Cyan
$kosTasks = Get-ScheduledTask | Where-Object {
    $_.TaskName -like '*KOS*' -or 
    $_.TaskName -like '*Kings*' -or
    $_.Description -like '*Kings Online*' -or
    $_.Actions.Execute -like '*KOS*' -or
    $_.Actions.Execute -like '*Kings Online*'
}
if ($kosTasks) {
    Write-Host "FOUND KOS SCHEDULED TASKS:" -ForegroundColor Red
    $kosTasks | Format-Table TaskName, State, TaskPath -AutoSize
} else {
    Write-Host "No KOS scheduled tasks found" -ForegroundColor Green
}

# Check network connections to known KOS servers
Write-Host "`n[7] Checking for connections to known KOS servers..." -ForegroundColor Cyan
$connections = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue
$suspiciousIPs = @()
foreach ($conn in $connections) {
    # Check if connection is to Korea or suspicious ports used by KOS
    $remoteIP = $conn.RemoteAddress
    if ($remoteIP -notlike "127.*" -and $remoteIP -notlike "::1" -and $remoteIP -ne "::") {
        # You would check against known KOS IPs here
        # For now, just log non-local connections
    }
}

# Check Windows Defender history
Write-Host "`n[8] Checking Windows Defender history for KOS..." -ForegroundColor Cyan
try {
    $defenderEvents = Get-WinEvent -LogName "Microsoft-Windows-Windows Defender/Operational" -MaxEvents 100 -ErrorAction SilentlyContinue |
                      Where-Object {$_.Message -like "*Kings*" -or $_.Message -like "*KOS*"}
    if ($defenderEvents) {
        Write-Host "Windows Defender KOS-related events:" -ForegroundColor Yellow
        $defenderEvents | Select-Object TimeCreated, Message | Format-List
    }
} catch {
    Write-Host "Could not check Windows Defender logs" -ForegroundColor Gray
}

Write-Host "`n=== KOS Hunt Complete ===" -ForegroundColor Yellow