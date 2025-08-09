# Comprehensive Registry Audit Tool
# Purpose: Full registry health analysis and security audit

param(
    [switch]$Export,
    [switch]$Quick
)

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "  COMPREHENSIVE REGISTRY AUDITOR   " -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date
$reportData = @{}
$issues = @()

function Analyze-StartupEntries {
    Write-Host "ANALYZING STARTUP ENTRIES" -ForegroundColor Yellow
    Write-Host "--------------------" -ForegroundColor Gray
    
    $startupLocations = @(
        @{Path="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; Name="System Run"},
        @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; Name="User Run"},
        @{Path="HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"; Name="32bit Run"}
    )
    
    $analysis = @{
        TotalEntries = 0
        SuspiciousEntries = 0
        SafeEntries = 0
        Details = @()
    }
    
    $knownSafe = @("*Windows*", "*Microsoft*", "*Intel*", "*NVIDIA*", "*Steam*")
    $suspicious = @("*temp*", "*downloads*", "*public*", "*appdata\local\temp*")
    
    foreach ($location in $startupLocations) {
        if (Test-Path $location.Path) {
            try {
                $entries = Get-ItemProperty $location.Path -ErrorAction SilentlyContinue
                if ($entries) {
                    $entries.PSObject.Properties | Where-Object { $_.Name -notlike "PS*" } | ForEach-Object {
                        $analysis.TotalEntries++
                        
                        $isSafe = $false
                        $isSuspicious = $false
                        
                        foreach ($pattern in $knownSafe) {
                            if ($_.Value -like $pattern) {
                                $analysis.SafeEntries++
                                $isSafe = $true
                                break
                            }
                        }
                        
                        if (-not $isSafe) {
                            foreach ($pattern in $suspicious) {
                                if ($_.Value -like $pattern) {
                                    $analysis.SuspiciousEntries++
                                    $isSuspicious = $true
                                    $script:issues += "SUSPICIOUS STARTUP: $($_.Name)"
                                    Write-Host "  [SUSPICIOUS] $($_.Name) -> $($_.Value)" -ForegroundColor Red
                                    break
                                }
                            }
                        }
                        
                        if (-not $isSafe -and -not $isSuspicious) {
                            Write-Host "  [UNKNOWN] $($_.Name) -> $($_.Value)" -ForegroundColor Yellow
                        } elseif ($isSafe) {
                            Write-Host "  [SAFE] $($_.Name)" -ForegroundColor Green
                        }
                    }
                }
            } catch {
                Write-Host "  Warning: Could not access $($location.Path)" -ForegroundColor Red
            }
        }
    }
    
    Write-Host ""
    Write-Host "STARTUP SUMMARY:" -ForegroundColor Green
    Write-Host "  Total Entries: $($analysis.TotalEntries)" -ForegroundColor White
    Write-Host "  Safe Entries: $($analysis.SafeEntries)" -ForegroundColor Green
    Write-Host "  Suspicious: $($analysis.SuspiciousEntries)" -ForegroundColor Red
    Write-Host ""
    
    $script:reportData.StartupAnalysis = $analysis
}

