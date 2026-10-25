# Quickstart: Reproducing the Coverage Comparison

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-09-15

## Prerequisites

```matlab
initCobraToolbox(false)
```

At least two LP solvers are needed for a paired comparison. Measured here: gurobi 1302,
mosek 11.2, glpk, pdco. `iDopaNeuroC` needs `git submodule update --init papers` and is a
documented check, not CI.

**Branch note**: this feature sits on top of
`20260914-204640-greedy-left-nullspace-conditioning`, not `develop`. Rebase once the
parent merges.

## 1. Reproduce the gap

```matlab
d = load('papers/2023_iDopaNeuro/models/iDopaNeuroC.mat'); m = d.iDopaNeuroC;
mm = struct('S', m.S(:, m.SConsistentRxnBool), ...
            'SConsistentRxnBool', true(nnz(m.SConsistentRxnBool), 1));
p.printLevel = 0; p.maxNewBasisTime = 40; p.maxTime = 300;

for s = {'gurobi', 'mosek'}
    changeCobraSolver(s{1}, 'LP', 0); rng(20260914, 'twister');
    [~, ~, st] = greedyExtremeRayBasis(mm, p);
    fprintf('%-8s %3d/%3d rays  residual %.4e  target %.4e\n', ...
        s{1}, st.raysFound, st.raysExpected, st.residualAbsolute, st.accuracyTarget);
end
```

Expect gurobi accurate but short of full coverage, mosek complete but above target. That
is the gap this feature exists to close.

## 2. Confirm the geometry is not the obstacle

```matlab
addpath('specs/20260914-204640-greedy-left-nullspace-conditioning/measurements')
checkNonNegativeConeSpan
```

Expect a strictly positive conservation vector, hence `span(K) = ker(N')` and every
direction reachable with non-negative weights. If this ever fails on a model, the shortfall
there is `'structural'`, not `'sampling'`.

## 3. Run the paired comparison

```matlab
p.compareSolvers = {'gurobi', 'mosek'};
[~, ~, st] = greedyExtremeRayBasis(mm, p);
```

Every solver receives the identical partial basis and the identical objective vector at
each point. Check `objectiveHash` is constant within each comparison group — that is what
makes the pairing auditable rather than merely claimed.

Read `meetsTarget` against `independentOfBasis`: the first is accuracy, the second is
vertex diversity, and the whole question is which solver supplies which.

## 4. Confirm the instrumentation is inert when off

```matlab
rng(20260914,'twister'); p1 = rmfield(p, 'compareSolvers');
[Za, ~, sa] = greedyExtremeRayBasis(mm, p1);
rng(20260914,'twister'); p2 = p1; p2.compareSolvers = {};
[Zb, ~, sb] = greedyExtremeRayBasis(mm, p2);
isequal(Za, Zb) && sa.raysFound == sb.raysFound     % must be true (SC-011)
```

## 5. Verify a tuned setting actually took effect

Do not infer this from having set the value. The toolbox reports no algorithm — its
gurobi `Method` label is off by one against its own comment and is never returned — so use
an observable: presence of `vbasis`/`cbasis`, iteration count, solve time, or the number
of components sitting exactly at a bound.

## 6. Run the tests

```matlab
runtests('test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m')
```

Or through the harness as CI does, without the full suite:

```bash
COBRA_CI=1 COBRA_TESTS='testGreedyExtremeRayBasis' matlab -batch "cd('test'); testAll"
```
