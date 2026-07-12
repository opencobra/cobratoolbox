---
name: "speckit-human-loop"
description: "Orchestrate GitHub Spec Kit's core commands as bundled, human-gated phases tailored to Claude/Cowork. Use when the user wants semi-automated spec-driven development: requirements preparation, implementation preparation, an explicit approval gate before any source-code change, scoped implementation, then verification and closeout. This skill embeds and invokes the installed core Spec Kit skills (constitution, specify, clarify, checklist, plan, tasks, analyze, implement) rather than replacing them. It uses Claude-native affordances: AskUserQuestion for gates, the task list for progress, the MATLAB MCP server for verification, and subagents for independent review."
argument-hint: "<feature request | continue | prepare | implement approved | closeout> [--scope all|slice:<phase>|tests-only]"
compatibility: "Requires a Spec Kit project initialized with .specify/ and the core speckit skills installed under .claude/skills/. Designed for Claude Code / Cowork. Honors the project constitution at .specify/memory/constitution.md, including its implementation gate and implementation-receipt ledger."
metadata:
  author: "local"
  source: "custom:speckit-human-loop (claude-tailored)"
  adapted_from: "speckit-human-loop-package-codex"
user-invocable: true
disable-model-invocation: false
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

# Spec Kit Human Loop (Claude-tailored)

Run the ordinary GitHub Spec Kit workflow as a small number of human-gated
bundles, so the user does not chain eight commands by hand. This skill is an
**orchestrator**: it must not replace, summarize away, or silently skip the core
Spec Kit commands. At each phase it invokes the installed core skill and follows
its instructions.

This version is adapted for Claude/Cowork and for projects whose constitution
already enforces a strict implementation gate and an implementation-receipt
ledger. Where this skill and the project constitution overlap, **the
constitution wins** and this skill defers to it (see "Constitution reconciliation").

## Non-negotiable rules

1. **No source edits before approval.** Do not modify source code, tests, build
   files, or other implementation artifacts before the human explicitly approves
   implementation at Gate 2 **and** the approval is expressed as a real
   implementation invocation (see Constitution reconciliation). Spec Kit
   artifacts under `specs/<feature>/` and the orchestration state file are not
   "source code" and may be written during preparation.
2. **Embed, never emulate, core commands.** Each bundle invokes the corresponding
   installed core skill via the Skill tool (e.g. `speckit-specify`). Do not
   hand-write `spec.md`, `plan.md`, or `tasks.md` unless the core skill is
   unavailable and the user explicitly asks for a temporary fallback.
3. **Sparse gates only.** Stop for a human decision only at the three gates, or on
   a real blocker (ambiguity, failed quality gate, excessive scope, an attempted
   source edit). Do not ask between routine phases.
4. **Record every human decision** in the orchestration state file.
5. **`spec.md` is the authority for requirements.** When it changes, re-derive the
   downstream artifacts (`plan.md`, `tasks.md`, analysis) rather than editing them
   in isolation.
6. **Stop and report** if the repository is not a Spec Kit project, a required core
   command is missing, the active feature cannot be determined, or the approved
   scope cannot be enforced. Do not invent replacements for missing core commands.

## Constitution reconciliation (read first)

Before Bundle 0, read `.specify/memory/constitution.md` if present and obey it.
This skill is explicitly subordinate to it. In particular:

- **Implementation gate.** If the constitution restricts implementation to an
  explicit invocation (for example, only `/speckit-implement`, `$speckit-implement`,
  or a stated exact phrase authorizes edits), then **a Gate 2 menu choice is not
  sufficient by itself**. Gate 2 records the human's intent and approved scope;
  the skill then proceeds to implementation **only via the constitution's required
  invocation**. If the user picked "approve" in the gate but the constitution
  needs an explicit implement invocation, ask the user to confirm with that exact
  invocation before any edit.
- **Run record / receipt.** If the constitution mandates an implementation-receipt
  ledger at a specific path (for example
  `<FEATURE_DIR>/agent-runs/<UTC-timestamp>-<short-name>/implementation-receipt.md`),
  that receipt is the **canonical** record of an implementation run. Do not invent
  a competing record. This skill's `human-loop.md` is a lightweight orchestration
  index only, and must cross-reference (not duplicate) the constitutional receipt.
  Follow the receipt's required sections and concision rules exactly.
- **Language/coding standards.** If the constitution sets coding standards (for
  example, MATLAB rules: no `evalc` that suppresses warnings or shadows built-ins,
  warnings must stay visible, propagate error stacks, no `nargin`), surface those
  as checks in the implementation and verification bundles.
