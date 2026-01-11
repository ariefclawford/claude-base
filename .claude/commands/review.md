---
description: Review code changes for bugs, security issues, and best practices
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Read, Glob, Grep
argument-hint: [path or branch]
---

# Code Review

Review code changes for bugs, security issues, and best practices.

## Scope

Determine what to review:
- If `$ARGUMENTS` contains a file path: review that specific file
- If `$ARGUMENTS` contains a branch name: review changes from that branch
- If nothing provided: review staged changes (`git diff --cached`)
- If nothing staged: review unstaged changes (`git diff`)

## Review Checklist

### 1. Correctness
- [ ] Logic errors and off-by-one mistakes
- [ ] Edge cases handled (null, empty, boundary values)
- [ ] Error handling is appropriate
- [ ] Async/await and promise handling is correct
- [ ] Race conditions considered

### 2. Security
- [ ] No hardcoded secrets, API keys, or passwords
- [ ] User input is validated and sanitized
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] Authentication/authorization checks present
- [ ] Sensitive data not logged

### 3. Performance
- [ ] No unnecessary loops or repeated operations
- [ ] Database queries are efficient (no N+1)
- [ ] Large data sets handled appropriately
- [ ] Caching considered where appropriate

### 4. Maintainability
- [ ] Code is readable and self-documenting
- [ ] Functions are focused and not too long
- [ ] Naming is clear and consistent
- [ ] No dead code or commented-out code
- [ ] Complex logic has explanatory comments

### 5. Testing
- [ ] New code has corresponding tests
- [ ] Edge cases are tested
- [ ] Tests are meaningful, not just coverage

## Output Format

### Summary
Brief overview of what the changes do.

### Issues Found

| Severity | Location | Issue | Recommendation |
|----------|----------|-------|----------------|
| Critical/High/Medium/Low | file:line | Description | How to fix |

### Suggestions
Non-blocking improvements that would enhance the code.

### Verdict
Overall assessment: Approve / Request Changes / Needs Discussion
