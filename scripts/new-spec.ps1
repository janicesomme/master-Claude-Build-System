# new-spec.ps1
# Creates a new spec folder with the next sequential number
# Usage: .\scripts\new-spec.ps1 "my-feature-name"

param(
    [Parameter(Mandatory=$true)]
    [string]$Name
)

$ErrorActionPreference = "Stop"

# Sanitize the name
$SafeName = $Name.ToLower() -replace '[^a-z0-9-]', '-' -replace '-+', '-' -replace '^-|-$', ''

# Find the next spec number
$SpecsDir = "specs"
if (-not (Test-Path $SpecsDir)) {
    New-Item -ItemType Directory -Path $SpecsDir | Out-Null
    Write-Host "Created specs directory" -ForegroundColor Green
}

$ExistingSpecs = Get-ChildItem -Path $SpecsDir -Directory -ErrorAction SilentlyContinue | 
    Where-Object { $_.Name -match '^\d{3}-' } |
    ForEach-Object { [int]($_.Name -split '-')[0] }

if ($ExistingSpecs) {
    $NextNumber = ($ExistingSpecs | Measure-Object -Maximum).Maximum + 1
} else {
    $NextNumber = 1
}

$SpecId = "{0:D3}" -f $NextNumber
$FolderName = "$SpecId-$SafeName"
$FullPath = Join-Path $SpecsDir $FolderName

# Create the folder
New-Item -ItemType Directory -Path $FullPath | Out-Null

# Update specs/current to point to this spec
$CurrentPath = Join-Path $SpecsDir "current"
if (Test-Path $CurrentPath) {
    Remove-Item $CurrentPath -Force -Recurse -ErrorAction SilentlyContinue
}
# Create junction (Windows symlink alternative)
try {
    cmd /c mklink /J "$CurrentPath" "$FullPath" 2>$null | Out-Null
} catch {
    # If junction fails, just copy the path to a file
    Set-Content -Path (Join-Path $SpecsDir "current.txt") -Value $FullPath
}

# Create initial files
$SpecContent = @"
# $SpecId`: $Name

## Metadata
- **Created:** $(Get-Date -Format "yyyy-MM-dd")
- **Complexity:** [simple | standard | complex]
- **Estimated Subtasks:** [NUMBER]
- **Status:** draft

---

<!-- Run /start in Claude Code to begin the intake process -->
"@

Set-Content -Path (Join-Path $FullPath "spec.md") -Value $SpecContent

Write-Host ""
Write-Host "Created new spec folder: $FullPath" -ForegroundColor Green
Write-Host "Set as current spec" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Open Claude Code: claude"
Write-Host "  2. Type /start to begin the intake process"
Write-Host "  3. Answer the questions to build your project brief"
Write-Host ""
