# Predecessor non-regression (T026, FR-013, SC-005) — 2026-10-03, after all changes

gurobi, seed 20260915 (twister), `param = struct('printLevel',0,'maxTime',120)`, models built as in
`specs/20260915-082551-extreme-ray-coverage/quickstart.md` / `measurements/results.md` §5.
(mosek column not re-run: greedyExtremeRayBasis now rejects mosek, develop commit a590dcca0.)

| Model | outcome | worst residual | acceptance target | accuracy rejections | elapsed | predecessor (gurobi) |
|---|---|---|---|---|---|---|
| iDopaNeuroC (internal) | complete 105/105 | 2.220e-16 | 1.193e-12 | 0 | 5.5 s | complete 105/105, 2.220e-16 |
| iAF1260 | complete 38/38 | 0 | 7.152e-13 | 0 | 2.4 s | complete 38/38, 0 |
| ecoli_core | complete 5/5 | 0 | 5.837e-13 | 0 | 0.1 s | complete 5/5, 0 |

No regression: coverage and residuals identical to the recorded predecessor values.
