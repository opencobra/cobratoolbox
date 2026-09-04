# Implementation Plan: Fix Empty-Selection Crashes in Reacting-Moieties Pipeline

**Branch**: `024-fix-empty-selection-bugs` | **Date**: 2026-09-04 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/024-fix-empty-selection-bugs/spec.md`

## Summary

Two hard crashes in the reacting-moieties pipeline, both root-caused to "empty
output isn't schema-safe": (1) `identifyConservedReactingMoieties.m` reads
`RM_sets`/`RM_graph` unconditionally after a loop that only ever assigns them
inside `for k = 1:length(selectedReactions)` — when the MILP set-cover
legitimately selects zero reactions, the loop body never runs and both variables
are undefined; (2) `buildReactingMoietyTables.m` stores a bare, columnless
`table()` when a selected reaction's formed- and broken-bond subtables are both
empty, and the *same* root cause (asymmetric `~isempty(F)`/`~isempty(B)` guards
around the `BondChange` column) also causes a **third, previously-unobserved**
concatenation crash when exactly one side is empty (FR-009, found during spec
validation pass 2).

Fix approach: (a) initialize `RM_sets = {}; RM_graph = {};` before the STEP-5
loops so both variables are always defined; (b) remove the `~isempty(F)`/
`~isempty(B)` guards around the `BondChange` assignment in
`buildReactingMoietyTables.m` (assign it unconditionally, including to 0-row
tables — MATLAB tables support this natively) and remove the bare-`table()`
special case, letting the existing non-empty-case processing pipeline run
unconditionally; because `F`/`B` are always row-slices of the same
`dBTM.Edges` schema, this one change closes FR-003, FR-004, and FR-009
together by construction rather than by three separate patches.

A third, narrower-scoped finding surfaced during this planning phase (Phase 0,
grounding Technical Context against source): reconXmoieties'
`constructCanonicalMoietySignature.m:278-283` unconditionally overwrites
`sig.reactingPattern` with a bare `table()` whenever `reacting.reactMoietyTables{k}`
is empty, **regardless of that table's column schema** — so the cobratoolbox
fix alone cannot prevent the `.BondChange` crash from reappearing one hop
upstream inside `compareMoietySignatures.m`. Per explicit user decision
(AskUserQuestion, 2026-09-04; recorded in
`checklists/requirements.md`), scope is widened by exactly this one branch:
`constructCanonicalMoietySignature.m` is amended to preserve `T`'s typed
schema when empty (the same "let 0-row inputs flow through the normal
processing path" pattern, not a hand-listed `table(..., 'VariableNames', ...)`
reconstruction), while `compareMoietySignatures.m` itself remains untouched,
preserving the original scope decision for that specific file.

## Technical Context

**Language/Version**: MATLAB R2024b+ (repo baseline per constitution); no new
language surface.

**Primary Dependencies**: COBRA Toolbox solver abstraction
(`solveCobraMILP`, unchanged by this feature — already routed through it since
feature 015-solver-spine-hardening); MATLAB `table`/`digraph`/`graph` object
model. No new toolboxes, no new third-party dependency.

**Storage**: N/A (in-memory MATLAB structures/tables only; no persisted data
format changes).

**Testing**: MATLAB `assert`-based tests under `test/verifiedTests/analysis/`,
run via `test/testAll.m` and the CI harness (GitHub Actions `testAllCI_*`);
`prepareTest('needsMILP', true)` requirement declaration (already used by the
target test file). Per constitution III-Naming, new assertions extend the
existing `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
— this file already exercises both `identifyConservedReactingMoieties` and
`buildReactingMoietyTables` end-to-end (feature 004-reacting-moieties-test), so
no new `test<FunctionName>.m` file is created. The reconXmoieties-side
amendment is verified by a test added to reconXmoieties' own test suite
(`moietySignature/tests/`), following that repository's own conventions — see
Artifact Placement below for why this sits outside cobratoolbox's Principle IX
role map.

**Target Platform**: Linux (CI: `matlab -batch` headless under Docker/Xvfb,
per constitution Scientific Computing Constraints); no OS-specific code.

**Project Type**: Single-project MATLAB toolbox library (COBRA Toolbox);
`src/analysis/topology/reactingMoieties/` is an existing subfolder, no new
subfolder is created.

