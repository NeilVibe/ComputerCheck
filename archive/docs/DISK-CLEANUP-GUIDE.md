# Disk Cleanup Guide - Find & Remove Space Wasters

**Your WSL Ubuntu uses 405GB (43% of E: drive). Let's find what's taking space and clean it up safely.**

---

## 🔍 **STEP 1: Quick Overview** (2 minutes)

### Run the Space Sniffer
```bash
cd ~/CheckComputer
./space-sniffer.sh
```

**What to look for:**
- Largest top-level directories on E:
- Ubuntu WSL total size
- Top 10 largest files
- Recycle Bin size
- Log/temp files

**Quick wins you might find:**
- Full Recycle Bin (empty it!)
- Old downloads (delete if not needed)
- Huge log files (can usually delete)

---

## 🕵️ **STEP 2: WSL Content Analysis** (5 minutes)

### Deep dive into what's IN your WSL
```bash
./analyze-wsl-contents.sh
```

**What this reveals:**
- Your home directory breakdown (which folders are biggest?)
- /var size (logs, apt cache)
- Docker data (if you use Docker)
- File type analysis (lots of videos? zips? ISOs?)

**Common space wasters in WSL:**
- `~/.cache` - Application caches (often HUGE!)
- `/var/log` - System logs (can grow to GBs)
- `/var/cache/apt` - Old package downloads
- `~/Downloads` - Forgotten downloads
- Docker images (`/var/lib/docker`)
- Conda/pip caches (if you use Python)
- Old project builds (node_modules, venv, etc.)

---

## 🎮 **STEP 3: Interactive Exploration** (As long as you want!)

### Use ncdu to explore interactively

**Start with your home directory:**
```bash
ncdu ~
```

**Navigate and find big folders:**
- Press **Enter** to dive into a folder
- Press **d** to delete (CAREFUL!)
- Press **q** to go back/quit

**Check common suspects:**
```bash
ncdu ~/.cache        # Application caches (SAFE to delete!)
ncdu ~/Downloads     # Old downloads
ncdu ~/Projects      # Old projects with build artifacts
ncdu ~/.local        # User-installed software
```

**Check system directories (need sudo):**
```bash
sudo ncdu /var       # Logs, apt cache
sudo ncdu /usr       # Installed software
sudo ncdu /tmp       # Temporary files
```

---

## 🧹 **STEP 4: Safe Cleanup Commands**

### Clear APT Package Cache (Safe!)
```bash
# Check size first
du -sh /var/cache/apt/archives

# Clean it (safe, can always re-download packages)
sudo apt clean
```

**Expected savings:** 100MB - 1GB

### Clear User Cache (Mostly Safe!)
```bash
# Check size first
du -sh ~/.cache

# Clean specific apps (examples)
rm -rf ~/.cache/pip              # Python pip cache
rm -rf ~/.cache/thumbnails       # Image thumbnails
rm -rf ~/.cache/mozilla          # Firefox cache
rm -rf ~/.cache/google-chrome    # Chrome cache

# OR clear entire cache (can cause apps to rebuild caches)
# Only if you're sure!
# rm -rf ~/.cache/*
```

**Expected savings:** 500MB - 10GB (depends on usage)

### Clear System Logs (Safe!)
```bash
# Check log size
sudo du -sh /var/log

# Clear old logs (keeps recent ones)
sudo journalctl --vacuum-time=7d    # Keep only last 7 days
sudo journalctl --vacuum-size=100M  # Or limit to 100MB

# Clear specific log files (if huge)
sudo truncate -s 0 /var/log/syslog
sudo truncate -s 0 /var/log/kern.log
```

**Expected savings:** 100MB - 2GB

### Remove Old Kernels (If many installed)
```bash
# Check installed kernels
dpkg -l | grep linux-image

# Keep only current kernel, remove old ones
sudo apt autoremove --purge
```

**Expected savings:** 500MB - 2GB per old kernel

### Docker Cleanup (If you use Docker)
```bash
# Check Docker disk usage
docker system df

# Remove unused images/containers/volumes
docker system prune -a --volumes

# WARNING: This removes ALL unused Docker data!
```

**Expected savings:** 1GB - 50GB+ (if you have lots of images)

### Conda/Pip Cleanup (If you use Python)
```bash
# Conda cache
conda clean --all

# Pip cache
pip cache purge

# Remove old conda environments you don't use
conda env list
conda env remove -n old_environment_name
```

**Expected savings:** 500MB - 10GB

### Node.js Cleanup (If you develop JS/TS)
```bash
# Find all node_modules folders (can be HUGE!)
find ~ -name "node_modules" -type d -prune -exec du -sh {} \;

# Remove node_modules from old projects
# Example:
# rm -rf ~/old-project/node_modules
```

**Expected savings:** 100MB - 20GB per project!

---

## 🗂️ **STEP 5: Find & Remove Large Files**

### Find largest files in your home
```bash
# Top 20 largest files
find ~ -type f -exec du -h {} + 2>/dev/null | sort -hr | head -20
```

**Common large files to check:**
- `.iso` files (Linux/Windows images) - 1-5GB each
- `.vdi` / `.vhdx` files (Virtual machines) - 10-50GB each
- `.zip` / `.tar.gz` (Archives you already extracted) - varies
- Videos (`.mp4`, `.mkv`, `.avi`) - 1-10GB each
- Database dumps (`.sql`, `.dump`) - varies
- Old backups - varies

