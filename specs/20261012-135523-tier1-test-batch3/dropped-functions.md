# Dropped functions: batch 3

Functions of the selection table that were dropped (no test file is written) because no useful
test is possible. A drop is not a verdict that the function is fine: the reason below says what
is wrong or why a Tier-1 test is impossible. Functions that fail only for some inputs are NOT
dropped; they get a test and a defect entry (Constitution III-Defects).

| Function | Reason | Details |
|---|---|---|
| `src/reconstruction/modelGeneration/massBalance/ispolymer.m` | defect: errors for every input | Its element list `{'X','R','FULLR','FULLR2','FULLR3'}` contains names with digits; `numAtomsOfElementInFormula` rejects them ("Element must not contain numbers"), so every call fails (an empty formula fails with an index error). Lines 14-20. Expected: true when the formula contains a polymer placeholder, false otherwise. |
| `src/visualization/metabolicCartography/visualizeFluxFromFile.m` | not Tier 1: reads files | Reads a map XML file and a flux CSV file and writes an XML file. |
| `src/analysis/thermo/groupContribution/wang/createFragmentIncidenceMatrix.m` | not Tier 1: external tool and data path | Calls `autoFragment(inchi, radius, dGPredictorPath, canonicalise)`, which needs the dGPredictor data files and a cheminformatics toolchain; it cannot run on plain data. |
| `src/dataIntegration/fluxomics/score_KS.m` | not Tier 1: MATLAB toolbox | Uses `kstest2` (Statistics and Machine Learning Toolbox) inside a `parfor` loop (Parallel Computing Toolbox). |
| `src/dataIntegration/fluxomics/calcMDVfromSamp.m` | not Tier 1: external solver routine | Needs the EMU solver `slvrEMU_fast`, an experiment structure with fragments, and a `parfor` loop. |
| `src/reconstruction/modelGeneration/stoichConsistency/optimalConservationVectors.m` | not Tier 1: needs a solver | Builds a problem and calls `optimizeCardinality`, which needs an optimisation solver. |
| `src/base/io/convertCobraLP2mps.m` | not Tier 1: writes a file | Builds an MPS problem and writes `<name>.mps` with `SaveMPS`. |
| `src/analysis/persephone/additionalFunctions/convertVMHIDName.m` | not Tier 1: reads a data file | Loads the VMH metabolite database with `loadVMHDatabase`. |
| `src/analysis/persephone/additionalFunctions/getVMHID.m` | not Tier 1: reads a data file | Loads the VMH metabolite database with `loadVMHDatabase`. |
| `src/analysis/persephone/performRegressions.m` | not Tier 1: MATLAB toolbox | Uses `fitglm` (Statistics and Machine Learning Toolbox); the product scan did not report it. |
| `src/analysis/persephone/runNonparametricTests.m` | not Tier 1: MATLAB toolbox | Uses `ranksum` and `kruskalwallis` (Statistics and Machine Learning Toolbox); the product scan did not report it. |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/performStatisticalAnalysis.m` | not Tier 1: MATLAB toolbox and data file | Uses `ranksum`, `kruskalwallis`, `anova1`, `mafdr` and `loadVMHDatabase`. |
| `src/analysis/topology/reactingMoieties/addBondMappingsRXNFile.m` | not Tier 1: reads a file | Reads a reaction file (`.rxn`) with `readABRXNFile`. |
| `src/analysis/topology/reactingMoieties/extractBondSubgraphs.m` | not testable faithfully | Needs domain-specific atom-transition and bond-instance graphs. A minimal hand-built pair of graphs made the function loop without terminating (the loop that resets the edge counter), so no safe, faithful input could be constructed. |
| `src/visualization/metabolicCartography/removeMapMol.m` | not Tier 1: needs a CellDesigner map | Works on a parsed CellDesigner XML structure together with map matrices (`getMapMatrices`, `getCorrespondingRows/Cols`); no faithful plain-data input exists. |
