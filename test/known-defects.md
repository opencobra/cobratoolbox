# Known defects in tested functions

> **Generated file: do not edit by hand.** It is built from the "Known defects documented" section of each test header by `python3 .github/scripts/known_defects.py` (Constitution III-Defects).
> It is a snapshot: a function may have been changed or fixed since an entry was written. When you rely on an entry or work on resolving a defect, re-check it against the current source, then update the test header and regenerate this file.

253 known defects in 135 functions (93 wrong-result, 85 error, 22 unusable-option, 28 cosmetic, 25 limitation).

## Summary

| Function | Severity | Problem | Test file |
|----------|----------|---------|-----------|
| `src/analysis/FBA/optimizeCbModel.m` | error | A text in param.minNorm reaches solveCobraLP and stops with an error | `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m` |
| `src/analysis/FBA/optimizeCbModel.m` | unusable-option | QRQP cannot run | `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m` |
| `src/analysis/FBA/optimizeCbModel.m` | limitation | The linear objective is dropped for param.solveWBMmethod | `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m` |
| `src/analysis/FBA/optimizeCbModel.m` | wrong-result | The residual and the slack of QRLP are read from the wrong positions | `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m` |
| `src/analysis/FBA/optimizeCbModel.m` | error | minNorm oneInternal fails for a model without linear objective | `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m` |
| `src/analysis/FBA/optimizeCbModel.m` | wrong-result | param.osenseStr and the sense of the model are ignored for a parameter structure | `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m` |
| `src/analysis/MOMA/MOMA.m` | error | Models with different reaction sets stop with an error | `test/verifiedTests/analysis/testMOMA/testMOMA.m` |
| `src/analysis/QFCA/QFCA.m` | error | A network that reduces to one metabolite stops with an error | `test/verifiedTests/analysis/testQFCA/testQFCA.m` |
| `src/analysis/dynamicFBA/dynamicFBA.m` | cosmetic | The number of tracked exchange reactions is printed on every call | `test/verifiedTests/analysis/testDynamicFBA/testDynamicFBA.m` |
| `src/analysis/exploration/findMetFromCompartment.m` | limitation | A compartment letter without brackets matches every identifier with that letter | `test/verifiedTests/analysis/testExploration/testFindMetFromCompartment.m` |
| `src/analysis/exploration/findMetFromCompartment.m` | error | A compartment without metabolites stops with an error | `test/verifiedTests/analysis/testExploration/testFindMetFromCompartment.m` |
| `src/analysis/exploration/findRxnFromCompartment.m` | wrong-result | A compartment with a single metabolite returns the first reaction of the model | `test/verifiedTests/analysis/testExploration/testFindRxnFromCompartment.m` |
| `src/analysis/exploration/findRxnsFromGenes.m` | error | Calling with the optional numericFlag only stops with an error | `test/verifiedTests/analysis/testExploration/testFindRxnsFromGenes.m` |
| `src/analysis/exploration/findRxnsFromMets.m` | error | The documented positional printFlag alone stops with an error | `test/verifiedTests/analysis/testExploration/testFindRxnsFromMets.m` |
| `src/analysis/exploration/findRxnsFromMets.m` | unusable-option | The parameter verbFlag can never be used | `test/verifiedTests/analysis/testExploration/testFindRxnsFromMets.m` |
| `src/analysis/exploration/findRxnsFromMets.m` | error | exclusive stops with an error together with the direction or minimal options | `test/verifiedTests/analysis/testExploration/testFindRxnsFromMets.m` |
| `src/analysis/exploration/findSubSystemsFromGenes.m` | error | A model without rxnGeneMat and rules cannot be used | `test/verifiedTests/analysis/testExploration/testFindSubSystemsFromGenes.m` |
| `src/analysis/exploration/findSubSystemsFromGenes.m` | wrong-result | Sub-systems stored as character arrays come back as single letters | `test/verifiedTests/analysis/testExploration/testFindSubSystemsFromGenes.m` |
| `src/analysis/exploration/isReactionInSubSystem.m` | wrong-result | Reactions listed by name out of model order get each other's answers | `test/verifiedTests/analysis/testIsReactionInSubSystem/testIsReactionInSubSystem.m` |
| `src/analysis/exploration/printFluxVector.m` | error | Formulas or GPRs of a partly zero flux vector stop with an error | `test/verifiedTests/analysis/testPrint/testPrintFluxVector.m` |
| `src/analysis/exploration/printFluxVector.m` | wrong-result | excFlag has no effect unless nonZeroFlag is set | `test/verifiedTests/analysis/testPrint/testPrintFluxVector.m` |
| `src/analysis/exploration/printLabeledData.m` | wrong-result | Sorting on a data column other than the first is silently ignored | `test/verifiedTests/base/testTools/testPrintLabeledData.m` |
| `src/analysis/exploration/printRxnFormula.m` | wrong-result | A model without ub loses its lower bounds | `test/verifiedTests/analysis/testPrint/testPrintRxnFormula.m` |
| `src/analysis/exploration/printRxnFormula.m` | wrong-result | Bounds do not follow the file identifier | `test/verifiedTests/analysis/testPrint/testPrintRxnFormula.m` |
| `src/analysis/exploration/printRxnFormula.m` | wrong-result | GPRs built from model.rules are wrong or stop with an error | `test/verifiedTests/analysis/testPrint/testPrintRxnFormula.m` |
| `src/analysis/exploration/surfNet.m` | error | Searching with a flux vector stops with an error | `test/verifiedTests/analysis/testPrint/testSurfNet.m` |
| `src/analysis/exploration/surfNet.m` | cosmetic | The message for a partial field name shows a literal backslash n | `test/verifiedTests/analysis/testPrint/testSurfNet.m` |
| `src/analysis/exploration/surfNetSubfunctions/generateGrRules.m` | wrong-result | Nested hyperlinks when genes are named from the rules and a gene repeats | `test/verifiedTests/analysis/testExploration/testGenerateGrRules.m` |
| `src/analysis/fluxEnrichmentAnalysis/FEA.m` | error | An empty reaction set raises an error instead of returning the header-only result | `test/verifiedTests/analysis/testFEA/testFEA.m` |
| `src/analysis/geometricFBA/geometricFBA.m` | error | A model with a unique optimum stops with an error | `test/verifiedTests/analysis/testGeometricFBA/testGeometricFBA.m` |
| `src/analysis/igemRNA/filterNonFluxReactions/filterNonFluxReactions.m` | wrong-result | The result file is written next to the result folder, not into it | `test/verifiedTests/analysis/testFilterNonFluxReactions/testFilterNonFluxReactions.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/addMicrobeCommunityBiomass.m` | wrong-result | Abundance weights are rounded to six significant digits | `test/verifiedTests/analysis/testMultiSpeciesModelling/testAddMicrobeCommunityBiomass.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/translateMetagenome2AGORA.m` | wrong-result | Abundances read from a tsv file are added and normalized as text | `test/verifiedTests/analysis/testMultiSpeciesModelling/testTranslateMetagenome2AGORA.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/joinModelsPairwiseFromList.m` | error | Two models whose file names start with the same model name stop the function | `test/verifiedTests/analysis/testMultiSpeciesModelling/testJoinModelsPairwiseFromList.m` |
| `src/analysis/parsimoniousFBA/pFBA.m` | error | A call with one output stops with an error | `test/verifiedTests/analysis/testpFBA/testpFBA.m` |
| `src/analysis/persephone/calculateMetrics.m` | wrong-result | Bray-Curtis wrong for a single taxon | `test/verifiedTests/analysis/testPersephone/testCalculateMetrics.m` |
| `src/analysis/persephone/validatePersephoneInputs.m` | error | A column reaction list with two or more duplicates fails while the message is built | `test/verifiedTests/analysis/testPersephone/testValidatePersephoneInputs.m` |
| `src/analysis/rFBA/solveBooleanRegModel.m` | error | A name that is contained in a later name of the same rule stops with an error | `test/verifiedTests/analysis/testrFBA/testSolveBooleanRegModel.m` |
| `src/analysis/relaxedFBA/relaxedFBA.m` | limitation | A generic LP without rxns and mets stops with an error | `test/verifiedTests/analysis/testRelaxedFBA/testRelaxedFBA.m` |
| `src/analysis/relaxedFBA/relaxedFBA.m` | error | Extra variables given only by model.D stop with an error | `test/verifiedTests/analysis/testRelaxedFBA/testRelaxedFBA.m` |
| `src/analysis/rumba/compareConditions.m` | limitation | Sample-point count taken from the first metabolite of the first list | `test/verifiedTests/analysis/testRumba/testCompareConditions.m` |
| `src/analysis/sampling/ACHR/convRevSamples.m` | wrong-result | Bounds of a reverse-only reaction are not exchanged correctly | `test/verifiedTests/analysis/testSampling/testConvRevSamples.m` |
| `src/analysis/sampling/ACHR/gpSampler.m` | unusable-option | A bias distribution stops with an error | `test/verifiedTests/analysis/testSampling/testGpSampler.m` |
| `src/analysis/sampling/ACHR/gpSampler.m` | error | A problem given by A without S stops with an error | `test/verifiedTests/analysis/testSampling/testGpSampler.m` |
| `src/analysis/sampling/ACHR/gpSampler.m` | unusable-option | The distributed sampler does not exist | `test/verifiedTests/analysis/testSampling/testGpSampler.m` |
| `src/analysis/sampling/BarrierRound/PolytopeSimplifier/TwoSidedBarrier.m` | error | step_size fails for more than one point | `test/verifiedTests/analysis/testSampling/testTwoSidedBarrier.m` |
| `src/analysis/sampling/BarrierRound/utils/TableDisplay.m` | error | A format without a width gives a NaN length and header fails | `test/verifiedTests/analysis/testSampling/testTableDisplay.m` |
| `src/analysis/sampling/BarrierRound/utils/TableDisplay.m` | wrong-result | The blank that separates the columns is dropped | `test/verifiedTests/analysis/testSampling/testTableDisplay.m` |
| `src/analysis/subspaces/lsqr/lsqrtest.m` | cosmetic | The function handle is printed by a statement without a semicolon | `test/verifiedTests/analysis/testSubspaces/testLsqrtest.m` |
| `src/analysis/thermo/experimentalData/alberty2006/adjustBaselinesInAlberty2006.m` | wrong-result | The reduced glutathione energies are halved together with the baseline | `test/verifiedTests/analysis/testThermo/testAdjustBaselinesInAlberty2006.m` |
| `src/analysis/thermo/formulae/checkFormulae.m` | limitation | Elements other than C, H, O, P, S, K, Na and N are ignored | `test/verifiedTests/analysis/testThermo/testCheckFormulae.m` |
| `src/analysis/thermo/groupContribution/createComputedSpeciesData.m` | error | A row structure array of species fails when two metabolites are included | `test/verifiedTests/analysis/testThermo/testCreateComputedSpeciesData.m` |
| `src/analysis/thermo/groupContribution/createComputedSpeciesData.m` | wrong-result | The first group-contribution entry is used for every metabolite | `test/verifiedTests/analysis/testThermo/testCreateComputedSpeciesData.m` |
| `src/analysis/thermo/inchi/getMolecularWeight.m` | wrong-result | Hydrogens are lost for an InChI whose formula starts with H | `test/verifiedTests/analysis/testThermo/testGetMolecularWeight.m` |
| `src/analysis/thermo/thermoFBA/addLoopLawConstraints.m` | error | A wrong input ends with an unassigned output | `test/verifiedTests/analysis/testThermo/testAddLoopLawConstraints.m` |
| `src/analysis/thermo/thermoFBA/addLoopLawConstraints.m` | wrong-result | Method 3 without a vartype returns numbers instead of characters | `test/verifiedTests/analysis/testThermo/testAddLoopLawConstraints.m` |
| `src/analysis/thermo/thermoFBA/cycleFreeFlux.m` | wrong-result | A solution of the relaxed problem under param.debug is dropped | `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m` |
| `src/analysis/thermo/thermoFBA/cycleFreeFlux.m` | wrong-result | Lower bounds are checked only when an upper bound is violated | `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m` |
| `src/analysis/thermo/thermoFBA/cycleFreeFlux.m` | unusable-option | The analysis of an infeasible problem under param.debug stops at its first step | `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m` |
| `src/analysis/thermo/thermoFBA/cycleFreeFlux.m` | wrong-result | The objective bound of the lp approach is tightened when it should be relaxed | `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m` |
| `src/analysis/thermo/thermoFBA/cycleFreeFlux.m` | unusable-option | The relaxedFBA fallback of the regularised approach can never succeed | `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m` |
| `src/analysis/thermo/thermoFBA/cycleFreeFlux.m` | error | param.removeFixedBool = 1 stops the regularised approach | `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m` |
| `src/analysis/topology/FR/bilinearDecomposition.m` | error | A lone reaction with one substrate and three products gives inconsistent sizes | `test/verifiedTests/analysis/testTopology/testBilinearDecomposition.m` |
| `src/analysis/topology/FR/connectedFR.m` | wrong-result | The column sets are computed over the rows of [F; R] | `test/verifiedTests/analysis/testTopology/testConnectedFR.m` |
| `src/analysis/topology/FR/largestConnectedFR.m` | wrong-result | The column output is read from the row nodes and has m entries | `test/verifiedTests/analysis/testTopology/testLargestConnectedFR.m` |
| `src/analysis/topology/extremeRays/lrs/extremePools.m` | error | A model with mets but no usable SIntRxnBool stops on an undefined variable | `test/verifiedTests/analysis/testTopology/testExtremePools.m` |
| `src/analysis/topology/extremeRays/lrs/extremePools.m` | cosmetic | The third output is the transpose of what the help text states | `test/verifiedTests/analysis/testTopology/testExtremePools.m` |
| `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m` | error | glpk, one of the solvers the routine falls back on, cannot run the search | `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m` |
| `src/analysis/topology/findCyclicRxns.m` | wrong-result | The first output is not a per-reaction boolean | `test/verifiedTests/analysis/testTopology/testFindCyclicRxns.m` |
| `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m` | error | A reaction with an elemental mismatch stops the build instead of being skipped | `test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m` |
| `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m` | wrong-result | Decompartmentalising the model keeps the opening bracket | `test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m` |
| `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m` | error | The bond graph is not decompartmentalised | `test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m` |
| `src/analysis/topology/reactingMoieties/checkABRXNFiles.m` | wrong-result | Decompartmentalising the model keeps the opening bracket | `test/verifiedTests/analysis/testReactingMoieties/testCheckABRXNFiles.m` |
| `src/analysis/topology/reactingMoieties/checkABRXNFiles.m` | cosmetic | The duplicates that stop the check are not shown | `test/verifiedTests/analysis/testReactingMoieties/testCheckABRXNFiles.m` |
| `src/analysis/topology/reactingMoieties/identifyAtomEquivalenceClasses.m` | limitation | The check for a duplicate bond never fires | `test/verifiedTests/analysis/testReactingMoieties/testIdentifyAtomEquivalenceClasses.m` |
| `src/analysis/topology/reactingMoieties/readABRXNFile.m` | cosmetic | The two warnings about transition numbers print a literal backslash n | `test/verifiedTests/analysis/testReactingMoieties/testReadABRXNFile.m` |
| `src/analysis/topology/reactingMoieties/readABRXNFile.m` | unusable-option | options.readBonds = 0 cannot be used | `test/verifiedTests/analysis/testReactingMoieties/testReadABRXNFile.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/isValidVmhID.m` | limitation | Identifiers with surrounding blanks are rejected although they are trimmed for the other checks | `test/verifiedTests/analysis/testWholeBody/testIsValidVmhID.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/searcher.m` | unusable-option | Non-iterative search type cannot run | `test/verifiedTests/analysis/testWholeBody/testSearcher.m` |
| `src/analysis/wholeBody/PSCMToolbox/compareBounds2Models.m` | error | Reactions missing from a model are collected in a character matrix, which fails for names of different lengths | `test/verifiedTests/analysis/testWholeBody/testCompareBounds2Models.m` |
| `src/analysis/wholeBody/PSCMToolbox/createModelNewCompartment.m` | limitation | All MATLAB warnings are switched off and never switched back on | `test/verifiedTests/analysis/testWholeBody/testCreateModelNewCompartment.m` |
| `src/analysis/wholeBody/PSCMToolbox/createModelNewCompartment.m` | cosmetic | The names of the new transport reactions lose their blanks | `test/verifiedTests/analysis/testWholeBody/testCreateModelNewCompartment.m` |
| `src/analysis/wholeBody/PSCMToolbox/createModelNewCompartment.m` | limitation | rxnGeneMat is dropped when the original exchange reactions are removed | `test/verifiedTests/analysis/testWholeBody/testCreateModelNewCompartment.m` |
| `src/analysis/wholeBody/PSCMToolbox/io/addReactionsHH.m` | unusable-option | The coupling factor given by the caller is ignored | `test/verifiedTests/analysis/testWholeBody/testAddReactionsHH.m` |
| `src/analysis/wholeBody/PSCMToolbox/io/addReactionsHH.m` | wrong-result | rxnGeneMat is not updated for the gene rules of the added reactions | `test/verifiedTests/analysis/testWholeBody/testAddReactionsHH.m` |
| `src/analysis/wholeBody/PSCMToolbox/setConstraints/setFeedingFastingConstraints.m` | cosmetic | The list of storable amino acids is printed on every call | `test/verifiedTests/analysis/testWholeBody/testSetFeedingFastingConstraints.m` |
| `src/base/generateSystemConfigReport.m` | error | A short answer from curl stops the report at the summary | `test/verifiedTests/base/testTools/testGenerateSystemConfigReport.m` |
| `src/base/io/KEGG/mapKEGGID2Model.m` | error | A dictionary abbreviation with several entries stops with an error | `test/verifiedTests/base/testIO/testKEGG/testMapKEGGID2Model.m` |
| `src/base/io/KEGG/mapKEGGID2Model.m` | error | A metabolite without compartment that is in the dictionary stops with an error | `test/verifiedTests/base/testIO/testKEGG/testMapKEGGID2Model.m` |
| `src/base/io/KEGG/mapMetName2KEGGID.m` | error | A metabolite without compartment that is in the dictionary stops with an error | `test/verifiedTests/base/testIO/testKEGG/testMapMetName2KEGGID.m` |
| `src/base/io/KEGG/mapMetName2KEGGID.m` | cosmetic | The message for a metabolite with several matches is never printed | `test/verifiedTests/base/testIO/testKEGG/testMapMetName2KEGGID.m` |
| `src/base/io/convertCNAModelToCbModel.m` | error | Without CellNetAnalyzer an output is never assigned | `test/verifiedTests/base/testIO/testConvertCNAModelToCbModel.m` |
| `src/base/io/definitions/descFileRead.m` | wrong-result | An empty line ends the reading | `test/verifiedTests/base/testIO/testDescFileRead.m` |
| `src/base/io/definitions/descFileRead.m` | limitation | Short entries are padded with null characters, not blanks | `test/verifiedTests/base/testIO/testDescFileRead.m` |
| `src/base/io/utilities/SBML/getDataBases.m` | wrong-result | Mixed matching and non-matching resources return nothing | `test/verifiedTests/base/testIO/testUtilities/testGetDataBases.m` |
| `src/base/io/utilities/SBML/getDataBases.m` | error | Third output unassigned when nothing matches | `test/verifiedTests/base/testIO/testUtilities/testGetDataBases.m` |
| `src/base/io/utilities/SBML/makeSBMLAnnotationString.m` | wrong-result | A field of another is-qualifier is also annotated under the qualifier is | `test/verifiedTests/base/testIO/testUtilities/testMakeSBMLAnnotationString.m` |
| `src/base/io/utilities/createEmptyFields.m` | limitation | A cell field with a computed default fills only its first column | `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m` |
| `src/base/io/utilities/createEmptyFields.m` | error | A field whose default refers to another field the model lacks cannot be created | `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m` |
| `src/base/io/utilities/createEmptyFields.m` | error | The default of comps cannot be evaluated | `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m` |
| `src/base/io/utilities/initFBAFields.m` | limitation | The documented osense and csense fields are not created | `test/verifiedTests/base/testIO/testUtilities/testInitFBAFields.m` |
| `src/base/io/utilities/readSBML.m` | error | The documented default of defaultBound does not exist | `test/verifiedTests/base/testIO/testReadSBML.m` |
| `src/base/io/utilities/writeSBML.m` | error | A model without reactions cannot be written | `test/verifiedTests/base/testIO/testWriteSBML.m` |
| `src/base/io/utilities/writeSBML.m` | wrong-result | The compartments of the model and the given lists are replaced by the defaults | `test/verifiedTests/base/testIO/testWriteSBML.m` |
| `src/base/io/utilities/writeSBML.m` | error | The model annotation cannot be written | `test/verifiedTests/base/testIO/testWriteSBML.m` |
| `src/base/io/writeCbModel.m` | unusable-option | The JSON format is not detected from the file extension | `test/verifiedTests/base/testIO/testWriteCbModel.m` |
| `src/base/io/writeCbModel.m` | unusable-option | The file dialog offers an MPS export that does not exist | `test/verifiedTests/base/testIO/testWriteCbModel.m` |
| `src/base/parseMetNames.m` | limitation | Mixed or longer compartment notations are not parsed | `test/verifiedTests/base/testTools/testParseMetNames.m` |
| `src/base/removeGeneVersions.m` | error | A model without grRules stops after the warning | `test/verifiedTests/base/testRemoveGeneVersions/testRemoveGeneVersions.m` |
| `src/base/solvers/buildOptProblemFromModel.m` | error | A model with extra columns and no coupling rows gets no csense in its problem | `test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m` |
| `src/base/solvers/buildOptProblemFromModel.m` | error | Missing coupling and extra-variable fields are never built | `test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m` |
| `src/base/solvers/buildOptProblemFromModel.m` | error | The form QRQP keeps the csense of the model only | `test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m` |
| `src/base/solvers/buildOptProblemFromModel.m` | wrong-result | The forms QRLP and QRQP lose the bounds of the extra variables | `test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m` |
| `src/base/solvers/entropicFBA/processConcConstraints.m` | cosmetic | Documented defaults for the concentration unit and the maximum concentration differ from the code | `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m` |
| `src/base/solvers/entropicFBA/processConcConstraints.m` | unusable-option | The case dxReplacement always stops with an error | `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m` |
| `src/base/solvers/entropicFBA/processConcConstraints.m` | wrong-result | The default row selection indexes the first row repeatedly | `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m` |
| `src/base/solvers/entropicFBA/processConcConstraints.m` | error | The parameter printLevel is required although it is documented as optional | `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m` |
| `src/base/solvers/getSetSolver/changeCobraSolver.m` | error | A call without input stops instead of listing the defined solvers | `test/verifiedTests/base/testSolvers/testChangeCobraSolver.m` |
| `src/base/solvers/getSetSolver/changeCobraSolver.m` | wrong-result | A failed validation with printLevel above 0 keeps the failed solver selected | `test/verifiedTests/base/testSolvers/testChangeCobraSolver.m` |
| `src/base/solvers/getSetSolver/changeCobraSolver.m` | wrong-result | The problem type is matched as a substring | `test/verifiedTests/base/testSolvers/testChangeCobraSolver.m` |
| `src/base/solvers/isCompatible.m` | wrong-result | The distributed compatibility matrix is not understood by the parser | `test/verifiedTests/base/testSolvers/testIsCompatible.m` |
| `src/base/solvers/mosek/setMosekParam.m` | wrong-result | The strict option never switches MOSEK to a free solve form | `test/verifiedTests/base/testSolvers/testSetMosekParam.m` |
| `src/base/solvers/rescale/liftCouplingConstraints.m` | error | A row with more than two variables cannot be lifted with the default options | `test/verifiedTests/base/testLifting/testLiftCouplingConstraints.m` |
| `src/base/solvers/rescale/liftCouplingConstraints.m` | cosmetic | The model identifier gets two suffixes | `test/verifiedTests/base/testLifting/testLiftCouplingConstraints.m` |
| `src/base/solvers/solveCobraLP.m` | unusable-option | The option lifting stops on an undefined variable | `test/verifiedTests/base/testSolvers/testSolveCobraLP.m` |
| `src/base/solvers/solveCobraMILP.m` | error | The legacy mps interface returns no output | `test/verifiedTests/base/testSolvers/testSolveCobraMILP.m` |
| `src/base/solvers/solveCobraMILP.m` | error | gurobi does not accept an empty csense | `test/verifiedTests/base/testSolvers/testSolveCobraMILP.m` |
| `src/base/solvers/solveCobraMIQP.m` | unusable-option | The option saveInput stops the call | `test/verifiedTests/base/testSolvers/testSolveCobraMIQP.m` |
| `src/base/solvers/solveCobraQP.m` | error | A nonconvex QP solved to optimality by gurobi stops the function | `test/verifiedTests/base/testSolvers/testSolveCobraQP.m` |
| `src/base/solvers/solveCobraQP.m` | error | The qpng interface reads the problem after it was cleared | `test/verifiedTests/base/testSolvers/testSolveCobraQP.m` |
| `src/base/solvers/varKin/optimizeVKmodel0.m` | error | F equal to R with a moiety basis returns without the output | `test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m` |
| `src/base/solvers/varKin/optimizeVKmodel0.m` | cosmetic | The display format is switched to long E and never restored | `test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m` |
| `src/base/solvers/varKin/optimizeVKmodel0.m` | unusable-option | The option flag_psi_error cannot be used | `test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m` |
| `src/base/solvers/varKin/optimizeVKmodel0.m` | wrong-result | The steady state is dropped when the QR factor is a vector with a negative entry | `test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m` |
| `src/base/solvers/verifyCobraProblem.m` | error | A NaN in x stops a call with more than one output | `test/verifiedTests/base/testSolvers/testVerifyCobraProblem.m` |
| `src/base/solvers/verifyCobraProblem.m` | wrong-result | invalidConstraints names the wrong rows when senses are mixed | `test/verifiedTests/base/testSolvers/testVerifyCobraProblem.m` |
| `src/base/utilities/removeIndicesInDimenion.m` | cosmetic | The help text says the given indices are removed, but they are the ones kept | `test/verifiedTests/base/testTools/testRemoveIndicesInDimenion.m` |
| `src/base/utilities/updateStructData.m` | limitation | A structure update is ignored when the original field is not a structure | `test/verifiedTests/base/testTools/testUpdateStructData.m` |
| `src/dataIntegration/XomicsToModel/analysis/coreMetRxnAnalysis.m` | wrong-result | A given list of deleted metabolites is discarded when the old model is empty and no deleted reactions are given | `test/verifiedTests/dataIntegration/testXomicsToModel/testCoreMetRxnAnalysis.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m` | error | A reaction listed three times stops the constraint step | `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m` | wrong-result | A tiny bound of the unusual sign changes sign | `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m` | error | An unknown varID stops the mode allConstraints on a model without extra variables | `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m` | limitation | The default eta is below the noise of the fit | `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m` | wrong-result | The fitted exometabolomic relaxation is not applied to a feasible model | `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m` | cosmetic | The message about a feasible fit is never printed | `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m` | error | The mode allConstraints needs the extra variable fields it treats as optional | `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m` | cosmetic | The session display format is changed | `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m` |
| `src/dataIntegration/chemoInformatics/deleteProtons.m` | wrong-result | Reactions that carried only protons are removed from the reaction fields but not from S | `test/verifiedTests/dataIntegration/testChemoInformatics/testDeleteProtons.m` |
| `src/dataIntegration/chemoInformatics/editChemicalFormula.m` | cosmetic | Element with zero atoms stays in the formula | `test/verifiedTests/dataIntegration/testChemoInformatics/testEditChemicalFormula.m` |
| `src/dataIntegration/chemoInformatics/inchi/getInchiData.m` | wrong-result | Negative charge layer gives NaN | `test/verifiedTests/dataIntegration/testChemoInformatics/testGetInchiData.m` |
| `src/dataIntegration/metaboAnnotator/buildMetStruct/convertModel2Metstructure.m` | wrong-result | A metabolite with a hyphen is overwritten by its next compartment | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testConvertModel2Metstructure.m` |
| `src/dataIntegration/metaboAnnotator/connect2resources/convertOld2NewHMDB.m` | limitation | Identifiers of 12 or more characters give an empty result | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testConvertOld2NewHMDB.m` |
| `src/dataIntegration/metanetxMapper/metanetxMapper.m` | error | Name search stops with an error when the search replies have the same field order | `test/verifiedTests/dataIntegration/testMetanetxMapper/testMetanetxMapper.m` |
| `src/dataIntegration/transcriptomics/MOOMIN/writeMoominOutput.m` | wrong-result | The json format writes colour names without quotes | `test/verifiedTests/dataIntegration/testMOOMIN/testWriteMoominOutput.m` |
| `src/dataIntegration/transcriptomics/preprocessing/selectGeneFromGPR.m` | wrong-result | With minSum the reported gene does not belong to the selected alternative | `test/verifiedTests/dataIntegration/testPreprocessing/testSelectGeneFromGPR.m` |
| `src/design/GDLS.m` | error | A single knockout cost in the model stops with an error | `test/verifiedTests/design/testGDLS/testGDLS.m` |
| `src/design/GDLS.m` | error | Options in a structure, or no options at all, stop with an error | `test/verifiedTests/design/testGDLS/testGDLS.m` |
| `src/design/GDLS.m` | unusable-option | The koCost option cannot be used | `test/verifiedTests/design/testGDLS/testGDLS.m` |
| `src/design/GDLS.m` | limitation | The per-solution field name has no number | `test/verifiedTests/design/testGDLS/testGDLS.m` |
| `src/design/GDLS.m` | wrong-result | The solution values of all the designs are those of the last knockout set | `test/verifiedTests/design/testGDLS/testGDLS.m` |
| `src/design/OptKnock.m` | error | A model with coupling constraints stops with an error | `test/verifiedTests/design/testOptKnock/testOptKnock.m` |
| `src/design/OptKnock.m` | wrong-result | Without constrOpt the inner growth maximisation is lost | `test/verifiedTests/design/testOptKnock/testOptKnock.m` |
| `src/design/TrimGdel/modelSetting.m` | wrong-result | A model without rev gets rev as a row vector | `test/verifiedTests/design/testTrimGdel/testModelSetting.m` |
| `src/design/multiProductionEnvelope.m` | error | An unbounded minimum is stored in the upper bounds | `test/verifiedTests/design/testMultiProductionEnvelope.m` |
| `src/design/multiProductionEnvelope.m` | wrong-result | The wrong reaction is removed when a later substrate is next to the end of the list | `test/verifiedTests/design/testMultiProductionEnvelope.m` |
| `src/design/optEnvelope/optEnvelope.m` | error | The mid output is not assigned without mid points | `test/verifiedTests/design/testOptEnvelope/testOptEnvelope.m` |
| `src/design/optEnvelope/optEnvelope.m` | unusable-option | The numKO option always stops with an error | `test/verifiedTests/design/testOptEnvelope/testOptEnvelope.m` |
| `src/design/optEnvelope/optEnvelope.m` | wrong-result | With prodMol the peaks of the mid envelopes are zero | `test/verifiedTests/design/testOptEnvelope/testOptEnvelope.m` |
| `src/design/optForce/optForce.m` | error | A progress message of the option loop is written to the report file | `test/verifiedTests/design/testOptForce/testOptForce.m` |
| `src/design/optForce/optForce.m` | cosmetic | A wrong exclusion type leaves the report open and the folder changed | `test/verifiedTests/design/testOptForce/testOptForce.m` |
| `src/design/optForce/optForce.m` | cosmetic | The documented exclusion type D is not recognised when the inputs are recorded | `test/verifiedTests/design/testOptForce/testOptForce.m` |
| `src/design/optForce/optForce.m` | wrong-result | The option loop solves the same problem in each pass | `test/verifiedTests/design/testOptForce/testOptForce.m` |
| `src/design/optForce/optForce.m` | unusable-option | The option loop stops with an error as soon as a set is found | `test/verifiedTests/design/testOptForce/testOptForce.m` |
| `src/design/optForce/optForce.m` | cosmetic | The report becomes a file named like the output folder | `test/verifiedTests/design/testOptForce/testOptForce.m` |
| `src/design/simpleOptKnock.m` | limitation | Single-deletion growth is stored in the first column in double-deletion mode | `test/verifiedTests/design/testSimpleOptKnock.m` |
| `src/design/simpleOptKnock.m` | wrong-result | The wild-type minimum production is the maximum | `test/verifiedTests/design/testSimpleOptKnock.m` |
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
| `src/reconstruction/growthExpMatch/growthExpMatch.m` | error | A SUX structure without exchange reactions cannot be solved | `test/verifiedTests/reconstruction/testGrowthExpMatch/testGrowthExpMatch.m` |
| `src/reconstruction/growthExpMatch/growthExpMatch.m` | error | An empty objective stops with an undefined variable | `test/verifiedTests/reconstruction/testGrowthExpMatch/testGrowthExpMatch.m` |
| `src/reconstruction/modelGeneration/checkDuplicateRxn.m` | wrong-result | the 'FR' method removes the last reaction of a group after testing the first two | `test/verifiedTests/reconstruction/testCheckDuplicateRxn/testCheckDuplicateRxn.m` |
| `src/reconstruction/modelGeneration/checkDuplicateRxn.m` | wrong-result | the 'rxnAbbr' method returns the unique reactions as the duplicates | `test/verifiedTests/reconstruction/testCheckDuplicateRxn/testCheckDuplicateRxn.m` |
| `src/reconstruction/modelGeneration/fastLeakTest.m` | error | an error when every tested reaction leaks | `test/verifiedTests/reconstruction/testFastLeakTest/testFastLeakTest.m` |
| `src/reconstruction/modelGeneration/modelProperties/checkModelProperties.m` | wrong-result | minSij is zero for every model with a zero in S | `test/verifiedTests/reconstruction/testCheckModelProperties/testCheckModelProperties.m` |
| `src/reconstruction/modelGeneration/modelProperties/checkModelProperties.m` | error | the randomised thermodynamic test can stop with an error | `test/verifiedTests/reconstruction/testCheckModelProperties/testCheckModelProperties.m` |
| `src/reconstruction/modelGeneration/modelProperties/checkModelProperties.m` | wrong-result | the sanity checks after the rank computation never fire | `test/verifiedTests/reconstruction/testCheckModelProperties/testCheckModelProperties.m` |
| `src/reconstruction/modelGeneration/modelProperties/checkModelProperties.m` | cosmetic | the thermodynamic consistency counts vary between runs | `test/verifiedTests/reconstruction/testCheckModelProperties/testCheckModelProperties.m` |
| `src/reconstruction/modelGeneration/modelVerification/checkDatabaseIDs.m` | wrong-result | Standard InChI strings with an undefined stereo centre are reported invalid | `test/verifiedTests/reconstruction/testModelGeneration/testCheckDatabaseIDs.m` |
| `src/reconstruction/modelGeneration/modelVerification/verifyModel.m` | wrong-result | a consistent model fails the simple check of flux consistency | `test/verifiedTests/reconstruction/testModelGeneration/testVerifyModel.m` |
| `src/reconstruction/modelGeneration/modelVerification/verifyModel.m` | wrong-result | every reaction counts as imbalanced in a mass balance without charges | `test/verifiedTests/reconstruction/testModelGeneration/testVerifyModel.m` |
| `src/reconstruction/modelGeneration/modelVerification/verifyModel.m` | wrong-result | the fields reported as problematic are the valid ones | `test/verifiedTests/reconstruction/testModelGeneration/testVerifyModel.m` |
| `src/reconstruction/modelGeneration/modelVerification/verifyModel.m` | error | the report of stoichiometric consistency stops with an error | `test/verifiedTests/reconstruction/testModelGeneration/testVerifyModel.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | limitation | All MATLAB warnings are switched off and never switched back on | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | cosmetic | An empty rev field is left when no reaction is removed | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | limitation | Annotation and constraint fields of the input model are dropped | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | wrong-result | Reactions that become duplicates are not removed | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | cosmetic | The default compartment and every reaction index are printed | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/removeCompartments.m` | wrong-result | metNames is a row and holds the metabolite identifiers | `test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m` |
| `src/reconstruction/modelGeneration/setConstraintsIrrevModel.m` | wrong-result | Reactions with names of one or two characters get the wrong sign | `test/verifiedTests/reconstruction/testModelGeneration/testSetConstraintsIrrevModel.m` |
| `src/reconstruction/modelGeneration/test4HumanFctExt.m` | error | an error when no test carried flux | `test/verifiedTests/reconstruction/testModelGeneration/testTest4HumanFctExt.m` |
| `src/reconstruction/modelGeneration/test4HumanFctExt.m` | cosmetic | the diary is opened in the current folder and never closed | `test/verifiedTests/reconstruction/testModelGeneration/testTest4HumanFctExt.m` |
| `src/reconstruction/modelGeneration/test4HumanFctExt.m` | unusable-option | the documented option 'IECori' is not recognised | `test/verifiedTests/reconstruction/testModelGeneration/testTest4HumanFctExt.m` |
| `src/reconstruction/modelGeneration/test4HumanFctExt.m` | unusable-option | the option 'IECOri' stops with an error for every model | `test/verifiedTests/reconstruction/testModelGeneration/testTest4HumanFctExt.m` |
| `src/reconstruction/modelGeneration/test4HumanFctExt.m` | error | three tests stop with an error when their objective reaction is missing | `test/verifiedTests/reconstruction/testModelGeneration/testTest4HumanFctExt.m` |
| `src/reconstruction/rBioNet/LegalRxnFormula.m` | wrong-result | An empty formula is accepted when more than one formula is checked | `test/verifiedTests/reconstruction/testRBioNet/testLegalRxnFormula.m` |
| `src/reconstruction/rBioNet/LegalRxnFormula.m` | cosmetic | The message has a spelling error | `test/verifiedTests/reconstruction/testRBioNet/testLegalRxnFormula.m` |
| `src/reconstruction/rBioNet/model2data.m` | error | A model whose description is missing or is not a text or a structure of seven fields stops | `test/verifiedTests/reconstruction/testRBioNet/testModel2data.m` |
| `src/reconstruction/rBioNet/model2data.m` | wrong-result | A model without grRules is reported as incomplete although the field is created | `test/verifiedTests/reconstruction/testRBioNet/testModel2data.m` |
| `src/reconstruction/rBioNet/model2data.m` | error | The two exits with a message box leave the output unassigned | `test/verifiedTests/reconstruction/testRBioNet/testModel2data.m` |
| `src/reconstruction/rBioNet/rBioNetSaveLoad.m` | error | A wrong path of the compartment database is not detected | `test/verifiedTests/reconstruction/testRBioNet/testRBioNetSaveLoad.m` |
| `src/reconstruction/rBioNet/rBioNetSaveLoad.m` | cosmetic | Saving prints the whole database | `test/verifiedTests/reconstruction/testRBioNet/testRBioNetSaveLoad.m` |
| `src/reconstruction/refinement/GPRLogic/combineChildren.m` | wrong-result | Identical generated clauses delete the earlier clause | `test/verifiedTests/reconstruction/testModelManipulation/testCombineChildren.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | error | A formula whose first metabolite has no coefficient stops with an error | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | wrong-result | A new metabolite used twice in one call is added twice or loses a coefficient | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | wrong-result | A proteins field of another size than the gene list discards the result | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | wrong-result | Appended reactions get no identifier, so rxns is shorter than the other fields | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | error | Appending a reaction whose first metabolite is already in the model stops with an error | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | wrong-result | The default gene list removes all genes of the model | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | wrong-result | The subsystem of every filled reaction is stored as a cell inside a cell | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/extractSubSysModel.m` | wrong-result | A single subsystem name given as text selects almost every reaction | `test/verifiedTests/reconstruction/testModelManipulation/testExtractSubSysModel.m` |
| `src/reconstruction/refinement/mergeModelFieldPositions.m` | error | A cell field that does not hold text or cell arrays cannot be merged | `test/verifiedTests/base/testTools/testMergeModelFieldPositions.m` |
| `src/reconstruction/refinement/mergeTwoModels.m` | wrong-result | A field that cannot be concatenated is dropped with a debug message | `test/verifiedTests/reconstruction/testModelManipulation/testMergeTwoModels.m` |
| `src/reconstruction/refinement/removeFieldEntriesForType.m` | error | removing genes from a model that has grRules but no rules field fails | `test/verifiedTests/reconstruction/testRemoveFieldEntriesForType/testRemoveFieldEntriesForType.m` |
| `src/reconstruction/refinement/updateFieldOrderForType.m` | limitation | An order that repeats indices is accepted | `test/verifiedTests/reconstruction/testModelManipulation/testUpdateFieldOrderForType.m` |
| `src/reconstruction/refinement/updateFieldOrderForType.m` | unusable-option | The type proteins is accepted but always stops with an error | `test/verifiedTests/reconstruction/testModelManipulation/testUpdateFieldOrderForType.m` |
| `src/reconstruction/refinement/updateGenes.m` | wrong-result | With two duplicated genes, different genes are merged | `test/verifiedTests/reconstruction/testModelManipulation/testUpdateGenes.m` |
| `src/visualization/cellDesigner/readCD.m` | limitation | Attributes missing from the first reaction are dropped for all reactions | `test/verifiedTests/visualization/testCellDesigner/testReadCD.m` |
| `src/visualization/cellDesigner/readCD.m` | cosmetic | Debug output of the attribute list and of the whole partial result | `test/verifiedTests/visualization/testCellDesigner/testReadCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | error | A text without "<species " lines stops with an error | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | cosmetic | Debug output of internal variables | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | wrong-result | Every occurrence of the old name in the line is replaced | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | unusable-option | The documented default value of note stops with an error | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | wrong-result | The second round pairs name lines with species rows by position and stops early | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | wrong-result | changedStrLines lists only the lines changed in the second round | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | wrong-result | number lists only the lines found in the second round | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/efmviz/efmEnrichmentAnalysis.m` | error | Expression data without significance values stops with an error | `test/verifiedTests/visualization/testEFMviz/testEfmEnrichmentAnalysis.m` |
| `src/visualization/efmviz/efmSubsystemsExtraction.m` | error | Every call with valid inputs stops with an error | `test/verifiedTests/visualization/testEFMviz/testEfmSubsystemsExtraction.m` |
| `src/visualization/maps/ReconMap/makeColorGradient.m` | wrong-result | A channel that is equal in both colours becomes 0 | `test/verifiedTests/visualization/testReconMap/testMakeColorGradient.m` |
| `src/visualization/maps/ReconMap/printInRecon3Dmap.m` | cosmetic | The line width is written with a stray digit | `test/verifiedTests/visualization/testReconMap/testPrintInRecon3Dmap.m` |
| `src/visualization/metabolicCartography/addFluxWidthAndColor.m` | limitation | Map reactions without flux data get no colour entry | `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxWidthAndColor.m` |
| `src/visualization/metabolicCartography/removeMapMol.m` | wrong-result | Aliases of a removed reaction are removed even when kept reactions use them | `test/verifiedTests/visualization/testMetabolicCartography/testRemoveMapMol.m` |
| `src/visualization/metabolicCartography/removeMapMol.m` | limitation | Reactions keep a removed alias of a species that has other aliases | `test/verifiedTests/visualization/testMetabolicCartography/testRemoveMapMol.m` |
| `src/visualization/upsetPlot/upsetPlot.m` | error | Sets without any element stop with an index error | `test/verifiedTests/visualization/testUpsetPlot/testUpsetPlot.m` |
| `src/visualization/visualizeEpistasis/findSubsystemOfGenes.m` | error | A reaction with several subsystems stops with an error | `test/verifiedTests/visualization/testVisualizeEpistasis/testFindSubsystemOfGenes.m` |
| `src/visualization/visualizeEpistasis/findSubsystemOfGenes.m` | wrong-result | Only the last reaction of a gene gives its subsystem | `test/verifiedTests/visualization/testVisualizeEpistasis/testFindSubsystemOfGenes.m` |

