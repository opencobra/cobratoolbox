# Implementation Plan: Speed up identifyConservedReactingMoieties' bond-subgraph, reacting-bond-graph and CRB2R stages, without changing its results

**Branch**: `20260921-154310-reacting-moiety-optimisation` | **Date**: 2026-09-21 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20260921-154310-reacting-moiety-optimisation/spec.md`

## Summary

Move the validated reacting-moiety prototype (`~/repos/reconXmoieties/experiments/moietySizing/scripts/reactingOptimisation/`)
into `src/` as in-place rewrites. Results must not change. The rewrites are:

1. **`extractBondSubgraphs.m`**: atom-to-component lookups built once; a cached copy of `BIGCopy`'s edge
   arrays, trimmed in step with `rmedge`; layer peeling on a table, not a graph; a new optional 3rd output
   `bmgEdgeIndex`. The original algorithm is kept as a local fallback for inputs outside the fast path's
   preconditions.
2. **`findAndExtractMolecularGraphs.m`**: a single `vertcat` in place of quadratic table growth; a new
   optional 4th input `bmgEdgeIndex`.
3. **`identifyConservedReactingMoieties.m`**: the stage-09 call lines pass the cache; the STEP B4 loops
   read it; the RBG and Condensed_RBG re-indexing use `ismember`; `CRB2R` is built from a sparse
   atom-to-reaction incidence. Each block keeps its original loop as a fallback, verbatim.

Planning found and fixes two defects in the prototype: stage 14b gives the wrong shape when the
Condensed_RBG has exactly one edge (research R5), and the `CRB2R` precondition check crashes on
non-numeric input (R6). It also restores the `verLessThan` guard that the prototype dropped (R1).

Evidence of equivalence: golden snapshots from **unmodified** `develop` of 7 fixtures x {default,
conserved-only} plus tyr with `sanityChecks = 1`, compared with `isequaln` along with console output;
`testConservedReactingMoieties.m` passing unmodified; and two new CI tests with references captured
before the change.

## Technical Context

**Language/Version**: MATLAB R2024b (the constitution's baseline; CI runs `matlab -batch` headless on Linux)

**Primary Dependencies**: MATLAB `graph`/`digraph` (`subgraph`, `rmedge`, `addedge`, `conncomp`), `ismember`, `sparse`; COBRA `classifySubgraphIsomorphism`, `solveCobraMILP` (unchanged callers)

**Storage**: MAT files: golden snapshots in `specs/<feature>/snapshots/` (external pointer above 10 MB); unit-test reference in `test/verifiedTests/analysis/testReactingMoieties/data/`

**Testing**: `test/testAll.m` harness; `prepareTest`; assert-based `.m` test scripts; non-CI reproducibility check script (029 pattern)

**Target Platform**: headless Linux (CI Docker, with Xvfb and gurobi where available); developer workstation for the non-CI check

**Project Type**: MATLAB library (COBRA Toolbox), internal performance refactor behind a stable public function

**Performance Goals**: after median whole-function time not greater than before on each of the 7 fixtures (SC-004). Reference only: the prototype's 1.4x to 2.0x; bileacid targeted stages about 34 s before, about 13 s after

**Constraints**: bit-identical outputs (`isequaln`) and console text; no removed or weakened diagnostic; no new option; no `*Fast` files; `testConservedReactingMoieties.m` not edited

**Scale/Scope**: 3 `src/` files (about 250 changed lines), 2 new test files, 1 test fixture `.mat`, 2 non-CI scripts plus a capture helper under `specs/`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design: PASS (no violations; Complexity Tracking is empty).*

- **Scientific code quality (I, II)**: No model field, stoichiometry, bound, objective or solver semantics
  is touched. `identifyConservedReactingMoieties`'s signature, options and outputs are unchanged. The two
  helpers each gain one optional trailing argument, and the default behaviour is historical (II:
  optional arguments default to historical behaviour). See [contracts/function-interface.md](contracts/function-interface.md).
  References cited: `documentation/source/guides/styleGuide.rst`, `documentationGuide.rst`, `testGuide.rst`.
- **Testing and reproducibility (III, III-Naming)**: New CI tests are `testExtractBondSubgraphs.m` and
  `testFindAndExtractMolecularGraphs.m` (one per function, named after it). They need no solver, but still
  call `prepareTest`. Their references come from unmodified `develop`, via a conditional breakpoint and no
  edit to `src/` (research R8). Existing CI: `testConservedReactingMoieties.m`, unmodified. The non-CI
  documented reproducibility check (`reactingOptimisationReproducibilityCheck.m`) exists because the 7
  fixtures depend on external data (spec Assumptions). Capture must come before any source change
  (research R10; quickstart step 0). FR-007 fallbacks that the public interface cannot reach are stated
  as such, not claimed as tested (research R8).
- **User experience and diagnostics**: Console output must be identical (SC-006), recorded with `diary`,
  not `evalc`. `BondIndex %d not found.` keeps its text, conditions and order (R6). Every `error`,
  `warning`, `fprintf` and sanity check is kept (FR-009), including `verLessThan`.
- **Performance and numerical integrity (IV)**: Performance is subordinate to identical outputs. No
  verification step is removed or made optional. Fallbacks keep the original algorithm and its errors, so
  there is no silent change of path. Measured: medians of 3 runs before and after per fixture;
  profiler-based targeted-stage sums on bileacid (reported, not gating).
- **External-solver configuration audit**: The MILP in STEP 4 (`solveCobraMILP`, `printLevel = 0`, COBRA
  defaults) is unchanged, and its input `A = -CRB2R(active, :)` must be byte-identical (FR-008), so no
  solver default is affected (research R11). The solver name is recorded in each snapshot, and a
  different solver is reported as `SOLVER MISMATCH`.
- **Spec-driven scope control (V)**: Edit `src/analysis/topology/reactingMoieties/extractBondSubgraphs.m`,
  `findAndExtractMolecularGraphs.m`, and `identifyConservedReactingMoieties.m`. In the last, only the
  stage-09 call lines (847, 855), the STEP B4 loops (lines 864-906), the stage 14a/14b re-indexing
  (1526-1576) and STEP 3 `CRB2R` (1624-1661), following FR-010 as amended during planning. Do not edit
  `createBIGraph`, `buildAtomAndBondTransitionMultigraph`, `identifyIsomorphicClasses`,
  `classifySubgraphIsomorphism`, the ATG and MTG stages, `testConservedReactingMoieties.m`, `external/`,
  `deprecated/`, or the stray `buildAtomAndBondTransitionMultigraph.asv`. No new dependency. The only
  abstractions are one local fallback function in `extractBondSubgraphs.m` and one local assembly function
  in `findAndExtractMolecularGraphs.m`. The prototype is reference material, not copied unreviewed:
  three differences are documented (R1, R5, R6).
- **MATLAB coding standards (VII)**: No `evalc` (console capture uses `diary`); no warning suppressed; any
  `try/catch ME` in the check scripts records `ME.identifier`, `ME.message` and `ME.stack(1)`; the new
  optional input uses `exist`/`isempty`, not `nargin` (VII-D); help headers updated with
  `OPTIONAL INPUT:`/`OPTIONAL OUTPUT:`/`NOTE:` (VII-E); openCOBRA style (VII-G). Skill discovery: no
  MATLAB-conventions skill is registered, so MathWorks guidance was applied and a project skill is
  proposed as a follow-up (research R12). The prototype's `%#ok<AGROW>` pragmas may be kept where arrays
  genuinely grow.
