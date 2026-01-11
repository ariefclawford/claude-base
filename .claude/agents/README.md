# Claude Code Agents

Sub-agents are specialized AI personas with restricted tool access, designed for focused tasks. They operate with the **principle of least privilege** — each agent only has access to the tools it needs.

## When to Use Agents

| Scenario | Use Agent? | Why |
|----------|------------|-----|
| Code review without edits | Yes | Restrict to Read, Glob, Grep |
| Generate documentation | Yes | Focused Write access |
| Complex debugging | Yes | Combine Bash + Read + Edit |
| Quick one-off question | No | Use Claude directly |
| Simple file edit | No | Use Claude directly |

**Rule of thumb:** Use agents when you want to **limit capabilities** or create a **reusable specialized persona**.

---

## Quick Verification

Verify the agent system works with this minimal test:

**1. Create** `.claude/agents/hello.md`:

```yaml
---
name: hello
description: Verifies agent system is working
tools: Read
model: haiku
---

You are a verification agent. When invoked:
1. Confirm you're running as the "hello" agent
2. Say "Agents are working!"
3. List the current directory contents
```

**2. Restart** Claude Code (agents are cached at startup)

**3. Test** by saying: `"Use the hello agent"`

**4. Delete** the test agent after verification

---

## Agent Structure

Agents are markdown files with YAML frontmatter:

```
.claude/agents/<name>.md
```

### Anatomy

```markdown
---
name: my-agent              # Unique identifier
description: What it does   # Used for auto-selection
tools: Read, Glob, Grep     # Available capabilities
model: sonnet               # Model tier
---

# Agent Instructions

Markdown body with:
- Persona and behavior
- Specific instructions
- Constraints and guidelines
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier. Used in "Use the **name** agent" |
| `description` | Yes | Purpose + keywords. Enables auto-selection |
| `tools` | Yes | Comma-separated list of available tools |
| `model` | Yes | `haiku`, `sonnet`, or `opus` |

### Body Content

The markdown body defines the agent's behavior:

- **Persona**: Who the agent is, its expertise
- **Instructions**: Step-by-step behavior when invoked
- **Constraints**: What the agent should NOT do
- **Output format**: How to structure responses

---

## Available Tools

### Read-Only Tools

| Tool | Purpose | Use When |
|------|---------|----------|
| `Read` | Read file contents | Examining code, configs, docs |
| `Glob` | Find files by pattern | Locating files (`**/*.ts`, `src/**/*.js`) |
| `Grep` | Search file contents | Finding code patterns, function usages |
| `WebFetch` | Fetch URL content | Reading external documentation |
| `WebSearch` | Search the web | Finding current information |

### Modification Tools

| Tool | Purpose | Security Note |
|------|---------|---------------|
| `Edit` | Modify existing files | Can change any allowed file |
| `Write` | Create new files | Can create files anywhere allowed |
| `Bash` | Execute shell commands | Subject to permission rules in settings.json |

### Utility Tools

| Tool | Purpose |
|------|---------|
| `TodoWrite` | Create and manage task lists |
| `Skill` | Invoke slash commands |

### Tool Selection Guidance

```
Start minimal → Add only what's needed
```

| Agent Purpose | Recommended Tools |
|---------------|-------------------|
| Review/Analyze | Read, Glob, Grep |
| Generate files | Read, Glob, Grep, Write |
| Modify code | Read, Glob, Grep, Edit |
| Debug/Investigate | Read, Glob, Grep, Bash |
| Full automation | All tools as needed |

---

## Model Selection

| Model | Speed | Cost | Best For |
|-------|-------|------|----------|
| `haiku` | Fastest | Lowest | Simple lookups, verification, quick reads |
| `sonnet` | Balanced | Medium | Most agents — reviews, docs, debugging |
| `opus` | Slowest | Highest | Complex reasoning, architecture, security analysis |

**Default to `sonnet`** unless you have a specific reason to use another tier.

### When to Use Each

**haiku** — Fast, cheap, simple:
- File lookups
- Quick verification
- Simple pattern matching

**sonnet** — Balanced, recommended:
- Code review
- Documentation generation
- Debugging
- Test writing

**opus** — Deep reasoning:
- Security audits
- Architecture decisions
- Complex refactoring analysis

---

## How to Use Agents

### Explicit Invocation

```
"Use the code-reviewer agent to check src/auth/"
"Ask the security-auditor to review the authentication module"
"Have the documentation-writer create API docs for the utils folder"
```

### Auto-Selection

Claude may automatically select an agent based on description keywords.

**Example:** An agent with this description:
```yaml
description: Reviews code for bugs, security issues, and performance problems
```

May be auto-selected when you say:
```
"Review this code for security issues"
```

**Tip:** Include relevant keywords in your description to improve auto-selection.

---

## Examples

### Example 1: Code Reviewer (Read-Only)

A focused reviewer that cannot modify code:

```yaml
---
name: code-reviewer
description: Reviews code for bugs, security issues, best practices, and code quality
tools: Read, Glob, Grep
model: sonnet
---