## Details

### `src/analysis/FBA/optimizeCbModel.m`

#### A text in param.minNorm reaches solveCobraLP and stops with an error

- **Severity**: error
- **Trigger**: param.minNorm = 'one' or 'oneInternal', for example optimizeCbModel(model, struct('minNorm', 'one'))
- **Observed**: the second solve passes param on to solveCobraLP, where the check of minNorm fails with "Operands to the logical AND (&&) and OR (||) operators must be convertible"
- **Expected**: the documented param.minNorm works as the input minNorm does
- **Source lines**: 677, 733
- **Documented in**: `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m`

#### QRQP cannot run

- **Severity**: unusable-option
- **Trigger**: param.solveWBMmethod = 'QRQP' with param.minNorm = 'QRQP'
- **Observed**: the variable minNormWBM does not exist, so the call stops with "Unrecognized function or variable 'minNormWBM'"
- **Expected**: the quadratically regularised QP is solved, using param.minNormWBM
- **Source lines**: 758-760
- **Documented in**: `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m`

#### The linear objective is dropped for param.solveWBMmethod

- **Severity**: limitation
- **Trigger**: param.solveWBMmethod = 'QP', 'QRLP' or 'QRQP' on a model with a linear objective
- **Observed**: model.c is set to zero, so the flux of the objective reaction is not maximised and solution.f is empty
- **Expected**: the regularised problem keeps the linear objective of the model
- **Source lines**: 441
- **Documented in**: `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m`

