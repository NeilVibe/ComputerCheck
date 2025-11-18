Write-Host "=== WSL SERVICE STATUS CHECK ===" -ForegroundColor Cyan
Write-Host ""

# Check WSLService
$wslService = Get-Service -Name "WSLService" -ErrorAction SilentlyContinue
if ($wslService) {
    Write-Host "WSLService Status:" -ForegroundColor Yellow
    Write-Host "  Name: $($wslService.Name)"
    Write-Host "  Status: $($wslService.Status)" -ForegroundColor $(if($wslService.Status -eq 'Running'){'Green'}else{'Red'})
    Write-Host "  StartType: $($wslService.StartType)" -ForegroundColor $(if($wslService.StartType -eq 'Automatic'){'Yellow'}else{'Green'})
    Write-Host ""
    
    if ($wslService.StartType -eq 'Automatic') {
        Write-Host "[PROBLEM] WSLService is set to Automatic startup!" -ForegroundColor Red
        Write-Host "This causes 30-second timeout delays during boot." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "WHY THIS HAPPENS:" -ForegroundColor Cyan
        Write-Host "- WSL doesn't need to start at boot" -ForegroundColor White
        Write-Host "- It competes with other services for resources" -ForegroundColor White
        Write-Host "- When system is busy, WSL can't initialize in 30 seconds" -ForegroundColor White
        Write-Host "- Windows logs Event 7011 and continues booting" -ForegroundColor White
        Write-Host ""
        Write-Host "RECOMMENDED FIX:" -ForegroundColor Green
        Write-Host "Set-Service -Name 'WSLService' -StartupType Manual" -ForegroundColor White
        Write-Host "(WSL will start automatically when you use it)" -ForegroundColor Gray
    } else {
        Write-Host "[OK] WSLService is set to Manual/Disabled" -ForegroundColor Green
        Write-Host "It will start on-demand when needed." -ForegroundColor Gray
    }
} else {
    Write-Host "WSLService not found (WSL may not be installed)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== OTHER RELATED SERVICES ===" -ForegroundColor Cyan
# Check other services that might delay boot
$services = @(
    @{Name="LxssManager"; Description="WSL Manager"},
    @{Name="vmcompute"; Description="Hyper-V Host Compute"},
    @{Name="WinDefend"; Description="Windows Defender"}
)

foreach ($svc in $services) {
    $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
    if ($service) {
        $color = if($service.Status -eq 'Running'){'Green'}else{'Gray'}
        Write-Host "$($svc.Description): $($service.Status) (Startup: $($service.StartType))" -ForegroundColor $color
    }
}