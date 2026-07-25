# Data Model: enzyme-aware diagnostics (012)

No new persisted entities. The feature reads existing runtime quantities and prints derived residuals.

## Inputs consumed (all already produced by 010/current code)

| Symbol | Source | Meaning |
|--------|--------|---------|
| `hasEnzymes` | function scope (L313): `isfield(model,'E') && ~isempty(model.E) && size(model.E,2)>0` | guard: enzyme path active |
| `model.E` | model (010) | `m x nEvar` enzyme columns in the metabolite rows |
| `model.D` | model (010) | `nCoupling x nEvar` enzyme columns in the coupling rows |
| `model.evarc` | model (010) | `nEvar x 1` linear objective on enzyme-usage variables |
| `solution.e` | 010 extraction (L933): `solution.full(end-nEvar+1:end)` | enzyme-usage primal |
| `solution.z_e` | 010 extraction (L935): `solution.rcost(end-nEvar+1:end)` | enzyme reduced cost (bound dual) |
| `y_N` | `solution.dual(1:m)` (pdco) / mosek dual | metabolite mass-balance dual |
| `y_C` | `solution.dual(...)` when `model.C` | coupling-constraint dual |
| `vf, vr, ve` | `solution.full` slices | internal forward/reverse + external net flux |

## Derived diagnostics (printed only when `hasEnzymes`)

| Residual (new/augmented) | Expression | Block |
|--------------------------|------------|-------|
| Enzyme stationarity (NEW line) | `model.evarc + model.E'*y_N + model.D'*y_C + solution.z_e` (sign per backend, R5) | Optimality conditions (biochemistry) / Dual optimality (fluxes) |
| Mass-balance primal (AUGMENT) | add `+ model.E*solution.e` to the existing `N*(vf-vr) + B*ve [- x + x0] - b` | Primal / Optimality conditions |
| Coupling primal (NEW line, if `model.C`) | `model.C*(vf-vr) + model.D*solution.e - model.d` | Primal / coupling effects |

## Invariants

- When `hasEnzymes` is false, none of the above execute → printed output identical to pre-change (FR-004).
- The change reads `solution` only; it never writes `solution`, `.stat`, `.origStat`, or any field (FR-005).
- Counts use `size(model.E,2)` / `numel(solution.e)` (robust) rather than the fold-in-local `nEvar`.
