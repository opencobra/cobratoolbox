# Known defects in tested functions

> **Generated file: do not edit by hand.** It is built from the "Known defects documented" section of each test header by `python3 .github/scripts/known_defects.py` (Constitution III-Defects).
> It is a snapshot: a function may have been changed or fixed since an entry was written. When you rely on an entry or work on resolving a defect, re-check it against the current source, then update the test header and regenerate this file.

404 known defects in 229 functions (142 wrong-result, 113 error, 30 unusable-option, 62 cosmetic, 57 limitation).

## Summary

| Function | Severity | Problem | Test file |
|----------|----------|---------|-----------|
| `src/analysis/FBA/optimizeCbModel.m` | error | A text in param.minNorm reaches solveCobraLP and stops with an error | `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m` |
| `src/analysis/FBA/optimizeCbModel.m` | unusable-option | QRQP cannot run | `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m` |
| `src/analysis/FBA/optimizeCbModel.m` | limitation | The linear objective is dropped for param.solveWBMmethod | `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m` |
| `src/analysis/FBA/optimizeCbModel.m` | wrong-result | The residual and the slack of QRLP are read from the wrong positions | `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m` |
| `src/analysis/FBA/optimizeCbModel.m` | error | minNorm oneInternal fails for a model without linear objective | `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m` |
| `src/analysis/FBA/optimizeCbModel.m` | wrong-result | param.osenseStr and the sense of the model are ignored for a parameter structure | `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m` |
| `src/analysis/FVA/fastFVA/cleanFilesFastFVA.m` | error | cleanFilesFastFVA(false) fails when there are log files to remove | `test/verifiedTests/analysis/testFVA/testCleanFilesFastFVA.m` |
| `src/analysis/FVA/fastFVA/mex/generateMexFastFVA.m` | cosmetic | printLevel 2 prints a truncated compilation command and a warning | `test/verifiedTests/analysis/testFVA/testGenerateMexFastFVA.m` |
| `src/analysis/FVA/fastFVA/mex/generateMexFastFVA.m` | cosmetic | the CPLEX root stays on the MATLAB path when the function stops with an error | `test/verifiedTests/analysis/testFVA/testGenerateMexFastFVA.m` |
| `src/analysis/FVA/fastFVA/mex/generateMexFastFVA.m` | cosmetic | the existence of the CPLEX library file is never checked | `test/verifiedTests/analysis/testFVA/testGenerateMexFastFVA.m` |
| `src/analysis/MOMA/MOMA.m` | error | Models with different reaction sets stop with an error | `test/verifiedTests/analysis/testMOMA/testMOMA.m` |
| `src/analysis/QFCA/QFCA.m` | error | A network that reduces to one metabolite stops with an error | `test/verifiedTests/analysis/testQFCA/testQFCA.m` |
| `src/analysis/dynamicFBA/dynamicFBA.m` | cosmetic | The number of tracked exchange reactions is printed on every call | `test/verifiedTests/analysis/testDynamicFBA/testDynamicFBA.m` |
| `src/analysis/ecosystem/clusterEcosystemPoints.m` | wrong-result | The hierarchical method returns the requested maximum k as the number of clusters | `test/verifiedTests/analysis/testEcosystem/testClusterEcosystemPoints.m` |
| `src/analysis/ecosystem/getEcosystemClusterDescriptor.m` | cosmetic | The status variable is named status_c<id>, not status as documented | `test/verifiedTests/analysis/testEcosystem/testGetEcosystemClusterDescriptor.m` |
| `src/analysis/ecosystem/getQualitativeFluxStates.m` | wrong-result | Zero band applied inconsistently to the maximum and to max - min | `test/verifiedTests/analysis/testEcosystem/testGetQualitativeFluxStates.m` |
| `src/analysis/ecosystem/matchEcosystemClusters.m` | wrong-result | clusters without points are matched to a reference cluster instead of NaN, and an empty reference cluster absorbs unmatched clusters | `test/verifiedTests/analysis/testEcosystem/testMatchEcosystemClusters.m` |
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
| `src/analysis/exploration/plotEssentialRxns.m` | error | Errors when no reaction is selected | `test/verifiedTests/analysis/testExploration/testPlotEssentialRxns.m` |
| `src/analysis/exploration/plotEssentialRxns.m` | cosmetic | The output is a cell array of reaction identifiers, not a table of fluxes | `test/verifiedTests/analysis/testExploration/testPlotEssentialRxns.m` |
| `src/analysis/exploration/printFluxVector.m` | error | Formulas or GPRs of a partly zero flux vector stop with an error | `test/verifiedTests/analysis/testPrint/testPrintFluxVector.m` |
| `src/analysis/exploration/printFluxVector.m` | wrong-result | excFlag has no effect unless nonZeroFlag is set | `test/verifiedTests/analysis/testPrint/testPrintFluxVector.m` |
| `src/analysis/exploration/printLabeledData.m` | wrong-result | Sorting on a data column other than the first is silently ignored | `test/verifiedTests/base/testTools/testPrintLabeledData.m` |
| `src/analysis/exploration/printRxnFormula.m` | wrong-result | A model without ub loses its lower bounds | `test/verifiedTests/analysis/testPrint/testPrintRxnFormula.m` |
| `src/analysis/exploration/printRxnFormula.m` | wrong-result | Bounds do not follow the file identifier | `test/verifiedTests/analysis/testPrint/testPrintRxnFormula.m` |
| `src/analysis/exploration/printRxnFormula.m` | wrong-result | GPRs built from model.rules are wrong or stop with an error | `test/verifiedTests/analysis/testPrint/testPrintRxnFormula.m` |
| `src/analysis/exploration/surfNet.m` | error | Searching with a flux vector stops with an error | `test/verifiedTests/analysis/testPrint/testSurfNet.m` |
| `src/analysis/exploration/surfNet.m` | cosmetic | The message for a partial field name shows a literal backslash n | `test/verifiedTests/analysis/testPrint/testSurfNet.m` |
| `src/analysis/exploration/surfNetSubfunctions/generateGrRules.m` | wrong-result | Nested hyperlinks when genes are named from the rules and a gene repeats | `test/verifiedTests/analysis/testExploration/testGenerateGrRules.m` |
| `src/analysis/fastForest/extractSubsetFeaturesfromFile.m` | wrong-result | The last sample of the file is not written to the subset file | `test/verifiedTests/analysis/testFastForest/testExtractSubsetFeaturesfromFile.m` |
| `src/analysis/fastForest/extractSubsetFeaturesfromFile.m` | limitation | The subset file is left open | `test/verifiedTests/analysis/testFastForest/testExtractSubsetFeaturesfromFile.m` |
| `src/analysis/fluxEnrichmentAnalysis/FEA.m` | error | An empty reaction set raises an error instead of returning the header-only result | `test/verifiedTests/analysis/testFEA/testFEA.m` |
| `src/analysis/geometricFBA/geometricFBA.m` | error | A model with a unique optimum stops with an error | `test/verifiedTests/analysis/testGeometricFBA/testGeometricFBA.m` |
| `src/analysis/igemRNA/LT1/findGenesAboveThresholdLocal1.m` | error | Errors when no gene qualifies | `test/verifiedTests/analysis/testLT1/testFindGenesAboveThresholdLocal1.m` |
| `src/analysis/igemRNA/LT1/findGenesAboveThresholdLocal1.m` | wrong-result | The local threshold is the sum divided by the row length minus one, not the mean | `test/verifiedTests/analysis/testLT1/testFindGenesAboveThresholdLocal1.m` |
| `src/analysis/igemRNA/LT1/findGenesBelowThresholdLocal1.m` | error | Errors when no gene qualifies | `test/verifiedTests/analysis/testLT1/testFindGenesBelowThresholdLocal1.m` |
| `src/analysis/igemRNA/LT1/findGenesBelowThresholdLocal1.m` | wrong-result | The local threshold is the sum divided by the row length minus one, not the mean | `test/verifiedTests/analysis/testLT1/testFindGenesBelowThresholdLocal1.m` |
| `src/analysis/igemRNA/LT2/findGenesAboveThresholdLocal2.m` | error | Errors when no gene qualifies | `test/verifiedTests/analysis/testLT2/testFindGenesAboveThresholdLocal2.m` |
| `src/analysis/igemRNA/LT2/findGenesAboveThresholdLocal2.m` | wrong-result | The local threshold is the sum divided by the row length minus one, not the mean | `test/verifiedTests/analysis/testLT2/testFindGenesAboveThresholdLocal2.m` |
| `src/analysis/igemRNA/LT2/findGenesBelowThresholdLocal2.m` | error | Errors when no gene qualifies | `test/verifiedTests/analysis/testLT2/testFindGenesBelowThresholdLocal2.m` |
| `src/analysis/igemRNA/LT2/findGenesBelowThresholdLocal2.m` | wrong-result | The local threshold is the sum divided by the row length minus one, not the mean | `test/verifiedTests/analysis/testLT2/testFindGenesBelowThresholdLocal2.m` |
| `src/analysis/igemRNA/filterNonFluxReactions/filterNonFluxReactions.m` | wrong-result | The result file is written next to the result folder, not into it | `test/verifiedTests/analysis/testFilterNonFluxReactions/testFilterNonFluxReactions.m` |
| `src/analysis/igemRNA/findUpDownRegulatedGenes/findUpDownRegulatedGenes.m` | limitation | Errors when the source sheet holds no gene | `test/verifiedTests/analysis/testFindUpDownRegulatedGenes/testFindUpDownRegulatedGenes.m` |
| `src/analysis/igemRNA/findUpDownRegulatedGenes/findUpDownRegulatedGenes.m` | limitation | Genes are matched by row position, not by gene ID | `test/verifiedTests/analysis/testFindUpDownRegulatedGenes/testFindUpDownRegulatedGenes.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/correlateFluxWithTaxonAbundance.m` | error | Every call stops with an error when the taxonomy is prepared for export | `test/verifiedTests/analysis/testAdditionalAnalysis/testCorrelateFluxWithTaxonAbundance.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/makeViolinPlots.m` | cosmetic | Box plots print the handle array of every plot | `test/verifiedTests/analysis/testAdditionalAnalysis/testMakeViolinPlots.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/makeViolinPlots.m` | limitation | Features with negative values are dropped as if they were all zero | `test/verifiedTests/analysis/testAdditionalAnalysis/testMakeViolinPlots.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/performStatisticalAnalysis.m` | cosmetic | Fecal exchange features never get a metabolite description | `test/verifiedTests/analysis/testAdditionalAnalysis/testPerformStatisticalAnalysis.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/performStatisticalAnalysis.m` | wrong-result | Samples whose values are all zero are not removed | `test/verifiedTests/analysis/testAdditionalAnalysis/testPerformStatisticalAnalysis.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/plotFluxesAgainstOrganismAbundances.m` | cosmetic | The current folder stays Metabolite_plots after an error | `test/verifiedTests/analysis/testAdditionalAnalysis/testPlotFluxesAgainstOrganismAbundances.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/plotFluxesAgainstOrganismAbundances.m` | error | The documented orientation of the flux table and relative file paths stop with an error | `test/verifiedTests/analysis/testAdditionalAnalysis/testPlotFluxesAgainstOrganismAbundances.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/addMicrobeCommunityBiomass.m` | wrong-result | Abundance weights are rounded to six significant digits | `test/verifiedTests/analysis/testMultiSpeciesModelling/testAddMicrobeCommunityBiomass.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/extractFullRes.m` | error | Errors when the first sample is infeasible and a later one is feasible | `test/verifiedTests/analysis/testMgPipe/testExtractFullRes.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/mgSimResCollect.m` | wrong-result | The feasibility of every diet is read from the last diet | `test/verifiedTests/analysis/testMgPipe/testMgSimResCollect.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/mgSimResCollect.m` | limitation | Two samples stop with an error in the PCoA | `test/verifiedTests/analysis/testMgPipe/testMgSimResCollect.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/mgSimResCollect.m` | wrong-result | Uptake of an exchange missing from a sample is copied from the previous sample | `test/verifiedTests/analysis/testMgPipe/testMgSimResCollect.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/parsave.m` | limitation | A structure without a rxns field is silently not saved | `test/verifiedTests/analysis/testMgPipe/testParsave.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/plotMappingInfo.m` | error | The documented matrix inputs stop with an error | `test/verifiedTests/analysis/testMgPipe/testPlotMappingInfo.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/plotMappingInfo.m` | wrong-result | The heatmap shows only the first four individuals | `test/verifiedTests/analysis/testMgPipe/testPlotMappingInfo.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/translateMetagenome2AGORA.m` | wrong-result | Abundances read from a tsv file are added and normalized as text | `test/verifiedTests/analysis/testMultiSpeciesModelling/testTranslateMetagenome2AGORA.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/updateTaxonomyInfoAGORA.m` | cosmetic | The row counter is printed for every strain | `test/verifiedTests/analysis/testMgPipe/testUpdateTaxonomyInfoAGORA.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/calculateInteractionsByTaxon.m` | error | Errors when the taxon table has fewer rows than columns | `test/verifiedTests/analysis/testMultiSpeciesModelling/testCalculateInteractionsByTaxon.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/joinModelsPairwiseFromList.m` | error | Two models whose file names start with the same model name stop the function | `test/verifiedTests/analysis/testMultiSpeciesModelling/testJoinModelsPairwiseFromList.m` |
| `src/analysis/parsimoniousFBA/pFBA.m` | error | A call with one output stops with an error | `test/verifiedTests/analysis/testpFBA/testpFBA.m` |
| `src/analysis/persephone/additionalFunctions/combineFluxResults.m` | error | Errors for a common germ-free sample preceded by a sample of the first run only | `test/verifiedTests/analysis/testPersephone/testCombineFluxResults.m` |
| `src/analysis/persephone/additionalFunctions/combineFluxResults.m` | wrong-result | Shadow prices of the second run are dropped when the folders hold different samples | `test/verifiedTests/analysis/testPersephone/testCombineFluxResults.m` |
| `src/analysis/persephone/additionalFunctions/convertVMHIDName.m` | wrong-result | Names of unknown IDs are dropped, so names and IDs do not line up | `test/verifiedTests/analysis/testPersephone/testConvertVMHIDName.m` |
| `src/analysis/persephone/additionalFunctions/convertVMHIDName.m` | error | The numeric skip flag 0 for metNames raises an error | `test/verifiedTests/analysis/testPersephone/testConvertVMHIDName.m` |
| `src/analysis/persephone/additionalFunctions/convertVMHIDName.m` | error | The skip flag 0 for VMHIDs raises an error | `test/verifiedTests/analysis/testPersephone/testConvertVMHIDName.m` |
| `src/analysis/persephone/additionalFunctions/convertVMHIDName.m` | error | similarMets is never assigned from the suggestions | `test/verifiedTests/analysis/testPersephone/testConvertVMHIDName.m` |
| `src/analysis/persephone/additionalFunctions/dimensionalityReductionAndMultivariateAnalysis.m` | limitation | A text (cell array) variable of interest is not supported | `test/verifiedTests/analysis/testPersephone/testDimensionalityReductionAndMultivariateAnalysis.m` |
| `src/analysis/persephone/additionalFunctions/dimensionalityReductionAndMultivariateAnalysis.m` | error | Errors when the regression of a metadata variable gives a warning | `test/verifiedTests/analysis/testPersephone/testDimensionalityReductionAndMultivariateAnalysis.m` |
| `src/analysis/persephone/additionalFunctions/dimensionalityReductionAndMultivariateAnalysis.m` | cosmetic | The loadings figure of PC 1 is saved as Loadings_PC11.png | `test/verifiedTests/analysis/testPersephone/testDimensionalityReductionAndMultivariateAnalysis.m` |
| `src/analysis/persephone/additionalFunctions/dimensionalityReductionAndMultivariateAnalysis.m` | wrong-result | The regression figures pair the values of one variable with the name of another | `test/verifiedTests/analysis/testPersephone/testDimensionalityReductionAndMultivariateAnalysis.m` |
| `src/analysis/persephone/additionalFunctions/generatePanAGORA2database.m` | cosmetic | Hard-coded personal input folder | `test/verifiedTests/analysis/testPersephone/testGeneratePanAGORA2database.m` |
| `src/analysis/persephone/additionalFunctions/generatePanAGORA2database.m` | wrong-result | Only the first three strains are processed | `test/verifiedTests/analysis/testPersephone/testGeneratePanAGORA2database.m` |
| `src/analysis/persephone/additionalFunctions/generatePanDatabase.m` | wrong-result | Coefficients of new metabolites are written to the wrong rows | `test/verifiedTests/analysis/testPersephone/testGeneratePanDatabase.m` |
| `src/analysis/persephone/additionalFunctions/generatePanDatabase.m` | wrong-result | Coefficients of new reactions are written to the wrong columns | `test/verifiedTests/analysis/testPersephone/testGeneratePanDatabase.m` |
| `src/analysis/persephone/additionalFunctions/generatePanDatabase.m` | limitation | The documented default inputDir needs an explicit empty argument | `test/verifiedTests/analysis/testPersephone/testGeneratePanDatabase.m` |
| `src/analysis/persephone/additionalFunctions/generateStackedBarPlot.m` | error | Errors for a single sample | `test/verifiedTests/analysis/testPersephone/testGenerateStackedBarPlot.m` |
| `src/analysis/persephone/additionalFunctions/getVMHID.m` | wrong-result | Suggestions are misaligned after a found name | `test/verifiedTests/analysis/testPersephone/testGetVMHID.m` |
| `src/analysis/persephone/additionalFunctions/microbiomeMappingStats.m` | cosmetic | An unlabelled count is printed | `test/verifiedTests/analysis/testPersephone/testMicrobiomeMappingStats.m` |
| `src/analysis/persephone/additionalFunctions/microbiomeMappingStats.m` | wrong-result | Taxa whose name contains "pan" are counted as unmapped | `test/verifiedTests/analysis/testPersephone/testMicrobiomeMappingStats.m` |
| `src/analysis/persephone/additionalFunctions/microbiomeMappingStats.m` | cosmetic | The sheet of unmapped taxa is named 'Umapped' | `test/verifiedTests/analysis/testPersephone/testMicrobiomeMappingStats.m` |
| `src/analysis/persephone/additionalFunctions/plotAbsentTaxaEffectOnMARScoverage.m` | wrong-result | The genus+epithet curve starts at the standard deviation of the base coverage | `test/verifiedTests/analysis/testPersephone/testPlotAbsentTaxaEffectOnMARScoverage.m` |
| `src/analysis/persephone/additionalFunctions/setResultPath.m` | error | On Linux and macOS the results folder is placed at the file-system root | `test/verifiedTests/analysis/testPersephone/testSetResultPath.m` |
| `src/analysis/persephone/additionalFunctions/slimDownFBAresults.m` | cosmetic | The call leaves every MATLAB warning switched on | `test/verifiedTests/analysis/testPersephone/testSlimDownFBAresults.m` |
| `src/analysis/persephone/additionalFunctions/validateDietPath.m` | error | A diet file path stops with an error | `test/verifiedTests/analysis/testPersephone/testValidateDietPath.m` |
| `src/analysis/persephone/analyseWBMsol.m` | error | Errors for germ-free and microbiome-personalised iWBMs with analyseGF | `test/verifiedTests/analysis/testPersephone/testAnalyseWBMsol.m` |
| `src/analysis/persephone/analyseWBMsol.m` | error | Errors when the reaction list contains a duplicate | `test/verifiedTests/analysis/testPersephone/testAnalyseWBMsol.m` |
| `src/analysis/persephone/calculateMetrics.m` | wrong-result | Bray-Curtis wrong for a single taxon | `test/verifiedTests/analysis/testPersephone/testCalculateMetrics.m` |
| `src/analysis/persephone/generateStackedBarPlot_PhylumMARScoverage.m` | error | Errors for more than seven phyla | `test/verifiedTests/analysis/testPersephone/testGenerateStackedBarPlot_PhylumMARScoverage.m` |
| `src/analysis/persephone/performRegressions.m` | wrong-result | The MATLAB version check reads the first product listed by ver | `test/verifiedTests/analysis/testPersephone/testPerformRegressions.m` |
| `src/analysis/persephone/readMetadataForPersephone.m` | cosmetic | All warnings are switched on after the call | `test/verifiedTests/analysis/testPersephone/testReadMetadataForPersephone.m` |
| `src/analysis/persephone/readMetadataForPersephone.m` | wrong-result | The units line is dropped instead of being stored in VariableUnits | `test/verifiedTests/analysis/testPersephone/testReadMetadataForPersephone.m` |
| `src/analysis/persephone/runMars.m` | wrong-result | The processed and mapped summary sheets hold the original data | `test/verifiedTests/analysis/testPersephone/testRunMars.m` |
| `src/analysis/persephone/runNonparametricTests.m` | wrong-result | A comparison skipped for missing values gets p-value 0 and FDR 0 | `test/verifiedTests/analysis/testPersephone/testRunNonparametricTests.m` |
| `src/analysis/persephone/runNonparametricTests.m` | limitation | The predictor name is accepted in any case but used as given | `test/verifiedTests/analysis/testPersephone/testRunNonparametricTests.m` |
| `src/analysis/persephone/validatePersephoneInputs.m` | error | A column reaction list with two or more duplicates fails while the message is built | `test/verifiedTests/analysis/testPersephone/testValidatePersephoneInputs.m` |
| `src/analysis/rFBA/solveBooleanRegModel.m` | error | A name that is contained in a later name of the same rule stops with an error | `test/verifiedTests/analysis/testrFBA/testSolveBooleanRegModel.m` |
| `src/analysis/rMTA/calculateEPSILON.m` | limitation | 'unique_epsilon' stops with an error when no reaction changes | `test/verifiedTests/analysis/testRMTA/testCalculateEPSILON.m` |
| `src/analysis/rMTA/calculateEPSILON.m` | cosmetic | The documented codes of rxnFBS do not match the code | `test/verifiedTests/analysis/testRMTA/testCalculateEPSILON.m` |
| `src/analysis/rMTA/rMTAsaveInExcel.m` | unusable-option | The documented default of alpha_values cannot be used | `test/verifiedTests/analysis/testRMTA/testRMTAsaveInExcel.m` |
| `src/analysis/rMTA/rMTAsaveInExcel.m` | limitation | The sheets written with xlswrite need Microsoft Excel | `test/verifiedTests/analysis/testRMTA/testRMTAsaveInExcel.m` |
| `src/analysis/relaxedFBA/relaxedFBA.m` | limitation | A generic LP without rxns and mets stops with an error | `test/verifiedTests/analysis/testRelaxedFBA/testRelaxedFBA.m` |
| `src/analysis/relaxedFBA/relaxedFBA.m` | error | Extra variables given only by model.D stop with an error | `test/verifiedTests/analysis/testRelaxedFBA/testRelaxedFBA.m` |
| `src/analysis/rumba/compareConditions.m` | limitation | Sample-point count taken from the first metabolite of the first list | `test/verifiedTests/analysis/testRumba/testCompareConditions.m` |
| `src/analysis/sampling/ACHR/ACHRSamplerParallelGeneral.m` | cosmetic | A log file is written into the current folder | `test/verifiedTests/analysis/testSampling/testACHRSamplerParallelGeneral.m` |
| `src/analysis/sampling/ACHR/ACHRSamplerParallelGeneral.m` | unusable-option | The parallel mode cannot start its worker processes on Linux and macOS | `test/verifiedTests/analysis/testSampling/testACHRSamplerParallelGeneral.m` |
| `src/analysis/sampling/ACHR/convRevSamples.m` | wrong-result | Bounds of a reverse-only reaction are not exchanged correctly | `test/verifiedTests/analysis/testSampling/testConvRevSamples.m` |
| `src/analysis/sampling/ACHR/gpSampler.m` | unusable-option | A bias distribution stops with an error | `test/verifiedTests/analysis/testSampling/testGpSampler.m` |
| `src/analysis/sampling/ACHR/gpSampler.m` | error | A problem given by A without S stops with an error | `test/verifiedTests/analysis/testSampling/testGpSampler.m` |
| `src/analysis/sampling/ACHR/gpSampler.m` | unusable-option | The distributed sampler does not exist | `test/verifiedTests/analysis/testSampling/testGpSampler.m` |
| `src/analysis/sampling/ACHR/verifyPoints.m` | error | One point stops with an error when a sense has a single row | `test/verifiedTests/analysis/testSampling/testVerifyPoints.m` |
| `src/analysis/sampling/ACHR/verifyPoints.m` | wrong-result | errorsA gives row numbers within the constraints of one sense, not rows of A | `test/verifiedTests/analysis/testSampling/testVerifyPoints.m` |
| `src/analysis/sampling/BarrierRound/CMatrix/CMatrix.m` | wrong-result | sparse(i, j, s) pairs the values with the sorted pattern, not with (i, j) | `test/verifiedTests/analysis/testSampling/testCMatrix.m` |
| `src/analysis/sampling/BarrierRound/CMatrix/configCMatrix.m` | error | Every call stops because the parent script config does not exist | `test/verifiedTests/analysis/testSampling/testConfigCMatrix.m` |
| `src/analysis/sampling/BarrierRound/CMatrix/include/ddouble.m` | wrong-result | sparse(i, j, s) pairs the values with the sorted pattern, not with (i, j) | `test/verifiedTests/analysis/testSampling/testDdouble.m` |
| `src/analysis/sampling/BarrierRound/CMatrix/include/qdouble.m` | wrong-result | sparse(i, j, s) pairs the values with the sorted pattern, not with (i, j) | `test/verifiedTests/analysis/testSampling/testQdouble.m` |
| `src/analysis/sampling/BarrierRound/PolytopeSimplifier/TwoSidedBarrier.m` | error | step_size fails for more than one point | `test/verifiedTests/analysis/testSampling/testTwoSidedBarrier.m` |
| `src/analysis/sampling/BarrierRound/utils/TableDisplay.m` | error | A format without a width gives a NaN length and header fails | `test/verifiedTests/analysis/testSampling/testTableDisplay.m` |
| `src/analysis/sampling/BarrierRound/utils/TableDisplay.m` | wrong-result | The blank that separates the columns is dropped | `test/verifiedTests/analysis/testSampling/testTableDisplay.m` |
| `src/analysis/sampling/compareTwoSamplesStat.m` | wrong-result | The chi-square p values are cumulative probabilities, near 0 for identical samples | `test/verifiedTests/analysis/testSampling/testCompareTwoSamplesStat.m` |
| `src/analysis/sampling/loadSamples.m` | wrong-result | More points than pointsPerFile are taken from a file at regular intervals | `test/verifiedTests/analysis/testSampling/testLoadSamples.m` |
| `src/analysis/sampling/printSampleStats.m` | wrong-result | With several samples only the first sample's mode is printed | `test/verifiedTests/analysis/testSampling/testPrintSampleStats.m` |
| `src/analysis/subspaces/lsqr/lsqr.m` | cosmetic | The x = 0 message is printed even when show = 0 | `test/verifiedTests/analysis/testSubspaces/testLsqr.m` |
| `src/analysis/subspaces/lsqr/lsqr.m` | error | r1norm and r2norm are not assigned when A'*b = 0 | `test/verifiedTests/analysis/testSubspaces/testLsqr.m` |
| `src/analysis/subspaces/lsqr/lsqrtest.m` | cosmetic | The function handle is printed by a statement without a semicolon | `test/verifiedTests/analysis/testSubspaces/testLsqrtest.m` |
| `src/analysis/subspaces/nullspace/nullSpaceOperator.m` | unusable-option | The option scale = 0 always fails | `test/verifiedTests/analysis/testSubspaces/testNullSpaceOperator.m` |
| `src/analysis/subspaces/rank/getRankLUSOL.m` | wrong-result | q is wrong when A has a zero column | `test/verifiedTests/analysis/testRank/testGetRankLUSOL.m` |
| `src/analysis/thermo/experimentalData/alberty2006/adjustBaselinesInAlberty2006.m` | wrong-result | The reduced glutathione energies are halved together with the baseline | `test/verifiedTests/analysis/testThermo/testAdjustBaselinesInAlberty2006.m` |
| `src/analysis/thermo/formulae/checkFormulae.m` | limitation | Elements other than C, H, O, P, S, K, Na and N are ignored | `test/verifiedTests/analysis/testThermo/testCheckFormulae.m` |
| `src/analysis/thermo/groupContribution/createComputedSpeciesData.m` | error | A row structure array of species fails when two metabolites are included | `test/verifiedTests/analysis/testThermo/testCreateComputedSpeciesData.m` |
| `src/analysis/thermo/groupContribution/createComputedSpeciesData.m` | wrong-result | The first group-contribution entry is used for every metabolite | `test/verifiedTests/analysis/testThermo/testCreateComputedSpeciesData.m` |
| `src/analysis/thermo/groupContribution/jankowski/createGroupContributionStruct.m` | limitation | The input files are left open | `test/verifiedTests/analysis/testThermo/testCreateGroupContributionStruct.m` |
| `src/analysis/thermo/inchi/getMolecularWeight.m` | wrong-result | Hydrogens are lost for an InChI whose formula starts with H | `test/verifiedTests/analysis/testThermo/testGetMolecularWeight.m` |
| `src/analysis/thermo/protons/getMetaboliteMsDistr.m` | wrong-result | Mol files are missed when another file precedes them or their name holds a dot or 'mol' | `test/verifiedTests/analysis/testThermo/testGetMetaboliteMsDistr.m` |
| `src/analysis/thermo/protons/getMetabolitepKa.m` | wrong-result | Mol files are missed when another file precedes them or their name holds a dot or 'mol' | `test/verifiedTests/analysis/testThermo/testGetMetabolitepKa.m` |
| `src/analysis/thermo/reactantContribution/calcdGHT.m` | limitation | The standard transformed enthalpy dHf0 is always NaN | `test/verifiedTests/analysis/testThermo/testCalcdGHT.m` |
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
| `src/analysis/topology/conservedMoieties/classifyMoieties.m` | cosmetic | isSecondary is returned as a row vector, not m x 1 | `test/verifiedTests/analysis/testConservedMoieties/testClassifyMoieties.m` |
| `src/analysis/topology/conservedMoieties/constructElementalMatrix.m` | error | Every call stops because atomicNumbers.mat is missing | `test/verifiedTests/analysis/testConservedMoieties/testConstructElementalMatrix.m` |
| `src/analysis/topology/conservedMoieties/estimateMoietyFormulas.m` | cosmetic | M is not the r x p matrix the documentation describes | `test/verifiedTests/analysis/testConservedMoieties/testEstimateMoietyFormulas.m` |
| `src/analysis/topology/conservedMoieties/representativeMoiety.m` | limitation | MMN.moi is required but not documented | `test/verifiedTests/analysis/testConservedMoieties/testRepresentativeMoiety.m` |
| `src/analysis/topology/conservedMoieties/representativeMoiety.m` | wrong-result | minimalMassFraction is always 1 | `test/verifiedTests/analysis/testConservedMoieties/testRepresentativeMoiety.m` |
| `src/analysis/topology/extremeRays/lrs/extremePools.m` | error | A model with mets but no usable SIntRxnBool stops on an undefined variable | `test/verifiedTests/analysis/testTopology/testExtremePools.m` |
| `src/analysis/topology/extremeRays/lrs/extremePools.m` | cosmetic | The third output is the transpose of what the help text states | `test/verifiedTests/analysis/testTopology/testExtremePools.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsInputHalfspace.m` | unusable-option | the linear objective f is malformed and placed where lrs ignores it | `test/verifiedTests/analysis/testLrsInterface/testLrsInputHalfspace.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsInputHalfspace.m` | unusable-option | the shell script writes to a fixed personal folder | `test/verifiedTests/analysis/testLrsInterface/testLrsInputHalfspace.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsInputHalfspace.m` | wrong-result | with A empty and inequality = 1 the column count is 1 | `test/verifiedTests/analysis/testLrsInterface/testLrsInputHalfspace.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsInputHalfspace.m` | wrong-result | with A empty and positivity = 1 the row count omits the x >= 0 rows | `test/verifiedTests/analysis/testLrsInterface/testLrsInputHalfspace.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsOutputReadRay.m` | wrong-result | rows with rational entries are dropped and become zero rays | `test/verifiedTests/analysis/testLrsInterface/testLrsOutputReadRay.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsOutputReadRay.m` | cosmetic | the empty matrix P is printed to the command window | `test/verifiedTests/analysis/testLrsInterface/testLrsOutputReadRay.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsSpecifyRows.m` | cosmetic | a file that cannot be opened gives an undefined-variable error | `test/verifiedTests/analysis/testLrsInterface/testLrsSpecifyRows.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsSpecifyRows.m` | limitation | the file identifier is never closed | `test/verifiedTests/analysis/testLrsInterface/testLrsSpecifyRows.m` |
| `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m` | error | glpk, one of the solvers the routine falls back on, cannot run the search | `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m` |
| `src/analysis/topology/findCyclicRxns.m` | wrong-result | The first output is not a per-reaction boolean | `test/verifiedTests/analysis/testTopology/testFindCyclicRxns.m` |
| `src/analysis/topology/getCorrespondingCols.m` | cosmetic | The error for a colBool of the wrong length names rowBool | `test/verifiedTests/analysis/testTopology/testGetCorrespondingCols.m` |
| `src/analysis/topology/getCorrespondingRows.m` | cosmetic | The error for a colBool of the wrong length names rowBool | `test/verifiedTests/analysis/testTopology/testGetCorrespondingRows.m` |
| `src/analysis/topology/graphHypergraphConversion/convertHypergraphToBipartiteGraph.m` | wrong-result | trailing empty hyperedges are missing from A and B | `test/verifiedTests/analysis/testTopology/testConvertHypergraphToBipartiteGraph/testConvertHypergraph2BipartiteGraph.m` |
| `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m` | error | A reaction with an elemental mismatch stops the build instead of being skipped | `test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m` |
| `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m` | wrong-result | Decompartmentalising the model keeps the opening bracket | `test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m` |
| `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m` | error | The bond graph is not decompartmentalised | `test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m` |
| `src/analysis/topology/reactingMoieties/checkABRXNFiles.m` | wrong-result | Decompartmentalising the model keeps the opening bracket | `test/verifiedTests/analysis/testReactingMoieties/testCheckABRXNFiles.m` |
| `src/analysis/topology/reactingMoieties/checkABRXNFiles.m` | cosmetic | The duplicates that stop the check are not shown | `test/verifiedTests/analysis/testReactingMoieties/testCheckABRXNFiles.m` |
| `src/analysis/topology/reactingMoieties/identifyAtomEquivalenceClasses.m` | limitation | The check for a duplicate bond never fires | `test/verifiedTests/analysis/testReactingMoieties/testIdentifyAtomEquivalenceClasses.m` |
| `src/analysis/topology/reactingMoieties/identifyIsomorphicClasses.m` | unusable-option | sanityChecks = true raises an error for any class with two or more members | `test/verifiedTests/analysis/testReactingMoieties/testIdentifyIsomorphicClasses.m` |
| `src/analysis/topology/reactingMoieties/readABRXNFile.m` | cosmetic | The two warnings about transition numbers print a literal backslash n | `test/verifiedTests/analysis/testReactingMoieties/testReadABRXNFile.m` |
| `src/analysis/topology/reactingMoieties/readABRXNFile.m` | unusable-option | options.readBonds = 0 cannot be used | `test/verifiedTests/analysis/testReactingMoieties/testReadABRXNFile.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/createUSDAdatabase.m` | cosmetic | The progress message has no space before the food source name | `test/verifiedTests/analysis/testWholeBody/testCreateUSDAdatabase.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/createUSDAdatabase.m` | unusable-option | brandedFoods = true always raises an error | `test/verifiedTests/analysis/testWholeBody/testCreateUSDAdatabase.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/getNutritionDatabaseFile.m` | limitation | The shipped USDA food items file is not found | `test/verifiedTests/analysis/testWholeBody/testGetNutritionDatabaseFile.m` |
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
| `src/base/install/prepareTest.m` | unusable-option | needsLinux makes every test skip on Linux | `test/verifiedTests/base/testInstall/testPrepareTest.m` |
| `src/base/io/KEGG/mapKEGGID2Model.m` | error | A dictionary abbreviation with several entries stops with an error | `test/verifiedTests/base/testIO/testKEGG/testMapKEGGID2Model.m` |
| `src/base/io/KEGG/mapKEGGID2Model.m` | error | A metabolite without compartment that is in the dictionary stops with an error | `test/verifiedTests/base/testIO/testKEGG/testMapKEGGID2Model.m` |
| `src/base/io/KEGG/mapMetName2KEGGID.m` | error | A metabolite without compartment that is in the dictionary stops with an error | `test/verifiedTests/base/testIO/testKEGG/testMapMetName2KEGGID.m` |
| `src/base/io/KEGG/mapMetName2KEGGID.m` | cosmetic | The message for a metabolite with several matches is never printed | `test/verifiedTests/base/testIO/testKEGG/testMapMetName2KEGGID.m` |
| `src/base/io/convertCNAModelToCbModel.m` | error | Without CellNetAnalyzer an output is never assigned | `test/verifiedTests/base/testIO/testConvertCNAModelToCbModel.m` |
| `src/base/io/definitions/descFileRead.m` | wrong-result | An empty line ends the reading | `test/verifiedTests/base/testIO/testDescFileRead.m` |
| `src/base/io/definitions/descFileRead.m` | limitation | Short entries are padded with null characters, not blanks | `test/verifiedTests/base/testIO/testDescFileRead.m` |
| `src/base/io/python/pyPath/py_addpath.m` | wrong-result | A relative folder is added as given, not converted to an absolute path | `test/verifiedTests/base/testPyPath/testPy_addpath.m` |
| `src/base/io/python/pyPath/py_addpath.m` | wrong-result | The empty input adds the current folder to the Python path | `test/verifiedTests/base/testPyPath/testPy_addpath.m` |
| `src/base/io/python/pyPath/py_rmpath.m` | error | MATLAB_too = true always raises an error | `test/verifiedTests/base/testPyPath/testPy_rmpath.m` |
| `src/base/io/utilities/SBML/getDataBases.m` | wrong-result | Mixed matching and non-matching resources return nothing | `test/verifiedTests/base/testIO/testUtilities/testGetDataBases.m` |
| `src/base/io/utilities/SBML/getDataBases.m` | error | Third output unassigned when nothing matches | `test/verifiedTests/base/testIO/testUtilities/testGetDataBases.m` |
| `src/base/io/utilities/SBML/makeSBMLAnnotationString.m` | wrong-result | A field of another is-qualifier is also annotated under the qualifier is | `test/verifiedTests/base/testIO/testUtilities/testMakeSBMLAnnotationString.m` |
| `src/base/io/utilities/createEmptyFields.m` | limitation | A cell field with a computed default fills only its first column | `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m` |
| `src/base/io/utilities/createEmptyFields.m` | error | A field whose default refers to another field the model lacks cannot be created | `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m` |
| `src/base/io/utilities/createEmptyFields.m` | error | The default of comps cannot be evaluated | `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m` |
| `src/base/io/utilities/getDefinedFieldProperties.m` | limitation | A requested field without definition raises an error instead of being left out | `test/verifiedTests/base/testIO/testUtilities/testGetDefinedFieldProperties.m` |
| `src/base/io/utilities/getDefinedFieldProperties.m` | limitation | SpecificFields is ignored together with Descriptions or DataBaseFields | `test/verifiedTests/base/testIO/testUtilities/testGetDefinedFieldProperties.m` |
| `src/base/io/utilities/initFBAFields.m` | limitation | The documented osense and csense fields are not created | `test/verifiedTests/base/testIO/testUtilities/testInitFBAFields.m` |
| `src/base/io/utilities/readSBML.m` | error | The documented default of defaultBound does not exist | `test/verifiedTests/base/testIO/testReadSBML.m` |
| `src/base/io/utilities/readSimPhenyCMPD.m` | limitation | A file without metabolite lines stops with an error | `test/verifiedTests/base/testIO/testUtilities/testReadSimPhenyCMPD.m` |
| `src/base/io/utilities/readSimPhenyCMPD.m` | cosmetic | Alternative names keep the blank that follows a '/' | `test/verifiedTests/base/testIO/testUtilities/testReadSimPhenyCMPD.m` |
| `src/base/io/utilities/readSimPhenyGPR.m` | limitation | A file without reaction lines stops with an error | `test/verifiedTests/base/testIO/testUtilities/testReadSimPhenyGPR.m` |
| `src/base/io/utilities/writeSBML.m` | error | A model without reactions cannot be written | `test/verifiedTests/base/testIO/testWriteSBML.m` |
| `src/base/io/utilities/writeSBML.m` | wrong-result | The compartments of the model and the given lists are replaced by the defaults | `test/verifiedTests/base/testIO/testWriteSBML.m` |
| `src/base/io/utilities/writeSBML.m` | error | The model annotation cannot be written | `test/verifiedTests/base/testIO/testWriteSBML.m` |
| `src/base/io/writeCbModel.m` | unusable-option | The JSON format is not detected from the file extension | `test/verifiedTests/base/testIO/testWriteCbModel.m` |
| `src/base/io/writeCbModel.m` | unusable-option | The file dialog offers an MPS export that does not exist | `test/verifiedTests/base/testIO/testWriteCbModel.m` |
| `src/base/parseMetNames.m` | limitation | Mixed or longer compartment notations are not parsed | `test/verifiedTests/base/testTools/testParseMetNames.m` |
| `src/base/paths/comparePaths.m` | limitation | Python path entries with blanks are reported as differences | `test/verifiedTests/base/testPaths/testComparePaths.m` |
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
| `src/base/solvers/getSetSolver/getAvailableSolversByType.m` | cosmetic | The output of initCobraToolbox is not silenced | `test/verifiedTests/base/testSolvers/testGetAvailableSolversByType.m` |
| `src/base/solvers/isCompatible.m` | wrong-result | The distributed compatibility matrix is not understood by the parser | `test/verifiedTests/base/testSolvers/testIsCompatible.m` |
| `src/base/solvers/mosek/setMosekParam.m` | wrong-result | The strict option never switches MOSEK to a free solve form | `test/verifiedTests/base/testSolvers/testSetMosekParam.m` |
| `src/base/solvers/param/changeCobraSolverParams.m` | cosmetic | The error for a parameter that is not allowed always names LP solvers | `test/verifiedTests/base/testSolvers/testChangeCobraSolverParams.m` |
| `src/base/solvers/param/changeCobraSolverParams.m` | cosmetic | solverType is documented as optional with default 'LP' but cannot be omitted | `test/verifiedTests/base/testSolvers/testChangeCobraSolverParams.m` |
| `src/base/solvers/param/getCobraSolverParams.m` | wrong-result | The global solver parameters are ignored when no paramStructure is given | `test/verifiedTests/base/testSolvers/testGetCobraSolverParams.m` |
| `src/base/solvers/param/getCobraSolverParams.m` | cosmetic | The structure output keeps the fields named in paramNames | `test/verifiedTests/base/testSolvers/testGetCobraSolverParams.m` |
| `src/base/solvers/param/getCobraSolverParams.m` | wrong-result | paramStructure 'default' returns the global values instead of the defaults | `test/verifiedTests/base/testSolvers/testGetCobraSolverParams.m` |
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
| `src/base/utilities/duplicates.m` | limitation | A cell array with more than one column is compared element by element, so M is not m x m | `test/verifiedTests/base/testTools/testDuplicates.m` |
| `src/base/utilities/getGlobalValue.m` | limitation | The value of a global named globalName cannot be read | `test/verifiedTests/base/testUtilities/testGetGlobalValue.m` |
| `src/base/utilities/removeIndicesInDimenion.m` | cosmetic | The help text says the given indices are removed, but they are the ones kept | `test/verifiedTests/base/testTools/testRemoveIndicesInDimenion.m` |
| `src/base/utilities/restoreEnvironment.m` | cosmetic | The printed path is cut at a folder name with a % sign | `test/verifiedTests/base/testUtilities/testRestoreEnvironment.m` |
| `src/base/utilities/setGlobal.m` | limitation | A global named globalName cannot be set | `test/verifiedTests/base/testUtilities/testSetGlobal.m` |
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
| `src/dataIntegration/chemoInformatics/inchi/getChargeFromInChI.m` | error | An empty component of a multi-component charge layer stops with an error | `test/verifiedTests/dataIntegration/testChemoInformatics/testGetChargeFromInChI.m` |
| `src/dataIntegration/chemoInformatics/inchi/getFormulaFromInChI.m` | wrong-result | A formula that loses all its hydrogen atoms keeps one H | `test/verifiedTests/dataIntegration/testChemoInformatics/testGetFormulaFromInChI.m` |
| `src/dataIntegration/chemoInformatics/inchi/getFormulaFromInChI.m` | wrong-result | Element counts are assigned to the wrong elements on the combining path | `test/verifiedTests/dataIntegration/testChemoInformatics/testGetFormulaFromInChI.m` |
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
| `src/reconstruction/modelGeneration/massBalance/getElementalComposition.m` | cosmetic | Formula numbers in error messages lose their zero padding inside parentheses | `test/verifiedTests/reconstruction/testModelGeneration/testGetElementalComposition.m` |
| `src/reconstruction/modelGeneration/massBalance/numAtomsOfElementInFormula.m` | cosmetic | A formula given as a cell or number stops with a MATLAB error, not the class error | `test/verifiedTests/reconstruction/testModelGeneration/testNumAtomsOfElementInFormula.m` |
| `src/reconstruction/modelGeneration/massBalance/numAtomsOfElementInFormula.m` | cosmetic | Output is printed at printLevel 0 | `test/verifiedTests/reconstruction/testModelGeneration/testNumAtomsOfElementInFormula.m` |
| `src/reconstruction/modelGeneration/massBalance/numAtomsOfElementInFormula.m` | limitation | Zero counts are replaced only when the formula holds a single zero | `test/verifiedTests/reconstruction/testModelGeneration/testNumAtomsOfElementInFormula.m` |
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
| `src/reconstruction/refinement/GPRLogic/AndNode.m` | limitation | A numeric literal ID is not deleted | `test/verifiedTests/reconstruction/testGPRLogic/testAndNode.m` |
| `src/reconstruction/refinement/GPRLogic/AndNode.m` | limitation | convertToDNF of an AndNode without children stops with an error | `test/verifiedTests/reconstruction/testGPRLogic/testAndNode.m` |
| `src/reconstruction/refinement/GPRLogic/FormulaParser.m` | limitation | An empty rule stops with an error | `test/verifiedTests/reconstruction/testGPRLogic/testFormulaParser.m` |
| `src/reconstruction/refinement/GPRLogic/FormulaParser.m` | limitation | createNodeStructure fails for a text with spaced operators that is not a stored key | `test/verifiedTests/reconstruction/testGPRLogic/testFormulaParser.m` |
| `src/reconstruction/refinement/GPRLogic/Node.m` | limitation | contains stops with an error on a node without children | `test/verifiedTests/reconstruction/testGPRLogic/testNode.m` |
| `src/reconstruction/refinement/GPRLogic/Node.m` | wrong-result | isequal is false for a tree with a repeated clause, and not symmetric | `test/verifiedTests/reconstruction/testGPRLogic/testNode.m` |
| `src/reconstruction/refinement/GPRLogic/Node.m` | wrong-result | isequal is false for equivalent trees with different literals | `test/verifiedTests/reconstruction/testGPRLogic/testNode.m` |
| `src/reconstruction/refinement/GPRLogic/Node.m` | wrong-result | removeDuplicateLiterals removes the wrong children when a child that is not a literal comes before a literal | `test/verifiedTests/reconstruction/testGPRLogic/testNode.m` |
| `src/reconstruction/refinement/GPRLogic/OrNode.m` | limitation | A numeric literal ID is not deleted | `test/verifiedTests/reconstruction/testGPRLogic/testOrNode.m` |
| `src/reconstruction/refinement/GPRLogic/OrNode.m` | limitation | convertToCNF of an OrNode without children returns an empty AndNode, which evaluates to true, while the empty OrNode evaluates to false | `test/verifiedTests/reconstruction/testGPRLogic/testOrNode.m` |
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

