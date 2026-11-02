# Known defects in tested functions

> **Generated file: do not edit by hand.** It is built from the "Known defects documented" section of each test header by `python3 .github/scripts/known_defects.py` (Constitution III-Defects).
> It is a snapshot: a function may have been changed or fixed since an entry was written. When you rely on an entry or work on resolving a defect, re-check it against the current source, then update the test header and regenerate this file.

48 known defects in 34 functions (21 wrong-result, 8 error, 3 unusable-option, 4 cosmetic, 12 limitation).

## Summary

| Function | Severity | Problem | Test file |
|----------|----------|---------|-----------|
| `src/analysis/exploration/findMetFromCompartment.m` | limitation | A compartment letter without brackets matches every identifier with that letter | `test/verifiedTests/analysis/testExploration/testFindMetFromCompartment.m` |
| `src/analysis/exploration/findMetFromCompartment.m` | error | A compartment without metabolites stops with an error | `test/verifiedTests/analysis/testExploration/testFindMetFromCompartment.m` |
| `src/analysis/exploration/findRxnFromCompartment.m` | wrong-result | A compartment with a single metabolite returns the first reaction of the model | `test/verifiedTests/analysis/testExploration/testFindRxnFromCompartment.m` |
| `src/analysis/persephone/calculateMetrics.m` | wrong-result | Bray-Curtis wrong for a single taxon | `test/verifiedTests/analysis/testPersephone/testCalculateMetrics.m` |
| `src/analysis/rumba/compareConditions.m` | limitation | Sample-point count taken from the first metabolite of the first list | `test/verifiedTests/analysis/testRumba/testCompareConditions.m` |
| `src/analysis/sampling/ACHR/convRevSamples.m` | wrong-result | Bounds of a reverse-only reaction are not exchanged correctly | `test/verifiedTests/analysis/testSampling/testConvRevSamples.m` |
| `src/analysis/thermo/formulae/checkFormulae.m` | limitation | Elements other than C, H, O, P, S, K, Na and N are ignored | `test/verifiedTests/analysis/testThermo/testCheckFormulae.m` |
| `src/analysis/thermo/inchi/getMolecularWeight.m` | wrong-result | Hydrogens are lost for an InChI whose formula starts with H | `test/verifiedTests/analysis/testThermo/testGetMolecularWeight.m` |
| `src/analysis/topology/FR/bilinearDecomposition.m` | error | A lone reaction with one substrate and three products gives inconsistent sizes | `test/verifiedTests/analysis/testTopology/testBilinearDecomposition.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/isValidVmhID.m` | limitation | Identifiers with surrounding blanks are rejected although they are trimmed for the other checks | `test/verifiedTests/analysis/testWholeBody/testIsValidVmhID.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/searcher.m` | unusable-option | Non-iterative search type cannot run | `test/verifiedTests/analysis/testWholeBody/testSearcher.m` |
| `src/analysis/wholeBody/PSCMToolbox/compareBounds2Models.m` | error | Reactions missing from a model are collected in a character matrix, which fails for names of different lengths | `test/verifiedTests/analysis/testWholeBody/testCompareBounds2Models.m` |
| `src/base/io/utilities/SBML/getDataBases.m` | wrong-result | Mixed matching and non-matching resources return nothing | `test/verifiedTests/base/testIO/testUtilities/testGetDataBases.m` |
| `src/base/io/utilities/SBML/getDataBases.m` | error | Third output unassigned when nothing matches | `test/verifiedTests/base/testIO/testUtilities/testGetDataBases.m` |
| `src/base/io/utilities/createEmptyFields.m` | limitation | A cell field with a computed default fills only its first column | `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m` |
| `src/base/io/utilities/createEmptyFields.m` | error | A field whose default refers to another field the model lacks cannot be created | `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m` |
| `src/base/io/utilities/createEmptyFields.m` | error | The default of comps cannot be evaluated | `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m` |
| `src/base/parseMetNames.m` | limitation | Mixed or longer compartment notations are not parsed | `test/verifiedTests/base/testTools/testParseMetNames.m` |
| `src/base/solvers/entropicFBA/processConcConstraints.m` | cosmetic | Documented defaults for the concentration unit and the maximum concentration differ from the code | `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m` |
| `src/base/solvers/entropicFBA/processConcConstraints.m` | unusable-option | The case dxReplacement always stops with an error | `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m` |
| `src/base/solvers/entropicFBA/processConcConstraints.m` | wrong-result | The default row selection indexes the first row repeatedly | `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m` |
| `src/base/solvers/entropicFBA/processConcConstraints.m` | error | The parameter printLevel is required although it is documented as optional | `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m` |
| `src/base/solvers/mosek/setMosekParam.m` | wrong-result | The strict option never switches MOSEK to a free solve form | `test/verifiedTests/base/testSolvers/testSetMosekParam.m` |
| `src/base/utilities/updateStructData.m` | limitation | A structure update is ignored when the original field is not a structure | `test/verifiedTests/base/testTools/testUpdateStructData.m` |
| `src/dataIntegration/XomicsToModel/analysis/coreMetRxnAnalysis.m` | wrong-result | A given list of deleted metabolites is discarded when the old model is empty and no deleted reactions are given | `test/verifiedTests/dataIntegration/testXomicsToModel/testCoreMetRxnAnalysis.m` |
| `src/dataIntegration/chemoInformatics/editChemicalFormula.m` | cosmetic | Element with zero atoms stays in the formula | `test/verifiedTests/dataIntegration/testChemoInformatics/testEditChemicalFormula.m` |
| `src/dataIntegration/chemoInformatics/inchi/getInchiData.m` | wrong-result | Negative charge layer gives NaN | `test/verifiedTests/dataIntegration/testChemoInformatics/testGetInchiData.m` |
| `src/dataIntegration/metaboAnnotator/connect2resources/convertOld2NewHMDB.m` | limitation | Identifiers of 12 or more characters give an empty result | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testConvertOld2NewHMDB.m` |
| `src/dataIntegration/transcriptomics/preprocessing/selectGeneFromGPR.m` | wrong-result | With minSum the reported gene does not belong to the selected alternative | `test/verifiedTests/dataIntegration/testPreprocessing/testSelectGeneFromGPR.m` |
| `src/reconstruction/comparison/modelBorgifier/charpos.m` | wrong-result | The letters i and j count as digits | `test/verifiedTests/reconstruction/testModelBorgifier/testCharpos.m` |
| `src/reconstruction/comparison/modelBorgifier/countC.m` | wrong-result | Elements whose symbol starts with C are counted as carbon | `test/verifiedTests/reconstruction/testModelBorgifier/testCountC.m` |
| `src/reconstruction/demeter/src/integration/gapfillRefinedGenomeReactions.m` | wrong-result | The first gap-filled row overwrites the last annotation row | `test/verifiedTests/reconstruction/testDemeter/testGapfillRefinedGenomeReactions.m` |
| `src/reconstruction/modelGeneration/checkDuplicateRxn.m` | wrong-result | the 'FR' method removes the last reaction of a group after testing the first two | `test/verifiedTests/reconstruction/testCheckDuplicateRxn/testCheckDuplicateRxn.m` |
| `src/reconstruction/modelGeneration/checkDuplicateRxn.m` | wrong-result | the 'rxnAbbr' method returns the unique reactions as the duplicates | `test/verifiedTests/reconstruction/testCheckDuplicateRxn/testCheckDuplicateRxn.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | limitation | All MATLAB warnings are switched off and never switched back on | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | cosmetic | An empty rev field is left when no reaction is removed | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | limitation | Annotation and constraint fields of the input model are dropped | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | wrong-result | Reactions that become duplicates are not removed | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | cosmetic | The default compartment and every reaction index are printed | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | wrong-result | metNames is a row and holds the metabolite identifiers | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/setConstraintsIrrevModel.m` | wrong-result | Reactions with names of one or two characters get the wrong sign | `test/verifiedTests/reconstruction/testModelGeneration/testSetConstraintsIrrevModel.m` |
| `src/reconstruction/refinement/GPRLogic/combineChildren.m` | wrong-result | Identical generated clauses delete the earlier clause | `test/verifiedTests/reconstruction/testModelManipulation/testCombineChildren.m` |
| `src/reconstruction/refinement/extractSubSysModel.m` | wrong-result | A single subsystem name given as text selects almost every reaction | `test/verifiedTests/reconstruction/testModelManipulation/testExtractSubSysModel.m` |
| `src/reconstruction/refinement/removeFieldEntriesForType.m` | error | removing genes from a model that has grRules but no rules field fails | `test/verifiedTests/reconstruction/testRemoveFieldEntriesForType/testRemoveFieldEntriesForType.m` |
| `src/reconstruction/refinement/updateFieldOrderForType.m` | limitation | An order that repeats indices is accepted | `test/verifiedTests/reconstruction/testModelManipulation/testUpdateFieldOrderForType.m` |
| `src/reconstruction/refinement/updateFieldOrderForType.m` | unusable-option | The type proteins is accepted but always stops with an error | `test/verifiedTests/reconstruction/testModelManipulation/testUpdateFieldOrderForType.m` |
| `src/visualization/maps/ReconMap/makeColorGradient.m` | wrong-result | A channel that is equal in both colours becomes 0 | `test/verifiedTests/visualization/testReconMap/testMakeColorGradient.m` |
| `src/visualization/metabolicCartography/addFluxWidthAndColor.m` | limitation | Map reactions without flux data get no colour entry | `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxWidthAndColor.m` |

## Details

### `src/analysis/exploration/findMetFromCompartment.m`

#### A compartment letter without brackets matches every identifier with that letter

- **Severity**: limitation
- **Trigger**: findMetFromCompartment(model, 'e')
- **Observed**: the text is searched anywhere in the identifiers, so 23 metabolites of ecoli_core_model are returned: the 20 of [e] and 3 of [c] whose identifier contains the letter e (for example pep[c]); findRxnFromCompartment puts a single letter in brackets first
- **Expected**: the 20 metabolites of [e], as for '[e]'
- **Source lines**: 24
- **Documented in**: `test/verifiedTests/analysis/testExploration/testFindMetFromCompartment.m`

#### A compartment without metabolites stops with an error

- **Severity**: error
- **Trigger**: a compartment that no metabolite identifier contains, for example findMetFromCompartment(model, '[x]') on ecoli_core_model
- **Observed**: the output is only assigned inside the loop over the matches, so the call stops with Output argument "compartmentMetabolites" (and possibly others) not assigned a value
- **Expected**: an empty list
- **Source lines**: 29-34
- **Documented in**: `test/verifiedTests/analysis/testExploration/testFindMetFromCompartment.m`

### `src/analysis/exploration/findRxnFromCompartment.m`

#### A compartment with a single metabolite returns the first reaction of the model

- **Severity**: wrong-result
- **Trigger**: a compartment that holds exactly one metabolite, for example ecoli_core_model with o2[e] renamed to o2[p] and findRxnFromCompartment(model, '[p]')
- **Observed**: any() of the single selected row of S is one scalar instead of one value per reaction, so only the first reaction of the model (ACALD) is returned
- **Expected**: the reactions that use the metabolite (EX_o2(e) and O2t)
- **Source lines**: 30
- **Documented in**: `test/verifiedTests/analysis/testExploration/testFindRxnFromCompartment.m`

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

### `src/analysis/sampling/ACHR/convRevSamples.m`

#### Bounds of a reverse-only reaction are not exchanged correctly

- **Severity**: wrong-result
- **Trigger**: a reaction named with the suffix _r, for example with lb = -10 and ub = 0
- **Observed**: the new upper bound is computed from the lower bound that was just overwritten, so it equals the old upper bound; lb = -10, ub = 0 becomes lb = 0, ub = 0
- **Expected**: the bounds are exchanged and negated: lb = -10, ub = 0 becomes lb = 0, ub = 10
- **Source lines**: 31-32
- **Documented in**: `test/verifiedTests/analysis/testSampling/testConvRevSamples.m`

### `src/analysis/thermo/formulae/checkFormulae.m`

#### Elements other than C, H, O, P, S, K, Na and N are ignored

- **Severity**: limitation
- **Trigger**: two formulas that differ only in another element, for example C6H12O6Cl and C6H12O6
- **Observed**: the function returns 1 (equal)
- **Expected**: 0 (different)
- **Source lines**: 31-45
- **Documented in**: `test/verifiedTests/analysis/testThermo/testCheckFormulae.m`

### `src/analysis/thermo/inchi/getMolecularWeight.m`

#### Hydrogens are lost for an InChI whose formula starts with H

- **Severity**: wrong-result
- **Trigger**: an InChI whose formula layer begins with hydrogen, for example water, InChI=1S/H2O/h1H2
- **Observed**: the formula returned by getFormulaAndChargeFromInChI is O and the hydrogen count is returned separately, but only the formula is used, so water gets a molecular weight of 16 and 0 hydrogens
- **Expected**: a molecular weight of 18 and 2 hydrogens for water
- **Source lines**: 41-61
- **Documented in**: `test/verifiedTests/analysis/testThermo/testGetMolecularWeight.m`

### `src/analysis/topology/FR/bilinearDecomposition.m`

#### A lone reaction with one substrate and three products gives inconsistent sizes

- **Severity**: error
- **Trigger**: a stoichiometric matrix whose only reaction with extra reactants has one substrate and three products, for example [-1; 1; 1; 1]
- **Observed**: the number of faux species counted for A (one) differs from the number used in B (two), so A*B*C fails with a dimension error and debugging output is printed
- **Expected**: the three matrices with consistent sizes and S = A*B*C
- **Source lines**: 45-53, 124-148, 288-300
- **Documented in**: `test/verifiedTests/analysis/testTopology/testBilinearDecomposition.m`

### `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/isValidVmhID.m`

#### Identifiers with surrounding blanks are rejected although they are trimmed for the other checks

- **Severity**: limitation
- **Trigger**: an identifier such as  pyr  with leading or trailing blanks
- **Observed**: the blank test is applied to the untrimmed text, so the identifier is invalid, while the empty, placeholder and "not in VMH" tests use the trimmed text
- **Expected**: a blank-padded identifier treated like its trimmed form
- **Source lines**: 28
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testIsValidVmhID.m`

