# Known defects in tested functions

> **Generated file: do not edit by hand.** It is built from the "Known defects documented" section of each test header by `python3 .github/scripts/known_defects.py` (Constitution III-Defects).
> It is a snapshot: a function may have been changed or fixed since an entry was written. When you rely on an entry or work on resolving a defect, re-check it against the current source, then update the test header and regenerate this file.

34 known defects in 28 functions (9 wrong-result, 14 error, 3 unusable-option, 4 cosmetic, 4 limitation).

## Summary

| Function | Severity | Problem | Test file |
|----------|----------|---------|-----------|
| `src/analysis/exploration/surfNetSubfunctions/numToFormattedString.m` | unusable-option | Width argument ignored for array input | `test/verifiedTests/analysis/testExploration/testNumToFormattedString.m` |
| `src/analysis/igemRNA/GT1/findGenesAboveThresholdGT1.m` | error | Errors when no gene qualifies | `test/verifiedTests/analysis/testGT1/testFindGenesAboveThresholdGT1.m` |
| `src/analysis/igemRNA/GT1/findGenesBelowThresholdGT1.m` | error | Errors when no gene qualifies | `test/verifiedTests/analysis/testGT1/testFindGenesBelowThresholdGT1.m` |
| `src/analysis/persephone/calculateMetrics.m` | wrong-result | Bray-Curtis wrong for a single taxon | `test/verifiedTests/analysis/testPersephone/testCalculateMetrics.m` |
| `src/analysis/rumba/compareConditions.m` | limitation | Sample-point count taken from the first metabolite of the first list | `test/verifiedTests/analysis/testRumba/testCompareConditions.m` |
| `src/analysis/topology/reactingMoieties/createBIGraph.m` | error | No edges left after removing the energy node errors | `test/verifiedTests/analysis/testTopology/testCreateBIGraph.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/calculateFoodScore.m` | error | Default translation assigned when nargin < 3 | `test/verifiedTests/analysis/testWholeBody/testCalculateFoodScore.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/compareDiets.m` | error | Direction false errors | `test/verifiedTests/analysis/testWholeBody/testCompareDiets.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/searcher.m` | unusable-option | Non-iterative search type cannot run | `test/verifiedTests/analysis/testWholeBody/testSearcher.m` |
| `src/base/io/utilities/SBML/getDataBases.m` | wrong-result | Mixed matching and non-matching resources return nothing | `test/verifiedTests/base/testIO/testUtilities/testGetDataBases.m` |
| `src/base/io/utilities/SBML/getDataBases.m` | error | Third output unassigned when nothing matches | `test/verifiedTests/base/testIO/testUtilities/testGetDataBases.m` |
| `src/base/io/utilities/parseSBMLAnnotationField.m` | wrong-result | ChEBI ID keeps a stray 3A prefix in the urn:miriam notation | `test/verifiedTests/base/testIO/testUtilities/testParseSBMLAnnotationField.m` |
| `src/base/parseMetNames.m` | limitation | Mixed or longer compartment notations are not parsed | `test/verifiedTests/base/testTools/testParseMetNames.m` |
| `src/base/solvers/varKin/BDCAmethods/StopCritBDCA.m` | error | Outputs unassigned for a criterion outside 1 to 5 | `test/verifiedTests/base/testSolvers/testStopCritBDCA.m` |
| `src/base/solvers/varKin/BDCAmethods/StopCritBDCA.m` | error | Stopping criterion 1 uses an undefined variable | `test/verifiedTests/base/testSolvers/testStopCritBDCA.m` |
| `src/base/solvers/varKin/derFreeMethods/InitialDuplo.m` | unusable-option | Option flag_x_error can never be set | `test/verifiedTests/base/testSolvers/testInitialDuplo.m` |
| `src/base/solvers/varKin/derFreeMethods/StopCritDuplo.m` | error | Outputs unassigned for a criterion outside 1 to 5 | `test/verifiedTests/base/testSolvers/testStopCritDuplo.m` |
| `src/base/solvers/varKin/derFreeMethods/StopCritDuplo.m` | error | Stopping criterion 1 uses an undefined variable | `test/verifiedTests/base/testSolvers/testStopCritDuplo.m` |
| `src/base/utilities/getDefaultValue.m` | error | No default for struct and function-handle input | `test/verifiedTests/base/testTools/testGetDefaultValue.m` |
| `src/base/utilities/isvar.m` | limitation | Index is 1 for a structure even when the field is missing | `test/verifiedTests/base/testTools/testIsvar.m` |
| `src/dataIntegration/chemoInformatics/editChemicalFormula.m` | cosmetic | Element with zero atoms stays in the formula | `test/verifiedTests/dataIntegration/testChemoInformatics/testEditChemicalFormula.m` |
| `src/dataIntegration/chemoInformatics/inchi/getInchiData.m` | wrong-result | Negative charge layer gives NaN | `test/verifiedTests/dataIntegration/testChemoInformatics/testGetInchiData.m` |
| `src/dataIntegration/chemoInformatics/inchi/getInchiData.m` | error | Several layers containing the letter p error | `test/verifiedTests/dataIntegration/testChemoInformatics/testGetInchiData.m` |
| `src/dataIntegration/fluxomics/c13solver/Combination.m` | cosmetic | Negative parameters print a message and return empty | `test/verifiedTests/dataIntegration/testFitC13Data/testCombination.m` |
| `src/dataIntegration/fluxomics/c13solver/Combination.m` | error | k = 0 errors | `test/verifiedTests/dataIntegration/testFitC13Data/testCombination.m` |
| `src/dataIntegration/metaboAnnotator/buildMetStruct/cleanUpMetabolite_structure.m` | cosmetic | Loop index printed to the console | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testCleanUpMetabolite_structure.m` |
| `src/dataIntegration/metaboAnnotator/connect2resources/convertOld2NewHMDB.m` | limitation | Identifiers of 12 or more characters give an empty result | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testConvertOld2NewHMDB.m` |
| `src/reconstruction/comparison/modelBorgifier/buildRxnEquationsFromName.m` | wrong-result | Backward-only reactions list the substrate on both sides | `test/verifiedTests/reconstruction/testModelBorgifier/testBuildRxnEquationsFromName.m` |
| `src/reconstruction/demeter/src/integration/checkInputData.m` | cosmetic | Header name listed in removedStrains | `test/verifiedTests/reconstruction/testDemeter/testCheckInputData.m` |
| `src/reconstruction/demeter/src/integration/checkInputData.m` | wrong-result | Unknown strain row not removed when the headers are equal | `test/verifiedTests/reconstruction/testDemeter/testCheckInputData.m` |
| `src/reconstruction/modelGeneration/massBalance/ispolymer.m` | error | Always errors because the element list contains names with digits | `test/verifiedTests/reconstruction/testMassChargeBalance/testIspolymer.m` |
| `src/reconstruction/refinement/GPRLogic/combineChildren.m` | wrong-result | Identical generated clauses delete the earlier clause | `test/verifiedTests/reconstruction/testModelManipulation/testCombineChildren.m` |
| `src/reconstruction/refinement/getMetAbbr.m` | wrong-result | IDs without brackets are silently dropped | `test/verifiedTests/reconstruction/testModelManipulation/testGetMetAbbr.m` |
| `src/visualization/maps/ReconMap/makeColorGradient.m` | wrong-result | A channel that is equal in both colours becomes 0 | `test/verifiedTests/visualization/testReconMap/testMakeColorGradient.m` |

