# Git Upstream Branch Error - Solution

## The Error:
```
fatal: The current branch master has no upstream branch.
To push the current branch and set the remote as upstream, use
    git push --set-upstream origin master
```

## Possible Causes:

### 1. Branch Name Mismatch
- **Local**: master
- **Remote**: might expect main
- **Modern repos**: use main as default

### 2. WSL + Permission Issues
- `.git/config.lock` permission errors
- Upstream tracking gets corrupted
- sudo vs non-sudo git commands

### 3. Git Configuration Issues
- Upstream branch tracking lost between pushes
- Remote origin configuration problems

## SOLUTION APPLIED:

### ✅ Fixed: Switched to MAIN branch
- **Problem**: Remote repo expects `main`, we were using `master`
- **Solution**: Switched local branch to `main`
- **Commands used**:
```bash
# Check remote default branch
gh repo view --json defaultBranchRef  # Returns: main

# Set full permissions
sudo chmod -R 777 .git/

# Force push to main 
git push origin main --force
```

## Other Solutions:

### Option 1: Always Use Full Command
```bash
# Instead of: git push
# Always use:
git push origin main
```

### Option 3: Reset Upstream Tracking
```bash
git branch --set-upstream-to=origin/master master
```

### Option 4: Fix Permissions First
```bash
chmod 777 .git/config
git push --set-upstream origin master
```

## Best Practice:
Just use explicit branch names in commands to avoid tracking issues:
```bash
git push origin master  # or main
```