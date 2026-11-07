# Known defects in tested functions

> **Generated file: do not edit by hand.** It is built from the "Known defects documented" section of each test header by `python3 .github/scripts/known_defects.py` (Constitution III-Defects).
> It is a snapshot: a function may have been changed or fixed since an entry was written. When you rely on an entry or work on resolving a defect, re-check it against the current source, then update the test header and regenerate this file.

110 known defects in 65 functions (51 wrong-result, 21 error, 6 unusable-option, 13 cosmetic, 19 limitation).

## Summary

| Function | Severity | Problem | Test file |
|----------|----------|---------|-----------|
| `src/analysis/exploration/findMetFromCompartment.m` | limitation | A compartment letter without brackets matches every identifier with that letter | `test/verifiedTests/analysis/testExploration/testFindMetFromCompartment.m` |
| `src/analysis/exploration/findMetFromCompartment.m` | error | A compartment without metabolites stops with an error | `test/verifiedTests/analysis/testExploration/testFindMetFromCompartment.m` |
| `src/analysis/exploration/findRxnFromCompartment.m` | wrong-result | A compartment with a single metabolite returns the first reaction of the model | `test/verifiedTests/analysis/testExploration/testFindRxnFromCompartment.m` |
| `src/analysis/exploration/surfNetSubfunctions/generateGrRules.m` | wrong-result | Nested hyperlinks when genes are named from the rules and a gene repeats | `test/verifiedTests/analysis/testExploration/testGenerateGrRules.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/addMicrobeCommunityBiomass.m` | wrong-result | Abundance weights are rounded to six significant digits | `test/verifiedTests/analysis/testMultiSpeciesModelling/testAddMicrobeCommunityBiomass.m` |
| `src/analysis/persephone/calculateMetrics.m` | wrong-result | Bray-Curtis wrong for a single taxon | `test/verifiedTests/analysis/testPersephone/testCalculateMetrics.m` |
| `src/analysis/persephone/validatePersephoneInputs.m` | error | A column reaction list with two or more duplicates fails while the message is built | `test/verifiedTests/analysis/testPersephone/testValidatePersephoneInputs.m` |
| `src/analysis/rumba/compareConditions.m` | limitation | Sample-point count taken from the first metabolite of the first list | `test/verifiedTests/analysis/testRumba/testCompareConditions.m` |
| `src/analysis/sampling/ACHR/convRevSamples.m` | wrong-result | Bounds of a reverse-only reaction are not exchanged correctly | `test/verifiedTests/analysis/testSampling/testConvRevSamples.m` |
| `src/analysis/sampling/BarrierRound/PolytopeSimplifier/TwoSidedBarrier.m` | error | step_size fails for more than one point | `test/verifiedTests/analysis/testSampling/testTwoSidedBarrier.m` |
| `src/analysis/sampling/BarrierRound/utils/TableDisplay.m` | error | A format without a width gives a NaN length and header fails | `test/verifiedTests/analysis/testSampling/testTableDisplay.m` |
| `src/analysis/sampling/BarrierRound/utils/TableDisplay.m` | wrong-result | The blank that separates the columns is dropped | `test/verifiedTests/analysis/testSampling/testTableDisplay.m` |
| `src/analysis/subspaces/lsqr/lsqrtest.m` | cosmetic | The function handle is printed by a statement without a semicolon | `test/verifiedTests/analysis/testSubspaces/testLsqrtest.m` |
| `src/analysis/thermo/experimentalData/alberty2006/adjustBaselinesInAlberty2006.m` | wrong-result | The reduced glutathione energies are halved together with the baseline | `test/verifiedTests/analysis/testThermo/testAdjustBaselinesInAlberty2006.m` |
| `src/analysis/thermo/formulae/checkFormulae.m` | limitation | Elements other than C, H, O, P, S, K, Na and N are ignored | `test/verifiedTests/analysis/testThermo/testCheckFormulae.m` |
| `src/analysis/thermo/groupContribution/createComputedSpeciesData.m` | error | A row structure array of species fails when two metabolites are included | `test/verifiedTests/analysis/testThermo/testCreateComputedSpeciesData.m` |
| `src/analysis/thermo/groupContribution/createComputedSpeciesData.m` | wrong-result | The first group-contribution entry is used for every metabolite | `test/verifiedTests/analysis/testThermo/testCreateComputedSpeciesData.m` |
| `src/analysis/thermo/inchi/getMolecularWeight.m` | wrong-result | Hydrogens are lost for an InChI whose formula starts with H | `test/verifiedTests/analysis/testThermo/testGetMolecularWeight.m` |
| `src/analysis/topology/FR/bilinearDecomposition.m` | error | A lone reaction with one substrate and three products gives inconsistent sizes | `test/verifiedTests/analysis/testTopology/testBilinearDecomposition.m` |
| `src/analysis/topology/FR/connectedFR.m` | wrong-result | The column sets are computed over the rows of [F; R] | `test/verifiedTests/analysis/testTopology/testConnectedFR.m` |
| `src/analysis/topology/FR/largestConnectedFR.m` | wrong-result | The column output is read from the row nodes and has m entries | `test/verifiedTests/analysis/testTopology/testLargestConnectedFR.m` |
| `src/analysis/topology/findCyclicRxns.m` | wrong-result | The first output is not a per-reaction boolean | `test/verifiedTests/analysis/testTopology/testFindCyclicRxns.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/isValidVmhID.m` | limitation | Identifiers with surrounding blanks are rejected although they are trimmed for the other checks | `test/verifiedTests/analysis/testWholeBody/testIsValidVmhID.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/searcher.m` | unusable-option | Non-iterative search type cannot run | `test/verifiedTests/analysis/testWholeBody/testSearcher.m` |
| `src/analysis/wholeBody/PSCMToolbox/compareBounds2Models.m` | error | Reactions missing from a model are collected in a character matrix, which fails for names of different lengths | `test/verifiedTests/analysis/testWholeBody/testCompareBounds2Models.m` |
| `src/analysis/wholeBody/PSCMToolbox/createModelNewCompartment.m` | limitation | All MATLAB warnings are switched off and never switched back on | `test/verifiedTests/analysis/testWholeBody/testCreateModelNewCompartment.m` |
| `src/analysis/wholeBody/PSCMToolbox/createModelNewCompartment.m` | cosmetic | The names of the new transport reactions lose their blanks | `test/verifiedTests/analysis/testWholeBody/testCreateModelNewCompartment.m` |
| `src/analysis/wholeBody/PSCMToolbox/createModelNewCompartment.m` | limitation | rxnGeneMat is dropped when the original exchange reactions are removed | `test/verifiedTests/analysis/testWholeBody/testCreateModelNewCompartment.m` |
| `src/analysis/wholeBody/PSCMToolbox/io/addReactionsHH.m` | unusable-option | The coupling factor given by the caller is ignored | `test/verifiedTests/analysis/testWholeBody/testAddReactionsHH.m` |
| `src/analysis/wholeBody/PSCMToolbox/io/addReactionsHH.m` | wrong-result | rxnGeneMat is not updated for the gene rules of the added reactions | `test/verifiedTests/analysis/testWholeBody/testAddReactionsHH.m` |
| `src/analysis/wholeBody/PSCMToolbox/setConstraints/setFeedingFastingConstraints.m` | cosmetic | The list of storable amino acids is printed on every call | `test/verifiedTests/analysis/testWholeBody/testSetFeedingFastingConstraints.m` |
| `src/base/io/KEGG/mapKEGGID2Model.m` | error | A dictionary abbreviation with several entries stops with an error | `test/verifiedTests/base/testIO/testKEGG/testMapKEGGID2Model.m` |
| `src/base/io/KEGG/mapKEGGID2Model.m` | error | A metabolite without compartment that is in the dictionary stops with an error | `test/verifiedTests/base/testIO/testKEGG/testMapKEGGID2Model.m` |
| `src/base/io/KEGG/mapMetName2KEGGID.m` | error | A metabolite without compartment that is in the dictionary stops with an error | `test/verifiedTests/base/testIO/testKEGG/testMapMetName2KEGGID.m` |
| `src/base/io/KEGG/mapMetName2KEGGID.m` | cosmetic | The message for a metabolite with several matches is never printed | `test/verifiedTests/base/testIO/testKEGG/testMapMetName2KEGGID.m` |
| `src/base/io/definitions/descFileRead.m` | wrong-result | An empty line ends the reading | `test/verifiedTests/base/testIO/testDescFileRead.m` |
| `src/base/io/definitions/descFileRead.m` | limitation | Short entries are padded with null characters, not blanks | `test/verifiedTests/base/testIO/testDescFileRead.m` |
| `src/base/io/utilities/SBML/getDataBases.m` | wrong-result | Mixed matching and non-matching resources return nothing | `test/verifiedTests/base/testIO/testUtilities/testGetDataBases.m` |
| `src/base/io/utilities/SBML/getDataBases.m` | error | Third output unassigned when nothing matches | `test/verifiedTests/base/testIO/testUtilities/testGetDataBases.m` |
| `src/base/io/utilities/SBML/makeSBMLAnnotationString.m` | wrong-result | A field of another is-qualifier is also annotated under the qualifier is | `test/verifiedTests/base/testIO/testUtilities/testMakeSBMLAnnotationString.m` |
| `src/base/io/utilities/createEmptyFields.m` | limitation | A cell field with a computed default fills only its first column | `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m` |
| `src/base/io/utilities/createEmptyFields.m` | error | A field whose default refers to another field the model lacks cannot be created | `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m` |
| `src/base/io/utilities/createEmptyFields.m` | error | The default of comps cannot be evaluated | `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m` |
| `src/base/io/utilities/initFBAFields.m` | limitation | The documented osense and csense fields are not created | `test/verifiedTests/base/testIO/testUtilities/testInitFBAFields.m` |
| `src/base/parseMetNames.m` | limitation | Mixed or longer compartment notations are not parsed | `test/verifiedTests/base/testTools/testParseMetNames.m` |
| `src/base/solvers/entropicFBA/processConcConstraints.m` | cosmetic | Documented defaults for the concentration unit and the maximum concentration differ from the code | `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m` |
| `src/base/solvers/entropicFBA/processConcConstraints.m` | unusable-option | The case dxReplacement always stops with an error | `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m` |
| `src/base/solvers/entropicFBA/processConcConstraints.m` | wrong-result | The default row selection indexes the first row repeatedly | `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m` |
| `src/base/solvers/entropicFBA/processConcConstraints.m` | error | The parameter printLevel is required although it is documented as optional | `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m` |
| `src/base/solvers/mosek/setMosekParam.m` | wrong-result | The strict option never switches MOSEK to a free solve form | `test/verifiedTests/base/testSolvers/testSetMosekParam.m` |
| `src/base/solvers/varKin/optimizeVKmodel0.m` | error | F equal to R with a moiety basis returns without the output | `test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m` |
| `src/base/solvers/varKin/optimizeVKmodel0.m` | cosmetic | The display format is switched to long E and never restored | `test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m` |
| `src/base/solvers/varKin/optimizeVKmodel0.m` | unusable-option | The option flag_psi_error cannot be used | `test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m` |
| `src/base/solvers/varKin/optimizeVKmodel0.m` | wrong-result | The steady state is dropped when the QR factor is a vector with a negative entry | `test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m` |
| `src/base/utilities/removeIndicesInDimenion.m` | cosmetic | The help text says the given indices are removed, but they are the ones kept | `test/verifiedTests/base/testTools/testRemoveIndicesInDimenion.m` |
| `src/base/utilities/updateStructData.m` | limitation | A structure update is ignored when the original field is not a structure | `test/verifiedTests/base/testTools/testUpdateStructData.m` |
| `src/dataIntegration/XomicsToModel/analysis/coreMetRxnAnalysis.m` | wrong-result | A given list of deleted metabolites is discarded when the old model is empty and no deleted reactions are given | `test/verifiedTests/dataIntegration/testXomicsToModel/testCoreMetRxnAnalysis.m` |
| `src/dataIntegration/chemoInformatics/editChemicalFormula.m` | cosmetic | Element with zero atoms stays in the formula | `test/verifiedTests/dataIntegration/testChemoInformatics/testEditChemicalFormula.m` |
| `src/dataIntegration/chemoInformatics/inchi/getInchiData.m` | wrong-result | Negative charge layer gives NaN | `test/verifiedTests/dataIntegration/testChemoInformatics/testGetInchiData.m` |
| `src/dataIntegration/metaboAnnotator/connect2resources/convertOld2NewHMDB.m` | limitation | Identifiers of 12 or more characters give an empty result | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testConvertOld2NewHMDB.m` |
| `src/dataIntegration/transcriptomics/preprocessing/selectGeneFromGPR.m` | wrong-result | With minSum the reported gene does not belong to the selected alternative | `test/verifiedTests/dataIntegration/testPreprocessing/testSelectGeneFromGPR.m` |
| `src/design/TrimGdel/modelSetting.m` | wrong-result | A model without rev gets rev as a row vector | `test/verifiedTests/design/testTrimGdel/testModelSetting.m` |
| `src/reconstruction/comparison/modelBorgifier/charpos.m` | wrong-result | The letters i and j count as digits | `test/verifiedTests/reconstruction/testModelBorgifier/testCharpos.m` |
| `src/reconstruction/comparison/modelBorgifier/countC.m` | wrong-result | Elements whose symbol starts with C are counted as carbon | `test/verifiedTests/reconstruction/testModelBorgifier/testCountC.m` |
| `src/reconstruction/comparison/modelBorgifier/makeNamesUnique.m` | error | An empty list stops with an error | `test/verifiedTests/reconstruction/testModelBorgifier/testMakeNamesUnique.m` |
| `src/reconstruction/comparison/modelBorgifier/makeNamesUnique.m` | wrong-result | Positions of duplicates are printed as character codes | `test/verifiedTests/reconstruction/testModelBorgifier/testMakeNamesUnique.m` |
| `src/reconstruction/demeter/src/debugging/conditionSpecificGapFilling.m` | wrong-result | A rule with a present- and an absent-condition applies when only the absent reaction is missing | `test/verifiedTests/reconstruction/testDemeter/testConditionSpecificGapFilling.m` |
| `src/reconstruction/demeter/src/debugging/conditionSpecificGapFilling.m` | wrong-result | The lower bound is not changed for a rule whose present-condition uses OR | `test/verifiedTests/reconstruction/testDemeter/testConditionSpecificGapFilling.m` |
| `src/reconstruction/demeter/src/integration/gapfillRefinedGenomeReactions.m` | wrong-result | The first gap-filled row overwrites the last annotation row | `test/verifiedTests/reconstruction/testDemeter/testGapfillRefinedGenomeReactions.m` |
| `src/reconstruction/demeter/src/refinement/rebuildBiomassReaction.m` | limitation | Biomass coefficients are rounded to about five significant digits | `test/verifiedTests/reconstruction/testDemeter/testRebuildBiomassReaction.m` |
| `src/reconstruction/demeter/src/refinement/rebuildBiomassReaction.m` | error | Rebuilding the biomass of Archaea stops with an error | `test/verifiedTests/reconstruction/testDemeter/testRebuildBiomassReaction.m` |
| `src/reconstruction/demeter/src/refinement/rebuildBiomassReaction.m` | wrong-result | The model has no objective after rebuilding the biomass of Tenericutes | `test/verifiedTests/reconstruction/testDemeter/testRebuildBiomassReaction.m` |
| `src/reconstruction/modelGeneration/checkDuplicateRxn.m` | wrong-result | the 'FR' method removes the last reaction of a group after testing the first two | `test/verifiedTests/reconstruction/testCheckDuplicateRxn/testCheckDuplicateRxn.m` |
| `src/reconstruction/modelGeneration/checkDuplicateRxn.m` | wrong-result | the 'rxnAbbr' method returns the unique reactions as the duplicates | `test/verifiedTests/reconstruction/testCheckDuplicateRxn/testCheckDuplicateRxn.m` |
| `src/reconstruction/modelGeneration/modelProperties/checkModelProperties.m` | wrong-result | minSij is zero for every model with a zero in S | `test/verifiedTests/reconstruction/testCheckModelProperties/testCheckModelProperties.m` |
| `src/reconstruction/modelGeneration/modelProperties/checkModelProperties.m` | wrong-result | the sanity checks after the rank computation never fire | `test/verifiedTests/reconstruction/testCheckModelProperties/testCheckModelProperties.m` |
| `src/reconstruction/modelGeneration/modelProperties/checkModelProperties.m` | cosmetic | the thermodynamic consistency counts vary between runs | `test/verifiedTests/reconstruction/testCheckModelProperties/testCheckModelProperties.m` |
| `src/reconstruction/modelGeneration/modelVerification/checkDatabaseIDs.m` | wrong-result | Standard InChI strings with an undefined stereo centre are reported invalid | `test/verifiedTests/reconstruction/testModelGeneration/testCheckDatabaseIDs.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | limitation | All MATLAB warnings are switched off and never switched back on | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | cosmetic | An empty rev field is left when no reaction is removed | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | limitation | Annotation and constraint fields of the input model are dropped | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | wrong-result | Reactions that become duplicates are not removed | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | cosmetic | The default compartment and every reaction index are printed | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | wrong-result | metNames is a row and holds the metabolite identifiers | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/setConstraintsIrrevModel.m` | wrong-result | Reactions with names of one or two characters get the wrong sign | `test/verifiedTests/reconstruction/testModelGeneration/testSetConstraintsIrrevModel.m` |
| `src/reconstruction/refinement/GPRLogic/combineChildren.m` | wrong-result | Identical generated clauses delete the earlier clause | `test/verifiedTests/reconstruction/testModelManipulation/testCombineChildren.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | error | A formula whose first metabolite has no coefficient stops with an error | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | wrong-result | A new metabolite used twice in one call is added twice or loses a coefficient | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | wrong-result | A proteins field of another size than the gene list discards the result | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | wrong-result | Appended reactions get no identifier, so rxns is shorter than the other fields | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | error | Appending a reaction whose first metabolite is already in the model stops with an error | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | wrong-result | The default gene list removes all genes of the model | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | wrong-result | The subsystem of every filled reaction is stored as a cell inside a cell | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/extractSubSysModel.m` | wrong-result | A single subsystem name given as text selects almost every reaction | `test/verifiedTests/reconstruction/testModelManipulation/testExtractSubSysModel.m` |
| `src/reconstruction/refinement/removeFieldEntriesForType.m` | error | removing genes from a model that has grRules but no rules field fails | `test/verifiedTests/reconstruction/testRemoveFieldEntriesForType/testRemoveFieldEntriesForType.m` |
| `src/reconstruction/refinement/updateFieldOrderForType.m` | limitation | An order that repeats indices is accepted | `test/verifiedTests/reconstruction/testModelManipulation/testUpdateFieldOrderForType.m` |
| `src/reconstruction/refinement/updateFieldOrderForType.m` | unusable-option | The type proteins is accepted but always stops with an error | `test/verifiedTests/reconstruction/testModelManipulation/testUpdateFieldOrderForType.m` |
| `src/visualization/cellDesigner/readCD.m` | limitation | Attributes missing from the first reaction are dropped for all reactions | `test/verifiedTests/visualization/testCellDesigner/testReadCD.m` |
| `src/visualization/cellDesigner/readCD.m` | cosmetic | Debug output of the attribute list and of the whole partial result | `test/verifiedTests/visualization/testCellDesigner/testReadCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | error | A text without "<species " lines stops with an error | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | cosmetic | Debug output of internal variables | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | wrong-result | Every occurrence of the old name in the line is replaced | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | unusable-option | The documented default value of note stops with an error | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | wrong-result | The second round pairs name lines with species rows by position and stops early | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | wrong-result | changedStrLines lists only the lines changed in the second round | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | wrong-result | number lists only the lines found in the second round | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/maps/ReconMap/makeColorGradient.m` | wrong-result | A channel that is equal in both colours becomes 0 | `test/verifiedTests/visualization/testReconMap/testMakeColorGradient.m` |
| `src/visualization/metabolicCartography/addFluxWidthAndColor.m` | limitation | Map reactions without flux data get no colour entry | `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxWidthAndColor.m` |
| `src/visualization/metabolicCartography/removeMapMol.m` | wrong-result | Aliases of a removed reaction are removed even when kept reactions use them | `test/verifiedTests/visualization/testMetabolicCartography/testRemoveMapMol.m` |
| `src/visualization/metabolicCartography/removeMapMol.m` | limitation | Reactions keep a removed alias of a species that has other aliases | `test/verifiedTests/visualization/testMetabolicCartography/testRemoveMapMol.m` |

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

### `src/analysis/exploration/surfNetSubfunctions/generateGrRules.m`

#### Nested hyperlinks when genes are named from the rules and a gene repeats

- **Severity**: wrong-result
- **Trigger**: generateGrRules(rmfield(model, 'genes'), 'fprintf(''%s'')') with ecoli_core_model, whose rules for 3 reactions use a gene twice
- **Observed**: the hyperlink of a gene x(i) contains the text x(i), and every occurrence is replaced again for each repetition of the gene in the rule, so grRulesLinked holds hyperlinks nested inside hyperlinks
- **Expected**: each gene of the rule hyperlinked exactly once
- **Source lines**: 64, 73-74
- **Documented in**: `test/verifiedTests/analysis/testExploration/testGenerateGrRules.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/addMicrobeCommunityBiomass.m`

#### Abundance weights are rounded to six significant digits

- **Severity**: wrong-result
- **Trigger**: weights with more than six significant digits, for example three microbes without abundances (weights 1/3) or abundances [0.123456789; 0.2; 0.676543211]
- **Observed**: the reactions are added through their printed formulas (printRxnFormula, then addReaction), so the coefficients become -0.333333 (sum 0.999999) and -0.123457, -0.676543 instead of the given weights
- **Expected**: the coefficients of communityBiomass equal the given abundances, or 1/n, exactly
- **Source lines**: 47-50
- **Documented in**: `test/verifiedTests/analysis/testMultiSpeciesModelling/testAddMicrobeCommunityBiomass.m`

### `src/analysis/persephone/calculateMetrics.m`

#### Bray-Curtis wrong for a single taxon

- **Severity**: wrong-result
- **Trigger**: a table with one row (one taxon) and calculateBrayCurtis true
- **Observed**: sum(comparisonData) sums along the row instead of down the columns, so counts 1, 3 and 5 give 0 and 1/3 for the sample pairs S1-S2 and S1-S3
- **Expected**: Bray-Curtis = 1 - 2*sum(min)/(a+b), that is 1/2 and 2/3 for the same counts
- **Source lines**: 38, 66-67
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testCalculateMetrics.m`

