# ============================================
# Claude Code Command Logger Hook
# Logs all Bash commands for audit purposes
# Use with PreToolUse event
# ============================================

# Read JSON input from stdin
$InputJson = $input | Out-String

try {
    $InputData = $InputJson | ConvertFrom-Json
    $Tool = $InputData.tool

    # Only log Bash commands
    if ($Tool -eq "Bash") {
        $Command = $InputData.input.command
        $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        # Ensure log directory exists
        $LogDir = ".claude/logs"
        if (-not (Test-Path $LogDir)) {
            New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
        }

        # Append to log file
        $LogEntry = "[$Timestamp] $Command"
        Add-Content -Path "$LogDir/commands.log" -Value $LogEntry
    }
} catch {
    # If JSON parsing fails, just continue silently
}

# Always exit 0 to allow the command to proceed
# Exit 1 would block the command
exit 0