- **Run-directory naming.** If the mandated receipt directory name does not match the
  active agent, **do not silently rename it** — the path is fixed by the
  constitution. Follow it; renaming is a `speckit-constitution` change, not an
  ad-hoc edit. (As of constitution v1.5.0 this directory is the agent-neutral
  `agent-runs/`.)

## Claude-native affordances (how to run each step)

- **Invoke core skills with the Skill tool**, not shell aliases. Use
  `speckit-constitution`, `speckit-specify`, `speckit-clarify`, `speckit-checklist`,
  `speckit-plan`, `speckit-tasks`, `speckit-analyze`, `speckit-implement`.
- **Track bundles and tasks with the task list.** At the start of a run, create a
  task per bundle with `TaskCreate`; mark each `in_progress`/`completed` with
  `TaskUpdate`. During implementation, mirror `tasks.md` entries as tasks so the
  user sees live progress.
- **Run human gates with `AskUserQuestion`,** not a plain-text lettered menu.
  Present the gate's options as structured choices (the tool always adds an
  "Other" escape). Record the selected option verbatim in `human-loop.md`.
- **Verify with the MATLAB MCP server** when MATLAB work is involved: prefer
  `mcp__matlab__check_matlab_code` for static checks, `mcp__matlab__run_matlab_test_file`
  for the narrowest relevant test, and `mcp__matlab__run_matlab_file` /
  `mcp__matlab__evaluate_matlab_code` for reproducibility checks. Follow the
  project's MATLAB workflow doc for diaries/logs. Capture solver status strings
  and residuals faithfully.
- **Use a subagent for independent review** (Gate 2 option "independent review")
  via the Task tool, so the review does not share the implementing context.
- **Surface review artifacts** to the user with `present_files`
  (`implementation-review.md`, comparison reports, diffs).

## Hook awareness

If `.specify/extensions.yml` exists with `auto_execute_hooks: true`, each embedded
core command may trigger `before_*`/`after_*` hooks (for example git auto-commit
and agent-context refresh). Because a bundle runs several phases in sequence, this
can produce several commit prompts. At the start of a bundle, tell the user that
per-phase hooks will fire, and offer to (a) let each hook prompt as configured, or
(b) defer commits and make one commit at the end of the bundle. Never disable
hooks silently.

## Orchestration state file

Maintain `specs/<feature>/human-loop.md` once the feature directory exists (create
it immediately after `speckit-specify` creates the directory). Keep it lightweight;
it indexes the run and points at the constitutional receipt rather than copying it.

```markdown
# Human Loop State

## Current State
- Status:
- Active feature directory:
- Last completed bundle:
- Source code modified by this workflow: yes/no

## Core Command Ledger
- constitution:   (checked | invoked | n/a)
- specify:
- clarify:
- checklist:
- plan:
- tasks:
- analyze:
- implement:

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|

## Approved Implementation Scope
- Approved: no
- Scope: (all | slice:<phase/task ids>)
- Tasks approved:
- Tasks deferred:
- Files allowed:
- Files not allowed:

## Pointers
- Implementation receipt(s): <path(s) under the constitution's receipt ledger>
- Implementation review: specs/<feature>/implementation-review.md

## Open Risks and Ambiguities
```

## Bundle 0: project and phase detection

1. Confirm the current directory is inside a Git repository and `.specify/` exists.
   If not, stop and ask the user to run `specify init` or give the correct root.
2. Read `.specify/memory/constitution.md` and apply "Constitution reconciliation".
3. Check `git status`; warn if uncommitted source changes already exist.
4. Determine the active feature from the current branch and `specs/`.
5. Confirm the core skills are installed under `.claude/skills/speckit-*` (fall
   back to `.agents/skills/` or `.specify/templates/commands/` only if needed).
6. Decide the requested mode: `start`, `prepare`, `implement`, `continue`, or
   `closeout`. If unclear, ask with `AskUserQuestion`:
   - Start a new human-gated workflow from this request.
   - Continue the active feature workflow.
   - Prepare the implementation review for the active feature.
   - Implement the approved task scope.
   - Verify and close out the active feature.

## Bundle 1: requirements preparation

Embedded core skills, in order:

1. `speckit-constitution` — **check, do not regenerate**. If the constitution is
   missing, stop and ask for governing principles (or invoke it if the user
   supplied enough detail). If present, read it and record `constitution: checked`.
   Only invoke it to create/revise principles when the user explicitly asks.
2. `speckit-specify` with the feature request.
3. `speckit-clarify`. If it raises blocking questions, stop at Gate 1.
4. `speckit-checklist`. If failures are blocking, stop at Gate 1.

