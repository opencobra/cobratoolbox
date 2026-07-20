# Feature Specification: Native SDD-workflow grafts (traceability, characterization mode, phantom-completion, red-team, module index)

**Feature Branch**: `008-sdd-workflow-grafts`

**Created**: 2026-07-14

**Status**: Draft

**Input**: User description: "Adopt selected Spec Kit community-extension mechanisms as native additions to this project's own templates and constitution — no third-party extensions installed — preserving single-sourcing. Five documentation-only grafts: (1) traceability matrix in spec-template; (2) characterization / legacy back-fill spec mode as a constitution clause plus a lightweight spec-template variant; (3) phantom-completion assertion in checklist-template; (4) pre-plan red-team risk checklist; (5) per-domain module index under documentation/, only if not redundant. Changes touch only .specify/ machinery and documentation/. No new lifecycle hooks; no toolbox source/test/build changes. Each graft single-sourced and gate-safe."

## Clarifications

### Session 2026-07-14

- Q: Graft #5 (per-domain module index) — build it, drop it as redundant, or make it a pointer only? → A: **Conditional build** — keep FR-008 as written: run the redundancy check during planning; build a full index only if it is NOT already covered by Constitution Principle IX and the existing architecture overview, otherwise drop it with a recorded rationale (at most a pointer).
- Q: The characterization "lightweight variant" — a separate template file or a selectable mode within `spec-template.md`? → A: **In-template mode** — add a selectable "Characterization Mode" section/guidance block inside the existing `spec-template.md`; one canonical template, single-sourced (Principle X), with no separate file to drift.
- Q: How does the phantom-completion assertion apply to documentation-only features that have no MATLAB test? → A: **Generalize the evidence** — every `[X]` maps to a diff hunk (or named non-code artifact) AND verification evidence: a test that actually ran, or an equivalent validation check for non-code work (e.g. checklist re-validation, diff-scope check).

## User Scenarios & Testing *(mandatory)*

The "users" of this feature are the people and agents who operate the spec-driven
development (SDD) workflow in this repository: contributors authoring features,
Spec Kit agents (Claude, Codex, others) executing the phases, and reviewers or
maintainers auditing per-feature artifacts. The "product" they consume is the set
of `.specify/` templates and the constitution; the value is a workflow that ties
every acceptance criterion to the test that discharges it, sanctions the
back-fill pattern already used by hand, and catches phantom completions and
cross-spec drift before they reach implementation.

### User Story 1 - Every acceptance criterion traces to the test that discharges it (Priority: P1)

A contributor specifies a new coverage feature. Because the spec template now
carries a **Traceability** section, the finished `spec.md` contains a table with
one row per acceptance criterion, each row naming the test that proves the
criterion and the `src/<domain>/` function under test. A reviewer can read the
table and confirm, without cross-referencing prose, that no criterion is left
undischarged and no test is orphaned.

**Why this priority**: The whole spec program to date is coverage-driven, yet
nothing structurally ties a criterion to the test that satisfies it. This is the
single highest-value graft: it makes the coverage intent auditable per feature.

**Independent Test**: Specify any feature using the updated template and confirm
its `spec.md` contains a Traceability section with exactly one row per acceptance
criterion, each mapping criterion → test name → source function (or the explicit
no-source convention for a docs/tooling feature). Delivered value: a reviewer can
verify criterion→test coverage at a glance.

**Acceptance Scenarios**:

1. **Given** the updated spec template, **When** a new feature spec is authored,
   **Then** the spec contains a `## Traceability` section whose table has one row
   per acceptance criterion, each row naming a test and a `src/<domain>/`
   function under test.
2. **Given** a documentation- or tooling-only feature that exercises no source
   function, **When** its Traceability table is filled, **Then** each row uses the
   documented no-source convention (naming the artifact/check that discharges the
   criterion) rather than being left blank or omitted.