### `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/searcher.m`

#### Non-iterative search type cannot run

- **Severity**: unusable-option
- **Trigger**: searchType other than iterative
- **Observed**: the input parser requires database to be a cell array, but this branch reads database.description, a property of tables, so every call errors
- **Expected**: a search that works with the database type the branch needs
- **Source lines**: 33, 90-133
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testSearcher.m`

### `src/analysis/wholeBody/PSCMToolbox/compareBounds2Models.m`

#### Reactions missing from a model are collected in a character matrix, which fails for names of different lengths

- **Severity**: error
- **Trigger**: two or more reactions missing from the same model whose identifiers have different lengths
- **Observed**: the names are appended as rows of a character array, so unequal lengths stop the function with "Dimensions of arrays being concatenated are not consistent"
- **Expected**: the missing reactions returned in a cell array
- **Source lines**: 48-50
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testCompareBounds2Models.m`

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

### `src/base/io/utilities/createEmptyFields.m`

#### A cell field with a computed default fills only its first column

- **Severity**: limitation
- **Trigger**: fieldDefinitions for a cell field with two dimensions above 1 and a default other than '', for example {'rxnGeneLabels', 'rxns', 'genes', '', '''x''', false, 'cell', false}
- **Observed**: the default is assigned to the first xdim linear entries only, so 95 of the 95 x 137 entries are 'x' and the rest stay empty; a default of '' fills every entry
- **Expected**: every entry set to the default
- **Source lines**: 85-88
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m`

#### A field whose default refers to another field the model lacks cannot be created

- **Severity**: error
- **Trigger**: createEmptyFields(model, 'proteinNames') on a model with genes but without proteins, for example ecoli_core_model
- **Observed**: the default model.proteins{i} is evaluated and the call stops with Unrecognized field name "proteins"
- **Expected**: the field created, as the help text states for every field defined in the toolbox (for example with empty entries, or after creating proteins first)
- **Source lines**: 82, 86
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m`

