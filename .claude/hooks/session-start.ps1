# ============================================
# Claude Code Session Start Hook
# Runs when a new Claude Code session begins
# ============================================

Write-Host ""
Write-Host "=====================================" -ForegroundColor Blue
Write-Host "   Claude Code Session Started" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Blue
Write-Host ""

# Project info
$ProjectName = Split-Path -Leaf (Get-Location)
Write-Host "Project: " -NoNewline -ForegroundColor Green
Write-Host $ProjectName

Write-Host "Time:    " -NoNewline -ForegroundColor Green
Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss")

# Git status (if in a git repo)
if (Test-Path ".git") {
    try {
        $Branch = git branch --show-current 2>$null
        if ($Branch) {
            Write-Host "Branch:  " -NoNewline -ForegroundColor Green
            Write-Host $Branch
        }

        # Check for uncommitted changes
        $Status = git status --porcelain 2>$null
        if ($Status) {
            Write-Host "Status:  " -NoNewline -ForegroundColor Yellow
            Write-Host "Uncommitted changes detected" -ForegroundColor Yellow
        }
    } catch {
        # Git not available or error - ignore
    }
}

Write-Host ""
Write-Host "Quick Commands:" -ForegroundColor Blue
Write-Host "  /hello   - Verify commands work"
Write-Host "  /commit  - Create conventional commit"
Write-Host "  /review  - Review code changes"
Write-Host ""

exit 0