3. **Given** a filled Traceability table, **When** a reviewer scans it, **Then**
   every acceptance criterion appears exactly once and every listed test maps to a
   real criterion (no orphan rows).

---

### User Story 2 - Legacy back-fill can be run in a sanctioned characterization mode (Priority: P2)

A contributor picks an untested legacy function surfaced by CI coverage and wants
to document its *existing* contract and write a characterization test — the exact
pattern features 004 and 006 executed by hand. Because the constitution now names
this pattern and a lightweight characterization spec variant exists, the
contributor follows a sanctioned mode that captures current behaviour instead of
inventing new requirements, and does so in a single canonical, referenced format.

**Why this priority**: This pattern is already the backbone of the repository's
coverage work (004, 006) but is undocumented, so each feature re-invents it.
Naming it makes it repeatable and reviewable, and prevents drift between ad hoc
retro-specs.

**Independent Test**: Author a characterization spec for an untested function
using the in-template characterization mode and confirm it documents the
function's existing inputs/outputs/invariants (not new requirements) and cites the
constitution's characterization clause as its single source. Delivered value: a
repeatable, single-sourced back-fill mode.

**Acceptance Scenarios**:

1. **Given** the constitution's characterization clause, **When** a contributor
   selects an untested legacy function from coverage, **Then** the clause defines
   the required steps (identify the untested function, document its EXISTING
   contract, write a characterization test) in exactly one canonical location.
2. **Given** the in-template characterization mode, **When** it is used,
   **Then** it prompts for *current* behaviour (existing inputs, outputs,
   invariants, tolerances) rather than net-new functional requirements.
3. **Given** the characterization mode, **When** it is compared to the standard
   spec template, **Then** it produces the same per-feature artifact structure
   (`spec.md`, `plan.md`, `tasks.md`, `checklists/`) so downstream phases are
   unchanged.

---

### User Story 3 - Completed tasks cannot be phantom-completed (Priority: P3)

A reviewer closes out a feature. Because the checklist template now carries a
required phantom-completion assertion, they verify that every `[X]` task in
`tasks.md` maps to a real diff hunk (or a named non-code artifact for
research/decision tasks) and to a test that actually ran. A task marked done with
no corresponding change or test is caught before the feature is accepted.

**Why this priority**: The repository already keeps an implementation-receipt
ledger (`agent-runs/`) and an implementation review, but nothing structurally
asserts that a checked-off task produced a real, tested change. This closes a
known integrity gap and reinforces existing controls.

**Independent Test**: Add the phantom-completion assertion to a feature's
checklist, mark a task `[X]` that has no diff/artifact behind it, and confirm the
assertion flags it. Delivered value: checked-off work is provably real.

**Acceptance Scenarios**:

1. **Given** the updated checklist template, **When** a checklist is generated,
   **Then** it contains a required item asserting every `[X]` in `tasks.md` maps to
   a real diff hunk (or named non-code artifact) and a passing/among-the-run test.
2. **Given** a `tasks.md` with a task marked `[X]` but no corresponding diff or
   artifact, **When** the assertion is evaluated, **Then** it fails and identifies
   the phantom task.
3. **Given** a legitimately code-free task (e.g., a research or decision task),
   **When** the assertion is evaluated, **Then** it is satisfied by pointing to the
   named artifact rather than requiring a code diff.

---

### User Story 4 - Risks are surfaced before planning, without touching the spec (Priority: P4)

Before a feature moves from spec to plan, a contributor runs a pre-plan red-team
checklist that scans for integrity gaps, silent-failure modes, and cross-spec
drift. It records findings only; it never edits `spec.md`, `plan.md`, or
`tasks.md`. Any real issue it surfaces is resolved through the normal spec-edit
route, keeping the Principle VI gate intact.

**Why this priority**: Mature SDD tooling surfaces risk before design commits to
an approach. A findings-only lens is fully consistent with the gate (it produces
no implementation and edits no spec), so it adds safety at no gate cost.