#### The default of comps cannot be evaluated

- **Severity**: error
- **Trigger**: createEmptyFields(model, 'comps') on a model that has comps
- **Observed**: the default ['C' num2str{i}] of the field definitions brace-indexes a function call and the call stops with a MATLAB error; without comps in the model the dimension is 0 and the default is never evaluated
- **Expected**: identifiers C1, C2, ... as for the other identifier fields
- **Source lines**: 82, 86
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m`

### `src/base/parseMetNames.m`

#### Mixed or longer compartment notations are not parsed

- **Severity**: limitation
- **Trigger**: a list that mixes name[c] and name(c), names without brackets, or a compartment symbol longer than one character
- **Observed**: the last pattern is used: the whole text is the base name and the compartment is empty
- **Expected**: name and compartment separated
- **Source lines**: 36-38
- **Documented in**: `test/verifiedTests/base/testTools/testParseMetNames.m`

### `src/base/solvers/entropicFBA/processConcConstraints.m`

#### Documented defaults for the concentration unit and the maximum concentration differ from the code

- **Severity**: cosmetic
- **Trigger**: param without concUnit and maxConc
- **Observed**: concUnit is set to 10-3, which evaluates to 7, and maxConc is set to infinity, while the header states 1e-3 and 1e4
- **Expected**: the documented defaults
- **Source lines**: 131-137
- **Documented in**: `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m`

#### The case dxReplacement always stops with an error

- **Severity**: unusable-option
- **Trigger**: param.externalNetFluxBounds = dxReplacement, or model.dcl or model.dcu present without an explicit option
- **Observed**: the case begins with error(revise how net initial and final conc bounds are dealt with), so the option can never be used; this is also the default when model.dcl or model.dcu exists
- **Expected**: the external net flux bounds replaced by concentration differences, as documented
- **Source lines**: 245-262
- **Documented in**: `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m`

#### The default row selection indexes the first row repeatedly

- **Severity**: wrong-result
- **Trigger**: a model without the field pp, with external reactions
- **Observed**: the default pp is a numeric vector of ones, and indexing the external stoichiometric matrix with it repeats row 1 for every metabolite instead of selecting all rows
- **Expected**: the default pp should be a logical vector of ones (true for all rows) so that all rows are kept
- **Source lines**: 116-118, 297
- **Documented in**: `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m`

#### The parameter printLevel is required although it is documented as optional

- **Severity**: error
- **Trigger**: a parameter structure without printLevel when the model has external reactions and externalNetFluxBounds is original or none
- **Observed**: the field is read without a default, so the call stops with "Unrecognized field name printLevel"
- **Expected**: printLevel defaulting to 0
- **Source lines**: 161, 224
- **Documented in**: `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m`

### `src/base/solvers/mosek/setMosekParam.m`

#### The strict option never switches MOSEK to a free solve form

- **Severity**: wrong-result
- **Trigger**: param.strict non-empty with a cobra profile
- **Observed**: the interior-point solve form is already set to MSK_SOLVE_PRIMAL earlier in the same profile, so the test for an absent solve form in the strict block is never true and MSK_SOLVE_FREE is never set
- **Expected**: a strict solve uses MSK_SOLVE_FREE, as the header of the function states
- **Source lines**: 541-549
- **Documented in**: `test/verifiedTests/base/testSolvers/testSetMosekParam.m`

### `src/base/utilities/updateStructData.m`

#### A structure update is ignored when the original field is not a structure

- **Severity**: limitation
- **Trigger**: a field that is a structure in the update but not a structure in the original
- **Observed**: the original value is kept and the update is dropped without a message
- **Expected**: the field replaced by the update (or an error)
- **Source lines**: 25-31
- **Documented in**: `test/verifiedTests/base/testTools/testUpdateStructData.m`

### `src/dataIntegration/XomicsToModel/analysis/coreMetRxnAnalysis.m`

#### A given list of deleted metabolites is discarded when the old model is empty and no deleted reactions are given

- **Severity**: wrong-result
- **Trigger**: an empty old model, a non-empty deletedMets and an empty deletedRxns, for example coreMetRxnAnalysis([], model, coreMets, coreRxns, {'c'}, [])
- **Observed**: the branch that fills the missing deletedRxns also sets deletedMets to empty, so the given deleted metabolites are not counted as deleted and core metabolites among them are reported as missing from the old model instead
- **Expected**: the given deletedMets is kept
- **Source lines**: 52
- **Documented in**: `test/verifiedTests/dataIntegration/testXomicsToModel/testCoreMetRxnAnalysis.m`

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

### `src/dataIntegration/metaboAnnotator/connect2resources/convertOld2NewHMDB.m`

#### Identifiers of 12 or more characters give an empty result

- **Severity**: limitation
- **Trigger**: an identifier with 12 or more characters, for example HMDB00012345
- **Observed**: the result is an empty text instead of the identifier
- **Expected**: the identifier returned unchanged or an error
- **Source lines**: 19-28
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testConvertOld2NewHMDB.m`