Ensure `human-loop.md` exists and records completed commands. Then **Gate 1**.

### Gate 1 — requirements decision (`AskUserQuestion`)

Options:
- Continue to implementation-preparation bundle.
- Revise the specification, then re-run clarify and checklist.
- Answer remaining clarification questions.
- Split this into smaller features.

No source code has been modified. Record the choice.

## Bundle 2: implementation preparation

Embedded core skills, in order:

1. `speckit-plan` (use the user's technical constraints; ask only for missing
   required constraints).
2. `speckit-tasks`.
3. `speckit-analyze` — classify findings as blocking / should-fix / acceptable /
   deferred.
4. Write `specs/<feature>/implementation-review.md` (no source edits):

```markdown
# Implementation Review

## Summary
## Embedded Core Commands Completed
- constitution / specify / clarify / checklist / plan / tasks / analyze:
## Cross-Artifact Analysis Summary
## Proposed Implementation Scope
- Tasks proposed:
- First independently testable slice:
- Files likely to change:
- Files that should NOT change:
## Tests and Validation Expected (name the narrowest relevant test first)
## Blocking Issues
## Acceptable Risks
## Human Approval
- Approved: no
- Approved option:
- Approved tasks/scope:
- Required implementation invocation per constitution:
- Date (UTC):
```

`present_files` the review, then **always** stop at Gate 2.

### Gate 2 — implementation approval (`AskUserQuestion`)

Options:
- Approve implementation of all proposed tasks.
- Approve only the first independently testable slice (name it, e.g. a single plan phase).
- Revise the task list, then re-run analyze.
- Revise the plan, then re-run tasks and analyze.
- Run an independent review (subagent) before deciding.

Only "approve all" or "approve a slice" can authorize edits — **and only then via
the constitution's required implementation invocation** (see reconciliation).
Record the approved scope in both `human-loop.md` and `implementation-review.md`.

## Bundle 3: approved implementation

Preconditions: `implementation-review.md` exists; `human-loop.md` records explicit
approval; the approved scope is "all" or a named slice; and the user has supplied
the constitution's required implementation invocation if one is mandated.

1. Mirror the approved `tasks.md` entries into the task list.
2. Invoke `speckit-implement`, constrained to the approved scope. Do not edit
   source directly and do not bypass `speckit-implement`.
3. Follow task order/dependencies from `tasks.md`. Stay inside the approved files;
   if a change outside scope is genuinely required to keep tests meaningful, record
   it as a deviation rather than silently expanding scope.
4. Apply constitution coding standards as you go (e.g. MATLAB `evalc`/warning rules).
5. Run the narrowest relevant test via the MATLAB MCP server (or the project's test
   harness) after the change.
6. Write the constitutional **implementation receipt** at its mandated path with the
   required sections (Prompt, Final response, Diff summary, Tests, Unresolved
   issues). The `Final response` must be the actual final user-facing completion
   text, not a paraphrase. Point `human-loop.md` at the receipt.

## Bundle 4: verification and closeout

1. Inspect `git diff --stat` and `git diff`.
2. Compare the work against `tasks.md` and `implementation-review.md`.
3. Run or report tests (narrowest relevant first; use the MATLAB MCP server when
   applicable). Preserve exact solver status strings and residual scale labels.
4. Optionally re-run `speckit-analyze` post-implementation (does not replace the
   pre-implementation analyze).
5. Update `human-loop.md`: diff summary, tests, unresolved issues, deviations,
   next recommended choice. Confirm the constitutional receipt is complete.
6. **Gate 3** with `AskUserQuestion`.

### Gate 3 — closeout decision

Options:
- Accept and close the feature.
- Continue with the next approved slice.
- Fix failing tests.
- Reconcile implementation drift by updating spec/plan/tasks.
- Revert selected changes.
- Open a follow-up specification.

## Gate discipline

- Use `AskUserQuestion` with at most four primary options (the tool adds "Other").
- State the safe default when there is one.
- Record the exact option chosen and its consequence in `human-loop.md`.
- Continue automatically only after a choice that permits continuation.

## Stop conditions

Stop rather than auto-continuing if: a core skill is missing; the active feature
is undeterminable; the constitution is missing and the user has not supplied
principles; clarify/checklist/analyze report blocking issues; source code would be
modified before Gate 2 approval (or before the constitution's required implement
invocation); the approved scope cannot be enforced; or tests fail when the mode
was not test repair.

## Concise progress report (after each bundle)

```text
Completed:
- Core skills run:
- Files created/updated:
- Source code modified: yes/no
- Receipt path (if implemented):
- Next human gate:
```
