# USB Device Monitor - Physical Security
Write-Host "=== USB DEVICE SECURITY MONITOR ===" -ForegroundColor Red
Write-Host "Monitoring USB devices and physical security..." -ForegroundColor Yellow
Write-Host ""

# Check currently connected USB devices (fast method)
Write-Host "Currently Connected USB Devices:" -ForegroundColor Cyan
try {
    $usbDevices = Get-Volume | Where-Object { 
        $_.DriveType -eq "Removable" 
    }
    
    if ($usbDevices) {
        foreach ($device in $usbDevices) {
            Write-Host "📱 Drive: $($device.DriveLetter) - Label: $($device.FileSystemLabel) - Size: $([math]::Round($device.Size/1GB,2))GB" -ForegroundColor Yellow
            
            # Quick scan for executables (fast)
            if ($device.DriveLetter) {
                $suspiciousFiles = Get-ChildItem "$($device.DriveLetter):\" -Include "*.exe", "*.bat", "*.cmd" -ErrorAction SilentlyContinue | Select-Object -First 5
                
                if ($suspiciousFiles) {
                    Write-Host "   ⚠️ Found executable files:" -ForegroundColor Red
                    $suspiciousFiles | Select-Object Name | Format-Table -AutoSize
                } else {
                    Write-Host "   ✅ No executables in root" -ForegroundColor Green
                }
            }
        }
    } else {
        Write-Host "✅ No removable USB devices currently connected" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Could not scan USB devices" -ForegroundColor Red
}

Write-Host ""

# Check USB device event logs (last 24 hours)
Write-Host "Recent USB Device Events (Last 24 Hours):" -ForegroundColor Cyan
$startTime = (Get-Date).AddDays(-1)

try {
    # Event ID 2003 = USB device plugged in
    # Event ID 2100/2102 = USB device removal
    $usbEvents = Get-WinEvent -FilterHashtable @{
        LogName="System"
        ID=2003,2100,2102
        StartTime=$startTime
    } -ErrorAction SilentlyContinue
    
    if ($usbEvents) {
        Write-Host "⚠️ Recent USB activity detected:" -ForegroundColor Yellow
        foreach ($event in $usbEvents | Select-Object -First 10) {
            $eventType = switch ($event.Id) {
                2003 { "USB Connected" }
                2100 { "USB Disconnected" }
                2102 { "USB Removed" }
                default { "USB Activity" }
            }
            Write-Host "   $($event.TimeCreated) - $eventType" -ForegroundColor Yellow
        }
    } else {
        Write-Host "✅ No recent USB device events" -ForegroundColor Green
    }
} catch {
    Write-Host "ℹ️ USB event logs not available or accessible" -ForegroundColor Gray
}

Write-Host ""

# Check for USB storage policy
Write-Host "USB Storage Policy Check:" -ForegroundColor Cyan
try {
    $usbPolicy = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR" -Name "Start" -ErrorAction SilentlyContinue
    
    if ($usbPolicy) {
        $status = switch ($usbPolicy.Start) {
            3 { "Enabled (Manual)" }
            4 { "Disabled" }
            default { "Unknown ($($usbPolicy.Start))" }
        }
        Write-Host "   USB Storage Service: $status" -ForegroundColor Cyan
        
        if ($usbPolicy.Start -eq 4) {
            Write-Host "   ✅ USB storage is disabled (secure)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ USB storage is enabled (potential risk)" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "   ℹ️ Could not check USB policy" -ForegroundColor Gray
}

# Quick check for common debug devices (fast)
Write-Host ""
Write-Host "Quick Debug Device Check:" -ForegroundColor Cyan
$debugKeywords = @("ADB", "Debug", "Arduino", "Development")
$foundDebug = $false

foreach ($keyword in $debugKeywords) {
    if (Get-Process "*$keyword*" -ErrorAction SilentlyContinue) {
        Write-Host "⚠️ $keyword process detected" -ForegroundColor Yellow
        $foundDebug = $true
    }
}

if (-not $foundDebug) {
    Write-Host "✅ No debug processes detected" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "USB device security scan complete." -ForegroundColor White
Write-Host "Monitor any YELLOW (warnings) or RED (threats) above." -ForegroundColor Yellow