### `src/dataIntegration/transcriptomics/preprocessing/selectGeneFromGPR.m`

#### With minSum the reported gene does not belong to the selected alternative

- **Severity**: wrong-result
- **Trigger**: minSum set and a rule with an alternative that has more than one gene before the selected alternative, for example (g1 and g2) or g3 with g3 selected
- **Observed**: the list of candidate genes has one entry per gene while the list of values has one entry per alternative, so the position of the minimum points into the wrong list entry (here g2 is reported instead of g3)
- **Expected**: the gene of the selected alternative
- **Source lines**: 44-49
- **Documented in**: `test/verifiedTests/dataIntegration/testPreprocessing/testSelectGeneFromGPR.m`

### `src/reconstruction/comparison/modelBorgifier/charpos.m`

#### The letters i and j count as digits

- **Severity**: wrong-result
- **Trigger**: a text containing the letter i or j (or other characters that str2double reads as numbers)
- **Observed**: each character is tested with str2double, which reads i and j as the imaginary unit, so charpos reports them as numeric
- **Expected**: only the digits 0 to 9 reported as numeric
- **Source lines**: 4-6
- **Documented in**: `test/verifiedTests/reconstruction/testModelBorgifier/testCharpos.m`

### `src/reconstruction/comparison/modelBorgifier/countC.m`