### `src/analysis/FVA/fastFVA/cleanFilesFastFVA.m`

#### cleanFilesFastFVA(false) fails when there are log files to remove

- **Severity**: error
- **Trigger**: cleanFilesFastFVA(false) with at least one *.log file in [CBTDIR]/src/analysis/FVA/fastFVA/logFiles
- **Observed**: MATLAB 2026-11-13: after printing " Number of files in logFiles/: 1" the call stops with "Unrecognized function or variable 'm'." (MATLAB:UndefinedFunction) at line 39; the log file is not removed. m is assigned only by the input() prompt of line 36, which runs only when userInteraction is true, and line 39 evaluates strcmpi(m, 'y') before ~userInteraction.
- **Expected**: all *.log files removed without a prompt and " >> All log files in logFiles/ removed." printed (the documented meaning of userInteraction = false)
- **Source lines**: 35-43
- **Documented in**: `test/verifiedTests/analysis/testFVA/testCleanFilesFastFVA.m`

### `src/analysis/FVA/fastFVA/mex/generateMexFastFVA.m`

#### printLevel 2 prints a truncated compilation command and a warning

- **Severity**: cosmetic
- **Trigger**: generateMexFastFVA(root, 2) with a CPLEX installation (include and library folders present)
- **Observed**: MATLAB 2026-11-13 (scratch run, mex stubbed): "Warning: Escaped character '\$' is not valid." and the printed command stops at CFLAGS=" because the command text is passed to fprintf as its format
- **Expected**: the whole compilation command printed, without a warning
- **Source lines**: 141-143
- **Documented in**: `test/verifiedTests/analysis/testFVA/testGenerateMexFastFVA.m`

