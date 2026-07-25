# Phase 0 Research: Native SDD-workflow grafts

All three research questions from the plan input are resolved below. No
`NEEDS CLARIFICATION` remains.

## R1 — Graft #5 redundancy check (build vs pointer vs drop)

**Decision: DROP the per-domain module index as redundant; record this rationale;
create no new `documentation/` artifact.** (This is the "conditional build"
clarification resolving to its drop branch: the redundancy check did not clear a
new index.)

**Rationale**: A per-domain map of `src/<domain>/` already exists in three
single-sourced places, so a fourth would violate Principle X:

1. **Constitution Principle IX** is the canonical domain/role map — it lists all
   six domains (`analysis/`, `base/`, `dataIntegration/`, `design/`,
   `reconstruction/`, `visualization/`) with their one-line roles and the
   "new code goes in a new subfolder under the correct `src/<domain>`" rule.
2. **`analysis/ARCHITECTURE.md`** (22 KB) is a full architecture overview with a
   per-domain breakdown table (`.m` files, code LOC, cyclomatic complexity, share
   of `src` complexity per domain), a layered view, and complexity hotspots. It is
   explicitly framed as "the map" that feeds `/speckit-specify` features, with
   `analysis/WEAKNESSES.md` as the prioritized backlog.
3. **`documentation/source/modules/index.rst`** is the generated Sphinx per-domain
   function index (a `toctree` glob per domain: Analysis, Base, …), i.e. the
   published module reference already organised by domain.

Building a new hand-maintained index would (a) duplicate the domain roles
(Principle IX), (b) duplicate the architecture map (`ARCHITECTURE.md`), and
(c) duplicate the generated function listing (`modules/index.rst`) — three
single-sourcing violations and three drift risks. A thin pointer was considered
and also rejected: it introduces a new file whose only content is links, which
still drifts and adds no information beyond the three canonical sources.

**Consequence**: FR-008 is satisfied by this recorded determination; the
implementation deliverable for graft #5 is *this rationale*, not a file. If a
human ever wants a single "where do the domains live" entry point, the
single-sourced home is Principle IX (roles) with `analysis/ARCHITECTURE.md` as the
narrative map — no new artifact needed.

**Alternatives considered**: (a) build a full `documentation/` module index —
rejected, triple redundancy; (b) thin pointer page — rejected, drift with zero net
information; (c) drop — **chosen**.

## R2 — Constitution clause placement for characterization back-fill (FR-003)

**Decision: attach the characterization / legacy back-fill clause to Principle III
(Testing, Reproducibility, And Continuous Integration) as a labelled sub-clause,
applied via `/speckit-constitution` (anticipated MINOR bump 1.2.0 → 1.3.0 with a
Sync Impact Report).**

**Rationale**: The pattern — *select an untested legacy function surfaced by CI
coverage → document its EXISTING contract → write a characterization test* — is a
testing/coverage discipline. Principle III already owns the coverage-driven test
program ("every new code module ships with a corresponding test", `prepareTest`,
tolerance-based asserts). Characterization tests are the mechanism by which the
coverage back-fill features (004, 006) discharge that principle for *existing*
untested code, so III is the single natural home. Placing it under Principle V
(scope control) or VI (the gate) was considered but rejected: those govern *what*
may be edited and *when*, not *how* a coverage test is authored.

**Single-sourcing**: the clause is the ONE canonical description of the pattern.
The in-template Characterization Mode block (R3) and `spec-template.md` reference
it by name and MUST NOT restate it (Principle X). The `/speckit-constitution`
invocation owns the exact wording and version bump; a wording sketch is in
`data-model.md`.

**Alternatives considered**: new standalone principle (rejected — heavier than the
pattern warrants; MAJOR-looking churn); a paragraph in "Development Workflow And
Quality Gates" (rejected — less discoverable than the testing principle that the
coverage program already lives under).

## R3 — Insertion points and minimal wording for the four template grafts

Exact insertion points and wording sketches (kept minimal; full text is drafted in
`data-model.md` and applied in implementation):

- **Traceability section (Graft #1)** → append a new `## Traceability` section at
  the END of `spec-template.md` (after `## Assumptions`). Contains a guidance
  comment (including the **no-source convention** for docs/tooling features) plus a
  three-column table skeleton: criterion → discharging test → `src/<domain>/`
  function under test. Matches the dogfooded table already in this feature's
  `spec.md`.
- **In-template Characterization Mode (Graft #2)** → add (a) an optional guidance
  comment block after the `**Input**` line pointing to the Principle III clause,
  and (b) an optional `## Existing Contract *(characterization mode only)*`
  section that captures current inputs/outputs/invariants/tolerances and the
  coverage gap. Greenfield features delete the block; no separate file
  (in-template mode per clarification).
- **Phantom-completion assertion (Graft #3)** → add a STANDING, always-retained
  `## Completion Integrity` item to `checklist-template.md`, placed distinctly from
  the illustrative sample block (whose "do not keep" warning must not apply to it).
  Wording uses the generalized evidence form (diff hunk OR named non-code artifact,
  AND a test that ran OR an equivalent validation check for non-code work).
- **Pre-plan red-team checklist (Graft #4)** → **decision: a dedicated new template
  file** `.specify/templates/red-team-checklist-template.md`, instantiated by a
  contributor to `specs/<feature>/checklists/red-team.md` BEFORE `/speckit-plan`.
  Three categories (integrity gaps, silent failures, cross-spec drift), each a
  probing question; the artifact is **findings-only** and MUST NOT edit
  spec/plan/tasks (FR-007). A dedicated file is chosen over a section inside
  `checklist-template.md` because the red-team runs at a different phase and folding
  it into the generic template would conflate two distinct artifact types. This
  adds exactly one new file under `.specify/templates/` (machinery; gate-safe, no
  hook).

### Out-of-scope observation (evidence for Graft #4's value)

While reading the machinery, the plan template's Constitution Check
(`.specify/templates/plan-template.md`) references a file-placement scheme
(`docs/repository-layout.md`, `data/`, `results/`, `reports/`, `bin/`, Git LFS
"IX-G") that does **not** exist in the current constitution v1.2.0 (Principle IX
lists `src/`, `test/`, `tutorials/`, `documentation/`, `external/`, `binary/`,
`papers/`, `deprecated/`, `.specify/`, `specs/`, root). This is exactly the
**cross-spec drift** a pre-plan red-team lens is meant to surface — a live
confirmation of Graft #4's motivation. It is **out of scope** for feature 008
(which does not touch `plan-template.md`); recorded here and suitable for a
follow-up feature.