### `src/analysis/persephone/validatePersephoneInputs.m`

#### A column reaction list with two or more duplicates fails while the message is built

- **Severity**: error
- **Trigger**: paths.fba.flagFBA true and paths.fba.rxnList a column cell array in which two or more entries are repeats, for example {'r1'; 'r2'; 'r1'; 'r2'}
- **Observed**: the error MATLAB:catenate:dimensionMismatch (the transposed list is concatenated with a column of commas)
- **Expected**: the error 'Reactions r1,r2 are duplicated in rxnList, please remove', as for a row list
- **Source lines**: 117
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testValidatePersephoneInputs.m`

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

### `src/analysis/sampling/BarrierRound/PolytopeSimplifier/TwoSidedBarrier.m`

#### step_size fails for more than one point

- **Severity**: error
- **Trigger**: step_size(x, v) with x and v holding two or more points (rows when vdim is 2, columns when vdim is 1) and a nonzero direction entry outside the first point
- **Observed**: error 'The logical indices contain a true value outside of the array bounds.' (the bound vector is indexed with the mask of the whole point matrix)
- **Expected**: one step size per point; for vdim 2 the largest step is already sized per point
- **Source lines**: 89, 94
- **Documented in**: `test/verifiedTests/analysis/testSampling/testTwoSidedBarrier.m`

### `src/analysis/sampling/BarrierRound/utils/TableDisplay.m`

#### A format without a width gives a NaN length and header fails

- **Severity**: error
- **Trigger**: a column whose format has no digits, for example 's' or 'g', then header()
- **Observed**: the column length is NaN, and header fails in repmat with 'Replication factors must be a row vector of integers or integer scalars.'
- **Expected**: the length Inf, so that the label is printed with %s
- **Source lines**: 55-57, 93
- **Documented in**: `test/verifiedTests/analysis/testSampling/testTableDisplay.m`

#### The blank that separates the columns is dropped

- **Severity**: wrong-result
- **Trigger**: header() or print(data) of any table
- **Observed**: strcat removes the trailing blank of every piece, so the columns are joined without a separator: the label line is one character per column boundary shorter than its dashed rule (23 versus 25 characters for the widths 5, 8 and 10), and a value that fills its width runs into the previous column
- **Expected**: one blank after every column, as counted by the dashed rule and assumed by the cut of text values to length - 1 characters
- **Source lines**: 89, 115
- **Documented in**: `test/verifiedTests/analysis/testSampling/testTableDisplay.m`

### `src/analysis/subspaces/lsqr/lsqrtest.m`

#### The function handle is printed by a statement without a semicolon

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: 'aprodfunc = function_handle with value: @(mode,m,n,x)lsqraprod(...)' is printed before the lsqr log
- **Expected**: no output for the assignment (debug leftover)
- **Source lines**: 33
- **Documented in**: `test/verifiedTests/analysis/testSubspaces/testLsqrtest.m`

### `src/analysis/thermo/experimentalData/alberty2006/adjustBaselinesInAlberty2006.m`

#### The reduced glutathione energies are halved together with the baseline

- **Severity**: wrong-result
- **Trigger**: an Alberty2006 entry glutathionered (with glutathioneox and the computed entry gthox)
- **Observed**: every species energy of glutathionered becomes (dfG0 + gc)/2, where gc is the group-contribution energy of the oxidized basic species, and its hydrogen numbers are shifted by the full hydrogen adjustment of the oxidized dimer; the tabulated energy of the reduced form relative to the oxidized form is halved
- **Expected**: dfG0 + gc/2 (and half the hydrogen adjustment): one reduced glutathione carries half the baseline of the dimer (GSSG + 2 e- = 2 GSH), while its tabulated energy keeps its value
- **Source lines**: 173, 175
- **Documented in**: `test/verifiedTests/analysis/testThermo/testAdjustBaselinesInAlberty2006.m`

### `src/analysis/thermo/formulae/checkFormulae.m`

#### Elements other than C, H, O, P, S, K, Na and N are ignored

- **Severity**: limitation
- **Trigger**: two formulas that differ only in another element, for example C6H12O6Cl and C6H12O6
- **Observed**: the function returns 1 (equal)
- **Expected**: 0 (different)
- **Source lines**: 31-45
- **Documented in**: `test/verifiedTests/analysis/testThermo/testCheckFormulae.m`

### `src/analysis/thermo/groupContribution/createComputedSpeciesData.m`

#### A row structure array of species fails when two metabolites are included

- **Severity**: error
- **Trigger**: metSpeciespKa as a 1 x n structure array (as assignpKasToSpecies returns it) with two or more metabolites that have a group-contribution entry
- **Observed**: error 'Index in position 1 exceeds array bounds. Index must not exceed 1.'
- **Expected**: one computedSpeciesData entry per included metabolite
- **Source lines**: 173-176
- **Documented in**: `test/verifiedTests/analysis/testThermo/testCreateComputedSpeciesData.m`

#### The first group-contribution entry is used for every metabolite

- **Severity**: wrong-result
- **Trigger**: metGroupCont with two or more entries and a metabolite whose entry is not the first one
- **Observed**: find(metGcIdx, 1) turns the index of the matching entry into 1, so the charge, formula and energy of metGroupCont(1) are used (for example -41.84 kJ/mol and 4 hydrogens of CH4 instead of -83.68 kJ/mol and 6 hydrogens of C2H6)
- **Expected**: the data of the matching entry
- **Source lines**: 47, 51
- **Documented in**: `test/verifiedTests/analysis/testThermo/testCreateComputedSpeciesData.m`

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

### `src/analysis/topology/FR/connectedFR.m`

#### The column sets are computed over the rows of [F; R]

- **Severity**: wrong-result
- **Trigger**: any call (second output connectedColsFRVBool)
- **Observed**: the first n nodes of the bipartite graph of [F; R] are its first n rows, not its columns, so the second output groups rows of [F; R]; for F = [1 0 0 0; 0 1 0 0; 0 0 1 0] and R = [0 1 0 0; 0 0 0 0; 0 0 0 1] it puts columns 2 and 4 together although no row of [F; R] uses both
- **Expected**: the sets of the column nodes 2m+1 to 2m+n (here four single columns)
- **Source lines**: 52
- **Documented in**: `test/verifiedTests/analysis/testTopology/testConnectedFR.m`

### `src/analysis/topology/FR/largestConnectedFR.m`

#### The column output is read from the row nodes and has m entries

- **Severity**: wrong-result
- **Trigger**: any call (second output connectedColsFRVBool)
- **Observed**: connectedColsFRVBool = pB(1:m) holds the first m rows of [F; R] (the rows of F) in the largest component of the bipartite graph of [F; R]: an m x 1 vector over rows
- **Expected**: an n x 1 vector over the columns, pB(2m+1:2m+n)
- **Source lines**: 71
- **Documented in**: `test/verifiedTests/analysis/testTopology/testLargestConnectedFR.m`

### `src/analysis/topology/findCyclicRxns.m`

#### The first output is not a per-reaction boolean

- **Severity**: wrong-result
- **Trigger**: any call, for example findCyclicRxns(model, 0) with ecoli_core_model
- **Observed**: cyclicRxnBool = Z' * ones(n, 1) sums the entries of each null-space basis vector, giving a (n - rank(S)) x 1 vector of real numbers (28 x 1 for ecoli_core_model), not one value per reaction
- **Expected**: an n x 1 logical vector, true for the reactions in the support of the null space (part of a stoichiometrically balanced cycle), as the help text states
- **Source lines**: 24
- **Documented in**: `test/verifiedTests/analysis/testTopology/testFindCyclicRxns.m`

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

### `src/analysis/wholeBody/PSCMToolbox/createModelNewCompartment.m`

#### All MATLAB warnings are switched off and never switched back on

- **Severity**: limitation
- **Trigger**: any call, for example createModelNewCompartment(model, 'e', 'lu', 'lumen')
- **Observed**: warning off at the start disables every warning for the rest of the MATLAB session
- **Expected**: warnings stay visible, or the previous warning state is restored before return
- **Source lines**: 29
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testCreateModelNewCompartment.m`

