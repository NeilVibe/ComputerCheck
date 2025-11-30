# Disk Cleanup Findings - WSL Ubuntu Analysis
**Date:** 2025-11-21
**Analysis Tool:** space-sniffer.sh + analyze-wsl-contents.sh
**Total WSL Size:** 405GB (on E:\Ubuntu\ext4.vhdx)

---

## Executive Summary

**Current Disk Usage:**
- **E: Drive Total:** 932GB capacity
- **E: Drive Used:** 597GB (64%)
- **WSL Ubuntu:** 405GB (68% of E: drive usage)
- **Other E: Drive:** 192GB

**Potential Cleanup:** **85-150GB** (depending on user decisions)

---

## 🔴 HIGH PRIORITY CLEANUP (Safe + Big Impact)

### 1. Python Package Caches - 35GB (SAFE TO DELETE)
**Location:** `~/.cache/pip`
**Size:** 35GB
**Risk:** None - packages automatically redownload when needed
**Command:** `rm -rf ~/.cache/pip`

**Why it's safe:**
- Pip downloads packages when installing, keeps cached copies
- If you reinstall package, it checks cache first (faster install)
- But accumulated 35GB of old versions over time
- Will NOT break any existing environments

### 2. Duplicate Conda Installation - 16GB
**Location:** `/mnt/e/minicondaaa`
**Size:** 16GB
**Risk:** None - it's a duplicate
**Command:** `rm -rf /mnt/e/minicondaaa`

**Why it's duplicate:**
- You have conda in WSL at `~/miniconda3` (97GB)
- This one on E: drive outside WSL is abandoned
- No environments using it

### 3. Ghost Backup Images - 34GB
**Location:** `/mnt/e/Ghost`
**Size:** 34GB
**Risk:** Medium - depends if you need old backups
**Command:** `rm -rf /mnt/e/Ghost`

**What it is:**
- Norton Ghost disk image backups
- Likely from old system or old Windows version
- Check creation date before deleting

**Recommended:** Check what's inside first with PowerShell from Windows

### 4. ML Model Caches - 18.3GB (Can Redownload)
**Locations:**
- `~/.cache/huggingface` - 16GB (ML models from Hugging Face)
- `~/.cache/torch` - 2.3GB (PyTorch cached models)

**Risk:** Low - models redownload automatically
**Commands:**
```bash
rm -rf ~/.cache/huggingface
rm -rf ~/.cache/torch
```

**Why it's OK to delete:**
- These are downloaded models (Stable Diffusion, transformers, etc.)
- When you run Fooocus or other ML tools, they redownload needed models
- First run after cleanup will be slower (downloading)
- But you get 18GB back immediately

### 5. Old Browser/App Caches - 2.7GB
**Locations:**
- `~/.cache/puppeteer` - 1.8GB (Chrome browser automation)
- `~/.cache/electron` - 852MB (Electron app builds)

**Risk:** Low
**Commands:**
```bash
rm -rf ~/.cache/puppeteer
rm -rf ~/.cache/electron
```

**Total High Priority Cleanup: ~106GB**

---

## 🟡 MEDIUM PRIORITY (Need User Decision)

### 6. Unused Conda Environments - 40-50GB potential

**Current Environments (9 total):**

| Environment | Size | Last Used? | Keep? |
|------------|------|------------|-------|
| `newfin_env` | 8.7GB | **Active - USER USES THIS** | ✅ KEEP |
| `esrgan_env` | 16GB | Image upscaling (ESRGAN AI) | ❓ Ask user |
| `test1` | 11GB | **Test environment** | ❌ LIKELY DELETE |
| `fintest` | 8.2GB | Finance testing | ❓ Duplicate of newfin? |
| `fooocus` | 8.3GB | Stable Diffusion images | ❓ If using Fooocus |
| `video_editor_env` | 5.1GB | Video editing | ❓ Ask user |
| `fetch_env` | 373MB | Small | ✅ Keep (small) |
| `ytdl_env` | 232MB | YouTube downloader | ✅ Keep (small) |
| `base` | ~40GB | Base conda | ✅ KEEP |

**Deletion Commands:**
```bash
# AFTER USER CONFIRMS - Don't run yet!
conda env remove -n test1           # 11GB
conda env remove -n fintest         # 8.2GB  (if duplicate)
conda env remove -n esrgan_env      # 16GB   (if not used)
conda env remove -n video_editor_env # 5.1GB (if not used)
```

