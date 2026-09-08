# Implementation Plan: Prefilter subgraph isomorphism classification

**Branch**: `021-prefilter-isomorphism-classification` | **Date**: 2026-09-02 | **Spec**: `specs/021-prefilter-isomorphism-classification/spec.md`

**Input**: Feature specification from `/specs/021-prefilter-isomorphism-classification/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Three independent all-pairs `isisomorphic` loops in
`src/analysis/topology/reactingMoieties/` (`findAndExtractMolecularGraphs.m`,
`identifyConservedReactingMoieties.m`, `identifyIsomorphicClasses.m`) account
for ~46% of pipeline runtime on even a small model and are believed to be the
scalability wall for larger ones. This feature introduces one new shared
helper, `classifySubgraphIsomorphism.m`, that computes a cheap, provably
necessary per-subgraph structural invariant (node count, edge count, sorted
relevant-label multiset) and skips the `isisomorphic` call for any candidate
pair whose invariants differ, falling back to the real check only when they
match. All three call sites route through this one helper instead of each
carrying its own inline loop. `research.md` R1-R3 prove this is a
zero-output-change refactor (the two existing loop skeletons already compute
the same equivalence-class partition, in the same order, given the same
pairwise `isisomorphic` truth table), and R2 proves the invariant pre-filter
itself cannot change any pairwise result (a mismatched invariant makes the
true answer provably `false`, so skipping the call is behaviorally identical
to calling it). The net effect: identical classification output (SC-004), a
strictly lower total `isisomorphic` call count (SC-002), reduced wall-clock
time for the classification step (SC-003), and exactly one pairwise
`isisomorphic` loop left in the directory (SC-006).

## Technical Context

**Language/Version**: MATLAB (R2024b+ supported baseline per constitution; `isisomorphic` with `NodeVariables`/`EdgeVariables` requires R2016b+, already assumed by `identifyIsomorphicClasses.m`)

**Primary Dependencies**: MATLAB Graph and Network Algorithms (`graph`/`digraph`, `isisomorphic`, `numnodes`, `numedges`); no new toolboxes or external packages

**Storage**: N/A (in-memory MATLAB values only; the FR-009 reproducibility check persists a `.mat` golden snapshot and a `.md` results file as feature artifacts under `specs/021-prefilter-isomorphism-classification/`, not toolbox storage)

**Testing**: MATLAB `test/testAll.m` harness via `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` (existing, CI-covered, `prepareTest('needsMILP', true)`); plus a new non-CI documented reproducibility check (`tyrosineReproducibilityCheck.m`) per Principle III's fallback for the externally-dependent, multi-minute Tyrosine benchmark

**Target Platform**: Headless Linux CI (GitHub Actions `testAllCI_*`, `.artenolis.yml`), matching the existing toolbox CI environment

**Project Type**: Single MATLAB toolbox library (no frontend/backend split)

**Performance Goals**: Strictly reduce (no fixed percentage — 2026-09-02 clarification) the total `isisomorphic` call count and wall-clock time for the classification step on the Tyrosine metabolism subsystem benchmark (baseline: 2,678,455 + 96,562 + the `identifyIsomorphicClasses` call count captured by the golden-snapshot run), while leaving classification output bit-for-bit identical

**Constraints**: No change to the three named functions' public signatures (FR-006); no change to `checkABRXNFiles.m` or `readABRXNFile.m`/`addBondMappingsRXNFile.m` (FR-010); no `src/` file outside the three named functions plus the new helper may be modified (SC-005); `sanityChecks` behavior must keep firing under the same conditions (FR-007)

**Scale/Scope**: Tyrosine metabolism subsystem (139 reactions) as the performance-benefit benchmark; the existing 3-reaction Recon3D CI fixture as the correctness-preserving benchmark (Edge Cases: must not regress or add measurable overhead at trivial scale)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: No stoichiometric, bound, objective, or
  solver-status semantics are touched (Principle I N/A to this feature —
  it operates purely on `graph`/`digraph` bond-subgraph objects used
  internally by the moiety-classification pipeline, not on the COBRA model
  `S`/`lb`/`ub`/`c` objects themselves). `mets`/`AtomIndex`/`TransIndex`
  node/edge label semantics are read-only and unchanged.
- **Testing and reproducibility**: `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
  (already declares `prepareTest('needsMILP', true)`) is the CI-covered
  regression gate (FR-008, SC-001) — no existing assertion is loosened,
  removed, or replaced. `classifySubgraphIsomorphism.m` is a new code module
  (Principle III) and gets its own CI test,
  `test/verifiedTests/analysis/testReactingMoieties/testClassifySubgraphIsomorphism.m`
  (Principle III-Naming), covering N∈{0,1}, the singleton-invariant-bucket
  case, and no-false-negatives across all three comparison modes, in
  addition to transitive exercise via `testConservedReactingMoieties.m`
  through all three call sites. The Tyrosine-benchmark
  reproducibility check (FR-009) is the documented, non-CI substitute
  Principle III sanctions for the externally-dependent, multi-minute
  benchmark; see `quickstart.md` step 4 and `research.md` R6.
- **User experience and diagnostics**: No new user-facing output, print
  level, or diagnostic; `sanityChecks`-gated error conditions (FR-007) keep
  firing for the same inputs (timing may shift from mid-scan to post-grouping
  — `research.md` R3 — which no acceptance scenario or test distinguishes).