#### The names of the new transport reactions lose their blanks

- **Severity**: cosmetic
- **Trigger**: any call that adds a reaction, for example createModelNewCompartment(model, 'e', 'lu', 'lumen') on ecoli_core_model
- **Observed**: strcat removes the trailing blanks of ' (from ' and ' to ', so the name is 'Acetate exchange (from[e] tolumen)'; with UB = 0 it is 'Acetate exchange (fromlumento[e]', also without the closing parenthesis
- **Expected**: 'Acetate exchange (from [e] to lumen)' and 'Acetate exchange (from lumen to [e])'
- **Source lines**: 71, 82
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testCreateModelNewCompartment.m`

#### rxnGeneMat is dropped when the original exchange reactions are removed

- **Severity**: limitation
- **Trigger**: RemoveExch = 1, for example createModelNewCompartment(model, 'e', 'lu', 'lumen', -1000, 1000, 1)
- **Observed**: the result has no rxnGeneMat field although the input model has one
- **Expected**: rxnGeneMat kept, with the rows of the removed reactions removed
- **Source lines**: 97-99
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testCreateModelNewCompartment.m`

### `src/analysis/wholeBody/PSCMToolbox/io/addReactionsHH.m`

#### The coupling factor given by the caller is ignored

- **Severity**: unusable-option
- **Trigger**: a couplingFactor other than 20000, for example addReactionsHH(model, {'Liver_NEWRXN'}, {'new'}, {'glc-D[c] -> g6p[c]'}, {''}, {'Glycolysis'}, 500) on a model with Liver_biomass_maintenance, or an empty couplingFactor []
- **Observed**: a non-empty value is replaced by 20000 (the coupling coefficient is -20000); an empty value is passed on as empty and coupleRxnList2Rxn then uses its own default 1000 (the coefficient is -1000)
- **Expected**: the given coupling factor is used, and 20000 when it is empty or not given
- **Source lines**: 36-38
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testAddReactionsHH.m`

#### rxnGeneMat is not updated for the gene rules of the added reactions

- **Severity**: wrong-result
- **Trigger**: a non-empty gene rule on a model with rxnGeneMat, for example the rule 'b0008 or b9999' on ecoli_core_model
- **Observed**: changeGeneAssociation is called with addRxnGeneMat = 0, so the row of the new reaction stays empty and the new gene b9999 gets no column: rxnGeneMat is 96 x 137 while genes has 138 entries
- **Expected**: rxnGeneMat with one column per gene and the associations of the new rule
- **Source lines**: 60
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testAddReactionsHH.m`

