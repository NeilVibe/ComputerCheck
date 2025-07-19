# Comprehensive Security Check Script
Write-Host "=== COMPREHENSIVE SECURITY CHECK ===" -ForegroundColor Cyan
Write-Host "Starting at: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# 1. Check for suspicious processes
Write-Host "=== CHECKING SUSPICIOUS PROCESSES ===" -ForegroundColor Green
Write-Host "Looking for:"
Write-Host "- Processes without company info"
Write-Host "- Processes with suspicious paths"
Write-Host "- Hidden processes"
Write-Host ""

$suspiciousProcesses = Get-Process | Where-Object {
    $_.Path -and (
        $_.Path -match 'AppData\\Roaming' -or
        $_.Path -match 'Temp' -or
        $_.Path -match 'Users\\Public' -or
        -not $_.Company -or
        $_.Company -match 'Unknown'
    )
} | Select-Object Name, Id, Path, Company

if ($suspiciousProcesses) {
    Write-Host "FOUND SUSPICIOUS PROCESSES:" -ForegroundColor Red
    $suspiciousProcesses | Format-Table -AutoSize
} else {
    Write-Host "No suspicious processes found" -ForegroundColor Green
}

# 2. Check network connections
Write-Host "`n=== CHECKING NETWORK CONNECTIONS ===" -ForegroundColor Green
Write-Host "Looking for connections to suspicious IPs..."
$connections = Get-NetTCPConnection -State Established | Where-Object {
    $_.RemoteAddress -ne '127.0.0.1' -and 
    $_.RemoteAddress -ne '::1' -and
    $_.RemoteAddress -ne '0.0.0.0'
} | Select-Object LocalPort, RemoteAddress, RemotePort, State, @{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).Name}}

Write-Host "Active connections:"
$connections | Format-Table -AutoSize

# 3. Check scheduled tasks
Write-Host "`n=== CHECKING SCHEDULED TASKS ===" -ForegroundColor Green
Write-Host "Looking for suspicious scheduled tasks..."
$suspiciousTasks = Get-ScheduledTask | Where-Object {
    $_.TaskPath -notmatch 'Microsoft' -and
    $_.State -eq 'Ready' -and
    ($_.Actions.Execute -match 'powershell' -or 
     $_.Actions.Execute -match 'cmd' -or
     $_.Actions.Arguments -match '-WindowStyle hidden' -or
     $_.Actions.Arguments -match '-EncodedCommand')
} | Select-Object TaskName, TaskPath, State, @{Name="Action";Expression={$_.Actions.Execute + " " + $_.Actions.Arguments}}

if ($suspiciousTasks) {
    Write-Host "SUSPICIOUS SCHEDULED TASKS FOUND:" -ForegroundColor Red
    $suspiciousTasks | Format-Table -Wrap
} else {
    Write-Host "No suspicious scheduled tasks found" -ForegroundColor Green
}

# 4. Check autostart programs
Write-Host "`n=== CHECKING AUTOSTART PROGRAMS ===" -ForegroundColor Green
$autostarts = Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location, User

Write-Host "Autostart programs:"
$autostarts | Format-Table -AutoSize

# 5. Check for hidden files in system directories
Write-Host "`n=== CHECKING FOR HIDDEN EXECUTABLES ===" -ForegroundColor Green
$hiddenExes = Get-ChildItem -Path "C:\Windows\System32", "C:\Windows\SysWOW64", "C:\ProgramData" -Filter "*.exe" -Hidden -ErrorAction SilentlyContinue | 
    Where-Object { $_.CreationTime -gt (Get-Date).AddDays(-30) } |
    Select-Object FullName, CreationTime, LastWriteTime

if ($hiddenExes) {
    Write-Host "Recently created hidden executables:" -ForegroundColor Yellow
    $hiddenExes | Format-Table -AutoSize
} else {
    Write-Host "No recently created hidden executables found" -ForegroundColor Green
}

# 6. Check DNS settings
Write-Host "`n=== CHECKING DNS SETTINGS ===" -ForegroundColor Green
$dnsServers = Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object {$_.ServerAddresses} | Select-Object InterfaceAlias, ServerAddresses
Write-Host "Current DNS servers:"
$dnsServers | Format-Table -AutoSize

# 7. Check for unsigned drivers
Write-Host "`n=== CHECKING FOR UNSIGNED DRIVERS ===" -ForegroundColor Green
$unsignedDrivers = Get-WmiObject Win32_PnPSignedDriver | Where-Object {$_.IsSigned -eq $false} | Select-Object DeviceName, DriverVersion, DriverDate

if ($unsignedDrivers) {
    Write-Host "UNSIGNED DRIVERS FOUND:" -ForegroundColor Yellow
    $unsignedDrivers | Format-Table -AutoSize
} else {
    Write-Host "All drivers are signed" -ForegroundColor Green
}

Write-Host "`n=== SECURITY CHECK COMPLETE ===" -ForegroundColor Cyan
Write-Host "Completed at: $(Get-Date)" -ForegroundColor Yellow