# Code Reviewer

You are an expert code reviewer. When reviewing code:

## Process
1. Read the target files using Read tool
2. Search for related code with Glob and Grep
3. Analyze for issues

## Review Checklist
- [ ] Logic errors and edge cases
- [ ] Security vulnerabilities (injection, XSS, etc.)
- [ ] Performance concerns
- [ ] Code style and readability
- [ ] Error handling
- [ ] Test coverage gaps

## Output Format
Provide findings as:

### Critical Issues
- Issue description with file:line reference

### Warnings
- Potential problems to consider

### Suggestions
- Improvements for code quality

## Constraints
- Do NOT suggest changes you cannot verify
- Reference specific line numbers
- Prioritize security issues
```

---

### Example 2: Documentation Writer (Can Write)

Creates documentation files:

```yaml
---
name: documentation-writer
description: Generates documentation, READMEs, API docs, and code comments
tools: Read, Glob, Grep, Write
model: sonnet
---

# Documentation Writer

You are a technical documentation expert. Generate clear, comprehensive docs.

## Process
1. Read existing code and documentation
2. Understand the codebase structure
3. Generate appropriate documentation

## Documentation Types
- README files
- API documentation
- Code comments
- Usage examples
- Architecture docs

## Style Guidelines
- Use clear, concise language
- Include code examples
- Add tables for quick reference
- Structure with headers for scannability

## Constraints
- Match existing documentation style if present
- Do not modify code files (only documentation)
- Ask for clarification if scope is unclear
```

---

### Example 3: Debugger (Full Investigation)

Can read, run commands, and fix issues:

```yaml
---
name: debugger
description: Investigates bugs, analyzes errors, traces issues, and fixes problems
tools: Read, Glob, Grep, Bash, Edit
model: sonnet
---

# Debugger

You are an expert debugger. Systematically investigate and resolve issues.

## Investigation Process
1. **Understand** — Read error messages and relevant code
2. **Reproduce** — Run commands to confirm the issue
3. **Trace** — Follow the code path to find root cause
4. **Fix** — Make minimal, targeted changes
5. **Verify** — Confirm the fix works

## Tools Usage
- `Read` — Examine source code and configs
- `Grep` — Search for related code, error strings
- `Glob` — Find relevant files
- `Bash` — Run tests, check logs, execute commands
- `Edit` — Apply fixes

## Output Format
1. **Issue Summary** — What's wrong
2. **Root Cause** — Why it's happening
3. **Fix Applied** — What was changed
4. **Verification** — How to confirm it's fixed

