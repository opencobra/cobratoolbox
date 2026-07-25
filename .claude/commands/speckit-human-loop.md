---
description: Run the Spec Kit human-loop orchestrator (bundled, human-gated phases) for the active feature.
argument-hint: "<feature request | continue <feature> | prepare | implement approved | closeout> [--scope all|slice:<phase>]"
---

Follow the orchestration workflow defined in `.claude/skills/speckit-human-loop/SKILL.md`.

User input: $ARGUMENTS

Execute that skill's bundles and human gates exactly as specified:
- Bundle 0: detect project, active feature, and mode; read and obey `.specify/memory/constitution.md`.
- Bundle 1 (requirements): constitution check -> specify -> clarify -> checklist, then stop at Gate 1.
- Bundle 2 (implementation prep): plan -> tasks -> analyze -> write implementation-review.md, then always stop at Gate 2.
- Bundle 3 (implement): only after explicit Gate 2 approval AND the constitution's required `/speckit-implement` invocation; write the implementation receipt under the feature's `agent-runs/` ledger.
- Bundle 4 (verify & closeout): git diff + narrowest tests (MATLAB MCP where relevant), then Gate 3.

Do not modify source before Gate 2 approval. Use AskUserQuestion for the gates and the task list for progress.
