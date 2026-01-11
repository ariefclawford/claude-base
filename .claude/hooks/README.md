# Claude Code Hooks

Hooks are event-driven scripts that run automatically at specific points in Claude Code's lifecycle. They enable automation, validation, logging, and integration with external systems.

## When to Use Hooks

| Scenario | Use Hook? | Why |
|----------|-----------|-----|
| Log all commands | Yes | Audit trail via PostToolUse |
| Validate environment | Yes | SessionStart check |
| Block dangerous ops | Yes | PreToolUse policy |
| Send notifications | Yes | PostToolUse integration |
| Modify Claude behavior | No | Use rules or instructions instead |
| Complex workflows | No | Use skills instead |

**Rule of thumb:** Use hooks for **automation and validation** that should happen transparently.

---

## Hook Types

| Event | When Triggered | Input | Primary Use Cases |
|-------|----------------|-------|-------------------|
| `SessionStart` | Session begins | None | Environment validation, setup, welcome |
| `PreToolUse` | Before a tool executes | JSON | Validation, logging, blocking |
| `PostToolUse` | After a tool completes | JSON | Logging, notifications, cleanup |

---

## Quick Verification

Verify the hook system works with this minimal test:

### Unix/macOS/Linux

**1. Create** `.claude/hooks/test-hook.sh`:

```bash
#!/bin/bash
echo "Hook system is working!"
echo "Platform: $(uname -s)"
echo "Date: $(date)"
exit 0
```

**2. Make executable:**

```bash
chmod +x .claude/hooks/test-hook.sh
```

**3. Add to** `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "os:darwin",
        "hooks": [{"type": "command", "command": "bash .claude/hooks/test-hook.sh"}]
      },
      {
        "matcher": "os:linux",
        "hooks": [{"type": "command", "command": "bash .claude/hooks/test-hook.sh"}]
      }
    ]
  }
}
```

**4. Restart** Claude Code

**5. Verify** you see the hook output at session start

**6. Remove** the test hook and configuration

### Windows

**1. Create** `.claude/hooks/test-hook.ps1`:

```powershell
Write-Host "Hook system is working!"
Write-Host "Platform: Windows"
Write-Host "Date: $(Get-Date)"
exit 0
```

**2. Add to** `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "os:windows",
        "hooks": [{"type": "command", "command": "powershell -ExecutionPolicy Bypass -File .claude/hooks/test-hook.ps1"}]
      }
    ]
  }
}
```

**3. Restart** Claude Code and verify

---

## Hook Configuration

Hooks are configured in `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [...],
    "PreToolUse": [...],
    "PostToolUse": [...]
  }
}
```

### Configuration Structure

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "os:platform",
        "hooks": [
          {
            "type": "command",
            "command": "path/to/script"
          }
        ]
      }
    ]
  }
}
```

### OS Matchers

| Matcher | Platform |
|---------|----------|
| `os:windows` | Windows |
| `os:darwin` | macOS |
| `os:linux` | Linux |

---

## Input/Output Format

### SessionStart

- **Input:** None
- **Output:** stdout displayed to user

### PreToolUse / PostToolUse

Hooks receive JSON via **stdin**:

```json
{
  "tool": "Bash",
  "input": {
    "command": "npm install"
  }
}
```

Tool-specific input formats:

| Tool | Input Fields |
|------|--------------|
| `Bash` | `command` |
| `Read` | `file_path` |
| `Write` | `file_path`, `content` |
| `Edit` | `file_path`, `old_string`, `new_string` |
| `Glob` | `pattern` |
| `Grep` | `pattern`, `path` |

---

## Exit Codes

| Exit Code | Meaning | Effect |
|-----------|---------|--------|
| `0` | Success | Continue execution |
| `1` | Failure | **PreToolUse:** Block the operation |
| | | **PostToolUse:** Log error, continue |

### Blocking Operations

PreToolUse hooks can **block** operations by exiting with code 1:

```bash
#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.input.command // empty')

# Block rm -rf commands
if [[ "$COMMAND" == *"rm -rf"* ]]; then
  echo "BLOCKED: rm -rf commands are not allowed"
  exit 1
fi