### `src/analysis/wholeBody/PSCMToolbox/setConstraints/setFeedingFastingConstraints.m`

#### The list of storable amino acids is printed on every call

- **Severity**: cosmetic
- **Trigger**: any call, for example setFeedingFastingConstraints(model, 'feeding')
- **Observed**: the script AAStorage, run at line 52, ends its storageAA assignment (AAStorage.m line 23) without a semicolon, so the 20 x 1 cell array storageAA is displayed
- **Expected**: no output
- **Source lines**: 52
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testSetFeedingFastingConstraints.m`

### `src/base/io/KEGG/mapKEGGID2Model.m`

#### A dictionary abbreviation with several entries stops with an error

- **Severity**: error
- **Trigger**: a dictionary in which an abbreviation appears twice, for example the dictionary of this test with its first row repeated, on Recon2.v04
- **Observed**: length(KEGGID{Match}) gets one argument per match and fails with 'Too many input arguments.'
- **Expected**: an empty metKEGGID entry and the warning 'multiple matchings for ...'
- **Source lines**: 50-52
- **Documented in**: `test/verifiedTests/base/testIO/testKEGG/testMapKEGGID2Model.m`

#### A metabolite without compartment that is in the dictionary stops with an error

- **Severity**: error
- **Trigger**: a model whose metabolite identifiers carry no compartment, for example mapKEGGID2Model(model, {'g6p', 'C00092'}) on AntCore
- **Observed**: the compartment variable KEGGComp is only set for [c], [p] and [e] metabolites, so the call fails with 'Unrecognized function or variable KEGGComp'; after an earlier [c], [p] or [e] metabolite the compartment of that metabolite would be appended instead
- **Expected**: the KEGG identifier without a compartment, as the comment of the else branch states
- **Source lines**: 40-41, 48
- **Documented in**: `test/verifiedTests/base/testIO/testKEGG/testMapKEGGID2Model.m`

### `src/base/io/KEGG/mapMetName2KEGGID.m`

#### A metabolite without compartment that is in the dictionary stops with an error

- **Severity**: error
- **Trigger**: a KEGG model whose metabolite identifiers carry no compartment, for example mapMetName2KEGGID(struct('mets', {{'C00092'}}), {'g6p', 'C00092'})
- **Observed**: the compartment variable KEGGComp is only set for [c], [p] and [e] metabolites, so the call fails with 'Unrecognized function or variable KEGGComp'; after an earlier [c], [p] or [e] metabolite the compartment of that metabolite would be appended instead
- **Expected**: the abbreviation without a compartment, as the comment of the else branch states
- **Source lines**: 52-53, 64
- **Documented in**: `test/verifiedTests/base/testIO/testKEGG/testMapMetName2KEGGID.m`

#### The message for a metabolite with several matches is never printed

- **Severity**: cosmetic
- **Trigger**: a KEGG identifier that belongs to several abbreviations of the dictionary, for example C00376 (retinal, retinal_cis_13 and retinal_cis_9) in the dictionary of this test
- **Observed**: the branch tests length(Match) < 0, which is never true, so the metabolite silently gets an empty entry through the last branch
- **Expected**: an empty entry and the message 'multiple matches' with the identifier
- **Source lines**: 66-71
- **Documented in**: `test/verifiedTests/base/testIO/testKEGG/testMapMetName2KEGGID.m`

### `src/base/io/definitions/descFileRead.m`

#### An empty line ends the reading

- **Severity**: wrong-result
- **Trigger**: a file with an empty line before its last data line
- **Observed**: the loop condition cline ~= -1 is empty for an empty line, so the reading stops there and the following lines are dropped without a message
- **Expected**: every data line read (the empty line skipped or kept as an empty row)
- **Source lines**: 34
- **Documented in**: `test/verifiedTests/base/testIO/testDescFileRead.m`

#### Short entries are padded with null characters, not blanks

- **Severity**: limitation
- **Trigger**: a column whose entries have different lengths (any ordinary file)
- **Observed**: the rows of the character arrays are filled up with char(0); cellstr and strtrim remove them, but the rows differ from the tdfread output the header promises
- **Expected**: rows padded with blanks, as tdfread returns them
- **Source lines**: 40
- **Documented in**: `test/verifiedTests/base/testIO/testDescFileRead.m`

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

### `src/base/io/utilities/SBML/makeSBMLAnnotationString.m`

#### A field of another is-qualifier is also annotated under the qualifier is

- **Severity**: wrong-result
- **Trigger**: a field named for a qualifier that starts with is, for example metisRelatedTometacyc__46__compoundID holding 10fthf[c] for metabolite 1, with makeSBMLAnnotationString(model, 'M_x', 'met', 1)
- **Observed**: the field is selected by prefix, so besides the correct resource http://identifiers.org/metacyc.compound/10fthf[c] in the bag isRelatedTo it also gives http://identifiers.org/RelatedTometacyc.compound/10fthf[c] in the bag is
- **Expected**: the field only in the bag of its own qualifier isRelatedTo
- **Source lines**: 62, 74
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testMakeSBMLAnnotationString.m`

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

