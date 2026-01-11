# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-11

### Added

- **Permissions**: 142 allow rules, 49 deny rules for secure defaults
- **Commands**: `/hello`, `/commit`, `/review` slash commands
- **Agents**: hello, code-reviewer, documentation-writer sub-agents
- **Skills**: `/example` skill for verification
- **Hooks**: session-start and log-commands (cross-platform Windows/Unix)
- **Rules**: Consolidated `coding-rules.md` for code style, security, git, testing
- **MCP**: 6 server examples (filesystem, fetch, memory, github, postgres, sqlite)
- **Documentation**: Comprehensive README, TUTORIAL, and component READMEs
- **Cross-platform**: .gitattributes for line endings, platform-specific hooks
- **.claudeignore**: Optimized ignore patterns for performance and security
- **Local overrides**: settings.local.json.example for personal configuration

[1.0.0]: https://github.com/ariefclawford/claude-base/releases/tag/v1.0.0
