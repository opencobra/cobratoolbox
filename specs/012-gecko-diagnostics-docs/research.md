# Research: GECKO header docs + enzyme-aware KKT/thermo diagnostics (012)

## R1 — Where the diagnostic blocks live and what variables are in scope

`entropicFluxBalanceAnalysis.m` prints KKT/thermo diagnostics under `param.printLevel > 0/1` in two
solver branches of the `'fluxes'` path:

- **pdco branch** (~L420–532): variables `vf, vr, v, x, x0, dx` (from `solution.full`), `ve = -B'*(x-x0)`,
  duals `y_N = solution.dual(1:m)`, `y_vi`, `z_dx`, `y_C` (if `model.C`), and bound reduced costs
  `z_vf, z_vr, z_vi, z_x, z_x0` (from `solution.rcost`). Blocks: "Primal optimality conditions",
  "Dual optimality conditions (fluxes)", "Thermo conditions (fluxes)", "(regularised)" variants.
- **mosek branch** (~L700–860+): cone duals `k_vf, k_vr, k_ve, k_x, k_x0, k_e_1, k_e_vf, k_e_vr`
  (`Fty_K = solution.coneF' * y_K`), bound reduced costs `z_vf, z_vr, z_ve, z_x, z_x0` (`solution.rcost`),
  `y_N, y_C, y_vi`, totals `t_vfvr, t_x, t_x0`. Blocks: "Optimality conditions (biochemistry)",
  "Derived optimality conditions (fluxes)/(concentrations)", "Thermo conditions (fluxes)/(concentrations)".

**Decision**: the enzyme-aware terms are added inside these existing `param.printLevel` blocks in both
branches, guarded by `hasEnzymes`. **Rationale**: keeps all diagnostics in one place; guarded additions
guarantee byte-identical non-enzyme output (FR-004). **Alternatives considered**: a separate enzyme
diagnostic block (rejected — duplicates the residual scaffolding and splits the read-out).

## R2 — CRITICAL naming: `ve/ce/z_ve` are EXTERNAL reactions, NOT enzymes

In this function `ve`/`ce`/`z_ve` (and `B`, `k_ve`) denote the `k` EXTERNAL reactions from the
`SConsistentRxnBool` split of `model.S` — **not** the GECKO enzyme columns. The GECKO enzyme-usage
variables are the `nEvar` columns appended by `prepareEnzymeConstrainedEP` (010) and are exposed as
`solution.e` and `solution.z_e`. **Decision**: the enzyme diagnostics MUST use enzyme-specific symbols
(`solution.e`, `solution.z_e`, `model.E`, `model.D`, `model.evarc`) and MUST NOT reuse `ve/ce/z_ve`.
The spec's shorthand "`ce + E'*y_N + D'*y_C + z_ve`" maps to the enzyme quantities
`model.evarc + model.E'*y_N + model.D'*y_C + solution.z_e`.

## R3 — Enzyme columns are linear ⇒ cone/`Fty_K` indexing is unaffected

Enzyme columns are linear by default (`enzymeEntropyWeight = 0`; `dEnzyme = 0`), so they add no
exponential-cone rows. `solution.e`/`solution.z_e` sit at the END of `solution.full`/`solution.rcost`
(appended columns), beyond every position-based extraction in the diagnostic blocks, and the
`coneF`/`Fty_K` cone-dual indices are unchanged. **Consequence**: enzyme diagnostics are strictly
additive — no existing extraction shifts, no reindexing (this is why 010's linear default was safe).
`hasEnzymes` (function scope, L313) and `solution.e`/`z_e` (L933/935) are all available at the blocks;
use `size(model.E,2)` / `numel(solution.e)` for the count rather than the fold-in-local `nEvar`.

## R4 — The enzyme-augmented residual expressions

For the linear enzyme columns the KKT conditions are:

1. **Enzyme-column stationarity (new line)**: `model.evarc + model.E'*y_N + model.D'*y_C + solution.z_e ≈ 0`.
   The enzyme column occupies the metabolite rows (via `model.E`, dual `y_N`) and the coupling rows
   (via `model.D`, dual `y_C`); `solution.z_e` is the bound reduced cost. Printed only if `hasEnzymes`.
2. **Enzyme contribution to the primal mass balance**: the residual becomes
   `N*(vf-vr) + B*ve + model.E*solution.e - x + x0 - b` (add `E*e`). In `buildEnzymeToy` `model.E = 0`,
   so this term is zero for the toy but is required for correctness on general ecModels.
3. **Enzyme contribution to the coupling primal (new line when `model.C` present)**:
   `model.C*(vf-vr) + model.D*solution.e - model.d` (add `D*e`).

The existing thermo/optimality lines that already reference `y_N`/`y_C` need no algebra change — those
duals already reflect the enzyme constraints in their VALUES; only the enzyme's own stationarity and the
enzyme primal terms are missing. **Decision**: add (1)–(3) guarded by `hasEnzymes`; leave the internal-
flux entropy thermo lines' algebra unchanged (enzymes are not entropy-split).

## R5 — Backend dual sign convention (verify, per 011)

011 found mosek and pdco use opposite reduced-cost sign conventions in `solveCobraEP`'s `res2`
(mosek uses `-sol.rcost`). **Decision**: derive the stationarity analytically, then EMPIRICALLY verify
the residual is small on `buildEnzymeToy` under EACH backend, flipping the `solution.z_e` (and/or
dual) sign per backend if required so the printed residual is ~0 for a well-solved problem — exactly
the pattern 011 used. The characterization test pins that whatever is printed for the NON-enzyme case
is unchanged; the GECKO check pins the enzyme residual is small on both backends.

## R6 — Fixtures & verification

- **GECKO**: the committed `buildEnzymeToy(eMax, kcat)` local fixture in `testEntropicFBAgecko.m` (010).
  Solve at `printLevel = 2` and assert the enzyme stationarity residual ≤ tol under mosek + pdco.
- **Non-enzyme invariance**: capture the printed diagnostic block text for a small non-enzyme model
  (ecoli_core or the Recon3D consistent subset) at `printLevel = 2` BEFORE the change (reference) and
  assert identical AFTER (FR-004). Capture via `evalc` of the call **for test capture only** — note
  VII-A forbids `evalc` that SUPPRESSES warnings/shadows built-ins in SOURCE; using `evalc` inside a
  TEST to capture stdout for comparison is acceptable, but the test must re-emit or assert on warnings
  so none are hidden. Alternative: compare specific `norm(...)` residual values recomputed in the test.
  **Decision**: prefer recomputing the enzyme residual directly in the test from returned
  primal/duals (robust, no stdout parsing); use it for BOTH the GECKO assertion and as the invariance
  check basis. Deferred to plan/tasks.
