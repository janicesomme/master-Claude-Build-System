# setup-worktree.ps1
# Creates an isolated git worktree for a build task
#
# Usage: 
#   .\scripts\setup-worktree.ps1 -TaskId "001" -TaskName "user-auth"
#   .\scripts\setup-worktree.ps1 -TaskId "001" -TaskName "user-auth" -Parallel 3

param(
    [Parameter(Mandatory=$true)]
    [string]$TaskId,
    
    [Parameter(Mandatory=$true)]
    [string]$TaskName,
    
    [Parameter(Mandatory=$false)]
    [int]$Parallel = 1
)

$ErrorActionPreference = "Stop"

# Validate we're in a git repo
if (-not (Test-Path ".git")) {
    Write-Error "Not in a git repository. Please run from your project root."
    exit 1
}

# Ensure we have at least one commit
$commitCount = git rev-list --count HEAD 2>$null
if (-not $commitCount -or $commitCount -eq "0") {
    Write-Error "Git repository needs at least one commit before creating worktrees."
    exit 1
}

# Create .worktrees directory if it doesn't exist
if (-not (Test-Path ".worktrees")) {
    New-Item -ItemType Directory -Path ".worktrees" | Out-Null
    Write-Host "Created .worktrees directory" -ForegroundColor Green
}

# Create spec directory if it doesn't exist
$specDir = "specs\$TaskId-$TaskName"
if (-not (Test-Path $specDir)) {
    New-Item -ItemType Directory -Path $specDir -Force | Out-Null
    Write-Host "Created spec directory: $specDir" -ForegroundColor Green
}

if ($Parallel -eq 1) {
    # Single worktree
    $worktreePath = ".worktrees\$TaskId-$TaskName"
    $branchName = "auto-claude/$TaskId-$TaskName"
    
    if (Test-Path $worktreePath) {
        Write-Warning "Worktree already exists at $worktreePath"
    } else {
        Write-Host "Creating worktree: $worktreePath" -ForegroundColor Cyan
        git worktree add $worktreePath -b $branchName
        Write-Host "✅ Worktree created successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "  1. Start a FRESH Claude Code session (context reset!)"
        Write-Host "  2. cd $worktreePath"
        Write-Host "  3. cat ../specs/current/implementation-plan.md"
        Write-Host "  4. Type /code to begin implementing"
    }
} else {
    # Parallel worktrees
    Write-Host "Creating $Parallel parallel worktrees..." -ForegroundColor Cyan
    
    for ($i = 1; $i -le $Parallel; $i++) {
        $worktreePath = ".worktrees\$TaskId-subtask-$i"
        $branchName = "auto-claude/$TaskId-subtask-$i"
        
        if (Test-Path $worktreePath) {
            Write-Warning "Worktree already exists at $worktreePath"
        } else {
            git worktree add $worktreePath -b $branchName
            Write-Host "✅ Created: $worktreePath" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Write-Host "Parallel worktrees created!" -ForegroundColor Green
    Write-Host ""
    Write-Host "IMPORTANT: Start each agent in a FRESH Claude Code session!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Next steps (run each in a separate terminal):" -ForegroundColor Yellow
    for ($i = 1; $i -le $Parallel; $i++) {
        Write-Host "  Terminal $i`:"
        Write-Host "    cd .worktrees\$TaskId-subtask-$i"
        Write-Host "    cat ../specs/current/implementation-plan.md"
        Write-Host "    # Then: /code and specify subtask $i"
    }
}

Write-Host ""
Write-Host "Spec directory: $specDir" -ForegroundColor Cyan