#### Elements whose symbol starts with C are counted as carbon

- **Severity**: wrong-result
- **Trigger**: a formula with chlorine, calcium, cobalt, copper, ... and no carbon, for example Cl2 or CaCl2
- **Observed**: the pattern C followed by digits matches the first letter of Cl, Ca, Co, Cu, ..., so Cl2 gives 1 instead of 0
- **Expected**: 0 carbon atoms
- **Source lines**: 39-47
- **Documented in**: `test/verifiedTests/reconstruction/testModelBorgifier/testCountC.m`

### `src/reconstruction/demeter/src/integration/gapfillRefinedGenomeReactions.m`

#### The first gap-filled row overwrites the last annotation row

- **Severity**: wrong-result
- **Trigger**: a genome annotation to which at least one gap-filling rule applies
- **Observed**: the row counter starts at the number of rows instead of one more, so the first added row replaces the last row of the input
- **Expected**: all input rows kept and the new rows appended after them
- **Source lines**: 127
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testGapfillRefinedGenomeReactions.m`

### `src/reconstruction/modelGeneration/checkDuplicateRxn.m`

#### the 'FR' method removes the last reaction of a group after testing the first two

- **Severity**: wrong-result
- **Trigger**: three or more reactions with the same stoichiometry up to scale and direction (for example A->B, B->A and 2A->2B)
- **Observed**: the direction test compares the first two members of the group only, and the last member (which may differ by a scale factor) is reported as the duplicate
- **Expected**: every reported duplicate is a duplicate of the kept reaction
- **Source lines**: 156-162
- **Documented in**: `test/verifiedTests/reconstruction/testCheckDuplicateRxn/testCheckDuplicateRxn.m`

#### the 'rxnAbbr' method returns the unique reactions as the duplicates

- **Severity**: wrong-result
- **Trigger**: checkDuplicateRxn(model, 'rxnAbbr') on any model
- **Observed**: removedRxnInd holds the first occurrence of every reaction abbreviation (all reactions when none repeats), so the function reports no duplicates only for an empty model, and removal by name deletes every reaction that has a repeated abbreviation
- **Expected**: removedRxnInd holds the repeated occurrences only
- **Source lines**: 64-72
- **Documented in**: `test/verifiedTests/reconstruction/testCheckDuplicateRxn/testCheckDuplicateRxn.m`

### `src/reconstruction/modelGeneration/removeCompartments.m`

#### All MATLAB warnings are switched off and never switched back on

- **Severity**: limitation
- **Trigger**: any call, for example removeCompartments(model, {'e'})
- **Observed**: warning('OFF') at the start disables every warning for the rest of the MATLAB session; warnings of addReaction (repeated metabolites) and of all later code are hidden
- **Expected**: warnings stay visible, or the previous warning state is restored before return
- **Source lines**: 36
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m`