**Performance Goals**: N/A beyond "no regression" — this feature does not
change the MILP problem formulation, its size, or its solve path (STEP 4 of
`identifyConservedReactingMoieties.m` is untouched); it only changes
post-solve handling of `selectedReactions` and post-classification table
construction.

**Constraints**: FR-008 (spec): no change to MILP solver behavior, numerical
results, or output volume for any already-succeeding (non-empty) reaction;
this feature only changes behavior on inputs that previously threw an
uncaught error.

**Scale/Scope**: 2 cobratoolbox functions edited (few-line changes each), 1
existing cobratoolbox test file extended (no new file), 1 reconXmoieties
function's one branch amended (~5 lines), 1 reconXmoieties test extended/added
per that repo's own convention. No repository-layout changes.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: Both cobratoolbox edits are pure
  output-representation fixes — no change to the stoichiometric matrix, bond
  classification, MILP set-cover formulation, or any conserved/reacting-moiety
  science content from Rahou et al. (2025, JTB) / Ghaderi et al. (2020, JTB),
  already cited in `identifyConservedReactingMoieties.m`'s header. The
  zero-selection and both/one-empty-subtable cases are legitimate valid
  results (per spec Assumptions), not degenerate inputs to be rejected — the
  fix represents them faithfully (`{}`, typed-but-empty table) rather than
  suppressing or defaulting them. The reconXmoieties amendment is likewise a
  pure schema-propagation fix (no change to `CanonicalBondElmts`/
  `IntraInterMoiety` classification logic for non-empty rows).
- **Testing and reproducibility**: Narrowest tests extend the existing
  `testConservedReactingMoieties.m` (III-Naming: one file per function,
  already the canonical file for both target functions), reusing its
  `prepareTest('needsMILP', true)` gate and its already-loaded
  `Recon3D_301`/r0317/ACONTm/r0426 fixture where practical (e.g. a
  phantom/absent reaction name against the existing `formedBondsTable`/
  `brokenBondsTable` to reach the both-empty branch without new biological
  fixture data). Where the zero-MILP-selection branch cannot be reached from
  the existing fixture, FR-007 explicitly sanctions "a minimal harness around
  its MILP set-cover step" — exact construction (synthetic vs. minimal real
  fixture) is an implementation-phase task, decided empirically against a
  live MATLAB session, not fixed at planning time (see research.md R1).
  reconXmoieties' own test addition lives in `moietySignature/tests/`, that
  repo's own convention (visible from existing pilot-test files there),
  independent of cobratoolbox's `test/testAll.m` harness.
