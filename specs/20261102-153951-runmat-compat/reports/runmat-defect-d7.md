# RunMat defect D7: compiler panic on a class property default that is not a numeric literal

**RunMat**: `feature/clean-room-matlab-builtins` @ `ebc6509f3` (0.6.2). **Found by**: task T015, 2026-11-02.

## Reproducer

`P.m`:

```matlab
classdef P
   properties
      w = NaN
   end
end
```

`runmat check P.m` stops with:

```
thread 'main' panicked at crates/runmat-hir/src/lowering/ctx.rs:630:28:
semantic lowering scope
```

The test-runner discovery stops with the same panic; it then runs no test at all.

## Scope (each a one-property class as above)

| Default value | Result |
|---|---|
| `w = 1` | OK |
| `w = NaN`, `w = NaN;`, `w = nan`, `w = Inf`, `w = pi`, `w = true` | panic |
| `w = NaN(2,1)`, `w = zeros(2)` | panic |
| `x = struct('dense', 0, 'sparse', 1)` in `properties (TestParameter)` | panic |

A numeric literal is accepted, while any default that names a function (with or without arguments) panics.

## COBRA files affected (in scope)

| File | Reduced to |
|---|---|
| `src/analysis/sampling/BarrierRound/CMatrix/include/AdaptiveChol.m` | `w = NaN` |
| `src/analysis/sampling/BarrierRound/CMatrix/coverage/CMatrixTest.m` | `rhsMode = struct('dense', 0, 'sparse', 1);` in `properties (TestParameter)` |
| `src/analysis/sampling/BarrierRound/PolytopeSimplifier/coverage/PolytopeSimplifierTest.m` | `problemName = struct('none', struct('name', 'none'));` in `properties(TestParameter)` |

Each was reduced on a copy outside the repository. The reducer deleted only whole blocks or simple statements, and kept a deletion only while the panic remained. The script is in the scratch area and is not part of the feature.

## Decision (FR-006)

The files are not rewritten. No small change keeps MATLAB's parse tree identical: moving a default into the constructor changes what the parse tree records. For a `TestParameter` it changes how `matlab.unittest` parametrizes the test. The three files are listed in `reports/runmat-set-aside.txt`, so RunMat discovery can measure the other files.
