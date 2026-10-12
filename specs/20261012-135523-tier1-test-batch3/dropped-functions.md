# Dropped functions: batch 3

Functions of the selection table that were dropped (no test file is written) because no useful
test is possible. A drop is not a verdict that the function is fine: the reason below says what
is wrong or why a Tier-1 test is impossible. Functions that fail only for some inputs are NOT
dropped; they get a test and a defect entry (Constitution III-Defects).

| Function | Reason | Details |
|---|---|---|
| `src/reconstruction/modelGeneration/massBalance/ispolymer.m` | defect: errors for every input | Its element list `{'X','R','FULLR','FULLR2','FULLR3'}` contains names with digits; `numAtomsOfElementInFormula` rejects them ("Element must not contain numbers"), so every call fails (an empty formula fails with an index error). Lines 14-20. Expected: true when the formula contains a polymer placeholder, false otherwise. |
| `src/visualization/metabolicCartography/visualizeFluxFromFile.m` | not Tier 1: reads files | Reads a map XML file and a flux CSV file and writes an XML file. |