### `src/base/io/utilities/initFBAFields.m`

#### The documented osense and csense fields are not created

- **Severity**: limitation
- **Trigger**: initFBAFields(model) on a model without osense or csense, for example a model with only S
- **Observed**: only S, mets, rxns, lb, ub, c, genes and rules are created; csense and osense are not added because the field definitions do not mark them for flux balance analysis
- **Expected**: osense (-1) and csense (one E per metabolite) added, as the help text states
- **Source lines**: 41-42
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testInitFBAFields.m`

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

### `src/base/solvers/varKin/optimizeVKmodel0.m`

#### F equal to R with a moiety basis returns without the output

- **Severity**: error
- **Trigger**: a model with the field L whose F - R has no nonzero entry
- **Observed**: the function returns after setting Xsub and idx, so the call stops with "Output argument "output" (and possibly others) not assigned a value"
- **Expected**: an output (for example x0 with its merit value) or an explicit error message
- **Source lines**: 225-229
- **Documented in**: `test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m`

#### The display format is switched to long E and never restored

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: format longE at the start, a debugging leftover, changes how every number is displayed in the MATLAB session after the call
- **Expected**: the display format of the session left unchanged
- **Source lines**: 153
- **Documented in**: `test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m`

#### The option flag_psi_error cannot be used

- **Severity**: unusable-option
- **Trigger**: parms.flag_psi_error = 1 (with psi_opt given) for any solver
- **Observed**: the option is passed on, but none of the solvers (LLM, GLM_YF, GLM_FY, LevMar, LMLS, LMTR, BDF, CSDF, DBDF) reads options.psi_opt, so the first iteration stops with "Unrecognized function or variable 'psi_opt'"
- **Expected**: output.psi_error, the relative error of the merit value in each iteration
- **Source lines**: 293-298, 442-447, 588-590
- **Documented in**: `test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m`

#### The steady state is dropped when the QR factor is a vector with a negative entry

- **Severity**: wrong-result
- **Trigger**: a model with the field L whose F - R has one reaction (or one metabolite) and a negative first pivot entry, for example ATPM of ecoli_core_model alone with its metabolites in model order (adp[c] first)
- **Observed**: the rank estimate uses S(1) without abs, so -1 >= tol * -1 is false, no row of F - R is kept and only the moiety conservation is solved: LMTR reports "a solution is found." with psi_best 4.5e-11 while the forward and reverse rates differ by 0.16
- **Expected**: abs(S(1)), as for the matrix case, so that the independent row is kept
- **Source lines**: 234
- **Documented in**: `test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m`

### `src/base/utilities/removeIndicesInDimenion.m`

#### The help text says the given indices are removed, but they are the ones kept

- **Severity**: cosmetic
- **Trigger**: any call, e.g. removeIndicesInDimenion(magic(4), 1, [1 3])
- **Observed**: rows 1 and 3 are returned (the given indices are kept); the only caller, removeFieldEntriesForType, relies on this and passes the complement of the entries to remove
- **Expected**: a help text that describes the indices as the entries to keep (the code is consistent with its caller)
- **Source lines**: 2-16
- **Documented in**: `test/verifiedTests/base/testTools/testRemoveIndicesInDimenion.m`

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

### `src/design/TrimGdel/modelSetting.m`

#### A model without rev gets rev as a row vector

- **Severity**: wrong-result
- **Trigger**: modelSetting(model, targetMet) on a model without the field rev and a target metabolite without EX_ or DM_ reaction, for example iAF1260 with btn_c
- **Observed**: model2.rev(n) = 0 creates rev as a 1 x n row of zeros, while every other reaction field has one row per reaction
- **Expected**: rev, if created at all, as an n x 1 column (or the deprecated field not created)
- **Source lines**: 56
- **Documented in**: `test/verifiedTests/design/testTrimGdel/testModelSetting.m`

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

### `src/reconstruction/comparison/modelBorgifier/makeNamesUnique.m`

#### An empty list stops with an error

- **Severity**: error
- **Trigger**: makeNamesUnique({})
- **Observed**: error "Unrecognized function or variable 'count'" from countUnique, called at line 50, which assigns count only inside a loop over the unique names
- **Expected**: the empty list returned unchanged (it has no duplicates)
- **Source lines**: 50
- **Documented in**: `test/verifiedTests/reconstruction/testModelBorgifier/testMakeNamesUnique.m`

#### Positions of duplicates are printed as character codes

- **Severity**: wrong-result
- **Trigger**: a list with duplicates and no nameInfo, answering the prompts (interactive)
- **Observed**: fprintf('%d\n', num2str(position)) prints the character codes of the digits, e.g. position 12 is printed as 49 and 50, so the user is told the wrong entries to rename
- **Expected**: the position of each duplicate printed as a number
- **Source lines**: 97
- **Documented in**: `test/verifiedTests/reconstruction/testModelBorgifier/testMakeNamesUnique.m`

### `src/reconstruction/demeter/src/debugging/conditionSpecificGapFilling.m`

#### A rule with a present- and an absent-condition applies when only the absent reaction is missing

- **Severity**: wrong-result
- **Trigger**: a rule with both conditions whose absent reaction is not in the model, while its present-condition is not met; for example the distributed Acidaminococcus_fermentans_DSM_20731, which lacks GTHS, AKGS and BTNCL (rules of lines 296, 341, 345 and 346)
- **Observed**: the absent-condition is evaluated a second time on its own and sets the rule to apply whenever the absent reaction is missing, so for example EX_gthrd(e) and GTHRDt2 are added although GTHP and TSULST are not in the model
- **Expected**: the rule applies only when the present-condition is met and the absent reaction is missing
- **Source lines**: 383-396
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testConditionSpecificGapFilling.m`

