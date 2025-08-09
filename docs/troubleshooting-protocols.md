# Troubleshooting Protocols - Systematic Issue Resolution

## Case Study: Black Screen at Startup (2025-01-09)

### Problem Statement
User reported: "Computer stayed on black screen for too long during startup, desktop seemed loaded but screen was black"

### Initial Confusion Points
1. First attempt to check event logs failed (syntax/encoding issues)
2. Too broad initial search scope
3. Needed to understand the project structure first

### Successful Resolution Protocol

#### Phase 1: Understanding the Environment
- **Read project documentation** (README.md) to understand available tools
- **Identify the right tool** (MegaManager.ps1) for comprehensive scanning
- **Learn tool capabilities** before using

#### Phase 2: Systematic Investigation
1. **Check for security events** (Event 7045 - service installations found)
2. **Scan memory usage** (Normal at 17%, ruled out memory issues)
3. **Review startup programs** (Found multiple security software)
4. **Look for malware** (None found - ruled out)
5. **Focus on time-specific events** (Last 10-15 minutes)

#### Phase 3: Root Cause Analysis
- **Key Finding**: Event ID 7011 - Service timeout errors
- **Pattern Recognition**: ArmouryCrateService timing out repeatedly
- **Time Correlation**: Multiple 30-second timeouts = 4+ minute delay
- **Impact Assessment**: Service failed but accomplished nothing

#### Phase 4: Solution Implementation
1. **Verify the service is non-critical**
2. **Get user confirmation**
3. **Execute fix** (Disable service)
4. **Verify changes**

### Key Learnings

#### What Worked
- Using project's built-in tools (MegaManager)
- Checking time-specific events rather than general logs
- Looking for ERROR level events specifically
- Following the timeout pattern to identify root cause

#### Event IDs to Remember
- **7011**: Service timeout (critical for startup delays)
- **7045**: New service installation (security indicator)
- **4625**: Failed logon attempts (security)
- **6008**: Unexpected shutdown

### Reusable PowerShell Commands

```powershell
# Check recent errors and warnings
Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2,3; StartTime=(Get-Date).AddMinutes(-15)} | Select-Object TimeCreated, ProviderName, Id, LevelDisplayName, Message | Format-List

# Check specific service status
Get-Service -Name "ServiceName" | Select-Object Name, Status, StartType

# Disable problematic service
Stop-Service -Name "ServiceName" -Force
Set-Service -Name "ServiceName" -StartupType Disabled
```

### Protocol Template for Future Issues

1. **Define the problem clearly**
   - When did it happen?
   - What was the symptom?
   - How long did it last?

2. **Use MegaManager for initial scan**
   ```bash
   ./MegaManager.ps1 monitoring dangerous-events
   ./MegaManager.ps1 performance memory
   ./MegaManager.ps1 security registry-startup
   ./MegaManager.ps1 security registry-audit
   ```

3. **Check time-specific events**
   - Focus on the exact timeframe of the issue
   - Look for ERROR and WARNING level events
   - Identify patterns (repeated errors)

4. **Correlate findings**
   - Match symptoms to errors
   - Identify service/process names
   - Check if timing aligns

5. **Verify before fixing**
   - Is the service/process essential?
   - What does it actually do?
   - Can it be safely disabled?

### Common Startup Delay Culprits
- **ArmouryCrateService** (ASUS RGB/monitoring)
- **Banking/Security software** (CrossEX, IPinside)
- **Cloud sync services** (OneDrive, Dropbox)
- **Antivirus full scans** at startup
- **Windows Update** post-restart tasks

### Success Metrics
- **Issue Identified**: ✅ Found ArmouryCrateService timeout
- **Root Cause Found**: ✅ Service hanging during initialization
- **Solution Applied**: ✅ Service disabled
- **User Satisfaction**: ✅ Problem solved, learned something

---

## For Claude/AI Systems: Learning Points

### Pattern Recognition
- Multiple 30-second timeouts = service hanging issue
- Black screen with loaded desktop = service blocking display initialization
- Event 7011 cluster = problematic service at startup

### Diagnostic Approach Evolution
1. Started too broad → Narrowed to specific timeframe
2. Started with complex commands → Simplified to working syntax
3. Started with assumptions → Used systematic elimination

### User Communication
- Explain findings in simple terms
- Show the evidence (event logs)
- Confirm before making changes
- Provide reversal instructions

### Tool Selection
- Use project's custom tools when available
- MegaManager.ps1 > individual scripts
- PowerShell native commands for verification

This protocol should be followed for any "computer acting strange" scenarios.

## Registry Analysis Protocol (NEW)

### When to Use Registry Analysis:
- **System slowdowns** with unknown cause
- **Mysterious startup programs** appearing
- **Software installation/uninstallation issues**
- **Security concerns** about system modifications
- **After malware removal** to check for persistence
- **Regular maintenance** (monthly recommended)

### Registry Analysis Commands:
```bash
# Quick registry health check
./MegaManager.ps1 security registry-audit

# Export detailed report
./MegaManager.ps1 security registry-audit -Export

# Focus on startup entries only
./MegaManager.ps1 security registry-startup
```

### Registry Analysis Interpretation:

#### **Startup Entries:**
- **[SAFE]** - Known good software (Microsoft, NVIDIA, Steam, etc.)
- **[UNKNOWN]** - Needs review (could be legitimate 3rd party software)
- **[SUSPICIOUS]** - High risk (temp folders, unusual locations)

#### **Registry Health:**
- **Orphaned Keys:** >20 = cleanup recommended
- **Empty Keys:** >50 = minor cleanup benefit  
- **Invalid References:** Any count = investigate

#### **Security Issues:**
- **Critical Issues:** >0 = immediate investigation required
- **Shell Modifications:** Always critical
- **Suspicious Services:** Investigate paths in temp/appdata folders

### Common Registry Issues Found:

#### **Startup Bloatware:**
- CrossEX, Interezen (Korean banking software)
- Expired trial software auto-starting
- Old gaming software overlays
- Unnecessary manufacturer utilities

#### **Orphaned Entries:**
- Uninstalled software leaving registry traces
- Broken file path references
- Empty installation folders still registered

#### **Security Red Flags:**
- Shell replaced (not explorer.exe)
- Services running from temp folders
- Unknown startup entries in suspicious locations
- Modified system policy settings

### Registry Cleanup Actions:

#### **Safe to Remove:**
- Orphaned uninstall entries (>6 months old)
- Startup entries for uninstalled software
- Empty registry keys with no subkeys/values
- Broken file path references

#### **Investigate Before Removing:**
- Unknown startup programs
- Services with unusual paths
- Modified system settings
- Recent registry changes

#### **Never Remove:**
- Windows system entries
- Active driver entries  
- Currently installed software entries
- Security software entries (unless confirmed malware)

### Registry Analysis Success Patterns:
- **Startup delays** → Check for banking/security software conflicts
- **Random crashes** → Look for orphaned driver entries
- **Performance issues** → Investigate startup program overload
- **Security concerns** → Focus on shell/winlogon modifications