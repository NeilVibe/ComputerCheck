# MEGA MANAGER - Controls All Security Tools
# Organized by classes, tested, no confusion!

param(
    [string]$Class = "help",
    [string]$Tool = "",
    [string]$Action = "",
    [switch]$List = $false
)

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host @"
╔══════════════════════════════════════╗
║          MEGA MANAGER v1.0           ║
║    Master Controller for All Tools   ║
╚══════════════════════════════════════╝
"@ -ForegroundColor Cyan

function Test-ScriptExists {
    param([string]$Path)
    if (Test-Path $Path) {
        Write-Host "✅ $Path" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ $Path" -ForegroundColor Red
        return $false
    }
}

function Run-CategoryScript {
    param(
        [string]$Category,
        [string]$ScriptName,
        [string]$Parameters = ""
    )
    
    $scriptPath = "$ScriptPath\categories\$Category\$ScriptName"
    
    if (Test-Path $scriptPath) {
        Write-Host "`n🚀 Running: $ScriptName" -ForegroundColor Yellow
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        
        if ($Parameters) {
            & $scriptPath $Parameters.Split(' ')
        } else {
            & $scriptPath
        }
        
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        Write-Host "✅ Completed: $ScriptName`n" -ForegroundColor Green
    } else {
        Write-Host "❌ Script not found: $scriptPath" -ForegroundColor Red
    }
}

