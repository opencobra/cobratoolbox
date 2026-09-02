# Implementation Plan: Eliminate table-object dot-indexing and cell.ismember hotspots in RXN parsing

**Branch**: `022-eliminate-table-object-hotspots` | **Date**: 2026-09-02 | **Spec**: `specs/022-eliminate-table-object-hotspots/spec.md`

**Input**: Feature specification from `/specs/022-eliminate-table-object-hotspots/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

A MATLAB profiler run on the Tyrosine metabolism subsystem benchmark shows `cell.ismember`
(11.6s/525,632 calls) and a cluster of `tabular.*` table-object internals (`dotAssign`
10.1s/797,966 calls, `dotReference` 7.9s/2,158,231 calls, plus `vertcat`/`horzcat`/etc.)
consuming ~70s of the run's 149s — nearly half the pipeline. Two call sites account for
almost all of it: (1) `readABRXNFile.m`'s per-bond loop, which does two redundant
`find(...&ismember(...))` linear scans over the whole atoms table per bond (research.md R1
replaces this with a `containers.Map` lookup built once, keyed by `(met, metNr,
instance)`, giving two lookups per bond instead of four scans, while reproducing the
existing implementation's exact resolution — including erroring — on duplicate-key or
no-match input); and (2) `buildAtomAndBondTransitionMultigraph.m`'s two `EdgeTable`-building
loops, which currently dot-assign ~15-23 fields per iteration into a live `table` object
(research.md R2 hoists this to plain preallocated arrays/cells written per iteration, with
the `table`/`digraph` construction deferred to once, after each loop). Because
`addBondMappingsRXNFile.m` and both of `buildAtomAndBondTransitionMultigraph`'s loops call
`readABRXNFile.m`, fixing it once benefits every caller without touching any of them.
Neither change alters any function's public signature, output values, row order, or
existing error/warning behavior (FR-002, FR-005, FR-006, FR-007, FR-008) — this is a
call-count and wall-clock optimization only, verified by
`testConservedReactingMoieties.m` (unchanged) and a new Tyrosine-benchmark reproducibility
check (`tyrosineReproducibilityCheck.m`, reusing feature 021's script as a structural
template — research.md R3) that reports before/after `cell.ismember`/`tabular.dotAssign`/
`tabular.dotReference` call counts via MATLAB's `profile` facility.

## Technical Context

**Language/Version**: MATLAB (R2024b+ supported baseline per constitution; `containers.Map`
and `profile` are core MATLAB, no version constraint beyond the existing baseline)

**Primary Dependencies**: MATLAB core (`table`, `digraph`, `containers.Map`, `profile`); no
new toolboxes or external packages

**Storage**: N/A (in-memory MATLAB values only; the FR-010 reproducibility check persists a
`.mat` golden snapshot and a `.md` results file as feature artifacts under
`specs/022-eliminate-table-object-hotspots/`, not toolbox storage)

**Testing**: MATLAB `test/testAll.m` harness via
`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
(existing, CI-covered, `prepareTest('needsMILP', true)`, unmodified per FR-009); plus a new
non-CI documented reproducibility check (`tyrosineReproducibilityCheck.m`) per Principle
III's fallback for the externally-dependent, multi-minute Tyrosine benchmark

**Target Platform**: Headless Linux CI (GitHub Actions `testAllCI_*`, `.artenolis.yml`),
matching the existing toolbox CI environment

**Project Type**: Single MATLAB toolbox library (no frontend/backend split)