exit 0
```

---

## Cross-Platform Configuration

Support all platforms with OS-specific matchers:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "os:windows",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -ExecutionPolicy Bypass -File .claude/hooks/session-start.ps1"
          }
        ]
      },
      {
        "matcher": "os:darwin",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/session-start.sh"
          }
        ]
      },
      {
        "matcher": "os:linux",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Examples

### Example 1: SessionStart - Environment Check

Verify required tools are installed:

**session-check.sh** (Unix):
```bash
#!/bin/bash

echo "=== Environment Check ==="

# Check Node.js
if command -v node &> /dev/null; then
  echo "[OK] Node.js: $(node --version)"
else
  echo "[WARN] Node.js not installed"
fi

# Check Git
if command -v git &> /dev/null; then
  echo "[OK] Git: $(git --version | cut -d' ' -f3)"
else
  echo "[ERROR] Git not installed"
  exit 1
fi

# Check for required files
if [ -f "package.json" ]; then
  echo "[OK] package.json found"
else
  echo "[INFO] No package.json (not a Node project)"
fi

echo "========================="
exit 0
```

**session-check.ps1** (Windows):
```powershell
Write-Host "=== Environment Check ==="

# Check Node.js
try {
  $nodeVersion = node --version
  Write-Host "[OK] Node.js: $nodeVersion"
} catch {
  Write-Host "[WARN] Node.js not installed"
}

# Check Git
try {
  $gitVersion = git --version
  Write-Host "[OK] Git: $gitVersion"
} catch {
  Write-Host "[ERROR] Git not installed"
  exit 1
}

# Check for required files
if (Test-Path "package.json") {
  Write-Host "[OK] package.json found"
} else {
  Write-Host "[INFO] No package.json (not a Node project)"
}

Write-Host "========================="
exit 0
```

---

### Example 2: PreToolUse - Command Logging

Log all Bash commands for audit:

**log-commands.sh** (Unix):
```bash
#!/bin/bash

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool')

# Only log Bash commands
if [ "$TOOL" = "Bash" ]; then
  COMMAND=$(echo "$INPUT" | jq -r '.input.command')
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

  # Ensure log directory exists
  mkdir -p .claude/logs

  # Append to log file
  echo "[$TIMESTAMP] $COMMAND" >> .claude/logs/commands.log
fi

exit 0
```

**log-commands.ps1** (Windows):
```powershell
$input = $input | ConvertFrom-Json
$tool = $input.tool

if ($tool -eq "Bash") {
  $command = $input.input.command
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

  # Ensure log directory exists
  New-Item -ItemType Directory -Force -Path ".claude/logs" | Out-Null

  # Append to log file
  Add-Content -Path ".claude/logs/commands.log" -Value "[$timestamp] $command"
}

exit 0
```

**Configuration:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "os:darwin",
        "hooks": [{"type": "command", "command": "bash .claude/hooks/log-commands.sh"}]
      },
      {
        "matcher": "os:linux",
        "hooks": [{"type": "command", "command": "bash .claude/hooks/log-commands.sh"}]
      },
      {
        "matcher": "os:windows",
        "hooks": [{"type": "command", "command": "powershell -ExecutionPolicy Bypass -File .claude/hooks/log-commands.ps1"}]
      }
    ]
  }
}
```

---

### Example 3: PreToolUse - Policy Enforcement

Block certain patterns:

**policy-check.sh**:
```bash
#!/bin/bash

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool')

if [ "$TOOL" = "Bash" ]; then
  COMMAND=$(echo "$INPUT" | jq -r '.input.command')

  # Block production database access
  if [[ "$COMMAND" == *"DATABASE_URL"*"production"* ]]; then
    echo "BLOCKED: Direct production database access is not allowed"
    echo "Use staging environment or request access through proper channels"
    exit 1
  fi

  # Block force push
  if [[ "$COMMAND" == *"git push"*"--force"* ]] || [[ "$COMMAND" == *"git push"*"-f"* ]]; then
    echo "BLOCKED: Force push is not allowed"
    echo "Please use regular push or rebase workflow"
    exit 1
  fi

  # Warn about dangerous commands (but allow)
  if [[ "$COMMAND" == *"rm -r"* ]]; then
    echo "WARNING: Recursive delete detected - proceeding with caution"
  fi
fi

exit 0
```

---