- **User experience and diagnostics**: No new diagnostics, warnings, or
  print-level behavior. Both fixes are silent structural-correctness
  corrections: previously-crashing inputs now complete normally, matching
  spec Assumptions ("a valid, expected outcome... not itself a bug to be
  prevented"). No change to `verbose`/`printLevel` gating.
- **Performance and numerical integrity**: No MILP formulation change (STEP 4:
  `A`, `bvec`, `f`, `lb`, `ub`, `vartype`, `csense`, `osense` all untouched);
  the fix is entirely post-solve (`selectedReactions` handling) and
  post-classification (table construction). Zero risk to solution quality —
  confirmed no `f`/`A`/`b` edits in the diff scope. No debug/diagnostic step
  is made skippable by this change.
- **External-solver configuration audit**: N/A — no new external-solver
  invocation. `solveCobraMILP` is called once, earlier in the same function
  (`identifyConservedReactingMoieties.m:1659`), already configured and
  audited under feature 015-solver-spine-hardening; this feature's diff does
  not touch that call or its `MILPproblem` construction (lines 1636-1657
  unchanged).
- **Spec-driven scope control**: Source paths to edit —
  `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`
  (init `RM_sets`/`RM_graph` before line ~1674's loop),
  `src/analysis/topology/reactingMoieties/buildReactingMoietyTables.m` (lines
  29-41: unconditional `BondChange` assignment, remove bare-`table()` branch),
  `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
  (extend, no new file). Outside cobratoolbox:
  `~/repos/reconXmoieties/moietySignature/functions/constructCanonicalMoietySignature.m`
  lines 278-283 only (amended per spec FR-005), plus that repo's own
  `moietySignature/tests/`. Explicitly read-only / out of scope:
  `compareMoietySignatures.m` (original scope decision, reaffirmed by the
  amendment), every other reconXmoieties file, every other cobratoolbox file.
  No new dependency, helper file, or abstraction is introduced.
- **MATLAB coding standards**: No `evalc` use. No warnings suppressed (none
  exist on this path today; none added). No `try/catch` on this path (none
  needed — the fix is unconditional initialization/assignment, not
  exception handling). No `nargin`-based optional-argument change (function
  signatures are unchanged — FR-006). VII-E (documentation): this is a
  *behavior* change (previously-undefined/crashing → a now-defined, valid
  empty result), so `identifyConservedReactingMoieties.m`'s and
  `buildReactingMoietyTables.m`'s help headers get a short `NOTE:` addition
  documenting the empty-input contract (see data-model.md /
  contracts/empty-output-schema.md) — tracked as an implementation task, not
  a signature or documented-option change (Principle II unaffected). VII-F:
  no new MATLAB idiom is introduced beyond patterns already used elsewhere in
  these same two files (cell-array pre-allocation, unconditional table-column
  assignment) — no new skill search needed beyond confirming this against the
  existing `EndNodes`/`Weight` typed-but-empty precedent already cited in
  spec FR-004.
- **Parameter-setting fidelity**: N/A — no porting/rendering of MATLAB code
  into another language or literate document.
- **Artifact placement**: `identifyConservedReactingMoieties.m` and
  `buildReactingMoietyTables.m` are edited in place in their existing
  `src/analysis/topology/reactingMoieties/` subfolder (Principle IX: source
  only, no new file). Test additions go into the existing
  `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
  (no new test file, per III-Naming). No `results/`, `reports/`, or `logs/`
  artifacts are produced by this feature. The `constructCanonicalMoietySignature.m`
  amendment lives in a **separate git repository**
  (`~/repos/reconXmoieties`, not a subtree of this repo) — Principle IX's
  binding role map governs *this* repository's tree and does not itself
  dictate reconXmoieties' internal layout; the amendment and its test follow
  that repository's own established conventions (source under
  `moietySignature/functions/`, tests under `moietySignature/tests/`, both
  already in use there) and are authorized only for the single narrow branch
  named in spec FR-005 — not a general license to edit that repository.
  `specs/024-fix-empty-selection-bugs/` holds this feature's own Spec Kit
  artifacts, correctly placed per Principle IX.

No Constitution Check violations requiring Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/024-fix-empty-selection-bugs/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md         # Phase 1 output (/speckit-plan command)
├── contracts/            # Phase 1 output (/speckit-plan command)
│   └── empty-output-schema.md
└── tasks.md              # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
# COBRA Toolbox — single-project MATLAB library (existing structure, no new
# directories created by this feature)
src/
└── analysis/
    └── topology/
        └── reactingMoieties/
            ├── identifyConservedReactingMoieties.m   # edit: init RM_sets/RM_graph
            ├── buildReactingMoietyTables.m           # edit: unconditional BondChange
            └── identifyConservedReactingSubgraphs.m  # read-only (root-cause context)

test/
└── verifiedTests/
    └── analysis/
        └── testReactingMoieties/
            └── testConservedReactingMoieties.m       # extend (no new test file)

# Outside this repository (separate git repo, amendment scoped to spec FR-005)
# ~/repos/reconXmoieties/
#   moietySignature/functions/constructCanonicalMoietySignature.m  (lines 278-283 only)
#   moietySignature/tests/                                          (new/extended test,
#                                                                     that repo's own convention)
```

**Structure Decision**: Single-project MATLAB toolbox (COBRA Toolbox). All
cobratoolbox edits land in the existing `src/analysis/topology/reactingMoieties/`
subfolder and the existing `test/verifiedTests/analysis/testReactingMoieties/`
test file — no new source or test files, no new subfolders. One narrowly
scoped edit plus test lands in the separate reconXmoieties repository per the
FR-005 amendment, following that repository's own existing layout.

## Complexity Tracking

*No Constitution Check violations — this section is not applicable.*