#### the CPLEX root stays on the MATLAB path when the function stops with an error

- **Severity**: cosmetic
- **Trigger**: any call that ends with the errors of lines 89 or 102 (as in this test)
- **Observed**: MATLAB 2026-11-13: rootPathCPLEX, added to the path at line 66, is still on the path after the error; the path saved at line 63 is restored only at lines 163 and 173 (this test restores the path itself)
- **Expected**: the MATLAB path unchanged after the error
- **Source lines**: 63-66, 89, 102
- **Documented in**: `test/verifiedTests/analysis/testFVA/testGenerateMexFastFVA.m`

#### the existence of the CPLEX library file is never checked

- **Severity**: cosmetic
- **Trigger**: generateMexFastFVA(root, 0) with root/include/ilcplex and root/lib/x86-64_linux/static_pic present but no libcplex.a in the latter
- **Observed**: MATLAB 2026-11-13 (with mex replaced by a recording stub in a scratch run): the function goes on to "mex -setup c" and to the compilation, passing the missing .../static_pic/libcplex.a to mex; line 111 tests exist(lib, 'dir') again instead of the library file, so the error of line 112 cannot occur
- **Expected**: the error "The required CPLEX library file ... does not exist." of line 112
- **Source lines**: 110-112
- **Documented in**: `test/verifiedTests/analysis/testFVA/testGenerateMexFastFVA.m`

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

### `src/analysis/ecosystem/clusterEcosystemPoints.m`

#### The hierarchical method returns the requested maximum k as the number of clusters

- **Severity**: wrong-result
- **Trigger**: eco = struct('qualVectors', [1 0 0; 1 0 0; 0 3 0; 0 3 1]); [eco, clusters, k] = clusterEcosystemPoints(eco, 'printLevel', 0) (default k = 20)
- **Observed**: clusters = [1 2 3 4], k = 20 and eco.k = 20; getEcosystemClusterReactionValues then returns 20 columns, 16 of them NaN for empty clusters, and with 'changing' true it counts the NaN of the empty clusters as a change
- **Expected**: k = eco.k = 4, the number of clusters (OUTPUTS: "k: number of clusters", "eco.k (number of clusters)"), as the dbscan branch does with numel(unique(labels))
- **Source lines**: 173, 185
- **Documented in**: `test/verifiedTests/analysis/testEcosystem/testClusterEcosystemPoints.m`

### `src/analysis/ecosystem/getEcosystemClusterDescriptor.m`

#### The status variable is named status_c<id>, not status as documented

- **Severity**: cosmetic
- **Trigger**: getEcosystemClusterDescriptor([1 2; 0 0], {'a'; 'b'}, 1)
- **Observed**: VariableNames {'status_c1', 'diff'}, so descriptorTable.status errors
- **Expected**: a variable named status, as OUTPUT documents ("variables status ... and diff")
- **Source lines**: 67
- **Documented in**: `test/verifiedTests/analysis/testEcosystem/testGetEcosystemClusterDescriptor.m`

### `src/analysis/ecosystem/getQualitativeFluxStates.m`

#### Zero band applied inconsistently to the maximum and to max - min

- **Severity**: wrong-result
- **Trigger**: getQualitativeFluxStates([-1 2 -2], [0 2 -2], 0); and with the default band getQualitativeFluxStates([-1 2], [1e-9 2 + 1e-9], 1e-9)
- **Observed**: [5 2 -2] ({'err', '++', '--'}) for delta = 0, and [5 2] for delta = 1e-9: the state -1 requires max < delta (not <= delta) and the fixed states -3 and 3 require |max - min| < delta (not <= delta), so with delta = 0 they cannot occur
- **Expected**: [-1 3 -3] ({'-0', '+', '-'}) and [-1 3]: the documented table treats |x| <= delta, and a difference max - min within delta, as zero
- **Source lines**: 68, 75, 85
- **Documented in**: `test/verifiedTests/analysis/testEcosystem/testGetQualitativeFluxStates.m`

### `src/analysis/ecosystem/matchEcosystemClusters.m`

#### clusters without points are matched to a reference cluster instead of NaN, and an empty reference cluster absorbs unmatched clusters

- **Severity**: wrong-result
- **Trigger**: a cluster without points, whose column of representative states is all NaN (as getEcosystemClusterReactionValues returns it), in repValues or refValues; e.g. refValues = [1 2; 0 NaN; -1 -1], refRxnIds = {'R1'; 'R2'; 'R3'}, repValues = [0 3 7 NaN; 1 2 9 NaN; 5 5 5 NaN], rxnIds = {'R2'; 'R1'; 'R4'}, clusters = [1; 2; 3; 3; 1]; and, matching a clustering with itself, eco = struct('qualVectors', [1 0; 1 0; 2 3], 'clusters', [1; 1; 3], 'k', 3, 'rxn2cluster', {{'R1'; 'R2'}}), [~, v, ids] = getEcosystemClusterReactionValues(eco, 'thr', 0.8, 'changing', false), [newClusters, ~, clusterMap] = matchEcosystemClusters(v, ids, v, ids, eco.clusters)
- **Observed**: MATLAB 2026-11-13: first call: clusterMap = [1; 2; 3; 1] (cluster 4 has no points); second call: v = [1 NaN 2; 0 NaN 3], clusterMap = [1; 1; 2] and newClusters = [1; 1; 2]: the empty cluster 2 is mapped to 1 and cluster 3 is relabelled 2, the empty reference cluster, because a column without defined states agrees vacuously with every column (line 63)
- **Expected**: clusterMap NaN for clusters without points (documented output: first call clusterMap = [1; 2; 3; NaN]); by the evident intent, a reference cluster without points is no match, so matching a clustering with itself returns its own labels: newClusters = [1; 1; 3], clusterMap = [1; NaN; 3]
- **Source lines**: 58-67
- **Documented in**: `test/verifiedTests/analysis/testEcosystem/testMatchEcosystemClusters.m`

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

### `src/analysis/exploration/plotEssentialRxns.m`

#### Errors when no reaction is selected

- **Severity**: error
- **Trigger**: T = cell2table({'R_1'; 'R2'}, 'VariableNames', {'rxn'}); T.m1 = {50; 'NotIncluded'}; T.m2 = {NaN; 30}; plotEssentialRxns(T, [0 100], 5)
- **Observed**: MATLAB:nonLogicalConditional, Operands to the logical AND (&&) and OR (||) operators must be convertible to logical scalar values. Use the ANY or ALL functions to reduce operands to logical scalar values. (max of an empty matrix is empty)
- **Expected**: no heat map, the message 'Attention: All non-essential reactions have flux above the threshold' and an empty list of reactions
- **Source lines**: 65-85
- **Documented in**: `test/verifiedTests/analysis/testExploration/testPlotEssentialRxns.m`

#### The output is a cell array of reaction identifiers, not a table of fluxes

- **Severity**: cosmetic
- **Trigger**: plotEssentialRxns(T, [0 100], 1) with the table above
- **Observed**: {'R_1'; 'R2'} (class cell), from table2cell of the rxn column
- **Expected**: per the OUTPUT section, a table with the fluxes of the reactions of interest (rows) across models (columns); the code and the tutorial use the identifiers, so the header is the likely error
- **Source lines**: 52
- **Documented in**: `test/verifiedTests/analysis/testExploration/testPlotEssentialRxns.m`

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

### `src/analysis/fastForest/extractSubsetFeaturesfromFile.m`

#### The last sample of the file is not written to the subset file

- **Severity**: wrong-result
- **Trigger**: a file feat.txt with the lines 'sample<TAB>f1<TAB>f2<TAB>f3', 's1<TAB>1<TAB>2<TAB>3', 's2<TAB>4<TAB>5<TAB>6', 's3<TAB>7<TAB>8<TAB>9'; extractSubsetFeaturesfromFile(file, {'f1', 'f3'})
- **Observed**: feat.txt_subset.txt holds 'sample,f1,f3', 's1,1,3', 's2,4,6' (the write loop runs to length(keep)-1)
- **Expected**: also 's3,7,9', the requested subset of every sample
- **Source lines**: 61
- **Documented in**: `test/verifiedTests/analysis/testFastForest/testExtractSubsetFeaturesfromFile.m`

#### The subset file is left open

- **Severity**: limitation
- **Trigger**: any call
- **Observed**: after the call openedFiles() still lists the identifier of <fileName>_subset.txt; the function has no fclose for it
- **Expected**: the output file closed before the function returns
- **Source lines**: 60-63
- **Documented in**: `test/verifiedTests/analysis/testFastForest/testExtractSubsetFeaturesfromFile.m`

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

### `src/analysis/igemRNA/LT1/findGenesAboveThresholdLocal1.m`

#### Errors when no gene qualifies

- **Severity**: error
- **Trigger**: findGenesAboveThresholdLocal1(100, workbook, 1) with the workbook above
- **Observed**: MATLAB:unassignedOutputs, Output argument "genes" (and possibly others) not assigned a value in the execution with "findGenesAboveThresholdLocal1" function.
- **Expected**: an empty list of genes
- **Source lines**: 1, 51-69
- **Documented in**: `test/verifiedTests/analysis/testLT1/testFindGenesAboveThresholdLocal1.m`

#### The local threshold is the sum divided by the row length minus one, not the mean

- **Severity**: wrong-result
- **Trigger**: a workbook with sheets S1_P (g1 = 10, g2 = 2) and S2_P (g1 = 20, g2 = 2); findGenesAboveThresholdLocal1(5, workbook, 1)
- **Observed**: {"g1", 10, 'High', 'Local'}: avg = expressionSum/length(row)-1 is evaluated as (10 + 20) / 3 - 1 = 9 (the row also holds the gene ID), so 10 passes the local test
- **Expected**: no gene: the local threshold of g1 is its mean over the two sheets, 15, and 10 < 15
- **Source lines**: 60-61
- **Documented in**: `test/verifiedTests/analysis/testLT1/testFindGenesAboveThresholdLocal1.m`

### `src/analysis/igemRNA/LT1/findGenesBelowThresholdLocal1.m`

#### Errors when no gene qualifies

- **Severity**: error
- **Trigger**: findGenesBelowThresholdLocal1(-100, workbook, 1) with the workbook above
- **Observed**: MATLAB:unassignedOutputs, Output argument "genes" (and possibly others) not assigned a value in the execution with "findGenesBelowThresholdLocal1" function.
- **Expected**: an empty list of genes
- **Source lines**: 1, 51-75
- **Documented in**: `test/verifiedTests/analysis/testLT1/testFindGenesBelowThresholdLocal1.m`

#### The local threshold is the sum divided by the row length minus one, not the mean

- **Severity**: wrong-result
- **Trigger**: a workbook with sheets S1_P (g1 = 10, g2 = 2) and S2_P (g1 = 20, g2 = 2); findGenesBelowThresholdLocal1(5, workbook, 1)
- **Observed**: {'g2', 2, 'Low', 'Global'} only: avg = expressionSum/length(row)-1 is evaluated as (10 + 20) / 3 - 1 = 9 (the row also holds the gene ID), so g1 (10) is not below its local threshold
- **Expected**: also {'g1', 10, 'Low', 'Local'}: the local threshold of g1 is its mean over the two sheets, 15, and 10 < 15
- **Source lines**: 66-67
- **Documented in**: `test/verifiedTests/analysis/testLT1/testFindGenesBelowThresholdLocal1.m`

### `src/analysis/igemRNA/LT2/findGenesAboveThresholdLocal2.m`

#### Errors when no gene qualifies

- **Severity**: error
- **Trigger**: findGenesAboveThresholdLocal2(100, 200, workbook, 1) with the workbook above
- **Observed**: MATLAB:unassignedOutputs, Output argument "genes" (and possibly others) not assigned a value in the execution with "findGenesAboveThresholdLocal2" function.
- **Expected**: an empty list of genes
- **Source lines**: 1, 52-76
- **Documented in**: `test/verifiedTests/analysis/testLT2/testFindGenesAboveThresholdLocal2.m`

#### The local threshold is the sum divided by the row length minus one, not the mean

- **Severity**: wrong-result
- **Trigger**: a workbook with sheets S1_P (g1 = 10, g2 = 2) and S2_P (g1 = 20, g2 = 2); findGenesAboveThresholdLocal2(5, 100, workbook, 1)
- **Observed**: {"g1", 10, 'High', 'Local'}: avg = expressionSum/length(row)-1 is evaluated as (10 + 20) / 3 - 1 = 9 (the row also holds the gene ID), so 10 passes the local test
- **Expected**: no gene: the local threshold of g1 is its mean over the two sheets, 15, and 10 < 15; g2 = 2 is below the lower threshold
- **Source lines**: 67-68
- **Documented in**: `test/verifiedTests/analysis/testLT2/testFindGenesAboveThresholdLocal2.m`

### `src/analysis/igemRNA/LT2/findGenesBelowThresholdLocal2.m`

#### Errors when no gene qualifies

- **Severity**: error
- **Trigger**: findGenesBelowThresholdLocal2(-100, -50, workbook, 1) with the workbook above
- **Observed**: MATLAB:unassignedOutputs, Output argument "genes" (and possibly others) not assigned a value in the execution with "findGenesBelowThresholdLocal2" function.
- **Expected**: an empty list of genes
- **Source lines**: 1, 52-76
- **Documented in**: `test/verifiedTests/analysis/testLT2/testFindGenesBelowThresholdLocal2.m`

#### The local threshold is the sum divided by the row length minus one, not the mean

- **Severity**: wrong-result
- **Trigger**: a workbook with sheets S1_P (g1 = 10, g2 = 2) and S2_P (g1 = 20, g2 = 2); findGenesBelowThresholdLocal2(5, 100, workbook, 1)
- **Observed**: {'g2', 2, 'Low', 'Global'} only: avg = expressionSum/length(row)-1 is evaluated as (10 + 20) / 3 - 1 = 9 for g1 (the row also holds the gene ID), and 10 is not below 9
- **Expected**: also {'g1', 10, 'Low', 'Local'}: the local threshold of g1 is its mean over the two sheets, 15, and 10 < 15
- **Source lines**: 67-68
- **Documented in**: `test/verifiedTests/analysis/testLT2/testFindGenesBelowThresholdLocal2.m`

### `src/analysis/igemRNA/filterNonFluxReactions/filterNonFluxReactions.m`

#### The result file is written next to the result folder, not into it

- **Severity**: wrong-result
- **Trigger**: any call, for example filterNonFluxReactions('WT')
- **Observed**: the path is built without a file separator, so the result goes to resultsPostOptimization/nonFluxReactionsnonFluxReactionsWT.xls and the folder nonFluxReactions stays empty. The first section below therefore compares the reference with the file stored in this folder, not with a new result.
- **Expected**: resultsPostOptimization/nonFluxReactions/nonFluxReactionsWT.xls
- **Source lines**: 84
- **Documented in**: `test/verifiedTests/analysis/testFilterNonFluxReactions/testFilterNonFluxReactions.m`

