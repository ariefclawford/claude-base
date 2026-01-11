# Project Rules

Concise, actionable rules for this codebase.

## Code Style

**Do:**
- camelCase for functions/variables, PascalCase for classes/components
- kebab-case for filenames (`user-service.ts`)
- SCREAMING_SNAKE_CASE for constants
- Prefix booleans: `isActive`, `hasPermission`, `canEdit`
- Keep functions under 30 lines, max 3-4 parameters
- Validate inputs at system boundaries

**Don't:**
- Swallow errors silently
- Use `any` type in TypeScript
- Hardcode secrets or credentials

## Security

**Never commit:**
- API keys, tokens, passwords
- `.env` files, `*.pem`, `*.key`
- Connection strings with credentials

**Always:**
- Use parameterized queries (never string concatenation for SQL)
- Escape user content in HTML
- Check authorization on every request
- Log context, not sensitive data (no passwords, PII, card numbers)

## Git

**Commits:** `type(scope): message` (imperative, max 50 chars)
- `feat` | `fix` | `docs` | `refactor` | `test` | `chore`

**Branches:** `type/short-description`
- `feature/user-auth`, `fix/login-bug`, `hotfix/security-patch`

**Don't:**
- Force push to shared branches
- Commit directly to main
- Skip pre-commit hooks

## Testing

- Test behavior, not implementation
- Arrange-Act-Assert pattern
- Mock external dependencies only
- Descriptive names: `should return null when user not found`

## Pull Requests

- Keep PRs small and focused (< 400 lines)
- One logical change per PR
- Self-review your diff before requesting review
