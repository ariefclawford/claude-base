# Claude Code Skills

Skills are **auto-invoked context providers** that Claude automatically applies when the task matches the skill's description. Unlike commands (which you manually trigger with `/command`), skills are discovered and applied by Claude based on contextual relevance.

## Skills vs Commands vs Agents

| Component | Location | Invocation | Purpose |
|-----------|----------|------------|---------|
| **Commands** | `.claude/commands/` | Manual `/name` | User-triggered shortcuts |
| **Skills** | `.claude/skills/` | **Auto by Claude** | Context providers (description matching) |
| **Agents** | `.claude/agents/` | "Use X agent" | Specialized sub-personas |

**Key Difference:**
- **Commands** = You type `/commit` → Claude runs it
- **Skills** = Claude detects relevant context → **Auto-applies** the skill

---

## When to Use Skills

| Scenario | Use Skill? | Why |
|----------|------------|-----|
| Persistent context for a technology | Yes | Auto-applied when discussing that tech |
| Coding patterns and conventions | Yes | Applied during relevant code tasks |
| Reference documentation | Yes | Bundled with skill as supporting files |
| Manual workflow shortcut | **No** | Use a command instead |
| One-off task | **No** | Just ask Claude directly |

**Rule of thumb:** Use skills for **context that should auto-load** when Claude detects relevance.

---

## Quick Start

**1. Create directory:** `.claude/skills/react-patterns/`

**2. Create** `.claude/skills/react-patterns/SKILL.md`:

```markdown
---
name: react-patterns
description: |
  WHEN: Working with React components, hooks, or state management
  WHEN NOT: Non-React JavaScript code, backend code
---

# React Patterns

Apply these patterns when working with React code.

## Component Structure
- Use functional components with hooks
- Keep components focused and small
- Extract custom hooks for reusable logic

## State Management
- Use useState for local state
- Use useReducer for complex state logic
- Lift state only when necessary

## Performance
- Memoize expensive computations with useMemo
- Wrap callbacks in useCallback when passing to children
- Use React.memo for pure components
```

**3. Restart** Claude Code

**4. Test** by asking Claude to help with React code — the skill should auto-apply

---

## Skill Structure

Skills are **directories** containing `SKILL.md` and optional supporting files:

```
.claude/skills/<skill-name>/
├── SKILL.md           # Main skill definition (required)
├── PATTERNS.md        # Reference patterns (optional)
├── EXAMPLES.md        # Code examples (optional)
├── MIGRATIONS.md      # Migration guides (optional)
└── scripts/           # Utility scripts (optional)
    └── validate.sh
```

### Why Directories?

Unlike commands (single files), skills can bundle:
- Reference documentation
- Code patterns and templates
- Utility scripts for deterministic operations
- Migration guides
- Example code

Claude can access all files in the skill directory when the skill is active.

---

## SKILL.md Anatomy

```markdown
---
name: skill-name
description: |
  WHEN: Conditions when this skill should activate
  WHEN NOT: Conditions when this skill should NOT activate
---

# Skill Title

Context and instructions that Claude should apply.

## Section 1
Relevant information...

## Section 2
More context...
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier for the skill |
| `description` | **Critical** | Determines when Claude auto-invokes the skill |

### Description Quality

The `description` field is **critical** — it determines when Claude applies the skill.

**Bad description** (too generic):
```yaml
description: Helps with database operations
```

**Good description** (explicit boundaries):
```yaml
description: |
  WHEN: Working with Dexie.js IndexedDB wrapper, including:
    - Schema definitions and migrations
    - CRUD operations on Dexie tables
    - Dexie hooks and middleware
  WHEN NOT:
    - Other IndexedDB libraries
    - Server-side databases (PostgreSQL, MongoDB)
    - General JavaScript that doesn't involve Dexie
```

The WHEN/WHEN NOT pattern prevents false positives and ensures proper activation.

---

## Examples

### Example 1: Technology-Specific Skill

For a specific library or framework:

```
.claude/skills/dexie-expert/
├── SKILL.md
├── PATTERNS.md
├── MIGRATIONS.md
└── scripts/
    └── generate-migration.js
```

**SKILL.md:**
```markdown
---
name: dexie-expert
description: |
  WHEN: Working with Dexie.js IndexedDB wrapper
    - Defining database schemas
    - Writing CRUD operations
    - Database migrations
    - Dexie hooks and transactions
  WHEN NOT:
    - Other databases (PostgreSQL, MongoDB, etc.)
    - Non-Dexie IndexedDB code
    - Server-side database operations
---

# Dexie.js Expert

Expert guidance for Dexie.js IndexedDB operations.

## Quick Reference

See [PATTERNS.md](PATTERNS.md) for common patterns.
See [MIGRATIONS.md](MIGRATIONS.md) for migration guides.

## Schema Definition

```typescript
const db = new Dexie('MyDatabase');
db.version(1).stores({
  users: '++id, email, *tags',
  posts: '++id, userId, createdAt'
});
```

## Key Patterns

### Auto-increment Primary Key
Use `++id` for auto-incrementing integer keys.

### Compound Index
Use `[prop1+prop2]` for compound indexes.

### Multi-Entry Index
Use `*prop` for array properties that should be indexed.

## Scripts

Run `scripts/generate-migration.js` to scaffold a new migration.
```

**PATTERNS.md:**
```markdown
# Dexie Patterns