#### An empty rev field is left when no reaction is removed

- **Severity**: cosmetic
- **Trigger**: a call in which no reaction column becomes empty, for example removeCompartments(model, {'e'}, '[x]')
- **Observed**: the result has a field rev of size 0 x 0 next to 95 reactions; the field is only removed when a reaction is removed
- **Expected**: no rev field, or one entry per reaction
- **Source lines**: 53, 74, 107
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m`

#### Annotation and constraint fields of the input model are dropped

- **Severity**: limitation
- **Trigger**: any call
- **Observed**: the result keeps only genes, rxns, mets, metNames, S, subSystems, lb, ub, c, rules, grRules and b; rxnGeneMat, rxnNames, metFormulas, csense, osenseStr, description and modelID of the input model are lost
- **Expected**: the reaction, metabolite and model fields of the input model carried over to the merged entries
- **Source lines**: 46-55
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m`

#### Reactions that become duplicates are not removed

- **Severity**: wrong-result
- **Trigger**: removeCompartments(model, {'e'}) on ecoli_core_model
- **Observed**: ATPM and GLNabc have the same column of S after the merge (gln[e] and gln[c] cancel in GLNabc) and both are kept; only reactions whose column is empty are removed
- **Expected**: duplicate and empty entries removed, as the help text states
- **Source lines**: 79-89
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m`

#### The default compartment and every reaction index are printed

- **Severity**: cosmetic
- **Trigger**: any call; the default compartment is printed when newComp is not given
- **Observed**: the assignment of newComp and the loop variable i are not terminated by a semicolon, so newComp = '[c]' and one line per reaction (95 for ecoli_core_model) are printed
- **Expected**: no output, or output gated behind a printLevel
- **Source lines**: 38, 57
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m`