**Independent Test**: Run the red-team checklist against an existing feature and
confirm it emits findings into a checklist artifact while leaving `spec.md`,
`plan.md`, and `tasks.md` byte-for-byte unchanged. Delivered value: pre-plan risk
visibility with zero gate impact.

**Acceptance Scenarios**:

1. **Given** the red-team checklist, **When** it is run before `/speckit-plan`,
   **Then** it produces a findings-only artifact covering integrity gaps, silent
   failures, and cross-spec drift.
2. **Given** the red-team checklist run, **When** its output is compared against
   the feature's `spec.md`/`plan.md`/`tasks.md`, **Then** those files are unchanged
   (findings-only, never edits specs — Principle VI).
3. **Given** a red-team finding that warrants a spec change, **When** it is acted
   on, **Then** the change is made through the normal spec-edit flow, not by the
   checklist itself.

---

### User Story 5 - A per-domain module index exists only if it is not already covered (Priority: P5)

A maintainer wants a per-domain map of `src/<domain>/` under `documentation/`.
Before it is built, a redundancy check compares it against what already exists —
the agent-context managed section, Constitution Principle IX's domain/file-
placement map, and any existing architecture overview. If the map is not already
covered, it is created under `documentation/`; if it is redundant, the feature
records that determination and drops the graft, adding at most a pointer.

**Why this priority**: This graft is explicitly conditional. Building a second
architecture map that duplicates Principle IX or an existing overview would
violate single-sourcing (Principle X). It is lowest priority and may be dropped.

**Independent Test**: Perform the redundancy check and either (a) produce a module
index under `documentation/` covering all six `src/<domain>` domains, or (b)
record a written determination that it is redundant and cite the covering
artifact. Delivered value: either a maintained index or a documented reason not to
have one.

**Acceptance Scenarios**:

1. **Given** the redundancy check, **When** it finds the per-domain map is not
   already covered by agent-context or Principle IX, **Then** a module index is
   created under `documentation/` listing each `src/<domain>` domain and its
   modules.
2. **Given** the redundancy check, **When** it finds the map is already covered,
   **Then** the feature records the determination (citing the covering artifact)
   and does not create a duplicate index.
3. **Given** either outcome, **When** the result is reviewed, **Then** no rule or
   map is stated in two canonical places (single-sourcing preserved).

### Edge Cases

- **Docs/tooling feature with no source-under-test** (this feature is itself an
  example): the Traceability table must still be fillable via a documented
  no-source convention that names the artifact or check discharging each
  criterion, not a `src/<domain>/` function.
- **Non-deterministic function under characterization**: when the legacy function's
  output depends on a solver or random draw, the characterization test must pin
  behaviour with a fixed seed and a justified tolerance (per Constitution
  Principle III), not an exact-equality assertion.
- **Legitimately code-free completed task**: the phantom-completion assertion must
  accept a named non-code artifact (research note, decision record) in place of a
  diff hunk, or it will produce false positives on research/decision tasks.
- **Red-team finding requiring a spec change**: the mechanism must not edit the
  spec to "fix" its own finding; resolution routes back through the normal
  spec-edit flow so the Principle VI gate is never bypassed.
- **Module-index staleness**: if a module index is built, `src/` evolution will
  drift from it; the feature must state how the index stays current (or the drift
  risk is itself a reason to drop the graft in favour of Principle IX).
- **Backward compatibility of past features**: features 001–007 predate these
  grafts; the changes must not require any migration or re-authoring of their
  existing artifacts.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The spec template MUST gain a `## Traceability` section that yields
  one table row per acceptance criterion, each row mapping the criterion to the
  test name that discharges it and to the `src/<domain>/` function under test.
- **FR-002**: The Traceability section MUST define an explicit convention for
  features that exercise no source function (documentation/tooling features), so
  each criterion still maps to the artifact or check that discharges it rather
  than being left blank.