**Delete if not needed:**
```bash
# Example (BE CAREFUL - verify path first!)
rm ~/Downloads/old-backup.zip
```

---

## 📊 **STEP 6: Identify Project Bloat**

### Common development bloat

**Python projects:**
```bash
# Find all virtual environments
find ~ -name "venv" -o -name ".venv" -o -name "env" 2>/dev/null

# Find all __pycache__ directories
find ~ -name "__pycache__" -type d 2>/dev/null

# Remove from old projects
# rm -rf ~/old-project/venv
# find ~/old-project -name "__pycache__" -type d -exec rm -rf {} +
```

**Node.js projects:**
```bash
# Find all node_modules
find ~ -name "node_modules" -type d -prune 2>/dev/null

# Remove from old projects
# rm -rf ~/old-project/node_modules
```

**Build artifacts:**
```bash
# Find build directories
find ~ -name "build" -o -name "dist" -o -name "target" -type d 2>/dev/null

# Remove from old projects
# rm -rf ~/old-project/build
```

---

## 🎯 **STEP 7: Reclaim Space on E: Drive (Windows Side)**

### Empty Recycle Bin
```powershell
# From PowerShell
powershell.exe -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
```

### Check for large files on E: (outside WSL)
```bash
# Use space-sniffer on E: drive
./space-sniffer.sh /mnt/e
```

**Look for:**
- Old backups in E:\Backups
- Duplicate files
- Old downloads
- Temporary game files

---

## 🚨 **SAFETY RULES - READ THIS!**

### ✅ SAFE to delete:
- `/var/cache/apt/archives/*` - Package cache (can re-download)
- `~/.cache/*` - User caches (apps will rebuild)
- Old logs in `/var/log` (keep recent 7 days)
- Docker images you don't use
- node_modules from OLD projects you don't work on
- Old virtual environments (venv, .venv)
- Recycle Bin contents
- Duplicate files you know about

### ⚠️ BE CAREFUL with:
- Database files (`.db`, `.sqlite`, `.sql`)
- Configuration files (`.config`, dotfiles)
- SSH keys (`~/.ssh`)
- Important documents
- Active project files

### ❌ NEVER delete:
- System directories (`/bin`, `/lib`, `/etc`, `/boot`)
- Your current project's dependencies
- Files you're not sure about
- Running application data

---

## 📋 **CLEANUP CHECKLIST**

**Quick Wins (Run these first):**
- [ ] Clear APT cache: `sudo apt clean`
- [ ] Clear pip cache: `pip cache purge`
- [ ] Vacuum journal logs: `sudo journalctl --vacuum-time=7d`
- [ ] Remove old kernels: `sudo apt autoremove --purge`
- [ ] Empty Recycle Bin (Windows)

**Check These:**
- [ ] `~/.cache` size - Clear if >5GB
- [ ] `/var/log` size - Truncate old logs if >2GB
- [ ] Docker images - Prune if you use Docker
- [ ] node_modules in old projects
- [ ] Python venv in old projects
- [ ] Old downloads in ~/Downloads

**Deep Clean (If needed):**
- [ ] Use ncdu to explore large directories
- [ ] Find and remove large files (ISOs, videos, archives)
- [ ] Remove old project builds
- [ ] Clean conda environments

---

## 📊 **BEFORE & AFTER**

### Before cleanup - Record current usage:
```bash
df -h | grep -E "/|/mnt/e"
```

Current usage:
- Linux (/): 367GB / 1007GB (39%)
- E: drive: 597GB / 932GB (64%)
- WSL ext4.vhdx: 405GB

### After cleanup - Check what you saved:
```bash
df -h | grep -E "/|/mnt/e"
```

**Target:** Free up 50-100GB (get WSL down to 300-350GB)

---

## 💡 **PREVENTION TIPS**

1. **Clean package cache monthly:**
   ```bash
   sudo apt clean && pip cache purge
   ```

2. **Limit journal log size permanently:**
   ```bash
   sudo journalctl --vacuum-size=500M
   # Edit /etc/systemd/journald.conf: SystemMaxUse=500M
   ```

3. **Remove old projects you don't use:**
   - Delete node_modules, venv before archiving
   - Zip and move to external storage

4. **Use Docker carefully:**
   - Run `docker system prune` monthly
   - Don't accumulate unused images

5. **Monitor monthly:**
   ```bash
   # Add to MONTHLY CHECKS
   ncdu ~ --exclude node_modules --exclude .cache
   ```

---

## 🎯 **MOST COMMON CULPRITS**

Based on typical WSL usage, your 405GB is likely:

1. **Development projects** (30-40%) - 120-160GB
   - node_modules (5-20GB per project!)
   - Python venv (1-5GB per project)
   - Build artifacts
   - Git clones

2. **Application caches** (10-20%) - 40-80GB
   - ~/.cache (pip, npm, browser, thumbnails)
   - /var/cache/apt

3. **Docker** (20-30%) - 80-120GB (if you use it)
   - Images, containers, volumes

4. **System files** (10-15%) - 40-60GB
   - Installed packages (/usr)
   - Logs (/var/log)

5. **User files** (10-20%) - 40-80GB
   - Downloads
   - Documents, videos, archives
   - Databases

**Start with #2 (caches) - easiest and safest to clean!**

---

**Last Updated:** 2025-11-20
**Target:** Free up 50-100GB from WSL
**Safety:** Always check size before deleting, can't undo!
