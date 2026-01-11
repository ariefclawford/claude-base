# Claude Code Configuration

This directory contains Claude Code configuration, extensions, and customizations for your project.

---

## Directory Structure

```
.claude/
├── README.md                 # This file
├── TUTORIAL.md               # Getting started guide
├── settings.json             # Permissions, hooks, plugins
├── settings.local.json       # Personal overrides (gitignored)
├── commands/                 # Slash commands (manual /command)
│   ├── README.md             # Commands documentation
│   ├── hello.md              # Verification command
│   ├── commit.md             # Conventional commit command
│   └── review.md             # Code review command
├── skills/                   # Auto-invoked context providers
│   ├── README.md             # Skills documentation
│   └── example/
│       └── SKILL.md          # Example verification skill
├── agents/                   # Sub-agents with restricted tools
│   ├── README.md             # Agents documentation
│   ├── hello.md              # Verification agent
│   ├── code-reviewer.md      # Read-only code reviewer
│   └── documentation-writer.md # Documentation generator
├── hooks/                    # Event automation scripts
│   ├── README.md             # Hooks documentation
│   ├── session-start.sh      # Session hook (Unix)
│   ├── session-start.ps1     # Session hook (Windows)
│   ├── log-commands.sh       # Command logger (Unix)
│   └── log-commands.ps1      # Command logger (Windows)
└── rules/                    # Persistent context files
    └── coding-rules.md       # Code style, security, git, testing
```

---

## Components Overview

| Component | Location | Invocation | Purpose |
|-----------|----------|------------|---------|
| **Commands** | `commands/` | Manual `/name` | User-triggered slash commands |
| **Skills** | `skills/` | **Auto by Claude** | Context providers (description matching) |
| **Agents** | `agents/` | "Use X agent" | Specialized sub-personas |
| **Hooks** | `hooks/` | Automatic | Event-driven scripts |
| **Rules** | `rules/` | Automatic | Persistent context |

### Quick Comparison

| Need | Use |
|------|-----|
| Manual shortcut `/commit` | **Command** |
| Auto-applied React patterns | **Skill** |
| Restricted tool access reviewer | **Agent** |
| Log all commands | **Hook** |
| Coding conventions | **Rule** |

---

## Quick Links

| Component | Documentation | Purpose |
|-----------|---------------|---------|
| **Commands** | [commands/README.md](commands/README.md) | Slash commands (`/commit`, `/review`) |
| **Skills** | [skills/README.md](skills/README.md) | Auto-invoked context (WHEN/WHEN NOT) |
| **Agents** | [agents/README.md](agents/README.md) | Sub-personas with restricted tools |
| **Hooks** | [hooks/README.md](hooks/README.md) | Event-driven automation |
| **Rules** | `rules/*.md` | Persistent context for Claude |

---

## Configuration Files

### settings.json

The main configuration file containing:

- **Permissions** — Allow/deny lists for tools and commands
- **Hooks** — Event triggers and scripts
- **Plugins** — Enabled plugins and settings
- **Marketplaces** — Custom marketplace sources

```json
{
  "permissions": {
    "allow": ["Bash(git status:*)"],
    "deny": ["Bash(rm -rf:*)"]
  },
  "hooks": {
    "SessionStart": [...]
  },
  "enabledPlugins": {},
  "extraKnownMarketplaces": {}
}
```

### settings.local.json

Personal overrides that are **gitignored**. Use for:

- Machine-specific settings
- Personal plugin preferences
- Local permission overrides
- API keys (though environment variables are preferred)

```json
{
  "permissions": {
    "allow": ["Bash(git push:*)"]
  }
}
```

---

## Plugins

Plugins are collections of commands, skills, agents, hooks, and MCP servers that install with a single command.

### What's in a Plugin?

| Component | Description |
|-----------|-------------|
| Commands | Slash commands (`/commit`, `/review`) |
| Skills | Auto-invoked context providers |
| Agents | Specialized sub-personas |
| Hooks | Event automation |
| MCP Servers | External tool integrations |

### Discovering Plugins

Open the plugin browser:

```
/plugin
```

Navigate to the **Discover** tab to browse available plugins.

### Installing Plugins

**From official marketplace:**
```
/plugin install typescript-lsp
```

**From custom marketplace:**
```
/plugin install my-plugin@marketplace-name
```

### Managing Plugins

| Command | Description |
|---------|-------------|
| `/plugin` | Open plugin browser |
| `/plugin list` | List installed plugins |
| `/plugin install <name>` | Install a plugin |
| `/plugin enable <name>` | Enable a plugin |
| `/plugin disable <name>` | Disable a plugin |
| `/plugin remove <name>` | Remove a plugin |

### Plugin Configuration

Enable plugins in `settings.json`:

```json
{
  "enabledPlugins": {
    "typescript-lsp@official": true,
    "python-lsp@official": true,
    "my-plugin@team-marketplace": true
  }
}
```

### Recommended Plugins by Language