#### The lower bound is not changed for a rule whose present-condition uses OR

- **Severity**: wrong-result
- **Trigger**: a model with EX_dpcoa(e) or EX_coa(e), or with EX_stys(e), EX_raffin(e), EX_melib(e) or EX_lcts(e) (for example Abiotrophia_defectiva_ATCC_49176)
- **Observed**: changeRxnBounds receives the whole condition text, for example 'EX_dpcoa(e) OR EX_coa(e)', as one reaction identifier, warns that the reaction is not in the model and changes no bound
- **Expected**: the lower bound of each listed reaction that is in the model set to 0
- **Source lines**: 36, 51, 400-402
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testConditionSpecificGapFilling.m`

### `src/reconstruction/demeter/src/integration/gapfillRefinedGenomeReactions.m`

#### The first gap-filled row overwrites the last annotation row

- **Severity**: wrong-result
- **Trigger**: a genome annotation to which at least one gap-filling rule applies
- **Observed**: the row counter starts at the number of rows instead of one more, so the first added row replaces the last row of the input
- **Expected**: all input rows kept and the new rows appended after them
- **Source lines**: 127
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testGapfillRefinedGenomeReactions.m`

### `src/reconstruction/demeter/src/refinement/rebuildBiomassReaction.m`

#### Biomass coefficients are rounded to about five significant digits

