# Quickstart: validating the initialBasis / sign-retry feature

Prerequisites: MATLAB R2024b+ with the COBRA Toolbox initialised (`initCobraToolbox(false)`),
and gurobi installed (`changeCobraSolver('gurobi','LP')` returns 1).

## 1. Before any source edit — record the baseline (R8)

```matlab
cd specs/20261025-235131-greedy-initial-basis
baselineRecord('record')   % ecoli_core left/right + iDopaNeuroC left, fixed seeds
```
Expected: `baseline/*.mat` written (ignored by `baseline/.gitignore`) and `baseline-summary.md` committed. The
summary holds per-run `raysFound`, `raysExpected`, `nTargetedObjectives` and a hash of `Zpos`.

## 2. Narrowest test

```matlab
runtests('test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m')
```
Expected: pass. The new blocks cover fixtures 1–4 in both modes, rejection reasons,
dependence reporting and the status fields (spec SC-001 – SC-005, SC-007).

| Fixture | Expected |
|---|---|
| 1 dimer | `Zpos == [1 1 2]`, complete, `raysAdded 0`, `nLPSolves 0` |
| 2 antiport | rows 1–2 == L0; 1 added ray ∝ (0,0,1,1,0,0) or (1,1,0,0,1,1); complete |
| 3 exchange/transport | kept `[1 2 3]`, dependent `[4]`, complete, `nLPSolves 0` |
| 4 sign recovery (hook `targetedSignFirst = -1`, `forceTargeted = true`) | added ray ∝ (0,0,1); `nSignRetries 1`; `nLPSolves 2` |

## 3. Regression

```matlab
runtests({'testCheckNullspaceBasis','testNullspaceAccuracyTarget'})
baselineRecord('compare')  % value-identical Zpos/Z; equal status fields except timings
```
Expected: pass. A divergent run is acceptable only if it shows `nSignRetries > 0` (FR-013).

## 4. Real-model reproducibility check (US5, local only)

```matlab
fixture6RealModelCheck   % iDopaNeuroC (primary), Recon3D model.L subset (secondary, if the file exists)
```
Expected output: see `fixture6RealModelCheck-expected.md`. Kept rows are value-identical,
the outcome is complete, the dependent sum-row is reported, and the counts and scope are
printed.
