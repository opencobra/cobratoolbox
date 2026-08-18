# Implementation Plan: Entropic-FBA infeasible-diagnostic hardening, legacy-test repair, and GECKO dual-residual resolution

**Branch**: `011-entropicfba-dual-fixes` | **Date**: 2026-07-16 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/011-entropicfba-dual-fixes/spec.md`

## Summary

Three corrective changes to the entropic-FBA solver stack, all surfaced during feature
010-gecko-entropic-fba (merged on `develop`), each additive/corrective with no public-interface,
model-field, or `.stat`/`.origStat` change:

1. **(P1) Infeasible enzyme-constrained EP must not crash.** In
   `entropicFluxBalanceAnalysis.m` the `otherwise` branch (~L1699) runs `optimizeCbModel` to
   diagnose an infeasible EP and `switch`es on its status handling only cases `0` and `1`; with no
   default, `message` is undefined for any other status and lines 1712/1714 throw. Additionally the
   mosek infeasibility diagnostic in `solveCobraEP.m` sizes its `prob.names` arrays from the
   pre-enzyme dimension, throwing `err_argument_dimension` when enzyme columns are present. Fix both
   so an infeasible EP (with or without enzyme columns) returns `stat = 0` with a populated
   `solution.messages`.

2. **(P2) Legacy test runs standalone.** `testEntropicFluxBalanceAnalysis.m:29` indexes
   `solverPkgs.EP{k}` with `k` undefined; fix the index so the test executes the function under test
   from a fresh workspace, unchanged in what it asserts.

3. **(P3) GECKO mosek dual-optimality residual.** Per the Session 2026-07-16 clarification, **pursue
   a fix**. Refined analysis (see research.md): for mosek, `grad` at `solveCobraEP.m:967` *already*
   equals `prob.c - F'*y_K` and `sol.rcost = -z(1:size(A,2)+p)` (L933), so the checked residual
   `res2 = grad + Aty + sol.rcost` (L1060) equals mosek's own linearized-cone stationarity
   `prob.c - prob.a'*y - z - F'*y_K` (L881/886) evaluated over the **full cone-variable vector,
   including the auxiliary exponential-cone variables** — whereas the clean pdco branch checks
   stationarity in the **original reduced coordinates** (`c + d.*logx + A'*y + z` on structural
   variables). The most probable root cause is therefore that the mosek dual-optimality residual is
   evaluated in the linearized-cone coordinates (where entropy auxiliary variables carry O(1)
   stationarity contributions) rather than the true entropy coordinates pdco uses; the ~2 on
   non-enzyme Recon3D and 1.45 on GECKO are the same artifact, not enzyme-specific. The intended fix
   is to compute the mosek dual-optimality residual in the structural/original coordinates (matching
   pdco), driving the reported residual to ~0 for both cases without altering the primal. Both
   candidate causes and the decisive debug-table experiment are in research.md; fall back to
   characterize-and-tolerate only if the confirmed residual is genuine (real KKT violation) and a
   correct fix proves infeasible.

Technical approach: correct in place within `src/base/solvers/entropicFBA/`, verify with the
narrowest tests under `test/verifiedTests/**` via the MATLAB MCP server (mosek + pdco), landing the
two low-risk fixes and the strictly-infeasible test first, re-running the 010 regression net, then
the dual-residual fix with the net re-run again.

## Technical Context

**Language/Version**: MATLAB, baseline R2024b+ (verified on R2026a locally).

**Primary Dependencies**: mosek (exponential-cone conic solver, EP path) and pdco (interior-point,
bundled). No new dependencies.

**Storage**: N/A (in-memory COBRA model structures; a tiny in-test toy fixture, no committed data).

**Testing**: `matlab.unittest`-style scripts under `test/verifiedTests/`, run via `test/testAll.m`
and CI (`testAllCI_*`), gated by `prepareTest('needsEP'/'requiredSolvers',{'mosek'})`. Verified
here through the MATLAB MCP server (`run_matlab_test_file`, `check_matlab_code`).

**Target Platform**: Linux headless (`matlab -batch`, Docker + Xvfb) and local desktop.

**Project Type**: MATLAB scientific-computing library (COBRA Toolbox); single-project layout.

**Performance Goals**: No performance change intended. The dual-residual fix must not add solver
calls; the diagnostic residual is computed once post-solve. Runtime dominated by the two solver
calls per test case on toy/Recon3D models (seconds).

**Constraints**: Numerical integrity is paramount and subordinates everything else (Principle IV):
the primal solution, objective, and `.stat`/`.origStat` MUST be unchanged; the non-enzyme dual
residual MUST NOT regress; warnings MUST remain visible (VII-B).

**Scale/Scope**: ~3 source edit sites across 2 files + 3 test files. Toy fixture is 3 rxns × 2 mets
+ 1 enzyme var; regression net uses Recon3D.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: Touches the entropic-FBA formulation's *diagnostic and status*
  surfaces only, not the optimization itself: (i) the infeasible-status/message bookkeeping in
  `entropicFluxBalanceAnalysis`, (ii) the mosek infeasibility name-array sizing and the post-solve
  KKT residual computation in `solveCobraEP`. The stoichiometry, bounds, objective, cones, and the
  returned primal are untouched. The primal/dual distinction (Principle I) is central: the P3 work
  concerns the *dual* residual diagnostic and must leave the *primal* `v`/`e`/objective exactly as
  computed by 010.