- **Parameter-setting fidelity (VIII)**: N/A. No port, binding or literate rendering.
- **Artifact placement (IX)**: `src/`: 3 modified source files only, with nothing generated. `test/verifiedTests/analysis/testReactingMoieties/`:
  the 2 new tests; `data/bondSubgraphReference.mat` goes next to them, as the existing fixtures do.
  `specs/20260921-154310-reacting-moiety-optimisation/`: the plan artefacts, the check script, the capture
  script, the capture helper `captureStageNineInputs.m`, `snapshots/`, the append-only results markdown,
  and `agent-runs/` receipts. Snapshots over 10 MB go outside the repository with a pointer file, as in
  029. Nothing at the repository root. Nothing moves.
- **Single-sourcing (X)**: Help headers describe behaviour for humans, with no agent instructions. The
  CLAUDE.md plan pointer is updated between the SPECKIT markers only.

## Project Structure

### Documentation (this feature)

```text
specs/20260921-154310-reacting-moiety-optimisation/
├── spec.md                                         # amended in plan phase (FR-010, SC-005, Clarifications)
├── plan.md                                         # this file
├── research.md                                     # Phase 0 (R1-R13)
├── data-model.md                                   # Phase 1
├── quickstart.md                                   # Phase 1 validation guide
├── contracts/function-interface.md                 # Phase 1 interface and fallback contract
├── captureBondSubgraphReferences.m                 # implement phase, run BEFORE src edits
├── captureStageNineInputs.m                        # conditional-breakpoint helper (saves BIG, ATG; returns false)
├── reactingOptimisationReproducibilityCheck.m      # CAPTURE/COMPARE, timings, console text, synthetic 14b case
├── reacting-optimisation-reproducibility-results.md  # append-only results
├── snapshots/                                      # golden snapshots (<=10 MB each, else .external.txt)
├── agent-runs/                                     # implementation receipt
└── tasks.md                                        # /speckit-tasks (not created here)
```