## Details

### `src/analysis/exploration/surfNetSubfunctions/numToFormattedString.m`

#### Width argument ignored for array input

- **Severity**: unusable-option
- **Trigger**: a non-scalar input together with the width argument nChar
- **Observed**: the recursive call passes false as the 4th argument (nChar), so every element is formatted with the minimum width 5
- **Expected**: every element formatted with the requested width
- **Source lines**: 48
- **Documented in**: `test/verifiedTests/analysis/testExploration/testNumToFormattedString.m`

### `src/analysis/igemRNA/GT1/findGenesAboveThresholdGT1.m`

#### Errors when no gene qualifies

- **Severity**: error
- **Trigger**: a threshold that no expression value passes
- **Observed**: the output genes is only assigned inside the loop, so the call errors (MATLAB:unassignedOutputs)
- **Expected**: an empty list
- **Source lines**: 24-33
- **Documented in**: `test/verifiedTests/analysis/testGT1/testFindGenesAboveThresholdGT1.m`

### `src/analysis/igemRNA/GT1/findGenesBelowThresholdGT1.m`

#### Errors when no gene qualifies

- **Severity**: error
- **Trigger**: a threshold that no expression value passes
- **Observed**: the output genes is only assigned inside the loop, so the call errors (MATLAB:unassignedOutputs)
- **Expected**: an empty list
- **Source lines**: 24-33
- **Documented in**: `test/verifiedTests/analysis/testGT1/testFindGenesBelowThresholdGT1.m`

