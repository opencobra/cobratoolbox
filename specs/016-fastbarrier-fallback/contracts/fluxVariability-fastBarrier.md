# Contract: `fluxVariability` fastBarrier Fallback

**Feature**: 016-fastbarrier-fallback  
**Public function**: `src/analysis/FVA/fluxVariability.m`

## Public call surface

No public signature change. Existing calls remain valid, including:

```matlab
[minFlux, maxFlux] = fluxVariability(model, 90, 'max', rxnNames, 'fastBarrier', 1, 'threads', 1);
```

The feature introduces no new user-facing parameter and does not change documented ordinary
FVA behaviour.

## Behavioural contract

1. When `fastBarrier` is disabled, `fluxVariability` behaviour is unchanged.
2. When `fastBarrier` is enabled, the first LP attempt for each reaction bound uses the
   existing fast no-crossover barrier path.
3. If that first attempt returns an optimal COBRA solution, its flux value is used exactly as
   before.
4. If that first attempt reports native Gurobi status `NUMERIC` and no valid optimal COBRA
   solution is available, `fluxVariability` retries the same LP with barrier crossover enabled
   or with the crossover override removed.
5. If the retry returns an optimal COBRA solution, the retry's flux value is used for that
   reaction bound.
6. If both attempts fail to produce a valid solution, the existing FVA error semantics remain:
   no invalid flux value is returned as if it were valid.
7. Existing unbounded handling is unchanged.
8. The user's pre-call LP solver is restored after fastBarrier completion or failure.

## Numerical contract

- For the verified FVA reaction set, fastBarrier min/max fluxes must match standard FVA
  min/max fluxes within the existing `testFVA` tolerance.
- The fallback must not alter the LP model, objective sense, target reaction, optimum
  percentage constraint, or loop-law decision relative to the failed first attempt.
- The fallback must not classify infeasible or unbounded outcomes as recoverable numeric
  failures.

## Test contract

Primary validation:

```matlab
testFVA
```

Required outcomes in a Gurobi-enabled environment:

- The fastBarrier section completes.
- The `PFK` and `PPS` cases that previously failed through native status `NUMERIC` return
  finite values through fallback.
- The standard-vs-fastBarrier min/max assertions in `testFVA` pass.
- Ordinary FVA sections in `testFVA` continue to pass.

Implementation may add focused assertions to `testFVA` if needed, but must not weaken or
remove existing fastBarrier comparison assertions.
