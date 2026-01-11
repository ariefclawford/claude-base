# Claude Code Commands

Commands are custom slash commands that you manually invoke from the terminal. They provide convenient shortcuts for common workflows like committing code, reviewing changes, or running tests.

## Commands vs Skills vs Agents

| Component | Location | Invocation | Purpose |
|-----------|----------|------------|---------|
| **Commands** | `.claude/commands/` | Manual `/name` | User-triggered shortcuts |
| **Skills** | `.claude/skills/` | Auto by Claude | Context providers (description matching) |
| **Agents** | `.claude/agents/` | "Use X agent" | Specialized sub-personas |

**Commands** = You type `/commit` → Claude runs it
**Skills** = Claude detects relevant context → Auto-applies skill

---

## Quick Start

**1. Create** `.claude/commands/hello.md`:

```markdown
---
description: Verify commands are working
---

Say "Commands are working!" and show the current directory.
```

**2. Restart** Claude Code (commands are cached at startup)

**3. Test** by typing: `/hello`

**4. Delete** the file after verification

---

## Command Structure

Commands are single markdown files:

```
.claude/commands/<name>.md
```

The **file name** becomes the **slash command**:
- `commands/commit.md` → `/commit`
- `commands/review.md` → `/review`
- `commands/test.md` → `/test`

### Anatomy

```markdown
---
description: What this command does
allowed-tools: Bash(git:*), Read
argument-hint: [optional-arg]
model: claude-sonnet-4-20250514
---

# Command Instructions

What Claude should do when this command is invoked.

Use $ARGUMENTS to access user input.
Use $1, $2 for positional arguments.
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `description` | Recommended | Shown in `/help` and autocomplete |
| `allowed-tools` | Optional | Tools this command can use (overrides session) |
| `argument-hint` | Optional | Hint shown for expected arguments |
| `model` | Optional | Specific model for this command |

### Arguments

Commands can accept arguments:

```
/commit fix login bug
/review src/auth/
/deploy staging
```

Access arguments in your command:

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments as single string |
| `$1`, `$2`, etc. | Positional arguments |

**Example:**
```markdown
---
description: Deploy to environment
argument-hint: <environment>
---

Deploy to the $1 environment (default: staging).

If no argument provided, use staging.
```

Usage: `/deploy production`

---

## Examples

### Example 1: Conventional Commit

```markdown
---
description: Create a conventional commit with proper formatting
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git commit:*)
---

# Conventional Commit

Create a well-formatted conventional commit.

## Process

1. Run `git status` to see changes
2. Run `git diff --cached` (or `git diff` if nothing staged) to analyze changes
3. Determine commit type based on changes:
   - `feat`: New feature
   - `fix`: Bug fix
   - `docs`: Documentation only
   - `style`: Formatting, no code change
   - `refactor`: Code restructuring
   - `test`: Adding/updating tests
   - `chore`: Maintenance, dependencies
4. Write clear commit message with body explaining "why"
5. If user provided message via $ARGUMENTS, incorporate it
6. Execute the commit

## Output Format

```
<type>(<scope>): <subject>

<body explaining why>
```
```

---

### Example 2: Code Review

```markdown
---
description: Review staged or specified changes for issues
allowed-tools: Bash(git:*), Read, Glob, Grep
argument-hint: [path]
---

# Code Review

Review code changes for bugs, security issues, and best practices.

## Scope

- If $ARGUMENTS provided, review that specific path
- Otherwise, review staged changes (`git diff --cached`)
- If nothing staged, review unstaged changes (`git diff`)

## Review Checklist

### Correctness
- Logic errors
- Edge cases
- Error handling

### Security
- No hardcoded secrets
- Input validation
- Injection vulnerabilities

### Quality
- Readable code
- Clear naming
- Appropriate comments

## Output Format

### Summary
Brief overview of changes.

### Issues Found
| Severity | Location | Issue |
|----------|----------|-------|
| High/Med/Low | file:line | Description |

### Suggestions
Non-blocking improvements.
```

---

### Example 3: Test Generator

```markdown
---
description: Generate unit tests for specified code
allowed-tools: Read, Glob, Grep, Write
argument-hint: <file-or-function>
---

# Test Generator

Generate comprehensive unit tests for the specified code.

## Target

Analyze $ARGUMENTS to determine what to test:
- If file path: Generate tests for that file
- If function name: Find and test that function
- If nothing: Ask what to test

## Process

1. Read the target code
2. Identify testable units (functions, methods, classes)
3. Determine test framework (look for existing tests)
4. Generate test cases:
   - Happy path
   - Edge cases
   - Error cases
5. Write tests following project conventions

## Test Structure

