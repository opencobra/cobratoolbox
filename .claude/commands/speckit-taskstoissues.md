---
description: Convert existing tasks into actionable, dependency-ordered GitHub issues for the feature based on available design artifacts.
argument-hint: "Optional filter or label for GitHub issues"
---

Follow the workflow defined in `.claude/skills/speckit-taskstoissues/SKILL.md`.

User input: $ARGUMENTS

Execute that skill exactly as written for the active feature, and obey the project constitution at `.specify/memory/constitution.md` throughout (in particular, do not modify source code outside an explicitly invoked implementation phase).
