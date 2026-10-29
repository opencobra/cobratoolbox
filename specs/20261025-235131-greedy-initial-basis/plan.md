# Implementation Plan: Complete a supplied partial non-negative nullspace basis in greedyExtremeRayBasis

**Branch**: `20261025-235131-greedy-initial-basis` | **Date**: 2026-10-26 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20261025-235131-greedy-initial-basis/spec.md`

## Summary

Add `param.initialBasis` to `greedyExtremeRayBasis`. The function validates the supplied
non-negative nullspace vectors (exact sign, the derived accuracy target), keeps a maximal
independent subset in supplied order as immutable leading rows of `Zpos`, restores them on
every restart, and searches only for the missing `nullity - kept` extreme rays. This is
Proposition prop:mr:left-basis (b) of the moietyRank manuscript. In the targeted step, a
`+d` vertex that is dependent on the rows held is re-solved with `-d` before a failure is
counted (Proposition (c)). Status gains partition counts and indices, `raysAdded`,
`nSignRetries` and `nLPSolves`. Without `initialBasis`, outputs are value-identical to
today's on every run in which no sign retry fires. All edits are confined to one source file
and its existing test.

## Technical Context

**Language/Version**: MATLAB, R2024b baseline; developed and verified locally on R2026a

**Primary Dependencies**: COBRA Toolbox internals already used by the function:
`findExtremePool` (unchanged), `solveCobraLP` (gurobi), `getNullSpace`, `getRankLUSOL`,
`nullspaceAccuracyTarget`, `changeCobraSolver`/`CobraSolverState`

**Storage**: N/A. Reproducibility outputs go in the feature directory; `.mat` baselines are
ignored by a feature-local `.gitignore`

**Testing**: `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m`
(extended), plus `testCheckNullspaceBasis` and `testNullspaceAccuracyTarget` (unchanged);
run via `runtests` / `test/testAll.m`

**Target Platform**: headless Linux CI (Docker, gurobi where licensed) and the local
workstation

**Project Type**: scientific library (MATLAB toolbox function)

**Performance Goals**: no regression on runs without `initialBasis`. With a complete
`initialBasis`, zero LPs. Each sign retry costs one extra LP of the same size, and only
fires where a failure would otherwise have been counted

**Constraints**: value-identical outputs without `initialBasis` when `nSignRetries = 0`
(FR-013, R8); kept rows value-identical (FR-004); exact non-negativity; vertex-returning LP
solver (gurobi default; mosek rejected)

**Scale/Scope**: fixtures 3–8 metabolites; ecoli_core (72 x 95); iDopaNeuroC (nullity 105);
Recon3D internal (5824 x 8748, nullity 251)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.* **Result: PASS**
(pre- and post-design; no violations, Complexity Tracking empty).

- **Scientific code quality (I)**: The semantics are those of Prop. prop:mr:left-basis.
  - Kept rows are conservation vectors of `ker(N')` and are not altered.
  - Added rays are vertices of `P = K ∩ {1'w=1}`.
  - Independence and accuracy are judged by the existing routines.
  - The status distinguishes supplied, kept, dependent, rejected and added vectors, so a
    caller can tell supplied moieties from added non-moiety conservation relations.
- **Backward compatibility (II)**:
  - Signature, outputs and existing status fields are unchanged; additions only
    ([contract](contracts/greedyExtremeRayBasis.md)).
  - One approved default change: the sign retry, always on (clarified 2026-10-26), recorded
    as a header NOTE. It is inert unless a dependent `+d` vertex occurs.
  - `findExtremePool` is untouched (FR-014).
  - The in-repo caller `optimalExtremePoolDriver.m:121` passes no `param` and is unaffected.
- **Testing and reproducibility (III)**:
  - The narrowest test is `testGreedyExtremeRayBasis.m` (III-Naming: extended, not
    duplicated). Its new blocks sit within the file's existing
    `prepareTest('needsLP', true)`. The no-LP fixtures run with any solver and the vertex
    fixtures run per available vertex-returning solver (analyze C1). They use fixed seeds, and compare rays in exact rational form.
  - Baseline record/compare script (R8) for SC-004.
  - Real-model reproducibility script with expected output (R7), local only, as in
    20260914.
- **User experience and diagnostics**:
  - `status` is complete on every path.
  - New identified warning `keptExceedsNullity` and errors `initialBasisSize`,
    `keptRowFailedVerification`.
  - Console output stays gated by `printLevel`: summary lines at `>0` (supplied/kept/added
    counts), the per-retry line and `g'w` at `>2`.
- **Performance and numerical integrity (IV)**:
  - No check is made skippable.
  - Kept rows are subjected to the same accuracy contract as searched rays. The final
    per-row verification still runs and now errors rather than drops if a kept row fails.
  - The retry adds LPs only where a failure would be counted. Performance is subordinate to
    correctness.
- **External-solver configuration audit**: research R5. gurobi via `findExtremePool`. The LP
  family (sparse `[N'; 1']`, equality rows, `0 <= w <= 100`) is unchanged and only `c`
  differs. Method, crossover, tolerances, presolve and seed were cross-checked against the
  20260915 audit. No default is mismatched, so nothing is overridden.
- **Spec-driven scope control (V)**:
  - Edit: `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m` and
    `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m`.
  - New files only under this feature directory (scripts, expected output, baseline
    summary, local `.gitignore`).
  - Read-only: `findExtremePool.m`, `nullspaceAccuracyTarget.m`, `checkNullspaceBasis.m`,
    `getRankLUSOL`, `external/`, `deprecated/`.
  - No new dependency or abstraction.
- **MATLAB coding standards (VII)**:
  - No `evalc`; warnings visible with identifiers; no new `try/catch`.
  - Optional fields via `isfield`/`isempty`, not `nargin`.
  - openCOBRA header format for the new `OPTIONAL INPUT`, `status` and `NOTE` entries.
  - `matlab-core:matlab-review-code` applied at implementation (R9).
- **Parameter-setting fidelity (VIII)**: N/A (no port or literate output).
- **Artifact placement (IX)**:
  - Source edit stays in its existing `src/analysis/...` file; the test edit stays in its
    existing `test/verifiedTests/...` file.
  - Reproducibility scripts, expected output and baseline summary go in
    `specs/20261025-235131-greedy-initial-basis/`. Baseline `.mat` files go in its
    `baseline/` subfolder, ignored by a feature-local `.gitignore` (no edit to the root
    `.gitignore`).
  - Nothing is written to the repo root or `src/`.
- **Single-sourcing (X)**: the contract lives in the function header and
  `contracts/greedyExtremeRayBasis.md`. No agent instructions go into the header.

## Project Structure

### Documentation (this feature)

```text
specs/20261025-235131-greedy-initial-basis/
├── feature-prompt.md        # authoritative description (copy)
├── spec.md / plan.md / research.md / data-model.md / quickstart.md
├── contracts/greedyExtremeRayBasis.md
├── checklists/{requirements.md, numerics-compat.md}
├── baselineRecord.m         # R8: record (pre-edit) / compare (post-edit)
├── baseline-summary.md      # committed summary of the baseline
├── baseline/.gitignore      # ignores baseline/*.mat
├── fixture6RealModelCheck.m # R7 reproducibility check
├── fixture6RealModelCheck-expected.md
├── human-loop.md / implementation-review.md
├── agent-runs/<UTC>-<name>/implementation-receipt.md
└── tasks.md                 # /speckit-tasks
```

### Source Code (repository root)

```text
src/analysis/topology/extremeRays/optimalRays/
└── greedyExtremeRayBasis.m          # EDIT: initialBasis, sign retry, status, header NOTE
test/verifiedTests/analysis/testTopology/
└── testGreedyExtremeRayBasis.m      # EDIT: fixtures 1-4 (left + right), status, rejection, hook
```

**Structure Decision**: the existing toolbox layout. One source file and one test file are
edited in place, and all supporting artifacts live in the feature directory.

### Design outline (for tasks; see research R2–R4)

1. **Orientation and validation block**, after `acceptanceTarget` is set (line 341):
   - Orient `initialBasis` for the mode.
   - Check its size.
   - Partition it into rejected/dependent/kept (R3 steps 1–3).
2. **Search initialisation** (lines 405–439):
   - Preallocate `Zpos` to `max(raysExpected, nKept)` rows.
   - Seed `Zpos(1:nKept,:)`, `nBases = nKept`, `nonZeroColumnsBool` and
     `bestZpos/bestNBases` from the kept rows.
   - Add counters `nSignRetries` and `nLPSolves`.
3. **Restart block** (lines 452–470): reset to the kept-only state.
4. **Solve call** (lines 506–532): count `nLPSolves` on the nominated solve.
   - Keep the solve in place so the non-targeted path is textually unchanged.
   - The retry re-uses the same two-branch call (ordinary / paired comparison) through a
     small local helper `solveCandidate`, so both branches get the retry identically.
5. **Targeted step**:
   - `targetedObjective` gains a sign argument and the canonical-orientation option for the
     hook. The first call is byte-for-byte today's objective.
   - After the independence test fails on a targeted candidate, do one retry with `-d`.
   - The retried vertex passes through the same accuracy → independence path.
   - Counters follow data-model E4. `testHook.forceTargeted` bypasses the `nfail` gate.
6. **Final verification** (lines 644–654): a failing kept row raises
   `keptRowFailedVerification`.
7. **Outcome** (lines 729–746): `complete` iff `nBases >= raysExpected`; warn
   `keptExceedsNullity` when `nKept > raysExpected`.
8. **Status**: add the E5 fields on the normal path and on the three early-return structs.
9. **Header**:
   - `OPTIONAL INPUT` entries for `initialBasis` and `testHook` (test only).
   - New `status` field lines.
   - A NOTE "CHANGE OF DEFAULT NUMERICAL BEHAVIOUR, October 2026, feature
     20261025-235131-greedy-initial-basis" covering the sign retry and the new capability.

## Complexity Tracking

No violations.
