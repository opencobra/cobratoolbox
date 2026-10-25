# Quickstart: Reproducing Every Measurement

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-09-14

For a reviewer who wants to re-derive the numbers rather than take them on trust. Every
claim this feature makes is reproducible from these steps; where a step cannot be run in
CI, that is stated with the reason.

## Prerequisites

```matlab
initCobraToolbox(false)                     % false: skip the submodule/update block
changeCobraSolver('gurobi', 'LP');          % or any installed LP solver
getCobraSolverParams('LP', 'feasTol')       % expect 1e-6 (getCobraSolverParams.m:90)
```

`papers/` is a **git submodule**. Steps marked *(submodule)* need
`git submodule update --init papers` and are deliberately excluded from CI.

## 1. Reproduce the defect as it stands today

Establishes the baseline before any change.

```matlab
% any model with a non-trivial left nullspace
[L, Z] = greedyExtremeRayBasis(model);            % today's two-output call
Sop = model.S;
absRes    = norm(L*Sop, inf)
scaledRes = absRes / (norm(L)*norm(Sop))          % BOTH forms -- see FR-016
```

Expect an absolute residual near `1e-7` that passes today's `1e-6` guard comfortably.
That is the defect: it passes, and it is still fatal downstream.

Then show the rank gap closing on the augmented matrix:

```matlab
% N is the caller's internal stoichiometric matrix (the augmented matrix is formed
% by the caller, not by this routine -- see spec.md Key Entities).
N = model.S;
Scyc = [N, -speye(size(N,1)); sparse(size(L,1), size(N,2)), L];   % as a caller forms it
rank_lusol = getRankLUSOL(Scyc)
rank_null  = size(Scyc,2) - size(getNullSpace(Scyc), 2)
s = svd(full(Scyc));
arrayfun(@(t) sum(s > t*s(1)), [1e-9 1e-12 eps*max(size(Scyc))])   % three tolerances
```

The three routines disagreeing is the symptom. On `iDopaNeuroC` the seed measured
1261 / 1271 / (1240, 1255, 1265) against a structural 1240.

## 2. R1 — is the truncation, not the LP, the cause?

The single most important measurement, and the one that may overturn the seed's
diagnosis. Compare the residual **before and after** the truncation at
`findExtremePool.m:66`:

```matlab
feasTol = getCobraSolverParams('LP', 'feasTol');
epsilon = feasTol*10;                     % 1e-5 by default -- findExtremePool.m:36-39

% solve one ray without the truncation that line 66 applies
[~, sol] = findExtremePool(model, rand(size(model.S,1),1), 0, 1);
x_raw   = sol.full;                       % untruncated
x_trunc = x_raw;  x_trunc(abs(x_trunc) < epsilon) = 0;   % what line 66 does

norm(model.S' * x_raw,   inf)             % residual the LP actually delivered
norm(model.S' * x_trunc, inf)             % residual after zeroing sub-epsilon entries
nnz(x_raw) - nnz(x_trunc)                 % how many entries were destroyed
max(abs(x_raw(abs(x_raw) < epsilon)))     % the largest magnitude discarded
```

Repeat over >= 200 rays and >= 2 solvers. If the raw residual is orders of magnitude
smaller, the truncation is the cause and the LP floor is not binding.

**Record the verdict either way.** A refutation is a successful measurement and changes
the feature's expected outcome toward Regime B.

## 3. R2 — the LP's genuinely attainable floor

On **raw** solutions only, sweep the solver's tolerances down and find where the achieved
residual stops improving. Record per solver; solvers do not share a floor.

## 4. R3/R4 — the two numbers that may not be invented

- **R3, accuracy target**: state the symbolic derivation from the singular-value
  separation a rank determination needs, then substitute. Validate against the two known
  outcomes: it must classify `1.418e-07` as failing and `~1e-16` as passing. A derivation
  that does not reproduce both is wrong.
- **R4, regime boundary**: scale a known-good matrix by controlled factors, find where
  the R3 target stops being attainable. That crossover *is* the boundary.

## 5. Run the test

```matlab
runtests('test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m')
```

Or the whole suite, as CI does: `testAll`. The test declares its requirements through
`prepareTest`, so it skips rather than fails where no LP solver is installed, and it
fixes the random seed — the greedy search draws random objectives, so an unseeded run is
not reproducible.

## 6. `iDopaNeuroC` regression *(submodule — not CI)*

```matlab
load('papers/2023_iDopaNeuro/models/iDopaNeuroC.mat')
[L, Z, status] = greedyExtremeRayBasis(model, param);
status.outcome        % 'complete' with an unambiguous augmented rank, OR 'badlyScaled'
status.residualScaled
```

Either outcome is acceptable (SC-005). Silently returning today's basis is not. Run as a
documented reproducibility check with its output recorded under this feature directory —
Principle III sanctions this where automation is impractical, and the submodule is the
stated reason.

## 7. Check every guard against the failure it guards

Not only the success paths (FR-019, SC-007). Each of the five terminal outcomes in
[data-model.md](./data-model.md) has a fixture that forces it: short time budget forces
`'incomplete'`; the badly scaled fixture forces `'badlyScaled'`; a model without the
consistency field, called with no `param`, forces `'missingField'`; a full-row-rank
matrix forces `'emptyNullspace'`.