### `src/analysis/persephone/calculateMetrics.m`

#### Bray-Curtis wrong for a single taxon

- **Severity**: wrong-result
- **Trigger**: a table with one row (one taxon) and calculateBrayCurtis true
- **Observed**: sum(comparisonData) sums along the row instead of down the columns, so counts 1, 3 and 5 give 0 and 1/3 for the sample pairs S1-S2 and S1-S3
- **Expected**: Bray-Curtis = 1 - 2*sum(min)/(a+b), that is 1/2 and 2/3 for the same counts
- **Source lines**: 38, 66-67
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testCalculateMetrics.m`

### `src/analysis/rumba/compareConditions.m`

#### Sample-point count taken from the first metabolite of the first list

- **Severity**: limitation
- **Trigger**: metabolites with different numbers of sample points
- **Observed**: MinNumPts is computed once from the first metabolite of the first list and used for all
- **Expected**: the minimum over all compared metabolites
- **Source lines**: 52
- **Documented in**: `test/verifiedTests/analysis/testRumba/testCompareConditions.m`

### `src/analysis/topology/reactingMoieties/createBIGraph.m`

#### No edges left after removing the energy node errors

- **Severity**: error
- **Trigger**: a bond graph whose edges all touch the energy node E
- **Observed**: assigning an empty edge property to the new graph fails inside MATLAB (Weight must be a column vector with as many entries as there are edges)
- **Expected**: an edgeless bond-instance graph
- **Source lines**: 81
- **Documented in**: `test/verifiedTests/analysis/testTopology/testCreateBIGraph.m`

### `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/calculateFoodScore.m`

#### Default translation assigned when nargin < 3

- **Severity**: error
- **Trigger**: fewer than four inputs, for example calculateFoodScore(originalFood, labelMacros, measuredMacros)
- **Observed**: translation = NaN is only assigned when nargin < 3, so with three inputs translation is undefined and the call errors; with NaN the following lines index it and fail too
- **Expected**: a default translation that works with three inputs (the check should be nargin < 4)
- **Source lines**: 45-46
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testCalculateFoodScore.m`

### `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/compareDiets.m`

#### Direction false errors

- **Severity**: error
- **Trigger**: direction argument one2Two = false
- **Observed**: fluxChanges is a cell array and cannot be multiplied by -1: error MATLAB:math:mustBeNumericCharOrLogical
- **Expected**: the signs of the flux changes reversed (diet 1 minus diet 2)
- **Source lines**: 73-74
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testCompareDiets.m`

### `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/searcher.m`

#### Non-iterative search type cannot run

- **Severity**: unusable-option
- **Trigger**: searchType other than iterative
- **Observed**: the input parser requires database to be a cell array, but this branch reads database.description, a property of tables, so every call errors
- **Expected**: a search that works with the database type the branch needs
- **Source lines**: 33, 90-133
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testSearcher.m`

### `src/base/io/utilities/SBML/getDataBases.m`

#### Mixed matching and non-matching resources return nothing

- **Severity**: wrong-result
- **Trigger**: a list that contains both matching identifiers and strings that match neither pattern
- **Observed**: the cellfun over the whole list fails, so databases and ids are empty for all entries
- **Expected**: the matching entries returned
- **Source lines**: 29-44
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testGetDataBases.m`

#### Third output unassigned when nothing matches

- **Severity**: error
- **Trigger**: three outputs requested when no resource matches either pattern
- **Observed**: qualifiers is only assigned inside the block that runs for matches, so the call errors
- **Expected**: an empty qualifiers output
- **Source lines**: 46
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testGetDataBases.m`

### `src/base/io/utilities/parseSBMLAnnotationField.m`

#### ChEBI ID keeps a stray 3A prefix in the urn:miriam notation