#### The residual and the slack of QRLP are read from the wrong positions

- **Severity**: wrong-result
- **Trigger**: minNorm = 'QRLP'
- **Observed**: the slack holds the first fluxes, and r runs from n+1 to m, which is empty for a model with more reactions than constraints
- **Expected**: r and the slack are the m residual values that follow the n fluxes
- **Source lines**: 744, 750
- **Documented in**: `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m`

#### minNorm oneInternal fails for a model without linear objective

- **Severity**: error
- **Trigger**: minNorm = 'oneInternal' on a model with all of c zero
- **Observed**: objectiveLP is empty, so the right hand side is one row short and solveCobraLP stops with "Incorrect size(model.rhs)"
- **Expected**: the internal fluxes are minimised
- **Source lines**: 719
- **Documented in**: `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m`

#### param.osenseStr and the sense of the model are ignored for a parameter structure

- **Severity**: wrong-result
- **Trigger**: the parameter structure as second input with a model that has osenseStr, for example model.osenseStr = 'min' or param.osenseStr = 'min' on a model with 'max'
- **Observed**: the else branch sets model.osenseStr to 'max', so the model is maximised
- **Expected**: param.osenseStr is used when given, otherwise the sense of the model
- **Source lines**: 259-263
- **Documented in**: `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m`