**Questions for User:**
1. Do you still do image upscaling? (esrgan_env - 16GB)
2. Is fintest different from newfin_env? (8.2GB)
3. Do you edit videos? (video_editor_env - 5.1GB)
4. test1 is clearly for testing - safe to remove?

### 7. Fooocus Models - 32GB
**Location:** `~/Fooocus/models`
**Size:** 32GB
**Risk:** Medium - can redownload but slow

**What's inside:**
- Stable Diffusion checkpoints (5-8GB each)
- LoRA models
- VAE models
- Upscaling models

**Recommendation:**
- Keep models you actively use
- Delete old/experimental models
- Keep 1-2 favorite checkpoints
- Can save 15-20GB by cleaning old models

**Audit command:** (READ ONLY)
```bash
ls -lh ~/Fooocus/models/checkpoints/
du -sh ~/Fooocus/models/*/
```

---

## 🟢 LOW PRIORITY (Small but Clean)

### 8. Old Project Directories
**Small Projects (< 100MB each):**
- `~/CycleGAN` - 26MB (GAN training project)
- Various test directories

**Check for old code:**
```bash
# Find directories not modified in 6+ months
find ~ -maxdepth 1 -type d -mtime +180 -exec du -sh {} \;
```

---

## 🔍 INVESTIGATE

### 9. E:/DOWLOAD Folder - BROKEN
**Location:** `/mnt/e/DOWLOAD`
**Size:** Shows "Infinity" (filesystem error)
**Status:** Cannot analyze from WSL

**Possible Causes:**
1. Symlink loop (folder points to itself)
2. Permission issues (WSL can't read Windows folder)
3. Corrupted filesystem metadata
4. Junction point or reparse point

**Needs:** Windows PowerShell with admin rights (see WSL-WINDOWS-BRIDGE-STRATEGY.md)

### 10. Suspicious Folder
**Location:** `/mnt/e/@!imrFo`
**Size:** 1.5MB
**Status:** Weird name - might be malware remnant or corrupted

**Check from Windows:**
```powershell
Get-ChildItem "E:\@!imrFo" -Force
Get-ItemProperty "E:\@!imrFo"
```

---

## 📊 CLEANUP IMPACT SUMMARY

| Action | Space Saved | Risk | Effort |
|--------|-------------|------|--------|
| Clear pip cache | 35GB | None | 1 command |
| Delete E:/minicondaaa | 16GB | None | 1 command |
| Delete Ghost backups | 34GB | Low | Check first |
| Clear ML caches | 18GB | Low | 2 commands |
| Remove old browser caches | 2.7GB | None | 2 commands |
| **High Priority Total** | **~106GB** | **Low** | **10 minutes** |
| Remove unused conda envs | 25-40GB | Low | User decision |
| Clean Fooocus models | 15-20GB | Medium | Manual audit |
| **With Medium Priority** | **~150GB** | **Low-Med** | **1 hour** |

---

## 🛡️ SAFETY NOTES

**What WON'T Break:**
- Cache clearing - programs rebuild caches automatically
- Unused conda envs - other environments are isolated
- Old backups - if you have current backups elsewhere

**What to CHECK Before Deleting:**
- Ghost backups - might contain important old files
- Conda environments - confirm you don't use them
- Fooocus models - some take hours to download

**Backup Strategy:**
- Keep newfin_env (your active environment)
- Keep base conda environment
- Keep small environments (< 1GB) - not worth the risk

---

## 📋 RECOMMENDED CLEANUP ORDER

1. **Phase 1: Zero Risk (35GB)** - pip cache only
2. **Phase 2: Very Low Risk (53GB)** - duplicate conda + ML caches
3. **Phase 3: Low Risk (34GB)** - Ghost backups (after checking)
4. **Phase 4: User Decision (40GB)** - unused conda environments
5. **Phase 5: Manual Audit (20GB)** - Fooocus models

**Total Potential: ~182GB freed**

---

## 🔧 EXECUTION PLAN (Future)

When user approves, create:
1. `cleanup-phase1-safe.sh` - pip cache only
2. `cleanup-phase2-duplicates.sh` - E: drive duplicates
3. `cleanup-phase3-conda.sh` - remove specific environments
4. `cleanup-phase4-models.sh` - Fooocus model cleanup

Each script will:
- Show what it will delete
- Ask for confirmation
- Create deletion log
- Report space freed

---

**Next Steps:**
1. Review this document
2. User decides which conda envs to keep
3. Investigate E:/DOWLOAD issue (see bridge strategy doc)
4. Create safe cleanup scripts
5. Execute in phases

---

**Generated:** 2025-11-21 by CheckComputer Infrastructure Analysis
