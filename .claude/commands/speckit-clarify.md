---
description: Identify underspecified areas in the current feature spec by asking up to 5 highly targeted clarification questions and encoding answers back into the spec.
argument-hint: "Optional areas to clarify in the spec"
---

Follow the workflow defined in `.claude/skills/speckit-clarify/SKILL.md`.

User input: $ARGUMENTS

Execute that skill exactly as written for the active feature, and obey the project constitution at `.specify/memory/constitution.md` throughout (in particular, do not modify source code outside an explicitly invoked implementation phase).
