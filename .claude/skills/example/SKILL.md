---
name: example
description: |
  WHEN: User explicitly invokes /example to verify the skill system
  WHEN NOT: Never auto-invoked - this is a verification skill only
---

# Example Skill

This skill verifies that Claude Code's skill system is properly configured and working.

## Purpose

When `/example` is invoked, confirm the skill system works by:

1. Acknowledging that skills are working
2. Explaining what skills are and how they differ from commands
3. Pointing to this project's skill documentation

## Response

When this skill is invoked, respond with:

---

**Skills are working!**

This message comes from the `example` skill located at `.claude/skills/example/SKILL.md`.

### What are Skills?

Skills are **auto-invoked context providers** that Claude loads based on the task at hand:

| Component | Invocation | Purpose |
|-----------|------------|---------|
| **Commands** | Manual (`/name`) | User-triggered shortcuts |
| **Skills** | Auto by Claude | Context when task matches description |
| **Agents** | "Use X agent" | Specialized sub-personas with tool restrictions |

### This Skill's Structure

```
.claude/skills/example/
└── SKILL.md          # This file
```

Skills can also include supporting files:
- `PATTERNS.md` - Code patterns
- `EXAMPLES.md` - Working examples
- `scripts/` - Utility scripts

### Next Steps

1. Create your own skill in `.claude/skills/your-skill/SKILL.md`
2. Use the WHEN/WHEN NOT pattern in the description
3. Restart Claude Code to load new skills

See `.claude/skills/README.md` for detailed documentation.

---

## Notes

This is a minimal skill for verification purposes. Real skills should:
- Have descriptive WHEN/WHEN NOT clauses for auto-invocation
- Include relevant context Claude should apply
- Bundle supporting documentation when needed
