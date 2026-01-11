# Getting Started with Claude Base

Welcome to Claude Base! This tutorial will walk you through all the features of Claude Code and help you verify everything is working correctly.

## Prerequisites

Before starting, ensure you have:
- Claude Code CLI installed (`claude --version`)
- Git installed (`git --version`)
- This repository cloned and as your working directory

## Level 1: Verify Everything Works (5 minutes)

### Step 1: Test Commands

Commands are slash-invoked shortcuts. Try these:

```
/hello
```

You should see a confirmation that commands are working.

```
/example
```

This invokes the example skill and confirms the skill system works.

### Step 2: Test Agents

Agents are specialized personas with restricted tools. Try:

```
"Use the hello agent to verify the system"
```

The hello agent has only `Read` and `Glob` tools - it cannot modify files. This demonstrates tool restrictions.

### Step 3: Verify Session Hook

When you started Claude Code, you should have seen a session start message showing:
- Project name
- Current time
- Git branch (if in a git repo)
- Quick command hints

This comes from the `SessionStart` hook in `.claude/hooks/`.

### Step 4: Check Permissions

Try running a git command:

```
"Run git status"
```

This should work (git is in the allow list).

Now try:
```
"Run git push"
```

This will be blocked (git push is in the deny list for safety).

---

## Level 2: Understand the Components (10 minutes)

### Commands vs Skills vs Agents

| Component | Location | Invocation | Purpose |
|-----------|----------|------------|---------|
| **Commands** | `.claude/commands/` | `/name` | Manual shortcuts |
| **Skills** | `.claude/skills/` | Auto or `/name` | Context providers |
| **Agents** | `.claude/agents/` | "Use X agent" | Restricted personas |

### When to Use Each

**Use Commands when:**
- You want a manual shortcut (like `/commit`)
- The action should only happen when explicitly requested
- You want to restrict which tools the command can use

**Use Skills when:**
- You want context to auto-load based on task
- You have reference documentation that should be available
- You're working with a specific technology (React patterns, API docs)

**Use Agents when:**
- You want to restrict tool access (read-only review)
- You need a specialized persona (security auditor)
- You want to use a different model tier (haiku for simple tasks)

---

## Level 3: Create Your First Command (5 minutes)

Let's create a simple command that shows project statistics.

### Step 1: Create the file

Create `.claude/commands/stats.md`:

```markdown
---
description: Show project statistics
allowed-tools: Bash(wc:*), Bash(find:*), Bash(git:*), Read, Glob
---

# Project Statistics

Show useful statistics about the current project:

1. Count total files (excluding node_modules, .git, etc.)
2. Count lines of code by file type
3. Show git statistics (if in a git repo):
   - Number of commits
   - Number of contributors
   - Recent activity

Format the output in a clear, readable table.
```

### Step 2: Restart Claude Code

Commands are cached at startup, so restart your session.

### Step 3: Test your command

```
/stats
```

You now have a custom command!

---

## Level 4: Create Your First Agent (5 minutes)

Let's create a simple agent that can only read files.

### Step 1: Create the file

Create `.claude/agents/explorer.md`:

```markdown
---
name: explorer
description: Explores and explains code structure without making changes
tools: Read, Glob, Grep
model: haiku
---

# Code Explorer

You are a code explorer. Your job is to:

1. Navigate the codebase
2. Explain what you find
3. Answer questions about code structure

## Constraints

- You CANNOT modify any files
- You CANNOT run commands
- You can only read and search

## When exploring:

1. Use Glob to find files matching patterns
2. Use Read to examine file contents
3. Use Grep to search for specific code patterns

Be thorough but concise in your explanations.
```

### Step 2: Restart Claude Code

### Step 3: Test your agent

```
"Use the explorer agent to understand the project structure"
```

The agent will only use Read, Glob, and Grep - it cannot modify anything.

---

## Level 5: Create Your First Skill (5 minutes)

Skills auto-load based on context. Let's create one for a specific technology.

### Step 1: Create the directory and file

Create `.claude/skills/typescript-tips/SKILL.md`:

```markdown
---
name: typescript-tips
description: |
  WHEN: Working with TypeScript files (.ts, .tsx)
  WHEN NOT: JavaScript files without TypeScript, other languages
---

# TypeScript Best Practices

Apply these patterns when working with TypeScript:

## Type Safety

- Prefer `unknown` over `any` when type is truly unknown
- Use `const` assertions for literal types: `as const`
- Enable strict mode in tsconfig.json

## Common Patterns

### Type Guards

```typescript
function isString(value: unknown): value is string {
  return typeof value === 'string';
}
```

### Utility Types

- `Partial<T>` - Make all properties optional
- `Required<T>` - Make all properties required
- `Pick<T, K>` - Select specific properties
- `Omit<T, K>` - Exclude specific properties

## Avoid

- Don't use `any` unless absolutely necessary
- Don't use `!` (non-null assertion) without good reason
- Don't ignore TypeScript errors with `@ts-ignore`
```