**Performance Goals**: On the Tyrosine metabolism subsystem benchmark, reduce the combined
`cell.ismember` call count attributable to `readABRXNFile` +
`buildAtomAndBondTransitionMultigraph` by ≥90% from the pre-change baseline (508,474 of
525,632 total, SC-002), and reduce their combined `tabular.dotAssign` and
`tabular.dotReference` call counts each by ≥70% from their pre-change baselines (717,081 of
797,966; 1,189,438 of 2,158,231, SC-003), while leaving `dATM`/`dBTM`/`atoms`/`bonds`
output bit-for-bit identical (SC-005). Wall-clock time is reported, not gated (SC-004,
given the session's own observed ±10% run-to-run noise).

**Constraints**: No change to `readABRXNFile`'s or `buildAtomAndBondTransitionMultigraph`'s
public signatures, inputs, outputs, or documented meaning (FR-006); no change to the number,
order, or content of `EdgeTable`/`dATM`/`dBTM` rows (FR-005); the existing
`nTotalAtomTransitions ~= k-1` mismatch warning and both existing try/catch log-and-skip
blocks must keep firing under the same conditions (FR-007, FR-008); `addBondMappingsRXNFile.m`'s
own internal redundant `readABRXNFile` call and anything already covered by feature
021-prefilter-isomorphism-classification are out of scope (FR-011)

**Scale/Scope**: Tyrosine metabolism subsystem (139 reactions) as the performance-benefit
benchmark; the existing small CI fixture (3 reactions) as the correctness-preserving
benchmark (Edge Cases: must not regress correctness or add measurable overhead at trivial
scale)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: No stoichiometric, bound, objective, or
  solver-status semantics are touched (Principle I N/A — this feature operates
  purely on RXN-file atom/bond parsing and `table`/`digraph` graph-object
  construction, not on the COBRA model `S`/`lb`/`ub`/`c` objects). The
  `atoms`/`bonds` table columns and `dATM`/`dBTM.Nodes`/`.Edges` column
  semantics are read-only inputs to this feature's algorithm change and are
  contractually unchanged in value (contracts/unchanged-public-contracts.md).
- **Testing and reproducibility**: `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
  (already declares `prepareTest('needsMILP', true)`) is the CI-covered
  regression gate (FR-009, SC-001) — no existing assertion is loosened,
  removed, or replaced, and this feature adds no new `src/` module requiring
  its own new test file (no new function is created — research.md R4). The
  Tyrosine-benchmark reproducibility check (FR-010) is the documented, non-CI
  substitute Principle III sanctions for the externally-dependent,
  multi-minute benchmark; see `quickstart.md` step 4 and `research.md` R3.
- **User experience and diagnostics**: No new user-facing output, print level,
  or diagnostic. The existing `nTotalAtomTransitions ~= k-1` mismatch warning
  (FR-007) and both existing per-reaction try/catch log-and-skip blocks
  (FR-008) keep firing under the same conditions as today — data-model.md E3
  and research.md R2 confirm the accumulator refactor preserves both exactly,
  including trailing-unfilled-row content when a mismatch occurs.
- **Performance and numerical integrity**: Performance goal (SC-002/SC-003) is
  explicitly subordinate to output identity (SC-005) — research.md R1/R2 show
  neither the lookup-index replacement nor the plain-array accumulator
  replacement can change any output value, only how many
  `cell.ismember`/`tabular.dotAssign`/`tabular.dotReference` calls and how much
  wall-clock time computing that same output takes. No diagnostic/verification
  step is removed or made skippable — the existing mismatch warning and both
  try/catch log-and-skip blocks are preserved verbatim (FR-007, FR-008), and
  the malformed-input error path (duplicate atom key, no-match) is deliberately
  reproduced rather than papered over (research.md R1, Edge Cases).
- **External-solver configuration audit**: N/A — no external solver is invoked
  by this feature (`testConservedReactingMoieties.m`'s MILP requirement is for
  an unrelated, pre-existing minimum-set-cover step this feature does not
  touch).
- **Spec-driven scope control**: Edit:
  `src/analysis/topology/reactingMoieties/readABRXNFile.m` (per-bond loop,
  currently lines ~250-259 only), `buildAtomAndBondTransitionMultigraph.m`
  (atom-transition loop, currently lines ~217-355, and bond-transition loop,
  currently lines ~547-693, only). Create (Spec Kit artifacts, not `src/`):
  `specs/022-eliminate-table-object-hotspots/tyrosineReproducibilityCheck.m`
  (new, non-CI), `specs/022-eliminate-table-object-hotspots/tyrosine-golden-snapshot.mat`
  (generated once, pre-change), `specs/022-eliminate-table-object-hotspots/tyrosine-reproducibility-results.md`
  (generated). Read-only / do not touch: every other file in
  `src/analysis/topology/reactingMoieties/` including `checkABRXNFiles.m`,
  `addBondMappingsRXNFile.m` (its own internal redundant `readABRXNFile` call
  is explicitly out of scope, FR-011), and everything in
  `specs/021-prefilter-isomorphism-classification/` (a different, completed
  feature's artifacts); every other `src/` path (SC-006). No new dependency,
  framework, new file, or new abstraction — both changes are algorithm
  replacements entirely local to the two named functions' existing bodies
  (research.md R4; no new helper file, unlike feature 021).
- **MATLAB coding standards**: No `evalc`, no suppressed warnings, no bare
  `nargin` (neither function's optional-argument handling is touched). Any
  `try/catch` this feature interacts with (the two pre-existing blocks in
  `buildAtomAndBondTransitionMultigraph.m`) already propagates `ME.stack` via
  `disp(getReport(ME))` and is left unmodified (FR-008), satisfying VII-C
  without new code. The `containers.Map`-keyed-lookup pattern (research.md R1)
  mirrors the existing precedent already in
  `buildAtomAndBondTransitionMultigraph.m` (`metBondCountGroundTruth`,
  `metAtomCanonicalRankMap`, `metUnsafeNeighborsMap`), so no new MATLAB
  idiom is introduced. No relevant project MATLAB-lint skill is currently
  registered (VII-F) — this plan proposes none beyond following the openCOBRA
  style guide already bound by reference (VII-G), since the change is a
  localized algorithmic refactor, not a new stylistic surface.
- **Parameter-setting fidelity**: N/A — this feature does not port, reuse, or
  render MATLAB code into another language or a literate document.
- **Artifact placement**: No source file changes destination — both edited
  files stay at their existing `src/analysis/topology/reactingMoieties/` paths
  (Principle IX, source only, no new subfolder). The FR-010 reproducibility
  script, its golden-snapshot `.mat`, and its results `.md` are new Spec Kit
  feature artifacts placed under `specs/022-eliminate-table-object-hotspots/`
  (Principle IX: "Spec Kit artifact → specs/<feature>/"), reusing feature
  021's script as a structural template rather than editing that other
  feature's own artifact directory (research.md R3) — not placed under `test/`
  (external, non-repo path dependency + multi-minute runtime, explicitly
  non-CI per Principle III) or `results/` (the golden snapshot is a
  persistent before/after comparison baseline, not regenerable/gitignored
  output).

## Project Structure

### Documentation (this feature)

```text
specs/022-eliminate-table-object-hotspots/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output — R1-R4
├── data-model.md        # Phase 1 output — E1-E4
├── quickstart.md        # Phase 1 output — validation steps 1-5
├── contracts/
│   └── unchanged-public-contracts.md   # Phase 1 output — both touched functions' preserved contracts
└── tasks.md             # Phase 2 output (/speckit-tasks command — NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
src/analysis/topology/reactingMoieties/
├── readABRXNFile.m                         # MODIFIED — per-bond lookup replaces four find(...&ismember(...)) scans (lines ~250-259 only)
├── buildAtomAndBondTransitionMultigraph.m  # MODIFIED — both EdgeTable-building loops use plain-array accumulators (lines ~217-355 and ~547-693 only)
└── (all other files in this folder)        # UNCHANGED — out of scope (FR-011 and SC-006), including checkABRXNFiles.m and addBondMappingsRXNFile.m

test/verifiedTests/analysis/testReactingMoieties/
└── testConservedReactingMoieties.m         # UNCHANGED — regression gate, every assertion intact (FR-009/SC-001)

specs/022-eliminate-table-object-hotspots/
├── tyrosineReproducibilityCheck.m          # NEW — non-CI FR-010 script (reuses feature 021's script as structural template)
├── tyrosine-golden-snapshot.mat            # NEW — generated pre-change baseline
└── tyrosine-reproducibility-results.md     # NEW — generated before/after report
```

**Structure Decision**: Single MATLAB toolbox project (Option 1 shape,
toolbox-specific paths). Both source changes stay within the existing
`src/analysis/topology/reactingMoieties/` domain folder per Principle IX, and
touch only the two named files' existing bodies — no new `src/` file is
created (research.md R4); no `tests/contract|integration|unit` split
applies — this repository's test taxonomy is
`test/verifiedTests/<category>/test*.m` run through `test/testAll.m`.

## Complexity Tracking

*No Constitution Check violations — table intentionally empty.*
