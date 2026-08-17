# Data Model / Change Contracts: Optional GECKO support in entropicFluxBalanceAnalysis

No new runtime data model; the "entities" are the optional model fields, the function's additive
contract, the new helper, and the enzyme block folded into the entropic problem.

## E1 — Optional input fields (semantics per `buildOptProblemFromModel`, research R3)

| Field | Meaning | Dimension check |
|-------|---------|-----------------|
| `model.E` | enzyme-variable columns in the metabolite (`S`) rows | rows == `size(S,1)`; cols == nEvar |
| `model.D` | enzyme-variable columns in the coupling (`C`) rows | rows == `size(C,1)`; cols == nEvar |
| `model.evarlb`/`evarub` | box bounds on the enzyme variables | length == nEvar; `evarlb <= evarub` |
| `model.evarc` | linear objective on the enzyme variables | length == nEvar |

Activation: presence of `E` (with `D`/evar*) via `isfield`/`~isempty` (not `nargin`). Partial/
inconsistent specification → error with `ME.stack` (FR-004). Absent → today's path (FR-002).

## E2 — `entropicFluxBalanceAnalysis.m` (edited, additive)

- **Detection**: after the model is loaded, detect the enzyme fields; if absent, unchanged path.
- **Consistency relax (CQ1/FR-003a)**: when present, scope the stoichiometric-consistency handling so
  enzyme-as-substrate reactions/columns are treated as added variables (not required mass-balanced);
  strict for genuine metabolic reactions. Field-presence-driven; no new param.
- **Fold-in**: append the `E` block to the metabolite rows and the `D` block to the coupling rows of
  `EPproblem.A` (extending the existing `[N -N B; (C -C D)]` assembly), the enzyme columns AFTER the
  reaction columns; append `evarlb/evarub` to `lb/ub` and `evarc` to the linear `c` (matching
  `buildOptProblemFromModel` ordering). Per method/backend (fluxes: mosek ~:1216-1219 & the `d`
  assignment ~:1151-1152; pdco ~:854-857 & ~:896-897).
- **Entropy on enzymes (CQ2/FR-003)**: set the enzyme columns' `EPproblem.d` entries `>0` (the entropy
  weight for enzyme usage), so `solveCobraEP` adds a PEXP cone (mosek) / `x log x` term (pdco) per
  enzyme column. Enzyme columns kept strictly positive (log domain).
- **Post-solve reindex (the risk)**: `nExpCone` now includes the enzyme columns; update the cone-dual
  reordering (`Fty_K`, ~:681-700) and the `auxPrimal/coneF/auxRcost` offsets so the enzyme-usage
  primal values and duals are extracted correctly; add them to the solution struct.
- **No public-interface change**: signature `[solution, modelOut] = entropicFluxBalanceAnalysis(model, param)`
  unchanged; existing outputs unchanged; enzyme outputs are ADDITIVE new fields.

## E3 — New helper `prepareEnzymeConstrainedEP.m` (working name)

- Validates E/evar*/D dimensions against S/C (FR-004), returns the assembled enzyme block (columns,
  bounds, objective, entropy-`d` entries) for the main function to splice in. openCOBRA header,
  camelCase, `ME.stack` on error. Keeps the fold-in logic testable and single-sourced.

## E4 — Solution struct additions (additive)

- New fields for the enzyme-usage primal values and their duals (names TBD in implementation, e.g.
  `.e`/`.z_e`), alongside the existing `.v/.vf/.vr/.y_N/...`. Existing fields unchanged.

## E5 — Fixtures & tests

- `testEntropicFluxBalanceAnalysis`: pins current `fluxes` non-GECKO behaviour (`.stat` exact; objective/
  flux/duals within tol) under mosek AND pdco. References captured from CURRENT code via MATLAB MCP.
- `testEntropicFBAgecko`: a minimal committed enzyme-constrained fixture solved through the GECKO path
  under mosek and pdco; asserts feasibility, `[S E; C D]`/evar-bound satisfaction, evarc objective
  contribution, canonical `.stat`/`.origStat`. Liver-GECKO full-mode-only.

## Backward-compat / gate-safety contract

- No change to `entropicFluxBalanceAnalysis` signature, existing outputs, default (no-`E`) results,
  `solveCobraEP` signature, or any existing model field meaning (Principle II).
- Only new file: `prepareEnzymeConstrainedEP.m` under `entropicFBA/`. No AdaptGECKO fork shipped.
- `fluxConc`/`fluxConcNorm` enzyme support explicitly OUT of scope (documented follow-up).
