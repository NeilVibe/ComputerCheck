# WSL UBUNTU SPACE ANALYSIS - UPDATED

**Initial Size:** 405GB
**Current Size:** ~359GB (after deletions)
**Space Freed:** 46GB
**Location:** E:\Ubuntu\UbuntuWSL\ext4.vhdx
**Last Updated:** 2025-10-25

---

## 🎉 CLEANUP COMPLETED

### ✅ Deleted (46GB Total)
- **46GB** - flan-t5 models (CONFIRMED UNUSED)
  - 42GB - flan-t5-xxl (not used since Sept 2023)
  - 3.0GB - flan-t5-large (not used since Sept 2023)
  - 948MB - flan-t5-base (not used since Aug 2023)

---

## EXECUTIVE SUMMARY (CURRENT STATE)

| Category | Original | Current | % of Total |
|----------|----------|---------|-----------|
| Your Home Directory | 235GB | ~189GB | 53% |
| Docker Storage | 154GB | 154GB | 43% |
| System Software | 19GB | 19GB | 5% |
| Other | <1GB | <1GB | <1% |
| **TOTAL** | **408GB** | **~362GB** | **100%** |

---

## TOP-LEVEL DIRECTORIES (CURRENT)

1. **~189GB** - `/home/neil1988` (YOUR PROJECTS & DATA) - Reduced from 235GB
2. **154GB** - `/var` (DOCKER STORAGE) - Unchanged
3. **19GB** - `/usr` (SYSTEM SOFTWARE) - Unchanged
4. **<1GB** - Everything else (tmp, etc, boot, root...)

---

## DETAILED BREAKDOWN (CURRENT)

### 1. YOUR HOME DIRECTORY (~189GB)

#### Python/AI Development (97GB)
- **57GB** - Python environments
  - 16GB - esrgan_env (last modified Feb 2025)
  - 11GB - test1 (last modified May 2024) ⚠️
  - 8.8GB - newfin_env
  - 8.3GB - fooocus
  - 8.2GB - fintest (last modified Apr 2025)
  - 373MB - fetch_env
  - Plus others
- **40GB** - Miniconda package cache (`~/miniconda3/pkgs`)

#### Hidden Caches (~47GB - Reduced from 93GB)
**Hugging Face AI Models: 16GB** (was 62GB)
- ~~**46GB** - flan-t5 models~~ ✅ **DELETED**
- **2.9GB** - `whisper-large-v3` (OpenAI voice model, June 2024)
- **1.9GB** - `m2m100_418M` (translation model, Sept 2023) ⚠️
- **893MB** - `KR-SBERT-V40K-klueNLI-augSTS` (Korean BERT, April 2025)
- **784MB** - `chronos-bolt-base` (time series, April 2025)
- Plus ~9GB of other models (emotion detection, speech recognition, etc.)

**Python Package Cache: 27GB**
- 18GB - pip http-v2 cache ⚠️
- 9.3GB - pip http cache ⚠️
- **Note:** Can be safely cleared and re-downloaded when needed

#### Fooocus AI Image Generation (33GB)
- **27GB** - Model checkpoints (actively used)
  - 6.7GB - juggernautXL_version6Rundiffusion.safetensors
  - 6.7GB - juggernautXL_v8Rundiffusion.safetensors
  - 6.5GB - realisticStockPhoto_v20.safetensors
  - 6.5GB - animaPencilXL_v310.safetensors
- **1.9GB** - clip_vision_vit_h.safetensors

#### Other Files (~12GB)
- **2.6GB** - `cuda-repo-wsl-ubuntu-11-8-local_11.8.0-1_amd64.deb` ⚠️ OLD INSTALLER (Sept 2022)
- **1.6GB** - pytorch-2.3.0 package
- **1.5GB** - pytorch-2.0.1 package
- Plus various smaller libraries and tools

#### Old Projects & Folders (~1GB)
- **462MB** - CityEmpire (Aug 2025 - KEEP)
- **295MB** - apex (Aug 2023) ⚠️
- **181MB** - DashVolleyBall ⚠️
- **136MB** - torch (Oct 2023) ⚠️
- **94MB** - discountstock ⚠️
- **71MB** - Stock-Prediction-Models (June 2024) ⚠️
- **45MB** - ParallelWaveGAN (Nov 2023) ⚠️
- **41MB** - lightning_logs (Sept 2024) ⚠️
- **26MB** - CycleGAN (Oct 2023) ⚠️
- Plus other small folders

