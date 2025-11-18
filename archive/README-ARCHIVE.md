# Archive Directory

**Purpose:** Scripts that were created but decided NOT to use
**Reason:** These scripts go against project philosophy

---

## Files In Archive

### install-monitoring-tools.sh
**Created:** 2025-11-16
**Purpose:** Bulk installer for 20+ Linux monitoring packages
**Why Archived:** Goes against anti-bloat philosophy

**Problem:**
- Installs 20+ tools at once (creates bloat!)
- No user feedback on what's actually needed
- Opposite of our careful, one-at-a-time approach

**Decision:**
- DO NOT USE this script
- Instead: Install tools one-by-one, only when specific need identified
- User approval required for each tool

**Philosophy:**
We fight bloat, we don't create it. This script was a mistake - it would add bloat just like the Windows bloatware we removed (Widgets, SearchHost, etc.).

**Correct Approach:**
1. Identify specific need ("I want to check network usage")
2. Install ONE tool (`sudo apt install nethogs`)
3. Try it for a week
4. User decides: keep or remove
5. Only then consider next tool

---

**If you need monitoring tools:** See LINUX-MONITORING-TOOLS.md for reference of available tools, then install individually as needed.

**Last Updated:** 2025-11-17
