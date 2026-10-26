# Expected output: fixture6RealModelCheck (SC-006, US5)

Run on 2026-10-26 with MATLAB 26.1.0.3276743 (R2026a) Update 3 and gurobi. Source:
`greedyExtremeRayBasis.m` at commit 76948d527 (feature branch
`20261025-235131-greedy-initial-basis`).

```matlab
cd specs/20261025-235131-greedy-initial-basis
results = fixture6RealModelCheck();
```

## Route

No atom-mapped iDopaNeuroC or Recon3D exists in this repository, so the moiety matrix from
`identifyConservedMoieties` cannot be supplied. The supplied basis is a random subset of
rows of a previously computed non-negative basis, which is the prompt's fallback (research
R7).

## Results

| | iDopaNeuroC | Recon3D 3.01 |
|---|---|---|
| Operative matrix | internal, consistent reactions | internal, consistent reactions (5824 metabolites) |
| Supply route | 50 random rows of a basis computed in the script (seed 20261026), plus the sum of the first two | 125 random rows of `model.L` (251 x 5824, computed before this feature) |
| Nullity (`raysExpected`) | 105 | 251 |
| Supplied | 51 | 125 |
| Kept | 50 | 76 |
| Dependent | 1 (index 51, the sum row) | 0 |
| Rejected | 0 | 49, all `'accuracy'` |
| Rays added | 55 | 175 |
| Sign retries | 0 | 0 |
| LPs solved | 115 | 240 |
| Targeted objectives | 12 | 13 |
| Outcome | complete | complete |
| Kept rows value-identical to supplied | yes | yes |
| `residualAbsolute` (target) | 1.04e-17 (1.19e-12) | 3.47e-13 (3.95e-13) |
| Elapsed | 3.0 s | 21.6 s |
| Verdict | PASS | PASS |

## Reading the Recon3D rejections

`model.L` predates the derived accuracy target of feature 20260914, when rays were accepted
at `feasTol = 1e-6`. Measured over all of its rows against today's target of 3.95e-13:

- 101 of 251 rows exceed the target: median residual 5.46e-12, maximum 3.17e-9;
- no row has a negative entry.

Rejecting 49 of the 125 sampled rows (39%) matches that rate (40%). The function behaves
as FR-002 requires: rows that fail the current accuracy contract are reported, by index
and reason, and are not returned. The basis is still completed, around the 76 rows that
pass.

## What this does not show

- Neither run fired the sign retry. Fixture 4 is the evidence for that path.
- The moiety route (`identifyConservedMoieties` `L` as `initialBasis`) is not exercised
  at genome scale (no atom-mapped model in the repository).
- Counts are from one seed per model, so they describe these runs, not a distribution.
