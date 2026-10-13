# Dropped functions (batch 4)

Functions of the selection table that the probe showed cannot be tested faithfully at Tier 1. No test file is written for them.

| Function | Why dropped | Detail |
|---|---|---|
| `src/base/solvers/varKin/derFreeMethods/Rate_function.m` and `src/base/solvers/varKin/BDCAmethods/Rate_function.m` | name shared by two files | Two source files have the same function name, so one test file named per III-Naming cannot address either; they are excluded rather than tested ambiguously. |
| `src/analysis/persephone/createForestPlot.m` | not Tier 1: plotting | Draws with `scatter`, `line`, `legend` and axes properties; the result is a figure, not data. |
| `src/analysis/persephone/createVolcanoPlot.m` | not Tier 1: plotting | Draws with `scatter`, `text`, `xline` and axes properties; the result is a figure, not data. |
| `src/analysis/relaxedFBA/plotRelaxedFBA.m` | not Tier 1: plotting | Creates figures and bar plots from a relaxed FBA solution. |
| `src/analysis/sampling/BarrierRound/CMatrix/configCMatrix.m` | not Tier 1: changes the MATLAB path | Adds folders to the path and runs a `config` script; the effect is persistent session state. |
| `src/analysis/sampling/BarrierRound/PolytopeSimplifier/configPolytopeSimplifier.m` | not Tier 1: changes the MATLAB path | Adds folders to the path and loads further modules through `loadModular`. |
| `src/analysis/sampling/BarrierRound/utils/loadModular.m` | not Tier 1: changes the MATLAB path | Adds a sibling folder to the path and runs its `config` function. |
| `src/analysis/sampling/CHRR/chrrExpSampler.m` | not Tier 1: random walk with compiled helpers | Preprocessing and sampling call the BarrierRound routines (compiled MEX code) and the Parallel Computing Toolbox is reported. |
| `src/analysis/topology/FR/combinatorialDependentRows.m` | not Tier 1: needs a solver | Solves a binary semidefinite program with CVX and MOSEK (`cvx_solver mosek`, `cvx_begin sdp`). |
| `src/analysis/topology/FR/connectedFR.m` | not Tier 1: external library | Needs the GAIMC graph library (`largest_component`, `scomponents`), which is not part of the toolbox; without it the function only raises an error. |
| `src/analysis/topology/FR/largestConnectedFR.m` | not Tier 1: external library | Needs the GAIMC graph library (`largest_component`), which is not part of the toolbox; without it the function only raises an error. |
| `src/analysis/wholeBody/PSCMToolbox/setConstraints/setDietConstraints.m` | not Tier 1: runs data scripts | Calls the diet and AGORA essential-metabolite scripts (`EUAverageDietNew`, `AGORAEssentialMetabolites`, ...), which define their data by running script files. |
| `src/base/install/addCOBRABinaryPathToSystemPath.m` | not Tier 1: changes the system environment | Changes the system path of the MATLAB process and depends on the operating system. |
| `src/base/install/getGitBashVersion.m` | not Tier 1: runs system commands | Runs `git` through the operating system. |
| `src/base/io/KEGG/mapKEGGID2Model.m` | always errors | Every input tried fails: a metabolite with a compartment stops with "Too many input arguments" and a metabolite without one reads the never-assigned variable `KEGGComp`. |
| `src/base/io/utilities/model2xls.m` | not Tier 1: writes a file | Writes a spreadsheet with `xlswrite`/`writetable`. |
| `src/base/io/writeGDXFromCOBRA.m` | not Tier 1: writes a file and needs GAMS | Writes a GDX file with the GAMS interface. |
| `src/base/solvers/cplex/buildCplexProblemFromCOBRAStruct.m` | not Tier 1: needs a solver | Creates a `Cplex()` object and stops with an error when CPLEX is not installed or licensed. |
| `src/base/solvers/param/parseSolverParameters.m` | not Tier 1: depends on solver configuration | Reads the default solver and its parameter defaults from the solver state, so the result depends on the installed and configured solvers. |
| `src/dataIntegration/fluxomics/getBinsOfFluxes.m` | always errors on its main path | After the early exits (too few samples), the output variable is a number (`output = 0`) and the function then assigns `output.samps`, which fails for every input that reaches that line. |
| `src/dataIntegration/transcriptomics/rFASTCORMICS/createFitL.m` | not Tier 1: MATLAB toolbox | Uses `fit`, `fittype` and `fitoptions` (Curve Fitting Toolbox). |
| `src/dataIntegration/transcriptomics/rFASTCORMICS/createFitR.m` | not Tier 1: MATLAB toolbox | Uses `fit`, `fittype` and `fitoptions` (Curve Fitting Toolbox). |