- **Severity**: limitation
- **Trigger**: a biomass coefficient with more significant digits than num2str keeps, for example 0.123456 (written as 0.12346)
- **Observed**: the rebuilt reaction is written as a formula with num2str, which keeps five significant digits for values below 10, so the coefficients of the components that are kept change
- **Expected**: the coefficients of the kept components unchanged
- **Source lines**: 81, 83, 90, 92, 166, 168, 175, 177, 265, 267, 274, 276, 327, 329, 336, 338
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testRebuildBiomassReaction.m`

#### Rebuilding the biomass of Archaea stops with an error

- **Severity**: error
- **Trigger**: an organism of the phylum Euryarchaeota, Crenarchaeota or Thaumarchaeota
- **Observed**: the loop over the archaeal lipids uses size(archaealComp), a vector, as colon operand: MATLAB R2025a stops with "Colon operands must be real scalars." (older releases use the first element, 1, so only dpgpi[c] of the nine lipids is added)
- **Expected**: all nine archaeal lipids added to the biomass (a loop over numel(archaealComp))
- **Source lines**: 140
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testRebuildBiomassReaction.m`

#### The model has no objective after rebuilding the biomass of Tenericutes

- **Severity**: wrong-result
- **Trigger**: an organism of the phylum Tenericutes in the taxonomy table
- **Observed**: the biomass reaction is removed and appended again with addReaction, whose objective coefficient is 0, and changeObjective is not called (as it is in the other branches), so every entry of model.c is 0
- **Expected**: the rebuilt biomass reaction is the objective, as for all other organisms
- **Source lines**: 97
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testRebuildBiomassReaction.m`

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

### `src/reconstruction/modelGeneration/modelProperties/checkModelProperties.m`

#### minSij is zero for every model with a zero in S

- **Severity**: wrong-result
- **Trigger**: any model with a sparse S (min(min(abs(S))) includes the structural zeros)
- **Observed**: model.minSij = 0, although the documentation says minimum NONZERO magnitude
- **Expected**: the smallest nonzero magnitude
- **Source lines**: 791
- **Documented in**: `test/verifiedTests/reconstruction/testCheckModelProperties/testCheckModelProperties.m`

#### the sanity checks after the rank computation never fire

- **Severity**: wrong-result
- **Trigger**: always
- **Observed**: (silent) error('') with an empty message is a no-op in MATLAB, so the checks at lines 706-711 test nothing
- **Expected**: an error when a row or column used for the rank analysis is not classified
- **Source lines**: 706-711
- **Documented in**: `test/verifiedTests/reconstruction/testCheckModelProperties/testCheckModelProperties.m`

#### the thermodynamic consistency counts vary between runs

- **Severity**: cosmetic
- **Trigger**: findThermoConsistentFluxSubset uses randomised passes
- **Observed**: the numbers of thermodynamically consistent reactions on a stored model may differ by a few reactions; this test therefore pins only quantities that do not depend on those counts (ranks of the whole matrix, the booleans of the small model)
- **Expected**: a deterministic result
- **Source lines**: 431
- **Documented in**: `test/verifiedTests/reconstruction/testCheckModelProperties/testCheckModelProperties.m`

### `src/reconstruction/modelGeneration/modelVerification/checkDatabaseIDs.m`

#### Standard InChI strings with an undefined stereo centre are reported invalid

- **Severity**: wrong-result
- **Trigger**: checkDatabaseIDs(model, struct()) on Abiotrophia_defectiva_ATCC_49176, whose metabolites 100, 241, 509 and 510 have complete InChI strings with ? in the /t layer
- **Observed**: the metInChIString pattern of the field definitions (src/base/io/definitions/COBRA_structure_fields.tab, line 24) does not allow ?, so the four strings are listed in invalidIDs.metInChIString
- **Expected**: valid InChI strings accepted; the InChI pattern of generateMetaboScore allows ?
- **Source lines**: 26
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testCheckDatabaseIDs.m`

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

### `src/reconstruction/refinement/addReactionGEM.m`

#### A formula whose first metabolite has no coefficient stops with an error

- **Severity**: error
- **Trigger**: a formula such as 'atp[c] --> 1 adp[c]'
- **Observed**: the coefficient is read from the token before the metabolite, which does not exist for the first token: "Array indices must be positive integers or logical values."; a later metabolite without coefficient gets the coefficient 1
- **Expected**: coefficient 1, as for the other metabolites without coefficient
- **Source lines**: 205
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m`

#### A new metabolite used twice in one call is added twice or loses a coefficient

- **Severity**: wrong-result
- **Trigger**: a metabolite that is not in the model and appears twice in the formulas of one call
- **Observed**: with more than two reactions and no hash table input, new metabolites are not put into the internal hash table, so the second use adds a second row with the same identifier; without a hash table, the existing coefficient of a metabolite that is new is taken as 0, so the second use in one formula overwrites the first
- **Expected**: one row per metabolite and the coefficients summed, as for metabolites already in the model
- **Source lines**: 117-126, 199-201, 210-218
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m`

#### A proteins field of another size than the gene list discards the result

