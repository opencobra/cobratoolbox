# Implementation Review

## Summary

Feature 008-sdd-workflow-grafts folds five SDD-tooling mechanisms into this
project's own `.specify/` machinery and constitution — single-sourced and
gate-safe, no third-party extension. Requirements, plan, and tasks are complete and
mutually consistent (100% requirement→task coverage, 0 blocking findings). This is a
documentation/machinery-only change: it ships no `.m` code, so validation is the
documented reproducibility check in `quickstart.md` (V1–V6), not a MATLAB test.

## Embedded Core Commands Completed

- constitution: **checked** (v1.2.0; not regenerated)
- specify: **invoked** (spec.md + checklists/requirements.md)
- clarify: **invoked** (3 clarifications integrated, Session 2026-07-14)
- checklist: requirements.md **16/16 pass**
- plan: **invoked** (plan.md, research.md, data-model.md, quickstart.md)
- tasks: **invoked** (tasks.md, 15 tasks across 8 phases)
- analyze: **invoked** (read-only; report below)

## Cross-Artifact Analysis Summary

- **Coverage**: 19 requirements (12 FR + 7 SC) → 15 tasks; **100%** have ≥1 task; no
  unmapped tasks.
- **Clarifications consistency**: module index = conditional→**dropped** (FR-008,
  research R1, data-model E5, tasks T012, quickstart V5); characterization =
  **in-template mode** (FR-004, data-model E1b, tasks T006, quickstart V2);
  phantom-completion = **generalized evidence** (FR-005, data-model E3, tasks T008,
  quickstart V3) — all consistent across artifacts.
- **Gate-safety**: no task edits `src/**`/`test/**`/build/`extensions.yml`; T005
  routed through `/speckit-constitution`; single-sourcing (Principle X) preserved.
- **Findings**: F1 MEDIUM/should-fix (diff-scope validation must exclude pre-existing
  007/bookkeeping changes carried onto this branch); F2/F3 LOW/acceptable; D1
  DEFERRED (plan-template cross-spec drift → follow-up feature). **0 blocking.**

## Proposed Implementation Scope

- **Tasks proposed**: T001–T015 (all).
- **First independently testable slice**: **US1 (Traceability)** = T001–T004 (MVP) —
  edit `spec-template.md` to add the `## Traceability` section, validate per V1.
- **Files likely to change**:
  - `.specify/templates/spec-template.md` (Traceability + Characterization Mode)
  - `.specify/templates/checklist-template.md` (Completion Integrity assertion)
  - `.specify/templates/red-team-checklist-template.md` (NEW)
  - `.specify/memory/constitution.md` (Principle III clause, via `/speckit-constitution`, MINOR bump)
  - `specs/008-sdd-workflow-grafts/agent-runs/.../implementation-receipt.md` (NEW receipt)
- **Files that should NOT change**: any `src/**`, `test/**`, build/CI,
  `.specify/extensions.yml`, `external/`, `deprecated/`, `documentation/**` (graft #5
  dropped), and features 001–007 artifacts.

## Tests and Validation Expected (narrowest first)

No MATLAB test (no code path). Validation = `quickstart.md`:
1. V1 Traceability table fills (one row per criterion; no-source form).
2. V3 phantom-completion flags a fake `[X]`; code-free task passes via artifact.
3. V4 red-team instantiation leaves spec/plan/tasks unchanged by diff.
4. V2 characterization clause single-sourced; template references it.
5. V5 no `documentation/` index; drop rationale recorded.
6. V6 diff scope confined to `.specify/` + `specs/008…`; no new hook; 001–007 untouched
   (apply F1: exclude pre-existing 007/bookkeeping changes from the diff base).

## Blocking Issues

None.

## Acceptable Risks

- F1 (should-fix): the gate-safety diff-scope check must be scoped to 008's branch
  point and exclude the pre-existing carried-over changes (untracked `specs/007/`,
  the `extensions.yml` human-loop line, `feature.json`→008). Handle at validation
  (T013), not a spec change.
- F2/F3 (LOW): minor Traceability header wording drift; `documentation/` allowed but
  unused; `feature.json` bookkeeping outside the listed surface — all consistent
  with intent.
- D1 (deferred): `plan-template.md` references a placement scheme absent from the
  constitution — out of scope; candidate follow-up feature.

## Human Approval

- Approved: intent yes (edits pending explicit implement invocation)
- Approved option: **Approve all tasks** (Gate 2)
- Approved tasks/scope: **all (T001–T015)**
- Required implementation invocation per constitution: an explicit
  `/speckit-implement` (or the exact override phrase) — a Gate 2 menu choice alone
  does NOT authorize edits (Principle VI). T005 additionally requires
  `/speckit-constitution`.
- Date (UTC): 2026-07-14
