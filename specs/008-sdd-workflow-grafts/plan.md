# Implementation Plan: Native SDD-workflow grafts

**Branch**: `008-sdd-workflow-grafts` | **Date**: 2026-07-14 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/008-sdd-workflow-grafts/spec.md`

## Summary

Fold five valuable SDD-tooling mechanisms into this project's own `.specify/`
machinery and constitution — no third-party extension installed — each
single-sourced and gate-safe. Primary requirement: a new feature should naturally
produce a filled traceability matrix, be runnable in a sanctioned characterization
mode, carry a phantom-completion assertion and a pre-plan red-team checklist, and
(only if not redundant) have a module index. Research resolved graft #5 to **drop
as redundant** (Principle IX + `analysis/ARCHITECTURE.md` +
`documentation/source/modules/index.rst` already cover it), the characterization
clause to **Principle III via `/speckit-constitution`**, and the four template
grafts to concrete additive insertion points (see `research.md`, `data-model.md`).

Net change surface: edit `spec-template.md`, `checklist-template.md`, and (via
`/speckit-constitution`) `constitution.md`; add one new template
`red-team-checklist-template.md`; create **no** `documentation/` file.

## Technical Context

**Language/Version**: N/A — documentation/machinery only (Markdown templates + the
Markdown constitution). No programming language, compiler, or runtime.

**Primary Dependencies**: None. Uses the installed Spec Kit core skills
(`/speckit-constitution` for the constitution clause) and the existing template
resolution stack.

**Storage**: N/A (files in `.specify/`).

**Testing**: No automated (MATLAB) test — this feature ships no `.m` code. Validation
is a documented reproducibility check (`quickstart.md`): author a spec and confirm
the Traceability table fills; introduce a fake `[X]` and confirm the
phantom-completion assertion flags it; run the red-team checklist and confirm
spec/plan/tasks are unchanged by diff; confirm diff scope is confined to `.specify/`
and features 001–007 are untouched. This is the Principle III "documented
reproducibility check" substitute, appropriate because there is no code path.

**Target Platform**: The Spec Kit workflow itself (agent-neutral: Claude, Codex).

**Project Type**: Process/machinery change to an existing brownfield MATLAB toolbox.

**Performance Goals**: N/A (no runtime/solver).

**Constraints**: Single-sourcing (Principle X); gate-safety (no new lifecycle hook,
no third-party extension, no `src/**`/`test/**`/build edits); backward-compatible
per-feature artifact structure (features 001–007 need no migration).

**Scale/Scope**: 3 edited files + 1 new template file + 1 constitution clause;
0 new documentation files (graft #5 dropped).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.* — **PASS**
(pre- and post-design; no violations).

- **Scientific code quality**: N/A — no formulation, solver, model field, or public
  interface is touched. The feature edits SDD templates and the constitution only.
- **Testing and reproducibility**: No MATLAB test (no code shipped). The narrowest
  checks are the reproducibility steps in `quickstart.md` (traceability fills;
  phantom-completion catches a fake `[X]`; red-team leaves spec/plan/tasks unchanged;
  diff scope confined to `.specify/`; 001–007 unchanged). Permitted under Principle
  III as a documented reproducibility check where automation does not apply.
- **User experience and diagnostics**: Consumers are contributors, Spec Kit agents,
  and reviewers. Grafts improve auditability (criterion→test traceability,
  completion integrity, pre-plan risk). No console/diagnostic/print-level behaviour.
- **Performance and numerical integrity**: N/A — no solver, runtime, residual, or
  diagnostic-volume surface. No skippable verification introduced.
- **External-solver configuration audit**: N/A — no external solver/library invoked.
- **Spec-driven scope control**:
  - Files to edit: `.specify/templates/spec-template.md`,
    `.specify/templates/checklist-template.md`,
    `.specify/memory/constitution.md` (via `/speckit-constitution` only).
  - New file: `.specify/templates/red-team-checklist-template.md` (justified — a
    distinct pre-plan artifact type; folding into `checklist-template.md` would
    conflate two artifacts run at different phases).
  - Read-only / must NOT touch: `src/**`, `test/**`, build/CI files,
    `.specify/extensions.yml`, `external/`, `deprecated/`, and any existing
    per-feature artifact of 001–007.
  - Graft #5: no `documentation/` file created (dropped as redundant — `research.md` R1).
- **MATLAB coding standards**: N/A — no `.m` file is created or modified; the
  `evalc`/warning/`ME.stack`/`nargin` rules have no surface here.
- **Parameter-setting fidelity**: N/A — nothing is ported or rendered into another
  language or a literate document; no `param.*` assignments are involved.
- **Artifact placement**: Every change lands in `.specify/` machinery
  (`templates/`, `memory/`) or `specs/008-sdd-workflow-grafts/`, per Principle IX
  (`.specify/` is the Spec Kit machinery home). No generated output enters `src/` or
  `documentation/`. Compliant.

**Single-sourcing (Principle X) confirmation**: the characterization pattern lives
in exactly one place (Principle III clause); templates reference it, not restate it.
Graft #5 is dropped precisely to avoid a fourth copy of the domain map.

## Project Structure

### Documentation (this feature)

```text
specs/008-sdd-workflow-grafts/
├── spec.md              # feature spec (+ Clarifications 2026-07-14)
├── plan.md              # this file
├── research.md          # Phase 0: R1 drop graft #5, R2 clause placement, R3 insertion points
├── data-model.md        # Phase 1: per-artifact change contracts + wording drafts
├── quickstart.md        # Phase 1: reproducibility/validation guide
├── checklists/
│   └── requirements.md   # spec-quality checklist (16/16)
├── human-loop.md        # orchestration state (this run)
└── tasks.md             # Phase 2 output (/speckit-tasks) — not created by plan
```

(No `contracts/` — this feature exposes no external/API/CLI interface; it is
internal SDD machinery.)

### Change map (repository)

```text
.specify/templates/spec-template.md               # EDIT: + ## Traceability; + Characterization Mode block
.specify/templates/checklist-template.md          # EDIT: + ## Completion Integrity (standing)
.specify/templates/red-team-checklist-template.md # NEW: pre-plan red-team template (findings-only)
.specify/memory/constitution.md                   # EDIT via /speckit-constitution: + Principle III characterization clause (MINOR bump)
documentation/                                     # NO CHANGE (graft #5 dropped as redundant)
```

**Structure Decision**: Documentation/machinery-only change confined to
`.specify/templates/` and `.specify/memory/`. No source-tree option applies (no
`src/`, `test/`, or language subtree is involved).

## Complexity Tracking

No Constitution Check violations — table intentionally empty. Two decisions worth
recording (both within `.specify/` machinery, neither a violation):

| Decision | Why | Rejected alternative |
|----------|-----|----------------------|
| Add one new template file `red-team-checklist-template.md` | Red-team runs at a different phase (pre-plan) and is findings-only; a distinct artifact type | A section inside `checklist-template.md` — conflates two artifacts and muddies the generic checklist |
| Drop graft #5 (no `documentation/` index) | Domain map already single-sourced in Principle IX + `analysis/ARCHITECTURE.md` + `documentation/source/modules/index.rst` | Build/pointer — triple redundancy and drift (Principle X) |
