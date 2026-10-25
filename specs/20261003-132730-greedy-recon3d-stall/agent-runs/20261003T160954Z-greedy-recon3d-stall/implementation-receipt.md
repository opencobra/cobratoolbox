# Implementation Receipt — 20261003-132730-greedy-recon3d-stall

## Prompt

`/speckit-implement` (no arguments), invoked by the user after Gate 2 approval
("Approve all tasks (Recommended)", path "/speckit-implement (Recommended)"), for the
active feature `specs/20261003-132730-greedy-recon3d-stall`, tasks T001–T027.

## Final response

I've implemented all 27 tasks. Your exact call on the VK Recon3D model now returns **all 251 of 251 rays in about 32 s**, where it used to stop at 237 and then run for the full 10,000 s default budget. All four tests pass. The work is committed on branch `20261003-132730-greedy-recon3d-stall`, and nothing is pushed.

**The stall fix.** `greedyExtremeRayBasis` now judges, and returns, each ray exactly as the solver computed it, with any negative entries clipped to zero. Before, it judged the copy `findExtremePool` had already truncated, which zeroed every entry below 1e-5 and turned exact rays into rejected ones. Accuracy rejections now also count as failed attempts, so they trigger the routine's stall remedy instead of spinning. `findExtremePool` itself is unchanged.

**Your reference call, before and after:**

| | Before | After |
|---|---|---|
| Rays | 237 / 251, then no progress | **251 / 251** (`complete`) |
| Time | 180 s capped (10,000 s by default) | **32.4 s** |
| Accuracy rejections | 884 | **0** |
| Accuracy target | 3.0e-14 fallback, scaling not assessed | 3.9e-13 derived, `wellScaled`; spectrum 6.0 s |
| Worst residual | — | 3.5e-16 |

**Your `model.L` question.** `checkNullspaceBasis` judges it **inaccurate**. It is non-negative and spans the nullspace (rank 251 = nullity), but **101 of its 251 rows exceed the accuracy target** (worst residual 3.2e-9). The new basis from your call comes back **valid** (worst residual 3.5e-16), so it is a drop-in replacement for `model.L`.

**Other corrections:**
- A run cut short now reports its shortfall correctly: `sampling` with 251 directions reachable, not a false `structural` with 237.
- The accuracy target is now derived for operative matrices up to 1e8 elements (adjustable via the new `param.maxElementsForSpectrum`).
- The status gains two fields, `nStallEscalations` and `spectrumTime`; nothing is removed.

**Files:**
- `greedyExtremeRayBasis.m` edited, with a dated help-header note on the behaviour change.
- New `nullspaceAccuracyTarget.m`, the target derivation moved out of `greedyExtremeRayBasis` so both functions share it.
- New `checkNullspaceBasis.m`.
- `testGreedyExtremeRayBasis.m` extended, plus two new test files.

**Tests:**
- All pass: `testGreedyExtremeRayBasis` (84 s), `testNullspaceAccuracyTarget`, `testCheckNullspaceBasis`, and the unchanged `testFindExtremePathway`.
- The new stall test fails on the old code (7 of 11 rays, 3,534 rejections) and passes on the new (11 of 11 in 0.6 s).
- The previous features' results reproduce exactly under gurobi: iDopaNeuroC 105/105, iAF1260 38/38, ecoli_core 5/5.
- Moving the target derivation out of the routine changed no target on any test model (all 9 bit-identical).

**Worth knowing:**
- **Denser rays:** returned rays can now contain tiny exact entries, the smallest here 5.5e-6, that used to be zeroed. Code that assumed the old 1e-5 sparsity will see slightly denser rows.
- **One test not run failing-first:** I wrote `checkNullspaceBasis` before running its test, so that one test never ran against missing code.
- **A first-run test failure was my own setup, not a bug:** the test is a script and inherited a stale `param` from my diagnostic session. Every later run cleared the workspace first.
- **Separate issue:** `test/models/mat/Recon3DModel_301_xomics_input.mat` in the COBRA.models submodule is a corrupt download. It is out of scope here and needs its own fix.

Next is Gate 3 (closeout), the question below.

## Diff summary

| File | Change |
|---|---|
| `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m` | edit (+~130/−~90): R1 judge/return untruncated ray (`untruncatedRay`, main loop and `compareSolversAtState`); R2 accuracy rejections count via `countFailure`, `nStallEscalations` on every path; R3 target derivation delegated to `nullspaceAccuracyTarget`, `param.maxElementsForSpectrum` (default 1e8), `spectrumTime` on every path; R4 `attainableNullspaceDimension` replaced by maximal-support LP; help header NOTE + OPTIONAL INPUT/OUTPUTS docs |
| `src/analysis/topology/extremeRays/optimalRays/nullspaceAccuracyTarget.m` | new: accuracy target and regime derivation, extracted verbatim |
| `src/analysis/topology/extremeRays/optimalRays/checkNullspaceBasis.m` | new: supplied-basis validation (US4) |
| `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m` | edit (+142): rescaled-ecoli R1 regression (left and right), R2 escalation and field-on-every-path, F4/G1 attainable dimension, spectrum ceiling fallback |
| `test/verifiedTests/analysis/testTopology/testNullspaceAccuracyTarget.m` | new |
| `test/verifiedTests/analysis/testTopology/testCheckNullspaceBasis.m` | new |
| `specs/20261003-132730-greedy-recon3d-stall/measurements/` | new: pre-implementation tests, target invariants, acceptance, predecessor regression |
| `specs/20261003-132730-greedy-recon3d-stall/tasks.md`, `human-loop.md` | T001–T027 marked; state updated |

Not changed (verified with `git status`): `findExtremePool.m`, `optimalExtremePoolDriver.m`,
`testFindExtremePathway.m`, `test/models/**`, `external/**`, `deprecated/**`, the VK model file.

## Tests

MATLAB R2026a, gurobi, clean workspace per run (`clearvars; rehash`):

| Test | Result | Elapsed |
|---|---|---|
| testGreedyExtremeRayBasis | PASS | 84.0 s |
| testNullspaceAccuracyTarget | PASS | 0.3 s |
| testCheckNullspaceBasis | PASS | 1.4 s |
| testFindExtremePathway (gurobi, glpk) | PASS | 2.1 s |

Failing-first confirmed: T007 (7/11, 3534 accuracy rejections) and T015 (attainable 1 ≠ 2).
`checkcode`: no new messages. The one remaining greedy message (sparse indexing) is
pre-existing on develop. Acceptance and regression numbers:
`measurements/20261003-acceptance.md`, `measurements/20261003-predecessor-regression.md`.

## Unresolved issues

- `test/models/mat/Recon3DModel_301_xomics_input.mat` (COBRA.models submodule) is a corrupt HTML download. Out of scope; needs a separate fix upstream.
- The printed "Hit fraction" uses `nTry`, which excludes accuracy rejections, so it can exceed 1. Pre-existing and out of scope.
- `testCheckNullspaceBasis` was not run failing-first (implementation written before the test was executed).
- T008 deviation: the task text expected `nStallEscalations == 0` on a complete ecoli_core run. A complete run may legitimately escalate on dependence failures, so the test asserts a non-negative integer count there and exactly 0 only on the early-return paths.

## Other information

The quoted reference call is the user's: `paramGreedyExtremeRayBasis.internalStoichiometriMatrixLeftNullspace=1; paramGreedyExtremeRayBasis.solver='gurobi'; [L, Llin] = greedyExtremeRayBasis(model,paramGreedyExtremeRayBasis);` on the VK model loaded as-is.
