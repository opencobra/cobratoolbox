# MATLAB Code Analyzer (checkcode) findings on core hotspot files

Environment: MATLAB **R2026a Update 3** (26.1.0.3276743), Linux. Installed toolboxes
detected via MCP: **M2HTML 1.5** and **Matrix Computation Toolbox 1.2** only — no
Optimization Toolbox, no Bioinformatics Toolbox, no Parallel Computing Toolbox on this
host. (Relevant to `requiredToolboxes`/`prepareTest` gating: the analyzer runs but many
solver paths cannot be exercised here.)

Tool: `mcp__matlab__check_matlab_code` (MATLAB Code Analyzer, read-only static analysis).

## Summary counts per file

| File | complexity (scc) | global-var warnings | unreachable-statement warnings | deprecated-fn (info) | unused/preallocation |
|---|---|---|---|---|---|
| `src/base/solvers/solveCobraLP.m` | 158 | 2 | **10** | clock/datestr/now/etime | ~20 unused-assignment |
| `src/base/solvers/getSetSolver/changeCobraSolver.m` | (dispatch) | **16** (lines 177–192) | 1 | — | several unused |
| `src/base/solvers/buildOptProblemFromModel.m` | (bridge) | 0 | 1 | — | 1 unused; 1 logic-simplification warning (line 239 `all(...)`) |
| `src/analysis/FBA/optimizeCbModel.m` | 107 | 0 | 3 | clock/etime | 1 unused |
| `src/dataIntegration/XomicsToModel/XomicsToModel.m` | 325 | 0 | **12** | hist | **6 grow-in-loop (no preallocation)** |

## Notable signals

- **Global-state surface is large and analyzer-flagged.** `changeCobraSolver.m` declares
  16 globals (lines 177–192, all "Global variables are inefficient and make errors
  difficult to diagnose"); `solveCobraLP.m` adds 2 more. This is the hidden coupling /
  testability concern quantified.
- **Dead / unreachable code in the two most load-bearing files.** `solveCobraLP.m` has 10
  "statement cannot be reached" warnings; `optimizeCbModel.m` has 3; `XomicsToModel.m`
  has 12. Unreachable branches in solver dispatch and the FBA core are latent-defect
  markers (per constitution VII-B warnings are defects, not cosmetics).
- **Deprecated time API throughout the timing code** (`clock`, `now`, `datestr`, `etime`)
  in both `solveCobraLP.m` and `optimizeCbModel.m` — a low-severity modernization item,
  but it is in the timing/telemetry path that reports `.time`.
- **`XomicsToModel.m` (complexity 325, 2290 lines)**: 6 "variable changes size on every
  loop iteration — preallocate" performance flags plus 12 unreachable-statement warnings;
  a god-file by every measure.

Raw analyzer output for each file is preserved in the conversation transcript; these
counts are the load-bearing subset.
