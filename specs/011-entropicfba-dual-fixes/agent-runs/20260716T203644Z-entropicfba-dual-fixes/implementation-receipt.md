# Implementation Receipt — 011-entropicfba-dual-fixes

**UTC:** 2026-07-16T20:36:44Z · **Branch:** `011-entropicfba-dual-fixes` (off `develop`) ·
**Solvers:** mosek 11.2.0 + pdco, MATLAB R2026a · Verified via the MATLAB MCP server.

## Prompt

Spec Kit human-loop feature to fix two latent entropic-FBA defects and the mosek GECKO
dual-optimality warning, all surfaced during feature 010-gecko-entropic-fba:
(1) undefined `message` crash on an infeasible enzyme-constrained EP; (2) undefined `k` in
`testEntropicFluxBalanceAnalysis`; (3) mosek dual-optimality residual = 1.45 on the GECKO cases —
Session 2026-07-16 clarification: **pursue the fix**. Implementation authorized by explicit
`/speckit-implement` (Principle VI) after Gate 2 approval of all tasks T001–T019.

## Final response

All three concerns resolved and verified green under mosek + pdco:

1. **US1 — infeasible enzyme-constrained EP no longer crashes.** The `otherwise` branch of
   `entropicFluxBalanceAnalysis` now initialises `message` before the inner
   `switch solution_optimizeCbModel.stat` and adds an `otherwise` case, so any `optimizeCbModel`
   status (including the `-1` returned for this model) yields a clean `stat = 0` with a populated
   `solution.messages` instead of an undefined-variable error. The `err_argument_dimension` was
   traced to `buildOptProblemFromModel.m:315` sizing the mosek debug constraint-name array
   `names.con = model.mets` when `model.ctrs` is absent but a `C` coupling row is present; the
   in-scope fix names the toy fixture's coupling constraint (`model.ctrs = {'enzymeCap'}`), which is
   also correct model specification. (The `buildOptProblemFromModel` behaviour is a latent
   out-of-scope follow-up.)
2. **US2 — legacy test runs standalone and validates the solve.** `testEntropicFluxBalanceAnalysis.m:29`
   `solverPkgs.EP{k}` → `{1}`. This revealed a pre-existing incompatibility: Recon3D-as-distributed
   carries 10 stoichiometrically inconsistent metabolites (under the mosek LP solver), which
   `entropicFluxBalanceAnalysis` rejects (`any(~SConsistentMetBool) → error`). The test now restricts
   Recon3D to its stoichiometrically consistent subset before solving (a 3-line, in-file addition),
   after which it solves to `stat = 1` in ~2.5 s and passes.
3. **US3 — mosek dual-optimality residual fixed (not characterized).** Root cause: `parseMskResult`
   returns reduced costs as `z = zu - zl` with stationarity `c - A'*y + (zu - zl) - F'*s = 0` (i.e.
   `+z`), but `solveCobraEP` computed the residual `res2 = grad + Aty + sol.rcost` with
   `sol.rcost = -z`, mis-signing the reduced-cost term so `res2 = (true residual) - 2z = -2z`
   (verified: `-2 × (-0.72477) = 1.4495`). The fix makes `res2` backend-specific — mosek uses
   `grad + Aty - sol.rcost` (`+z`), pdco keeps `+sol.rcost`. This changes only the **diagnostic**
   residual, never the primal or the returned `sol.rcost` (Principle II/IV safe). The mosek residual
   drops from 1.4495→3.4e-07 (GECKO feasible), 1.4513→3.8e-07 (binding), and **1187→2.5e-08**
   (non-enzyme characterization), all below `optTol = 5e-5`; the warning no longer fires.
   `testEntropicFBAgecko` now asserts the absence of the dual-optimality warning via `lastwarn`
   (VII-B: reads only, no suppression).

## Diff summary

Confined to the four allowed files (FR-009); no public signature / model-field / `.stat`/`.origStat`
change; default (no-enzyme) feasible-path primal unchanged.

- `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` (+7): define `message` for all
  `optimizeCbModel` statuses in the `otherwise` branch (+ an `otherwise` case that warns).
- `src/base/solvers/entropicFBA/solveCobraEP.m` (+17/-2): backend-specific KKT dual-optimality
  residual (`res2`), correcting the mosek reduced-cost sign; documented.
- `test/verifiedTests/analysis/testEntropicFBAgecko/testEntropicFBAgecko.m` (+45/-6): name the
  coupling constraint (`ctrs`); add the strictly-infeasible enzyme case (mosek-only — pdco does not
  detect this infeasibility); add `assertNoDualWarning` for the mosek feasible + binding cases.
- `test/verifiedTests/base/testEntropicFBA/testEntropicFluxBalanceAnalysis.m` (+10/-1): `{k}`→`{1}`;
  restrict Recon3D to its stoichiometrically consistent subset.

(Also updated: `.specify/feature.json`, `CLAUDE.md` pointer, and `specs/011-.../` artifacts.)

## Tests

Via MATLAB MCP (mosek + pdco), all green:

| Test | Result | Notes |
|---|---|---|
| `testEntropicFBAgecko` | 1 Passed / 0 Failed | feasible + binding (no dual warning), new strictly-infeasible case clean (no crash / no err_argument_dimension), E/D dimension error case |
| `testCharacterizeEntropicFBA` | 1 Passed / 0 Failed | non-enzyme `fluxes` path; mosek dual warning (was 1187) gone |
| `testEntropicFluxBalanceAnalysis` | 1 Passed / 0 Failed | Recon3D consistent subset; `stat = 1`; no `res2` dual warning |

`check_matlab_code` on all four edited files: no NEW flags at edited sites (SC-005) — remaining flags
are pre-existing (e.g. `entropicFluxBalanceAnalysis` L1692 `messages` in the feasible block;
`solveCobraEP` L161/L664 pre-existing errors; `testEntropicFluxBalanceAnalysis` L18 `global CBTDIR`).
`testEntropicFBAgecko.m` is flag-clean.

## Unresolved issues / deviations

- **Deviation (US1/FR-003):** the `err_argument_dimension` fix landed in the test fixture (`ctrs`)
  rather than `solveCobraEP`, because the root cause is `buildOptProblemFromModel.m:315`
  (`names.con = model.mets` ignores `C` rows when `ctrs` absent, under mosek debug) — outside the
  FR-009 edit scope. Latent follow-up: size `names.con` from the actual constraint count there.
- **Deviation (US2/FR-005):** required a stoichiometric-consistency preprocessing step in the test
  (not only the index fix), because Recon3D-as-distributed violates `entropicFluxBalanceAnalysis`'s
  consistency precondition under the mosek LP solver (10 inconsistent metabolites) — the 010 memo's
  "passes with k=1" was solver-dependent.
- **Observation (out of scope):** pdco returns `stat = 1` (not 0) for the strictly-infeasible enzyme
  model, with a "primal optimality only approximately satisfied, residual = 0.5" warning — a
  pre-existing pdco limitation in detecting this infeasibility; the infeasible assertion is mosek-only.
- **Observation (out of scope):** under `debug = 1`, `entropicFluxBalanceAnalysis` still prints large
  per-block biochemistry optimality residuals on Recon3D (e.g. `1.3e+04 || k_e_1 + z_e_1 ||`); these
  are a separate diagnostic from the `res2` dual-optimality warning that this feature fixed.
- Not pushed; per-phase commits deferred.