- **Performance and numerical integrity**: Performance goal (SC-002/SC-003)
  is explicitly subordinate to output identity (SC-004) — `research.md`
  R1-R2 show the pre-filter cannot change any pairwise `isisomorphic` result,
  so there is no risk of the classic "faster but wrong" failure mode this
  gate exists to catch. No diagnostic/verification step is removed or made
  skippable; the pre-filter is additive gating in front of the existing
  exhaustive check, not a replacement for it (FR-003: "The full `isisomorphic`
  check MUST still run for every pair whose invariants match").
- **External-solver configuration audit**: N/A — no external solver is
  invoked by this feature (the MILP solver `testConservedReactingMoieties.m`
  requires is for an unrelated, pre-existing minimum-set-cover step this
  feature does not touch).
- **Spec-driven scope control**: Edit:
  `src/analysis/topology/reactingMoieties/findAndExtractMolecularGraphs.m`,
  `identifyConservedReactingMoieties.m` (lines ~603-676 only),
  `identifyIsomorphicClasses.m`; create:
  `src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism.m` (new
  shared helper), `specs/021-prefilter-isomorphism-classification/tyrosineReproducibilityCheck.m`
  (new, non-CI), `specs/021-prefilter-isomorphism-classification/tyrosine-golden-snapshot.mat`
  (generated once, pre-change), `specs/021-prefilter-isomorphism-classification/tyrosine-reproducibility-results.md`
  (generated). Read-only / do not touch: `checkABRXNFiles.m`, `readABRXNFile.m`,
  `addBondMappingsRXNFile.m` (FR-010), `identifyAtomEquivalenceClasses.m` and
  `identifyConservedReactingMoieties.m:1020`'s single-pair check (different,
  out-of-scope `isisomorphic` usages — `research.md` R1 note), and every other
  `src/` path (SC-005). No new dependency, framework, or repository-layout
  change — one new file within the existing domain folder (Principle IX: new
  code as a new file under the correct existing `src/<domain>/` subfolder,
  no new subfolder needed since this augments an existing algorithm family
  rather than introducing a new one).
- **MATLAB coding standards**: `classifySubgraphIsomorphism.m` will carry the
  full openCOBRA help header (VII-E: `USAGE`/`INPUTS`/`OUTPUTS`/`NOTE`); no
  `evalc`, no suppressed warnings, no bare `nargin` (existence/emptiness
  checks per VII-D for the optional `varargin` mode), and any `try/catch`
  introduced (none currently planned — the helper has no fallible I/O)
  would propagate `ME.stack` per VII-C. No relevant project MATLAB-lint
  skill is currently registered (VII-F) — this plan proposes none beyond
  following the openCOBRA style guide already bound by reference
  (VII-G), since the change is a localized algorithmic refactor, not a
  new stylistic surface.
- **Parameter-setting fidelity**: N/A — this feature does not port, reuse, or
  render MATLAB code into another language or a literate document.
- **Artifact placement**: `classifySubgraphIsomorphism.m` → existing
  `src/analysis/topology/reactingMoieties/` domain folder (source only, no
  new subfolder — Principle IX). The FR-009 reproducibility script, its
  golden-snapshot `.mat`, and its results `.md` are Spec Kit feature
  artifacts placed under `specs/021-prefilter-isomorphism-classification/`
  (Principle IX: "Spec Kit artifact → specs/<feature>/") rather than
  `test/` (external, non-repo path dependency + multi-minute runtime,
  explicitly non-CI per Principle III) or `results/` (that golden snapshot
  is a persistent before/after comparison baseline, not regenerable/
  gitignored output). No file changes destination for any existing file.

## Project Structure

### Documentation (this feature)

```text
specs/021-prefilter-isomorphism-classification/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output — R1-R6
├── data-model.md        # Phase 1 output — E1-E3
├── quickstart.md        # Phase 1 output — validation steps 1-5
├── contracts/
│   └── classifySubgraphIsomorphism.md   # Phase 1 output — new helper's contract
└── tasks.md             # Phase 2 output (/speckit-tasks command — NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
src/analysis/topology/reactingMoieties/
├── classifySubgraphIsomorphism.m           # NEW — shared invariant-prefiltered classification helper
├── findAndExtractMolecularGraphs.m         # MODIFIED — routes through the helper (lines ~24-61)
├── identifyConservedReactingMoieties.m     # MODIFIED — routes through the helper (lines ~603-676 only)
├── identifyIsomorphicClasses.m             # MODIFIED — becomes a thin wrapper over the helper
└── (all other files in this folder)        # UNCHANGED — out of scope (FR-010 and SC-005)

test/verifiedTests/analysis/testReactingMoieties/
└── testConservedReactingMoieties.m         # UNCHANGED — regression gate, every assertion intact (FR-008/SC-001)

specs/021-prefilter-isomorphism-classification/
├── tyrosineReproducibilityCheck.m        # NEW — non-CI FR-009 script
├── tyrosine-golden-snapshot.mat            # NEW — generated pre-change baseline
└── tyrosine-reproducibility-results.md     # NEW — generated before/after report
```

**Structure Decision**: Single MATLAB toolbox project (Option 1 shape,
toolbox-specific paths). All source changes stay within the existing
`src/analysis/topology/reactingMoieties/` domain folder per Principle IX
(one new file, no new subfolder); no `tests/contract|integration|unit` split
applies — this repository's test taxonomy is
`test/verifiedTests/<category>/test*.m` run through `test/testAll.m`.

## Complexity Tracking

*No Constitution Check violations — table intentionally empty.*