| Language | Recommended Plugins |
|----------|---------------------|
| TypeScript/JavaScript | `typescript-lsp@official` |
| Python | `python-lsp@official`, `ruff@official` |
| Rust | `rust-analyzer@official` |
| Go | `gopls@official` |

---

## Marketplaces

Marketplaces are repositories that host collections of plugins.

### Official Marketplace

The official Anthropic marketplace is **automatically available**:

- Repository: [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official)
- Curated, high-quality plugins
- No configuration required

### Adding Marketplaces

**Via command:**
```
/plugin marketplace add owner/repo
```

**Via settings.json:**
```json
{
  "extraKnownMarketplaces": {
    "my-marketplace": {
      "source": {
        "source": "github",
        "repo": "owner/repo"
      }
    }
  }
}
```

### Community Marketplaces

| Marketplace | Repository | Description |
|-------------|------------|-------------|
| **Official** | [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) | Anthropic-curated plugins |
| **ivan-magda** | [ivan-magda/claude-code-marketplace](https://github.com/ivan-magda/claude-code-marketplace) | Swift dev, code migration, AI workflows |
| **netresearch** | [netresearch/claude-code-marketplace](https://github.com/netresearch/claude-code-marketplace) | Automated sync, agentic skills |
| **kivilaid** | [kivilaid/plugin-marketplace](https://github.com/kivilaid/plugin-marketplace) | 87+ plugins from 10+ sources |
| **ananddtyagi** | [ananddtyagi/cc-marketplace](https://github.com/ananddtyagi/cc-marketplace) | Community-driven plugins |
| **hekmon8** | [hekmon8/awesome-claude-code-plugins](https://github.com/hekmon8/awesome-claude-code-plugins) | Curated best plugins |
| **wshobson** | [wshobson/commands](https://github.com/wshobson/commands) | Production-ready slash commands |

### Creating Your Own Marketplace

1. **Create repository** on GitHub
2. **Add `marketplace.json`** with plugin catalog
3. **Add `plugins/` directory** with plugin definitions
4. **Share** via `/plugin marketplace add owner/repo`

See [Plugin Marketplace Documentation](https://code.claude.com/docs/en/plugin-marketplaces) for details.

### Team Marketplaces

Share plugins across your organization:

```json
{
  "extraKnownMarketplaces": {
    "company-plugins": {
      "source": {
        "source": "github",
        "repo": "your-org/claude-plugins"
      }
    }
  }
}
```

When team members clone the repo and trust the folder, the marketplace is automatically available.

---

## Integration Patterns

Commands, skills, agents, and hooks can work together for powerful workflows.

### Pattern 1: Command Uses Agent

A command can delegate to a specialized agent:

**Command:** `.claude/commands/security.md`
```markdown
---
description: Run security audit on codebase
allowed-tools: Read, Glob, Grep
argument-hint: [path]
---

Run a security audit on the specified path (or entire project).
Use the **security-auditor agent** for analysis.
```

**Agent:** `.claude/agents/security-auditor.md`
```yaml
---
name: security-auditor
description: Audits code for security vulnerabilities
tools: Read, Glob, Grep
model: opus
---

[Detailed security analysis instructions]
```

**Usage:** `/security src/auth/`

### Pattern 2: Skill Provides Context for Commands

A skill auto-applies context when commands are used:

**Skill:** `.claude/skills/react-patterns/SKILL.md`
```yaml
---
name: react-patterns
description: |
  WHEN: Working with React components or hooks
  WHEN NOT: Backend code, non-React JavaScript
---

# React Patterns
[React best practices that auto-apply during React work]
```

When you run `/review` on React code, the skill's context is automatically available.

### Pattern 3: Hooks Wrap Operations

Add logging/notifications around operations:

```
User runs /deploy
    ↓
PreToolUse hook (log start, validate)
    ↓
Tool executes
    ↓
PostToolUse hook (log result, notify)
```

### Pattern 4: Complete Pipeline

A full code review workflow combining all components:

```
┌─────────────────────────────────────────────────────────┐
│                  Code Review Pipeline                    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   User: /review                                          │
│         ↓                                                │
│   PreToolUse Hook                                        │
│   └── Log review started                                 │
│         ↓                                                │
│   Command: /review                                       │
│   └── Determines scope                                   │
│   └── Invokes code-reviewer agent                        │
│         ↓                                                │
│   Skill: project-conventions (auto-applied)              │
│   └── Provides project-specific patterns                 │
│         ↓                                                │
│   Agent: code-reviewer                                   │
│   └── Tools: Read, Glob, Grep                            │
│   └── Analyzes code with skill context                   │
│   └── Returns findings                                   │
│         ↓                                                │
│   PostToolUse Hook                                       │
│   └── Log review completed                               │
│   └── Send notification (optional)                       │
│         ↓                                                │
│   User receives review results                           │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Integration Example Files

**1. Command:** `.claude/commands/review.md`
```markdown
---
description: Review code changes for issues
allowed-tools: Bash(git:*), Read, Glob, Grep
argument-hint: [path]
---

# Code Review

Review code for bugs, security issues, and best practices.

1. Determine scope from $ARGUMENTS or git status
2. Use the **code-reviewer agent** for analysis
3. Format results with severity levels
```

**2. Skill:** `.claude/skills/project-conventions/SKILL.md`
```yaml
---
name: project-conventions
description: |
  WHEN: Writing or reviewing code in this project
  WHEN NOT: Discussing external concepts
---

# Project Conventions
[Auto-applied coding standards]
```

**3. Agent:** `.claude/agents/code-reviewer.md`
```yaml
---
name: code-reviewer
description: Reviews code for bugs, security, and best practices
tools: Read, Glob, Grep
model: sonnet
---

# Code Reviewer Agent

Expert code reviewer analyzing for:
- Logic errors and edge cases
- Security vulnerabilities
- Performance issues
- Code quality
```

**4. Hook:** `.claude/hooks/review-logger.sh`
```bash
#!/bin/bash
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool')

if [ "$TOOL" = "Read" ]; then
  mkdir -p .claude/logs
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Code review: $TOOL" >> .claude/logs/reviews.log
fi

exit 0
```

---

## Rules

Rules in the `rules/` directory provide persistent context to Claude. They're automatically loaded every session.

### Current Rules

| File | Purpose |
|------|---------|
| `coding-rules.md` | Code style, security, git conventions, testing |

### Writing Effective Rules

**Do:**
- Be specific and actionable
- Include concrete examples
- Keep concise (loaded every session)

**Don't:**
- Include sensitive information
- Write lengthy documents
- Contradict settings.json

---

## Permissions Overview

Permissions control what Claude Code can do. See the main [README](../README.md) for full details.

### Quick Reference

**Allow (pre-configured):**
- Core tools: Read, Write, Edit, Glob, Grep
- Git operations: status, diff, log, commit, branch
- Package managers: npm, yarn, pip, cargo
- Build tools: make, tsc, webpack

**Deny (blocked by default):**
- Secrets: .env, *.pem, .ssh/
- Destructive: rm -rf /, sudo
- Git push: Requires explicit user action

### Customizing Permissions

```json
{
  "permissions": {
    "allow": ["Bash(git push:*)"],
    "deny": ["Bash(rm:*)"]
  }
}
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Commands not appearing | Restart Claude Code |
| Skills not auto-applying | Check description WHEN/WHEN NOT |
| Agents not loading | Restart Claude Code |
| Hooks not running | Check settings.json, verify scripts executable |
| Plugin not found | Run `/plugin` and check Discover tab |
| Marketplace not available | Check extraKnownMarketplaces config |
| Permission denied | Check deny list, add to settings.local.json |

---

## References

### Official Documentation

| Resource | Link |
|----------|------|
| Claude Code Overview | [docs.anthropic.com/en/docs/claude-code](https://docs.anthropic.com/en/docs/claude-code) |
| Slash Commands | [code.claude.com/docs/en/slash-commands](https://code.claude.com/docs/en/slash-commands) |
| Settings Reference | [docs.anthropic.com/en/docs/claude-code/settings](https://docs.anthropic.com/en/docs/claude-code/settings) |
| CLI Reference | [docs.anthropic.com/en/docs/claude-code/cli](https://docs.anthropic.com/en/docs/claude-code/cli) |
| Plugin Documentation | [code.claude.com/docs/en/discover-plugins](https://code.claude.com/docs/en/discover-plugins) |
| Marketplace Guide | [code.claude.com/docs/en/plugin-marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) |

### Community Resources

| Resource | Link |
|----------|------|
| Official Plugins | [github.com/anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) |
| Plugin Template | [github.com/ivan-magda/claude-code-plugin-template](https://github.com/ivan-magda/claude-code-plugin-template) |
| Production Commands | [github.com/wshobson/commands](https://github.com/wshobson/commands) |
| Awesome Claude Code Plugins | [github.com/hekmon8/awesome-claude-code-plugins](https://github.com/hekmon8/awesome-claude-code-plugins) |
| Community Marketplaces | [claudemarketplaces.com](https://claudemarketplaces.com/) |

### Related Projects

| Project | Description |
|---------|-------------|
| [Claude Code](https://github.com/anthropics/claude-code) | Official CLI repository |
| [MCP Servers](https://github.com/modelcontextprotocol/servers) | Model Context Protocol servers |
| [MCP Specification](https://modelcontextprotocol.io) | Protocol documentation |

### Guides & Tutorials

| Guide | Link |
|-------|------|
| Skills vs Commands | [alexop.dev](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/) |
| Component Deep Dive | [youngleaders.tech](https://www.youngleaders.tech/p/claude-skills-commands-subagents-plugins) |
| Best Practices | [anthropic.com](https://www.anthropic.com/engineering/claude-code-best-practices) |