- **Severity**: wrong-result
- **Trigger**: annotation text containing urn:miriam:obo.chebi:CHEBI%3A15422
- **Observed**: only the text obo.chebi:CHEBI% is removed, so the result is 3A15422
- **Expected**: 15422
- **Source lines**: 36-37
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testParseSBMLAnnotationField.m`

### `src/base/parseMetNames.m`

#### Mixed or longer compartment notations are not parsed

- **Severity**: limitation
- **Trigger**: a list that mixes name[c] and name(c), names without brackets, or a compartment symbol longer than one character
- **Observed**: the last pattern is used: the whole text is the base name and the compartment is empty
- **Expected**: name and compartment separated
- **Source lines**: 36-38
- **Documented in**: `test/verifiedTests/base/testTools/testParseMetNames.m`

### `src/base/solvers/varKin/BDCAmethods/StopCritBDCA.m`

#### Outputs unassigned for a criterion outside 1 to 5

- **Severity**: error
- **Trigger**: Stopping_Crit not in 1..5
- **Observed**: the switch has no otherwise branch, so StopFlag and Status are not assigned (error MATLAB:unassignedOutputs)
- **Expected**: defined outputs or a clear error message
- **Source lines**: 31-82
- **Documented in**: `test/verifiedTests/base/testSolvers/testStopCritBDCA.m`

#### Stopping criterion 1 uses an undefined variable

- **Severity**: error
- **Trigger**: Stopping_Crit = 1
- **Observed**: the variable nhxk is undefined: error MATLAB:UndefinedFunction
- **Expected**: the residual nfxk compared with epsilon
- **Source lines**: 33-41
- **Documented in**: `test/verifiedTests/base/testSolvers/testStopCritBDCA.m`

### `src/base/solvers/varKin/derFreeMethods/InitialDuplo.m`

#### Option flag_x_error can never be set

- **Severity**: unusable-option
- **Trigger**: options.flag_x_error given
- **Observed**: the code tests the misspelled field name flag_`x_error` (with backticks), so the output flag_x_error is always 0
- **Expected**: the given value returned
- **Source lines**: 121-122
- **Documented in**: `test/verifiedTests/base/testSolvers/testInitialDuplo.m`

### `src/base/solvers/varKin/derFreeMethods/StopCritDuplo.m`

#### Outputs unassigned for a criterion outside 1 to 5

- **Severity**: error
- **Trigger**: Stopping_Crit not in 1..5
- **Observed**: the switch has no otherwise branch, so StopFlag and Status are not assigned (error MATLAB:unassignedOutputs)
- **Expected**: defined outputs or a clear error message
- **Source lines**: 30-81
- **Documented in**: `test/verifiedTests/base/testSolvers/testStopCritDuplo.m`

#### Stopping criterion 1 uses an undefined variable

- **Severity**: error
- **Trigger**: Stopping_Crit = 1
- **Observed**: the variable nhxk is undefined: error MATLAB:UndefinedFunction
- **Expected**: the residual nfxk compared with epsilon
- **Source lines**: 32-40
- **Documented in**: `test/verifiedTests/base/testSolvers/testStopCritDuplo.m`

### `src/base/utilities/getDefaultValue.m`

#### No default for struct and function-handle input

- **Severity**: error
- **Trigger**: struct or function handle input
- **Observed**: there is no final else, so defValue is not assigned (MATLAB:unassignedOutputs)
- **Expected**: a default of the same type or a clear error
- **Source lines**: 13-29
- **Documented in**: `test/verifiedTests/base/testTools/testGetDefaultValue.m`

### `src/base/utilities/isvar.m`

#### Index is 1 for a structure even when the field is missing

- **Severity**: limitation
- **Trigger**: a structure and a name that is not one of its fields
- **Observed**: the third output (ind) is always 1 for structures
- **Expected**: an empty index when the field does not exist
- **Source lines**: 24-27
- **Documented in**: `test/verifiedTests/base/testTools/testIsvar.m`

### `src/dataIntegration/chemoInformatics/editChemicalFormula.m`

#### Element with zero atoms stays in the formula

- **Severity**: cosmetic
- **Trigger**: removing all atoms of an element, for example C2H5OH minus one O
- **Observed**: the result is C2H6O0
- **Expected**: C2H6
- **Source lines**: 71-74
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testEditChemicalFormula.m`

### `src/dataIntegration/chemoInformatics/inchi/getInchiData.m`

#### Negative charge layer gives NaN

- **Severity**: wrong-result
- **Trigger**: an InChI with a q- layer, for example /q-1
- **Observed**: only q+ is removed before the conversion to a number, so netCharge is NaN
- **Expected**: netCharge -1
- **Source lines**: 69
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testGetInchiData.m`

#### Several layers containing the letter p error

- **Severity**: error
- **Trigger**: an InChI with two layers that contain the letter p
- **Observed**: regexprep receives several layers at once and fails (Invalid option for regexprep)
- **Expected**: the proton layers added up
- **Source lines**: 63
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testGetInchiData.m`

### `src/dataIntegration/fluxomics/c13solver/Combination.m`

#### Negative parameters print a message and return empty

