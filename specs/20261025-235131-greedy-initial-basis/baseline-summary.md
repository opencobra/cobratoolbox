# Baseline: greedyExtremeRayBasis before feature 20261025-235131

Recorded 2026-10-26 00:46:49Z on MATLAB 26.1.0.3276743 (R2026a) Update 3 with gurobi, seed `rng(20261025, 'twister')` before each run.
Source: `greedyExtremeRayBasis.m` at commit 980e532b2, unmodified.

| Run | raysFound | raysExpected | nTargetedObjectives | nRestarts | SHA-256 of full(Zpos) |
|---|---|---|---|---|---|
| ecoliLeft | 5 | 5 | 0 | 0 | `d926dc6e9c3ebbcc624e55b098e0f84116c865c77c12d38fb1e892b32e150496` |
| ecoliRight | 5 | 5 | 0 | 0 | `ea3c42fb3655226a153f0d41173c9d0a0542564e4dac7deed457e3228c04a837` |
| iDopaNeuroCLeft | 105 | 105 | 7 | 0 | `c8990860824db6d86d348d0108513cddb1b15c13d367c09a320885fd529cdf6f` |

The `.mat` files in `baseline/` hold the full outputs and are not committed.

Self-check: `baselineRecord('compare')` immediately after recording reported all three runs identical.

After US2 (sign retry, commit following 37dd5ef4c): `baselineRecord('compare')` reported all three runs identical; no sign retry fired on any baseline run.