#### metNames is a row and holds the metabolite identifiers

- **Severity**: wrong-result
- **Trigger**: any call
- **Observed**: metNames is 1 x m while mets is m x 1, and it holds the new metabolite identifiers (for example acald[c]) instead of the metabolite names of the input model
- **Expected**: an m x 1 metNames with the names of the input model
- **Source lines**: 50, 70
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m`

### `src/reconstruction/modelGeneration/setConstraintsIrrevModel.m`

#### Reactions with names of one or two characters get the wrong sign

- **Severity**: wrong-result
- **Trigger**: an irreversible reaction whose identifier has at most two characters (for example r1) with a constraint
- **Observed**: the test that decides whether the reaction was reversed in the irreversible model is only applied for names longer than two characters, so the value of the constraint is negated although the reaction was not reversed
- **Expected**: the value is kept for a reaction that is not reversed, whatever the length of its name
- **Source lines**: 22
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testSetConstraintsIrrevModel.m`

### `src/reconstruction/refinement/GPRLogic/combineChildren.m`

#### Identical generated clauses delete the earlier clause

- **Severity**: wrong-result
- **Trigger**: (a AND b) OR (a OR b), where two generated clauses contain exactly the same genes
- **Observed**: the clause is both existing and superseded, so the earlier clause is removed and the new one is not added, giving an empty node
- **Expected**: the clause (a OR b)
- **Source lines**: 53-63
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testCombineChildren.m`

### `src/reconstruction/refinement/extractSubSysModel.m`

#### A single subsystem name given as text selects almost every reaction

- **Severity**: wrong-result
- **Trigger**: subSysNames given as a character vector, for example extractSubSysModel(model, 'Exchange')
- **Observed**: ismember compares the characters of the name with the characters of each subsystem, so every reaction whose subsystem shares one letter with the name is kept (94 of the 95 reactions of ecoli_core_model instead of the 20 exchange reactions)
- **Expected**: the reactions annotated with that subsystem only, as for {'Exchange'}
- **Source lines**: 20
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testExtractSubSysModel.m`