- **FR-003**: The constitution MUST gain a clause defining the
  characterization / legacy back-fill spec mode — select an untested legacy
  function from coverage, document its EXISTING contract, write a characterization
  test — as the single canonical description of the pattern already used by hand
  in features 004 and 006. This clause MUST be applied via `/speckit-constitution`.
- **FR-004**: A lightweight characterization mode MUST exist as a selectable
  section/guidance block WITHIN the existing `spec-template.md` (not a separate
  template file), capturing current behaviour (existing inputs, outputs,
  invariants, tolerances) rather than net-new requirements, while producing the
  same per-feature artifact structure as the standard template (single-sourced,
  Principle X).
- **FR-005**: The checklist template MUST include a required phantom-completion
  assertion: every `[X]` in `tasks.md` maps to a real diff hunk (or a named
  non-code artifact) AND to verification evidence — a test that actually ran, or
  an equivalent validation check for non-code work (e.g. checklist re-validation,
  diff-scope check).
- **FR-006**: A pre-plan red-team checklist MUST be defined, run before the plan
  phase, covering integrity gaps, silent failures, and cross-spec drift.
- **FR-007**: The red-team mechanism MUST be findings-only: it MUST NOT edit
  `spec.md`, `plan.md`, or `tasks.md`, consistent with Constitution Principle VI.
- **FR-008**: A per-domain module index of `src/<domain>/` under `documentation/`
  MUST be created ONLY IF a redundancy check first determines it is not already
  covered by the agent-context managed section and Constitution Principle IX;
  otherwise the feature MUST record the redundancy determination (citing the
  covering artifact) and drop the graft.
- **FR-009**: Every graft MUST be single-sourced — each new rule has exactly one
  canonical home, and any other file points to it rather than restating it
  (Constitution Principle X).
- **FR-010**: The feature MUST be gate-safe: it MUST NOT add any new lifecycle
  hook to `.specify/extensions.yml`, MUST NOT install any third-party extension,
  and MUST NOT modify any toolbox source, test, or build file.
- **FR-011**: The feature MUST preserve backward compatibility of the existing
  per-feature artifact structure (`spec.md`, `plan.md`, `tasks.md`, `checklists/`,
  `human-loop.md`, `implementation-review.md`, `agent-runs/`); features 001–007
  MUST remain valid with no migration.
- **FR-012**: Changes MUST be confined to `.specify/` machinery (templates,
  constitution) and `documentation/`; constitution clauses go through
  `/speckit-constitution` and template edits through the normal Spec Kit flow.

### Key Entities *(artifacts this feature changes)*

- **Spec template** (`.specify/templates/spec-template.md`): gains the
  Traceability section (FR-001/002) and a selectable in-template Characterization
  Mode block (FR-004).
- **Constitution** (`.specify/memory/constitution.md`): gains the characterization
  back-fill clause (FR-003); remains the single source for the grafted rules
  (FR-009).
- **Checklist template** (`.specify/templates/checklist-template.md`): gains the
  required phantom-completion assertion (FR-005).
- **Pre-plan red-team checklist**: a findings-only checklist artifact/section run
  before planning (FR-006/007).
- **Per-domain module index** (under `documentation/`): conditional artifact,
  created only if the redundancy check clears it (FR-008).
- **Per-feature artifact set** (`specs/<NNN>/…`): the consumer of the templates;
  its structure MUST remain backward compatible (FR-011).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A feature specified after the graft lands produces a `spec.md` whose
  Traceability table has exactly one row per acceptance criterion, each row naming
  a test and a source function (or the no-source convention), with no orphan rows.
- **SC-002**: The characterization back-fill pattern is described in exactly one
  canonical place (the constitution clause) and is usable via the in-template
  characterization mode, so a new back-fill feature needs no ad hoc format —
  measured by the pattern appearing once and being referenced, not restated,
  elsewhere.
- **SC-003**: Introducing a task marked `[X]` with no backing diff/artifact into a
  feature's `tasks.md` causes the phantom-completion assertion to fail and name the
  phantom task; a legitimately code-free task passes by naming its artifact.
