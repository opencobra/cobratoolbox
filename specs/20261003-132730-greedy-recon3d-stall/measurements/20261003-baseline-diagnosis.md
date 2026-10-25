# Baseline diagnosis — 2026-10-03 (pre-feature, `develop` @ a2069f7ed)

Model: `~/drive/sbgCloud/projects/variationalKinetics/data/Recon3T/Recon3DModel_301_xomics_input_VK_withL.mat`
(variable `model`, S 5824 x 10554). Operative matrix `N = S(:,SConsistentRxnBool)`, 5824 x 8748.
MATLAB R2026a, gurobi LP. Run via MATLAB MCP, interactive session.

## Spectrum
rank(N) = 5573, nullity 251; sigma_1 = 136.6, sigma_r = 8.92669e-4, sigma_{r+1} = 7.84252e-15.
max|S| = 20, min nonzero |S| = 1. numel(N) = 5.0948e7 > maxElementsForSpectrum = 5e7.

## greedyExtremeRayBasis, param = struct('printLevel',1,'internalStoichiometriMatrixLeftNullspace',1,'maxTime',180)
outcome incomplete / timeBudget; raysFound 237 / 251; raysRejectedForAccuracy 884;
raysRejectedForDependence 1; nTargetedObjectives 0; nRestarts 0; regime notAssessed;
accuracyTarget 3.0331e-14 (derived = false); residualAbsolute 2.7756e-17;
shortfallKind structural; attainableDimension 237; elapsed 180.3 s.

## Replay of the inner LP (findExtremePool formulation, gurobi, feasTol 1e-6 -> truncation eps 1e-5)
- 30 random objectives (rng(1)): raw residual max 0, truncated residual max 0, smallest entry >= 0.33.
- 20 objectives zeroed on metabolites covered by the 237 rays (rng(2)): raw residual max 3.2e-16;
  truncated residual median 1.6e-4; median 196 entries in (0, 1e-5); median smallest entry 5.5e-6;
  20/20 rejected for accuracy after truncation, 20/20 would pass untruncated.
- 20 objectives supported only on the 19 metabolites excluded by the attainable-dimension LP:
  raw and truncated residual 0; 20/20 pass.

## Attainable dimension
- As implemented (max sum x, 0<=x<=1): support 5805, 19 metabolites excluded, attainable 237.
- Maximal-support LP (z<=x, 0<=z<=1, 0<=x<=1e4, N'x=0, max sum z): support 5824, attainable 251
  (LUSOL and SVD agree); residual of x 4.9e-11; x ranges 1 .. 1e4.

## Shipped model.L
251 x 5824 sparse, nnz 2847, min nonzero 5.18865e-4, max 1, non-negative, no zero rows, rank 251.
max|L*N| = 3.16922e-9; per-row residual median 1.84575e-13, 90th pct 3.19778e-11;
rows >1e-12: 76, >1e-10: 12. Distance of rows from ker(N') (orth projection): max 1.16446e-8,
>1e-8: 1, >1e-10: 11. Rows of L touching the 19 excluded metabolites: 8, residuals 9.5e-13 .. 3.2e-9.
rank([Zpos;L]) with the 237-ray exact Zpos: LUSOL 256, SVD (default tol) 296.
