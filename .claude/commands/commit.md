---
description: Create a conventional commit with proper formatting
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*)
argument-hint: [message]
---

# Conventional Commit

Create a well-formatted commit following the Conventional Commits specification.

## Process

1. Run `git status` to see all changes (staged and unstaged)
2. Run `git diff --cached` to analyze staged changes
   - If nothing is staged, run `git diff` to see unstaged changes
3. Determine the appropriate commit type based on changes:

   | Type | Description |
   |------|-------------|
   | `feat` | New feature for the user |
   | `fix` | Bug fix |
   | `docs` | Documentation only |
   | `style` | Formatting, no code change |
   | `refactor` | Code restructuring, no behavior change |
   | `perf` | Performance improvement |
   | `test` | Adding or updating tests |
   | `build` | Build system or dependencies |
   | `ci` | CI configuration |
   | `chore` | Maintenance tasks |

4. If user provided a message via $ARGUMENTS, incorporate it
5. Write a clear commit message with:
   - Subject line: `<type>(<scope>): <description>` (max 50 chars)
   - Blank line
   - Body explaining the "why" (wrap at 72 chars)
6. Stage changes if needed and execute the commit

## Commit Message Format

```
<type>(<scope>): <short description>

<body explaining why this change was made>

<optional footer with breaking changes or issue references>
```

## Examples

```
feat(auth): add password reset functionality

Users can now reset their password via email. This addresses
the most requested feature from customer support tickets.

Closes #123
```

```
fix(api): handle null response from payment provider

The payment provider occasionally returns null instead of
an error object. Added defensive check to prevent crash.
```

## Guidelines

- Keep subject line under 50 characters
- Use imperative mood ("add" not "added")
- Don't end subject with period
- Explain WHY in the body, not just WHAT
- Reference issues when applicable
