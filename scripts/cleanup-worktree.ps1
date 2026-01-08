# cleanup-worktree.ps1
# Merges completed worktree(s) and cleans up
# Usage: .\scripts\cleanup-worktree.ps1 -Spec "001-my-feature" -Action merge
# Usage: .\scripts\cleanup-worktree.ps1 -Spec "001-my-feature" -Action discard

param(
    [Parameter(Mandatory=$true)]
    [string]$Spec,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("merge", "discard")]
    [string]$Action
)

$ErrorActionPreference = "Stop"

# Validate we're in a git repo root
if (-not (Test-Path ".git")) {
    Write-Host "Error: Not in a git repository root" -ForegroundColor Red
    exit 1
}

$WorktreesDir = ".worktrees"

# Find all worktrees for this spec
$Worktrees = Get-ChildItem -Path $WorktreesDir -Directory -ErrorAction SilentlyContinue | 
    Where-Object { $_.Name -match "^$Spec" }

if (-not $Worktrees) {
    Write-Host "No worktrees found for spec: $Spec" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Found $($Worktrees.Count) worktree(s) for spec: $Spec" -ForegroundColor Cyan
Write-Host ""

foreach ($Worktree in $Worktrees) {
    $WorktreePath = $Worktree.FullName
    $BranchName = "auto-claude/$($Worktree.Name)"
    
    Write-Host "Processing: $($Worktree.Name)" -ForegroundColor White
    
    if ($Action -eq "merge") {
        # Check for uncommitted changes
        Push-Location $WorktreePath
        $Status = git status --porcelain
        Pop-Location
        
        if ($Status) {
            Write-Host "  Warning: Uncommitted changes in worktree!" -ForegroundColor Yellow
            Write-Host "  Please commit or discard changes first." -ForegroundColor Yellow
            Write-Host "  Run: cd $WorktreePath && git add . && git commit -m 'final changes'" -ForegroundColor Gray
            continue
        }
        
        # Merge the branch
        Write-Host "  Merging $BranchName..." -ForegroundColor Gray
        $MergeResult = git merge $BranchName --no-edit 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  Merge conflict! Please resolve manually:" -ForegroundColor Red
            Write-Host "    git mergetool" -ForegroundColor Gray
            Write-Host "    git commit" -ForegroundColor Gray
            continue
        }
        
        Write-Host "  Merged successfully!" -ForegroundColor Green
    }
    
    # Remove worktree
    Write-Host "  Removing worktree..." -ForegroundColor Gray
    git worktree remove $WorktreePath --force 2>&1 | Out-Null
    
    # Delete branch
    Write-Host "  Deleting branch..." -ForegroundColor Gray
    git branch -D $BranchName 2>&1 | Out-Null
    
    Write-Host "  Cleaned up!" -ForegroundColor Green
    Write-Host ""
}

if ($Action -eq "merge") {
    Write-Host "All worktrees merged and cleaned up." -ForegroundColor Green
    Write-Host ""
    Write-Host "Your changes are now on the main branch." -ForegroundColor Cyan
    Write-Host "Review with: git log --oneline -10" -ForegroundColor Gray
} else {
    Write-Host "All worktrees discarded." -ForegroundColor Yellow
    Write-Host "No changes were merged." -ForegroundColor Gray
}

Write-Host ""