### `src/reconstruction/refinement/removeFieldEntriesForType.m`

#### removing genes from a model that has grRules but no rules field fails

- **Severity**: error
- **Trigger**: removeFieldEntriesForType(model, genesToRemove, 'genes', numel(model.genes)) on a model without model.rules and with model.grRules
- **Observed**: the function builds model.rules, removes the field again at its end of the genes branch, and then reads model.rules to rewrite grRules: error 'Unrecognized field name "rules"'
- **Expected**: the gene reaction rules are rewritten and the model has no rules field
- **Source lines**: 86-87, 173, 190-196
- **Documented in**: `test/verifiedTests/reconstruction/testRemoveFieldEntriesForType/testRemoveFieldEntriesForType.m`

### `src/reconstruction/refinement/updateFieldOrderForType.m`

#### An order that repeats indices is accepted

- **Severity**: limitation
- **Trigger**: a newOrder of the right size whose entries are valid indices but not a permutation, for example ones(numel(model.rxns), 1) for rxns
- **Observed**: the input check only tests that every entry is a valid index, so the call returns a model whose reactions are all copies of the first reaction
- **Expected**: an error, because newOrder is documented as a new order of the field
- **Source lines**: 31
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testUpdateFieldOrderForType.m`

#### The type proteins is accepted but always stops with an error

- **Severity**: unusable-option
- **Trigger**: updateFieldOrderForType(model, 'proteins', newOrder) on a model with a proteins field
- **Observed**: the input check accepts proteins, but getModelFieldsForType does not know the type and stops with "The value of 'type' is invalid"
- **Expected**: the protein fields reordered, or proteins rejected by the input check of this function (the help text lists only rxns, mets, comps and genes)
- **Source lines**: 30, 35
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testUpdateFieldOrderForType.m`

### `src/visualization/maps/ReconMap/makeColorGradient.m`

#### A channel that is equal in both colours becomes 0

- **Severity**: wrong-result
- **Trigger**: start and end colours with the same red, green or blue value
- **Observed**: that channel is 0 in every step, for example #ff0000 to #ff0000 gives #000000
- **Expected**: the channel keeps its value
- **Source lines**: 28-29
- **Documented in**: `test/verifiedTests/visualization/testReconMap/testMakeColorGradient.m`

### `src/visualization/metabolicCartography/addFluxWidthAndColor.m`

#### Map reactions without flux data get no colour entry

- **Severity**: limitation
- **Trigger**: a map with reactions that are not in the list of reaction IDs given with the fluxes
- **Observed**: rxnColor is filled only for reactions with flux data (zero or non-zero), so it can be shorter than rxnName and the other map reactions have no colour entry
- **Expected**: a default colour for every map reaction
- **Source lines**: 102-105, 133
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxWidthAndColor.m`
