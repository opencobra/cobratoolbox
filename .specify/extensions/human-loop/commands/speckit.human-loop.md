---
description: "Run bundled core Spec Kit phases with sparse human gates and constitution-compliant approval before implementation (Claude-tailored)."
argument-hint: "<feature request | continue | prepare | implement approved | closeout> [--scope all|slice:<phase>|tests-only]"
---

# Spec Kit Human Loop Orchestrator (Claude)

## User input

```text
$ARGUMENTS
```

You MUST consider the user input before proceeding.

## Behaviour

Follow the installed `speckit-human-loop` skill at
`.claude/skills/speckit-human-loop/SKILL.md`. That skill is the authoritative
definition of this workflow. In summary it:

1. Detects the project, active feature, and requested mode (Bundle 0), reading and
   obeying `.specify/memory/constitution.md`.
2. Bundles requirements preparation — `speckit.constitution` (check), `speckit.specify`,
   `speckit.clarify`, `speckit.checklist` — then stops at Gate 1.
3. Bundles implementation preparation — `speckit.plan`, `speckit.tasks`,
   `speckit.analyze`, plus `implementation-review.md` — then always stops at Gate 2.
4. Implements only the human-approved scope, and only via the constitution's
   required implementation invocation; writes the constitutional implementation
   receipt.
5. Verifies (git diff, narrowest relevant tests, MATLAB MCP where applicable) and
   closes out at Gate 3.

## Embedding requirement

Invoke the installed core Spec Kit skills via the Skill tool
(`speckit-constitution`, `speckit-specify`, `speckit-clarify`, `speckit-checklist`,
`speckit-plan`, `speckit-tasks`, `speckit-analyze`, `speckit-implement`). Do not
hand-write replacements. If a required core command is unavailable, stop and report
which one is missing.

## Safety rule

Do not modify source code until the human approves implementation at Gate 2 AND the
constitution's required implementation invocation has been given. Run human gates
with the `AskUserQuestion` tool; track bundles and tasks with the task list.