switch ($Class.ToLower()) {
    "help" {
        Write-Host @"

USAGE: .\MegaManager.ps1 <class> [tool] [action]

CLASSES:
  security     - Security scanning and analysis tools
  performance  - Memory and performance monitoring
  monitoring   - Event log and system monitoring
  utilities    - Helper tools and basic functions (NEW: D drive management!)
  test         - Test all tools are working
  list         - List all available tools

EXAMPLES:
  .\MegaManager.ps1 security comprehensive
  .\MegaManager.ps1 performance memory
  .\MegaManager.ps1 monitoring events
  .\MegaManager.ps1 utilities check-drive
  .\MegaManager.ps1 utilities release-drive
  .\MegaManager.ps1 test
  .\MegaManager.ps1 list

NEW D DRIVE TOOLS:
  .\MegaManager.ps1 utilities check-drive       # Check what's using D drive
  .\MegaManager.ps1 utilities check-drive-ties  # Find hidden locks
  .\MegaManager.ps1 utilities release-drive     # Release all locks

"@ -ForegroundColor White
    }
    
    "security" {
        Write-Host "`nSECURITY CLASS" -ForegroundColor Red
        
        if ($List) {
            Write-Host "Available security tools:" -ForegroundColor Yellow
            Write-Host "  comprehensive    - Full system security scan"
            Write-Host "  deep-process     - Advanced process analysis"
            Write-Host "  safe-events      - Security event monitoring"
            Write-Host "  registry-startup - Registry malware detection"
            Write-Host "  registry-audit   - Comprehensive registry health audit"
            Write-Host "  system-files     - System file integrity check"
            Write-Host "  original         - Original security checker"
            return
        }
        
        switch ($Tool.ToLower()) {
            "comprehensive" { 
                Run-CategoryScript "security" "comprehensive-security-check.ps1" $Action
            }
            "deep-process" { 
                Run-CategoryScript "security" "deep-process-check.ps1" $Action
            }
            "safe-events" { 
                Run-CategoryScript "security" "safe-event-monitor.ps1" $Action
            }
            "registry-startup" { 
                Run-CategoryScript "security" "registry-startup-check.ps1" $Action
            }
            "registry-audit" { 
                Run-CategoryScript "security" "registry-comprehensive-audit.ps1" $Action
            }
            "system-files" { 
                Run-CategoryScript "security" "system-file-monitor.ps1" $Action
            }
            "original" { 
                Run-CategoryScript "security" "check_security.ps1" $Action
            }
            "" {
                Write-Host "Available security tools:" -ForegroundColor Yellow
                Write-Host "  comprehensive, deep-process, safe-events, registry-startup, registry-audit, system-files, original"
                Write-Host "Example: .\MegaManager.ps1 security comprehensive"
            }
            default {
                Write-Host "Unknown security tool: $Tool" -ForegroundColor Red
                Write-Host "Use: .\MegaManager.ps1 security list"
            }
        }
    }
    
    "performance" {
        Write-Host "`nPERFORMANCE CLASS" -ForegroundColor Green
        
        if ($List) {
            Write-Host "Available performance tools:" -ForegroundColor Yellow
            Write-Host "  memory    - Memory usage analysis"
            Write-Host "  vmmem     - WSL/VM memory check"
            return
        }
        
        switch ($Tool.ToLower()) {
            "memory" { 
                Run-CategoryScript "performance" "memory-usage-check.ps1" $Action
            }
            "vmmem" { 
                Run-CategoryScript "performance" "check-vmmem.ps1" $Action
            }
            "" {
                Write-Host "Available performance tools:" -ForegroundColor Yellow
                Write-Host "  memory, vmmem"
                Write-Host "Example: .\MegaManager.ps1 performance memory"
            }
            default {
                Write-Host "Unknown performance tool: $Tool" -ForegroundColor Red
            }
        }
    }
    
    "monitoring" {
        Write-Host "`nMONITORING CLASS" -ForegroundColor Blue
        
        if ($List) {
            Write-Host "Available monitoring tools:" -ForegroundColor Yellow
            Write-Host "  powershell-events  - PowerShell execution monitoring (4104)"
            Write-Host "  powershell-simple  - Simple PowerShell event check"
            Write-Host "  event-levels       - Event level analysis"
            Write-Host "  dangerous-events   - Critical security events"
            Write-Host "  usb-devices        - USB device security monitoring"
            return
        }
        
        switch ($Tool.ToLower()) {
            "powershell-events" { 
                Run-CategoryScript "monitoring" "check-4104-events.ps1" $Action
            }
            "powershell-simple" { 
                Run-CategoryScript "monitoring" "check-4104-simple.ps1" $Action
            }
            "event-levels" { 
                Run-CategoryScript "monitoring" "check-event-levels.ps1" $Action
            }
            "dangerous-events" { 
                Run-CategoryScript "monitoring" "dangerous-event-ids.ps1" $Action
            }
            "usb-devices" { 
                Run-CategoryScript "monitoring" "usb-device-monitor.ps1" $Action
            }
            "" {
                Write-Host "Available monitoring tools:" -ForegroundColor Yellow
                Write-Host "  powershell-events, powershell-simple, event-levels, dangerous-events, usb-devices"
                Write-Host "Example: .\MegaManager.ps1 monitoring powershell-events"
            }
            default {
                Write-Host "Unknown monitoring tool: $Tool" -ForegroundColor Red
            }
        }
    }
    
    "utilities" {
        Write-Host "`nUTILITIES CLASS" -ForegroundColor Magenta

        if ($List) {
            Write-Host "Available utility tools:" -ForegroundColor Yellow
            Write-Host "  test-admin       - Test admin privileges"
            Write-Host "  security-mgr     - Simple security manager"
            Write-Host "  check-drive      - Check what's using a drive (D: by default)"
            Write-Host "  check-drive-ties - Find hidden Windows locks on drive"
            Write-Host "  release-drive    - Release all Windows locks on drive"
            return
        }

        switch ($Tool.ToLower()) {
            "test-admin" {
                Run-CategoryScript "utilities" "test-admin.ps1" $Action
            }
            "security-mgr" {
                Run-CategoryScript "utilities" "SecurityManager.ps1" $Action
            }
            "check-drive" {
                $scriptPath = "$ScriptPath\check-d-drive.ps1"
                if (Test-Path $scriptPath) {
                    Write-Host "`n🚀 Checking Drive Usage" -ForegroundColor Yellow
                    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
                    & $scriptPath
                    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
                } else {
                    Write-Host "❌ Script not found: $scriptPath" -ForegroundColor Red
                }
            }
            "check-drive-ties" {
                $scriptPath = "$ScriptPath\check-d-drive-hidden-ties.ps1"
                if (Test-Path $scriptPath) {
                    Write-Host "`n🚀 Checking Hidden Drive Locks" -ForegroundColor Yellow
                    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
                    & $scriptPath
                    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
                } else {
                    Write-Host "❌ Script not found: $scriptPath" -ForegroundColor Red
                }
            }
            "release-drive" {
                $scriptPath = "$ScriptPath\release-d-drive.ps1"
                if (Test-Path $scriptPath) {
                    Write-Host "`n🚀 Releasing Drive Locks" -ForegroundColor Yellow
                    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
                    & $scriptPath
                    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
                } else {
                    Write-Host "❌ Script not found: $scriptPath" -ForegroundColor Red
                }
            }
            "" {
                Write-Host "Available utility tools:" -ForegroundColor Yellow
                Write-Host "  test-admin, security-mgr, check-drive, check-drive-ties, release-drive"
                Write-Host "Example: .\MegaManager.ps1 utilities check-drive"
            }
            default {
                Write-Host "Unknown utility tool: $Tool" -ForegroundColor Red
            }
        }
    }
    
    "test" {
        Write-Host "`n🧪 TESTING ALL TOOLS" -ForegroundColor Yellow
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        Write-Host "`nSECURITY TOOLS:" -ForegroundColor Red
        Test-ScriptExists "$ScriptPath\categories\security\comprehensive-security-check.ps1"
        Test-ScriptExists "$ScriptPath\categories\security\deep-process-check.ps1"
        Test-ScriptExists "$ScriptPath\categories\security\safe-event-monitor.ps1"
        Test-ScriptExists "$ScriptPath\categories\security\registry-startup-check.ps1"
        Test-ScriptExists "$ScriptPath\categories\security\system-file-monitor.ps1"
        Test-ScriptExists "$ScriptPath\categories\security\check_security.ps1"
        
        Write-Host "`nPERFORMANCE TOOLS:" -ForegroundColor Green
        Test-ScriptExists "$ScriptPath\categories\performance\memory-usage-check.ps1"
        Test-ScriptExists "$ScriptPath\categories\performance\check-vmmem.ps1"
        
        Write-Host "`nMONITORING TOOLS:" -ForegroundColor Blue
        Test-ScriptExists "$ScriptPath\categories\monitoring\check-4104-events.ps1"
        Test-ScriptExists "$ScriptPath\categories\monitoring\check-4104-simple.ps1"
        Test-ScriptExists "$ScriptPath\categories\monitoring\check-event-levels.ps1"
        Test-ScriptExists "$ScriptPath\categories\monitoring\dangerous-event-ids.ps1"
        Test-ScriptExists "$ScriptPath\categories\monitoring\usb-device-monitor.ps1"
        
        Write-Host "`nUTILITY TOOLS:" -ForegroundColor Magenta
        Test-ScriptExists "$ScriptPath\categories\utilities\test-admin.ps1"
        Test-ScriptExists "$ScriptPath\categories\utilities\SecurityManager.ps1"
        
        Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        Write-Host "🎯 All tools inventory complete!" -ForegroundColor Cyan
    }
    
    "list" {
        Write-Host "`n📋 ALL AVAILABLE TOOLS" -ForegroundColor White
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        Write-Host "`nSECURITY - 7 tools:" -ForegroundColor Red
        Write-Host "   comprehensive, deep-process, safe-events, registry-startup, registry-audit, system-files, original"
        
        Write-Host "`nPERFORMANCE - 2 tools:" -ForegroundColor Green
        Write-Host "   memory, vmmem"
        
        Write-Host "`nMONITORING - 5 tools:" -ForegroundColor Blue
        Write-Host "   powershell-events, powershell-simple, event-levels, dangerous-events, usb-devices"
        
        Write-Host "`nUTILITIES - 2 tools:" -ForegroundColor Magenta
        Write-Host "   test-admin, security-mgr"
        
        Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        Write-Host "Total: 16 organized tools" -ForegroundColor Cyan
    }
    
    default {
        Write-Host "Unknown class: $Class" -ForegroundColor Red
        Write-Host "Use: .\MegaManager.ps1 help"
    }
}