## CRUD Operations

### Create
```typescript
await db.users.add({ email: 'user@example.com' });
```

### Read
```typescript
const user = await db.users.get(id);
const users = await db.users.where('email').equals(email).toArray();
```

### Update
```typescript
await db.users.update(id, { email: 'new@example.com' });
```

### Delete
```typescript
await db.users.delete(id);
```

## Transactions

```typescript
await db.transaction('rw', db.users, db.posts, async () => {
  const userId = await db.users.add({ email });
  await db.posts.add({ userId, title });
});
```
```

---

### Example 2: Project Conventions Skill

For project-specific patterns:

```
.claude/skills/project-conventions/
├── SKILL.md
└── EXAMPLES.md
```

**SKILL.md:**
```markdown
---
name: project-conventions
description: |
  WHEN: Writing or modifying code in this project
  WHEN NOT: Discussing external libraries or general concepts
---

# Project Conventions

Apply these conventions when working on this codebase.

## File Organization

```
src/
├── components/     # React components
├── hooks/          # Custom hooks
├── services/       # API and business logic
├── utils/          # Pure utility functions
└── types/          # TypeScript types
```

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `UserProfile.tsx` |
| Hooks | camelCase, use prefix | `useAuth.ts` |
| Utils | camelCase | `formatDate.ts` |
| Types | PascalCase | `User.ts` |

## Component Pattern

```tsx
interface Props {
  // Props interface above component
}

export function ComponentName({ prop }: Props) {
  // Hooks at top
  // Handlers next
  // Return JSX
}
```

## Error Handling

- Use Result type for operations that can fail
- Throw only for unexpected errors
- Log errors with context
```

---

### Example 3: API Integration Skill

For working with specific APIs:

```
.claude/skills/stripe-integration/
├── SKILL.md
├── WEBHOOKS.md
└── TESTING.md
```

**SKILL.md:**
```markdown
---
name: stripe-integration
description: |
  WHEN: Working with Stripe payments, subscriptions, or webhooks
    - Creating payment intents
    - Managing subscriptions
    - Handling Stripe webhooks
    - Stripe CLI testing
  WHEN NOT:
    - Other payment providers (PayPal, Square)
    - General e-commerce without Stripe
---

# Stripe Integration

Guidance for Stripe payment integration.

## Environment Variables

Required in `.env`:
```
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
```

## Common Operations

### Create Payment Intent

```typescript
const paymentIntent = await stripe.paymentIntents.create({
  amount: 1000, // cents
  currency: 'usd',
  metadata: { orderId }
});
```

### Handle Webhook

See [WEBHOOKS.md](WEBHOOKS.md) for webhook handling patterns.

## Testing

See [TESTING.md](TESTING.md) for Stripe CLI testing guide.

## Security

- Never log full card numbers
- Validate webhook signatures
- Use idempotency keys for retries
```

---

## Supporting Files

Skills can include additional markdown files that Claude can reference:

| File | Purpose |
|------|---------|
| `PATTERNS.md` | Common code patterns |
| `EXAMPLES.md` | Working code examples |
| `MIGRATIONS.md` | Migration/upgrade guides |
| `API.md` | API reference documentation |
| `TROUBLESHOOTING.md` | Common issues and solutions |

### Scripts

Skills can bundle scripts for deterministic operations:

```
.claude/skills/my-skill/
└── scripts/
    ├── generate-component.js
    ├── validate-schema.sh
    └── run-migration.py
```

Claude can execute these scripts when the skill is active, providing deterministic behavior for complex operations.

---

## Skill Locations

| Location | Scope |
|----------|-------|
| `.claude/skills/` | Project-specific, shared via git |
| `~/.claude/skills/` | Personal, all projects |
| `.claude/skills/shared/` | Shared skills (convention) |

---

## Best Practices

### Do

- **Use WHEN/WHEN NOT descriptions** — Explicit activation boundaries
- **Bundle reference docs** — Patterns, examples, migrations
- **Keep skills focused** — One technology/domain per skill
- **Include working examples** — Not just theory
- **Add scripts for deterministic tasks** — Scaffolding, validation

### Don't

- **Use generic descriptions** — Causes false positives
- **Create manual workflow skills** — Use commands instead
- **Duplicate project rules** — Use `.claude/rules/` for conventions
- **Make skills too broad** — Split into focused skills

---

## Skills vs Other Components

| Need | Use |
|------|-----|
| Auto-applied context | **Skill** |
| Manual shortcut | Command |
| Restricted tool access | Agent |
| Persistent conventions | Rules |

### Example Decision

"I want React best practices applied automatically when working on React code"
→ **Skill** (auto-invoked based on context)

"I want to run `/react-component` to scaffold a component"
→ **Command** (manual invocation)

"I want a code-reviewer that only has Read access"
→ **Agent** (tool restrictions)

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Skill not activating | Description too vague | Add WHEN/WHEN NOT boundaries |
| Skill activating incorrectly | Description too broad | Narrow the description |
| Skill not found | Missing SKILL.md | Ensure file exists in skill directory |
| Changes not reflected | Cached at startup | Restart Claude Code |
| Supporting files not accessible | Wrong location | Place in skill directory, not subdirectory |

---

## References

- [Claude Code Skills Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Skills vs Commands Guide](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/)
- [Skills Deep Dive](https://www.youngleaders.tech/p/claude-skills-commands-subagents-plugins)
