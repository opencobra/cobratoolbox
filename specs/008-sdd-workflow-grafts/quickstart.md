# Quickstart / Validation Guide: Native SDD-workflow grafts

How to prove each graft works after implementation. There is no MATLAB code, so
validation is documentation inspection + `git diff` scope checks, not a test run.
Run these from the repo root.

## Prerequisites

- On branch `008-sdd-workflow-grafts` with the implementation applied.
- The `/speckit-constitution` clause (E2) has been applied and the constitution
  version bumped with a Sync Impact Report.

## V1 — Traceability section fills (Graft #1, FR-001/002, SC-001)

1. Confirm `spec-template.md` ends with a `## Traceability` section containing the
   three-column table and the no-source-convention comment:
   `grep -n "## Traceability" .specify/templates/spec-template.md`
2. Author (or re-open) a feature spec from the template and fill the table. Expected:
   exactly one row per acceptance criterion; each row names a test and a
   `src/<domain>/` function, OR uses `— (no source function)` + the discharging
   artifact for a docs/tooling feature. No orphan rows.
   - This feature's own `spec.md` already models the no-source form — compare against it.

## V2 — Characterization mode is available and single-sourced (Graft #2, FR-003/004, SC-002)

1. Confirm the constitution has exactly one characterization clause:
   `grep -rn "haracterization" .specify/memory/constitution.md` → the Principle III
   clause is the only normative definition.
2. Confirm `spec-template.md` has the optional Characterization Mode comment + the
   `## Existing Contract *(characterization mode only)*` section, and that it
   **references** the Principle III clause rather than restating it:
   `grep -n "Existing Contract\|Characterization" .specify/templates/spec-template.md`
3. Negative check (single-sourcing): the pattern's steps are not duplicated in the
   template — the template points to the clause.

## V3 — Phantom-completion assertion catches a fake completion (Graft #3, FR-005, SC-003)

1. Confirm the standing item exists and survives generation:
   `grep -n "Completion Integrity" .specify/templates/checklist-template.md`
2. Demonstration: in a scratch copy of a `tasks.md`, mark a task `[X]` that has no
   diff/artifact behind it and evaluate the assertion → it MUST flag that task.
3. Confirm a legitimately code-free task passes by naming its artifact (the
   generalized-evidence branch), not by requiring a MATLAB test.

## V4 — Red-team is findings-only (Graft #4, FR-006/007, SC-004)

1. Confirm the template exists:
   `test -f .specify/templates/red-team-checklist-template.md && echo present`
2. Instantiate it to `specs/<somefeature>/checklists/red-team.md`, complete it, then
   run: `git diff --name-only` and confirm that feature's `spec.md`, `plan.md`, and
   `tasks.md` are NOT in the changed set (findings-only; Principle VI).

## V5 — Module index correctly absent (Graft #5, FR-008, SC-005)

1. Confirm NO new `documentation/` module-index file was added:
   `git diff --name-only origin/develop... | grep '^documentation/' || echo "none (expected)"`
2. Confirm the drop rationale is recorded (`research.md` R1 cites Principle IX,
   `analysis/ARCHITECTURE.md`, `documentation/source/modules/index.rst`).

## V6 — Gate-safety and backward compatibility (FR-009/010/011/012, SC-006/007)

1. Diff scope confined to `.specify/` (+ this feature's `specs/` dir):
   `git diff --name-only origin/develop...` → only `.specify/templates/*`,
   `.specify/memory/constitution.md`, and `specs/008-sdd-workflow-grafts/*`.
2. No new lifecycle hook: `git diff .specify/extensions.yml` → empty (no hook added;
   the pre-existing `human-loop` install line is unrelated).
3. No toolbox changes: `git diff --name-only origin/develop... | grep -E '^(src|test)/|Makefile|\.github/' || echo "none (expected)"`.
4. Features 001–007 untouched:
   `git diff --name-only origin/develop... | grep -E '^specs/00[1-7]' || echo "none (expected)"`.

## Done when

All of V1–V6 pass and the constitutional implementation receipt is written under
`specs/008-sdd-workflow-grafts/agent-runs/<UTC-timestamp>-<short-name>/`.