function Analyze-RegistryHealth {
    Write-Host "ANALYZING REGISTRY HEALTH" -ForegroundColor Yellow
    Write-Host "--------------------" -ForegroundColor Gray
    
    $health = @{
        OrphanedKeys = 0
        EmptyKeys = 0
        Issues = @()
    }
    
    # Check uninstall entries for orphaned programs
    $uninstallPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    if (Test-Path $uninstallPath) {
        try {
            $uninstallKeys = Get-ChildItem $uninstallPath -ErrorAction SilentlyContinue | Select-Object -First 15
            foreach ($key in $uninstallKeys) {
                $props = Get-ItemProperty $key.PSPath -ErrorAction SilentlyContinue
                if ($props -and $props.PSObject.Properties.Name -contains "InstallLocation") {
                    if ($props.InstallLocation -and -not (Test-Path $props.InstallLocation -ErrorAction SilentlyContinue)) {
                        $health.OrphanedKeys++
                    }
                }
            }
            Write-Host "  Checked uninstall entries for orphaned programs" -ForegroundColor Cyan
        } catch {
            Write-Host "  Warning: Could not check uninstall entries" -ForegroundColor Yellow
        }
    }
    
    # Check for empty registry keys
    $testPaths = @("HKCU:\SOFTWARE\Classes", "HKLM:\SOFTWARE\Classes")
    foreach ($path in $testPaths) {
        if (Test-Path $path) {
            try {
                $subKeys = Get-ChildItem $path -ErrorAction SilentlyContinue | Select-Object -First 5
                foreach ($key in $subKeys) {
                    $hasSubKeys = (Get-ChildItem $key.PSPath -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0
                    $hasValues = (Get-ItemProperty $key.PSPath -ErrorAction SilentlyContinue | Get-Member -MemberType NoteProperty | Where-Object {$_.Name -notlike "PS*"} | Measure-Object).Count -gt 0
                    
                    if (-not $hasSubKeys -and -not $hasValues) {
                        $health.EmptyKeys++
                    }
                }
            } catch {
                # Continue on error
            }
        }
    }
    
    Write-Host ""
    Write-Host "REGISTRY HEALTH SUMMARY:" -ForegroundColor Green
    Write-Host "  Orphaned Keys: $($health.OrphanedKeys)" -ForegroundColor $(if($health.OrphanedKeys -gt 10) {"Red"} else {"Green"})
    Write-Host "  Empty Keys: $($health.EmptyKeys)" -ForegroundColor $(if($health.EmptyKeys -gt 20) {"Yellow"} else {"Green"})
    Write-Host ""
    
    $script:reportData.HealthAnalysis = $health
}

function Analyze-SecuritySettings {
    Write-Host "ANALYZING SECURITY SETTINGS" -ForegroundColor Yellow
    Write-Host "--------------------" -ForegroundColor Gray
    
    $security = @{
        CriticalIssues = 0
        SuspiciousServices = 0
        Issues = @()
    }
    
    # Check Windows logon settings
    $winlogonPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    if (Test-Path $winlogonPath) {
        try {
            $winlogon = Get-ItemProperty $winlogonPath -ErrorAction SilentlyContinue
            if ($winlogon -and $winlogon.PSObject.Properties.Name -contains "Shell") {
                if ($winlogon.Shell -ne "explorer.exe") {
                    $security.CriticalIssues++
                    $security.Issues += "Shell modified to: $($winlogon.Shell)"
                    $script:issues += "CRITICAL: Windows Shell has been modified"
                    Write-Host "  [CRITICAL] Windows Shell modified: $($winlogon.Shell)" -ForegroundColor Red
                } else {
                    Write-Host "  [OK] Windows Shell: explorer.exe" -ForegroundColor Green
                }
            }
        } catch {
            Write-Host "  Warning: Could not check Winlogon settings" -ForegroundColor Yellow
        }
    }
    
    # Sample check for suspicious services
    $servicesPath = "HKLM:\SYSTEM\CurrentControlSet\Services"
    if (Test-Path $servicesPath) {
        try {
            $services = Get-ChildItem $servicesPath -ErrorAction SilentlyContinue | Select-Object -First 10
            $checkedServices = 0
            foreach ($service in $services) {
                $serviceProps = Get-ItemProperty $service.PSPath -ErrorAction SilentlyContinue
                if ($serviceProps -and $serviceProps.PSObject.Properties.Name -contains "ImagePath") {
                    $imagePath = $serviceProps.ImagePath
                    if ($imagePath -like "*temp*" -or $imagePath -like "*appdata*") {
                        $security.SuspiciousServices++
                        $script:issues += "SUSPICIOUS SERVICE: $($service.PSChildName)"
                        Write-Host "  [SUSPICIOUS] Service: $($service.PSChildName)" -ForegroundColor Red
                    }
                    $checkedServices++
                }
            }
            Write-Host "  Checked $checkedServices services for suspicious paths" -ForegroundColor Cyan
        } catch {
            Write-Host "  Warning: Could not check all services" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "SECURITY SUMMARY:" -ForegroundColor Green
    Write-Host "  Critical Issues: $($security.CriticalIssues)" -ForegroundColor $(if($security.CriticalIssues -gt 0) {"Red"} else {"Green"})
    Write-Host "  Suspicious Services: $($security.SuspiciousServices)" -ForegroundColor $(if($security.SuspiciousServices -gt 0) {"Red"} else {"Green"})
    Write-Host ""
    
    $script:reportData.SecurityAnalysis = $security
}

function Generate-Report {
    Write-Host "GENERATING RECOMMENDATIONS" -ForegroundColor Yellow
    Write-Host "--------------------" -ForegroundColor Gray
    
    $recommendations = @()
    
    if ($script:reportData.StartupAnalysis.SuspiciousEntries -gt 0) {
        $recommendations += "HIGH PRIORITY: Remove $($script:reportData.StartupAnalysis.SuspiciousEntries) suspicious startup entries"
    }
    
    if ($script:reportData.HealthAnalysis.OrphanedKeys -gt 15) {
        $recommendations += "CLEANUP: Remove $($script:reportData.HealthAnalysis.OrphanedKeys) orphaned registry keys"
    }
    
    if ($script:reportData.SecurityAnalysis.CriticalIssues -gt 0) {
        $recommendations += "CRITICAL: Investigate $($script:reportData.SecurityAnalysis.CriticalIssues) security issues immediately"
    }
    
    Write-Host "RECOMMENDATIONS:" -ForegroundColor Green
    if ($recommendations.Count -eq 0) {
        Write-Host "  Registry appears to be in good condition!" -ForegroundColor Green
    } else {
        $recommendations | ForEach-Object {
            Write-Host "  - $_" -ForegroundColor White
        }
    }
    Write-Host ""
    
    return $recommendations
}

# Main Execution
Write-Host "Starting comprehensive registry audit..." -ForegroundColor Green
Write-Host ""

Analyze-StartupEntries
Analyze-RegistryHealth  
Analyze-SecuritySettings
$recommendations = Generate-Report

# Export functionality
if ($Export) {
    $reportPath = "C:\Users\MYCOM\Desktop\CheckComputer\registry-audit-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"
    $reportContent = @"
COMPREHENSIVE REGISTRY AUDIT REPORT
Generated: $(Get-Date)

=== STARTUP ANALYSIS ===
Total Entries: $($script:reportData.StartupAnalysis.TotalEntries)
Safe Entries: $($script:reportData.StartupAnalysis.SafeEntries)  
Suspicious Entries: $($script:reportData.StartupAnalysis.SuspiciousEntries)

=== REGISTRY HEALTH ===
Orphaned Keys: $($script:reportData.HealthAnalysis.OrphanedKeys)
Empty Keys: $($script:reportData.HealthAnalysis.EmptyKeys)

=== SECURITY ANALYSIS ===
Critical Issues: $($script:reportData.SecurityAnalysis.CriticalIssues)
Suspicious Services: $($script:reportData.SecurityAnalysis.SuspiciousServices)

=== ISSUES FOUND ===
$(if ($script:issues.Count -gt 0) { $script:issues -join "`n" } else { "No critical issues found" })

=== RECOMMENDATIONS ===
$($recommendations -join "`n")
"@
    
    try {
        $reportContent | Out-File -FilePath $reportPath -Encoding UTF8
        Write-Host "Report exported to: $reportPath" -ForegroundColor Green
    } catch {
        Write-Host "Failed to export report: $_" -ForegroundColor Red
    }
}

# Final Summary
$endTime = Get-Date  
$duration = $endTime - $startTime

Write-Host "====================================" -ForegroundColor Green
Write-Host "         AUDIT COMPLETE            " -ForegroundColor Green  
Write-Host "====================================" -ForegroundColor Green
Write-Host "Duration: $([math]::Round($duration.TotalSeconds, 1)) seconds" -ForegroundColor Cyan
Write-Host "Issues Found: $($script:issues.Count)" -ForegroundColor $(if($script:issues.Count -gt 0) {"Red"} else {"Green"})
Write-Host "Recommendations: $($recommendations.Count)" -ForegroundColor $(if($recommendations.Count -gt 0) {"Yellow"} else {"Green"})

if ($script:issues.Count -eq 0) {
    Write-Host "Registry is healthy!" -ForegroundColor Green
} else {
    Write-Host "Registry needs attention" -ForegroundColor Yellow
}