- **SC-004**: Running the pre-plan red-team checklist against a feature yields a
  findings-only artifact while that feature's `spec.md`, `plan.md`, and `tasks.md`
  remain byte-for-byte unchanged (verified by diff).
- **SC-005**: The module-index redundancy determination is recorded; if the index
  is built it lists all six `src/<domain>` domains under `documentation/`, and if
  it is dropped the recorded rationale cites the covering artifact — in neither
  case is any map duplicated.
- **SC-006**: After the grafts land, the artifacts of features 001–007 are
  unchanged and still valid (no migration performed or required), and the full set
  of changes is confined to `.specify/` and `documentation/` (verified by diff
  scope).
- **SC-007**: `.specify/extensions.yml` gains no new lifecycle hook and no
  third-party extension is installed, and no toolbox source/test/build file is
  modified (verified by diff scope).

## Assumptions

- The consumers of these artifacts are contributors, Spec Kit agents, and
  reviewers operating the SDD workflow; there is no external end-user surface.
- "Test name" in the Traceability matrix refers to a test under
  `test/verifiedTests/<category>/` run by `test/testAll.m` and CI; "source
  function under test" refers to a function under `src/<domain>/`. The untested
  legacy functions targeted by characterization mode are those surfaced by the
  existing CI coverage program (features 001, 007).
- The constitution clause (FR-003) is applied during the implementation phase via
  `/speckit-constitution`, not by editing `constitution.md` in the specify phase;
  template and documentation edits go through the normal Spec Kit flow.
- The characterization "lightweight variant" is a selectable Characterization
  Mode section within the standard `spec-template.md` (resolved in clarification —
  not a separate file), constrained by FR-004 to preserve the standard
  per-feature artifact structure.
- Graft #5 is expected to be at least partially redundant with Constitution
  Principle IX's domain/file-placement map and any existing architecture overview;
  the default outcome, absent the redundancy check clearing it, is to reduce it to
  a pointer or drop it (Principle X).
- The phantom-completion assertion is evaluated by a human or agent reviewer at
  closeout against `tasks.md`, the diff, and the `agent-runs/` receipt; it defines
  the required check, not a new automated tool.
- No change to toolbox source, tests, or the build is in scope; all five grafts
  are documentation/machinery edits only.

## Traceability

*(Modelled per FR-001/FR-002. This feature exercises no `src/<domain>/` function,
so it uses the no-source convention: each acceptance criterion maps to the
artifact or check that discharges it. This section also dogfoods the graft it
proposes.)*

| Acceptance criterion | Discharging test / check | Artifact under change (no source function) |
|----------------------|--------------------------|--------------------------------------------|
| US1 / FR-001, FR-002 — Traceability section, incl. no-source convention | Inspect a newly authored `spec.md` for one row per criterion (SC-001) | `.specify/templates/spec-template.md` |
| US2 / FR-003, FR-004 — characterization clause + in-template mode | Pattern appears once, referenced not restated; mode preserves artifact structure (SC-002) | `.specify/memory/constitution.md`; `spec-template.md` Characterization Mode block |
| US3 / FR-005 — phantom-completion assertion | Fake `[X]` with no diff is flagged; code-free task passes via artifact (SC-003) | `.specify/templates/checklist-template.md` |
| US4 / FR-006, FR-007 — pre-plan red-team, findings-only | Red-team run leaves spec/plan/tasks unchanged by diff (SC-004) | pre-plan red-team checklist artifact |
| US5 / FR-008 — conditional module index | Redundancy determination recorded; index (6 domains) built or dropped with cited rationale (SC-005) | `documentation/` module index (conditional) |
| FR-009, FR-010, FR-011, FR-012 — single-sourced, gate-safe, backward-compatible, scoped | Diff scope confined to `.specify/` + `documentation/`; no new hook; 001–007 unchanged (SC-006, SC-007) | `.specify/` machinery + `documentation/` only |