## Constraints
- Make minimal changes (don't refactor unrelated code)
- Explain your reasoning
- Test fixes before declaring success
```

---

### Example 4: Security Auditor (Deep Analysis)

Uses opus for complex security reasoning:

```yaml
---
name: security-auditor
description: Audits code for security vulnerabilities, OWASP issues, and security best practices
tools: Read, Glob, Grep
model: opus
---

# Security Auditor

You are a security expert performing a thorough code audit.

## Audit Scope
- Authentication and authorization
- Input validation and sanitization
- Injection vulnerabilities (SQL, XSS, command)
- Secrets and credential handling
- Dependency vulnerabilities
- Access control issues

## OWASP Top 10 Checklist
1. Broken Access Control
2. Cryptographic Failures
3. Injection
4. Insecure Design
5. Security Misconfiguration
6. Vulnerable Components
7. Authentication Failures
8. Data Integrity Failures
9. Logging Failures
10. SSRF

## Output Format

### Critical Vulnerabilities
Immediate action required. Include:
- Vulnerability type
- File and line number
- Exploitation scenario
- Remediation steps

### High Risk Issues
Should be addressed soon.

### Medium Risk Issues
Address in normal development cycle.

### Recommendations
General security improvements.

## Constraints
- Do NOT modify files (read-only audit)
- Prioritize by exploitability and impact
- Provide specific remediation guidance
```

---

## Best Practices

### Do

- **Keep agents focused** — One purpose per agent
- **Use minimal tools** — Only what's needed (least privilege)
- **Write clear descriptions** — Include keywords for auto-selection
- **Document behavior** — Clear instructions in the body
- **Test after creating** — Verify the agent works as expected

### Don't

- **Over-permission** — Don't give Write/Edit to read-only agents
- **Use opus for simple tasks** — Unnecessary cost
- **Create generic agents** — "general-helper" is just Claude
- **Skip testing** — Always verify new agents work

---

## Common Patterns

| Agent Type | Tools | Model | Use Case |
|------------|-------|-------|----------|
| Code Reviewer | Read, Glob, Grep | sonnet | PR reviews, code quality |
| Documentation Writer | Read, Glob, Write | sonnet | Generate docs, READMEs |
| Test Writer | Read, Glob, Write | sonnet | Generate unit/integration tests |
| Debugger | Read, Glob, Grep, Bash, Edit | sonnet | Investigate and fix issues |
| Security Auditor | Read, Glob, Grep | opus | Vulnerability analysis |
| Refactoring Assistant | Read, Glob, Grep, Edit | sonnet | Code improvements |
| Dependency Checker | Read, Glob, Grep, Bash | haiku | Check outdated packages |
| API Explorer | Read, Glob, WebFetch | haiku | Research external APIs |
| Log Analyzer | Read, Glob, Grep | haiku | Parse and analyze logs |
| Migration Helper | Read, Glob, Grep, Edit, Write | sonnet | Code migrations |

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Agent not appearing | Cached at startup | Restart Claude Code |
| "Use the X agent" fails | Name mismatch | Check `name` field matches exactly |
| Agent can't read files | Missing tool | Add `Read` to tools list |
| Agent can't run commands | Bash missing or denied | Add `Bash` + check settings.json permissions |
| Agent seems slow | Wrong model tier | Consider `haiku` or `sonnet` instead of `opus` |
| Agent not auto-selecting | Weak description | Add more keywords to description |
| Agent ignores instructions | Body too complex | Simplify and clarify instructions |
| Permission denied errors | Settings deny list | Check `.claude/settings.json` deny rules |

---

## Permissions & Security

Agents inherit all permission rules from `.claude/settings.json`:

- **Deny rules apply** — Agents cannot read `.env`, push to git, etc.
- **Allow rules apply** — Pre-approved commands work in Bash
- **Tool + Permission** — Both must allow an action

**Example:** An agent with `Bash` tool still cannot:
- Read `.env` files (denied)
- Run `git push` (denied)
- Execute `sudo` commands (denied)

```
Agent Tools + Settings Permissions = Actual Capabilities
```

For local overrides, use `.claude/settings.local.json` (gitignored).

---

## References

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Claude Code Settings](https://docs.anthropic.com/en/docs/claude-code/settings)
- [Claude Code CLI Reference](https://docs.anthropic.com/en/docs/claude-code/cli)
