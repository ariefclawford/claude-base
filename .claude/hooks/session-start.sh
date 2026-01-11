#!/bin/bash
# ============================================
# Claude Code Session Start Hook
# Runs when a new Claude Code session begins
# ============================================

# Colors (if terminal supports them)
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
else
    GREEN=''
    BLUE=''
    YELLOW=''
    NC=''
fi

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}     ${GREEN}Claude Code Session Started${NC}            ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Project info
PROJECT_NAME=$(basename "$(pwd)")
echo -e "${GREEN}Project:${NC} $PROJECT_NAME"
echo -e "${GREEN}Time:${NC}    $(date '+%Y-%m-%d %H:%M:%S')"

# Git status (if in a git repo)
if [ -d ".git" ]; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        echo -e "${GREEN}Branch:${NC}  $BRANCH"
    fi

    # Show if there are uncommitted changes
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
        echo -e "${YELLOW}Status:${NC}  Uncommitted changes detected"
    fi
fi

echo ""
echo -e "${BLUE}Quick Commands:${NC}"
echo "  /hello   - Verify commands work"
echo "  /commit  - Create conventional commit"
echo "  /review  - Review code changes"
echo ""

exit 0