---

### 2. DOCKER STORAGE (154GB)

**Docker Data Location:** `/var/lib/docker`

- **103GB** - Docker overlay2 (layered filesystems)
  - 10GB - Largest container layer
  - 7.5GB - Container merged filesystem
  - 7.1GB - Python 3.10 site-packages in container
- **39GB** - Docker volumes (persistent container data)

⚠️ **Potential cleanup:** `docker system prune -a --volumes` could reclaim significant space

---

### 3. SYSTEM SOFTWARE (19GB)

**Installation Location:** `/usr`

- **7.7GB** - CUDA 11.8 (GPU computing toolkit) - NEEDED
- **6.6GB** - WSL drivers - NEEDED
  - 2.5GB - NVIDIA display driver
  - 1.3GB - Intel graphics driver #1
  - 1.2GB - Intel graphics driver #2
- **2.0GB** - System libraries (x86_64-linux-gnu) - NEEDED
- **0.8GB** - 32-bit libraries (i386-linux-gnu)
- **0.6GB** - Shared files

---

## 🎯 RECOMMENDED NEXT CLEANUP STEPS

### 🟢 TIER 1: SUPER SAFE (Zero Risk) - **~30GB**

These are 100% safe to delete and can be re-downloaded if needed:

```bash
# 1. Clear pip cache (27GB) - Just cached downloads
rm -rf ~/.cache/pip

# 2. Delete old CUDA installer (2.6GB) - Already installed
rm ~/cuda-repo-wsl-ubuntu-11-8-local_11.8.0-1_amd64.deb

# 3. Delete old test report folders (43MB)
rm -rf ~/lightning_logs ~/TESTREPORT_fintestORIGINAL ~/SHORTREPORT ~/new_report
```

**Potential savings: 30GB**
**New total: 359GB → 329GB**

---

### 🟡 TIER 2: SAFE (Low Risk) - **~40GB**

```bash
# 4. Clean conda package cache (40GB)
# These are cached installers that can be re-downloaded
conda clean --all --yes
```

**Potential savings: 40GB**
**New total: 329GB → 289GB**

---

### 🟠 TIER 3: REVIEW FIRST (Medium Risk) - **~15GB**

**Old AI Models (unused since 2023):**
- `m2m100_418M` (1.9GB) - Translation, Sept 2023
- `t5-small` (233MB) - Text generation, Aug 2023
- `t5-v1_1-small` (295MB) - Text generation, Sept 2023
- `speecht5_vc` (592MB) - Voice conversion, Sept 2023
- `wav2vec2-base-960h` (361MB) - Speech recognition, Sept 2023
- `dangvantuan/sentence-camembert-base` (425MB) - French embeddings, Sept 2023

**Old Python Environments:**
- `test1` (11GB) - Last modified May 2024 ⚠️

**Old Projects:**
- apex (295MB), torch (136MB), DashVolleyBall (181MB), etc. (~1GB total)

```bash
# Delete old 2023 AI models (if not using)
rm -rf ~/.cache/huggingface/hub/models--facebook--m2m100_418M
rm -rf ~/.cache/huggingface/hub/models--t5-small
rm -rf ~/.cache/huggingface/hub/models--google--t5-v1_1-small
rm -rf ~/.cache/huggingface/hub/models--microsoft--speecht5_vc
rm -rf ~/.cache/huggingface/hub/models--facebook--wav2vec2-base-960h
rm -rf ~/.cache/huggingface/hub/models--dangvantuan--sentence-camembert-base

# Delete test1 environment (if not using)
conda env remove -n test1

# Delete old projects (if not using)
rm -rf ~/apex ~/torch ~/DashVolleyBall ~/discountstock
rm -rf ~/CycleGAN ~/ParallelWaveGAN ~/Stock-Prediction-Models
```

**Potential savings: ~15GB**

---

### 🔴 TIER 4: CAREFUL (High Risk) - **~103GB**

Only do these if you're SURE you don't need them:

