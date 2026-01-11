#!/bin/bash
# ============================================
# Claude Code Command Logger Hook
# Logs all Bash commands for audit purposes
# Use with PreToolUse event
# ============================================

# Read JSON input from stdin
INPUT=$(cat)

# Parse tool name
TOOL=$(echo "$INPUT" | jq -r '.tool // empty')

# Only log Bash commands
if [ "$TOOL" = "Bash" ]; then
    COMMAND=$(echo "$INPUT" | jq -r '.input.command // empty')
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    # Ensure log directory exists
    mkdir -p .claude/logs

    # Append to log file
    echo "[$TIMESTAMP] $COMMAND" >> .claude/logs/commands.log
fi

# Always exit 0 to allow the command to proceed
# Exit 1 would block the command
exit 0
