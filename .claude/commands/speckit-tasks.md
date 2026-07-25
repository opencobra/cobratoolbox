---
description: Generate an actionable, dependency-ordered tasks.md for the feature based on available design artifacts.
argument-hint: "Optional task generation constraints"
---

Follow the workflow defined in `.claude/skills/speckit-tasks/SKILL.md`.

User input: $ARGUMENTS

Execute that skill exactly as written for the active feature, and obey the project constitution at `.specify/memory/constitution.md` throughout (in particular, do not modify source code outside an explicitly invoked implementation phase).
