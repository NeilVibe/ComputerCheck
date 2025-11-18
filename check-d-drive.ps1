# D Drive Usage Checker
# Finds all processes and files currently using D drive

Write-Host "`n=== D DRIVE USAGE CHECK ===`n" -ForegroundColor Cyan

# 1. Check processes running FROM D drive
Write-Host "[1] Processes Running FROM D Drive:" -ForegroundColor Yellow
$dProcesses = Get-Process | Where-Object { $_.Path -like "D:*" } | Select-Object Name, Id, Path
if ($dProcesses) {
    $dProcesses | Format-Table -AutoSize
} else {
    Write-Host "   No processes running from D drive" -ForegroundColor Green
}

# 2. Check services installed on D drive
Write-Host "`n[2] Services Installed on D Drive:" -ForegroundColor Yellow
$dServices = Get-WmiObject Win32_Service | Where-Object { $_.PathName -like "*D:*" } | Select-Object Name, State, StartMode, PathName
if ($dServices) {
    $dServices | Format-Table -AutoSize -Wrap
} else {
    Write-Host "   No services on D drive" -ForegroundColor Green
}

# 3. Check scheduled tasks using D drive
Write-Host "`n[3] Scheduled Tasks Using D Drive:" -ForegroundColor Yellow
$dTasks = Get-ScheduledTask | Where-Object { $_.Actions.Execute -like "*D:*" -or $_.Actions.WorkingDirectory -like "*D:*" }
if ($dTasks) {
    $dTasks | Select-Object TaskName, State, @{N='Execute';E={$_.Actions.Execute}} | Format-Table -AutoSize
} else {
    Write-Host "   No scheduled tasks using D drive" -ForegroundColor Green
}

# 4. Check loaded DLLs/modules from D drive
Write-Host "`n[4] Loaded DLLs/Modules from D Drive:" -ForegroundColor Yellow
$dModules = @()
Get-Process | ForEach-Object {
    try {
        $proc = $_
        $_.Modules | Where-Object { $_.FileName -like "D:*" } | ForEach-Object {
            $dModules += [PSCustomObject]@{
                ProcessName = $proc.Name
                ProcessId = $proc.Id
                Module = $_.FileName
            }
        }
    } catch {}
}
if ($dModules) {
    $dModules | Select-Object -Unique ProcessName, ProcessId, Module | Format-Table -AutoSize -Wrap
} else {
    Write-Host "   No DLLs/modules loaded from D drive" -ForegroundColor Green
}

# 5. Check D drive space
Write-Host "`n[5] D Drive Space:" -ForegroundColor Yellow
$drive = Get-PSDrive D
$usedGB = [math]::Round($drive.Used / 1GB, 2)
$freeGB = [math]::Round($drive.Free / 1GB, 2)
$totalGB = [math]::Round(($drive.Used + $drive.Free) / 1GB, 2)
$percentUsed = [math]::Round(($drive.Used / ($drive.Used + $drive.Free)) * 100, 1)

Write-Host "   Total: $totalGB GB"
Write-Host "   Used: $usedGB GB ($percentUsed%)"
Write-Host "   Free: $freeGB GB"

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "If all sections show 'No...' or are empty, D drive is safe to format!" -ForegroundColor Green
Write-Host "Otherwise, close/uninstall any software found above before formatting.`n" -ForegroundColor Yellow
