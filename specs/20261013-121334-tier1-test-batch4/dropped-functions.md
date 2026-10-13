# Dropped functions (batch 4)

Functions of the selection table that the probe showed cannot be tested faithfully at Tier 1. No test file is written for them.

| Function | Why dropped | Detail |
|---|---|---|
| `src/base/solvers/varKin/derFreeMethods/Rate_function.m` and `src/base/solvers/varKin/BDCAmethods/Rate_function.m` | name shared by two files | Two source files have the same function name, so one test file named per III-Naming cannot address either; they are excluded rather than tested ambiguously. |
| `src/analysis/persephone/createForestPlot.m` | not Tier 1: plotting | Draws with `scatter`, `line`, `legend` and axes properties; the result is a figure, not data. |
| `src/analysis/persephone/createVolcanoPlot.m` | not Tier 1: plotting | Draws with `scatter`, `text`, `xline` and axes properties; the result is a figure, not data. |
| `src/analysis/relaxedFBA/plotRelaxedFBA.m` | not Tier 1: plotting | Creates figures and bar plots from a relaxed FBA solution. |