### Source Code (repository root)

```text
src/analysis/topology/reactingMoieties/
├── extractBondSubgraphs.m               # body rewritten; + optional 3rd output; + local legacy fallback
├── findAndExtractMolecularGraphs.m      # body rewritten; + optional 4th input; + local table-assembly function
└── identifyConservedReactingMoieties.m  # stage-09 call lines, STEP B4 loops, stage 14a/14b, STEP 3 only

test/verifiedTests/analysis/testReactingMoieties/
├── testExtractBondSubgraphs.m           # new (CI)
├── testFindAndExtractMolecularGraphs.m  # new (CI)
├── testConservedReactingMoieties.m      # UNCHANGED
└── data/bondSubgraphReference.mat       # new fixture, captured from unmodified develop
```

**Structure Decision**: Existing COBRA layout. The changes are in-place edits in the existing
`src/analysis/topology/reactingMoieties/` folder, which already owns these functions, so no new `src`
subfolder is needed. The tests go in the existing `testReactingMoieties` category folder.

## Implementation sequencing (input to /speckit-tasks)

The order matters, because the evidence is only valid if it was captured from unmodified code.

1. **Phase A: capture, blocking.** Write `captureStageNineInputs.m`, `captureBondSubgraphReferences.m` and
   `reactingOptimisationReproducibilityCheck.m`. With `src/` unmodified, run the capture script
   (produces `bondSubgraphReference.mat`) and the check in CAPTURE mode (7 fixtures x default and
   conserved-only, then tyr with sanity). Commit the snapshots and results **before** any `src/` edit.
2. **Phase B: tests first (US3).** Write the two CI tests against the reference. Running them now, on
   unmodified code, must pass. That confirms the reference and the tests agree before the code changes.
   The 3-output and 4-input arity checks are added in phase C, straight after each helper gains its
   new argument (tasks T015, T017), so every checkpoint is green.
3. **Phase C: `extractBondSubgraphs.m`** (R1, R2), then **`findAndExtractMolecularGraphs.m`** (R3).
   Re-run both new tests and `testConservedReactingMoieties.m`.
4. **Phase D: `identifyConservedReactingMoieties.m`**: stage-09 call lines and STEP B4 (R7); stage 14a
   (R4); stage 14b with `reshape` (R5); STEP 3 `CRB2R` with the tightened precondition (R6). Each
   block's original loop goes, verbatim, in the `else` branch.
5. **Phase E: verification.** The check in COMPARE mode for all fixtures and modes, plus the synthetic
   single-edge 14b section; the static `git diff` scope review (quickstart step 3); `testAll` for the
   `testReactingMoieties` folder; optionally the pufa timing (FR-014); the implementation receipt.

## Risks

| Risk | Mitigation |
|---|---|
| Snapshot captured after an edit to `src/` | Phase A blocks the rest; the capture scripts record `git diff --quiet develop -- src/` and refuse to CAPTURE if it is not clean |
| Solver finds a different optimal cover | Same solver recorded and enforced; `SOLVER MISMATCH` reported separately (R10, R11) |
| Conditional-breakpoint line drift | Line found by searching the file text at capture time (R8) |
| Prototype-only edge cases (one-edge Condensed_RBG, cell `EndNodes`) | Fixed in design (R5, R6); a synthetic check for 14b |
| Timing noise marks a real no-op as slower | Median of 3; a shortfall within noise is re-measured, per the spec's Assumptions |

## Complexity Tracking

No Constitution Check violations. The one local fallback function in `extractBondSubgraphs.m` is required
by FR-007, and research R1 says why no other copy of the original algorithm can serve.