```bash
# Docker cleanup - removes ALL unused containers, images, volumes
docker system prune -a --volumes

# WARNING: This will delete:
# - All stopped containers
# - All networks not used by at least one container
# - All volumes not used by at least one container
# - All images without at least one container associated to them
# - All build cache
```

**Potential savings: 50-100GB** (depends on what's unused)

---

## SUMMARY TABLE: CLEANUP POTENTIAL

| Tier | Risk | Items | Space | Running Total |
|------|------|-------|-------|---------------|
| Current | - | - | - | 359GB (after flan-t5) |
| Tier 1 | 🟢 Zero | Pip cache + CUDA installer + old reports | 30GB | 329GB |
| Tier 2 | 🟡 Low | Conda package cache | 40GB | 289GB |
| Tier 3 | 🟠 Medium | Old models + test1 env + old projects | 15GB | 274GB |
| Tier 4 | 🔴 High | Docker cleanup | ~50-100GB | 174-224GB |

**Maximum potential cleanup: ~135-185GB**
**Realistic safe cleanup (Tier 1+2): 70GB → Down to 289GB**

---

## TOP 20 LARGEST FILES (UPDATED)

| Rank | Size | File Path | Status |
|------|------|-----------|--------|
| ~~1-4~~ | ~~42GB~~ | ~~flan-t5-xxl blobs~~ | ✅ **DELETED** |
| ~~10~~ | ~~3.0GB~~ | ~~flan-t5-large~~ | ✅ **DELETED** |
| 1 | 6.7GB | `~/Fooocus/models/checkpoints/juggernautXL_version6Rundiffusion.safetensors` | Active |
| 2 | 6.7GB | `~/Fooocus/models/checkpoints/juggernautXL_v8Rundiffusion.safetensors` | Active |
| 3 | 6.5GB | `~/Fooocus/models/checkpoints/realisticStockPhoto_v20.safetensors` | Active |
| 4 | 6.5GB | `~/Fooocus/models/checkpoints/animaPencilXL_v310.safetensors` | Active |
| 5 | 2.9GB | `~/.cache/huggingface/hub/models--openai--whisper-large-v3/blobs/...` | 2024 |
| 6 | 2.6GB | `~/cuda-repo-wsl-ubuntu-11-8-local_11.8.0-1_amd64.deb` | ⚠️ Can delete |
| 7 | 2.1GB | `~/.cache/pip/http/3/9/f/0/2/39f02...` | ⚠️ Can delete |
| 8 | 1.9GB | `~/Fooocus/models/clip_vision/clip_vision_vit_h.safetensors` | Active |
| 9 | 1.9GB | `~/.cache/huggingface/hub/models--facebook--m2m100_418M/blobs/...` | ⚠️ 2023 |
| 10 | 1.8GB | `~/.cache/pip/http-v2/6/b/4/8/9/6b489...` | ⚠️ Can delete |
| 11-20 | Various | PyTorch libraries, conda packages, etc. | Mixed |

---

## ANALYSIS METHODOLOGY

- **Tool Used:** Custom bash script (`analyze-wsl-contents.sh`)
- **Initial Scan Date:** 2025-10-25
- **Last Update:** 2025-10-25 (after flan-t5 deletion)
- **Method:**
  - `du -h` for directory sizes
  - `stat` for last access/modify times
  - `grep` searches for code references
  - Manual verification of model usage
  - All deletions performed after confirming zero usage

---

## NOTES

- All file paths are relative to `/home/neil1988` unless otherwise specified
- Docker storage is in `/var/lib/docker`
- System files are in `/usr`
- WSL Ubuntu installation stores everything in a single `.vhdx` file on E: drive
- ⚠️ = Recommended for review/deletion
- ✅ = Already deleted

---

## CHANGE LOG

**2025-10-25 - Initial Analysis:**
- Total size: 405GB
- Identified flan-t5 models as unused (46GB)
- Created comprehensive cleanup recommendations

**2025-10-25 - First Cleanup:**
- ✅ Deleted all flan-t5 models (46GB)
- Verified zero code references to flan-t5
- Updated recommendations for next cleanup steps

---

**Generated by:** WSL Content Analyzer
**Status:** ACTIVELY MAINTAINED
**Next Review:** When ready for more cleanup