### Example 4: PostToolUse - Notifications

Send notification after deployment:

**notify-deploy.sh**:
```bash
#!/bin/bash

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool')

if [ "$TOOL" = "Bash" ]; then
  COMMAND=$(echo "$INPUT" | jq -r '.input.command')

  # Check if this was a deploy command
  if [[ "$COMMAND" == *"deploy"* ]] || [[ "$COMMAND" == *"kubectl apply"* ]]; then
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    USER=$(whoami)

    # Log deployment
    echo "[$TIMESTAMP] Deployment executed by $USER" >> .claude/logs/deployments.log

    # Optional: Send to Slack webhook (uncomment and configure)
    # curl -X POST -H 'Content-type: application/json' \
    #   --data "{\"text\":\"Deployment executed by $USER at $TIMESTAMP\"}" \
    #   $SLACK_WEBHOOK_URL

    echo "Deployment logged"
  fi
fi

exit 0
```

---

## Best Practices

### Do

- **Keep hooks fast** — They block execution
- **Handle errors gracefully** — Don't crash on unexpected input
- **Use exit codes correctly** — 0 = success, 1 = failure
- **Make scripts executable** — `chmod +x` on Unix
- **Log meaningful information** — Include timestamps
- **Support all platforms** — Provide both .sh and .ps1

### Don't

- **Long-running operations** — Hooks should be quick
- **Ignore exit codes** — They control flow
- **Forget cross-platform** — Test on target platforms
- **Store secrets in scripts** — Use environment variables
- **Block everything** — Be surgical with PreToolUse blocks

---

## Security Considerations

### Permissions
- Hooks run with **user permissions**
- Can access environment variables
- Can read/write files user can access

### Sensitive Data
- **Don't** log sensitive data (passwords, tokens)
- **Don't** hardcode secrets in hook scripts
- **Do** use environment variables for credentials
- **Do** sanitize logged data

### Validation
- Validate JSON input before processing
- Handle malformed input gracefully
- Don't trust input blindly

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Hook not running | Not configured | Check settings.json hooks section |
| Permission denied | Not executable | `chmod +x script.sh` (Unix) |
| Script blocked | PowerShell policy | `Set-ExecutionPolicy RemoteSigned` |
| Wrong platform | Matcher mismatch | Verify `os:` matcher matches your OS |
| Hook errors | Script bug | Test script manually first |
| JSON parse error | Invalid input | Check jq/ConvertFrom-Json usage |
| Hook blocks everything | Exit code wrong | Ensure `exit 0` for success |

### Testing Hooks Manually

**Test SessionStart hook:**
```bash
# Unix
bash .claude/hooks/your-hook.sh

# Windows
powershell -File .claude/hooks/your-hook.ps1
```

**Test PreToolUse/PostToolUse hook:**
```bash
# Unix
echo '{"tool": "Bash", "input": {"command": "npm install"}}' | bash .claude/hooks/your-hook.sh

# Windows
'{"tool": "Bash", "input": {"command": "npm install"}}' | powershell -File .claude/hooks/your-hook.ps1
```

---

## Common Patterns

| Pattern | Hook Type | Use Case |
|---------|-----------|----------|
| Environment validation | SessionStart | Verify tools installed |
| Welcome message | SessionStart | Display project info |
| Command audit | PreToolUse | Log all commands |
| Policy enforcement | PreToolUse | Block dangerous operations |
| File access logging | PreToolUse | Track file reads/writes |
| Deployment notification | PostToolUse | Alert on deploys |
| Error tracking | PostToolUse | Log failures |
| Cleanup | PostToolUse | Remove temp files |

---

## Platform Setup

### Unix/macOS/Linux

Make hook scripts executable:

```bash
chmod +x .claude/hooks/*.sh
```

### Windows

If PowerShell blocks scripts:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Line Endings

Ensure correct line endings (configured in `.gitattributes`):
- `.sh` files: LF (Unix)
- `.ps1` files: CRLF (Windows)

If hooks fail after cloning on Windows:
```bash
git add --renormalize .
```

---

## References

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Claude Code Settings](https://docs.anthropic.com/en/docs/claude-code/settings)
- [Claude Code CLI Reference](https://docs.anthropic.com/en/docs/claude-code/cli)