### `src/analysis/MOMA/MOMA.m`

#### Models with different reaction sets stop with an error

- **Severity**: error
- **Trigger**: MOMA(model, removeRxns(model, 'ACt2r'), 'max', false, 0), a deletion model that lacks a reaction of the wild type model
- **Observed**: the solution vectors of both models are subtracted without matching their reactions, which stops with "Arrays have incompatible sizes for this operation"
- **Expected**: a solution, since the help says that the two reaction sets do not have to be equal as long as there is at least one reaction in common
- **Source lines**: 243
- **Documented in**: `test/verifiedTests/analysis/testMOMA/testMOMA.m`

### `src/analysis/QFCA/QFCA.m`

#### A network that reduces to one metabolite stops with an error

- **Severity**: error
- **Trigger**: the network -> A, A -> B, A -> B, B -> with QFCA(model, false, 'gurobi')
- **Observed**: after the merging the reduced S has one row, so R of qr(S.') is a vector, diag(R) is a matrix and the rank is a vector; the next line stops with "Colon operands must be real scalars"
- **Expected**: the flux coupling table of the network
- **Source lines**: 125
- **Documented in**: `test/verifiedTests/analysis/testQFCA/testQFCA.m`

### `src/analysis/dynamicFBA/dynamicFBA.m`

#### The number of tracked exchange reactions is printed on every call

- **Severity**: cosmetic
- **Trigger**: any call of dynamicFBA
- **Observed**: the statement length(excRxnNames) has no semicolon, so ans = 16 is displayed
- **Expected**: no output
- **Source lines**: 66
- **Documented in**: `test/verifiedTests/analysis/testDynamicFBA/testDynamicFBA.m`

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

### `src/analysis/exploration/findRxnsFromGenes.m`

#### Calling with the optional numericFlag only stops with an error

- **Severity**: error
- **Trigger**: three input arguments, for example findRxnsFromGenes(model, 'b0115', 0)
- **Observed**: ListResultsFlag is only given a default for fewer than three inputs, so the call fails with "Not enough input arguments" where ListResultsFlag is read
- **Expected**: ListResultsFlag takes its documented default 0 and the call succeeds
- **Source lines**: 43, 122
- **Documented in**: `test/verifiedTests/analysis/testExploration/testFindRxnsFromGenes.m`

### `src/analysis/exploration/findRxnsFromMets.m`

#### The documented positional printFlag alone stops with an error

- **Severity**: error
- **Trigger**: findRxnsFromMets(model, metList, printFlag) with no parameter/value pair after it
- **Observed**: varargin keeps its single element, so inputParser fails with "Expected a string scalar or character vector for the parameter name"
- **Expected**: the reactions are returned and printed, as in the USAGE line
- **Source lines**: 50-52, 64
- **Documented in**: `test/verifiedTests/analysis/testExploration/testFindRxnsFromMets.m`

#### The parameter verbFlag can never be used

- **Severity**: unusable-option
- **Trigger**: findRxnsFromMets(model, metList, 'verbFlag', 1)
- **Observed**: the validator calls isnumeric without an argument, so parsing fails with "The value of 'verbFlag' is invalid"; the branch behind it also reads the misspelt field verbFag
- **Expected**: verbFlag is accepted as the backward compatible name of printFlag
- **Source lines**: 60, 68-69, 71
- **Documented in**: `test/verifiedTests/analysis/testExploration/testFindRxnsFromMets.m`

#### exclusive stops with an error together with the direction or minimal options

- **Severity**: error
- **Trigger**: 'exclusive' true together with 'producersOnly', 'consumersOnly' or 'minimalReactionN', for example findRxnsFromMets(model, mets, 'exclusive', true, 'producersOnly', true)
- **Observed**: rels is a column in those branches and others a row, so implicit expansion gives an n x n matrix and indexing model.rxns fails
- **Expected**: the reactions that meet both options are returned
- **Source lines**: 136, 145
- **Documented in**: `test/verifiedTests/analysis/testExploration/testFindRxnsFromMets.m`

### `src/analysis/exploration/findSubSystemsFromGenes.m`

#### A model without rxnGeneMat and rules cannot be used

- **Severity**: error
- **Trigger**: a model that has grRules but neither rxnGeneMat nor rules
- **Observed**: `regexptranslate y` inside the square brackets calls regexptranslate without arguments, so the call fails with "Not enough input arguments"
- **Expected**: the gene associations are read from grRules, as the comment in the code says
- **Source lines**: 76
- **Documented in**: `test/verifiedTests/analysis/testExploration/testFindSubSystemsFromGenes.m`

#### Sub-systems stored as character arrays come back as single letters

- **Severity**: wrong-result
- **Trigger**: a model whose subSystems entries are character arrays, the format kept by getDistributedModel for ecoli_core_model, for example findSubSystemsFromGenes(model, 'b1779')
- **Observed**: the entries are concatenated into one character array, so unique returns its letters, '/Gcegilnosuy' instead of 'Glycolysis/Gluconeogenesis'
- **Expected**: the names of the sub-systems
- **Source lines**: 87, 92
- **Documented in**: `test/verifiedTests/analysis/testExploration/testFindSubSystemsFromGenes.m`

### `src/analysis/exploration/isReactionInSubSystem.m`

#### Reactions listed by name out of model order get each other's answers

- **Severity**: wrong-result
- **Trigger**: a cell array of reactions in another order than model.rxns, for example isReactionInSubSystem(model, {'R5', 'Ex_A'}, 'S3') with only R5 in S3
- **Observed**: [0; 1], because the reactions are looked up in model order while the answers are stored in the order of the request
- **Expected**: [1; 0], one answer per requested reaction in the order of the request
- **Source lines**: 40, 63
- **Documented in**: `test/verifiedTests/analysis/testIsReactionInSubSystem/testIsReactionInSubSystem.m`

### `src/analysis/exploration/printFluxVector.m`

#### Formulas or GPRs of a partly zero flux vector stop with an error

- **Severity**: error
- **Trigger**: nonZeroFlag true with formulaFlag or gprFlag true while at least one reaction is not selected, for example a flux vector with a zero entry
- **Observed**: the column of formulas holds fewer texts than rows, so the assignment fails with "Unable to perform assignment because the size of the left side is 95-by-1 and the size of the right side is 92-by-1"
- **Expected**: the selected reactions are printed with their formula or GPR
- **Source lines**: 82-85, 102-105
- **Documented in**: `test/verifiedTests/analysis/testPrint/testPrintFluxVector.m`

#### excFlag has no effect unless nonZeroFlag is set

- **Severity**: wrong-result
- **Trigger**: printFluxVector(model, flux, false, true)
- **Observed**: every reaction is printed, because the selection of the exchange reactions is only applied when nonZeroFlag is true
- **Expected**: only the exchange fluxes are printed, as documented for excFlag
- **Source lines**: 112-115
- **Documented in**: `test/verifiedTests/analysis/testPrint/testPrintFluxVector.m`

### `src/analysis/exploration/printLabeledData.m`

#### Sorting on a data column other than the first is silently ignored

- **Severity**: wrong-result
- **Trigger**: sortCol greater than 1, for example printLabeledData({'a';'b'}, [1 9; 2 3], 0, 2)
- **Observed**: the rows keep their input order, because `case sortCol > 0` of the switch compares sortCol with the logical value true, which only equals 1
- **Expected**: the rows are sorted on the requested data column, as documented for sortCol
- **Source lines**: 81
- **Documented in**: `test/verifiedTests/base/testTools/testPrintLabeledData.m`

### `src/analysis/exploration/printRxnFormula.m`

#### A model without ub loses its lower bounds

- **Severity**: wrong-result
- **Trigger**: a model without the field ub
- **Observed**: model.lb is overwritten with +Inf and ub stays missing, so a reversible reaction is printed with -> instead of <=>
- **Expected**: model.ub is set to +Inf and model.lb is left as it is
- **Source lines**: 91
- **Documented in**: `test/verifiedTests/analysis/testPrint/testPrintRxnFormula.m`

#### Bounds do not follow the file identifier

- **Severity**: wrong-result
- **Trigger**: printBounds true with a file identifier in fid
- **Observed**: the bounds are printed on the screen, the formula goes to the file
- **Expected**: the bounds go to the file together with the formula
- **Source lines**: 237
- **Documented in**: `test/verifiedTests/analysis/testPrint/testPrintRxnFormula.m`

#### GPRs built from model.rules are wrong or stop with an error

- **Severity**: wrong-result
- **Trigger**: printing with gprFlag on a model without grRules, or with proteinFlag, on any reaction with a rule
- **Observed**: num2str($1) gives a character, which indexes the gene list by its character code (x(1) reads gene 49), so another gene is printed or the call fails with "Index exceeds the number of array elements"; the pattern '|' also matches the empty text
- **Expected**: the rule printed with the gene or protein names and the words or and and
- **Source lines**: 221-225, 229-233
- **Documented in**: `test/verifiedTests/analysis/testPrint/testPrintRxnFormula.m`

### `src/analysis/exploration/surfNet.m`

#### Searching with a flux vector stops with an error

- **Severity**: error
- **Trigger**: a query that is no identifier and matches reactions, together with a flux vector, for example surfNet(model, 'glucose', 't', 0.6, 'flux', solution.x)
- **Observed**: the search listing reads fluxLocal(id) although id is only set after the search, so the call fails with "Unrecognized function or variable 'id'"
- **Expected**: the matching reactions are listed with their fluxes
- **Source lines**: 522, 543, 566
- **Documented in**: `test/verifiedTests/analysis/testPrint/testSurfNet.m`

#### The message for a partial field name shows a literal backslash n

- **Severity**: cosmetic
- **Trigger**: a partial field name in printFields that matches several fields, for example 'met'
- **Observed**: the message starts with the two characters backslash and n, because error is called with the text as its only argument, which is not processed as a format
- **Expected**: the message starts on a new line
- **Source lines**: 319, 333
- **Documented in**: `test/verifiedTests/analysis/testPrint/testSurfNet.m`

### `src/analysis/exploration/surfNetSubfunctions/generateGrRules.m`

#### Nested hyperlinks when genes are named from the rules and a gene repeats

- **Severity**: wrong-result
- **Trigger**: generateGrRules(rmfield(model, 'genes'), 'fprintf(''%s'')') with ecoli_core_model, whose rules for 3 reactions use a gene twice
- **Observed**: the hyperlink of a gene x(i) contains the text x(i), and every occurrence is replaced again for each repetition of the gene in the rule, so grRulesLinked holds hyperlinks nested inside hyperlinks
- **Expected**: each gene of the rule hyperlinked exactly once
- **Source lines**: 64, 73-74
- **Documented in**: `test/verifiedTests/analysis/testExploration/testGenerateGrRules.m`

### `src/analysis/fluxEnrichmentAnalysis/FEA.m`

#### An empty reaction set raises an error instead of returning the header-only result

- **Severity**: error
- **Trigger**: FEA(model, [], 'subSystems')
- **Observed**: error 'Please provide the indices of the reactions e.g. 1:10', because isvector([]) is false, so the check at line 32 fires before the empty-set branch
- **Expected**: the header-only cell array of lines 35-36 (the branch is unreachable)
- **Source lines**: 32, 35-37
- **Documented in**: `test/verifiedTests/analysis/testFEA/testFEA.m`

### `src/analysis/geometricFBA/geometricFBA.m`

#### A model with a unique optimum stops with an error

- **Severity**: error
- **Trigger**: geometricFBA(model) when every reaction is fixed by the first flux variability loop, for example -> A, A -> with the second reaction as objective and a finite uptake
- **Observed**: the output is only assigned in the iteration loop, which is then not entered, so the call stops with "Output argument flux (and possibly others) not assigned a value"
- **Expected**: the unique flux vector
- **Source lines**: 215
- **Documented in**: `test/verifiedTests/analysis/testGeometricFBA/testGeometricFBA.m`

### `src/analysis/igemRNA/filterNonFluxReactions/filterNonFluxReactions.m`

#### The result file is written next to the result folder, not into it

- **Severity**: wrong-result
- **Trigger**: any call, for example filterNonFluxReactions('WT')
- **Observed**: the path is built without a file separator, so the result goes to resultsPostOptimization/nonFluxReactionsnonFluxReactionsWT.xls and the folder nonFluxReactions stays empty. The first section below therefore compares the reference with the file stored in this folder, not with a new result.
- **Expected**: resultsPostOptimization/nonFluxReactions/nonFluxReactionsWT.xls
- **Source lines**: 84
- **Documented in**: `test/verifiedTests/analysis/testFilterNonFluxReactions/testFilterNonFluxReactions.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/addMicrobeCommunityBiomass.m`

#### Abundance weights are rounded to six significant digits

- **Severity**: wrong-result
- **Trigger**: weights with more than six significant digits, for example three microbes without abundances (weights 1/3) or abundances [0.123456789; 0.2; 0.676543211]
- **Observed**: the reactions are added through their printed formulas (printRxnFormula, then addReaction), so the coefficients become -0.333333 (sum 0.999999) and -0.123457, -0.676543 instead of the given weights
- **Expected**: the coefficients of communityBiomass equal the given abundances, or 1/n, exactly
- **Source lines**: 47-50
- **Documented in**: `test/verifiedTests/analysis/testMultiSpeciesModelling/testAddMicrobeCommunityBiomass.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/translateMetagenome2AGORA.m`

#### Abundances read from a tsv file are added and normalized as text

- **Severity**: wrong-result
- **Trigger**: an input file with the extension .tsv, the format named in the help text
- **Observed**: readInputTableForPipeline returns the numbers of a tsv file as text, so the two rows of one taxon with 4 and 2 add up to 102 ('4' + '2') and the normalized abundances of 4 and 3 are 0.5049 and 0.4951 (character codes) instead of 0.5714 and 0.4286
- **Expected**: the abundances are summed and normalized as numbers
- **Source lines**: 224, 258
- **Documented in**: `test/verifiedTests/analysis/testMultiSpeciesModelling/testTranslateMetagenome2AGORA.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/joinModelsPairwiseFromList.m`

#### Two models whose file names start with the same model name stop the function

- **Severity**: error
- **Trigger**: a modelFolder holding toyA.mat and toyA2.mat, with toyA in modelList
- **Observed**: the search by name prefix returns both files, models{findModID,1} expands to two arguments of contains, and the call stops with "Incorrect number of arguments"
- **Expected**: the file named exactly after the model is used
- **Source lines**: 111, 113-114, 139, 141-142, 157, 159-160
- **Documented in**: `test/verifiedTests/analysis/testMultiSpeciesModelling/testJoinModelsPairwiseFromList.m`

### `src/analysis/parsimoniousFBA/pFBA.m`

#### A call with one output stops with an error

- **Severity**: error
- **Trigger**: GeneClasses = pFBA(model), without skipclass
- **Observed**: the essential reactions are only computed for more than one output, but they are always stored in RxnClasses, which stops with "Unrecognized function or variable 'pFBAEssentialRxns'"
- **Expected**: the gene classes
- **Source lines**: 213
- **Documented in**: `test/verifiedTests/analysis/testpFBA/testpFBA.m`

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

### `src/analysis/rFBA/solveBooleanRegModel.m`

#### A name that is contained in a later name of the same rule stops with an error

- **Severity**: error
- **Trigger**: the rule 'g1 || g11' with the regulatory genes g1 and g11
- **Observed**: the names are replaced with strrep in the whole rule, so g11 becomes initialState(1)1 before it is replaced itself, and eval stops with a syntax error
- **Expected**: the value of the rule
- **Source lines**: 115
- **Documented in**: `test/verifiedTests/analysis/testrFBA/testSolveBooleanRegModel.m`

### `src/analysis/relaxedFBA/relaxedFBA.m`

#### A generic LP without rxns and mets stops with an error

- **Severity**: limitation
- **Trigger**: relaxedFBA(struct with A, b, c, lb, ub, csense and SIntRxnBool only)
- **Observed**: the feasibility check calls optimizeCbModel, whose model check stops with "The input model does have inconsistent fields", although the help says that mets and rxns are only required if SIntRxnBool is absent. The generic LP below therefore has mets and rxns.
- **Expected**: a relaxation of the generic LP
- **Source lines**: 704
- **Documented in**: `test/verifiedTests/analysis/testRelaxedFBA/testRelaxedFBA.m`

#### Extra variables given only by model.D stop with an error

- **Severity**: error
- **Trigger**: a model with the field D and without the fields C and E
- **Observed**: only a pair of C, D and E gets the third matrix filled with zeros, so the expansion of the model reads the absent field C and stops with "Unrecognized field name C"
- **Expected**: the missing C and E filled with zeros, as for the other combinations
- **Source lines**: 380
- **Documented in**: `test/verifiedTests/analysis/testRelaxedFBA/testRelaxedFBA.m`

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

### `src/analysis/sampling/ACHR/gpSampler.m`

#### A bias distribution stops with an error

- **Severity**: unusable-option
- **Trigger**: gpSampler(model, 10, bias, 1) with bias.method = 'uniform', bias.index = 1 and bias.param = [0.1 0.2]
- **Observed**: createHRWarmup loops over 1:size(bias.index), and a vector in a colon expression stops with "Colon operands must be real scalars" (MATLAB R2025a)
- **Expected**: warmup points and samples that follow the bias distribution
- **Source lines**: 176
- **Documented in**: `test/verifiedTests/analysis/testSampling/testGpSampler.m`

#### A problem given by A without S stops with an error

- **Severity**: error
- **Trigger**: gpSampler(struct('A', [1 1 -1], 'b', 0, 'lb', [0; 0; 0], 'ub', [1; 1; 2], 'csense', 'E'), 10)
- **Observed**: the warmup calls buildOptProblemFromModel, which reads .S and stops with "Unrecognized field name S"
- **Expected**: sampling of the space, since the help describes .A as the matrix of the problem and .S only as the replacement of an absent .A
- **Source lines**: 186
- **Documented in**: `test/verifiedTests/analysis/testSampling/testGpSampler.m`

#### The distributed sampler does not exist

- **Severity**: unusable-option
- **Trigger**: gpSampler(model, 10, [], 1, [], -1), a negative number of threads
- **Observed**: the help describes threads < 0 as the use of the distributed toolbox, but the function ACHRSamplerDistributedGeneral is not in the toolbox, so the call stops with an undefined function error
- **Expected**: sampling with the distributed toolbox
- **Source lines**: 205
- **Documented in**: `test/verifiedTests/analysis/testSampling/testGpSampler.m`

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

### `src/analysis/thermo/thermoFBA/addLoopLawConstraints.m`

#### A wrong input ends with an unassigned output

- **Severity**: error
- **Trigger**: MILPproblem = addLoopLawConstraints(LPproblem, model) with fewer variables than reactions, or a rxnIndex of the wrong size or out of bounds
- **Observed**: a message is displayed, then the caller gets an error because MILPproblem was not assigned; the comment in the source notes this
- **Expected**: an error that names the problem, or the output assigned
- **Source lines**: 94, 98, 102
- **Documented in**: `test/verifiedTests/analysis/testThermo/testAddLoopLawConstraints.m`

#### Method 3 without a vartype returns numbers instead of characters

- **Severity**: wrong-result
- **Trigger**: addLoopLawConstraints(LPproblem, model, rxnIndex, 3) with no LPproblem.vartype
- **Observed**: vartype starts as [] and character assignments store their codes, 67 and 66
- **Expected**: a character vector, as with methods 1 and 2
- **Source lines**: 333
- **Documented in**: `test/verifiedTests/analysis/testThermo/testAddLoopLawConstraints.m`

### `src/analysis/thermo/thermoFBA/cycleFreeFlux.m`

#### A solution of the relaxed problem under param.debug is dropped

- **Severity**: wrong-result
- **Trigger**: param.debug = 1 with a linear approach on an infeasible problem that the bounds relaxed by feasTol*10 make feasible
- **Observed**: it prints that a solution was found, then line 1076 sets v1 = [] with the warning that no solution was found, so the regularised approach is run instead
- **Expected**: the solution of the relaxed problem is returned
- **Source lines**: 1012, 1076
- **Documented in**: `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m`

#### Lower bounds are checked only when an upper bound is violated

- **Severity**: wrong-result
- **Trigger**: cycleFreeFlux with param.debug = 1 and a flux vector below a lower bound and within its upper bounds; or two flux vectors with an upper bound violated
- **Observed**: line 184 tests bool_ub instead of bool_lb, so a violated lower bound passes unnoticed, and a violated upper bound always gives the warning about lower bounds; line 183 compares with the whole matrix V0, not with v0
- **Expected**: each flux vector is checked against its lower bounds, as it is against the upper bounds
- **Source lines**: 183, 184
- **Documented in**: `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m`

#### The analysis of an infeasible problem under param.debug stops at its first step

- **Severity**: unusable-option
- **Trigger**: param.debug = 1 with a linear approach on a problem that stays infeasible when relaxed
- **Observed**: relaxedFBA stops in verifyModel, because the problem has no mets or rxns, so the rest of the analysis never runs
- **Expected**: the three relaxations and the printed measures of infeasibility
- **Source lines**: 1032-1072
- **Documented in**: `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m`

#### The objective bound of the lp approach is tightened when it should be relaxed

- **Severity**: wrong-result
- **Trigger**: param.approach = 'lp' with osenseStr 'min' and a positive objective value c0'*v0
- **Observed**: the constraint c0'*v <= (1 - feasTol)*c0'*v0 excludes v0, and the exchange fluxes are fixed, so the problem is infeasible and the regularised approach is used instead, with a warning
- **Expected**: the bound lets the flux vector keep its objective value
- **Source lines**: 802, 813
- **Documented in**: `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m`

#### The relaxedFBA fallback of the regularised approach can never succeed

- **Severity**: unusable-option
- **Trigger**: any regularised problem that gurobi finds infeasible, as a flux vector that takes up more than it excretes
- **Observed**: relaxedFBA stops in verifyModel, because qp has no mets or rxns, so the error is caught and no relaxed solution is ever used
- **Expected**: the relaxed solution is returned
- **Source lines**: 513-516, 518-520
- **Documented in**: `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m`

#### param.removeFixedBool = 1 stops the regularised approach

- **Severity**: error
- **Trigger**: param.approach = 'regularised' with param.removeFixedBool = 1; or param.approach = 'lp0' with it and non-zero exchange fluxes, which is infeasible and falls back on regularised
- **Observed**: error "Unrecognized function or variable 'fixedBool'", which only the two linear approaches define
- **Expected**: the option has no effect on the regularised approach, or removes its fixed variables
- **Source lines**: 991
- **Documented in**: `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m`

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

### `src/analysis/topology/extremeRays/lrs/extremePools.m`

#### A model with mets but no usable SIntRxnBool stops on an undefined variable

- **Severity**: error
- **Trigger**: extremePools(model) with model.mets and without model.SIntRxnBool or model.SIntMetBool, or with either of them of the wrong length
- **Observed**: error "Unrecognized function or variable 'printLevel'": findSExRxnInd is called with printLevel-1, and printLevel is never defined
- **Expected**: the exchange reactions are found heuristically, as the comments say, and the extreme pools are returned
- **Source lines**: 55, 62
- **Documented in**: `test/verifiedTests/analysis/testTopology/testExtremePools.m`

#### The third output is the transpose of what the help text states

- **Severity**: cosmetic
- **Trigger**: any call, for example [P, vertexBool, N] = extremePools(model) with model.SConsistentRxnBool
- **Observed**: N is the n x m matrix S', and P*N' = 0 holds
- **Expected**: the help text states an m x n matrix N such that P*N = 0
- **Source lines**: 44
- **Documented in**: `test/verifiedTests/analysis/testTopology/testExtremePools.m`

### `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m`

#### glpk, one of the solvers the routine falls back on, cannot run the search

- **Severity**: error
- **Trigger**: greedyExtremeRayBasis with glpk as the solver and any LP to solve, for example param.solver = 'glpk' on a model without a supplied complete basis
- **Observed**: below printLevel 2 the negative param.printLevel-2 stops glpk with "glpkcc: param.msglev must be 0 ...", and at any level contains(sol.origStat, 'WARNING') stops with "First argument must be text", because the origStat of glpk is a number
- **Expected**: the search runs with glpk; the sections here use glpk only where no search with it is needed
- **Source lines**: 650, 1018, 1167
- **Documented in**: `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m`

### `src/analysis/topology/findCyclicRxns.m`

#### The first output is not a per-reaction boolean

- **Severity**: wrong-result
- **Trigger**: any call, for example findCyclicRxns(model, 0) with ecoli_core_model
- **Observed**: cyclicRxnBool = Z' * ones(n, 1) sums the entries of each null-space basis vector, giving a (n - rank(S)) x 1 vector of real numbers (28 x 1 for ecoli_core_model), not one value per reaction
- **Expected**: an n x 1 logical vector, true for the reactions in the support of the null space (part of a stoichiometrically balanced cycle), as the help text states
- **Source lines**: 24
- **Documented in**: `test/verifiedTests/analysis/testTopology/testFindCyclicRxns.m`

### `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m`

#### A reaction with an elemental mismatch stops the build instead of being skipped

- **Severity**: error
- **Trigger**: an RXN file with an atom transition between two elements
- **Observed**: the reaction is reported as skipped, then the unfilled rows of the edge table stop digraph at line 382 with an error about the edge table
- **Expected**: the reaction is skipped, as the message says and as for an RXN file that cannot be parsed, and the graphs are built from the others
- **Source lines**: 325, 368
- **Documented in**: `test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m`

#### Decompartmentalising the model keeps the opening bracket

- **Severity**: wrong-result
- **Trigger**: model.mets with compartments, as in 'a[c]', and RXN files without, as in 'a'
- **Observed**: model.mets{i}(1:end-2) turns 'a[c]' into 'a[', which matches no atom
- **Expected**: 'a[c]' becomes 'a', the three characters of the compartment removed, as for the atoms at line 275
- **Source lines**: 206, 207
- **Documented in**: `test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m`

#### The bond graph is not decompartmentalised

- **Severity**: error
- **Trigger**: model.mets without compartments, RXN files with compartments, and options.bondTransitionMultigraph = 1
- **Observed**: the atoms are decompartmentalised for the atom graph only, so no atom of the bonds is found, every reaction is skipped and digraph stops at line 771
- **Expected**: the bond graph is built as the atom graph is; the option 0 works
- **Source lines**: 771
- **Documented in**: `test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m`

### `src/analysis/topology/reactingMoieties/checkABRXNFiles.m`

#### Decompartmentalising the model keeps the opening bracket

- **Severity**: wrong-result
- **Trigger**: model.mets with compartments, as in 'a[c]', and RXN files without, as in 'a'
- **Observed**: model.mets{j}(1:end-2) turns 'a[c]' into 'a[', which matches no atom, so every reaction fails the stoichiometry check and modelOut.mets is corrupted
- **Expected**: 'a[c]' becomes 'a', the three characters of the compartment removed, as for the atoms at line 182
- **Source lines**: 140, 141
- **Documented in**: `test/verifiedTests/analysis/testReactingMoieties/testCheckABRXNFiles.m`

#### The duplicates that stop the check are not shown

- **Severity**: cosmetic
- **Trigger**: a model with a repeated metabolite or reaction identifier
- **Observed**: setdiff(model.mets, unique(model.mets)) is always empty, so nothing is displayed before the error
- **Expected**: the repeated identifiers are displayed
- **Source lines**: 65, 69
- **Documented in**: `test/verifiedTests/analysis/testReactingMoieties/testCheckABRXNFiles.m`

### `src/analysis/topology/reactingMoieties/identifyAtomEquivalenceClasses.m`

#### The check for a duplicate bond never fires

- **Severity**: limitation
- **Trigger**: identifyAtomEquivalenceClasses([1; 2], {'C'; 'C'}, [1; 1], [2; 2], [1; 1], 'met') with two bonds between one atom pair
- **Observed**: graph keeps parallel edges, so numedges(G) always equals numel(headAtoms); classes are returned without the warning
- **Expected**: the input is detected as a duplicate bond and the function falls back to the identity map with a warning
- **Source lines**: 110
- **Documented in**: `test/verifiedTests/analysis/testReactingMoieties/testIdentifyAtomEquivalenceClasses.m`

### `src/analysis/topology/reactingMoieties/readABRXNFile.m`

#### The two warnings about transition numbers print a literal backslash n

- **Severity**: cosmetic
- **Trigger**: an RXN file whose substrate or product transition numbers are not 1:q
- **Observed**: warning text ending in the two characters \n, because a one-argument warning does not process escapes
- **Expected**: a warning ending at the full stop
- **Source lines**: 231, 234
- **Documented in**: `test/verifiedTests/analysis/testReactingMoieties/testReadABRXNFile.m`

#### options.readBonds = 0 cannot be used

- **Severity**: unusable-option
- **Trigger**: readABRXNFile(rxnfileName, rxnfileDirectory, struct('readBonds', 0)) with any RXN file
- **Observed**: error 'Unrecognized field name "Properties"': the code after the branch that sets bonds to [] builds a structure and then reads bonds.Properties
- **Expected**: the atom table is returned and the bond table is not read, as the help text states
- **Source lines**: 260
- **Documented in**: `test/verifiedTests/analysis/testReactingMoieties/testReadABRXNFile.m`

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

### `src/base/generateSystemConfigReport.m`

#### A short answer from curl stops the report at the summary

- **Severity**: error
- **Trigger**: a curl command whose output of --version has fewer than three words
- **Observed**: the warning at line 66 leaves result_curlVersion undefined, so line 95 stops the function with an undefined-variable error, with the diary still on and the current folder left at the toolbox root
- **Expected**: the report finishes and shows that the curl version is not known
- **Source lines**: 65-66
- **Documented in**: `test/verifiedTests/base/testTools/testGenerateSystemConfigReport.m`

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

### `src/base/io/convertCNAModelToCbModel.m`

#### Without CellNetAnalyzer an output is never assigned

- **Severity**: error
- **Trigger**: model = convertCNAModelToCbModel(cnaModel) when CellNetAnalyzer is not installed
- **Observed**: MATLAB stops with "Output argument model not assigned"; only with no output requested does the call return, after the message of checkCNAinstallation
- **Expected**: an error that says CellNetAnalyzer is needed
- **Source lines**: 31
- **Documented in**: `test/verifiedTests/base/testIO/testConvertCNAModelToCbModel.m`

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

### `src/base/io/utilities/readSBML.m`

#### The documented default of defaultBound does not exist

- **Severity**: error
- **Trigger**: readSBML(fileName), without the optional input defaultBound
- **Observed**: the call stops with "Not enough input arguments" where the bound is first used
- **Expected**: the default of 1000 given in the help text
- **Source lines**: 310
- **Documented in**: `test/verifiedTests/base/testIO/testReadSBML.m`

### `src/base/io/utilities/writeSBML.m`

#### A model without reactions cannot be written

- **Severity**: error
- **Trigger**: a model whose bounds are empty, the case that the branch at line 449 is there for
- **Observed**: OutputSBML stops with "Cannot copy static.fbc_association field"
- **Expected**: an SBML file without reactions
- **Source lines**: 449
- **Documented in**: `test/verifiedTests/base/testIO/testWriteSBML.m`

#### The compartments of the model and the given lists are replaced by the defaults

- **Severity**: wrong-result
- **Trigger**: writeSBML(model, fileName) for a model with comps and compNames, or lists given for a model without compNames and without comps
- **Observed**: line 55 overwrites both fields with getDefaultCompartments, so a compartment that is not a default gets the warning "Unknown compartment" and a made-up name
- **Expected**: the compartments and names of the model or of the lists
- **Source lines**: 55
- **Documented in**: `test/verifiedTests/base/testIO/testWriteSBML.m`

#### The model annotation cannot be written

- **Severity**: error
- **Trigger**: a model with the field modelAnnotation
- **Observed**: a cell array of strings stops in OutputSBML with "model annotation field incorrect type"; a char, which is what readSBML returns, is split into one paragraph per character
- **Expected**: the annotation written as a whole
- **Source lines**: 160-162, 164-165
- **Documented in**: `test/verifiedTests/base/testIO/testWriteSBML.m`

### `src/base/io/writeCbModel.m`

#### The JSON format is not detected from the file extension

- **Severity**: unusable-option
- **Trigger**: a .json file name without an explicit format, writeCbModel(model, 'x.json'), or writeCbModel(model, 'format', 'json') with the name picked in the dialog
- **Observed**: getFormatFromExtension does not know .json, so the call stops with "Unknown file format"; an explicit format together with a file name works
- **Expected**: the same JSON file as with the explicit format
- **Source lines**: 177-178
- **Documented in**: `test/verifiedTests/base/testIO/testWriteCbModel.m`

#### The file dialog offers an MPS export that does not exist

- **Severity**: unusable-option
- **Trigger**: a .MPS file name without an explicit format, which the dialog offers as MPS Export
- **Observed**: the extension is mapped to the format mps, which has no writer, so the call stops with "Unknown file format"
- **Expected**: an MPS file, or no such choice in the dialog
- **Source lines**: 280-281
- **Documented in**: `test/verifiedTests/base/testIO/testWriteCbModel.m`

### `src/base/parseMetNames.m`

#### Mixed or longer compartment notations are not parsed

- **Severity**: limitation
- **Trigger**: a list that mixes name[c] and name(c), names without brackets, or a compartment symbol longer than one character
- **Observed**: the last pattern is used: the whole text is the base name and the compartment is empty
- **Expected**: name and compartment separated
- **Source lines**: 36-38
- **Documented in**: `test/verifiedTests/base/testTools/testParseMetNames.m`

### `src/base/removeGeneVersions.m`

#### A model without grRules stops after the warning

- **Severity**: error
- **Trigger**: a model with genes but without the field grRules
- **Observed**: the warning at line 46 suggests that the call goes on, but with no rule to build from, generateRules (called at line 70) stops with an error from setdiff
- **Expected**: the genes stripped of their versions, and empty rules
- **Source lines**: 46
- **Documented in**: `test/verifiedTests/base/testRemoveGeneVersions/testRemoveGeneVersions.m`

### `src/base/solvers/buildOptProblemFromModel.m`

#### A model with extra columns and no coupling rows gets no csense in its problem

- **Severity**: error
- **Trigger**: a model with the fields E, evarlb, evarub, evarc but without C
- **Observed**: optProblem has no field csense, and a solver call stops on the missing field
- **Expected**: optProblem.csense = model.csense, as in the other three branches
- **Source lines**: 212-217
- **Documented in**: `test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m`

#### Missing coupling and extra-variable fields are never built

- **Severity**: error
- **Trigger**: a model with C but without d or dsense, or with E but without evarlb, evarub or evarc
- **Observed**: the test length(unique([toBuild, fields])) == length(fields) is always true, so the list of fields to build is always cleared and the call stops on the missing field
- **Expected**: the missing fields created by createEmptyFields
- **Source lines**: 155-161
- **Documented in**: `test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m`

#### The form QRQP keeps the csense of the model only

- **Severity**: error
- **Trigger**: param.solveWBMmethod = QRQP
- **Observed**: the matrix has one row per metabolite and one per variable, but csense keeps one entry per metabolite, and it drops the coupling rows
- **Expected**: csense with one entry per row of A, as in the form QRLP
- **Source lines**: 303
- **Documented in**: `test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m`

#### The forms QRLP and QRQP lose the bounds of the extra variables

- **Severity**: wrong-result
- **Trigger**: param.solveWBMmethod = QRLP or QRQP for a model with E
- **Observed**: lb, ub and c are rebuilt from model.lb, model.ub and model.c, so they are shorter than the number of columns of A
- **Expected**: vectors with one entry per column of A
- **Source lines**: 255-256, 258, 301-302, 304
- **Documented in**: `test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m`

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

### `src/base/solvers/getSetSolver/changeCobraSolver.m`

#### A call without input stops instead of listing the defined solvers

- **Severity**: error
- **Trigger**: changeCobraSolver() without input
- **Observed**: line 174 reads solverName before any input check, so the call stops with Not enough input arguments and the listing of the defined solvers can never run
- **Expected**: the list of the solvers defined in CBT_*_SOLVER
- **Source lines**: 174, 252-265
- **Documented in**: `test/verifiedTests/base/testSolvers/testChangeCobraSolver.m`

#### A failed validation with printLevel above 0 keeps the failed solver selected

- **Severity**: wrong-result
- **Trigger**: a solver that fails the validation solve, with printLevel above 0, for example changeCobraSolver('pdco', 'MILP')
- **Observed**: the error is rethrown before the old solver and the warning state are restored, so the failed solver stays selected and warnings stay off
- **Expected**: the selection and the warning state of before the call, as with printLevel 0
- **Source lines**: 530-531, 553-558
- **Documented in**: `test/verifiedTests/base/testSolvers/testChangeCobraSolver.m`

#### The problem type is matched as a substring

- **Severity**: wrong-result
- **Trigger**: a problem type that contains the name of a type of the solver, for example pdco with MILP
- **Observed**: contains accepts MILP for a solver of LP problems, so the solver reaches the validation solve and the call stops there, with a message from the solver interface
- **Expected**: the message that the solver cannot solve the problem type, as at line 381
- **Source lines**: 364, 376
- **Documented in**: `test/verifiedTests/base/testSolvers/testChangeCobraSolver.m`

### `src/base/solvers/isCompatible.m`

#### The distributed compatibility matrix is not understood by the parser

- **Severity**: wrong-result
- **Trigger**: any call, with documentation/source/installation/compatMatrix.rst as distributed
- **Observed**: the file is a reStructuredText list-table, the parser only reads grid tables whose rows start with a vertical bar, so every solver gets status 2 (unverified)
- **Expected**: the status of the table: 1 for the solvers marked as tested
- **Source lines**: 98-116
- **Documented in**: `test/verifiedTests/base/testSolvers/testIsCompatible.m`

### `src/base/solvers/mosek/setMosekParam.m`

#### The strict option never switches MOSEK to a free solve form

- **Severity**: wrong-result
- **Trigger**: param.strict non-empty with a cobra profile
- **Observed**: the interior-point solve form is already set to MSK_SOLVE_PRIMAL earlier in the same profile, so the test for an absent solve form in the strict block is never true and MSK_SOLVE_FREE is never set
- **Expected**: a strict solve uses MSK_SOLVE_FREE, as the header of the function states
- **Source lines**: 541-549
- **Documented in**: `test/verifiedTests/base/testSolvers/testSetMosekParam.m`

### `src/base/solvers/rescale/liftCouplingConstraints.m`

#### A row with more than two variables cannot be lifted with the default options

- **Severity**: error
- **Trigger**: an inequality row with more than two variables and a large coefficient, with equalities false (the default), for example C = [1, 1, -1000000] with dsense L
- **Observed**: the split of the row adds equality rows, so the check that follows stops with equality dsense at 1 positions, although the original constraint is an inequality
- **Expected**: the row lifted, as the option equalities only concerns original constraints
- **Source lines**: 245, 331-333
- **Documented in**: `test/verifiedTests/base/testLifting/testLiftCouplingConstraints.m`

#### The model identifier gets two suffixes

- **Severity**: cosmetic
- **Trigger**: a model with the field modelID
- **Observed**: the identifier toy becomes toy_lifted_liftedCouplingConstraints
- **Expected**: toy_liftedCouplingConstraints, as documented
- **Source lines**: 186, 423
- **Documented in**: `test/verifiedTests/base/testLifting/testLiftCouplingConstraints.m`

### `src/base/solvers/solveCobraLP.m`

#### The option lifting stops on an undefined variable

- **Severity**: unusable-option
- **Trigger**: solverParams.lifting = 1
- **Observed**: line 184 passes printLevel, which does not exist in this function, so the call stops with Unrecognized function or variable printLevel
- **Expected**: the problem reformulated with problemTypeParams.printLevel
- **Source lines**: 183-184
- **Documented in**: `test/verifiedTests/base/testSolvers/testSolveCobraLP.m`

### `src/base/solvers/solveCobraMILP.m`

#### The legacy mps interface returns no output

- **Severity**: error
- **Trigger**: solution = solveCobraMILP(problem) with the solver mps
- **Observed**: the function returns before solution is assigned, so the call stops with Output argument solution not assigned, after the file was written
- **Expected**: an empty solution, as in solveCobraLP
- **Source lines**: 469
- **Documented in**: `test/verifiedTests/base/testSolvers/testSolveCobraMILP.m`

#### gurobi does not accept an empty csense

- **Severity**: error
- **Trigger**: MILPproblem.csense empty, with the solver gurobi
- **Observed**: the default senses go to the local csense, while the problem passed to gurobi keeps the empty field, so gurobi stops with Incorrect size(model.sense)
- **Expected**: equalities, as with glpk
- **Source lines**: 351-352, 375
- **Documented in**: `test/verifiedTests/base/testSolvers/testSolveCobraMILP.m`

### `src/base/solvers/solveCobraMIQP.m`

#### The option saveInput stops the call

- **Severity**: unusable-option
- **Trigger**: the parameter saveInput
- **Observed**: the function saves a variable MILPproblem, while its input is MIQPproblem, so the call stops with Variable MILPproblem not found
- **Expected**: MIQPproblem saved to the file, and the solve going on
- **Source lines**: 107-112
- **Documented in**: `test/verifiedTests/base/testSolvers/testSolveCobraMIQP.m`

### `src/base/solvers/solveCobraQP.m`

#### A nonconvex QP solved to optimality by gurobi stops the function

- **Severity**: error
- **Trigger**: a QP with an indefinite F, with the default gurobi parameter NonConvex
- **Observed**: gurobi returns OPTIMAL from its global search without duals, so reading resultgurobi.pi stops with Unrecognized field name pi
- **Expected**: the solution returned with empty duals, or an explicit message
- **Source lines**: 679
- **Documented in**: `test/verifiedTests/base/testSolvers/testSolveCobraQP.m`

#### The qpng interface reads the problem after it was cleared

- **Severity**: error
- **Trigger**: the solver qpng
- **Observed**: QPproblem is cleared at line 178 for every solver except three, so line 368 stops with Reference to a cleared variable QPproblem
- **Expected**: the qpng branch uses the local A, b, c, F, lb and ub, or QPproblem is kept
- **Source lines**: 178, 363-376
- **Documented in**: `test/verifiedTests/base/testSolvers/testSolveCobraQP.m`

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

### `src/base/solvers/verifyCobraProblem.m`

#### A NaN in x stops a call with more than one output

- **Severity**: error
- **Trigger**: verifyCobraProblem(problem, x) with a NaN in x and two or more outputs
- **Observed**: the function returns before invalidConstraints and invalidVars are assigned, so the call stops with an unassigned output argument
- **Expected**: status -1 with empty invalidConstraints and invalidVars
- **Source lines**: 310-319
- **Documented in**: `test/verifiedTests/base/testSolvers/testVerifyCobraProblem.m`

#### invalidConstraints names the wrong rows when senses are mixed

- **Severity**: wrong-result
- **Trigger**: an x that violates a row of a problem whose csense mixes E, L and G
- **Observed**: the mask computed on the rows of one sense indexes the vector of all rows, so the violated rows are reported at their position among the rows of that sense
- **Expected**: the row numbers of the violated rows in A
- **Source lines**: 335, 341, 347
- **Documented in**: `test/verifiedTests/base/testSolvers/testVerifyCobraProblem.m`

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

### `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m`

#### A reaction listed three times stops the constraint step

- **Severity**: error
- **Trigger**: rxns2constrain or mediaData with one reaction in three or more rows
- **Observed**: idx2delete(c) = idR(1:end - 1) assigns several numbers to one element and the call stops with "Unable to perform assignment"
- **Expected**: the repeated rows removed as they are for two rows
- **Source lines**: 1203
- **Documented in**: `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m`

#### A tiny bound of the unusual sign changes sign

- **Severity**: wrong-result
- **Trigger**: a positive lower bound or a negative upper bound below boundPrecisionLimit in absolute value
- **Observed**: lb = 1e-7 becomes -boundPrecisionLimit and ub = -1e-7 becomes +boundPrecisionLimit, which opens the reaction in a direction it was closed for; extra variables keep their sign
- **Expected**: the sign kept, as lines 1361-1371 do for extra variables
- **Source lines**: 1341, 1348
- **Documented in**: `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m`

#### An unknown varID stops the mode allConstraints on a model without extra variables

- **Severity**: error
- **Trigger**: mode allConstraints, no extra variables, several exoMet rows and one that is not a reaction of the model
- **Observed**: false(numel(exo.varID)) is a square matrix, so the mask indexes outside the table and the call stops with "The logical indices contain a true value outside of the array bounds"
- **Expected**: the entry reported and ignored, as it is with extra variables
- **Source lines**: 650-651, 655
- **Documented in**: `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m`

#### The default eta is below the noise of the fit

- **Severity**: limitation
- **Trigger**: an exometabolomic or allConstraints fit with the default eta, solved by gurobi
- **Observed**: the fit leaves relaxations of about 2e-5 on bounds that need none. They exceed eta = 1e-5, count as relaxed, and such a measured bound stays at its model value instead of mean +/- SD. The sections below that need the bounds exact set eta = 1e-3
- **Expected**: an eta that separates a relaxation from the tolerance of the QP
- **Source lines**: 112, 441-442, 1020-1023
- **Documented in**: `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m`

#### The fitted exometabolomic relaxation is not applied to a feasible model

- **Severity**: wrong-result
- **Trigger**: mode exometabolomicConstraints, a feasible model and a measured flux outside its bounds, so that the fit relaxes a bound
- **Observed**: modelFitted is a plain copy of the model and only an infeasible model gets the bounds lb - p and ub + q. The relaxation is reported but the bound stays, and the bound opposite to it moves to the fitted flux, which can stop the call with "lower bounds greater than upper bounds"
- **Expected**: the relaxed bounds in modelFitted before the feasibility check, as the mode allConstraints does
- **Source lines**: 395
- **Documented in**: `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m`

#### The message about a feasible fit is never printed

- **Severity**: cosmetic
- **Trigger**: any fit whose model is feasible
- **Observed**: fprintf('%\n', text) has no conversion for the text, so an empty line is printed at every printLevel
- **Expected**: fprintf('%s\n', text) under printLevel > 0
- **Source lines**: 400, 963
- **Documented in**: `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m`

#### The mode allConstraints needs the extra variable fields it treats as optional

- **Severity**: error
- **Trigger**: mode allConstraints with a model without the field evarlb
- **Observed**: the call stops with "Unrecognized field name evarlb" although nExt = 0 is handled earlier; the test passes empty evars, evarNames, evarlb and evarub to reach those lines
- **Expected**: a model without extra variables fitted like any other
- **Source lines**: 954-955
- **Documented in**: `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m`

#### The session display format is changed

- **Severity**: cosmetic
- **Trigger**: any call that reaches the bound correction
- **Observed**: format long g stays in force after the call returns
- **Expected**: the display format left as it was
- **Source lines**: 1244
- **Documented in**: `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m`

### `src/dataIntegration/chemoInformatics/deleteProtons.m`

#### Reactions that carried only protons are removed from the reaction fields but not from S

- **Severity**: wrong-result
- **Trigger**: a model with a reaction whose only metabolites are protons, such as a proton transport
- **Observed**: the reaction is removed from rxns, lb, ub and the other reaction vectors, but its column stays in S and rxnGeneMat as zeros, so the number of columns of S no longer equals the number of reactions
- **Expected**: the column deleted from S and rxnGeneMat as well, as the help says the output has no proton transport reactions
- **Source lines**: 43, 45, 50
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testDeleteProtons.m`

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

### `src/dataIntegration/metaboAnnotator/buildMetStruct/convertModel2Metstructure.m`

#### A metabolite with a hyphen is overwritten by its next compartment

- **Severity**: wrong-result
- **Trigger**: a metabolite abbreviation with a hyphen in more than one compartment
- **Observed**: the check for an existing entry uses the name with the hyphen but the entry is stored with an underscore, so the last occurrence overwrites the entry (originalID a-b[e], not a-b[c])
- **Expected**: the first occurrence defines the entry, as for all other metabolites
- **Source lines**: 36, 38
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testConvertModel2Metstructure.m`

### `src/dataIntegration/metaboAnnotator/connect2resources/convertOld2NewHMDB.m`

#### Identifiers of 12 or more characters give an empty result

- **Severity**: limitation
- **Trigger**: an identifier with 12 or more characters, for example HMDB00012345
- **Observed**: the result is an empty text instead of the identifier
- **Expected**: the identifier returned unchanged or an error
- **Source lines**: 19-28
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testConvertOld2NewHMDB.m`

### `src/dataIntegration/metanetxMapper/metanetxMapper.m`

#### Name search stops with an error when the search replies have the same field order

- **Severity**: error
- **Trigger**: a name search with more than one result whose JSON objects list their fields in the same order, which webread then returns as a struct array instead of a cell array
- **Observed**: the brace index response{1} stops with "Brace indexing is not supported"
- **Expected**: the first result taken from a struct array as well as from a cell array
- **Source lines**: 137
- **Documented in**: `test/verifiedTests/dataIntegration/testMetanetxMapper/testMetanetxMapper.m`

### `src/dataIntegration/transcriptomics/MOOMIN/writeMoominOutput.m`

#### The json format writes colour names without quotes

- **Severity**: wrong-result
- **Trigger**: format json with the default colours as strings
- **Observed**: the file reads {"rxn1": red, "rxn2": blue, "rxn3": yellow}, which is not valid JSON; the reference file ref_test_json.out, from the original test, holds the same text
- **Expected**: quoted values, {"rxn1": "red", "rxn2": "blue", "rxn3": "yellow"}
- **Source lines**: 140-141, 148-149
- **Documented in**: `test/verifiedTests/dataIntegration/testMOOMIN/testWriteMoominOutput.m`

### `src/dataIntegration/transcriptomics/preprocessing/selectGeneFromGPR.m`

#### With minSum the reported gene does not belong to the selected alternative

- **Severity**: wrong-result
- **Trigger**: minSum set and a rule with an alternative that has more than one gene before the selected alternative, for example (g1 and g2) or g3 with g3 selected
- **Observed**: the list of candidate genes has one entry per gene while the list of values has one entry per alternative, so the position of the minimum points into the wrong list entry (here g2 is reported instead of g3)
- **Expected**: the gene of the selected alternative
- **Source lines**: 44-49
- **Documented in**: `test/verifiedTests/dataIntegration/testPreprocessing/testSelectGeneFromGPR.m`

### `src/design/GDLS.m`

#### A single knockout cost in the model stops with an error

- **Severity**: error
- **Trigger**: model.koCost with one value and no koCost option
- **Observed**: length(possibleKOList,1) has one input too many, which is an error
- **Expected**: the same cost for every candidate
- **Source lines**: 131
- **Documented in**: `test/verifiedTests/design/testGDLS/testGDLS.m`

#### Options in a structure, or no options at all, stop with an error

- **Severity**: error
- **Trigger**: GDLS(model, options, options) or GDLS(model, targetRxns), once an iteration has been solved
- **Observed**: i is only assigned by the loop over the option pairs (or the gene-set loop), so the field name of gdlsSolutionStructs stops with "Unrecognized function or variable 'i'"
- **Expected**: the options of the structure are used, and the defaults without options
- **Source lines**: 298
- **Documented in**: `test/verifiedTests/design/testGDLS/testGDLS.m`

#### The koCost option cannot be used

- **Severity**: unusable-option
- **Trigger**: the option koCost
- **Observed**: without model.koCost the check on model.koCost stops with an error, a single value in model.koCost fails as in the defect above, and a vector in model.koCost replaces the option
- **Expected**: the costs of the option are used
- **Source lines**: 138-139, 141
- **Documented in**: `test/verifiedTests/design/testGDLS/testGDLS.m`

#### The per-solution field name has no number

- **Severity**: limitation
- **Trigger**: more than one design in an iteration (option M = 2)
- **Observed**: the format 'solution_%2' has no conversion, so all the designs of an iteration share the field solution_ and only the last one is kept in gdlsSolutionStructs
- **Expected**: one field per design
- **Source lines**: 298-300
- **Documented in**: `test/verifiedTests/design/testGDLS/testGDLS.m`

#### The solution values of all the designs are those of the last knockout set

- **Severity**: wrong-result
- **Trigger**: more than one final design (option M = 2 on the toy model of this test), or a last MILP solution that was rejected as inconsistent
- **Observed**: the final loop does not set model.rxnsPresent for each design, so biomass, minTargetProd and maxTargetProd are those of the last knockout set that was tried: the toy model reports a biomass of 10 and 10 for the designs without knockouts and with R1
- **Expected**: the values of each design (a biomass of 20 and 10 on the toy model)
- **Source lines**: 315-318
- **Documented in**: `test/verifiedTests/design/testGDLS/testGDLS.m`

### `src/design/OptKnock.m`

#### A model with coupling constraints stops with an error

- **Severity**: error
- **Trigger**: a model with the field C, for which line 60 announces that C is ignored
- **Observed**: the conversion with OrderReactions multiplies C by a column of reaction directions (convertToIrreversible, line 182), which fails with 'Unable to perform assignment because the indices on the left side are not compatible'
- **Expected**: the warning, then the problem without the coupling constraints
- **Source lines**: 112
- **Documented in**: `test/verifiedTests/design/testOptKnock/testOptKnock.m`

#### Without constrOpt the inner growth maximisation is lost

- **Severity**: wrong-result
- **Trigger**: a solved OptKnock call without constrOpt, or with a constrOpt that omits the biomass reaction; for the anaerobic model of this test, OptKnock(model, smallRxnList, smallOptions)
- **Observed**: createBilevelMILPproblem puts the inner objective into the dual only for the reactions of constrOpt, so the status is optimal with 33.78 of EX_succ(e), no knockouts and a growth of 0, although the strain without knockouts grows at 0.516 and makes no EX_succ(e)
- **Expected**: the production at the maximal growth of the knockout strain; the empty default of constrOpt is documented as optional. Only the problem building of this input is tested.
- **Source lines**: 86-89
- **Documented in**: `test/verifiedTests/design/testOptKnock/testOptKnock.m`

### `src/design/TrimGdel/modelSetting.m`

#### A model without rev gets rev as a row vector

- **Severity**: wrong-result
- **Trigger**: modelSetting(model, targetMet) on a model without the field rev and a target metabolite without EX_ or DM_ reaction, for example iAF1260 with btn_c
- **Observed**: model2.rev(n) = 0 creates rev as a 1 x n row of zeros, while every other reaction field has one row per reaction
- **Expected**: rev, if created at all, as an n x 1 column (or the deprecated field not created)
- **Source lines**: 56
- **Documented in**: `test/verifiedTests/design/testTrimGdel/testModelSetting.m`

### `src/design/multiProductionEnvelope.m`

#### An unbounded minimum is stored in the upper bounds

- **Severity**: error
- **Trigger**: a target whose minimum is unbounded, which needs a carbon uptake with an infinite lower bound left in the list by the defect above
- **Observed**: targetUpperBounds is set to Inf and targetLowerBounds gets no value, so the two differ in size and plot stops with 'Specify the coordinates as vectors or matrices'
- **Expected**: targetLowerBounds is set to -Inf
- **Source lines**: 119-120
- **Documented in**: `test/verifiedTests/design/testMultiProductionEnvelope.m`

#### The wrong reaction is removed when a later substrate is next to the end of the list

- **Severity**: wrong-result
- **Trigger**: a second or later substrate at position n - 1 of the n carbon exchange reactions, for example ecoli_core_model with EX_pyr(e) lower bound -1
- **Observed**: the test j == length(CExcRxns) compares the original position with the length of the list that already lost a substrate, so the last entry is removed: EX_pyr(e) stays in the list and EX_succ(e) is dropped
- **Expected**: EX_pyr(e) is removed and EX_succ(e) stays
- **Source lines**: 77-78
- **Documented in**: `test/verifiedTests/design/testMultiProductionEnvelope.m`

### `src/design/optEnvelope/optEnvelope.m`

#### The mid output is not assigned without mid points

- **Severity**: error
- **Trigger**: [main, mid] = optEnvelope(model, product), that is midPoints 0 and two outputs
- **Observed**: the call ends with 'Output argument "mid" (and possibly others) not assigned'
- **Expected**: an empty mid output
- **Source lines**: 280
- **Documented in**: `test/verifiedTests/design/testOptEnvelope/testOptEnvelope.m`

#### The numKO option always stops with an error

- **Severity**: unusable-option
- **Trigger**: the option numKO
- **Observed**: milpOEReinserts ends with debug code: addEnv gets the biomass reaction as a cell and stops with 'The value of biomass is invalid', before any knockouts are returned
- **Expected**: the knockouts found by the MILP are returned
- **Source lines**: 211
- **Documented in**: `test/verifiedTests/design/testOptEnvelope/testOptEnvelope.m`

#### With prodMol the peaks of the mid envelopes are zero

- **Severity**: wrong-result
- **Trigger**: the options prodMol and midPoints together
- **Observed**: mem is only filled when prodMol is not given, so mid.peak.x and mid.peak.y are 0
- **Expected**: the peaks of the mid envelopes in yield units
- **Source lines**: 240
- **Documented in**: `test/verifiedTests/design/testOptEnvelope/testOptEnvelope.m`

### `src/design/optForce/optForce.m`

#### A progress message of the option loop is written to the report file

- **Severity**: error
- **Trigger**: optForce(..., 'loop', 1, 'k', 3, 'printLevel', 1, 'printReport', 0) on a problem without solution
- **Observed**: the message "increasing k" of the printLevel branch uses freport, which does not exist without a report: "Unrecognized function or variable 'freport'"; with a report the message goes to the report instead of the console
- **Expected**: the message is printed to the console
- **Source lines**: 548
- **Documented in**: `test/verifiedTests/design/testOptForce/testOptForce.m`

#### A wrong exclusion type leaves the report open and the folder changed

- **Severity**: cosmetic
- **Trigger**: excludedRxns with a typeReg other than U, D, K or A
- **Observed**: the error is raised with the report still open and the run folder as current folder
- **Expected**: the report is closed and the starting folder restored
- **Source lines**: 887
- **Documented in**: `test/verifiedTests/design/testOptForce/testOptForce.m`

#### The documented exclusion type D is not recognised when the inputs are recorded

- **Severity**: cosmetic
- **Trigger**: excludedRxns with typeReg D
- **Observed**: the problem excludes the reaction, but excludedLRxns.mat stays empty and the report says "Excluded from D". The recording expects L, which the problem builder rejects with an error
- **Expected**: one letter for downregulations throughout, D as documented
- **Source lines**: 347, 365-366, 876-881
- **Documented in**: `test/verifiedTests/design/testOptForce/testOptForce.m`

#### The option loop solves the same problem in each pass

- **Severity**: wrong-result
- **Trigger**: optForce(..., 'loop', 1, 'k', 3, 'kMin', 1)
- **Observed**: the passes count currentK from kMin to k, but the problem and the saved inputs are built with k, so sets smaller than k are not searched for
- **Expected**: each pass builds the problem and sizes the results with currentK interventions
- **Source lines**: 385-386, 395-398, 403
- **Documented in**: `test/verifiedTests/design/testOptForce/testOptForce.m`

#### The option loop stops with an error as soon as a set is found

- **Severity**: unusable-option
- **Trigger**: optForce(..., 'loop', 1) on a problem that has a solution
- **Observed**: analyzeOptForceSol is called without biomassRxn, so the solution structure takes its place and the call stops with "OptForce: input biomassRxn must be an string"
- **Expected**: the sets are returned as without loop: analyzeOptForceSol(model, targetRxn, biomassRxn, solution)
- **Source lines**: 407-445, 452-535
- **Documented in**: `test/verifiedTests/design/testOptForce/testOptForce.m`

#### The report becomes a file named like the output folder

- **Severity**: cosmetic
- **Trigger**: a run that creates no output folder: no set found, or printText = 0 on Linux
- **Observed**: movefile finds no folder and renames the report to OutputsOptForce, a plain file
- **Expected**: the output folder is created first and the report is moved into it
- **Source lines**: 746
- **Documented in**: `test/verifiedTests/design/testOptForce/testOptForce.m`

### `src/design/simpleOptKnock.m`

#### Single-deletion growth is stored in the first column in double-deletion mode

- **Severity**: limitation
- **Trigger**: doubleDelFlag true
- **Observed**: delRes.growth(i, 1) holds the growth of the single deletion i, whereas delRes.maxProd and delRes.minProd hold the single deletion on the diagonal (i, i)
- **Expected**: the same layout for the three outputs
- **Source lines**: 104
- **Documented in**: `test/verifiedTests/design/testSimpleOptKnock.m`

#### The wild-type minimum production is the maximum

- **Severity**: wrong-result
- **Trigger**: any call (output wtRes.minProd)
- **Observed**: solMin is computed with the default maximisation, so wtRes.minProd equals wtRes.maxProd
- **Expected**: the minimum production at the wild-type growth rate ('min' sense, as used for the deletion strains)
- **Source lines**: 66
- **Documented in**: `test/verifiedTests/design/testSimpleOptKnock.m`

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

### `src/reconstruction/growthExpMatch/growthExpMatch.m`

#### A SUX structure without exchange reactions cannot be solved

- **Severity**: error
- **Trigger**: growthExpMatch(MatricesSUX) with no entry equal to 3 in MatricesSUX.MatrixPart
- **Observed**: lengthEx is set to 0, but the names of the dummy reactions are taken from startKegg:stopEx, which is empty, so the call stops with Unable to perform assignment because the left and right sides have a different number of elements
- **Expected**: the problem is solved with the universal reactions only
- **Source lines**: 93, 150
- **Documented in**: `test/verifiedTests/reconstruction/testGrowthExpMatch/testGrowthExpMatch.m`

#### An empty objective stops with an undefined variable

- **Severity**: error
- **Trigger**: growthExpMatch(MatricesSUX) with MatricesSUX.c = []
- **Observed**: the text No biomass reaction found is printed and the run continues, so it stops with Unrecognized function or variable 'biomass_rxn_loc'
- **Expected**: an error that says that no biomass reaction was found
- **Source lines**: 126, 132
- **Documented in**: `test/verifiedTests/reconstruction/testGrowthExpMatch/testGrowthExpMatch.m`

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

### `src/reconstruction/modelGeneration/fastLeakTest.m`

#### an error when every tested reaction leaks

- **Severity**: error
- **Trigger**: a model in which every exchange and demand reaction under test carries a leak
- **Observed**: the list of reactions to test becomes empty, and changeObjective stops with 'Objective reactions not found in model!'
- **Expected**: the list of leaking reactions is returned
- **Source lines**: 61
- **Documented in**: `test/verifiedTests/reconstruction/testFastLeakTest/testFastLeakTest.m`

### `src/reconstruction/modelGeneration/modelProperties/checkModelProperties.m`

#### minSij is zero for every model with a zero in S

- **Severity**: wrong-result
- **Trigger**: any model with a sparse S (min(min(abs(S))) includes the structural zeros)
- **Observed**: model.minSij = 0, although the documentation says minimum NONZERO magnitude
- **Expected**: the smallest nonzero magnitude
- **Source lines**: 791
- **Documented in**: `test/verifiedTests/reconstruction/testCheckModelProperties/testCheckModelProperties.m`

#### the randomised thermodynamic test can stop with an error

- **Severity**: error
- **Trigger**: checkModelProperties(model) on ecoli_core_model with rng(2) or rng(5), which are 2 of the 8 seeds 0 to 7 that were tried; the error comes from findThermoConsistentFluxSubset
- **Observed**: 'Unable to perform assignment because the left and right sides have a different number of elements' at line 641 of findThermoConsistentFluxSubset
- **Expected**: a result for every random state; this test fixes the seed to avoid the failure
- **Source lines**: 431
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

### `src/reconstruction/modelGeneration/modelVerification/verifyModel.m`

#### a consistent model fails the simple check of flux consistency

- **Severity**: wrong-result
- **Trigger**: verifyModel(model, 'simpleCheck', true, 'fluxConsistency', true)
- **Observed**: the test is ~(abs(mins) > 1e-12) | (abs(maxs) > 1e-12), which is true for a reaction that can carry flux, so results is not empty and false is returned
- **Expected**: true when every reaction can carry flux
- **Source lines**: 195
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testVerifyModel.m`

#### every reaction counts as imbalanced in a mass balance without charges

- **Severity**: wrong-result
- **Trigger**: verifyModel(model, 'massBalance', true) on a model without metCharges
- **Observed**: the charges are set to NaN, a NaN charge imbalance flags the reaction, so that results.massBalance.imBalancedRxnBool is true for mass balanced reactions as well
- **Expected**: imBalancedRxnBool reflects the elements when the charges are not known
- **Source lines**: 158
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testVerifyModel.m`

#### the fields reported as problematic are the valid ones

- **Severity**: wrong-result
- **Trigger**: verifyModel(model, 'fluxConsistency', true) on a model that lacks one of S, lb, ub, c
- **Observed**: checkFields returns true for a VALID field, and that vector selects the entries of results.consistency.problematicFields, so the valid fields are listed and the missing one is not
- **Expected**: the missing or inconsistent fields are listed
- **Source lines**: 188-190
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testVerifyModel.m`

#### the report of stoichiometric consistency stops with an error

- **Severity**: error
- **Trigger**: verifyModel(model, 'stoichiometricConsistency', true) without 'simpleCheck', or with 'simpleCheck' on a stoichiometrically inconsistent model
- **Observed**: line 224 reads the misspelled, undefined variable ununknownSConsistencyRxnBool
- **Expected**: the booleans of the consistency test are returned in results.stoichiometricConsistency
- **Source lines**: 218-225
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testVerifyModel.m`

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

### `src/reconstruction/modelGeneration/test4HumanFctExt.m`

#### an error when no test carried flux

- **Severity**: error
- **Trigger**: test4HumanFctExt(model, 'IEC') on a model with no objective reaction of that block
- **Observed**: TestedRxns stays [], and intersect stops because a cell is compared with a double
- **Expected**: an empty list of tested reactions and a percentage of 0
- **Source lines**: 8387
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testTest4HumanFctExt.m`

#### the diary is opened in the current folder and never closed

- **Severity**: cosmetic
- **Trigger**: every call
- **Observed**: Test4Functions_diary.txt is written to the current folder, and the diary stays on after the function returns; this test works in a temporary folder and closes the diary
- **Expected**: no file is left behind and the diary is closed
- **Source lines**: 64
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testTest4HumanFctExt.m`

#### the documented option 'IECori' is not recognised

- **Severity**: unusable-option
- **Trigger**: test4HumanFctExt(model, 'IECori'), or any other value that no block compares with
- **Observed**: the help text says IECori and the code compares with 'IECOri', so that no block runs and the assignment to TestSolutionName stops with an error
- **Expected**: the documented option works, and an unknown option gets a clear message
- **Source lines**: 8385
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testTest4HumanFctExt.m`

#### the option 'IECOri' stops with an error for every model

- **Severity**: unusable-option
- **Trigger**: test4HumanFctExt(model, 'IECOri')
- **Observed**: the second test of the block has no call of optimizeCbModel, so that line 4715 reads FBA after 'clear FBA': 'Reference to a cleared variable FBA'. Nothing after it can run.
- **Expected**: each test of the block is solved and reported
- **Source lines**: 4694-5581
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testTest4HumanFctExt.m`

#### three tests stop with an error when their objective reaction is missing

- **Severity**: error
- **Trigger**: a model without ABTArm or METAT, or without DPCOAK when the LP of that test is feasible, with test 'all' or 'Harvey'
- **Observed**: model.c stays zero, optimizeCbModel returns an empty f, and the assignment to TestSolution fails: these three tests lack the check for an objective that the others have
- **Expected**: NaN for that test, as in the other tests
- **Source lines**: 8230, 8281, 8292
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testTest4HumanFctExt.m`

### `src/reconstruction/rBioNet/LegalRxnFormula.m`

#### An empty formula is accepted when more than one formula is checked

- **Severity**: wrong-result
- **Trigger**: LegalRxnFormula({''; 'a[c] -> b[c]'}, {'R1'; 'R2'})
- **Observed**: the flags of the empty formulas are a square matrix of size n by n, and the check only reports when all its elements are true, which needs n = 1, so the result is true and no message is shown
- **Expected**: false, with a message that names R1
- **Source lines**: 46, 53
- **Documented in**: `test/verifiedTests/reconstruction/testRBioNet/testLegalRxnFormula.m`

#### The message has a spelling error

- **Severity**: cosmetic
- **Trigger**: any illegal formula
- **Observed**: the message says illeagal
- **Expected**: illegal
- **Source lines**: 69
- **Documented in**: `test/verifiedTests/reconstruction/testRBioNet/testLegalRxnFormula.m`

### `src/reconstruction/rBioNet/model2data.m`

#### A model whose description is missing or is not a text or a structure of seven fields stops

- **Severity**: error
- **Trigger**: model2data(rmfield(model, 'description')); model.description = {'text'}; model.description = struct('name', 'text')
- **Observed**: the variable description is only set for the two supported forms, so the call stops with Unrecognized function or variable 'description'
- **Expected**: an output with an empty description, or an error that names the problem
- **Source lines**: 179
- **Documented in**: `test/verifiedTests/reconstruction/testRBioNet/testModel2data.m`

#### A model without grRules is reported as incomplete although the field is created

- **Severity**: wrong-result
- **Trigger**: model2data(rmfield(model, 'grRules'))
- **Observed**: the field is created in model, but the mandatory fields are then checked against the names read before and later read from handles.model, so the message Group grRules is missing from structure of model is shown and nothing is returned
- **Expected**: the output is built with the created grRules field
- **Source lines**: 49
- **Documented in**: `test/verifiedTests/reconstruction/testRBioNet/testModel2data.m`

#### The two exits with a message box leave the output unassigned

- **Severity**: error
- **Trigger**: data = model2data(rmfield(model, 'rxnNames'))
- **Observed**: after the message box the call stops with Output argument "data_out" (and possibly others) not assigned a value; the test calls these exits without an output
- **Expected**: an empty output after the message box, as in rBioNetSaveLoad
- **Source lines**: 44, 82
- **Documented in**: `test/verifiedTests/reconstruction/testRBioNet/testModel2data.m`

### `src/reconstruction/rBioNet/rBioNetSaveLoad.m`

#### A wrong path of the compartment database is not detected

- **Severity**: error
- **Trigger**: a settings file with a comp_path that does not exist, followed by rBioNetSaveLoad('load', 'comp')
- **Observed**: comp_exist is computed from met_path, so the message about the compartment database can never appear (a wrong met_path stops at the check before it) and the call stops in load with an error about the missing file
- **Expected**: the message about the compartment database and an empty output
- **Source lines**: 45, 57-60
- **Documented in**: `test/verifiedTests/reconstruction/testRBioNet/testRBioNetSaveLoad.m`

#### Saving prints the whole database

- **Severity**: cosmetic
- **Trigger**: rBioNetSaveLoad('save', 'met', data)
- **Observed**: the assignment in eval has no semicolon, so the data are printed to the console
- **Expected**: no output
- **Source lines**: 77, 87, 97
- **Documented in**: `test/verifiedTests/reconstruction/testRBioNet/testRBioNetSaveLoad.m`

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

### `src/reconstruction/refinement/mergeModelFieldPositions.m`

#### A cell field that does not hold text or cell arrays cannot be merged

- **Severity**: error
- **Trigger**: a cell field with one entry per reaction that holds numbers, strings or empty matrices, for example model.rxnValues = num2cell(ones(size(model.rxns))), followed by mergeModelFieldPositions(model, 'rxns', [1, 2])
- **Observed**: the call stops in setSlice with Conversion to cell from double is not possible (for string entries: value of type 'string' is not convertible to 'cell'; for empty entries: the size of the right side is 0-by-1)
- **Expected**: the entries are merged into one cell entry, as for the other cell fields
- **Source lines**: 115
- **Documented in**: `test/verifiedTests/base/testTools/testMergeModelFieldPositions.m`

### `src/reconstruction/refinement/mergeTwoModels.m`

#### A field that cannot be concatenated is dropped with a debug message

- **Severity**: wrong-result
- **Trigger**: a reaction field present in both models whose sizes do not fit, for example model1.rxnMat = zeros(2, 2) and model2.rxnMat = zeros(3, 3) for models with 2 and 3 reactions
- **Observed**: the error is caught, the text test is printed and the merged model has no rxnMat field, without any warning
- **Expected**: an error, or a warning that names the field that is lost
- **Source lines**: 236-237
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testMergeTwoModels.m`

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

### `src/reconstruction/refinement/updateGenes.m`

#### With two duplicated genes, different genes are merged

- **Severity**: wrong-result
- **Trigger**: a model with two pairs of duplicates, for example model.genes = {'g1'; 'g1'; 'g2'; 'g2'} with rules x(1), x(2), x(3), x(4) on four reactions, passed to updateGenes
- **Observed**: the gene list is recomputed from the input model and not from the merged one, so the same two positions are merged again although they now hold other genes: the result has the genes g1;g2 and g2, and three reactions with rule x(1)
- **Expected**: the genes g1 and g2, the first two reactions with rule x(1) and the others x(2)
- **Source lines**: 43
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testUpdateGenes.m`

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

### `src/visualization/efmviz/efmEnrichmentAnalysis.m`

#### Expression data without significance values stops with an error

- **Severity**: error
- **Trigger**: exprData with the fields gene and value only, as the input description lists them
- **Observed**: mapExpressionToReactions does not assign its fourth output without the field sig, so the call stops with 'Output argument "signifRxns" ... not assigned'
- **Expected**: the expression is written, without or with a default significance
- **Source lines**: 44
- **Documented in**: `test/verifiedTests/visualization/testEFMviz/testEfmEnrichmentAnalysis.m`

### `src/visualization/efmviz/efmSubsystemsExtraction.m`

#### Every call with valid inputs stops with an error

- **Severity**: error
- **Trigger**: any call with a model and an array of EFM reactions, so the valid call of Case 1 below is skipped until this is fixed
- **Observed**: uniqSubsys is built with string(...), which is never a cell array, and the next check then stops with the error 'uniqSubsys is not a cell'
- **Expected**: the unique subsystems and their counts per EFM
- **Source lines**: 30-31, 33-40
- **Documented in**: `test/verifiedTests/visualization/testEFMviz/testEfmSubsystemsExtraction.m`

### `src/visualization/maps/ReconMap/makeColorGradient.m`

#### A channel that is equal in both colours becomes 0

- **Severity**: wrong-result
- **Trigger**: start and end colours with the same red, green or blue value
- **Observed**: that channel is 0 in every step, for example #ff0000 to #ff0000 gives #000000
- **Expected**: the channel keeps its value
- **Source lines**: 28-29
- **Documented in**: `test/verifiedTests/visualization/testReconMap/testMakeColorGradient.m`

### `src/visualization/maps/ReconMap/printInRecon3Dmap.m`

#### The line width is written with a stray digit

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: the format %f4 prints a six-decimal number followed by the character 4, so a line width of 8 is written as 8.0000004
- **Expected**: the line width alone (a format such as %.4f)
- **Source lines**: 87
- **Documented in**: `test/verifiedTests/visualization/testReconMap/testPrintInRecon3Dmap.m`

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

### `src/visualization/upsetPlot/upsetPlot.m`

#### Sets without any element stop with an index error

- **Severity**: error
- **Trigger**: a membership matrix without any true entry, for example false(3, 2), or empty raw sets
- **Observed**: no intersection pattern is found, but [diff(sPPos); 1] still gives one position, so sPPos(dPPos) fails with "Index exceeds array bounds" before the plot is made
- **Expected**: an empty plot; the code at the end of the function already handles a largest set of size zero
- **Source lines**: 213
- **Documented in**: `test/verifiedTests/visualization/testUpsetPlot/testUpsetPlot.m`

### `src/visualization/visualizeEpistasis/findSubsystemOfGenes.m`

#### A reaction with several subsystems stops with an error

- **Severity**: error
- **Trigger**: model.subSystems as a cell array of cell arrays, with a reaction that holds two subsystems
- **Observed**: the gene gets a cell inside a cell, which convertMyCell2List passes on, and unique fails because the list is not a cell array of character vectors
- **Expected**: the subsystems of the gene are listed one by one
- **Source lines**: 56, 60
- **Documented in**: `test/verifiedTests/visualization/testVisualizeEpistasis/testFindSubsystemOfGenes.m`

#### Only the last reaction of a gene gives its subsystem

- **Severity**: wrong-result
- **Trigger**: a gene that catalyses reactions in more than one subsystem
- **Observed**: the loop over the reactions of the gene overwrites rxnInds, so subs and subsys hold the subsystem of its last reaction only
- **Expected**: the subsystems of all the reactions of the gene, as the output description and the comment on checking all the reactions state
- **Source lines**: 46-48, 50
- **Documented in**: `test/verifiedTests/visualization/testVisualizeEpistasis/testFindSubsystemOfGenes.m`
