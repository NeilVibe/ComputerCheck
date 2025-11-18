# Check for Driver/DPC Latency Issues
Write-Host "=== DRIVER & DPC LATENCY CHECK ===" -ForegroundColor Cyan

# Check loaded kernel drivers
Write-Host "`n[1] SUSPICIOUS KERNEL DRIVERS" -ForegroundColor Yellow
$suspiciousDrivers = @('IOMap', 'vgk', 'vgc') # IOMap, Riot Vanguard kernel, Riot Vanguard client
Get-Service | Where-Object {
    $suspiciousDrivers -contains $_.Name
} | Select-Object Name, Status, StartType, DisplayName | Format-Table

# Check all running kernel drivers
Write-Host "`n[2] ALL RUNNING KERNEL/BOOT DRIVERS" -ForegroundColor Yellow
Get-Service | Where-Object {
    $_.Status -eq 'Running' -and ($_.StartType -eq 'Boot' -or $_.StartType -eq 'System')
} | Select-Object Name, DisplayName | Sort-Object Name

# Check for driver errors in event log
Write-Host "`n[3] RECENT DRIVER ERRORS (Last 30 min)" -ForegroundColor Yellow
Get-WinEvent -FilterHashtable @{
    LogName='System'
    Level=1,2
    StartTime=(Get-Date).AddMinutes(-30)
} -MaxEvents 20 -ErrorAction SilentlyContinue |
    Where-Object { $_.ProviderName -like '*driver*' -or $_.ProviderName -like '*kernel*' -or $_.Id -eq 219 } |
    Select-Object TimeCreated, Id, ProviderName, Message |
    Format-List

# Check NVIDIA driver status
Write-Host "`n[4] NVIDIA DRIVER STATUS" -ForegroundColor Yellow
Get-Process nvcontainer -ErrorAction SilentlyContinue |
    Select-Object Name, Id, CPU, @{N='RAM(MB)';E={[math]::Round($_.WS/1MB,0)}} |
    Format-Table

# Check for audio driver issues (common DPC latency source)
Write-Host "`n[5] AUDIO DRIVERS" -ForegroundColor Yellow
Get-Service | Where-Object {
    $_.Name -like '*audio*' -and $_.Status -eq 'Running'
} | Select-Object Name, DisplayName | Format-Table

Write-Host "`n=== RECOMMENDATION ===" -ForegroundColor Cyan
Write-Host "If IOMap or Riot Vanguard (vgk/vgc) are running, they may be causing DPC latency." -ForegroundColor Yellow
Write-Host "DPC latency = kernel drivers blocking UI thread despite low CPU/RAM usage" -ForegroundColor Yellow
