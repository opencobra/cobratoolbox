# Quickstart: validating the feature

## 1. CI-scale tests (bounded, in-repo fixtures)
```matlab
initCobraToolbox(false); changeCobraSolver('gurobi','LP');
runtests('test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m')
runtests('test/verifiedTests/analysis/testTopology/testNullspaceAccuracyTarget.m')
runtests('test/verifiedTests/analysis/testTopology/testCheckNullspaceBasis.m')
runtests('test/verifiedTests/analysis/testTopology/testFindExtremePathway.m')   % FR-012 regression
```
Expected: all pass. Key new assertions: ecoli_core with one conserved row ×2e5 → `outcome = 'complete'`, 11/11, 0 accuracy rejections (baseline 7/11, 1814); impossible target → `nStallEscalations > 0`; `maxElementsForSpectrum` below `numel` → `notAssessed`; F4 `[1;-1;2]` → `attainableDimension = 2`; G1 → `structural`, 0.

## 2. Recon3D acceptance (development workstation, VK file as-is)
```matlab
load('~/drive/sbgCloud/projects/variationalKinetics/data/Recon3T/Recon3DModel_301_xomics_input_VK_withL.mat')
Lshipped = model.L;
rng(20261003)
paramGreedyExtremeRayBasis.internalStoichiometriMatrixLeftNullspace=1;
paramGreedyExtremeRayBasis.solver='gurobi';
tic; [L, Llin, status] = greedyExtremeRayBasis(model,paramGreedyExtremeRayBasis); toc
model.L = L;
report = checkNullspaceBasis(model, Lshipped, paramGreedyExtremeRayBasis);
reportNew = checkNullspaceBasis(model, L, paramGreedyExtremeRayBasis);
```
Expected (research.md R0, R6): `status.outcome = 'complete'`, 251/251, < 10 min (measured 35.9 s), `raysRejectedForAccuracy/(attempts) < 5 %`, `accuracyTargetDerived = true`, `regime = 'wellScaled'`, `spectrumTime < 15 s`; `report.outcome = 'inaccurate'` with 101 failing rows, `report.spansNullspace = true`; `reportNew.outcome = 'valid'`.

Record the run (values, seed, solver, MATLAB version, elapsed) in `measurements/<date>-acceptance.md`.

## 3. Predecessor non-regression (FR-013)
Re-run the iDopaNeuroC / iAF1260 / ecoli_core cases recorded in `specs/20260915-082551-extreme-ray-coverage/measurements/` with the same seeds; record coverage, worst residual and runtime alongside the earlier values.
