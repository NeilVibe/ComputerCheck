# Quick targeted KOS hunt
Write-Host "=== Quick KOS Hunt ===" -ForegroundColor Yellow

# First, let's check those Kingston processes that showed up
Write-Host "`n[1] Checking Kingston processes (false positive check)..." -ForegroundColor Cyan
$kingston = Get-Process -Name "*Kingston*" -ErrorAction SilentlyContinue
if ($kingston) {
    Write-Host "Found Kingston processes (likely ASUS/Kingston RAM software, NOT KOS):" -ForegroundColor Yellow
    $kingston | Select-Object Name, Path, Company | Format-Table -AutoSize
}

# Quick registry check for KOS
Write-Host "`n[2] Quick registry scan for KOS..." -ForegroundColor Cyan
$regKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
)

foreach ($key in $regKeys) {
    if (Test-Path $key) {
        $values = Get-ItemProperty $key -ErrorAction SilentlyContinue
        $properties = $values.PSObject.Properties | Where-Object {
            $_.Value -like "*KOS*" -or $_.Value -like "*Kings Online*" -or 
            $_.Name -like "*KOS*" -or $_.Name -like "*Kings Online*"
        }
        if ($properties) {
            Write-Host "FOUND in ${key}:" -ForegroundColor Red
            $properties | Format-Table Name, Value -AutoSize
        }
    }
}

# Check specific KOS locations only
Write-Host "`n[3] Checking known KOS locations..." -ForegroundColor Cyan
$quickCheck = @(
    "C:\Program Files\Kings Online Security",
    "C:\Program Files (x86)\Kings Online Security", 
    "C:\ProgramData\KOS",
    "$env:APPDATA\KOS",
    "$env:LOCALAPPDATA\KOS",
    "$env:TEMP\KOS*"
)

$found = $false
foreach ($path in $quickCheck) {
    if (Test-Path $path) {
        Write-Host "FOUND: $path" -ForegroundColor Red
        $found = $true
    }
}
if (-not $found) {
    Write-Host "No KOS directories found in common locations" -ForegroundColor Green
}

# Check for KOS service remnants
Write-Host "`n[4] Checking for KOS service in registry..." -ForegroundColor Cyan
$servicePath = "HKLM:\SYSTEM\CurrentControlSet\Services\KOS_Service"
if (Test-Path $servicePath) {
    Write-Host "FOUND KOS SERVICE REGISTRY ENTRY!" -ForegroundColor Red
    Get-ItemProperty $servicePath
} else {
    Write-Host "No KOS service registry entries found" -ForegroundColor Green
}

# Quick process check for exact KOS names
Write-Host "`n[5] Checking for exact KOS process names..." -ForegroundColor Cyan
$kosProcs = Get-Process | Where-Object {
    $_.Name -eq "KOSinj" -or $_.Name -eq "KOSinj64" -or 
    $_.Path -like "*\Kings Online Security\*"
}
if ($kosProcs) {
    Write-Host "FOUND KOS PROCESSES!" -ForegroundColor Red
    $kosProcs | Format-Table Name, Id, Path -AutoSize
} else {
    Write-Host "No KOS processes running" -ForegroundColor Green
}

# Check recent Defender detections
Write-Host "`n[6] Recent Windows Defender detections..." -ForegroundColor Cyan
try {
    $threats = Get-MpThreatDetection -ErrorAction SilentlyContinue | 
               Where-Object {$_.ThreatName -like "*Kings*" -or $_.ThreatName -like "*KOS*"}
    if ($threats) {
        Write-Host "Defender detected KOS threats:" -ForegroundColor Yellow
        $threats | Select-Object ThreatName, ActionSuccess, ProcessName | Format-Table -AutoSize
    } else {
        Write-Host "No recent KOS detections by Defender" -ForegroundColor Green
    }
} catch {
    Write-Host "Could not check Defender threat history" -ForegroundColor Gray
}

Write-Host "`n=== Quick Hunt Complete ===" -ForegroundColor Yellow