### `src/analysis/igemRNA/findUpDownRegulatedGenes/findUpDownRegulatedGenes.m`

#### Errors when the source sheet holds no gene

- **Severity**: limitation
- **Trigger**: findUpDownRegulatedGenes({'E'}, {'E'}, workbook) with a sheet E that has only the header Geneid, Data
- **Observed**: MATLAB:unassignedOutputs, Output argument "result" (and possibly others) not assigned a value in the execution with "findUpDownRegulatedGenes" function.
- **Expected**: an empty result
- **Source lines**: 1, 29
- **Documented in**: `test/verifiedTests/analysis/testFindUpDownRegulatedGenes/testFindUpDownRegulatedGenes.m`

#### Genes are matched by row position, not by gene ID

- **Severity**: limitation
- **Trigger**: source sheet A (g1 = 1, g2 = 5, g3 = 3) and target sheet with the same genes in the order g3 = 3, g2 = 4, g1 = 2, or a target sheet with only g1 = 2
- **Observed**: reordered target: {'g1', 1, 3, 'Up'; 'g2', 5, 4, 'Down'; 'g3', 3, 2, 'Down'} (the target values of g3 and g1 are swapped); shorter target: MATLAB:badsubscript is caught and displayed and {'g1', 1, 2, 'Up'; 'g2', 5, [], []} is returned
- **Expected**: g1 compared with 2 and g3 with 3; a missing gene reported or rejected. The function assumes both sheets list the same genes in the same order
- **Source lines**: 30-32
- **Documented in**: `test/verifiedTests/analysis/testFindUpDownRegulatedGenes/testFindUpDownRegulatedGenes.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/correlateFluxWithTaxonAbundance.m`

#### Every call stops with an error when the taxonomy is prepared for export

- **Severity**: error
- **Trigger**: any input that reaches line 262, for example abundance file 'ID,S1,S2,S3,S4,S5' with Bact_a 0.1..0.5, Bact_b 0.5..0.1, Esch_c 0.4 in every sample; taxonomy file 'MicrobeID,Phylum,Class,Order,Family,Genus,Species' with Bact_a P1,C1,O1,F1,G1,Sp1, Bact_b P1,C1,O1,F1,G1,Sp2, Esch_c P2,C2,O2,F2,G2,Sp3; flux file 'ID,EX_ac[fe],EX_but[fe]' with samples S1-S5 as rows; correlateFluxWithTaxonAbundance(abundancePath, fluxPath, infoFilePath)
- **Observed**: MATLAB:colon:operandsNotRealScalar, Colon operands must be real scalars. Line 260 sets taxonCol = 'Phylum' and line 262 indexes taxonomy(:, taxonCol+1:end) with a character vector as colon operand (MATLAB R2025a). The folder Taxon_Flux_Correlations is already created in the current folder.
- **Expected**: the correlations, p-values and taxonomy information returned and written to Taxon_Flux_Correlations
- **Source lines**: 260-262
- **Documented in**: `test/verifiedTests/analysis/testAdditionalAnalysis/testCorrelateFluxWithTaxonAbundance.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/makeViolinPlots.m`

#### Box plots print the handle array of every plot

- **Severity**: cosmetic
- **Trigger**: makeViolinPlots(sampleData, {}, 'plotType', 'Boxplot') with a plotted feature
- **Observed**: "ans = 7x1 Line array" (7x<groups> with stratification) is printed for every plot: the calls to cobraBoxplot have no semicolon
- **Expected**: no console output
- **Source lines**: 102, 199
- **Documented in**: `test/verifiedTests/analysis/testAdditionalAnalysis/testMakeViolinPlots.m`

#### Features with negative values are dropped as if they were all zero

- **Severity**: limitation
- **Trigger**: a row of sampleData whose values sum below 1e-4, for example {'EX_glc_D[fe]', -1, -2, -3, -4, -5, -6}
- **Observed**: the row is removed (line 63 tests sum(...) < 0.0001) and no plot is drawn; likewise a group whose values sum to zero is overwritten with 1e-7 (lines 188-189)
- **Expected**: only features that are all zero removed (code comment "remove fluxes that are all zeros"); data of any sign plotted
- **Source lines**: 63, 188-189
- **Documented in**: `test/verifiedTests/analysis/testAdditionalAnalysis/testMakeViolinPlots.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/performStatisticalAnalysis.m`

#### Fecal exchange features never get a metabolite description

- **Severity**: cosmetic
- **Trigger**: the call above; the metabolite ac (Acetate) is in the VMH database
- **Observed**: the Description of EX_ac[fe] is 'NA'. The condition on line 230 includes the header 'Feature' of Statistics(:,1), which never contains '[fe]', so the prefix and suffix are never stripped.
- **Expected**: 'Acetate'
- **Source lines**: 230-232
- **Documented in**: `test/verifiedTests/analysis/testAdditionalAnalysis/testPerformStatisticalAnalysis.m`

#### Samples whose values are all zero are not removed

