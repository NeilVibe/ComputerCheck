# Toggle Riot Vanguard (vgk) On/Off
# Quick script to enable/disable Vanguard for gaming

Write-Host "=== RIOT VANGUARD TOGGLE ===" -ForegroundColor Cyan

# Check current status
$vgkStatus = sc query vgk 2>$null
$vgkConfig = sc qc vgk 2>$null

if ($vgkStatus -match "RUNNING" -or $vgkConfig -match "START_TYPE.*SYSTEM") {
    Write-Host "`nVanguard is currently: ENABLED" -ForegroundColor Yellow
    Write-Host "Games work: YES (Valorant, League)" -ForegroundColor Green
    Write-Host ""

    $choice = Read-Host "Disable Vanguard for better performance? (y/n)"
    if ($choice -eq 'y') {
        sc config vgk start=disabled | Out-Null
        Write-Host "`n✓ Vanguard DISABLED" -ForegroundColor Green
        Write-Host "REBOOT REQUIRED to apply changes" -ForegroundColor Red
        Write-Host "After reboot: Games won't work, but better performance" -ForegroundColor Yellow
    } else {
        Write-Host "No changes made." -ForegroundColor Gray
    }
} else {
    Write-Host "`nVanguard is currently: DISABLED" -ForegroundColor Yellow
    Write-Host "Games work: NO (Valorant, League won't start)" -ForegroundColor Red
    Write-Host ""

    $choice = Read-Host "Enable Vanguard for gaming? (y/n)"
    if ($choice -eq 'y') {
        sc config vgk start=system | Out-Null
        Write-Host "`n✓ Vanguard ENABLED" -ForegroundColor Green
        Write-Host "REBOOT REQUIRED to apply changes" -ForegroundColor Red
        Write-Host "After reboot: Games will work" -ForegroundColor Yellow
    } else {
        Write-Host "No changes made." -ForegroundColor Gray
    }
}

Write-Host "`n==========================" -ForegroundColor Cyan
pause
