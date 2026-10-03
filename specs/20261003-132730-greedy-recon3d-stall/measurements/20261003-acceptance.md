# Acceptance on the VK Recon3D model — 2026-10-03

Development workstation, MATLAB R2026a, gurobi. Model loaded as-is:
`load('~/drive/sbgCloud/projects/variationalKinetics/data/Recon3T/Recon3DModel_301_xomics_input_VK_withL.mat')`,
then the reference call (spec Clarifications), `rng(20261003)`, no `maxTime`.

## T014 — US1 reference call (after R1 + R2; before R3, R4)

| Quantity | Baseline (develop, 180 s cap) | After |
|---|---|---|
| outcome / reason | incomplete / timeBudget | **complete / basisComplete** |
| rays | 237 / 251 | **251 / 251** |
| elapsed | 180 s capped (10 000 s by default) | **32.4 s** (SC-001: < 10 min ✓) |
| raysRejectedForAccuracy | 884 | **0** |
| raysRejectedForDependence | 1 | 70 |
| accuracy-rejection fraction (SC-002 definition) | 884/1122 = 0.788 | **0.000** (SC-002: < 0.05 ✓) |
| nTargetedObjectives | 0 | 14 |
| nStallEscalations | (field absent) | 14 |
| nRestarts | 0 | 0 |
| accuracyTarget / derived / regime | 3.03e-14 / 0 / notAssessed | 3.945e-13 / 1 / wellScaled (R3 already in via T005) |
| worst returned residual | 2.8e-17 | 3.49e-16 (recomputed independently: 3.49e-16) |
| min entry / smallest positive entry | 0 / – | 0 / 5.5e-6 (an entry truncation would have zeroed) |

Note: the target was already derived here because T005 (the extracted helper with the
1e8 default ceiling) preceded T014. The ablation in research.md shows R1 alone suffices
with the fallback target too (251/251, 31.0 s).

## T017 — US2 shortfall classification (after R4)

Reference model, `maxTime = 5` to force a shortfall, `rng(20261003)`:
outcome incomplete, 63/251 rays, **shortfallKind `sampling`, attainableDimension 251**, assessed.
Baseline (develop): `structural`, 237. SC-004 ✓. CI: F4 → 2 / sampling (was 1); G1 → 0 / structural (unchanged).

## T020 — US3 spectrum (after R3 reporting)

Reference call, `rng(20261003)`: complete 251/251 in 31.6 s; `accuracyTargetDerived = 1`,
`regime = wellScaled`, **`spectrumTime = 6.04 s`** (SC-003: < 15 s ✓). testGreedyExtremeRayBasis PASS (84.6 s),
including the ceiling-parameter fallback case.

## T023 — US4 supplied-basis validation (SC-006)

`checkNullspaceBasis(model, L, struct('internalStoichiometriMatrixLeftNullspace',1,'solver','gurobi'))`:

| Basis | outcome | failing rows | rankB / nullity | spans | non-negative | worst residual | target |
|---|---|---|---|---|---|---|---|
| shipped `model.L` | **inaccurate** | **101 of 251** | 251 / 251 | yes | yes | 3.17e-9 | 3.945e-13 (derived) |
| new `L` from the reference call | **valid** | 0 | 251 / 251 | yes | yes | 3.49e-16 | 3.945e-13 |

Matches research.md R6 (101 failing rows) and the baseline measurements of `model.L`. testCheckNullspaceBasis PASS (1.8 s).