- **Severity**: cosmetic
- **Trigger**: n < 0 or k < 0
- **Observed**: the text Negative parameter in constructor is printed to the console and an empty value is returned
- **Expected**: a clear error instead of console text
- **Source lines**: 17-20
- **Documented in**: `test/verifiedTests/dataIntegration/testFitC13Data/testCombination.m`

#### k = 0 errors

- **Severity**: error
- **Trigger**: Combination(n, 0)
- **Observed**: data(0) is an invalid index (MATLAB:badsubscript)
- **Expected**: one empty combination
- **Source lines**: 23
- **Documented in**: `test/verifiedTests/dataIntegration/testFitC13Data/testCombination.m`

### `src/dataIntegration/metaboAnnotator/buildMetStruct/cleanUpMetabolite_structure.m`

#### Loop index printed to the console

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: the statement i without a semicolon prints i = ... for every metabolite
- **Expected**: no console output
- **Source lines**: 38
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testCleanUpMetabolite_structure.m`

### `src/dataIntegration/metaboAnnotator/connect2resources/convertOld2NewHMDB.m`

#### Identifiers of 12 or more characters give an empty result

- **Severity**: limitation
- **Trigger**: an identifier with 12 or more characters, for example HMDB00012345
- **Observed**: the result is an empty text instead of the identifier
- **Expected**: the identifier returned unchanged or an error
- **Source lines**: 19-28
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testConvertOld2NewHMDB.m`

### `src/reconstruction/comparison/modelBorgifier/buildRxnEquationsFromName.m`

#### Backward-only reactions list the substrate on both sides

- **Severity**: wrong-result
- **Trigger**: a reaction with lower bound < 0 and upper bound <= 0
- **Observed**: products is overwritten with educts, for example (2) A <-- (-2) A
- **Expected**: (2) A <-- C
- **Source lines**: 59
- **Documented in**: `test/verifiedTests/reconstruction/testModelBorgifier/testBuildRxnEquationsFromName.m`

### `src/reconstruction/demeter/src/integration/checkInputData.m`

#### Header name listed in removedStrains

- **Severity**: cosmetic
- **Trigger**: the first-column header of the data differs from that of the strain information
- **Observed**: removedStrains also contains the header cell
- **Expected**: only strain names
- **Source lines**: 27-28
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testCheckInputData.m`

#### Unknown strain row not removed when the headers are equal

- **Severity**: wrong-result
- **Trigger**: data and strain information with the same first-column header
- **Observed**: the first removed index is skipped (IA(2:end)), so the row of an unknown strain stays in the checked data
- **Expected**: the row removed
- **Source lines**: 29
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testCheckInputData.m`

### `src/reconstruction/modelGeneration/massBalance/ispolymer.m`

#### Always errors because the element list contains names with digits

- **Severity**: error
- **Trigger**: any formula, for example ispolymer('C6H12O6')
- **Observed**: the list includes FULLR2 and FULLR3; numAtomsOfElementInFormula rejects element names that contain numbers (Element must not contain numbers), so the call errors for every formula (an empty formula errors with an index error)
- **Expected**: true when the formula contains a polymer placeholder, false otherwise
- **Source lines**: 14-20
- **Documented in**: `test/verifiedTests/reconstruction/testMassChargeBalance/testIspolymer.m`

### `src/reconstruction/refinement/GPRLogic/combineChildren.m`

#### Identical generated clauses delete the earlier clause

- **Severity**: wrong-result
- **Trigger**: (a AND b) OR (a OR b), where two generated clauses contain exactly the same genes
- **Observed**: the clause is both existing and superseded, so the earlier clause is removed and the new one is not added, giving an empty node
- **Expected**: the clause (a OR b)
- **Source lines**: 53-63
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testCombineChildren.m`

### `src/reconstruction/refinement/getMetAbbr.m`

#### IDs without brackets are silently dropped

- **Severity**: wrong-result
- **Trigger**: a metabolite list containing an ID without [compartment]
- **Observed**: the output has fewer entries than the input (3 IDs give 2 abbreviations), so positions no longer line up
- **Expected**: an entry or an error for every input
- **Source lines**: 35-37
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testGetMetAbbr.m`

### `src/visualization/maps/ReconMap/makeColorGradient.m`

#### A channel that is equal in both colours becomes 0

- **Severity**: wrong-result
- **Trigger**: start and end colours with the same red, green or blue value
- **Observed**: that channel is 0 in every step, for example #ff0000 to #ff0000 gives #000000
- **Expected**: the channel keeps its value
- **Source lines**: 28-29
- **Documented in**: `test/verifiedTests/visualization/testReconMap/testMakeColorGradient.m`
