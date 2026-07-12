---
description: Generate a custom checklist for the current feature based on user requirements.
argument-hint: "Domain or focus area for the checklist"
---

Follow the workflow defined in `.claude/skills/speckit-checklist/SKILL.md`.

User input: $ARGUMENTS

Execute that skill exactly as written for the active feature, and obey the project constitution at `.specify/memory/constitution.md` throughout (in particular, do not modify source code outside an explicitly invoked implementation phase).
