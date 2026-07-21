# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-04-28

### Added

- `.extensionignore` to exclude dev-only and maintainer files (`.git/`, `.claude/`, `.specify/`, `CLAUDE.md`, OS cruft) from `specify extension add` installs. Reduces the installed payload to only `extension.yml`, `commands/`, `README.md`, `CHANGELOG.md`, `LICENSE`, and `agents.png`.

### Changed

- Align command frontmatter with official spec-kit template conventions
- Add `scripts:` frontmatter with both `sh` and `ps` entries to all three commands (restores Windows/PowerShell support)
- Replace hardcoded `.specify/scripts/bash/check-prerequisites.sh` calls with the `{SCRIPT}` placeholder so spec-kit's command registrar can rewrite paths per platform
- Expand `/speckit.agent-assign.execute` project setup detection to include `.terraformignore` and `.helmignore`, matching the latest `/speckit.implement` behavior
- Bump minimum `speckit_version` requirement to `>=0.7.1` (the release that added this extension to the community catalog)

### Removed

- Remove the inline "Check for extension hooks" blocks from all three command files. Those blocks belong to core spec-kit commands (implement, tasks, plan, etc.) — extension commands are hook *providers*, not hook *consumers*, so the checks were both unnecessary and referenced the wrong events. This also trims ~160 lines of prompt-only noise from the command files.

## [1.0.0] - 2026-03-31

### Added

- `speckit.agent-assign.assign` — Scan Claude Code agent definitions and assign them to tasks
- `speckit.agent-assign.validate` — Read-only validation of agent assignments before execution
- `speckit.agent-assign.execute` — Phase-by-phase task execution with specialized agent spawning
- Agent discovery following Claude Code's priority hierarchy (project > user)
- YAML-based assignment storage (`agent-assignments.yml`)
- `after_tasks` hook for automatic agent assignment after task generation
- Parallel task execution support for tasks marked with `[P]`
- Fallback to `default` mode when assigned agent is unavailable

[1.1.0]: https://github.com/xymelon/spec-kit-agent-assign/releases/tag/v1.1.0
[1.0.0]: https://github.com/xymelon/spec-kit-agent-assign/releases/tag/v1.0.0