- **Severity**: wrong-result
- **Trigger**: a model with a proteins field whose size differs from the genes input
- **Observed**: rmfield is applied to the input model instead of the result, so the filled reactions are lost and the input model (without proteins or proteinNames) is returned
- **Expected**: rmfield applied to the result
- **Source lines**: 256-258
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m`

#### Appended reactions get no identifier, so rxns is shorter than the other fields

- **Severity**: wrong-result
- **Trigger**: nRxn after the last reaction, including the default length(model.lb) + 1, for example addReactionGEM(model, {'NEW'}, {'new'}, {'1 newmet[c] + 1 atp[c] --> 1 adp[c]'}, 1, 0, 1000) on ecoli_core_model
- **Observed**: the rxns input is never stored (the assignment is commented out) and the reaction fields are extended with the original size taken after the call, so lb, ub, c, rxnNames, rules, grRules, subSystems and S have 96 entries while rxns keeps 95 and rxnGeneMat keeps 95 rows
- **Expected**: rxns extended with the given identifiers and every reaction field extended
- **Source lines**: 105, 136, 273
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m`

#### Appending a reaction whose first metabolite is already in the model stops with an error

- **Severity**: error
- **Trigger**: nRxn after the last reaction and a formula whose first metabolite exists, for example '1 atp[c] --> 1 adp[c]'
- **Observed**: the existing coefficient is read from a column of S that does not exist yet: "Index exceeds array bounds."
- **Expected**: the new column starts empty
- **Source lines**: 211-212
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m`

#### The default gene list removes all genes of the model

- **Severity**: wrong-result
- **Trigger**: a model with genes and no genes input (or a genes input other than model.genes)
- **Observed**: model.genes is replaced by the genes input (default cell(0,1)), while rules still refer to x(i) of the old genes and rxnGeneMat keeps its columns; gene fields of the old size (genes*) are removed
- **Expected**: the genes of the model kept when no genes are given, and the rules and rxnGeneMat consistent with the new gene list
- **Source lines**: 100-101, 245-253, 262-271
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m`

#### The subsystem of every filled reaction is stored as a cell inside a cell

- **Severity**: wrong-result
- **Trigger**: any call, with or without the subSystems input
- **Observed**: subSystems(i,1) (a 1 x 1 cell holding the cell {'name'}) is assigned with braces, so model.subSystems{nRxn} becomes {{'name'}} instead of {'name'} or 'name'
- **Expected**: the entry holds the subsystem name (a character array or a cell of character arrays), like every other entry of the field
- **Source lines**: 64-73, 139
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m`

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

### `src/visualization/cellDesigner/readCD.m`

#### Attributes missing from the first reaction are dropped for all reactions

- **Severity**: limitation
- **Trigger**: a parsed structure whose first reaction has no field that a later reaction has (e.g. reactant only in the second reaction)
- **Observed**: the attribute list is taken from the first reaction only, so that attribute is absent from the result
- **Expected**: every attribute of any reaction collected (the comment at line 39 says that some entries may lack a field)
- **Source lines**: 33
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testReadCD.m`

#### Debug output of the attribute list and of the whole partial result

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: lines 33 and 41 lack a terminating semicolon, so the attribute list and the whole partially built structure are printed after every single entry copied
- **Expected**: no output
- **Source lines**: 33, 41
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testReadCD.m`

### `src/visualization/cellDesigner/updateCD.m`

#### A text without "<species " lines stops with an error

- **Severity**: error
- **Trigger**: a text with "<celldesigner:name>" lines but no "<species " line
- **Observed**: error "Unrecognized function or variable 'number'" at line 82
- **Expected**: the text returned unchanged
- **Source lines**: 77, 82
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m`

#### Debug output of internal variables

- **Severity**: cosmetic
- **Trigger**: any call that finds a species line
- **Observed**: lines without a terminating semicolon and disp calls print the search pattern, keyword, mark, line counts, sizes, loop index, column number, matched positions and every changed line, and a warning "starting the second round of the program" is issued
- **Expected**: no debug output
- **Source lines**: 58, 61, 63, 65, 82, 95, 98-101, 106, 115, 121, 132, 160, 164
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m`

#### Every occurrence of the old name in the line is replaced

- **Severity**: wrong-result
- **Trigger**: a name that also occurs elsewhere in its line, e.g. name="a" in '<species metaid="s1" id="s1" name="a" compartment="c">'
- **Observed**: strrep replaces every "a" of the line: metAid, nAme, compArtment
- **Expected**: only the name value replaced
- **Source lines**: 117, 121
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m`

#### The documented default value of note stops with an error

- **Severity**: unusable-option
- **Trigger**: updateCD(text, parsed, '0') (any note other than 'true')
- **Observed**: error "Unrecognized function or variable 'ConductCol'" at line 130 once a name is replaced (and col is undefined at line 148 otherwise)
- **Expected**: no record of the replaced names, as without note
- **Source lines**: 38-45, 130, 148
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m`

#### The second round pairs name lines with species rows by position and stops early

- **Severity**: wrong-result
- **Trigger**: more "<celldesigner:name>" lines than "<species " lines, or name lines in another order (e.g. glycolysisAndTCA.xml has 107 name lines and 67 species lines)
- **Observed**: only as many name lines as species lines are processed, and the d-th name line receives the d-th species name whichever species it belongs to (a species line "a" followed by name lines "b" and "a" renames "b" and leaves "a")
- **Expected**: each name line renamed with the name of its own species
- **Source lines**: 81-85, 90-92
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m`

#### changedStrLines lists only the lines changed in the second round

- **Severity**: wrong-result
- **Trigger**: a text whose "<species " lines are renamed, e.g. the text of the first section below
- **Observed**: changedStrLines is reset before the second round, so it is empty although two lines were changed
- **Expected**: every changed line, as the help text states
- **Source lines**: 87-88, 128
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m`

#### number lists only the lines found in the second round

- **Severity**: wrong-result
- **Trigger**: a text with both "<species " and "<celldesigner:name>" lines, e.g. the text of the fourth section below
- **Observed**: number = [3; 6], the "<celldesigner:name>" lines overwrite the "<species " lines found first
- **Expected**: [2; 3; 5; 6], every line where a replacement was found
- **Source lines**: 56, 76-77
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m`

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

### `src/visualization/metabolicCartography/removeMapMol.m`

#### Aliases of a removed reaction are removed even when kept reactions use them

- **Severity**: wrong-result
- **Trigger**: removeMapMol(xmlStruct, map, {'sa5'}) on the map of glycolysisAndTCA.xml (sa5 is the only alias of glc_D[r]); every alias of that map whose removal removes a reaction behaves alike
- **Observed**: reaction GLCter is removed together with all its aliases, including sa4, the only alias of species s4427 (glc_D [c]), which kept reactions still reference; s4427 is left without any alias
- **Expected**: only the aliases involved exclusively in removed reactions are removed, as the comment at lines 98-99 states ('inclusive' is used instead of 'exclusive')
- **Source lines**: 96, 100
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testRemoveMapMol.m`

#### Reactions keep a removed alias of a species that has other aliases

- **Severity**: limitation
- **Trigger**: removeMapMol(xmlStruct, map, {'sa2'}) on the map of glycolysisAndTCA.xml (sa2 is one of the 12 aliases of h[c])
- **Observed**: the alias is removed but the reaction that uses it is kept and still lists sa2 among its reactant or product aliases
- **Expected**: the reaction removed, or its reference to the alias removed ("also removing the corresponding reaction if necessary")
- **Source lines**: 80, 87
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testRemoveMapMol.m`