### Step 2: Restart Claude Code

### Step 3: Test the skill

When you work on TypeScript files, Claude will automatically have this context available. Try:

```
"Help me write a type-safe function in TypeScript"
```

The skill's patterns should influence the response.

---

## Level 6: Understanding Hooks (5 minutes)

Hooks run automatically at specific events.

### Available Hook Events

| Event | When | Use Case |
|-------|------|----------|
| `SessionStart` | Session begins | Welcome, environment check |
| `PreToolUse` | Before tool runs | Validation, logging |
| `PostToolUse` | After tool completes | Notifications, cleanup |

### How Hooks Work

1. Hooks are configured in `.claude/settings.json`
2. Scripts live in `.claude/hooks/`
3. OS matchers run platform-specific scripts

### The Current SessionStart Hook

Look at `.claude/hooks/session-start.sh` (Unix) or `session-start.ps1` (Windows):

- Shows project name and time
- Displays git branch if available
- Lists quick commands

### Creating a PreToolUse Hook (Advanced)

PreToolUse hooks receive JSON input and can block operations:

```bash
#!/bin/bash
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool')

if [ "$TOOL" = "Bash" ]; then
  COMMAND=$(echo "$INPUT" | jq -r '.input.command')
  # Log the command
  echo "[$(date)] $COMMAND" >> .claude/logs/commands.log
fi

exit 0  # 0 = allow, 1 = block
```

---

## Level 7: Understanding Rules (5 minutes)

Rules provide persistent context that Claude reads every session.

### Current Rules

| File | Purpose |
|------|---------|
| `coding-rules.md` | Code style, security, git conventions, testing |

### How Rules Work

- Claude reads all `.claude/rules/*.md` files at session start
- Rules influence how Claude writes code and responds
- Keep rules concise - they're read every session

### Customizing Rules

Edit `coding-rules.md` to match your project:

```markdown
# Project Rules

## Code Style
- camelCase for functions, PascalCase for classes
- Keep functions under 30 lines

## Security
- Never commit secrets
- Use parameterized queries

## Git
- Conventional commits: feat|fix|docs(scope): message
```

---

## Level 8: Permissions Deep Dive (5 minutes)

### Permission Categories

**Allow List (142 rules):**
- Core tools: Read, Write, Edit, Glob, Grep
- Git operations: status, diff, log, commit, branch, etc.
- Package managers: npm, pip, cargo, go, etc.
- Build tools: make, cmake, tsc, webpack, etc.

**Deny List (49 rules):**
- Secrets: `.env`, `*.pem`, `*secret*`, `.ssh/`
- Destructive: `rm -rf /`, `sudo`, `shutdown`
- Git push: Requires explicit approval

### Local Overrides

Create `.claude/settings.local.json` (gitignored) for personal settings:

```json
{
  "permissions": {
    "allow": ["Bash(git push:*)"]
  }
}
```

---

## Next Steps

You now understand all the core features! Here's what to do next:

### For Your Project

1. **Update CLAUDE.md** with your project-specific context
2. **Customize rules** to match your team's conventions
3. **Create useful commands** for common tasks (/deploy, /test, /lint)
4. **Create focused agents** for specific workflows (security-auditor, test-writer)

### Resources

- **README.md** - Comprehensive documentation
- **`.claude/*/README.md`** - Component-specific guides
- **[Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code)** - Official documentation

### Command Ideas

| Command | Purpose |
|---------|---------|
| `/deploy` | Deploy to staging/production |
| `/test` | Run test suite with coverage |
| `/lint` | Fix linting issues |
| `/docs` | Generate documentation |
| `/changelog` | Update CHANGELOG.md |

### Agent Ideas

| Agent | Tools | Purpose |
|-------|-------|---------|
| security-auditor | Read, Glob, Grep | Find vulnerabilities |
| test-writer | Read, Glob, Write | Generate tests |
| refactor-helper | Read, Glob, Grep, Edit | Suggest improvements |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Command not found | Restart Claude Code (commands are cached) |
| Agent not available | Check file is in `.claude/agents/` with correct frontmatter |
| Skill not loading | Verify SKILL.md exists with WHEN/WHEN NOT description |
| Hook not running | Check `settings.json` hooks config and script permissions |
| Permission denied | Check deny list or add to `settings.local.json` allow list |

---

*Congratulations! You're now ready to use Claude Base effectively. Happy coding!*