```javascript
describe('functionName', () => {
  it('should handle normal input', () => {
    // Arrange, Act, Assert
  });

  it('should handle edge case', () => {});

  it('should throw on invalid input', () => {});
});
```

Adapt to project's test framework (Jest, Pytest, etc.).
```

---

### Example 4: Quick Fix

```markdown
---
description: Fix linting/type errors in specified files
allowed-tools: Bash(npm:*), Bash(npx:*), Read, Edit, Glob
argument-hint: [path]
---

# Quick Fix

Fix linting and type errors.

## Scope

- If $ARGUMENTS provided, fix that path
- Otherwise, run project-wide

## Process

1. Run linter/type checker to identify issues:
   - `npx eslint . --format json` (JS/TS)
   - `npx tsc --noEmit` (TypeScript)
   - Or project's configured tools

2. For each fixable error:
   - Read the file
   - Apply minimal fix
   - Verify fix doesn't break logic

3. Run check again to confirm fixes

## Constraints

- Only fix clear errors, not style preferences
- Don't refactor beyond the fix
- Preserve existing code style
```

---

### Example 5: PR Description

```markdown
---
description: Generate PR description from commits
allowed-tools: Bash(git:*)
argument-hint: [base-branch]
---

# PR Description Generator

Generate a pull request description from commit history.

## Process

1. Determine base branch:
   - Use $1 if provided
   - Otherwise use `main` or `master`

2. Get commits: `git log <base>..HEAD --oneline`

3. Get diff summary: `git diff <base>..HEAD --stat`

4. Generate PR description:

## Output Format

```markdown
## Summary
Brief overview of what this PR does.

## Changes
- Change 1
- Change 2
- Change 3

## Testing
- [ ] Unit tests pass
- [ ] Manual testing completed
- [ ] No regressions

## Related Issues
Closes #XXX (if mentioned in commits)
```
```

---

## Organizing Commands

### Subdirectories (Namespacing)

Organize related commands in subdirectories:

```
.claude/commands/
├── git/
│   ├── commit.md      → /commit (project:git)
│   ├── pr.md          → /pr (project:git)
│   └── rebase.md      → /rebase (project:git)
├── test/
│   ├── unit.md        → /unit (project:test)
│   └── e2e.md         → /e2e (project:test)
└── review.md          → /review (project)
```

The subdirectory appears in the command description but **not** in the command name.

### Personal vs Project Commands

| Location | Scope |
|----------|-------|
| `.claude/commands/` | Project-specific, shared via git |
| `~/.claude/commands/` | Personal, all projects |

---

## Tool Restrictions

Limit what tools a command can use:

```markdown
---
allowed-tools: Bash(git:*), Read
---
```

### Tool Patterns

| Pattern | Allows |
|---------|--------|
| `Read` | Read any file |
| `Bash(git:*)` | Any git command |
| `Bash(npm test:*)` | Only `npm test` |
| `Edit` | Edit any file |
| `Write` | Write any file |

Commands with `allowed-tools` can **only** use those tools, regardless of session permissions.

---

## Model Selection

Specify a model for compute-appropriate commands:

```markdown
---
model: claude-3-5-haiku-20241022
---
```

| Use Case | Recommended Model |
|----------|-------------------|
| Quick lookups, simple tasks | `haiku` |
| Most commands | `sonnet` (default) |
| Complex analysis | `opus` |

---

## Best Practices

### Do

- **Keep commands focused** — One task per command
- **Use descriptive names** — `/commit` not `/c`
- **Add descriptions** — Shows in `/help`
- **Specify allowed-tools** — Principle of least privilege
- **Handle missing arguments** — Provide sensible defaults
- **Include examples** — In command instructions

### Don't

- **Over-engineer** — Commands should be simple shortcuts
- **Duplicate skills** — If it should auto-invoke, use a skill
- **Hardcode paths** — Use arguments or auto-detection
- **Ignore errors** — Handle edge cases gracefully

---

## Viewing Commands

```
/help              # Shows all available commands
/<tab>             # Autocomplete available commands
```

Commands from all sources:
- `.claude/commands/` (project)
- `~/.claude/commands/` (personal)
- Installed plugins
- MCP servers

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Command not appearing | Cached at startup | Restart Claude Code |
| `/name` not found | File name mismatch | Check file name matches command |
| Wrong tools available | `allowed-tools` restriction | Check frontmatter |
| Arguments not working | Variable syntax | Use `$ARGUMENTS` or `$1` |
| Command in wrong location | Directory structure | Ensure `.claude/commands/name.md` |

---

## References

- [Slash Commands - Claude Code Docs](https://code.claude.com/docs/en/slash-commands)
- [Claude Code CLI Reference](https://docs.anthropic.com/en/docs/claude-code/cli)
- [wshobson/commands](https://github.com/wshobson/commands) - Production-ready command examples