- **Testing and reproducibility**: Narrowest tests — `testEntropicFBAgecko` (adds a strictly-
  infeasible enzyme case + deterministic dual-optimality outcome), `testEntropicFluxBalanceAnalysis`
  (repaired to run standalone), `testEntropicFluxBalanceAnalysis` (regression net, unchanged). All gated
  by `prepareTest` mosek/EP so they skip gracefully. Verified via MATLAB MCP under mosek + pdco;
  fixed toy fixture (no seed needed — deterministic small LP/EP).
- **User experience and diagnostics**: An infeasible EP returns `stat = 0` with an informative
  `solution.messages` instead of crashing (better diagnostic behaviour, same contract). The mosek
  dual-optimality line either stops warning (fix path) or emits a documented, tolerated residual
  (characterize path). `printLevel`/`debug` gating of verbose output is preserved.
- **Performance and numerical integrity**: No runtime-affecting change; no solver call added or
  removed. The residual/diagnostic computation stays post-solve and default-on. Solution quality
  (objective, feasibility, primal, `.stat`/`.origStat`) must not degrade — this is the primary
  acceptance bar (SC-004/SC-006). The dual-residual fix corrects a *reported* quantity to reflect
  true KKT stationarity; it must not mask a genuine failure (if, after including the cone dual, the
  residual is still large, that is a real signal to keep — see research.md decision rule).
- **External-solver configuration audit**: mosek is the invoked external solver. Relevant surface:
  the affine-conic problem definition (`prob.a`, `prob.f`/`F`, `prob.g`, the exponential + quadratic
  cones), the returned dual structures (`res.sol.itr.{y,slx,sux,snx}` parsed by `parseMskResult` into
  `y,z,k`), and the post-solve KKT check with hardcoded `optTol = 5e-5` (L1066) and the
  `length(A)==1 && pdco` guard (L1071). The audit (research.md) confirms whether the KKT residual
  formula matches mosek's conic-dual convention (the cone dual `k`/`y_K` reordered at L875–878). No
  mosek *option* default is changed; the fix, if any, is to the residual *formula*, not solver
  configuration. pdco's config surface is unchanged.
- **Spec-driven scope control**: Edit `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m`
  and `src/base/solvers/entropicFBA/solveCobraEP.m`; edit tests
  `test/verifiedTests/base/testEntropicFBA/testEntropicFluxBalanceAnalysis.m` and
  `test/verifiedTests/analysis/testEntropicFBAgecko/testEntropicFBAgecko.m`. Read-only:
  `testEntropicFluxBalanceAnalysis` (rerun only, edit only if a regression guard demands it),
  `optimizeCbModel`, `parseMskResult`, and everything outside `entropicFBA/`. No new dependency,
  file, or abstraction. No migration boundary.
- **MATLAB coding standards**: No `evalc` (VII-A). Warnings stay visible (VII-B) — the dual-
  optimality `warning(...)` is corrected, not suppressed. Any `try/catch` added for the infeasible
  path propagates `ME.message` + `ME.stack` (VII-C). No new function is introduced expected (edits
  are in-place); if a small helper is extracted it carries the openCOBRA header (VII-E) and
  `camelCase`/`filesep` conventions (VII-G). No `nargin` added (VII-D). No diary suppression.
- **Parameter-setting fidelity**: N/A — this feature renders no ported/literate output; it is
  in-language MATLAB correction.
- **Artifact placement**: All source edits stay under `src/base/solvers/entropicFBA/` (source only);
  all test edits under `test/verifiedTests/**` (fixtures live in-test as the existing `buildEnzymeToy`
  local function). Spec artifacts under `specs/011-entropicfba-dual-fixes/`; the implementation
  receipt under `specs/011-entropicfba-dual-fixes/agent-runs/<UTC>-<name>/`. No generated output in
  `src/`. No file placement changes.

**Gate result**: PASS. No violations; Complexity Tracking empty.

## Project Structure

### Documentation (this feature)

```text
specs/011-entropicfba-dual-fixes/
├── plan.md              # This file
├── research.md          # Phase 0 output (mosek dual-residual audit + control-flow map)
├── data-model.md        # Phase 1 output (status/message + KKT-residual "entities")
├── quickstart.md        # Phase 1 output (MATLAB validation scenarios)
├── spec.md
├── checklists/
│   ├── requirements.md
│   └── correctness.md
├── human-loop.md
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
src/base/solvers/entropicFBA/
├── entropicFluxBalanceAnalysis.m   # EDIT: define `message` on all optimizeCbModel statuses (~L1699)
└── solveCobraEP.m                  # EDIT: mosek infeasibility name-array sizing (FR-003);
                                    #        dual/KKT residual computation incl. cone dual (US3/FR-006)

test/verifiedTests/base/testEntropicFBA/
└── testEntropicFluxBalanceAnalysis.m   # EDIT: fix undefined `k` index (US2/FR-005)

test/verifiedTests/analysis/testEntropicFBAgecko/
└── testEntropicFBAgecko.m              # EDIT: add strictly-infeasible enzyme case (US1);
                                        #        deterministic dual-optimality outcome (US3)

test/verifiedTests/analysis/testEntropicFluxBalanceAnalysis/
└── testEntropicFluxBalanceAnalysis.m       # READ-ONLY regression net (rerun; edit only if forced)
```

**Structure Decision**: Single-project MATLAB library layout (COBRA Toolbox). Solver source under
`src/base/solvers/entropicFBA/`; tests under `test/verifiedTests/{base,analysis}/`, matching the
existing placement of the 010 tests. No new directories.

## Complexity Tracking

> No Constitution Check violations. Table intentionally empty.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| — | — | — |