- **Severity**: wrong-result
- **Trigger**: sampleData = {'', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7'; 'EX_ac[fe]', 1, 2, 3, 10, 11, 12, 0; 'ATPM', 5, 6, 7, 1, 2, 3, 0}; sampleInformation = {'ID', 'Group'; 'S1', 'A'; 'S2', 'A'; 'S3', 'A'; 'S4', 'B'; 'S5', 'B'; 'S6', 'B'; 'S7', 'A'}; performStatisticalAnalysis(sampleData, sampleInformation, 'BHFDR', true)
- **Observed**: the all-zero sample S7 stays in significantFeatures and in the tests: p-values before correction 0.0518 and 0.3768, Average_A 1.5 and 4.5 (without S7: 0.0809, 0.0809, 2 and 6). Line 75 applies str2double to numeric cells, which gives NaN, so the all-zero condition never holds (MATLAB R2025a).
- **Expected**: S7 removed (code comment "delete columns that are all zeros") and the statistics of S1 to S6
- **Source lines**: 75-77
- **Documented in**: `test/verifiedTests/analysis/testAdditionalAnalysis/testPerformStatisticalAnalysis.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/plotFluxesAgainstOrganismAbundances.m`

#### The current folder stays Metabolite_plots after an error

- **Severity**: cosmetic
- **Trigger**: abundance and flux tables with different samples
- **Observed**: after the error of line 38, pwd is <current folder>/Metabolite_plots (the cd .. of line 90 is not reached)
- **Expected**: the current folder of the caller
- **Source lines**: 26, 38, 90
- **Documented in**: `test/verifiedTests/analysis/testAdditionalAnalysis/testPlotFluxesAgainstOrganismAbundances.m`

#### The documented orientation of the flux table and relative file paths stop with an error

- **Severity**: error
- **Trigger**: a flux file with sample IDs as rows and reactions as columns, as documented ('ID,EX_ac[fe],EX_but[fe]' then 'S1,1,3', 'S2,2,1', 'S3,3,2') with an abundance file 'ID,S1,S2,S3' / 'panBact_a,0.1,0.2,0.3' / 'Esch_c,0.9,0.8,0.7'; or the file names relative to the current folder: plotFluxesAgainstOrganismAbundances('abun2.csv', 'flux2.csv')
- **Observed**: Sample IDs in abundance and flux files do not agree! (line 37 compares the first row of the flux table with the samples; no transposition as in correlateFluxWithTaxonAbundance). Relative names: Unable to find or open 'abun2.csv'. Check the path and filename or file permissions., because line 26 changes to Metabolite_plots before the files are read.
- **Expected**: the plots of the documented layout (sample IDs as rows) and of files given relative to the current folder
- **Source lines**: 26, 29, 37-39
- **Documented in**: `test/verifiedTests/analysis/testAdditionalAnalysis/testPlotFluxesAgainstOrganismAbundances.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/addMicrobeCommunityBiomass.m`

#### Abundance weights are rounded to six significant digits

- **Severity**: wrong-result
- **Trigger**: weights with more than six significant digits, for example three microbes without abundances (weights 1/3) or abundances [0.123456789; 0.2; 0.676543211]
- **Observed**: the reactions are added through their printed formulas (printRxnFormula, then addReaction), so the coefficients become -0.333333 (sum 0.999999) and -0.123457, -0.676543 instead of the given weights
- **Expected**: the coefficients of communityBiomass equal the given abundances, or 1/n, exactly
- **Source lines**: 47-50
- **Documented in**: `test/verifiedTests/analysis/testMultiSpeciesModelling/testAddMicrobeCommunityBiomass.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/extractFullRes.m`

#### Errors when the first sample is infeasible and a later one is feasible

- **Severity**: error
- **Trigger**: ID = {'EX_a[fe]'; 'EX_b[fe]'}; fva = cell(3, 2); ns = cell(3, 2); fva{2, 2} = {'EX_a[fe]', -1, 2; 'EX_b[fe]', -3, 4}; ns{2, 2} = {'EX_a[fe]', -5, 6; 'EX_b[fe]', -7, 8}; extractFullRes([tempname filesep], ID, 'sDiet', {'s1'; 's2'}, fva, ns)
- **Observed**: prints 'Jumping not feasible model', then MATLAB:catenate:dimensionMismatch, Dimensions of arrays being concatenated are not consistent. The 'Rxn' column name is added to the header only when k == 1, so the header row has 4 columns and the flux rows 5.
- **Expected**: the infeasible sample s1 is skipped, as the message says, and the table Rxn, minUpt_s2, maxUpt_s2, minScr_s2, maxScr_s2 with the fluxes of s2 is returned and written
- **Source lines**: 70-76
- **Documented in**: `test/verifiedTests/analysis/testMgPipe/testExtractFullRes.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/mgSimResCollect.m`

#### The feasibility of every diet is read from the last diet

- **Severity**: wrong-result
- **Trigger**: rDiet = 1, pDiet = 0, three samples with rich-diet and input-diet results, except netProduction{2,3} = {} and netUptake{2,3} = {} (input diet infeasible for S3); mgSimResCollect([resDir filesep], {'S1'; 'S2'; 'S3'}, exchanges, 1, 0, '', netProduction, netUptake, '-dpng')
- **Observed**: rich_net_secretion_fluxes.csv holds NaN for S3 although netProduction{1,3} holds its rich-diet results: line 72 tests isempty(netProduction{fl,k}) (the last diet) instead of netProduction{j,k}. With the opposite pattern (last diet filled, an earlier diet empty) line 83 indexes an empty cell.
- **Expected**: the rich-diet values of S3
- **Source lines**: 72
- **Documented in**: `test/verifiedTests/analysis/testMgPipe/testMgSimResCollect.m`

#### Two samples stop with an error in the PCoA

- **Severity**: limitation
- **Trigger**: the first call above with two samples {'S1'; 'S2'} (cells of S1 and S2 only)
- **Observed**: cobraCmdscale: D must have a zero diagonal (or ones for a similarity matrix). cobraPdist of two samples returns one distance, a scalar that is read as a 1-by-1 matrix; the check on line 125 ("too few individuals to plot") is not reached.
- **Expected**: no PCoA, as for too few individuals, and the flux tables written
- **Source lines**: 119-120
- **Documented in**: `test/verifiedTests/analysis/testMgPipe/testMgSimResCollect.m`

#### Uptake of an exchange missing from a sample is copied from the previous sample

- **Severity**: wrong-result
- **Trigger**: exchanges = {'EX_ac[fe]'; 'EX_glc_D[fe]'}; netProduction = cell(3, 3); netUptake = cell(3, 3); netProduction{2,1} = {'EX_ac[fe]', -1, 3; 'EX_glc_D[fe]', -2, 5}; netUptake{2,1} = {'EX_ac[fe]', 4, -1; 'EX_glc_D[fe]', 7, -1}; netProduction{2,2} = {'EX_ac[fe]', -1, 2; 'EX_glc_D[fe]', [], []}; netUptake{2,2} = {'EX_ac[fe]', 6, -1; 'EX_glc_D[fe]', [], []}; netProduction{2,3} = {'EX_ac[fe]', -1, 9; 'EX_glc_D[fe]', -2, 1}; netUptake{2,3} = {'EX_ac[fe]', 2, -1; 'EX_glc_D[fe]', 3, -1}; [sec, upt] = mgSimResCollect([resDir filesep], {'S1'; 'S2'; 'S3'}, exchanges, 0, 0, '', netProduction, netUptake, '-dpng')
- **Observed**: upt{3,3} (EX_glc_D[fe] in S2, absent from that sample) is 6, the value |7 + -1| of S1, while sec{3,3} is 0. Only sp is reset for each sample (line 81); up keeps the values of the previous sample where the FVA value is empty.
- **Expected**: 0 for the missing exchange, as for the net secretion
- **Source lines**: 81, 95-97
- **Documented in**: `test/verifiedTests/analysis/testMgPipe/testMgSimResCollect.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/parsave.m`

#### A structure without a rxns field is silently not saved

- **Severity**: limitation
- **Trigger**: parsave(fullfile(tempname, 'x.mat'), struct('a', 1))
- **Observed**: no file is written and no warning or error is raised (the isfield test on line 15 has no else branch)
- **Expected**: per the header ('Saves a data variable (e.g., model)'), the structure is saved; the callers in the toolbox pass only models or cell arrays
- **Source lines**: 15
- **Documented in**: `test/verifiedTests/analysis/testMgPipe/testParsave.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/plotMappingInfo.m`

#### The documented matrix inputs stop with an error

- **Severity**: error
- **Trigger**: plotMappingInfo([resDir filesep], [2 2 2 2 2 2], [1 2 3 4 5 6; 6 5 4 3 2 1], [1 0 1; 0 1 1; 1 1 0; 1 0 0; 0 0 1; 1 1 1], [3 4 5 3 4 5], '', '-dpng')
- **Observed**: MATLAB:table2cell:NonTable, Input argument must be a table. (line 48; the PCoA lines 101 and 169 also call table2cell on reacTab)
- **Expected**: reacPat and reacTab are documented as a matrix and a binary matrix
- **Source lines**: 48, 101, 169
- **Documented in**: `test/verifiedTests/analysis/testMgPipe/testPlotMappingInfo.m`

#### The heatmap shows only the first four individuals

- **Severity**: wrong-result
- **Trigger**: reacPat = cell2table({'org1', 1, 2, 3, 4, 5, 6; 'org2', 6, 5, 4, 3, 2, 1}); reacTab = cell2table({'s1', 1, 0, 1; 's2', 0, 1, 1; 's3', 1, 1, 0; 's4', 1, 0, 0; 's5', 0, 0, 1; 's6', 1, 1, 1}); plotMappingInfo([resDir filesep], [2 2 2 2 2 2], reacPat, reacTab, [3 4 5 3 4 5], '', '-dpng')
- **Observed**: the image of the heatmap figure has CData of size 2-by-4: line 48 plots columns 2:5 of reacPat (hard-coded), so individuals 5 and 6 are missing while the x axis has six ticks.
- **Expected**: a 2-by-6 heatmap, one column per individual
- **Source lines**: 48
- **Documented in**: `test/verifiedTests/analysis/testMgPipe/testPlotMappingInfo.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/translateMetagenome2AGORA.m`

#### Abundances read from a tsv file are added and normalized as text

- **Severity**: wrong-result
- **Trigger**: an input file with the extension .tsv, the format named in the help text
- **Observed**: readInputTableForPipeline returns the numbers of a tsv file as text, so the two rows of one taxon with 4 and 2 add up to 102 ('4' + '2') and the normalized abundances of 4 and 3 are 0.5049 and 0.4951 (character codes) instead of 0.5714 and 0.4286
- **Expected**: the abundances are summed and normalized as numbers
- **Source lines**: 224, 258
- **Documented in**: `test/verifiedTests/analysis/testMultiSpeciesModelling/testTranslateMetagenome2AGORA.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/updateTaxonomyInfoAGORA.m`

#### The row counter is printed for every strain

- **Severity**: cosmetic
- **Trigger**: updateTaxonomyInfoAGORA() with information tables of one or more strains
- **Observed**: "i = 2", "i = 3", ... printed for every row of both tables (the statement i has no semicolon)
- **Expected**: no console output, or progress gated behind a print level
- **Source lines**: 38, 87
- **Documented in**: `test/verifiedTests/analysis/testMgPipe/testUpdateTaxonomyInfoAGORA.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/calculateInteractionsByTaxon.m`

#### Errors when the taxon table has fewer rows than columns

- **Severity**: error
- **Trigger**: pw = {'Pair', 'M1', 'M2', 'a', 'b', 'c', 'd', 'Outcome1', 'Outcome2'; 'A_B', 'A', 'B', 0, 0, 0, 0, 'Competition', 'Competition'}; tx = {'ModelID', 'Genus', 'Family', 'Order', 'Class', 'Phylum'; 'A', 'g1', 'f1', 'o1', 'c1', 'p1'; 'B', 'g2', 'f1', 'o1', 'c1', 'p1'}; calculateInteractionsByTaxon(pw, tx)
- **Observed**: MATLAB:badsubscript, Index in position 1 exceeds array bounds. Index must not exceed 3. The loop on line 42 runs over length(taxonInformation), the larger dimension (6 columns), instead of the 3 rows, and line 43 reads row 4.
- **Expected**: one Competition counted for each of g1 and g2, two for family f1 and for every higher level (the header requires six columns and any number of microbes)
- **Source lines**: 42-43
- **Documented in**: `test/verifiedTests/analysis/testMultiSpeciesModelling/testCalculateInteractionsByTaxon.m`

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

### `src/analysis/persephone/additionalFunctions/combineFluxResults.m`

#### Errors for a common germ-free sample preceded by a sample of the first run only

- **Severity**: error
- **Trigger**: folder d1 holds FBA_sol_A1.mat (all variables, shadowPriceBIO = 10) and FBA_sol_GF_female.mat (rxns, ID, sex, f, stat, OrigStat); folder d2 holds FBA_sol_GF_female.mat (rxns, f, stat, OrigStat); combineFluxResults(d1, d2, d3)
- **Observed**: MATLAB:nonExistentField, Unrecognized field name "shadowPriceBIO". (line 95, reached because line 93 tests the non-GF file A1 instead of the GF sample)
- **Expected**: the GF sample is merged without shadow prices
- **Source lines**: 93-96
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testCombineFluxResults.m`

#### Shadow prices of the second run are dropped when the folders hold different samples

- **Severity**: wrong-result
- **Trigger**: folder d1 holds FBA_sol_GF_female.mat (rxns, ID, sex, f, stat, OrigStat) and FBA_sol_S1.mat (rxns = {'r1'}, ID, sex, speciesBIO, shadowPriceBIO = 10, f = 1, stat, relAbundances, OrigStat); folder d2 holds FBA_sol_S1.mat (rxns = {'r2'}, shadowPriceBIO = 20, f = 2, stat, OrigStat); combineFluxResults(d1, d2, d3)
- **Observed**: d3/S1.mat holds rxns {'r1' 'r2'} and f [1 2] but shadowPriceBIO 10. Line 93 tests pathsRun1(i) (here the GF file of the first run) instead of the path of the i-th common sample, pathsRun1_commonSamples(i).
- **Expected**: shadowPriceBIO [10 20], as for any non-GF sample
- **Source lines**: 93-96
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testCombineFluxResults.m`

### `src/analysis/persephone/additionalFunctions/convertVMHIDName.m`

#### Names of unknown IDs are dropped, so names and IDs do not line up

- **Severity**: wrong-result
- **Trigger**: [ids, names] = convertVMHIDName(false, {'atp', 'notAnId', 'h2o'}, 0)
- **Observed**: names = {'ATP'; 'Water'}, two names for three IDs (intersect with 'stable' on line 72 drops the unknown ID and duplicates)
- **Expected**: one entry per ID, in the order of the IDs (empty for an unknown ID)
- **Source lines**: 72-73
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testConvertVMHIDName.m`

#### The numeric skip flag 0 for metNames raises an error

- **Severity**: error
- **Trigger**: convertVMHIDName(0, {'atp'}, 0)
- **Observed**: the numeric 0 is not logical, so it is treated as a list of names (line 107) and brace indexing fails on line 129: MATLAB:cellRefFromNonCell, Brace indexing is not supported for variables of this type.
- **Expected**: 0 skips the conversion, as the header says (false works)
- **Source lines**: 107, 183
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testConvertVMHIDName.m`

#### The skip flag 0 for VMHIDs raises an error

- **Severity**: error
- **Trigger**: convertVMHIDName(false, 0, 0) or convertVMHIDName({'ATP'}, 0, 0)
- **Observed**: prints 'VMH IDs provided, finding corresponding names from VMH', then MATLAB:cellRefFromNonCell, Brace indexing is not supported for variables of this type. (line 52; MATLAB R2025a): exist('VMHIDs', 'var') is true for any passed value, and the skip branch tests the undefined name VMHIDS
- **Expected**: the conversion of IDs to names skipped, as the header documents for the flag 0
- **Source lines**: 38, 50-53, 97
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testConvertVMHIDName.m`

#### similarMets is never assigned from the suggestions

- **Severity**: error
- **Trigger**: [ids, names, similar] = convertVMHIDName({'ATP', 'lactate'}, {'atp'}, 1)
- **Observed**: MATLAB:unassignedOutputs, Output argument "similarMets" (and possibly others) not assigned a value: line 179 tests ischar('similarMets'), the literal text, which is always true
- **Expected**: similarMets holds the suggestions for the names not found
- **Source lines**: 179-181
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testConvertVMHIDName.m`

### `src/analysis/persephone/additionalFunctions/dimensionalityReductionAndMultivariateAnalysis.m`

#### A text (cell array) variable of interest is not supported

- **Severity**: limitation
- **Trigger**: M and s as in the first entry; meta = table((1:10)', [repmat({'a'}, 5, 1); repmat({'b'}, 5, 1)], 'VariableNames', {'V2', 'Group'}, 'RowNames', s'); (text as a cellstr, as readtable returns it by default) called with varOfInterest 'Group'
- **Observed**: MATLAB:math:mustBeNumericCharOrLogical, Invalid data type. Argument must be numeric, char, or logical. (line 162 compares cells with ==); string and categorical variables pass this line
- **Expected**: groups of a text variable are plotted as those of a categorical one
- **Source lines**: 162
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testDimensionalityReductionAndMultivariateAnalysis.m`

#### Errors when the regression of a metadata variable gives a warning

- **Severity**: error
- **Trigger**: rng(1); s = arrayfun(@(k) sprintf('s%d', k), 1:10, 'UniformOutput', false); M = array2table(rand(6, 10) + 0.1, 'VariableNames', s, 'RowNames', {'t1', 't2', 't3', 't4', 't5', 't6'}); meta = table((1:10)', ones(10, 1), 'VariableNames', {'V2', 'Const'}, 'RowNames', s'); dimensionalityReductionAndMultivariateAnalysis(M, meta, 'V2', [tempname filesep], 'numLoadings', 3)
- **Observed**: warning 'Regression design matrix is rank deficient to within machine precision.' from cobraFitlm (line 248) for the constant variable, then MATLAB:table:VarDimensionMismatch, The number of table variables in an assignment must match. (line 255 assigns 12 values to a row of the 10-column table)
- **Expected**: the row of that variable holds its formula, predictor, regression type and NaN statistics (as the comment 'do not save the result' intends) and the analysis continues
- **Source lines**: 255
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testDimensionalityReductionAndMultivariateAnalysis.m`

#### The loadings figure of PC 1 is saved as Loadings_PC11.png

- **Severity**: cosmetic
- **Trigger**: any call with inputDataType 'abundance' and PCofInterest 1
- **Observed**: file Loadings_PC11.png (a literal '1' follows the PC number)
- **Expected**: Loadings_PC1.png
- **Source lines**: 229
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testDimensionalityReductionAndMultivariateAnalysis.m`

#### The regression figures pair the values of one variable with the name of another

- **Severity**: wrong-result
- **Trigger**: M as above (rng(1), 6 x 10); pc1 = first score column of cobraPca(clr(M)', 'Centered', false, 'Algorithm', 'als'); metadata V1 = rand, V2 = pc1 + 0.01 * randn, V3 = -pc1 + 0.3 * std(pc1) * randn (10 x 1 each); call with varOfInterest 'V2' and 'numLoadings', 3
- **Observed**: the CSV table (sorted by p-value) holds V2 R2 0.99989 estimate 1.0014, V3 R2 0.91242 estimate -0.95694, V1 R2 0.0090745 estimate 0.37112; the R2 bar chart shows [0.9124 0.0091] and the coefficient chart [-0.9569 0.3711], both labelled {V2, V3}. significantIdx (line 285) comes from the unsorted p-values but indexes the table sorted on line 278; line 328 labels the sorted points with the unsorted names.
- **Expected**: R2 [0.99989 0.91242] and coefficients [1.0014 -0.95694] labelled {V2, V3}
- **Source lines**: 285-288, 328
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testDimensionalityReductionAndMultivariateAnalysis.m`

### `src/analysis/persephone/additionalFunctions/generatePanAGORA2database.m`

#### Hard-coded personal input folder

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: line 15 sets a folder under a Windows user profile (C:\Users\...), line 16 looks it up and line 17 overwrites the result with what('AGORA2')
- **Expected**: no leftover machine-specific path (lines 15-16 have no effect)
- **Source lines**: 15-16
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testGeneratePanAGORA2database.m`

#### Only the first three strains are processed

- **Severity**: wrong-result
- **Trigger**: a folder named AGORA2 on the MATLAB path holding strain1.mat to strain4.mat (each a struct model with rxns = {'r<k>'}, mets = {'x'}, S = sparse(1)); from a writable folder: p = generatePanAGORA2database(); s = load(p)
- **Observed**: s.agoraStruct.strains = {'strain1'; 'strain2'; 'strain3'} and s.agoraStruct.rxns = {'r1'; 'r2'; 'r3'}; strain4 and r4 are missing (line 26 keeps strains(1:3))
- **Expected**: all four strains and reactions, as the header says (which reactions and metabolites are present in which AGORA2 strains)
- **Source lines**: 26
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testGeneratePanAGORA2database.m`

### `src/analysis/persephone/additionalFunctions/generatePanDatabase.m`

#### Coefficients of new metabolites are written to the wrong rows

- **Severity**: wrong-result
- **Trigger**: folder d with mA.mat (struct model, rxns = {'r1'}, mets = {'x'}, S = sparse(1)) and mB.mat (rxns = {'r1'}, mets = {'x'; 'z'; 'y'}, S = sparse([1; 2; 3])); p = generatePanDatabase(d); s = load(p)
- **Observed**: s.panModel.mets = {'x'; 'y'; 'z'} and full(s.panModel.S) = [1; 2; 3]. The new metabolites are appended in sorted order (setdiff, line 159) but their rows are taken from model 2 in its own order (matches, line 179).
- **Expected**: [1; 3; 2] (y has the coefficient 3 and z the coefficient 2 in mB)
- **Source lines**: 176-181
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testGeneratePanDatabase.m`

#### Coefficients of new reactions are written to the wrong columns

- **Severity**: wrong-result
- **Trigger**: as above with mB.mat (rxns = {'r1'; 'r3'; 'r2'}, mets = {'x'}, S = sparse([1 3 2]))
- **Observed**: s.panModel.rxns = {'r1' 'r2' 'r3'} and full(s.panModel.S) = [1 3 2] (setdiff on line 186 sorts, matches on line 207 keeps the order of model 2)
- **Expected**: [1 2 3] (r2 has the coefficient 2 and r3 the coefficient 3 in mB)
- **Source lines**: 203-208
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testGeneratePanDatabase.m`

#### The documented default inputDir needs an explicit empty argument

- **Severity**: limitation
- **Trigger**: generatePanDatabase()
- **Observed**: MATLAB:minrhs, Not enough input arguments. (line 18 reads inputDir); generatePanDatabase([]) uses the default 'AGORA2'
- **Expected**: the call without argument uses the default 'AGORA2' given in the header
- **Source lines**: 18
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testGeneratePanDatabase.m`

### `src/analysis/persephone/additionalFunctions/generateStackedBarPlot.m`

#### Errors for a single sample

- **Severity**: error
- **Trigger**: T = table({'t1'; 't2'; 't3'}, [0.5; 0.495; 0.005], 'VariableNames', {'Taxon', 's1'}); generateStackedBarPlot(T, tempname)
- **Observed**: MATLAB:noPublicFieldForClass, Unrecognized property 'FaceColor' for class 'matlab.graphics.GraphicsPlaceholder'. For one sample bar (line 51) receives a 1-by-4 vector and draws a single Bar series, so b(2) on line 78 does not exist.
- **Expected**: one stacked bar with the taxa t1, t2 and Others (the header says 'for single or multiple samples'), saved as .fig and .svg
- **Source lines**: 51, 77-79
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testGenerateStackedBarPlot.m`

### `src/analysis/persephone/additionalFunctions/getVMHID.m`

#### Suggestions are misaligned after a found name

- **Severity**: wrong-result
- **Trigger**: [metIDs, suggestedMets] = getVMHID({'ATP', 'lactate'}, 1) with the VMH database (ATP is found, lactate is not)
- **Observed**: suggestedMets is a 23x2 cell array (MATLAB R2025a) whose first column is {'lactate'; []; []; ...} and whose second column is {[]; 'D-lactate'; 'L-lactate'; 'Indolelactate'; ...}: the column of the found name is deleted (line 63), so the suggestions of the i-th name are written into column i of the shrunken array, next to their name instead of below it. getVMHID({'lactate'}, 1) gives the correct 23x1 column.
- **Expected**: one column per name not found, the name in row 1 and its suggestions below it: {'lactate'; 'D-lactate'; 'L-lactate'; 'Indolelactate'; ...}
- **Source lines**: 60-64, 79-80
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testGetVMHID.m`

### `src/analysis/persephone/additionalFunctions/microbiomeMappingStats.m`

#### An unlabelled count is printed

- **Severity**: cosmetic
- **Trigger**: the call above
- **Observed**: 'ans = 2' is printed (statement without semicolon)
- **Expected**: no output, or output gated behind a verbose flag
- **Source lines**: 122
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testMicrobiomeMappingStats.m`

#### Taxa whose name contains "pan" are counted as unmapped

- **Severity**: wrong-result
- **Trigger**: raw.csv = table Taxon = {'Bacteroides fragilis'; 'Ruminococcus champanellensis'; 'Lactobacillus panis'; 'Unknown species'; ''}, S1 = [60; 20; 10; 10; 5], S2 = [0; 30; 20; 50; 5], S3 = [1; 1; 1; 1; 1]; mars.csv = table Taxon = {'panBacteroides fragilis'; 'panRuminococcus chamellensis'; 'panLactobacillus panis'}, S1 = [1; 2; 3]; meta.csv = table ID = {'S1'; 'S2'}, age = [30; 40]; microbiomeMappingStats('raw.csv', 'mars.csv', outDir, 'meta.csv')
- **Observed**: erase(MARS.Taxon, 'pan') also removes the "pan" inside the species name ('panLactobacillus panis' becomes 'Lactobacillus is'), so Lactobacillus panis is flagged unmapped: alphaDiversities.csv gives 'alpha mapped' 2 for S1 and 1 for S2, and the sheet Mapped of speciesRelAbunStats.xlsx lists only Ruminococcus chamellensis and Bacteroides fragilis
- **Expected**: only the prefix 'pan' is removed: 'alpha mapped' 3 for S1 and 2 for S2, Lactobacillus panis in the sheet Mapped
- **Source lines**: 118
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testMicrobiomeMappingStats.m`

#### The sheet of unmapped taxa is named 'Umapped'

- **Severity**: cosmetic
- **Trigger**: the call above
- **Observed**: speciesRelAbunStats.xlsx has the sheets Total, Umapped and Mapped
- **Expected**: a sheet named Unmapped
- **Source lines**: 205
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testMicrobiomeMappingStats.m`

### `src/analysis/persephone/additionalFunctions/plotAbsentTaxaEffectOnMARScoverage.m`

#### The genus+epithet curve starts at the standard deviation of the base coverage

- **Severity**: wrong-result
- **Trigger**: pre = table({'Alpha one'; 'Beta two'; 'Gamma three'}, [10; 5; 1], [20; 0; 2], 'VariableNames', {'Taxon', 's1', 's2'}); absent = table({'Alpha_one'; 'Beta_two'}, [0.3; 0.1], 'VariableNames', {'Taxon', 'mean'}); rc = table({'pre'; 'post'}, [100; 50], [100; 70], 'VariableNames', {'Var', 's1', 's2'}); plotAbsentTaxaEffectOnMARScoverage(pre, absent, rc, [tmpDir filesep], 'numAbsentTaxaToInvestigate', 3), with the default figure CloseRequestFcn set to hide the figure so that the YData of the two plotted lines can be read
- **Observed**: 'All absent taxa' YData [0.6 0.75 0.775]; 'Absent taxa with standard nomenclature (genus+epithet)' YData [0.141421 0.75 0.775]: line 79 writes stdCov_readCounts(1) into meanCov_readCounts_onlyNamedTaxa(1), overwriting the mean set on line 78, instead of into stdCov_readCounts_onlyNamedTaxa(1)
- **Expected**: both curves start at the base mean coverage 0.6 (mean of 50/100 and 70/100)
- **Source lines**: 79
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testPlotAbsentTaxaEffectOnMARScoverage.m`

### `src/analysis/persephone/additionalFunctions/setResultPath.m`

#### On Linux and macOS the results folder is placed at the file-system root

- **Severity**: error
- **Trigger**: on Linux: setResultPath(fullfile(tempname, 'sol'))
- **Observed**: prints 'Create new folder:/Results_sol' and stops with 'Permission denied' (setResultPath:27); the non-Windows branch (line 19) looks for the text before the last backslash, which a path with '/' separators does not have, so the parent folder is empty
- **Expected**: the folder <tempname>/Results_sol is created and returned
- **Source lines**: 19
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testSetResultPath.m`

### `src/analysis/persephone/additionalFunctions/slimDownFBAresults.m`

#### The call leaves every MATLAB warning switched on

- **Severity**: cosmetic
- **Trigger**: w = warning; slimDownFBAresults(folder); w2 = warning
- **Observed**: in a fresh MATLAB session 6 warnings are off before the call and 0 after it: line 35 switches all warnings off and line 44 switches all of them on instead of restoring the previous state
- **Expected**: the warning state of the caller is restored
- **Source lines**: 35, 44
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testSlimDownFBAresults.m`

### `src/analysis/persephone/additionalFunctions/validateDietPath.m`

#### A diet file path stops with an error

- **Severity**: error
- **Trigger**: a file myDiet.txt holding the line 'EX_a<TAB>1' in tmpDir; validateDietPath(fullfile(tmpDir, 'myDiet.txt'), tmpDir)
- **Observed**: error "Unrecognized function or variable 'diet'." (validateDietPath:50); the file branch and the final else use the undefined lower-case variable diet instead of Diet
- **Expected**: the input path is returned (documented: '.txt' files are skipped)
- **Source lines**: 50-53, 65
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testValidateDietPath.m`

### `src/analysis/persephone/analyseWBMsol.m`

#### Errors for germ-free and microbiome-personalised iWBMs with analyseGF

- **Severity**: error
- **Trigger**: a folder with FBA_sol_gfiWBM_S1_male.mat, FBA_sol_gfiWBM_S2_female.mat, FBA_sol_miWBM_S1_male.mat and FBA_sol_miWBM_S2_female.mat, each saved with save(file, '-struct', 's') from s = struct('rxns', {{'r1', 'r2', 'r3'}}, 'ID', "<model name>", 'sex', {{'<sex>'}}, 'f', <1x3 fluxes>, 'stat', [1 1 1]) (the miWBM files also with taxonNames {'panA_biomass[c]'; 'panB_biomass[c]'} and relAbundances [61; 41]); analyseWBMsol(folder, struct('rxnRemovalCutoff', {{'count', 0}}), outFolder, true)
- **Observed**: MATLAB:table:RowDimensionMismatch, To assign to or create a variable in a table, the number of rows must match the height of the table (describeFluxes, line 598; MATLAB R2025a). meanSd takes the mean over the first dimension of the transposed reactions-by-samples germ-free array, i.e. over the reactions, and returns one value per germ-free sample (here 1) instead of one per reaction (3). With two male germ-free samples, two reactions and no female sample it stops on line 599 with MATLAB:string:MustBeCharCellArrayOrString, Input must be text.
- **Expected**: the per-reaction mean (SD) of the male and female germ-free fluxes in the scaled flux summary table, and all results written
- **Source lines**: 598-599
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testAnalyseWBMsol.m`

#### Errors when the reaction list contains a duplicate

- **Severity**: error
- **Trigger**: one file FBA_sol_WBM_S1_male.mat saved from s = struct('rxns', {{'r1', 'r2', 'r1'}}, 'ID', "WBM_S1_male", 'sex', {{'male'}}, 'f', [1 2 1], 'stat', [1 1 1]); analyseWBMsol(folder, struct(), outFolder, false)
- **Observed**: MATLAB:table:WrongNumberRHSCols, The value on the right-hand side of the assignment has the wrong width. The assignment requires a value whose width is 2. (line 111): the duplicate is removed from rxns and f (lines 84 and 105) but not from stat
- **Expected**: the duplicate removed from stat as well and the results written for r1 and r2, as the duplicate handling of lines 81-84 intends
- **Source lines**: 105-111
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testAnalyseWBMsol.m`

### `src/analysis/persephone/calculateMetrics.m`

#### Bray-Curtis wrong for a single taxon

- **Severity**: wrong-result
- **Trigger**: a table with one row (one taxon) and calculateBrayCurtis true
- **Observed**: sum(comparisonData) sums along the row instead of down the columns, so counts 1, 3 and 5 give 0 and 1/3 for the sample pairs S1-S2 and S1-S3
- **Expected**: Bray-Curtis = 1 - 2*sum(min)/(a+b), that is 1/2 and 2/3 for the same counts
- **Source lines**: 38, 66-67
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testCalculateMetrics.m`

### `src/analysis/persephone/generateStackedBarPlot_PhylumMARScoverage.m`

#### Errors for more than seven phyla

- **Severity**: error
- **Trigger**: pre.csv and post.csv written from table({'p1'; 'p2'; 'p3'; 'p4'; 'p5'; 'p6'; 'p7'; 'p8'}, [0.3; 0.2; 0.15; 0.1; 0.1; 0.05; 0.05; 0.05], 'VariableNames', {'Taxon', 'mean'}); generateStackedBarPlot_PhylumMARScoverage('pre.csv', 'post.csv', tempdirPath)
- **Observed**: MATLAB:UndefinedFunction, Unrecognized function or variable 'base_colors'. (line 121; MATLAB R2025a): with 8 phyla and 'Others' num_taxa is 9 > 7, and the interpolation branch uses base_colors and num_colors, which are never defined
- **Expected**: a palette of num_taxa colours interpolated from the seven base colours and the figure saved, as the comment of the branch says
- **Source lines**: 118-123
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testGenerateStackedBarPlot_PhylumMARScoverage.m`

### `src/analysis/persephone/performRegressions.m`

#### The MATLAB version check reads the first product listed by ver

- **Severity**: wrong-result
- **Trigger**: any call in a session where ver does not list MATLAB first, e.g. after initCobraToolbox (MATLAB R2025a lists 'M2HTML Toolbox' version 1.5 first)
- **Observed**: matlabVersion(1) is 1.5, so firthRegression stays false and the logistic fits are not penalised on R2025a; a perfectly separated reaction is then dropped (warning in cobraFitglm, NaN row) instead of being fitted
- **Expected**: the version of MATLAB itself (ver('MATLAB')), so that R2024b and newer use the Firth regression as the code comment states
- **Source lines**: 137-143
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testPerformRegressions.m`

### `src/analysis/persephone/readMetadataForPersephone.m`

#### All warnings are switched on after the call

- **Severity**: cosmetic
- **Trigger**: any call, e.g. readMetadataForPersephone('metadata.csv')
- **Observed**: warning('off') and warning('on') replace the warning state of the caller; the state had 11 entries before the call and one ('all', 'on') after it, so the warnings that MATLAB disables by default are enabled
- **Expected**: the warning state of the caller restored after reading
- **Source lines**: 39, 43
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testReadMetadataForPersephone.m`

#### The units line is dropped instead of being stored in VariableUnits

- **Severity**: wrong-result
- **Trigger**: a metadata file whose second line starts with units, e.g. the lines 'ID,Age' / 'units,years' / 'S1,30' / 'S2,40'
- **Observed**: the units line is not in the table (when a numeric column has text in that line the reader already skips it; otherwise line 54 removes it), but metadata.Properties.VariableUnits is an empty 0x0 cell array (MATLAB R2025a); the units of numeric columns are lost
- **Expected**: the units kept in the VariableUnits property of the table, as the header (DESCRIPTION and OUTPUTS) states
- **Source lines**: 52-55
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testReadMetadataForPersephone.m`

### `src/analysis/persephone/runMars.m`

#### The processed and mapped summary sheets hold the original data

- **Severity**: wrong-result
- **Trigger**: reads.xlsx written from table({'k__Bacteria;p__Bacillota;c__Bacilli; o__Lactobacillales;f__Lactobacillaceae;g__Lactobacillus;s__acidophilus'; 'k__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae; g__Bacteroides;s__fragilis'; 'k__Bacteria;p__Bacteroidota;c__Bacteroidia; o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__'}, [100; 60; 40], [50; 30; 20], 'VariableNames', {'Taxon', 'S1', 'S2'}) (taxon strings without line breaks) and db.csv with the columns Kingdom to Species of Lactobacillus acidophilus and Bacteroides fragilis; runMars('reads.xlsx', 'reconstructionDb', 'user_db', 'userDbPath', 'db.csv', 'outputPathMars', outFolder)
- **Observed**: the sheets processedData and mappedData of metrics/Species/taxonSummary.xlsx are identical to originalData (MATLAB R2025a): they list the row 'NaN' (the reads without a species, mean 30) that processed/processed_Species.csv does not contain. Lines 474-475 (and 479-480 for brayCurtisDissimilarity.xlsx) write taxonSummary.originalData (brayCurtis.originalData) to all three sheets.
- **Expected**: the processed and mapped summaries (taxonSummary.processed and taxonSummary.mapped, brayCurtis.processed and brayCurtis.mapped) in the sheets of the same names
- **Source lines**: 474-475, 479-480
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testRunMars.m`

### `src/analysis/persephone/runNonparametricTests.m`

#### A comparison skipped for missing values gets p-value 0 and FDR 0

- **Severity**: wrong-result
- **Trigger**: data = table({'s1'; 's2'; 's3'; 's4'; 's5'; 's6'}, [1; 2; 3; 4; 5; 6], [NaN; NaN; 3; 4; 5; 6], 'VariableNames', {'ID', 'r1', 'r2'}); metadata = table({'s1'; 's2'; 's3'; 's4'; 's5'; 's6'}, {'a'; 'a'; 'a'; 'b'; 'b'; 'b'}, 'VariableNames', {'ID', 'Grp'}); runNonparametricTests(data, metadata, 'Flux', 'Grp')
- **Observed**: r2 (two of the three values of group a missing, test skipped on lines 160-162) has statistic NaN, p-value 0 and FDR 0 and is sorted first, ahead of r1 (p-value 0.1): the p-value column of the preallocated table keeps its 0.
- **Expected**: p-value and FDR NaN for a comparison that is not performed
- **Source lines**: 160-162, 203-206
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testRunNonparametricTests.m`

#### The predictor name is accepted in any case but used as given

- **Severity**: limitation
- **Trigger**: runNonparametricTests(data, metadata, 'flux', 'Grp') with the tables above
- **Observed**: Unrecognized table variable name 'flux'. Variable names are case sensitive. The switch on line 78 uses lower(predictor) and names the stacked column 'Flux', but line 134 reads dataGroup.(predictor).
- **Expected**: the result of the call with 'Flux'
- **Source lines**: 78, 134
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testRunNonparametricTests.m`

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

### `src/analysis/rMTA/calculateEPSILON.m`

#### 'unique_epsilon' stops with an error when no reaction changes

- **Severity**: limitation
- **Trigger**: calculateEPSILON([1 2 3 4; 0 0 1 1], [0; 0], 'unique_epsilon', true)
- **Observed**: error 'Array indices must be positive integers or logical values.' (calculateEPSILON:51): int64(0 * 0.7) = 0 is used as an index
- **Expected**: epsilon = [0; 0] (no reaction is changed)
- **Source lines**: 51
- **Documented in**: `test/verifiedTests/analysis/testRMTA/testCalculateEPSILON.m`

#### The documented codes of rxnFBS do not match the code

- **Severity**: cosmetic
- **Trigger**: reading the help of calculateEPSILON
- **Observed**: the help lists "Forward, Backward and Unchanged (+1;0;-1)", i.e. 0 for a backward change, while the code (and rMTA) treat rxnFBS == 0 as unchanged and -1 as backward
- **Expected**: Forward, Backward and Unchanged (+1;-1;0)
- **Source lines**: 15-17
- **Documented in**: `test/verifiedTests/analysis/testRMTA/testCalculateEPSILON.m`

### `src/analysis/rMTA/rMTAsaveInExcel.m`

#### The documented default of alpha_values cannot be used

- **Severity**: unusable-option
- **Trigger**: TS.bTS = [1 2; 3 4]; TS.mTS = [1; 1]; TS.wTS = TS.bTS; TS.rTS = TS.bTS; rMTAsaveInExcel(fullfile(tmpDir, 'r.xlsx'), TS, {'g1'; 'g2'}), then the same call with alpha_values = -1
- **Observed**: without alpha_values: error 'Not enough input arguments.' (rMTAsaveInExcel:47; alpha_values is a named argument of the signature, so the addOptional default -1 is never used); with -1: the file has only the sheet 'alpha = 1', because num_alphas = numel(-1) = 1 is set on line 51 before line 53 replaces alpha_values by 1:2
- **Expected**: the documented default alpha_1, alpha_2, ...: one sheet per column of TSscore.bTS ('alpha = 1' and 'alpha = 2')
- **Source lines**: 41, 47, 51-53
- **Documented in**: `test/verifiedTests/analysis/testRMTA/testRMTAsaveInExcel.m`

#### The sheets written with xlswrite need Microsoft Excel

- **Severity**: limitation
- **Trigger**: on Linux: genes = {'g1'; 'g2'; 'g3'; 'g4'}; TS.bTS = [3 2; 1 4; -Inf -Inf; 2 1]; TS.mTS = [0.5; 0.7; -Inf; -0.2]; TS.wTS = [1 1; -2 0.5; -Inf -Inf; 0 1]; TS.rTS = [2 -1; 1 3; -Inf -Inf; -0.5 0.5]; gi = table(genes, {'A'; 'B'; 'C'; 'D'}, 'VariableNames', {'gene', 'name'}); dg = table({'g2'; 'g4'; 'g9'; ''; 'g2'}, [1.5; -0.3; 2; 0; 1.5], 'VariableNames', {'gene', 'logFC'}); rMTAsaveInExcel(fullfile(tmpDir, 'res.xlsx'), TS, genes, [0.5 1], 'gene_info', gi, 'differ_genes', dg, 'RankingGeneID', 'g2')
- **Observed**: every xlswrite call warns 'Unable to write to Excel format, attempting to write file to CSV format.' (the ranking cells, TOP_GENES_ID and TOP_GENES_diff_expr go to CSV files, not to sheets of res.xlsx) and the SUMMARY write stops with 'An error occurred while writing file to CSV format. To write to an Excel file, convert your data to a table and use writetable.' (xlswrite:112, called on line 199)
- **Expected**: all sheets in res.xlsx on every platform (writetable, as used for the alpha sheets), or a documented Windows/Excel requirement
- **Source lines**: 98-103, 116-117, 133-134, 199
- **Documented in**: `test/verifiedTests/analysis/testRMTA/testRMTAsaveInExcel.m`

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

### `src/analysis/sampling/ACHR/ACHRSamplerParallelGeneral.m`

#### A log file is written into the current folder

- **Severity**: cosmetic
- **Trigger**: from an empty folder, with sampleStruct.warmupPts = [0.2 0.8 0.5 0.4; 0.3 0.1 0.6 0.9] and sampleStruct.internal with offset [0; 0], ubnew [1; 1], lbnew [0; 0], Anew zeros(0, 2), Cnew zeros(0, 2), Dnew zeros(0, 1), fixed []: ACHRSamplerParallelGeneral(sampleStruct, 1, 10, 60) (serial mode)
- **Observed**: the folder then holds ACHRParallelError.txt (opened on line 115), left there after the call
- **Expected**: no undocumented file, or a documented location
- **Source lines**: 115
- **Documented in**: `test/verifiedTests/analysis/testSampling/testACHRSamplerParallelGeneral.m`

#### The parallel mode cannot start its worker processes on Linux and macOS

- **Severity**: unusable-option
- **Trigger**: on Linux, ACHRSamplerParallelGeneral(sampleStruct, 1, 10, 60, 2) (proc = 2, as gpSampler calls it with threads = 2), any sampleStruct
- **Observed**: line 126 builds the shell command 'matlab -singleCompThread -automation -nojvm -r ACHRSamplerParallelGeneral([],1,10,0,-1,'<pwd>');exit; &' with the -r argument unquoted; sh -c on this text prints 'sh: 1: Syntax error: "(" unexpected' and MATLAB system() on the same text (matlab replaced by echo) returns status 2, so no worker starts; the master then waits for xxRoundAck1x1.mat in the loop of lines 286-296, which only a worker writes (read from the code; the master was not run here because it calls system('matlab ...'))
- **Expected**: the workers start (the -r argument quoted for the shell) and the sampling finishes
- **Source lines**: 126, 128
- **Documented in**: `test/verifiedTests/analysis/testSampling/testACHRSamplerParallelGeneral.m`

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

### `src/analysis/sampling/ACHR/verifyPoints.m`

#### One point stops with an error when a sense has a single row

- **Severity**: error
- **Trigger**: s.A = [1 1; 1 0]; s.b = [2; 0.5]; s.csense = ['E'; 'L']; s.lb = [0; 0]; s.ub = [5; 5]; s.points = [1.5; 0.5]; s.warmupPts = [20; 20]; verifyPoints(s)
- **Observed**: error 'Unable to perform assignment because the indices on the left side are not compatible with the size of the right side.' (verifyPoints:58)
- **Expected**: errorsA = [2 1] (row 2: 1.5 > 0.5 + 0.01), errorsLUB empty
- **Source lines**: 56-58
- **Documented in**: `test/verifiedTests/analysis/testSampling/testVerifyPoints.m`

#### errorsA gives row numbers within the constraints of one sense, not rows of A

- **Severity**: wrong-result
- **Trigger**: s.A = [1 0; 0 1; 1 1]; s.b = [1; 1; 1]; s.csense = ['E'; 'E'; 'L']; s.lb = [0; 0]; s.ub = [5; 5]; s.points = [1 1; 1 1]; s.warmupPts = [20 1; 20 1]; errorsA = verifyPoints(s)
- **Observed**: errorsA = [1 1; 1 2]; the violated constraint is row 3 (x1 + x2 = 2 > 1); lines 56-58 search the rows of one sense only and line 63 stacks the results
- **Expected**: [3 1; 3 2] (row 3 of A for points 1 and 2), the "row index of the constraint in sampleStruct" of the help
- **Source lines**: 56-58, 63
- **Documented in**: `test/verifiedTests/analysis/testSampling/testVerifyPoints.m`

### `src/analysis/sampling/BarrierRound/CMatrix/CMatrix.m`

#### sparse(i, j, s) pairs the values with the sorted pattern, not with (i, j)

- **Severity**: wrong-result
- **Trigger**: raw = zeros(4, 2, 1, 'uint8'); raw(:, 1) = 10; raw(:, 2) = 20; vals = CMatrix(raw); f = full(sparse([2 1], [1 1], vals)); f.x(1, :)
- **Observed**: bytes [10 20] at rows 1 and 2 (MATLAB R2025a), while MATLAB's full(sparse([2 1], [1 1], [10 20]))' is [20 10]; the logical pattern A (line 133) is ordered column-major but the values s (lines 135-136) keep the input order. Repeated (i, j) pairs, e.g. sparse([1 1], [1 1], vals), give a 1 x 1 object whose pattern has 1 nonzero but which stores 2 values. The 5- and 6-argument forms share these lines. No MEX file is involved.
- **Expected**: S(i(k), j(k)) = s(k) as for MATLAB's sparse (repeated pairs summed or rejected)
- **Source lines**: 133-136
- **Documented in**: `test/verifiedTests/analysis/testSampling/testCMatrix.m`

### `src/analysis/sampling/BarrierRound/CMatrix/configCMatrix.m`

#### Every call stops because the parent script config does not exist

- **Severity**: error
- **Trigger**: configCMatrix() (also loadModular('CMatrix'), after initCobraToolbox)
- **Observed**: error MATLAB:UndefinedFunction 'Unrecognized function or variable 'config'.' at line 11 (MATLAB R2025a; which config -all finds nothing, and no config.m exists under src/analysis/sampling/BarrierRound); the BarrierRound folder added by line 10 stays at the top of the path and the include folder is never added.
- **Expected**: the parent configuration runs (it is expected to set the global EIGEN_PATH that compileCMatrix reads) and the CMatrix include folder is added to the path
- **Source lines**: 11, 13
- **Documented in**: `test/verifiedTests/analysis/testSampling/testConfigCMatrix.m`

### `src/analysis/sampling/BarrierRound/CMatrix/include/ddouble.m`

#### sparse(i, j, s) pairs the values with the sorted pattern, not with (i, j)

- **Severity**: wrong-result
- **Trigger**: raw = zeros(4, 2, 1, 'uint8'); raw(:, 1) = 10; raw(:, 2) = 20; vals = ddouble(raw); f = full(sparse([2 1], [1 1], vals)); f.x(1, :)
- **Observed**: bytes [10 20] at rows 1 and 2 (MATLAB R2025a), while MATLAB's full(sparse([2 1], [1 1], [10 20]))' is [20 10]; the logical pattern A (line 133) is ordered column-major but the values s (lines 135-136) keep the input order. Repeated (i, j) pairs, e.g. sparse([1 1], [1 1], vals), give a 1 x 1 object whose pattern has 1 nonzero but which stores 2 values. The 5- and 6-argument forms share these lines. No MEX file is involved.
- **Expected**: S(i(k), j(k)) = s(k) as for MATLAB's sparse (repeated pairs summed or rejected)
- **Source lines**: 133-136
- **Documented in**: `test/verifiedTests/analysis/testSampling/testDdouble.m`

### `src/analysis/sampling/BarrierRound/CMatrix/include/qdouble.m`

#### sparse(i, j, s) pairs the values with the sorted pattern, not with (i, j)

- **Severity**: wrong-result
- **Trigger**: raw = zeros(4, 2, 1, 'uint8'); raw(:, 1) = 10; raw(:, 2) = 20; vals = qdouble(raw); f = full(sparse([2 1], [1 1], vals)); f.x(1, :)
- **Observed**: bytes [10 20] at rows 1 and 2 (MATLAB R2025a), while MATLAB's full(sparse([2 1], [1 1], [10 20]))' is [20 10]; the logical pattern A (line 133) is ordered column-major but the values s (lines 135-136) keep the input order. Repeated (i, j) pairs, e.g. sparse([1 1], [1 1], vals), give a 1 x 1 object whose pattern has 1 nonzero but which stores 2 values. The 5- and 6-argument forms share these lines. No MEX file is involved.
- **Expected**: S(i(k), j(k)) = s(k) as for MATLAB's sparse (repeated pairs summed or rejected)
- **Source lines**: 133-136
- **Documented in**: `test/verifiedTests/analysis/testSampling/testQdouble.m`

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

### `src/analysis/sampling/compareTwoSamplesStat.m`

#### The chi-square p values are cumulative probabilities, near 0 for identical samples

- **Severity**: wrong-result
- **Trigger**: rng(1); s = randn(2, 200); [stats, pVals] = compareTwoSamplesStat(s, s, {'chiSquare'}) and compareTwoSamplesStat(s, s + 5, {'chiSquare'})
- **Observed**: identical samples give stats.chisquare = [0; 0] and pVals.chisquare = [0; 0]; samples shifted by 5 standard deviations (no overlap) give stats.chisquare = [1.9604; 2.0000] and pVals.chisquare = [0.4193; 0.4276] (MATLAB R2025a). Line 75 returns the lower tail chi2cdf(stat, nBin - 1), and lines 70-73 compute the statistic from relative frequencies (counts / nSample), so it is at most 2 whatever the sample size.
- **Expected**: p values of the chi-square test (upper tail of the statistic computed from the counts): 1 for identical samples and close to 0 for samples that do not overlap, as the other tests give (ks, ranksum and ttest p values are 1 for identical samples)
- **Source lines**: 70-75
- **Documented in**: `test/verifiedTests/analysis/testSampling/testCompareTwoSamplesStat.m`

### `src/analysis/sampling/loadSamples.m`

#### More points than pointsPerFile are taken from a file at regular intervals

- **Severity**: wrong-result
- **Trigger**: points = [1:8 0 0; 11:18 0 0]; save('samples_1.mat', 'points'); loadSamples('samples', 1, 3) (and in general whenever pointsPerFile does not divide the number of points of a file)
- **Observed**: 4 points (columns 1, 3, 5, 7) are returned: the step floor(8 / 3) = 2 gives ceil(8 / 2) points; loadSamples('samples', 1, 5) returns all 8 points (MATLAB R2025a). Up to 2 * pointsPerFile - 1 points can be returned per file.
- **Expected**: the documented number of points to be taken from each file (pointsPerFile), as the random selection does
- **Source lines**: 50-51
- **Documented in**: `test/verifiedTests/analysis/testSampling/testLoadSamples.m`

### `src/analysis/sampling/printSampleStats.m`

#### With several samples only the first sample's mode is printed

- **Severity**: wrong-result
- **Trigger**: printSampleStats({[1 1 2; 3 4 4], [5 5 6; 7 8 8]}, struct('rxns', {{'r1'; 'r2'}}), {'A', 'B'})
- **Observed**: header 'Rxn A-mode B-mode A-mean B-mean A-median B-median A-std B-std' (8 value columns) but row 'r1 1.000000 1.333333 5.333333 1.000000 5.000000 0.577350 0.577350' (7 values: B-mode 5 is missing and every later value is shifted one column to the left; MATLAB R2025a). sampleStats.mode(i) (line 56) indexes the reactions x samples matrix linearly, so it is always the first sample's value.
- **Expected**: one mode per sample (sampleStats.mode(i, :)), as for mean, median and std (lines 59, 62, 65), matching the header of lines 36-38
- **Source lines**: 56
- **Documented in**: `test/verifiedTests/analysis/testSampling/testPrintSampleStats.m`

### `src/analysis/subspaces/lsqr/lsqr.m`

#### The x = 0 message is printed even when show = 0

- **Severity**: cosmetic
- **Trigger**: x = lsqr(4, 3, aprod, zeros(4, 1), 0, 1e-12, 1e-12, 1e8, 10, 0) with the aprod above
- **Observed**: 'The exact solution is  x = 0' printed (disp without the show test)
- **Expected**: no output when show = 0 ("0 - suppresses output")
- **Source lines**: 143
- **Documented in**: `test/verifiedTests/analysis/testSubspaces/testLsqr.m`

#### r1norm and r2norm are not assigned when A'*b = 0

- **Severity**: error
- **Trigger**: aprod = @(mode, m, n, x) lsqraprod(mode, m, n, x, 0, 0); [x, istop, itn, r1norm] = lsqr(4, 3, aprod, zeros(4, 1), 0, 1e-12, 1e-12, 1e8, 10, 0)
- **Observed**: 'Output argument "r1norm" (and possibly others) not assigned a value in the execution with "lsqr" function.' (R2025a, 2026-11-15; also with A = [1 0; 0 2; 0 0] and b = [0; 0; 5], which is orthogonal to range(A)); the early return of line 143 (arnorm = alfa*beta = 0) comes before r1norm and r2norm are set on lines 147-148. With two outputs the call returns x = 0, istop = 0.
- **Expected**: x = 0 (the documented message "The exact solution is x = 0" for b = 0, and the least-squares solution for b orthogonal to range(A)) with r1norm = norm(b), r2norm = r1norm, as OUTPUTS document
- **Source lines**: 143, 147-148
- **Documented in**: `test/verifiedTests/analysis/testSubspaces/testLsqr.m`

### `src/analysis/subspaces/lsqr/lsqrtest.m`

#### The function handle is printed by a statement without a semicolon

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: 'aprodfunc = function_handle with value: @(mode,m,n,x)lsqraprod(...)' is printed before the lsqr log
- **Expected**: no output for the assignment (debug leftover)
- **Source lines**: 33
- **Documented in**: `test/verifiedTests/analysis/testSubspaces/testLsqrtest.m`

### `src/analysis/subspaces/nullspace/nullSpaceOperator.m`

#### The option scale = 0 always fails

- **Severity**: unusable-option
- **Trigger**: nullSpaceOperator(sparse([1 -1 0 0; 0 1 -1 0]), 0, 0)
- **Observed**: "Unrecognized function or variable 'A'." at line 151 (R2025a, 2026-11-15); A (and Cinv, used on line 227) are assigned only on lines 79-81 inside "if scale"
- **Expected**: the operator of the unscaled S (INPUTS: "scale: {(1), 0} geometric mean scaling of S"), e.g. rank 2 for the matrix above, as with scale = 1
- **Source lines**: 72-90, 151, 227
- **Documented in**: `test/verifiedTests/analysis/testSubspaces/testNullSpaceOperator.m`

### `src/analysis/subspaces/rank/getRankLUSOL.m`

#### q is wrong when A has a zero column

- **Severity**: wrong-result
- **Trigger**: [rankA, p, q] = getRankLUSOL([0 1 2; 0 2 5])
- **Observed**: rankA = 2, q = [2; 1; 1] (R2025a, 2026-11-15, LUSOL); q(1:2) = [2 1] includes the zero column 1 (rank(A(:, q(1:2))) = 1), column 3 is missing and 1 is repeated. [1 0 2; 2 0 5; 1 0 1] gives q = [2; 1; 2]. The pivot order of the reduced matrix A(:, ~bool) (line 65) is used as column indices of A, then ind(bool) is appended (lines 199-201)
- **Expected**: q a permutation of 1:3 with q(1:2) = the independent columns 2 and 3 and q(3) = 1 (OUTPUTS: "q(1:rankA) gives indices of independent columns"; comment of line 198: "pad out q in case some columns are dropped")
- **Source lines**: 62-66, 199-201
- **Documented in**: `test/verifiedTests/analysis/testRank/testGetRankLUSOL.m`

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

### `src/analysis/thermo/groupContribution/jankowski/createGroupContributionStruct.m`

#### The input files are left open

- **Severity**: limitation
- **Trigger**: createGroupContributionStruct(primaryFile, 7, secondaryFile) with two readable files
- **Observed**: the file identifiers opened on lines 50 and 75 are never closed (no fclose); this test closes them itself
- **Expected**: the files closed after reading
- **Source lines**: 50, 75
- **Documented in**: `test/verifiedTests/analysis/testThermo/testCreateGroupContributionStruct.m`

### `src/analysis/thermo/inchi/getMolecularWeight.m`

#### Hydrogens are lost for an InChI whose formula starts with H

- **Severity**: wrong-result
- **Trigger**: an InChI whose formula layer begins with hydrogen, for example water, InChI=1S/H2O/h1H2
- **Observed**: the formula returned by getFormulaAndChargeFromInChI is O and the hydrogen count is returned separately, but only the formula is used, so water gets a molecular weight of 16 and 0 hydrogens
- **Expected**: a molecular weight of 18 and 2 hydrogens for water
- **Source lines**: 41-61
- **Documented in**: `test/verifiedTests/analysis/testThermo/testGetMolecularWeight.m`

### `src/analysis/thermo/protons/getMetaboliteMsDistr.m`

#### Mol files are missed when another file precedes them or their name holds a dot or 'mol'

- **Severity**: wrong-result
- **Trigger**: molfiledir holding A.txt, B.mol, C.mol, glc.D.mol, xmol.mol; getMetaboliteMsDistr({'B[c]'; 'C[c]'; 'glc.D[c]'; 'xmol[c]'}, molDir, outDir, [7 7.5])
- **Observed**: with ispc and system replaced by recording stubs (MATLAB R2025a), only the two calls for C ('... C_msdistr_ph7.sdf msdistr -H 7 ...' and '... C_msdistr_ph7.5.sdf msdistr -H 7.5 ...') are issued; B (preceded by A.txt in the concatenated listing '...A.txtB.molC.mol...'), glc.D (dots removed: 'glcD') and xmol (the unescaped '.' of '.mol' also matches 'xmol') get no call.
- **Expected**: one cxcalc call for every metabolite whose <id>.mol file exists
- **Source lines**: 20-22
- **Documented in**: `test/verifiedTests/analysis/testThermo/testGetMetaboliteMsDistr.m`

### `src/analysis/thermo/protons/getMetabolitepKa.m`

#### Mol files are missed when another file precedes them or their name holds a dot or 'mol'

- **Severity**: wrong-result
- **Trigger**: molfiledir holding A.txt, B.mol, C.mol, glc.D.mol, xmol.mol; getMetabolitepKa({'B[c]'; 'C[c]'; 'C[e]'; 'glc.D[c]'; 'xmol[c]'}, molDir, outDir)
- **Observed**: with ispc and system replaced by recording stubs (MATLAB R2025a), only 'cxcalc -o <outDir>/C_pkas.txt pka -M true -a 20 -b 20 <molDir>/C.mol' is issued; B (preceded by A.txt in the concatenated listing '...A.txtB.molC.mol...'), glc.D (dots removed: 'glcD') and xmol (the unescaped '.' of '.mol' also matches 'xmol') get no call.
- **Expected**: one cxcalc call for every metabolite whose <id>.mol file exists
- **Source lines**: 18-20
- **Documented in**: `test/verifiedTests/analysis/testThermo/testGetMetabolitepKa.m`

### `src/analysis/thermo/reactantContribution/calcdGHT.m`

#### The standard transformed enthalpy dHf0 is always NaN

- **Severity**: limitation
- **Trigger**: any call, e.g. calcdGHT(-100, -50, -1, 3, 7, 0.25, 298.15)
- **Observed**: dHf0 = NaN; line 195 sets dHzero = [] before the enthalpy branch ("makes script faster to leave this out for now")
- **Expected**: the documented output "reactant standard transformed enthalpy of formation"
- **Source lines**: 195-196, 411
- **Documented in**: `test/verifiedTests/analysis/testThermo/testCalcdGHT.m`

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

### `src/analysis/topology/conservedMoieties/classifyMoieties.m`

#### isSecondary is returned as a row vector, not m x 1

- **Severity**: cosmetic
- **Trigger**: [~, isSecondary] = classifyMoieties([1 1 0 0; 0 0 1 0], [-1 0; 1 0; 0 -1; 0 0])
- **Observed**: size(isSecondary) is [1 4] (MATLAB R2025a): any(..., 1) returns a row
- **Expected**: an m x 1 Boolean vector, as the OUTPUTS documentation says
- **Source lines**: 27
- **Documented in**: `test/verifiedTests/analysis/testConservedMoieties/testClassifyMoieties.m`

### `src/analysis/topology/conservedMoieties/constructElementalMatrix.m`

#### Every call stops because atomicNumbers.mat is missing

- **Severity**: error
- **Trigger**: constructElementalMatrix({'H2O'; 'CO2'; 'HO'}, [0; 0; -1]) (any input)
- **Observed**: 'Error using load: Unable to find file or directory 'atomicNumbers.mat'.' at line 30 (MATLAB R2025a, after initCobraToolbox); the file src/analysis/topology/conservedMoieties/atomicNumbers.mat was deleted by commit 008e0e4f51 (2020-10-31) and no copy exists anywhere in the repository.
- **Expected**: the element symbols and atomic numbers are loaded and the elemental matrix is returned, e.g. H2O -> H 2, O 1, e 10
- **Source lines**: 30
- **Documented in**: `test/verifiedTests/analysis/testConservedMoieties/testConstructElementalMatrix.m`

### `src/analysis/topology/conservedMoieties/estimateMoietyFormulas.m`

#### M is not the r x p matrix the documentation describes

- **Severity**: cosmetic
- **Trigger**: [f, M] = estimateMoietyFormulas([1 0; 1 1; 0 1], [2 4 1 0; 4 6 1 1; 2 2 0 1], {'e', 'H', 'C', 'O'})
- **Observed**: M = [1 4 0; 0 2 1] (R2025a, 2026-11-15): the electron column is removed and the columns are sorted to C, H, O (lines 26 and 29), so M is r x 3 and its columns no longer follow the input elements
- **Expected**: OUTPUT: "M: An r x p estimated elemental matrix for moieties" (here 2 x 4 in the order e, H, C, O), or a documentation that says M follows the sorted elements without 'e'
- **Source lines**: 26, 29
- **Documented in**: `test/verifiedTests/analysis/testConservedMoieties/testEstimateMoietyFormulas.m`

### `src/analysis/topology/conservedMoieties/representativeMoiety.m`

#### MMN.moi is required but not documented

- **Severity**: limitation
- **Trigger**: representativeMoiety(rmfield(MMN, 'moi')) with MMN as above
- **Observed**: error 'Unrecognized field name "moi".' (line 39)
- **Expected**: INPUT lists only .L and .mol and OUTPUT calls .moi an "added or updated field"; either the input documentation names .moi (a table with one row per moiety) or the field is created when absent
- **Source lines**: 39
- **Documented in**: `test/verifiedTests/analysis/testConservedMoieties/testRepresentativeMoiety.m`

#### minimalMassFraction is always 1

- **Severity**: wrong-result
- **Trigger**: MMN.L = [1 1 0; 0 1 1]; MMN.mol = table({'a'; 'b'; 'c'}, [16; 32; 16], 'VariableNames', {'Mets', 'Mass'}); MMN.moi = table([12; 14], 'VariableNames', {'Mass'}); out = representativeMoiety(MMN)
- **Observed**: out.moi.minimalMassFraction = [1; 1] (R2025a, 2026-11-15); MinimalMassMol = {'a'; 'c'} and NumMinimalMassMol = [1; 1] are right. Line 35 divides minimumMass by MMN.mol.Mass(ind(1)), which is minimumMass by construction of ind (line 30)
- **Expected**: the moiety/metabolite mass fraction, here [12/16; 14/16] = [0.75; 0.875]: the sibling representativeMolecule.m computes moietyMasses(i)/minimumMass and documents minimalMassFraction as "the moiety/metabolite mass fraction"; MMN.moi carries the moiety Mass column (old/generateMoietyMoleculeNetwork.m, line 72); the tutorials filter moieties on minimalMassFraction > 0.1, which is meaningless for a constant 1
- **Source lines**: 35
- **Documented in**: `test/verifiedTests/analysis/testConservedMoieties/testRepresentativeMoiety.m`

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

### `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsInputHalfspace.m`

#### the linear objective f is malformed and placed where lrs ignores it

- **Severity**: unusable-option
- **Trigger**: lrsInputHalfspace([1 1 -1], [], 'lp', 1, 0, 1, [], [1 2 3]), then system('lrs lp_pos_eq.ine'); and lrsInputHalfspace([1 1 -1], [], 'lq', 1, 1, 1, [], [1 2 3])
- **Observed**: the files hold "lponly / minimize 02 3" (equality form: the loop of line 80 starts at c = 2, so f(1) is dropped, and no space follows the constant 0) and "lponly / minimize 01 2 3" (inequality form, lines 233-235), both before "begin"; lrs ignores them and prints the full V-representation (vertices and rays) instead of an LP solution
- **Expected**: an lrs LP request "minimize 0 1 2 3" with "lponly" (OPTIONAL INPUTS: "f: linear objective for a linear optimization problem in rational arithmetic")
- **Source lines**: 76-84, 230-238
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsInputHalfspace.m`

#### the shell script writes to a fixed personal folder

- **Severity**: unusable-option
- **Trigger**: lrsInputHalfspace([1 1 -1], [], 'sh', 1, 1, 0, [], [], 1)
- **Observed**: sh_pos_ineq.sh holds "(time lrs sh_pos_ineq.ine > /nas/rfleming/sh_pos_ineq.ext) 2> sh_pos_ineq.time" (line 300), a folder of one developer's cluster
- **Expected**: a script whose output .ext lies next to the input (OPTIONAL INPUTS: "sh: if sh == 1, output a shell script for submitting qsub job")
- **Source lines**: 300
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsInputHalfspace.m`

#### with A empty and inequality = 1 the column count is 1

- **Severity**: wrong-result
- **Trigger**: lrsInputHalfspace([], [1 1], 'di', 1, 1, zeros(0, 1), 2), then system('lrs di_pos_ineq.ine'); likewise with positivity = 0 ('dn_neg_ineq.ine')
- **Observed**: "begin / 1 1 integer / -2 1 1 / end" (line 260 writes clt + 1 = 1, clt being the column count of the empty A); lrs answers "No feasible solution" for a feasible polyhedron
- **Expected**: "1 3 integer" (Dclt + 1 columns) and the V-representation of the polyhedron
- **Source lines**: 260
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsInputHalfspace.m`

#### with A empty and positivity = 1 the row count omits the x >= 0 rows

- **Severity**: wrong-result
- **Trigger**: lrsInputHalfspace([], [1 1], 'de', 1, 0, zeros(0, 1), 2), i.e. x1 + x2 >= 2, x >= 0, then system('lrs de_pos_eq.ine')
- **Observed**: de_pos_eq.ine has "begin / 1 3 integer / -2 1 1 / 0 1 0 / 0 0 1 / end" (R2025a, lrslib 7.1, 2026-11-15): the count is Drlt + clt = 1 + 0 (line 124 uses clt, the column count of the empty A) but Dclt = 2 positivity rows follow; lrs reads one row and returns vertex (2, 0), ray (1, 0) and linearity (-1, 1), i.e. the half-plane x1 + x2 >= 2 without x >= 0
- **Expected**: "3 3 integer" (Drlt + Dclt rows) and the V-representation of {x >= 0, x1 + x2 >= 2}: vertices (2, 0), (0, 2), rays (1, 0), (0, 1)
- **Source lines**: 124
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsInputHalfspace.m`

### `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsOutputReadRay.m`

#### rows with rational entries are dropped and become zero rays

- **Severity**: wrong-result
- **Trigger**: sq.ine = "sq / H-representation / begin / 3 3 rational / 1 -2 0 / 0 1 0 / 0 0 1 / end" (one line per item: 1 - 2*x1 >= 0, x1 >= 0, x2 >= 0); system('lrs sq.ine > sq.ext') writes the rows "1 0 0", "0 0 1" and "1 1/2 0"; then [R, V] = lrsOutputReadRay('sq.ext')
- **Observed**: V = [0; 0] and R = [0 0; 0 1] (R2025a, lrslib 7.1, 2026-11-15): the vertex (1/2, 0) is missing and a zero ray is returned instead. The '/' branch (lines 72-82) converts "1/2" to 1.2 and then to fix(1.2)/mod(1.2, 1) = 5, but never assigns scannedLine to P(r, :), so the row stays zero and is classified as a ray (line 94)
- **Expected**: V = [0 1/2; 0 0] (vertices (0, 0) and (1/2, 0)) and R = [0; 1] (description: "Reads into matlab a vertex representation output from lrs"; lrs writes rationals as p/q)
- **Source lines**: 70-82, 90-94
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsOutputReadRay.m`

#### the empty matrix P is printed to the command window

- **Severity**: cosmetic
- **Trigger**: any call, for example [R, V] = lrsOutputReadRay('sq.ext') as above
- **Observed**: "P = 3x3 sparse double matrix All zero" printed (line 64 has no semicolon)
- **Expected**: no output
- **Source lines**: 64
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsOutputReadRay.m`

### `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsSpecifyRows.m`

#### a file that cannot be opened gives an undefined-variable error

- **Severity**: cosmetic
- **Trigger**: lrsSpecifyRows(fullfile(tempname, 'nope.ext'))
- **Observed**: error "Unrecognized function or variable 'fileNameOut'." (R2025a, 2026-11-15): line 22 displays fileNameOut, which is not defined in the function
- **Expected**: error 'Could not open lrs output file.' (line 23)
- **Source lines**: 22-23
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsSpecifyRows.m`

#### the file identifier is never closed

- **Severity**: limitation
- **Trigger**: any call, for example lrsSpecifyRows('x.ext') on a valid file
- **Observed**: the identifier opened on line 20 stays in openedFiles() after the call (identifier 3 after the first call, 3 and 4 after a second call that stopped with an error); there is no fclose
- **Expected**: no open file left behind; this test closes the identifiers the function leaves open
- **Source lines**: 20
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsSpecifyRows.m`

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

### `src/analysis/topology/getCorrespondingCols.m`

#### The error for a colBool of the wrong length names rowBool

- **Severity**: cosmetic
- **Trigger**: getCorrespondingCols(eye(2), true(2, 1), true(3, 1), 'inclusive')
- **Observed**: the error message is 'length of rowBool must equal size(A,2)'
- **Expected**: a message naming colBool, 'length of colBool must equal size(A,2)'
- **Source lines**: 68
- **Documented in**: `test/verifiedTests/analysis/testTopology/testGetCorrespondingCols.m`

### `src/analysis/topology/getCorrespondingRows.m`

#### The error for a colBool of the wrong length names rowBool

- **Severity**: cosmetic
- **Trigger**: getCorrespondingRows(eye(2), true(2, 1), true(3, 1), 'inclusive')
- **Observed**: the error message is 'length of rowBool must equal size(A,2)'
- **Expected**: a message naming colBool, 'length of colBool must equal size(A,2)'
- **Source lines**: 72
- **Documented in**: `test/verifiedTests/analysis/testTopology/testGetCorrespondingRows.m`

### `src/analysis/topology/graphHypergraphConversion/convertHypergraphToBipartiteGraph.m`

#### trailing empty hyperedges are missing from A and B

- **Severity**: wrong-result
- **Trigger**: [A, B] = convertHypergraphToBipartiteGraph([-1 0 0; 2 -1 0]) (m = 2, n = 3, the last hyperedge empty); also convertHypergraphToBipartiteGraph(zeros(2, 2))
- **Observed**: size(A) = [4 4] and size(B) = [4 3] (R2025a, 2026-11-15); for zeros(2, 2) A and B are 0 x 0. B = sparse(rowIndices, colIndices, values) (line 46) takes its row count from the largest index, m + the last nonempty column, and A = inc2adj(B ~= 0) (line 56) inherits it, so an empty hyperedge in the middle is kept as an isolated node but one at the end is not
- **Expected**: size(A) = [5 5] and size(B) = [5 3] with node 5 isolated (OUTPUTS: "A: (m+n) x (m+n) adjacency matrix", "B: (m+n) x nnz(S) incidence matrix"); for zeros(2, 2) a 4 x 4 zero A and a 4 x 0 B
- **Source lines**: 46, 56
- **Documented in**: `test/verifiedTests/analysis/testTopology/testConvertHypergraphToBipartiteGraph/testConvertHypergraph2BipartiteGraph.m`

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

### `src/analysis/topology/reactingMoieties/identifyIsomorphicClasses.m`

#### sanityChecks = true raises an error for any class with two or more members

- **Severity**: unusable-option
- **Trigger**: e = @(m) table([1 2], {m}, 'VariableNames', {'EndNodes', 'mets'}); n = @(i) table(i, 'VariableNames', {'AtomIndex'}); g = {graph(e('m1'), n([1; 2])); graph(e('m1'), n([3; 4])); graph(e('m2'), n([5; 6]))}; identifyIsomorphicClasses(g, 1)
- **Observed**: error 'Inconsistent mapping of atoms to connected components.' (R2025a, 2026-11-15); with sanityChecks = 0 the classes are {[1 2], 3}, firsts [1; 3] and class indices [1; 1; 2]. Line 33 tests CBSubgraphs{j}.Nodes.AtomIndex ~= j, i.e. atom ids against the subgraph index, which can only pass if every node of subgraph j has AtomIndex j. The code this was ported from (conservedMoieties/old/identifyConservedMoietiesLegacyInterface.m, line 453) tests atoms2component(subgraphs{j}.Nodes.AtomIndex) ~= j. identifyConservedReactingMoieties passes options.sanityChecks (default 1), and testConservedReactingMoieties.m records sanityChecks = 1 as a known crash in this path
- **Expected**: the same classes as with sanityChecks = 0 and no error, since each subgraph is its own connected component (INPUTS: "sanityChecks: boolean flag to enable additional consistency checks")
- **Source lines**: 33-34
- **Documented in**: `test/verifiedTests/analysis/testReactingMoieties/testIdentifyIsomorphicClasses.m`

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

### `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/createUSDAdatabase.m`

#### The progress message has no space before the food source name

- **Severity**: cosmetic
- **Trigger**: any call, e.g. the default foodSource2Use
- **Observed**: "Currently creating the individual database forsr_legacy_food" (strcat drops the trailing blank of its first argument)
- **Expected**: "Currently creating the individual database for sr_legacy_food"
- **Source lines**: 94
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testCreateUSDAdatabase.m`

#### brandedFoods = true always raises an error

- **Severity**: unusable-option
- **Trigger**: createUSDAdatabase(d, 'brandedFoods', true, 'foodSource2Use', {'sr_legacy_food'; 'foundation_food'}) with a folder d holding food.csv, food_nutrient.csv and usda2vmhInfoFile.xlsx (one branded_food item)
- **Observed**: error "Colon operands must be real scalars." on line 127 (the loop bound size(brandedNames.fdc_id) is a 1x2 vector); past it, line 133 uses the undefined name foodsnutrients (the table is foodNutrients) and lines 145 and 151 save into the current folder instead of outputDir
- **Expected**: the branded-food tables are created, as the help text says ("brandedFoods - boolean; if true the branded-foods source table is also created")
- **Source lines**: 127, 133
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testCreateUSDAdatabase.m`

### `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/getNutritionDatabaseFile.m`

#### The shipped USDA food items file is not found

- **Severity**: limitation
- **Trigger**: getNutritionDatabaseFile('usda', 'foodItems') with the papers submodule
- **Observed**: error "Could not find USDA2024_foodItems.mat in <toolbox>/papers/2025_nutritionToolbox/usdaDatabase or on the MATLAB path." - the shipped file is named USDAFoodItems.mat (also on the submodule's origin/master); createUSDAdatabase writes USDA<YEAR>_foodItems.mat, the name this function builds
- **Expected**: the path of the shipped USDA food items file, as the help text lists 'foodItems' (usda) as a file type
- **Source lines**: 85-90
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testGetNutritionDatabaseFile.m`

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

### `src/base/install/prepareTest.m`

#### needsLinux makes every test skip on Linux

- **Severity**: unusable-option
- **Trigger**: prepareTest('needsLinux', true) on a 64-bit Linux machine
- **Observed**: error COBRA:RequirementsNotMet "This test only works on Linux Systems" although isunix is 1; computer('arch') returns 'glnxa64' (probe output: "isunix=1 arch=glnxa64"), and line 177 compares it with 'glnx64', so the check always fails
- **Expected**: no requirement error on Linux, as the help text says ("needsLinux: Whether the test only works on a Linux system")
- **Source lines**: 177-179
- **Documented in**: `test/verifiedTests/base/testInstall/testPrepareTest.m`

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

### `src/base/io/python/pyPath/py_addpath.m`

#### A relative folder is added as given, not converted to an absolute path

- **Severity**: wrong-result
- **Trigger**: d = tempname; mkdir(fullfile(d, 'sub')); cd(d); p = py_addpath('sub')
- **Observed**: the entry 'sub' is added ("after py_addpath('sub'): added = sub"); Python resolves it against its working folder, which follows MATLAB's cd, so the folder is lost after a change of directory. exist('sub', 'dir') is 7, so the conversion on line 63 is skipped for every existing folder
- **Expected**: the absolute path fullfile(d, 'sub'), as the comment on line 61 ("Convert relative path to absolute path") states
- **Source lines**: 62-63
- **Documented in**: `test/verifiedTests/base/testPyPath/testPy_addpath.m`

#### The empty input adds the current folder to the Python path

- **Severity**: wrong-result
- **Trigger**: d = tempname; mkdir(d); cd(d); p = py_addpath('')
- **Observed**: sys.path gains d as its second entry (probe output: "after py_addpath(''): added = <d>"); exist('', 'dir') is 0, so line 63 replaces '' with py.os.path.abspath(''), the current folder, which lines 67-69 insert
- **Expected**: the help text: "to get this output without updating the Python path, use an empty string as the input: py_path = py_addpath('')" - sys.path unchanged
- **Source lines**: 62-63, 67-69
- **Documented in**: `test/verifiedTests/base/testPyPath/testPy_addpath.m`

### `src/base/io/python/pyPath/py_rmpath.m`

#### MATLAB_too = true always raises an error

- **Severity**: error
- **Trigger**: d = tempname; mkdir(d); sp = py.sys.path; sp.insert(int64(0), d); py_rmpath(d, true)
- **Observed**: error "Undefined function 'rnpath' for input arguments of type 'char'." on line 48 (rnpath is a misspelling of rmpath); the folder has already been removed from sys.path, the MATLAB path is not changed and no output is returned
- **Expected**: the folder removed from sys.path and from the MATLAB path, as the help text says ("If true (or 1), directory will also be removed from the MATLAB path")
- **Source lines**: 47-48
- **Documented in**: `test/verifiedTests/base/testPyPath/testPy_rmpath.m`

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

### `src/base/io/utilities/getDefinedFieldProperties.m`

#### A requested field without definition raises an error instead of being left out

- **Severity**: limitation
- **Trigger**: getDefinedFieldProperties('SpecificFields', {'lb', 'notAField'})
- **Observed**: error "The following requesteds fields have no Specifications: notAField"
- **Expected**: the documented OUTPUTS: "if fields without definitions are requested, they will not be contained in the result" (i.e. only the row of lb)
- **Source lines**: 192-194
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testGetDefinedFieldProperties.m`

#### SpecificFields is ignored together with Descriptions or DataBaseFields

- **Severity**: limitation
- **Trigger**: getDefinedFieldProperties('Descriptions', true, 'SpecificFields', {'lb'})
- **Observed**: all 82 description rows are returned
- **Expected**: only the row of lb (SpecificFields: "only obtain definitions for a specific set of fields"); both branches return before the selection of lines 190-196
- **Source lines**: 102-103, 135-136
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testGetDefinedFieldProperties.m`

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

### `src/base/io/utilities/readSimPhenyCMPD.m`

#### A file without metabolite lines stops with an error

- **Severity**: limitation
- **Trigger**: readSimPhenyCMPD on an empty file (or one without lines of nine fields)
- **Observed**: "Unrecognized function or variable 'mets'." (mets and metInfo are only created when a metabolite line is read)
- **Expected**: empty outputs (no metabolite)
- **Source lines**: 46
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testReadSimPhenyCMPD.m`

#### Alternative names keep the blank that follows a '/'

- **Severity**: cosmetic
- **Trigger**: a line whose eighth field is "adenosine triphosphate / ATP"
- **Observed**: altNames is {'adenosine triphosphate'; ' ATP'} (deblank removes trailing blanks only)
- **Expected**: {'adenosine triphosphate'; 'ATP'}, the names without the blanks around the separator that the deblank loop is meant to remove
- **Source lines**: 40
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testReadSimPhenyCMPD.m`

### `src/base/io/utilities/readSimPhenyGPR.m`

#### A file without reaction lines stops with an error

- **Severity**: limitation
- **Trigger**: readSimPhenyGPR on an empty file (or one without lines of eight fields)
- **Observed**: "Unrecognized function or variable 'rxns'." (rxns and rxnInfo are only created when a reaction line is read)
- **Expected**: empty outputs (no reaction, no gene)
- **Source lines**: 48
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testReadSimPhenyGPR.m`

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

### `src/base/paths/comparePaths.m`

#### Python path entries with blanks are reported as differences

- **Severity**: limitation
- **Trigger**: setenv('PYTHONPATH', fullfile(d, 'a b')) before MATLAB's Python starts, then comparePaths('PYTHON')
- **Observed**: system_not_matlab = {'<d>/ab'} and matlab_not_system = {'<d>/a b', ...}; line 39 deletes every blank of the system entries (meant for the blanks after the commas of the printed list), and lines 32-40 also split entries that contain a comma or quote
- **Expected**: the entry '<d>/a b' common to both sides
- **Source lines**: 32-40
- **Documented in**: `test/verifiedTests/base/testPaths/testComparePaths.m`

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

### `src/base/solvers/getSetSolver/getAvailableSolversByType.m`

#### The output of initCobraToolbox is not silenced

- **Severity**: cosmetic
- **Trigger**: global SOLVERS; SOLVERS = []; getAvailableSolversByType()
- **Observed**: the full initCobraToolbox output is printed (banner, solver checks, "Saving the MATLAB path ... Done.", the solver summary table); ENV_VARS on lines 17 and 19 is a local variable (not declared global), so setting ENV_VARS.printLevel has no effect
- **Expected**: initCobraToolbox runs with the global ENV_VARS.printLevel false, then restored
- **Source lines**: 17, 19
- **Documented in**: `test/verifiedTests/base/testSolvers/testGetAvailableSolversByType.m`

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

### `src/base/solvers/param/changeCobraSolverParams.m`

#### The error for a parameter that is not allowed always names LP solvers

- **Severity**: cosmetic
- **Trigger**: changeCobraSolverParams('MILP', 'minNorm', 1)
- **Observed**: the error message is 'Parameter name minNorm not allowed for LP solvers'
- **Expected**: a message naming the solver type given, MILP
- **Source lines**: 85
- **Documented in**: `test/verifiedTests/base/testSolvers/testChangeCobraSolverParams.m`

#### solverType is documented as optional with default 'LP' but cannot be omitted

- **Severity**: cosmetic
- **Trigger**: changeCobraSolverParams('feasTol', 1e-9)
- **Observed**: error 'Solver type feasTol is not supported by the COBRA Toolbox' (the first input is always the solver type; USAGE lists three inputs)
- **Expected**: per INPUTS ("solverType: Solver type, 'LP' or 'MILP' (opt, default, 'LP')"), the LP parameter feasTol set; the USAGE line and the code agree that the input is required, so the INPUTS text is the likely error
- **Source lines**: 80
- **Documented in**: `test/verifiedTests/base/testSolvers/testChangeCobraSolverParams.m`

### `src/base/solvers/param/getCobraSolverParams.m`

#### The global solver parameters are ignored when no paramStructure is given

- **Severity**: wrong-result
- **Trigger**: changeCobraSolverParams('LP', 'feasTol', 1e-9); getCobraSolverParams('LP', 'feasTol')
- **Observed**: 1e-06 (the default of the script; overRideDefaults is 0 without a third input, so CBT_LP_PARAMS is never read)
- **Expected**: 1e-09, the global value (header: "gets ... from paramStructure, the global cobra parameters variable or default values ... with the following priority paramStructure > solver type paramStructure > default paramStructure")
- **Source lines**: 64-68, 169-176
- **Documented in**: `test/verifiedTests/base/testSolvers/testGetCobraSolverParams.m`

#### The structure output keeps the fields named in paramNames

- **Severity**: cosmetic
- **Trigger**: [v, s] = getCobraSolverParams('LP', 'feasTol', struct('feasTol', 1e-3, 'other', 5))
- **Observed**: s has the fields feasTol (1e-3) and other (5)
- **Expected**: per OUTPUTS, "paramStructureOut, with fields removed corresponding to paramNames" (only other); no caller in src/ uses this output, so the header is the likely error
- **Source lines**: 166, 181, 186
- **Documented in**: `test/verifiedTests/base/testSolvers/testGetCobraSolverParams.m`

#### paramStructure 'default' returns the global values instead of the defaults

- **Severity**: wrong-result
- **Trigger**: changeCobraSolverParams('LP', 'feasTol', 1e-9); getCobraSolverParams('LP', 'feasTol', 'default')
- **Observed**: 1e-09 (the global value; overRideDefaults is set to 1 for 'default')
- **Expected**: 1e-06 (OPTIONAL INPUTS: "paramStructure can be set to 'default' to use the default values set within this script"; the comment of line 56 reads "overide defaults unless hack is asking for defaults")
- **Source lines**: 60-62
- **Documented in**: `test/verifiedTests/base/testSolvers/testGetCobraSolverParams.m`

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

### `src/base/utilities/duplicates.m`

#### A cell array with more than one column is compared element by element, so M is not m x m

- **Severity**: limitation
- **Trigger**: [M, duplicateBool] = duplicates({'a', 'a', 'b'})
- **Observed**: M = [0 1] (1 x 2) and duplicateBool = [0; 1] (2 x 1) for an input with one row
- **Expected**: M of size m x m and duplicateBool of size m x 1 (m = 1 here), as documented
- **Source lines**: 50
- **Documented in**: `test/verifiedTests/base/testTools/testDuplicates.m`

### `src/base/utilities/getGlobalValue.m`

#### The value of a global named globalName cannot be read

- **Severity**: limitation
- **Trigger**: getGlobalValue('globalName')
- **Observed**: the function declares its own argument variable global, so the text it then evaluates is no longer the name; MATLAB raises MATLAB:m_illegal_character
- **Expected**: the value of the global variable globalName, as for any other name
- **Source lines**: 13-14
- **Documented in**: `test/verifiedTests/base/testUtilities/testGetGlobalValue.m`

### `src/base/utilities/removeIndicesInDimenion.m`

#### The help text says the given indices are removed, but they are the ones kept

- **Severity**: cosmetic
- **Trigger**: any call, e.g. removeIndicesInDimenion(magic(4), 1, [1 3])
- **Observed**: rows 1 and 3 are returned (the given indices are kept); the only caller, removeFieldEntriesForType, relies on this and passes the complement of the entries to remove
- **Expected**: a help text that describes the indices as the entries to keep (the code is consistent with its caller)
- **Source lines**: 2-16
- **Documented in**: `test/verifiedTests/base/testTools/testRemoveIndicesInDimenion.m`

### `src/base/utilities/restoreEnvironment.m`

#### The printed path is cut at a folder name with a % sign

- **Severity**: cosmetic
- **Trigger**: a folder named '100%done' on environment.path, restoreEnvironment(environment, true, 1)
- **Observed**: "Path set to:" is followed by '<tempdir>/100' and nothing else: the path is used as the format of sprintf, which stops at the conversion %d that has no data (backslashes in folder names would likewise be read as escapes); the path itself is restored correctly; the test uses no such folder name
- **Expected**: every folder of the path, one per line
- **Source lines**: 44
- **Documented in**: `test/verifiedTests/base/testUtilities/testRestoreEnvironment.m`

### `src/base/utilities/setGlobal.m`

#### A global named globalName cannot be set

- **Severity**: limitation
- **Trigger**: setGlobal('globalName', value)
- **Observed**: the function declares its own argument variable global, so the text it then evaluates is no longer the name; MATLAB raises MATLAB:m_illegal_character
- **Expected**: the global variable globalName set to value, as for any other name
- **Source lines**: 13-14
- **Documented in**: `test/verifiedTests/base/testUtilities/testSetGlobal.m`

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

### `src/dataIntegration/chemoInformatics/inchi/getChargeFromInChI.m`

#### An empty component of a multi-component charge layer stops with an error

- **Severity**: error
- **Trigger**: getChargeFromInChI('InChI=1S/Na.H2O/h;1H2/q+1;/p-1') (sodium hydroxide); getChargeFromInChI('InChI=1S/2C2H4O2.Ca/c2*1-2(3)4;/h2*1H3,(H,3,4);/q;+2/p-2') (calcium acetate); standard InChI leaves the charge of an uncharged component empty
- **Observed**: "Error: This statement is incomplete." raised by eval('') in the anonymous function on line 43 (strsplit of '+1;' or ';+2' gives an empty component)
- **Expected**: an empty component counts as 0: sodium hydroxide charge 0 and chargeWithoutProtons +1; calcium acetate charge 0 and chargeWithoutProtons +2
- **Source lines**: 41-46, 52-53
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testGetChargeFromInChI.m`

### `src/dataIntegration/chemoInformatics/inchi/getFormulaFromInChI.m`

#### A formula that loses all its hydrogen atoms keeps one H

- **Severity**: wrong-result
- **Trigger**: getFormulaFromInChI('InChI=1S/H2O4S/c1-5(2,3)4/h(H2,1,2,3,4)/p-2') (sulfate; also phosphate 'InChI=1S/H3O4P/c1-5(2,3)4/h(H3,1,2,3,4)/p-3' and carbonate 'InChI=1S/CH2O3/c2-1(3)4/h(H2,2,3,4)/p-2')
- **Observed**: formula 'HO4S', protons = 0 (phosphate 'HO4P', carbonate 'CHO3'); the H coefficient 0 is written as 'H0' (lines 59-64) and lines 72-79 replace 'H0' by 'H'
- **Expected**: 'O4S' (phosphate 'O4P', carbonate 'CO3'), protons = 0
- **Source lines**: 59-64, 72-79
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testGetFormulaFromInChI.m`

#### Element counts are assigned to the wrong elements on the combining path

- **Severity**: wrong-result
- **Trigger**: getFormulaFromInChI('InChI=1S/C2H3Cl/c1-2-3/h2H,1H2/p+1') (any InChI with a /p layer or a composite or multiplied formula whose element order differs from alphabetical order, e.g. one containing Cl, Co, Br, Ca)
- **Observed**: formula 'C2Cl3H2', protons = 2; line 50 sorts the new elements alphabetically (setdiff) but line 55 adds the coefficients in the order of the formula layer, so Cl receives the 3 of H and H the 1 of Cl (plus the proton)
- **Expected**: C2, H4, Cl1 (e.g. 'C2H4Cl') and protons = 4
- **Source lines**: 50-55
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testGetFormulaFromInChI.m`

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

### `src/reconstruction/modelGeneration/massBalance/getElementalComposition.m`

#### Formula numbers in error messages lose their zero padding inside parentheses

- **Severity**: cosmetic
- **Trigger**: getElementalComposition({'H2O'; 'h2o'; 'H2O'; 'H2O'; 'H2O'; 'H2O'; '(cD)'; 'H2O'; 'H2O'; 'H2O'}) (ten or more formulae, one failing inside or next to a parenthesis)
- **Observed**: "#02:  h2o" but "#7:  (cD)" in the same message; the nested function uses the digit count of the recursive call that found the error (line 80 of that call: one formula, one digit)
- **Expected**: the same width for every formula number ("#07:  (cD)")
- **Source lines**: 252
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testGetElementalComposition.m`

### `src/reconstruction/modelGeneration/massBalance/numAtomsOfElementInFormula.m`

#### A formula given as a cell or number stops with a MATLAB error, not the class error

- **Severity**: cosmetic
- **Trigger**: numAtomsOfElementInFormula({'C2'}, 'C')
- **Observed**: a warning (line 41), then "Invalid data type. Argument must be numeric, char, or logical." from line 48
- **Expected**: "Formula must be given by a variable of class char" (line 126)
- **Source lines**: 46-48
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testNumAtomsOfElementInFormula.m`

#### Output is printed at printLevel 0

- **Severity**: cosmetic
- **Trigger**: numAtomsOfElementInFormula('2H2O', 'H', 0); numAtomsOfElementInFormula('CH0', 'H', 0)
- **Observed**: the formula is displayed (line 39), and "Formula before:" / "Formula after:" lines are printed (lines 49, 52), whatever printLevel is
- **Expected**: no output at printLevel 0
- **Source lines**: 39, 49, 52
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testNumAtomsOfElementInFormula.m`

#### Zero counts are replaced only when the formula holds a single zero

- **Severity**: limitation
- **Trigger**: numAtomsOfElementInFormula('C10H0', 'H', 0); numAtomsOfElementInFormula('H0O0', 'O', 0)
- **Observed**: 'C10H0' returns 0 without the replacement (while 'CH0' is replaced by 'CH' and returns 1); 'H0O0' stops with the error "Colon operands must be real scalars." (line 51)
- **Expected**: every letter followed by a zero treated as for 'CH0', without an error
- **Source lines**: 47-53
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testNumAtomsOfElementInFormula.m`

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

### `src/reconstruction/refinement/GPRLogic/AndNode.m`

#### A numeric literal ID is not deleted

- **Severity**: limitation
- **Trigger**: n = AndNode(); n.addChild(LiteralNode('1')); n.addChild(LiteralNode('2')); n.deleteLiteral(1)
- **Observed**: n.toString() is still 'x(1) and x(2)' (no error); LiteralNode.contains compares the number with the text ID with strcmp
- **Expected**: 'x(2)', as for n.deleteLiteral('1'); the Node interface documents "literalID: The LiteralID (As string or number)"
- **Source lines**: 38
- **Documented in**: `test/verifiedTests/reconstruction/testGPRLogic/testAndNode.m`

#### convertToDNF of an AndNode without children stops with an error

- **Severity**: limitation
- **Trigger**: AndNode().convertToDNF() (an empty AndNode is also what deleteLiteral(id, false) leaves when the literal is a direct child)
- **Observed**: "Index exceeds array bounds." in AndNode.nextcombination (line 189): the empty step vector has no first element
- **Expected**: a DNF node (the class does not define the meaning of an empty node)
- **Source lines**: 125-126, 188-189
- **Documented in**: `test/verifiedTests/reconstruction/testGPRLogic/testAndNode.m`

### `src/reconstruction/refinement/GPRLogic/FormulaParser.m`

#### An empty rule stops with an error

- **Severity**: limitation
- **Trigger**: fp = FormulaParser(); fp.parseFormula('')
- **Observed**: error "Unrecognized function or variable 'finalid'." (FormulaParser.parseFormula:84); no sub-formula is stored for an empty text
- **Expected**: an empty tree (or a documented error); the callers in the toolbox skip empty rules before calling parseFormula
- **Source lines**: 84
- **Documented in**: `test/verifiedTests/reconstruction/testGPRLogic/testFormulaParser.m`

#### createNodeStructure fails for a text with spaced operators that is not a stored key

- **Severity**: limitation
- **Trigger**: fp = FormulaParser(); fp.createNodeStructure('1 | 2 & 3') (a direct call of the method its header marks as a private function)
- **Observed**: the branch of lines 143-175 is the only way in, and line 172 reads andliterals, which that branch never defines
- **Expected**: the node tree of the text, as for the stored sub-formulas
- **Source lines**: 143-175
- **Documented in**: `test/verifiedTests/reconstruction/testGPRLogic/testFormulaParser.m`

### `src/reconstruction/refinement/GPRLogic/Node.m`

#### contains stops with an error on a node without children

- **Severity**: limitation
- **Trigger**: n = OrNode(); r = n.contains('1')
- **Observed**: "Output argument "res" (and possibly others) not assigned a value in the execution with "Node/contains" function."
- **Expected**: false (an empty node contains no literal)
- **Source lines**: 167-173
- **Documented in**: `test/verifiedTests/reconstruction/testGPRLogic/testNode.m`

#### isequal is false for a tree with a repeated clause, and not symmetric

- **Severity**: wrong-result
- **Trigger**: a = OrNode(); a.children = [LiteralNode('1'), LiteralNode('2')]; b = OrNode(); b.children = [LiteralNode('1'), LiteralNode('2'), LiteralNode('1')]; a.isequal(b)
- **Observed**: a.isequal(b) is false and b.isequal(a) is true; the loop over the remaining clauses of otherNode compares geneSets{1} (already empty) instead of the remaining clause, so any repeated clause of otherNode makes the result false
- **Expected**: true in both directions (header: "true, if this node is equal to the other node, i.e. it represents the same boolean truth table"; x1 or x2 or x1 = x1 or x2)
- **Source lines**: 360-377
- **Documented in**: `test/verifiedTests/reconstruction/testGPRLogic/testNode.m`

#### isequal is false for equivalent trees with different literals

- **Severity**: wrong-result
- **Trigger**: x = AndNode(); x.children = [LiteralNode('1'), LiteralNode('2')]; a = OrNode(); a.children = [LiteralNode('1'), x]; b = OrNode(); b.children = LiteralNode('1'); a.isequal(b)
- **Observed**: false (the literal sets {1, 2} and {1} differ, and DNF clauses are compared without absorption)
- **Expected**: true, as x1 or (x1 and x2) has the truth table of x1 (header: "i.e. it represents the same boolean truth table")
- **Source lines**: 321-326, 331-359
- **Documented in**: `test/verifiedTests/reconstruction/testGPRLogic/testNode.m`

#### removeDuplicateLiterals removes the wrong children when a child that is not a literal comes before a literal

- **Severity**: wrong-result
- **Trigger**: n = OrNode(); n.children = [LiteralNode('1'), AndNode(), LiteralNode('2')]; n.removeDuplicateLiterals()
- **Observed**: n.toString() is '(x(1) or )': the literal 2, which has no duplicate, is removed; with n.children = [AndNode(), LiteralNode('1'), LiteralNode('1')] both literals 1 are removed (one child left, of class AndNode). The positions returned by unique count among the literal children only and are then compared with positions among all children
- **Expected**: only repeated literal nodes are removed: x(1) and x(2) kept in the first case, one x(1) kept in the second (header: "Remove all duplicate literal nodes in this node")
- **Source lines**: 199-201
- **Documented in**: `test/verifiedTests/reconstruction/testGPRLogic/testNode.m`

### `src/reconstruction/refinement/GPRLogic/OrNode.m`

#### A numeric literal ID is not deleted

- **Severity**: limitation
- **Trigger**: n = OrNode(); n.addChild(LiteralNode('1')); n.addChild(LiteralNode('2')); n.deleteLiteral(1)
- **Observed**: n.toString() is still '(x(1) or x(2))' (no error); LiteralNode.contains compares the number with the text ID with strcmp
- **Expected**: '(x(2))', as for n.deleteLiteral('1'); the Node interface documents "literalID: The LiteralID (As string or number)"
- **Source lines**: 138
- **Documented in**: `test/verifiedTests/reconstruction/testGPRLogic/testOrNode.m`

#### convertToCNF of an OrNode without children returns an empty AndNode, which evaluates to true, while the empty OrNode evaluates to false

- **Severity**: limitation
- **Trigger**: n = OrNode(); n.evaluate(containers.Map()), n.convertToCNF().evaluate(containers.Map()) (an empty OrNode is also what deleteLiteral leaves when every child is removed)
- **Observed**: false, and true (an AndNode with 0 children)
- **Expected**: an equivalent CNF (the class does not define the meaning of an empty node)
- **Source lines**: 31-39
- **Documented in**: `test/verifiedTests/reconstruction/testGPRLogic/testOrNode.m`

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
