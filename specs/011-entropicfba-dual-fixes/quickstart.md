# Quickstart / Validation Guide: 011-entropicfba-dual-fixes

Runnable validation scenarios that prove the feature works end-to-end. Run via the MATLAB MCP
server (mosek + pdco installed) or `matlab -batch`. Implementation details live in `tasks.md`; this
is the run/verify guide.

## Prerequisites

- `initCobraToolbox` initialised; mosek on the path (`mosekopt` resolvable) and pdco available.
- `changeCobraSolver` able to select the EP path (`prepareTest('needsEP', true)` succeeds).
- Branch `011-entropicfba-dual-fixes` checked out.

## V1 — Legacy test runs standalone (US2 / FR-005 / SC-002)

Fresh MATLAB session (no stray `k` in the workspace):
```matlab
clear
runtests('testEntropicFluxBalanceAnalysis')   % or run the script directly
```
**Expected:** no `Unrecognized function or variable 'k'` error; the test loads Recon3D, calls
`entropicFluxBalanceAnalysis`, and completes with its `solution.stat == 1` assertion green.

## V2 — Infeasible enzyme-constrained EP returns stat=0, no crash (US1 / FR-001/2/3 / SC-001)

```matlab
% strictly-infeasible enzyme fixture: kcat*eMax < forced flux (R3 lb = 2)
model = buildEnzymeToy(0.5, 2);                 % eMax=0.5, kcat=2 -> v_R2 <= 1 < 2  (infeasible)
solution = entropicFluxBalanceAnalysis(model, struct('solver','mosek','printLevel',0));
assert(solution.stat == 0);                      % clean infeasible status, not a thrown error
assert(~isempty(solution.messages));             % informative message populated
```
**Expected:** returns `solution.stat == 0` with non-empty `solution.messages`; **no**
`Unrecognized function or variable 'message'` and **no** mosek `err_argument_dimension`.

## V3 — mosek dual-optimality residual (US3 / FR-006 / SC-003)

Fix path (target):
```matlab
model = buildEnzymeToy(3, 2);                    % feasible GECKO case
solution = entropicFluxBalanceAnalysis(model, struct('solver','mosek','printLevel',0));
% Expected after fix: NO "[mosek] Dual optimality condition ... not satisfied, residual = 1.45" warning
assert(solution.stat == 1);
```
Diagnostic spike (used to reach the decision, read-only):
```matlab
solDbg = entropicFluxBalanceAnalysis(buildEnzymeToy(3,2), struct('solver','mosek','printLevel',2,'debug',1));
% inspect solDbg / sol.T (tot,c,Aty,z,Ftdoty,Fty_K) to see which variable rows carry the residual
```
**Expected (fix path):** the reduced-coordinate residual ≤ `optTol = 5e-5`, warning gone, primal
`v`/`e`/objective identical to pre-change. **Expected (characterize fallback):** warning replaced by
a documented, tolerated residual; test asserts primal feasibility + KKT + status strings.

## V4 — GECKO regression: feasible + binding cases unchanged (FR-004 / SC-004)

```matlab
runtests('testEntropicFBAgecko')
```
**Expected:** feasible case (`stat==1`, `e` within bounds, `v_R2 <= kcat*e`, mass balance, forced
flux) and enzyme-limited binding case (`v_R2 == kcat*e`, fully-utilised enzyme) both pass under
mosek and pdco; the new infeasible case passes; dimension-mismatch error case still errors.

## V5 — No-enzyme regression net (FR-004 / SC-004)

```matlab
runtests('testEntropicFluxBalanceAnalysis')
```
**Expected:** non-enzyme `fluxes` path `||v||` within 1% of the 010 baseline under mosek + pdco; no
regression from the dual-residual change.

## V6 — Static analysis (SC-005)

```matlab
% via MATLAB MCP: check_matlab_code on each edited file
%   src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m
%   src/base/solvers/entropicFBA/solveCobraEP.m
%   test/verifiedTests/base/testEntropicFBA/testEntropicFluxBalanceAnalysis.m
%   test/verifiedTests/analysis/testEntropicFBAgecko/testEntropicFBAgecko.m
```
**Expected:** no NEW warnings/errors at the edited sites relative to the pre-change baseline;
warnings remain visible (not suppressed).

## Success = all of

V1 green standalone · V2 `stat==0` + message, no crash · V3 warning resolved (or documented+tolerated)
· V4 + V5 regression nets green (mosek + pdco) · V6 no new static-analysis flags.
