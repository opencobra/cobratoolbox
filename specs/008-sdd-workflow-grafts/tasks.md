# Tasks: Native SDD-workflow grafts

**Input**: Design documents from `specs/008-sdd-workflow-grafts/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md (all present)

**Tests**: This is a documentation/machinery-only feature — no `.m` code ships, so
no executable MATLAB test is required. Validation is the documented reproducibility
check in `quickstart.md` (V1–V6), permitted under Constitution Principle III.

**Organization**: Tasks are grouped by user story (each = one graft), in priority order.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1–US5 map to the five grafts in spec.md
- Exact file paths are included in each task

## Path note

All edits are confined to `.specify/templates/`, `.specify/memory/constitution.md`
(via `/speckit-constitution` only), and this feature's `specs/` dir. No `src/**`,
`test/**`, build/CI, or `.specify/extensions.yml` changes (FR-010).

---

## Phase 1: Setup

- [X] T001 Confirm the scoped change surface before editing: only
  `.specify/templates/spec-template.md`, `.specify/templates/checklist-template.md`,
  `.specify/memory/constitution.md`, and a NEW
  `.specify/templates/red-team-checklist-template.md` may be touched (per
  `specs/008-sdd-workflow-grafts/plan.md` Change map). No `documentation/` file
  (graft #5 dropped).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Fix the validation frame that all stories are checked against.

- [X] T002 Confirm `specs/008-sdd-workflow-grafts/quickstart.md` V1–V6 are the
  reproducibility checks for this feature (documented-check substitute per
  Constitution Principle III; MATLAB coding-standards check is N/A — no `.m` file
  is created or modified, record this in the receipt).

**Checkpoint**: Validation frame fixed — story work can begin.

---

## Phase 3: User Story 1 - Traceability matrix (Priority: P1) 🎯 MVP

**Goal**: `spec-template.md` yields a filled criterion→test→source-function matrix,
with a no-source convention for docs/tooling features.

**Independent Test**: A spec authored from the template contains a `## Traceability`
section with one row per acceptance criterion (quickstart V1).

- [X] T003 [US1] Edit `.specify/templates/spec-template.md`: append a `## Traceability`
  section after `## Assumptions` — the three-column table (criterion → discharging
  test → `src/<domain>/` function) plus the guidance comment including the no-source
  convention, per `data-model.md` E1a.
- [X] T004 [US1] Validate US1 per `quickstart.md` V1: exactly one row per criterion,
  no orphan rows, no-source form available (compare against this feature's own
  `spec.md` Traceability table).

**Checkpoint**: Traceability graft complete and independently verifiable.

---

## Phase 4: User Story 2 - Characterization back-fill mode (Priority: P2)

**Goal**: A single-sourced constitution clause defines the characterization pattern,
and `spec-template.md` offers an in-template mode that references it.

**Independent Test**: The pattern is defined once (Principle III clause) and usable
via the template's Characterization Mode block (quickstart V2).

- [X] T005 [US2] Apply the characterization / legacy back-fill clause to Constitution
  **Principle III** via **`/speckit-constitution`** (NOT a raw edit) — MINOR bump
  (1.2.0 → 1.3.0) with a Sync Impact Report and dependent-template review, per
  `data-model.md` E2.
- [X] T006 [US2] Edit `.specify/templates/spec-template.md`: add the optional
  Characterization Mode comment after the `**Input**` line and the
  `## Existing Contract *(characterization mode only)*` section after
  `## Requirements`, **referencing** the Principle III clause (not restating it),
  per `data-model.md` E1b. (Depends on T005 so the referenced clause exists; same
  file as T003 so runs after it.)
- [X] T007 [US2] Validate US2 per `quickstart.md` V2: clause single-sourced, template
  references it, per-feature artifact structure preserved.

**Checkpoint**: Characterization mode complete; single-sourcing preserved.

---

## Phase 5: User Story 3 - Phantom-completion assertion (Priority: P3)

**Goal**: Every generated checklist carries a standing assertion that each `[X]`
task maps to a real change + verification evidence.

**Independent Test**: A fake `[X]` with no diff is flagged; a code-free task passes
via a named artifact (quickstart V3).

- [X] T008 [P] [US3] Edit `.specify/templates/checklist-template.md`: add the
  standing `## Completion Integrity *(standing — always retained)*` item with the
  generalized-evidence wording (diff hunk OR named non-code artifact, AND a test
  that ran OR an equivalent validation check), placed distinctly from the
  illustrative sample block, per `data-model.md` E3.
- [X] T009 [US3] Validate US3 per `quickstart.md` V3: fake `[X]` flagged; code-free
  task satisfied by artifact.

**Checkpoint**: Phantom-completion guard complete.

---

## Phase 6: User Story 4 - Pre-plan red-team checklist (Priority: P4)

**Goal**: A findings-only pre-plan risk checklist exists as a template, never edits
specs.

**Independent Test**: Instantiating and completing it leaves the feature's
spec/plan/tasks unchanged by diff (quickstart V4).

- [X] T010 [P] [US4] Create NEW `.specify/templates/red-team-checklist-template.md`:
  findings-only header (MUST NOT edit spec/plan/tasks — Principle VI; run before
  `/speckit-plan`) plus three categories — integrity gaps, silent failures,
  cross-spec drift — each a probing question, and a Findings section, per
  `data-model.md` E4.
- [X] T011 [US4] Validate US4 per `quickstart.md` V4: template present; a completed
  instantiation changes no `spec.md`/`plan.md`/`tasks.md` (git diff check).

**Checkpoint**: Red-team lens available and gate-consistent.

---

## Phase 7: User Story 5 - Module index (conditional → dropped) (Priority: P5)

**Goal**: Record the redundancy determination; create no duplicate index.

**Independent Test**: No `documentation/` index file exists; the drop rationale is
recorded (quickstart V5).

- [X] T012 [US5] Record/verify the graft #5 drop: confirm `research.md` R1 states the
  drop rationale citing Principle IX, `analysis/ARCHITECTURE.md`, and
  `documentation/source/modules/index.rst`, and confirm NO new `documentation/`
  file is created, per `quickstart.md` V5. (Verification-only; creates no file.)

**Checkpoint**: Graft #5 resolved as a recorded determination.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [X] T013 Run the full `quickstart.md` V1–V6 validation, including V6 gate-safety:
  `git diff` scope confined to `.specify/` + `specs/008-sdd-workflow-grafts/`; no new
  hook in `.specify/extensions.yml`; no `src/**`/`test/**`/build change; features
  001–007 untouched.
- [X] T014 Report files edited, checks run, pass/fail results, and any unverified
  behavior.
- [X] T015 Create the implementation receipt at
  `specs/008-sdd-workflow-grafts/agent-runs/<UTC-timestamp>-<short-name>/implementation-receipt.md`
  with sections Prompt, Final response (the actual final user-facing completion text,
  verbatim), Diff summary, Tests, Unresolved issues.

---

## Dependencies & Execution Order

- **Setup (T001)** → **Foundational (T002)** → user stories.
- **US1 (T003–T004)**: MVP; edits `spec-template.md` first.
- **US2 (T005–T007)**: T005 (`/speckit-constitution`) precedes T006 (template
  reference to the clause); T006 edits `spec-template.md` after T003 (same file).
- **US3 (T008–T009)** and **US4 (T010–T011)**: independent of US1/US2 and of each
  other — T008 and T010 touch different files and are marked **[P]**.
- **US5 (T012)**: verification-only; depends on `research.md` (already complete).
- **Polish (T013–T015)**: after all stories.

### Parallel opportunities

- T008 (`checklist-template.md`) and T010 (`red-team-checklist-template.md`) can run
  in parallel — different files, no shared state.
- US3, US4, US5 can proceed in parallel with US1/US2 except where they share
  `spec-template.md` (only US1 and US2 do).

## Implementation Strategy

- **MVP** = US1 (Traceability), the highest-value graft. Land and validate it first.
- Then US2 (characterization; requires the `/speckit-constitution` step), then US3/US4
  in parallel, then record US5, then polish + receipt.

## Notes

- The only new file is `.specify/templates/red-team-checklist-template.md`.
- T005 MUST go through `/speckit-constitution`; it is the sole task that edits the
  constitution and it is gated separately.
- No task edits `src/**`, `test/**`, build/CI, or `.specify/extensions.yml`.
