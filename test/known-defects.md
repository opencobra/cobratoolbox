# Known defects in tested functions

> **Generated file: do not edit by hand.** It is built from the "Known defects documented" section of each test header by `python3 .github/scripts/known_defects.py` (Constitution III-Defects).
> It is a snapshot: a function may have been changed or fixed since an entry was written. When you rely on an entry or work on resolving a defect, re-check it against the current source, then update the test header and regenerate this file.

821 known defects in 451 functions (303 wrong-result, 258 error, 73 unusable-option, 124 cosmetic, 63 limitation).

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
| `src/analysis/FVA/fastFVA/mex/generateMexFastFVA.m` | limitation | CPLEX 12.10 and later 12.1x versions are classed as older than 12.8 | `test/verifiedTests/analysis/testFVA/testGenerateMexFastFVA.m` |
| `src/analysis/FVA/fastFVA/mex/generateMexFastFVA.m` | cosmetic | printLevel 2 prints a truncated compilation command and a warning | `test/verifiedTests/analysis/testFVA/testGenerateMexFastFVA.m` |
| `src/analysis/FVA/fastFVA/mex/generateMexFastFVA.m` | cosmetic | the CPLEX root stays on the MATLAB path when the function stops with an error | `test/verifiedTests/analysis/testFVA/testGenerateMexFastFVA.m` |
| `src/analysis/FVA/fastFVA/mex/generateMexFastFVA.m` | cosmetic | the existence of the CPLEX library file is never checked | `test/verifiedTests/analysis/testFVA/testGenerateMexFastFVA.m` |
| `src/analysis/FVA/fastFVA/mex/generateMexFastFVA.m` | wrong-result | the version flag and the compiler options are never passed to mex | `test/verifiedTests/analysis/testFVA/testGenerateMexFastFVA.m` |
| `src/analysis/KLdistance/KLdistance.m` | wrong-result | The two densities are compared on different grids, so distinct populations get a zero distance | `test/verifiedTests/analysis/testKLdistance/testKLdistance.m` |
| `src/analysis/MOMA/MOMA.m` | error | Models with different reaction sets stop with an error | `test/verifiedTests/analysis/testMOMA/testMOMA.m` |
| `src/analysis/QFCA/QFCA.m` | error | A network that reduces to one metabolite stops with an error | `test/verifiedTests/analysis/testQFCA/testQFCA.m` |
| `src/analysis/dynamicFBA/dynamicFBA.m` | cosmetic | The number of tracked exchange reactions is printed on every call | `test/verifiedTests/analysis/testDynamicFBA/testDynamicFBA.m` |
| `src/analysis/ecosystem/clusterEcosystemPoints.m` | wrong-result | The hierarchical method returns the requested maximum k as the number of clusters | `test/verifiedTests/analysis/testEcosystem/testClusterEcosystemPoints.m` |
| `src/analysis/ecosystem/getQualitativeFluxStates.m` | wrong-result | Zero band applied inconsistently to the maximum and to max - min | `test/verifiedTests/analysis/testEcosystem/testGetQualitativeFluxStates.m` |
| `src/analysis/ecosystem/matchEcosystemClusters.m` | wrong-result | clusters without points are matched to a reference cluster instead of NaN, and an empty reference cluster absorbs unmatched clusters | `test/verifiedTests/analysis/testEcosystem/testMatchEcosystemClusters.m` |
| `src/analysis/exploration/findCarbonRxns.m` | wrong-result | Two-letter element symbols beginning with C are counted as carbon | `test/verifiedTests/analysis/testExploration/testFindCarbonRxns.m` |
| `src/analysis/exploration/findMetFromCompartment.m` | limitation | A compartment letter without brackets matches every identifier with that letter | `test/verifiedTests/analysis/testExploration/testFindMetFromCompartment.m` |
| `src/analysis/exploration/findMetFromCompartment.m` | error | A compartment without metabolites stops with an error | `test/verifiedTests/analysis/testExploration/testFindMetFromCompartment.m` |
| `src/analysis/exploration/findRxnFromCompartment.m` | wrong-result | A compartment with a single metabolite returns the first reaction of the model | `test/verifiedTests/analysis/testExploration/testFindRxnFromCompartment.m` |
| `src/analysis/exploration/findRxnsFromGenes.m` | error | Calling with the optional numericFlag only stops with an error | `test/verifiedTests/analysis/testExploration/testFindRxnsFromGenes.m` |
| `src/analysis/exploration/findRxnsFromMets.m` | error | The documented positional printFlag alone stops with an error | `test/verifiedTests/analysis/testExploration/testFindRxnsFromMets.m` |
| `src/analysis/exploration/findRxnsFromMets.m` | unusable-option | The parameter verbFlag can never be used | `test/verifiedTests/analysis/testExploration/testFindRxnsFromMets.m` |
| `src/analysis/exploration/findRxnsFromMets.m` | error | exclusive stops with an error together with the direction or minimal options | `test/verifiedTests/analysis/testExploration/testFindRxnsFromMets.m` |
| `src/analysis/exploration/findSubSystemsFromGenes.m` | error | A gene that no reaction uses stops the call with onlyOneSub | `test/verifiedTests/analysis/testExploration/testFindSubSystemsFromGenes.m` |
| `src/analysis/exploration/findSubSystemsFromGenes.m` | error | A model without rxnGeneMat and rules cannot be used | `test/verifiedTests/analysis/testExploration/testFindSubSystemsFromGenes.m` |
| `src/analysis/exploration/findSubSystemsFromGenes.m` | wrong-result | Sub-systems stored as character arrays come back as single letters | `test/verifiedTests/analysis/testExploration/testFindSubSystemsFromGenes.m` |
| `src/analysis/exploration/generateHyperlinkedModel.m` | error | A model without rules and without grRules stops at a reference to the missing field rules | `test/verifiedTests/analysis/testExploration/testGenerateHyperlinkedModel.m` |
| `src/analysis/exploration/generateHyperlinkedModel.m` | error | Every call stops at the undefined variable addGrRulesLinked | `test/verifiedTests/analysis/testExploration/testGenerateHyperlinkedModel.m` |
| `src/analysis/exploration/generateHyperlinkedModel.m` | error | The hyperlink format string is read from the undefined variable command | `test/verifiedTests/analysis/testExploration/testGenerateHyperlinkedModel.m` |
| `src/analysis/exploration/getMIRIAMAnnotations.m` | error | A character vector for the ids option stops the call | `test/verifiedTests/analysis/testExploration/testGetMIRIAMAnnotations.m` |
| `src/analysis/exploration/getMIRIAMAnnotations.m` | wrong-result | Resources of an earlier controlled-vocabulary term leak into a later term with fewer identifiers | `test/verifiedTests/analysis/testExploration/testGetMIRIAMAnnotations.m` |
| `src/analysis/exploration/isReactionInSubSystem.m` | wrong-result | Reactions listed by name out of model order get each other's answers | `test/verifiedTests/analysis/testIsReactionInSubSystem/testIsReactionInSubSystem.m` |
| `src/analysis/exploration/plotEssentialRxns.m` | error | Errors when no reaction is selected | `test/verifiedTests/analysis/testExploration/testPlotEssentialRxns.m` |
| `src/analysis/exploration/plotEssentialRxns.m` | wrong-result | The output is a cell array of reaction identifiers, not a table of fluxes | `test/verifiedTests/analysis/testExploration/testPlotEssentialRxns.m` |
| `src/analysis/exploration/printCouplingConstraints.m` | error | The documented output is not assigned with the default printLevel, so a call requesting it stops | `test/verifiedTests/analysis/testExploration/testPrintCouplingConstraints.m` |
| `src/analysis/exploration/printFluxBounds.m` | error | The documented calls without rxnNameFlag stop with an error | `test/verifiedTests/analysis/testExploration/testPrintFluxBounds.m` |
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
| `src/analysis/gMCS/calculateMCS.m` | error | A row cell array rxn_set together with KO stops with an error | `test/verifiedTests/analysis/testGeneMCS/testCalculateMCS.m` |
| `src/analysis/gMCS/calculateMCS.m` | cosmetic | The enumeration writes tmp.mat into the current folder | `test/verifiedTests/analysis/testGeneMCS/testCalculateMCS.m` |
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
| `src/analysis/igemRNA/findUpDownRegulatedGenes/findUpDownRegulatedGenes.m` | wrong-result | Genes are matched by row position, not by gene ID | `test/verifiedTests/analysis/testFindUpDownRegulatedGenes/testFindUpDownRegulatedGenes.m` |
| `src/analysis/multiSpecies/SteadyCom/subroutines/SteadyComSubroutines.m` | error | 'initialize' reads modelCom.indCom before building it from infoCom | `test/verifiedTests/analysis/testSteadyCom/testSteadyComSubroutines.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/correlateFluxWithTaxonAbundance.m` | error | Every call stops with an error when the taxonomy is prepared for export | `test/verifiedTests/analysis/testAdditionalAnalysis/testCorrelateFluxWithTaxonAbundance.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/makeViolinPlots.m` | cosmetic | Box plots print the handle array of every plot | `test/verifiedTests/analysis/testAdditionalAnalysis/testMakeViolinPlots.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/makeViolinPlots.m` | wrong-result | Features with negative values are dropped as if they were all zero | `test/verifiedTests/analysis/testAdditionalAnalysis/testMakeViolinPlots.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/performStatisticalAnalysis.m` | wrong-result | Fecal exchange features never get a metabolite description | `test/verifiedTests/analysis/testAdditionalAnalysis/testPerformStatisticalAnalysis.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/performStatisticalAnalysis.m` | wrong-result | Samples whose values are all zero are not removed | `test/verifiedTests/analysis/testAdditionalAnalysis/testPerformStatisticalAnalysis.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/plotFluxesAgainstOrganismAbundances.m` | cosmetic | The current folder stays Metabolite_plots after an error | `test/verifiedTests/analysis/testAdditionalAnalysis/testPlotFluxesAgainstOrganismAbundances.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/plotFluxesAgainstOrganismAbundances.m` | error | The documented orientation of the flux table and relative file paths stop with an error | `test/verifiedTests/analysis/testAdditionalAnalysis/testPlotFluxesAgainstOrganismAbundances.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/addMicrobeCommunityBiomass.m` | wrong-result | Abundance weights are rounded to six significant digits | `test/verifiedTests/analysis/testMultiSpeciesModelling/testAddMicrobeCommunityBiomass.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/extractFullRes.m` | error | Errors when the first sample is infeasible and a later one is feasible | `test/verifiedTests/analysis/testMgPipe/testExtractFullRes.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/mgSimResCollect.m` | wrong-result | The feasibility of every diet is read from the last diet | `test/verifiedTests/analysis/testMgPipe/testMgSimResCollect.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/mgSimResCollect.m` | error | Two samples stop with an error in the PCoA | `test/verifiedTests/analysis/testMgPipe/testMgSimResCollect.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/mgSimResCollect.m` | wrong-result | Uptake of an exchange missing from a sample is copied from the previous sample | `test/verifiedTests/analysis/testMgPipe/testMgSimResCollect.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/parsave.m` | wrong-result | A structure without a rxns field is silently not saved | `test/verifiedTests/analysis/testMgPipe/testParsave.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/plotMappingInfo.m` | error | The documented matrix inputs stop with an error | `test/verifiedTests/analysis/testMgPipe/testPlotMappingInfo.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/plotMappingInfo.m` | wrong-result | The heatmap shows only the first four individuals | `test/verifiedTests/analysis/testMgPipe/testPlotMappingInfo.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/retrieveModelStats.m` | wrong-result | The size plot is never produced without a stratification file | `test/verifiedTests/analysis/testMgPipe/testRetrieveModelStats.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/translateMetagenome2AGORA.m` | wrong-result | Abundances read from a tsv file are added and normalized as text | `test/verifiedTests/analysis/testMultiSpeciesModelling/testTranslateMetagenome2AGORA.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/updateTaxonomyInfoAGORA.m` | cosmetic | The row counter is printed for every strain | `test/verifiedTests/analysis/testMgPipe/testUpdateTaxonomyInfoAGORA.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/calculateInteractionsByTaxon.m` | error | Errors when the taxon table has fewer rows than columns | `test/verifiedTests/analysis/testMultiSpeciesModelling/testCalculateInteractionsByTaxon.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/getMultiSpeciesModelId.m` | cosmetic | The compartmentalization error never names the species | `test/verifiedTests/analysis/testMultiSpeciesModelling/testGetMultiSpeciesModelId.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/joinModelsPairwiseFromList.m` | error | Two models whose file names start with the same model name stop the function | `test/verifiedTests/analysis/testMultiSpeciesModelling/testJoinModelsPairwiseFromList.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/printUptakeBoundCom.m` | limitation | A model without indCom cannot be printed | `test/verifiedTests/analysis/testMultiSpeciesModelling/testPrintUptakeBoundCom.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/printUptakeBoundCom.m` | limitation | A model without infoCom fails after the default abbreviations are built | `test/verifiedTests/analysis/testMultiSpeciesModelling/testPrintUptakeBoundCom.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/printUptakeBoundCom.m` | cosmetic | Continuation lines of long names are printed as the literal text %30s in the host layout | `test/verifiedTests/analysis/testMultiSpeciesModelling/testPrintUptakeBoundCom.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/useDiet.m` | error | A diet with fewer rows than columns stops with an index error | `test/verifiedTests/analysis/testMultiSpeciesModelling/testUseDiet.m` |
| `src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/useDiet.m` | limitation | Numeric bounds become NaN | `test/verifiedTests/analysis/testMultiSpeciesModelling/testUseDiet.m` |
| `src/analysis/parsimoniousFBA/pFBA.m` | error | A call with one output stops with an error | `test/verifiedTests/analysis/testpFBA/testpFBA.m` |
| `src/analysis/persephone/additionalFunctions/combineFluxResults.m` | error | Errors for a common germ-free sample preceded by a sample of the first run only | `test/verifiedTests/analysis/testPersephone/testCombineFluxResults.m` |
| `src/analysis/persephone/additionalFunctions/combineFluxResults.m` | wrong-result | Shadow prices of the second run are dropped when the folders hold different samples | `test/verifiedTests/analysis/testPersephone/testCombineFluxResults.m` |
| `src/analysis/persephone/additionalFunctions/convertVMHIDName.m` | wrong-result | Names of unknown IDs are dropped, so names and IDs do not line up | `test/verifiedTests/analysis/testPersephone/testConvertVMHIDName.m` |
| `src/analysis/persephone/additionalFunctions/convertVMHIDName.m` | error | The numeric skip flag 0 for metNames raises an error | `test/verifiedTests/analysis/testPersephone/testConvertVMHIDName.m` |
| `src/analysis/persephone/additionalFunctions/convertVMHIDName.m` | error | The skip flag 0 for VMHIDs raises an error | `test/verifiedTests/analysis/testPersephone/testConvertVMHIDName.m` |
| `src/analysis/persephone/additionalFunctions/convertVMHIDName.m` | error | similarMets is never assigned from the suggestions | `test/verifiedTests/analysis/testPersephone/testConvertVMHIDName.m` |
| `src/analysis/persephone/additionalFunctions/dimensionalityReductionAndMultivariateAnalysis.m` | error | A text (cell array) variable of interest is not supported | `test/verifiedTests/analysis/testPersephone/testDimensionalityReductionAndMultivariateAnalysis.m` |
| `src/analysis/persephone/additionalFunctions/dimensionalityReductionAndMultivariateAnalysis.m` | error | Errors when the regression of a metadata variable gives a warning | `test/verifiedTests/analysis/testPersephone/testDimensionalityReductionAndMultivariateAnalysis.m` |
| `src/analysis/persephone/additionalFunctions/dimensionalityReductionAndMultivariateAnalysis.m` | cosmetic | The loadings figure of PC 1 is saved as Loadings_PC11.png | `test/verifiedTests/analysis/testPersephone/testDimensionalityReductionAndMultivariateAnalysis.m` |
| `src/analysis/persephone/additionalFunctions/dimensionalityReductionAndMultivariateAnalysis.m` | wrong-result | The regression figures pair the values of one variable with the name of another | `test/verifiedTests/analysis/testPersephone/testDimensionalityReductionAndMultivariateAnalysis.m` |
| `src/analysis/persephone/additionalFunctions/generatePanAGORA2database.m` | cosmetic | Hard-coded personal input folder | `test/verifiedTests/analysis/testPersephone/testGeneratePanAGORA2database.m` |
| `src/analysis/persephone/additionalFunctions/generatePanAGORA2database.m` | wrong-result | Only the first three strains are processed | `test/verifiedTests/analysis/testPersephone/testGeneratePanAGORA2database.m` |
| `src/analysis/persephone/additionalFunctions/generatePanDatabase.m` | wrong-result | Coefficients of new metabolites are written to the wrong rows | `test/verifiedTests/analysis/testPersephone/testGeneratePanDatabase.m` |
| `src/analysis/persephone/additionalFunctions/generatePanDatabase.m` | wrong-result | Coefficients of new reactions are written to the wrong columns | `test/verifiedTests/analysis/testPersephone/testGeneratePanDatabase.m` |
| `src/analysis/persephone/additionalFunctions/generatePanDatabase.m` | error | The documented default inputDir needs an explicit empty argument | `test/verifiedTests/analysis/testPersephone/testGeneratePanDatabase.m` |
| `src/analysis/persephone/additionalFunctions/generateStackedBarPlot.m` | error | Errors for a single sample | `test/verifiedTests/analysis/testPersephone/testGenerateStackedBarPlot.m` |
| `src/analysis/persephone/additionalFunctions/getVMHID.m` | wrong-result | Suggestions are misaligned after a found name | `test/verifiedTests/analysis/testPersephone/testGetVMHID.m` |
| `src/analysis/persephone/additionalFunctions/microbiomeMappingStats.m` | cosmetic | An unlabelled count is printed | `test/verifiedTests/analysis/testPersephone/testMicrobiomeMappingStats.m` |
| `src/analysis/persephone/additionalFunctions/microbiomeMappingStats.m` | wrong-result | Taxa whose name contains "pan" are counted as unmapped | `test/verifiedTests/analysis/testPersephone/testMicrobiomeMappingStats.m` |
| `src/analysis/persephone/additionalFunctions/microbiomeMappingStats.m` | cosmetic | The sheet of unmapped taxa is named 'Umapped' | `test/verifiedTests/analysis/testPersephone/testMicrobiomeMappingStats.m` |
| `src/analysis/persephone/additionalFunctions/physiologicalConstraintsHMDBbasedTEMP.m` | wrong-result | Blood uptake constraints of organs other than the kidney are never applied | `test/verifiedTests/analysis/testPersephone/testPhysiologicalConstraintsHMDBbasedTEMP.m` |
| `src/analysis/persephone/additionalFunctions/physiologicalConstraintsHMDBbasedTEMP.m` | wrong-result | Measured concentrations are never matched when the data has more than one row | `test/verifiedTests/analysis/testPersephone/testPhysiologicalConstraintsHMDBbasedTEMP.m` |
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
| `src/analysis/rMTA/calculateEPSILON.m` | error | 'unique_epsilon' stops with an error when no reaction changes | `test/verifiedTests/analysis/testRMTA/testCalculateEPSILON.m` |
| `src/analysis/rMTA/rMTAsaveInExcel.m` | unusable-option | The documented default of alpha_values cannot be used | `test/verifiedTests/analysis/testRMTA/testRMTAsaveInExcel.m` |
| `src/analysis/rMTA/rMTAsaveInExcel.m` | unusable-option | The sheets written with xlswrite need Microsoft Excel | `test/verifiedTests/analysis/testRMTA/testRMTAsaveInExcel.m` |
| `src/analysis/relaxedFBA/relaxedFBA.m` | limitation | A generic LP without rxns and mets stops with an error | `test/verifiedTests/analysis/testRelaxedFBA/testRelaxedFBA.m` |
| `src/analysis/relaxedFBA/relaxedFBA.m` | error | Extra variables given only by model.D stop with an error | `test/verifiedTests/analysis/testRelaxedFBA/testRelaxedFBA.m` |
| `src/analysis/rumba/classifyRxns.m` | error | The documented defaults of maxMetConn, maxNumPnts and LoopRxnsToIgnore are not implemented, so these arguments cannot be omitted | `test/verifiedTests/analysis/testRumba/testClassifyRxns.m` |
| `src/analysis/rumba/compareConditions.m` | limitation | Sample-point count taken from the first metabolite of the first list | `test/verifiedTests/analysis/testRumba/testCompareConditions.m` |
| `src/analysis/sampling/ACHR/ACHRSampler.m` | cosmetic | The time-limit exit leaves the error log open | `test/verifiedTests/analysis/testSampling/testACHRSampler.m` |
| `src/analysis/sampling/ACHR/ACHRSampler.m` | cosmetic | printLevel 0 does not silence the header and the step warnings | `test/verifiedTests/analysis/testSampling/testACHRSampler.m` |
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
| `src/analysis/sampling/CHRR/chrrExpSampler.m` | limitation | A model without metabolites and a reaction of zero width stops in preprocess | `test/verifiedTests/analysis/testSampling/testChrrExpSampler.m` |
| `src/analysis/sampling/CHRR/chrrExpSampler.m` | error | minFlux and maxFlux cannot be requested together with a rounded polytope | `test/verifiedTests/analysis/testSampling/testChrrExpSampler.m` |
| `src/analysis/sampling/CHRR/chrrSampler.m` | error | minFlux and maxFlux cannot be requested together with a rounded polytope | `test/verifiedTests/analysis/testSampling/testChrrSampler.m` |
| `src/analysis/sampling/compareSampleTraj.m` | error | The documented default of nBins is never set, so a call without nBins fails | `test/verifiedTests/analysis/testSampling/testCompareSampleTraj.m` |
| `src/analysis/sampling/compareSampleTraj.m` | wrong-result | The fallback to the reversed reaction <name>_r never runs | `test/verifiedTests/analysis/testSampling/testCompareSampleTraj.m` |
| `src/analysis/sampling/compareTwoSamplesStat.m` | wrong-result | The chi-square p values are cumulative probabilities, near 0 for identical samples | `test/verifiedTests/analysis/testSampling/testCompareTwoSamplesStat.m` |
| `src/analysis/sampling/loadSamples.m` | wrong-result | More points than pointsPerFile are taken from a file at regular intervals | `test/verifiedTests/analysis/testSampling/testLoadSamples.m` |
| `src/analysis/sampling/plotSampleHist.m` | error | A call in which no requested reaction is kept stops with an index error | `test/verifiedTests/analysis/testSampling/testPlotSampleHist.m` |
| `src/analysis/sampling/plotSampleHist.m` | wrong-result | A reaction held as its flipped copy <rxn>_r in one model is never plotted | `test/verifiedTests/analysis/testSampling/testPlotSampleHist.m` |
| `src/analysis/sampling/plotSampleHist.m` | cosmetic | The subplot grid is transposed for perScreen = [nY, nX] | `test/verifiedTests/analysis/testSampling/testPlotSampleHist.m` |
| `src/analysis/sampling/printSampleStats.m` | wrong-result | With several samples only the first sample's mode is printed | `test/verifiedTests/analysis/testSampling/testPrintSampleStats.m` |
| `src/analysis/sampling/sampleScatterMatrix.m` | error | The documented optional inputs cannot be omitted one at a time | `test/verifiedTests/analysis/testSampling/testSampleScatterMatrix.m` |
| `src/analysis/sampling/sampleScatterMatrix.m` | cosmetic | The progress of the two-set layout exceeds 100 % | `test/verifiedTests/analysis/testSampling/testSampleScatterMatrix.m` |
| `src/analysis/subspaces/checkScaling.m` | error | A model whose lower bounds are all zero stops with an error | `test/verifiedTests/analysis/testSubspaces/testCheckScaling.m` |
| `src/analysis/subspaces/checkScaling.m` | error | A model with C and d but without b stops with an error | `test/verifiedTests/analysis/testSubspaces/testCheckScaling.m` |
| `src/analysis/subspaces/lsqr/lsqr.m` | cosmetic | The x = 0 message is printed even when show = 0 | `test/verifiedTests/analysis/testSubspaces/testLsqr.m` |
| `src/analysis/subspaces/lsqr/lsqr.m` | error | r1norm and r2norm are not assigned when A'*b = 0 | `test/verifiedTests/analysis/testSubspaces/testLsqr.m` |
| `src/analysis/subspaces/lsqr/lsqrtest.m` | cosmetic | The function handle is printed by a statement without a semicolon | `test/verifiedTests/analysis/testSubspaces/testLsqrtest.m` |
| `src/analysis/subspaces/nullspace/nullSpaceOperator.m` | unusable-option | The option scale = 0 always fails | `test/verifiedTests/analysis/testSubspaces/testNullSpaceOperator.m` |
| `src/analysis/subspaces/rank/getRankLUSOL.m` | wrong-result | q is wrong when A has a zero column | `test/verifiedTests/analysis/testRank/testGetRankLUSOL.m` |
| `src/analysis/thermo/directionalityReport/directionalityChangeReport.m` | wrong-result | The descriptions of the bydGt0LHS and bydGt0RHS classes state the wrong probability bound | `test/verifiedTests/analysis/testThermo/testDirectionalityChangeReport.m` |
| `src/analysis/thermo/directionalityReport/directionalityChangeReport.m` | wrong-result | Two pairs of classes are written to the same file, so one class of each pair is lost | `test/verifiedTests/analysis/testThermo/testDirectionalityChangeReport.m` |
| `src/analysis/thermo/directionalityReport/directionalityStats.m` | wrong-result | The printed Reverse -> Reverse count is the number of reverse -> reversible reactions | `test/verifiedTests/analysis/testThermo/testDirectionalityStats.m` |
| `src/analysis/thermo/directionalityReport/directionalityStats.m` | cosmetic | The reverse -> uncertain count is labelled Reversible -> Uncertain | `test/verifiedTests/analysis/testThermo/testDirectionalityStats.m` |
| `src/analysis/thermo/directionalityReport/directionalityStatsFigures.m` | wrong-result | The forward -> reversible by standard Gibbs energy chart counts every reaction twice and doubles the percentage of its title | `test/verifiedTests/analysis/testThermo/testDirectionalityStatsFigures.m` |
| `src/analysis/thermo/directionalityReport/directionalityStatsFigures.m` | cosmetic | The title of the standard Gibbs energy chart names the formation energy | `test/verifiedTests/analysis/testThermo/testDirectionalityStatsFigures.m` |
| `src/analysis/thermo/directionalityReport/forwardProbablyReverseFigures.m` | limitation | The structure array model.rxn is required but not documented | `test/verifiedTests/analysis/testThermo/testForwardProbablyReverseFigures.m` |
| `src/analysis/thermo/directionalityReport/forwardProbablyReverseFigures.m` | unusable-option | miliMolarStandard true stops with an error | `test/verifiedTests/analysis/testThermo/testForwardProbablyReverseFigures.m` |
| `src/analysis/thermo/directionalityReport/forwardReversibleFigures.m` | error | Reactions with a fixed DrGt0 stop the figures with an error | `test/verifiedTests/analysis/testThermo/testForwardReversibleFigures.m` |
| `src/analysis/thermo/directionalityReport/forwardReversibleFigures.m` | cosmetic | The warning about extra NaN probabilities is garbled | `test/verifiedTests/analysis/testThermo/testForwardReversibleFigures.m` |
| `src/analysis/thermo/directionalityReport/forwardTransportQuantReverseFigures.m` | error | A model without a qualifying transport reaction stops with an error | `test/verifiedTests/analysis/testThermo/testForwardTransportQuantReverseFigures.m` |
| `src/analysis/thermo/directionalityReport/forwardTransportQuantReverseFigures.m` | limitation | The fields transportRxnBool and directions.forwardProbability are required but not documented | `test/verifiedTests/analysis/testThermo/testForwardTransportQuantReverseFigures.m` |
| `src/analysis/thermo/directionalityReport/plotFeasibleReactionEnergyRanges.m` | error | Every call fails when the error bars are adjusted | `test/verifiedTests/analysis/testThermo/testPlotFeasibleReactionEnergyRanges.m` |
| `src/analysis/thermo/directionalityReport/plotFeasibleReactionEnergyRanges.m` | wrong-result | Only the first reaction is plotted for the documented n x 1 rxns | `test/verifiedTests/analysis/testThermo/testPlotFeasibleReactionEnergyRanges.m` |
| `src/analysis/thermo/directionalityReport/singleMetaboliteThermoFigure.m` | error | Every call fails on the undefined variable directions | `test/verifiedTests/analysis/testThermo/testSingleMetaboliteThermoFigure.m` |
| `src/analysis/thermo/directionalityReport/singleMetaboliteThermoFigure.m` | unusable-option | The metabolite argument metAbbr is never read | `test/verifiedTests/analysis/testThermo/testSingleMetaboliteThermoFigure.m` |
| `src/analysis/thermo/directionalityReport/standardGibbsFormationEnergyStats.m` | unusable-option | The documented figures option always fails in pie | `test/verifiedTests/analysis/testThermo/testStandardGibbsFormationEnergyStats.m` |
| `src/analysis/thermo/directionalityReport/standardGibbsFormationEnergyStats.m` | wrong-result | The returned counts are offset by eps | `test/verifiedTests/analysis/testThermo/testStandardGibbsFormationEnergyStats.m` |
| `src/analysis/thermo/directionalityReport/writeReactionListThermo.m` | wrong-result | No arrow for an irreversible exchange reaction that has a product | `test/verifiedTests/analysis/testThermo/testWriteReactionListThermo.m` |
| `src/analysis/thermo/directionalityReport/writeReactionListThermo.m` | cosmetic | Non-integer stoichiometric coefficients are printed in exponent form | `test/verifiedTests/analysis/testThermo/testWriteReactionListThermo.m` |
| `src/analysis/thermo/experimentalData/alberty2006/adjustBaselinesInAlberty2006.m` | wrong-result | The reduced glutathione energies are halved together with the baseline | `test/verifiedTests/analysis/testThermo/testAdjustBaselinesInAlberty2006.m` |
| `src/analysis/thermo/experimentalData/readMetRxnBoundsFiles.m` | error | Omitting the optional printLevel fails when a metabolite file is read | `test/verifiedTests/analysis/testThermo/testReadMetRxnBoundsFiles.m` |
| `src/analysis/thermo/experimentalData/readMetRxnBoundsFiles.m` | cosmetic | The concMax error message says Minimum | `test/verifiedTests/analysis/testThermo/testReadMetRxnBoundsFiles.m` |
| `src/analysis/thermo/experimentalDesign/priorityKeqMeasurement.m` | error | A model whose metabolites all have Keq data fails | `test/verifiedTests/analysis/testThermo/testPriorityKeqMeasurement.m` |
| `src/analysis/thermo/experimentalDesign/priorityKeqMeasurement.m` | error | The plot fails on an invalid line style, so no call returns | `test/verifiedTests/analysis/testThermo/testPriorityKeqMeasurement.m` |
| `src/analysis/thermo/formulae/checkFormulae.m` | limitation | Elements other than C, H, O, P, S, K, Na and N are ignored | `test/verifiedTests/analysis/testThermo/testCheckFormulae.m` |
| `src/analysis/thermo/formulae/compareMetaboliteFormulae.m` | wrong-result | The identifier and the reconstruction formula are not tab separated | `test/verifiedTests/analysis/testThermo/testCompareMetaboliteFormulae.m` |
| `src/analysis/thermo/groupContribution/createComputedSpeciesData.m` | error | A row structure array of species fails when two metabolites are included | `test/verifiedTests/analysis/testThermo/testCreateComputedSpeciesData.m` |
| `src/analysis/thermo/groupContribution/createComputedSpeciesData.m` | wrong-result | The first group-contribution entry is used for every metabolite | `test/verifiedTests/analysis/testThermo/testCreateComputedSpeciesData.m` |
| `src/analysis/thermo/groupContribution/jankowski/createGroupContributionStruct.m` | limitation | The input files are left open | `test/verifiedTests/analysis/testThermo/testCreateGroupContributionStruct.m` |
| `src/analysis/thermo/groupContribution/jankowski/createGroupIncidenceMatrix_jankowski.m` | unusable-option | The documented arguments gcmOutputFile, gcmMetList and jankowskiGroupData are ignored | `test/verifiedTests/analysis/testThermo/testCreateGroupIncidenceMatrix_jankowski.m` |
| `src/analysis/thermo/groupContribution/jankowski/createGroupIncidenceMatrix_jankowski.m` | cosmetic | The function line names createGroupIncidenceMatrix_old, not the file name | `test/verifiedTests/analysis/testThermo/testCreateGroupIncidenceMatrix_jankowski.m` |
| `src/analysis/thermo/groupContribution/jankowski/plotConcVSdGft0GroupContUncertainty.m` | cosmetic | An intermediate fraction is echoed to the command window | `test/verifiedTests/analysis/testThermo/testPlotConcVSdGft0GroupContUncertainty.m` |
| `src/analysis/thermo/groupContribution/jankowski/webCGMtoTabDelimitedFile.m` | error | A metabolite without group contribution data stops the call or is reported under another name | `test/verifiedTests/analysis/testThermo/testWebCGMtoTabDelimitedFile.m` |
| `src/analysis/thermo/inchi/addInchiToModel.m` | unusable-option | The method 'mol' stops with Too many input arguments | `test/verifiedTests/analysis/testThermo/testAddInchiToModel.m` |
| `src/analysis/thermo/inchi/getMolecularWeight.m` | wrong-result | Hydrogens are lost for an InChI whose formula starts with H | `test/verifiedTests/analysis/testThermo/testGetMolecularWeight.m` |
| `src/analysis/thermo/molFiles/molFilesToCDFfile.m` | cosmetic | The share of metabolites without mol files is printed as a fraction labelled percentage | `test/verifiedTests/analysis/testThermo/testMolFilesToCDFfile.m` |
| `src/analysis/thermo/protons/getMetaboliteMsDistr.m` | wrong-result | Mol files are missed when another file precedes them or their name holds a dot or 'mol' | `test/verifiedTests/analysis/testThermo/testGetMetaboliteMsDistr.m` |
| `src/analysis/thermo/protons/getMetabolitepKa.m` | wrong-result | Mol files are missed when another file precedes them or their name holds a dot or 'mol' | `test/verifiedTests/analysis/testThermo/testGetMetabolitepKa.m` |
| `src/analysis/thermo/protons/moleFractionStats.m` | error | Fewer than two cytoplasmic reactants with a spread distribution stop the call | `test/verifiedTests/analysis/testThermo/testMoleFractionStats.m` |
| `src/analysis/thermo/protons/plotActivityCoefficients.m` | wrong-result | The output lambda holds the ionic-strength curves, not the activity coefficients of the species | `test/verifiedTests/analysis/testThermo/testPlotActivityCoefficients.m` |
| `src/analysis/thermo/reactantContribution/calcdGHT.m` | wrong-result | The standard transformed enthalpy dHf0 is always NaN | `test/verifiedTests/analysis/testThermo/testCalcdGHT.m` |
| `src/analysis/thermo/reactantContribution/setCommonZeroStandardGibbsEnergyOfFormation.m` | error | Every call stops at getCompartment with Too many input arguments | `test/verifiedTests/analysis/testThermo/testSetCommonZeroStandardGibbsEnergyOfFormation.m` |
| `src/analysis/thermo/reactantContribution/thermodynamicAdjustmentToStoichiometry.m` | error | An internal reaction with carbon dioxide stops with an index error | `test/verifiedTests/analysis/testThermo/testThermodynamicAdjustmentToStoichiometry.m` |
| `src/analysis/thermo/reactantContribution/thermodynamicAdjustmentToStoichiometry.m` | error | Every call stops at getCompartment with Too many input arguments | `test/verifiedTests/analysis/testThermo/testThermodynamicAdjustmentToStoichiometry.m` |
| `src/analysis/thermo/thermoDirectionality/deltaG0concFluxConstraintBounds.m` | error | every call stops with an undefined function createGroupIncidenceMatrix_old | `test/verifiedTests/analysis/testThermo/testDeltaG0concFluxConstraintBounds.m` |
| `src/analysis/thermo/thermoDirectionality/thermoConstrainFluxBounds.m` | error | A Gibbs energy range with one bound at zero stops the call | `test/verifiedTests/analysis/testThermo/testThermoConstrainFluxBounds.m` |
| `src/analysis/thermo/thermoDirectionality/thermoConstrainFluxBounds.m` | limitation | A confidence level outside the built-in table stops the call | `test/verifiedTests/analysis/testThermo/testThermoConstrainFluxBounds.m` |
| `src/analysis/thermo/thermoFBA/addLoopLawConstraints.m` | error | A wrong input ends with an unassigned output | `test/verifiedTests/analysis/testThermo/testAddLoopLawConstraints.m` |
| `src/analysis/thermo/thermoFBA/addLoopLawConstraints.m` | wrong-result | Method 3 without a vartype returns numbers instead of characters | `test/verifiedTests/analysis/testThermo/testAddLoopLawConstraints.m` |
| `src/analysis/thermo/thermoFBA/connectedRxnsByEFM.m` | cosmetic | The working directory is not restored when EFMtool fails | `test/verifiedTests/analysis/testThermo/testConnectedRxnsByEFM.m` |
| `src/analysis/thermo/thermoFBA/cycleFreeFlux.m` | wrong-result | A solution of the relaxed problem under param.debug is dropped | `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m` |
| `src/analysis/thermo/thermoFBA/cycleFreeFlux.m` | wrong-result | Lower bounds are checked only when an upper bound is violated | `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m` |
| `src/analysis/thermo/thermoFBA/cycleFreeFlux.m` | unusable-option | The analysis of an infeasible problem under param.debug stops at its first step | `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m` |
| `src/analysis/thermo/thermoFBA/cycleFreeFlux.m` | wrong-result | The objective bound of the lp approach is tightened when it should be relaxed | `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m` |
| `src/analysis/thermo/thermoFBA/cycleFreeFlux.m` | unusable-option | The relaxedFBA fallback of the regularised approach can never succeed | `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m` |
| `src/analysis/thermo/thermoFBA/cycleFreeFlux.m` | error | param.removeFixedBool = 1 stops the regularised approach | `test/verifiedTests/analysis/testThermo/testCycleFreeFlux.m` |
| `src/analysis/thermo/thermoFBA/metaboliteMassBalancePlot.m` | cosmetic | The empty-producer branch labels the consumer axes | `test/verifiedTests/analysis/testThermo/testMetaboliteMassBalancePlot.m` |
| `src/analysis/thermo/thermoFBA/metaboliteMassBalancePlot.m` | error | The reaction labels read an undocumented legacy field model.rxn(k).directionality | `test/verifiedTests/analysis/testThermo/testMetaboliteMassBalancePlot.m` |
| `src/analysis/thermo/vonBertalanffy/configureSetupThermoModelInputs.m` | error | A model with concMin or concMax fails unless concMinDefault and concMaxDefault are passed | `test/verifiedTests/analysis/testVonBertalanffy/testConfigureSetupThermoModelInputs.m` |
| `src/analysis/thermo/vonBertalanffy/configureSetupThermoModelInputs.m` | unusable-option | concMinDefault and concMaxDefault are ignored | `test/verifiedTests/analysis/testVonBertalanffy/testConfigureSetupThermoModelInputs.m` |
| `src/analysis/thermo/vonBertalanffy/estimateDrGt0.m` | error | a model with the field R (gas constant) stops with an undefined variable | `test/verifiedTests/analysis/testVonBertalanffy/testEstimateDrGt0.m` |
| `src/analysis/topology/FR/bilinearDecomposition.m` | error | A lone reaction with one substrate and three products gives inconsistent sizes | `test/verifiedTests/analysis/testTopology/testBilinearDecomposition.m` |
| `src/analysis/topology/FR/connectedFR.m` | wrong-result | The column sets are computed over the rows of [F; R] | `test/verifiedTests/analysis/testTopology/testConnectedFR.m` |
| `src/analysis/topology/FR/largestConnectedFR.m` | wrong-result | The column output is read from the row nodes and has m entries | `test/verifiedTests/analysis/testTopology/testLargestConnectedFR.m` |
| `src/analysis/topology/FR/makeFRresultsTable.m` | error | A model missing from modelMetaData stops the function with an error | `test/verifiedTests/analysis/testTopology/testMakeFRresultsTable.m` |
| `src/analysis/topology/FR/makeFRresultsTable.m` | error | A resultsDirectory without a trailing file separator cannot be loaded | `test/verifiedTests/analysis/testTopology/testMakeFRresultsTable.m` |
| `src/analysis/topology/FR/makeFRresultsTable.m` | error | The optional resultsDirectory cannot be omitted: its default is one developer's personal folder | `test/verifiedTests/analysis/testTopology/testMakeFRresultsTable.m` |
| `src/analysis/topology/FR/plotFRresults.m` | wrong-result | Reconstructions with few stoichiometrically consistent rows are never reported | `test/verifiedTests/analysis/testTopology/testPlotFRresults.m` |
| `src/analysis/topology/FR/plotFRresults.m` | wrong-result | Row rank deficiency of [F,R] and [Fb,Rb] is misreported | `test/verifiedTests/analysis/testTopology/testPlotFRresults.m` |
| `src/analysis/topology/FR/plotFRresults.m` | error | The optional input modelMetaData cannot be omitted | `test/verifiedTests/analysis/testTopology/testPlotFRresults.m` |
| `src/analysis/topology/FR/printFRdependencies.m` | wrong-result | Dependent rows are counted and displayed among the independent rows | `test/verifiedTests/analysis/testTopology/testPrintFRdependencies.m` |
| `src/analysis/topology/FR/printFRdependencies.m` | wrong-result | Each dependent metabolite is reported as dependent on itself | `test/verifiedTests/analysis/testTopology/testPrintFRdependencies.m` |
| `src/analysis/topology/conservedMoieties/classifyMoieties.m` | wrong-result | isSecondary is returned as a row vector, not m x 1 | `test/verifiedTests/analysis/testConservedMoieties/testClassifyMoieties.m` |
| `src/analysis/topology/conservedMoieties/constructElementalMatrix.m` | error | Every call stops because atomicNumbers.mat is missing | `test/verifiedTests/analysis/testConservedMoieties/testConstructElementalMatrix.m` |
| `src/analysis/topology/conservedMoieties/estimateMoietyFormulas.m` | wrong-result | M is not the r x p matrix the documentation describes | `test/verifiedTests/analysis/testConservedMoieties/testEstimateMoietyFormulas.m` |
| `src/analysis/topology/conservedMoieties/identifyConservedMoieties.m` | error | the default sanity checks stop when an atom transition has two instances | `test/verifiedTests/analysis/testConservedMoieties/testIdentifyConservedMoieties.m` |
| `src/analysis/topology/conservedMoieties/identifyConservedMoieties.m` | wrong-result | the moiety index of a non-canonical component follows its atom order | `test/verifiedTests/analysis/testConservedMoieties/testIdentifyConservedMoieties.m` |
| `src/analysis/topology/conservedMoieties/representativeMoiety.m` | error | MMN.moi is required but not documented | `test/verifiedTests/analysis/testConservedMoieties/testRepresentativeMoiety.m` |
| `src/analysis/topology/conservedMoieties/representativeMoiety.m` | wrong-result | minimalMassFraction is always 1 | `test/verifiedTests/analysis/testConservedMoieties/testRepresentativeMoiety.m` |
| `src/analysis/topology/extremeRays/lrs/extremePools.m` | error | A model with mets but no usable SIntRxnBool stops on an undefined variable | `test/verifiedTests/analysis/testTopology/testExtremePools.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsInputHalfspace.m` | unusable-option | the linear objective f is malformed and placed where lrs ignores it | `test/verifiedTests/analysis/testLrsInterface/testLrsInputHalfspace.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsInputHalfspace.m` | unusable-option | the shell script writes to a fixed personal folder | `test/verifiedTests/analysis/testLrsInterface/testLrsInputHalfspace.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsInputHalfspace.m` | wrong-result | with A empty and inequality = 1 the column count is 1 | `test/verifiedTests/analysis/testLrsInterface/testLrsInputHalfspace.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsInputHalfspace.m` | wrong-result | with A empty and positivity = 1 the row count omits the x >= 0 rows | `test/verifiedTests/analysis/testLrsInterface/testLrsInputHalfspace.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsOutputReadRay.m` | wrong-result | rows with rational entries are dropped and become zero rays | `test/verifiedTests/analysis/testLrsInterface/testLrsOutputReadRay.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsOutputReadRay.m` | cosmetic | the empty matrix P is printed to the command window | `test/verifiedTests/analysis/testLrsInterface/testLrsOutputReadRay.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsReadHalfspace.m` | wrong-result | a row with rational coefficients is read as a row of zeros | `test/verifiedTests/analysis/testLrsInterface/testLrsReadHalfspace.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsReadRay.m` | error | a row with rational coefficients is lost | `test/verifiedTests/analysis/testLrsInterface/testLrsReadRay.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsReadRay.m` | wrong-result | a vertex whose coordinates sum to zero is removed | `test/verifiedTests/analysis/testLrsInterface/testLrsReadRay.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsReadRay.m` | error | the optional param cannot be omitted | `test/verifiedTests/analysis/testLrsInterface/testLrsReadRay.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsWriteHalfspace.m` | wrong-result | the documented default positivity = 1 is implemented as 0 | `test/verifiedTests/analysis/testLrsInterface/testLrsWriteHalfspace.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsWriteHalfspace.m` | error | the optional param cannot be omitted | `test/verifiedTests/analysis/testLrsInterface/testLrsWriteHalfspace.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsWriteHalfspace.m` | unusable-option | the shell-script option fails | `test/verifiedTests/analysis/testLrsInterface/testLrsWriteHalfspace.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsWriteHalfspace.m` | wrong-result | with no equality and inequality = 1 the column count is 1 | `test/verifiedTests/analysis/testLrsInterface/testLrsWriteHalfspace.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsWriteHalfspace.m` | wrong-result | with no equality and positivity = 1 the row count omits the x >= 0 rows | `test/verifiedTests/analysis/testLrsInterface/testLrsWriteHalfspace.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsWriteRay.m` | wrong-result | the positivity rows are not counted | `test/verifiedTests/analysis/testLrsInterface/testLrsWriteRay.m` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsWriteRay.m` | wrong-result | vertices are written as lrs linearities | `test/verifiedTests/analysis/testLrsInterface/testLrsWriteRay.m` |
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
| `src/analysis/topology/reactingMoieties/createMoietyGraph.m` | wrong-result | Edge weights are shifted when a metabolite lies off the cycle | `test/verifiedTests/analysis/testReactingMoieties/testCreateMoietyGraph.m` |
| `src/analysis/topology/reactingMoieties/identifyAtomEquivalenceClasses.m` | limitation | The check for a duplicate bond never fires | `test/verifiedTests/analysis/testReactingMoieties/testIdentifyAtomEquivalenceClasses.m` |
| `src/analysis/topology/reactingMoieties/identifyConservedReactingSubgraphs.m` | wrong-result | reaction nodes are removed from RBG with their node indices in dBTM | `test/verifiedTests/analysis/testReactingMoieties/testIdentifyConservedReactingSubgraphs.m` |
| `src/analysis/topology/reactingMoieties/identifyIsomorphicClasses.m` | unusable-option | sanityChecks = true raises an error for any class with two or more members | `test/verifiedTests/analysis/testReactingMoieties/testIdentifyIsomorphicClasses.m` |
| `src/analysis/topology/reactingMoieties/readABRXNFile.m` | cosmetic | The two warnings about transition numbers print a literal backslash n | `test/verifiedTests/analysis/testReactingMoieties/testReadABRXNFile.m` |
| `src/analysis/topology/reactingMoieties/readABRXNFile.m` | unusable-option | options.readBonds = 0 cannot be used | `test/verifiedTests/analysis/testReactingMoieties/testReadABRXNFile.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/createUSDAdatabase.m` | cosmetic | The progress message has no space before the food source name | `test/verifiedTests/analysis/testWholeBody/testCreateUSDAdatabase.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/createUSDAdatabase.m` | unusable-option | brandedFoods = true always raises an error | `test/verifiedTests/analysis/testWholeBody/testCreateUSDAdatabase.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/getDietComposition.m` | error | A whole-body model (struct) input is rejected | `test/verifiedTests/analysis/testWholeBody/testGetDietComposition.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/getMetaboliteFlux.m` | unusable-option | addStarch fails for every food of the shipped USDA database | `test/verifiedTests/analysis/testWholeBody/testGetMetaboliteFlux.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/getMetaboliteFlux.m` | error | addStarch fails when a macro value of the food equals a looked-up nutrient id | `test/verifiedTests/analysis/testWholeBody/testGetMetaboliteFlux.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/getNutritionDatabaseFile.m` | error | The documented file type 'foodItems' of the USDA database is not found | `test/verifiedTests/analysis/testWholeBody/testGetNutritionDatabaseFile.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/isValidVmhID.m` | limitation | Identifiers with surrounding blanks are rejected although they are trimmed for the other checks | `test/verifiedTests/analysis/testWholeBody/testIsValidVmhID.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/makeDietFormatConsistant.m` | error | the food tables fdTable.mat and fdCategoriesTable.mat are not in the repository | `test/verifiedTests/analysis/testWholeBody/testMakeDietFormatConsistant.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/normalizeDiet.m` | error | Every call fails because fdTable.mat is not shipped | `test/verifiedTests/analysis/testWholeBody/testNormalizeDiet.m` |
| `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/searcher.m` | unusable-option | Non-iterative search type cannot run | `test/verifiedTests/analysis/testWholeBody/testSearcher.m` |
| `src/analysis/wholeBody/PSCMToolbox/annotateModel.m` | wrong-result | every non-transport reaction gets the exchange SBO term when any reaction is an exchange | `test/verifiedTests/analysis/testWholeBody/testAnnotateModel.m` |
| `src/analysis/wholeBody/PSCMToolbox/annotateModel.m` | error | modelID without modelName stops the call | `test/verifiedTests/analysis/testWholeBody/testAnnotateModel.m` |
| `src/analysis/wholeBody/PSCMToolbox/calcOrganFract.m` | wrong-result | The lung of a whole-body model keeps the reference weight instead of the lung polynomial | `test/verifiedTests/analysis/testWholeBody/testCalcOrganFract.m` |
| `src/analysis/wholeBody/PSCMToolbox/compareBounds2Models.m` | error | Reactions missing from a model are collected in a character matrix, which fails for names of different lengths | `test/verifiedTests/analysis/testWholeBody/testCompareBounds2Models.m` |
| `src/analysis/wholeBody/PSCMToolbox/createModelNewCompartment.m` | limitation | All MATLAB warnings are switched off and never switched back on | `test/verifiedTests/analysis/testWholeBody/testCreateModelNewCompartment.m` |
| `src/analysis/wholeBody/PSCMToolbox/createModelNewCompartment.m` | cosmetic | The names of the new transport reactions lose their blanks | `test/verifiedTests/analysis/testWholeBody/testCreateModelNewCompartment.m` |
| `src/analysis/wholeBody/PSCMToolbox/createModelNewCompartment.m` | limitation | rxnGeneMat is dropped when the original exchange reactions are removed | `test/verifiedTests/analysis/testWholeBody/testCreateModelNewCompartment.m` |
| `src/analysis/wholeBody/PSCMToolbox/getStatsOrganComp.m` | wrong-result | The metabolite presence matrices keep entries of the compartment-free metabolite list | `test/verifiedTests/analysis/testWholeBody/testGetStatsOrganComp.m` |
| `src/analysis/wholeBody/PSCMToolbox/getStatsOrganComp.m` | wrong-result | The results file named in the help text is never written | `test/verifiedTests/analysis/testWholeBody/testGetStatsOrganComp.m` |
| `src/analysis/wholeBody/PSCMToolbox/io/addReactionsHH.m` | unusable-option | The coupling factor given by the caller is ignored | `test/verifiedTests/analysis/testWholeBody/testAddReactionsHH.m` |
| `src/analysis/wholeBody/PSCMToolbox/io/addReactionsHH.m` | wrong-result | rxnGeneMat is not updated for the gene rules of the added reactions | `test/verifiedTests/analysis/testWholeBody/testAddReactionsHH.m` |
| `src/analysis/wholeBody/PSCMToolbox/setConstraints/physiologicalConstraintsHMDBbased.m` | wrong-result | ExclList is ignored for the blood exchanges of every organ but the kidney | `test/verifiedTests/analysis/testWholeBody/testPhysiologicalConstraintsHMDBbased.m` |
| `src/analysis/wholeBody/PSCMToolbox/setConstraints/physiologicalConstraintsHMDBbased_old.m` | wrong-result | ExclList is ignored for the blood exchanges of every organ but the kidney | `test/verifiedTests/analysis/testWholeBody/testPhysiologicalConstraintsHMDBbased_old.m` |
| `src/analysis/wholeBody/PSCMToolbox/setConstraints/readInDietFromVMH.m` | limitation | Flux values are rounded to the default precision of num2str | `test/verifiedTests/analysis/testWholeBody/testReadInDietFromVMH.m` |
| `src/analysis/wholeBody/PSCMToolbox/setConstraints/setDietConstraints.m` | error | A user diet with numeric flux values stops with an error | `test/verifiedTests/analysis/testWholeBody/testSetDietConstraints.m` |
| `src/analysis/wholeBody/PSCMToolbox/setConstraints/setFeedingFastingConstraints.m` | cosmetic | The list of storable amino acids is printed on every call | `test/verifiedTests/analysis/testWholeBody/testSetFeedingFastingConstraints.m` |
| `src/base/ci/addKeyToKnownHostsCT.m` | error | The documented host name ' ' does not select github.com and the call fails | `test/verifiedTests/base/testCi/testAddKeyToKnownHostsCT.m` |
| `src/base/ci/addKeyToKnownHostsCT.m` | cosmetic | The error messages fail with a dot-indexing error when gitCmd is not set | `test/verifiedTests/base/testCi/testAddKeyToKnownHostsCT.m` |
| `src/base/cobrarrow/COBRArrowSolver.m` | wrong-result | Copies of a solver object share one parameter map | `test/verifiedTests/base/testCobrarrow/testCOBRArrowSolver.m` |
| `src/base/codeConsistency/printFunctionIO.m` | wrong-result | Fields of a variable whose name ends with an input name are listed as fields of the input | `test/verifiedTests/base/testCodeConsistency/testPrintFunctionIO.m` |
| `src/base/codeConsistency/printFunctionIO.m` | wrong-result | Fields of the second and later outputs are missed when the reference starts a line | `test/verifiedTests/base/testCodeConsistency/testPrintFunctionIO.m` |
| `src/base/generateSystemConfigReport.m` | error | A short answer from curl stops the report at the summary | `test/verifiedTests/base/testTools/testGenerateSystemConfigReport.m` |
| `src/base/getExchangedMetaboliteTable.m` | error | exRxnsOrdered = {} stops the call | `test/verifiedTests/base/testTools/testGetExchangedMetaboliteTable.m` |
| `src/base/install/adaptMacPath.m` | wrong-result | pre-Sierra macOS versions with a patch number or a one-digit minor select postSierra | `test/verifiedTests/base/testInstall/testAdaptMacPath.m` |
| `src/base/install/prepareTest.m` | unusable-option | needsLinux makes every test skip on Linux | `test/verifiedTests/base/testInstall/testPrepareTest.m` |
| `src/base/install/updateCobraToolbox.m` | error | A commit count that git cannot compute stops the function with an undefined variable instead of the intended warning | `test/verifiedTests/base/testInstall/testUpdateCobraToolbox.m` |
| `src/base/io/KEGG/mapKEGGID2Model.m` | error | A dictionary abbreviation with several entries stops with an error | `test/verifiedTests/base/testIO/testKEGG/testMapKEGGID2Model.m` |
| `src/base/io/KEGG/mapKEGGID2Model.m` | error | A metabolite without compartment that is in the dictionary stops with an error | `test/verifiedTests/base/testIO/testKEGG/testMapKEGGID2Model.m` |
| `src/base/io/KEGG/mapMetName2KEGGID.m` | error | A metabolite without compartment that is in the dictionary stops with an error | `test/verifiedTests/base/testIO/testKEGG/testMapMetName2KEGGID.m` |
| `src/base/io/KEGG/mapMetName2KEGGID.m` | cosmetic | The message for a metabolite with several matches is never printed | `test/verifiedTests/base/testIO/testKEGG/testMapMetName2KEGGID.m` |
| `src/base/io/convertCNAModelToCbModel.m` | error | Without CellNetAnalyzer an output is never assigned | `test/verifiedTests/base/testIO/testConvertCNAModelToCbModel.m` |
| `src/base/io/convertCbModelToCNAModel.m` | error | Ordinary metabolite names stop the conversion with an index error | `test/verifiedTests/base/testIO/testConvertCbModelToCNAModel.m` |
| `src/base/io/convertCbModelToCNAModel.m` | wrong-result | Whitespace in metabolite names is replaced only in the first rows | `test/verifiedTests/base/testIO/testConvertCbModelToCNAModel.m` |
| `src/base/io/convertCbModelToCNAModel.m` | cosmetic | without CellNetAnalyzer a call with an output stops with an unassigned-output error | `test/verifiedTests/base/testIO/testConvertCbModelToCNAModel.m` |
| `src/base/io/convertCobraLP2mps.m` | wrong-result | only the first column of a 'G' row is negated | `test/verifiedTests/base/testIO/testConvertCobraLP2mps.m` |
| `src/base/io/definitions/descFileRead.m` | wrong-result | An empty line ends the reading | `test/verifiedTests/base/testIO/testDescFileRead.m` |
| `src/base/io/definitions/descFileRead.m` | limitation | Short entries are padded with null characters, not blanks | `test/verifiedTests/base/testIO/testDescFileRead.m` |
| `src/base/io/python/initPythonEnvironment.m` | unusable-option | The default environment CPython3 rejects every Python newer than 3.8 | `test/verifiedTests/base/testPython/testInitPythonEnvironment.m` |
| `src/base/io/python/pyPath/py_addpath.m` | wrong-result | A relative folder is added as given, not converted to an absolute path | `test/verifiedTests/base/testPyPath/testPy_addpath.m` |
| `src/base/io/python/pyPath/py_addpath.m` | wrong-result | The empty input adds the current folder to the Python path | `test/verifiedTests/base/testPyPath/testPy_addpath.m` |
| `src/base/io/python/pyPath/py_rmpath.m` | error | MATLAB_too = true always raises an error | `test/verifiedTests/base/testPyPath/testPy_rmpath.m` |
| `src/base/io/utilities/SBML/getDataBases.m` | wrong-result | Mixed matching and non-matching resources return nothing | `test/verifiedTests/base/testIO/testUtilities/testGetDataBases.m` |
| `src/base/io/utilities/SBML/getDataBases.m` | error | Third output unassigned when nothing matches | `test/verifiedTests/base/testIO/testUtilities/testGetDataBases.m` |
| `src/base/io/utilities/SBML/makeSBMLAnnotationString.m` | wrong-result | A field of another is-qualifier is also annotated under the qualifier is | `test/verifiedTests/base/testIO/testUtilities/testMakeSBMLAnnotationString.m` |
| `src/base/io/utilities/createEmptyFields.m` | limitation | A cell field with a computed default fills only its first column | `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m` |
| `src/base/io/utilities/createEmptyFields.m` | error | A field whose default refers to another field the model lacks cannot be created | `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m` |
| `src/base/io/utilities/createEmptyFields.m` | error | The default of comps cannot be evaluated | `test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m` |
| `src/base/io/utilities/creategrRulesField.m` | cosmetic | unknown reaction names in positions are not reported as intended | `test/verifiedTests/base/testIO/testUtilities/testCreategrRulesField.m` |
| `src/base/io/utilities/getDefinedFieldProperties.m` | error | A requested field without definition raises an error instead of being left out | `test/verifiedTests/base/testIO/testUtilities/testGetDefinedFieldProperties.m` |
| `src/base/io/utilities/getDefinedFieldProperties.m` | unusable-option | SpecificFields is ignored together with Descriptions or DataBaseFields | `test/verifiedTests/base/testIO/testUtilities/testGetDefinedFieldProperties.m` |
| `src/base/io/utilities/getDistributedModelFolder.m` | cosmetic | the warning shows a literal \n | `test/verifiedTests/base/testIO/testUtilities/testGetDistributedModelFolder.m` |
| `src/base/io/utilities/initFBAFields.m` | limitation | The documented osense and csense fields are not created | `test/verifiedTests/base/testIO/testUtilities/testInitFBAFields.m` |
| `src/base/io/utilities/model2xls.m` | error | compSymbols without compNames stops the call | `test/verifiedTests/base/testIO/testUtilities/testModel2xls.m` |
| `src/base/io/utilities/readBooleanRegModel.m` | limitation | A file without a rule of every type stops with an error | `test/verifiedTests/base/testIO/testUtilities/testReadBooleanRegModel.m` |
| `src/base/io/utilities/readBooleanRegModel.m` | limitation | Pool members written with spaces around + are not found | `test/verifiedTests/base/testIO/testUtilities/testReadBooleanRegModel.m` |
| `src/base/io/utilities/readBooleanRegModel.m` | limitation | The default file iMHruletest.xls is not distributed | `test/verifiedTests/base/testIO/testUtilities/testReadBooleanRegModel.m` |
| `src/base/io/utilities/readBooleanRegModel.m` | cosmetic | The message for a missing exchange reaction names the wrong metabolite | `test/verifiedTests/base/testIO/testUtilities/testReadBooleanRegModel.m` |
| `src/base/io/utilities/readBooleanRegModel.m` | cosmetic | The message for a missing internal reaction has no line break | `test/verifiedTests/base/testIO/testUtilities/testReadBooleanRegModel.m` |
| `src/base/io/utilities/readSBML.m` | error | The documented default of defaultBound does not exist | `test/verifiedTests/base/testIO/testReadSBML.m` |
| `src/base/io/utilities/readSimPhenyCMPD.m` | limitation | A file without metabolite lines stops with an error | `test/verifiedTests/base/testIO/testUtilities/testReadSimPhenyCMPD.m` |
| `src/base/io/utilities/readSimPhenyCMPD.m` | wrong-result | Alternative names keep the blank that follows a '/' | `test/verifiedTests/base/testIO/testUtilities/testReadSimPhenyCMPD.m` |
| `src/base/io/utilities/readSimPhenyGPR.m` | limitation | A file without reaction lines stops with an error | `test/verifiedTests/base/testIO/testUtilities/testReadSimPhenyGPR.m` |
| `src/base/io/utilities/readSimPhenyGprText.m` | wrong-result | the rules of reactions with several genes refer to the wrong genes | `test/verifiedTests/base/testIO/testUtilities/testReadSimPhenyGprText.m` |
| `src/base/io/utilities/write4ti2.m` | error | The optional input uni has no default, so it cannot be omitted | `test/verifiedTests/base/testIO/testUtilities/testWrite4ti2.m` |
| `src/base/io/utilities/write4ti2.m` | error | With uni = 0 the file is closed twice and the call stops after writing it | `test/verifiedTests/base/testIO/testUtilities/testWrite4ti2.m` |
| `src/base/io/utilities/write4ti2.m` | error | integerizeS is called with a matrix but needs a model structure | `test/verifiedTests/base/testIO/testUtilities/testWrite4ti2.m` |
| `src/base/io/utilities/writeSBML.m` | error | A model without reactions cannot be written | `test/verifiedTests/base/testIO/testWriteSBML.m` |
| `src/base/io/utilities/writeSBML.m` | wrong-result | The compartments of the model and the given lists are replaced by the defaults | `test/verifiedTests/base/testIO/testWriteSBML.m` |
| `src/base/io/utilities/writeSBML.m` | error | The model annotation cannot be written | `test/verifiedTests/base/testIO/testWriteSBML.m` |
| `src/base/io/writeCbModel.m` | unusable-option | The JSON format is not detected from the file extension | `test/verifiedTests/base/testIO/testWriteCbModel.m` |
| `src/base/io/writeCbModel.m` | unusable-option | The file dialog offers an MPS export that does not exist | `test/verifiedTests/base/testIO/testWriteCbModel.m` |
| `src/base/io/writeLPProblem.m` | unusable-option | the outputFormat option always fails validation | `test/verifiedTests/base/testIO/testWriteLPProblem.m` |
| `src/base/io/writeLPProblem.m` | unusable-option | writeMatrix given as the first option is taken for a positional problem name | `test/verifiedTests/base/testIO/testWriteLPProblem.m` |
| `src/base/parseMetNames.m` | limitation | Mixed or longer compartment notations are not parsed | `test/verifiedTests/base/testTools/testParseMetNames.m` |
| `src/base/paths/comparePaths.m` | wrong-result | Python path entries with blanks, commas or quotes are reported as differences | `test/verifiedTests/base/testPaths/testComparePaths.m` |
| `src/base/paths/editCobraToolboxPath.m` | unusable-option | The default basePath does nothing on Windows | `test/verifiedTests/base/testPaths/testEditCobraToolboxPath.m` |
| `src/base/removeGeneVersions.m` | error | A model without grRules stops after the warning | `test/verifiedTests/base/testRemoveGeneVersions/testRemoveGeneVersions.m` |
| `src/base/solvers/buildOptProblemFromModel.m` | error | A model with extra columns and no coupling rows gets no csense in its problem | `test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m` |
| `src/base/solvers/buildOptProblemFromModel.m` | error | Missing coupling and extra-variable fields are never built | `test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m` |
| `src/base/solvers/buildOptProblemFromModel.m` | error | The form QRQP keeps the csense of the model only | `test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m` |
| `src/base/solvers/buildOptProblemFromModel.m` | wrong-result | The forms QRLP and QRQP lose the bounds of the extra variables | `test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m` |
| `src/base/solvers/cardOpt/smoothConcave/SparseLP_old.m` | cosmetic | Diagnostic output is printed unconditionally | `test/verifiedTests/base/testSmoothConcave/testSparseLP_old.m` |
| `src/base/solvers/cardOpt/smoothConcave/SparseLP_old.m` | error | Empty inequality (or equality) block errors when the LP optimum is zero | `test/verifiedTests/base/testSmoothConcave/testSparseLP_old.m` |
| `src/base/solvers/cardOpt/smoothConcave/SparseLP_old.m` | error | Output z is not assigned when every entry of the LP solution is below zeps | `test/verifiedTests/base/testSmoothConcave/testSparseLP_old.m` |
| `src/base/solvers/cardOpt/smoothConcave/SparseLP_old.m` | wrong-result | The zero vector is returned as the solution although it violates Aeq*x = beq | `test/verifiedTests/base/testSmoothConcave/testSparseLP_old.m` |
| `src/base/solvers/cardOpt/smoothConcave/SparseLP_old.m` | error | Theta L0 iteration errors when the l1 solution has no positive entry | `test/verifiedTests/base/testSmoothConcave/testSparseLP_old.m` |
| `src/base/solvers/cplex/solveCobraLPCPLEX_2018.m` | error | An LPProblem without csense stops with an error | `test/verifiedTests/base/testSolvers/testSolveCobraLPCPLEX_2018.m` |
| `src/base/solvers/cplex/solveCobraLPCPLEX_2018.m` | wrong-result | The documented solution fields solver (every interface) and stat (ILOGsimple) are missing | `test/verifiedTests/base/testSolvers/testSolveCobraLPCPLEX_2018.m` |
| `src/base/solvers/cplex/solveCobraLPCPLEXcard.m` | error | An LPProblem without csense stops with an error | `test/verifiedTests/base/testSolvers/testSolveCobraLPCPLEXcard.m` |
| `src/base/solvers/cplex/solveCobraLPCPLEXcard.m` | wrong-result | The IBM ILOG branch returns the objective of a maximisation with the wrong sign | `test/verifiedTests/base/testSolvers/testSolveCobraLPCPLEXcard.m` |
| `src/base/solvers/cplex/solveCobraLPCPLEXcard.m` | cosmetic | The cardinality solve prints the solution structure and a minimum-Euclidean-norm note | `test/verifiedTests/base/testSolvers/testSolveCobraLPCPLEXcard.m` |
| `src/base/solvers/cplex/solveCobraLPCPLEXcard.m` | wrong-result | With osense = 1 the IBM ILOG branch optimises in the wrong direction | `test/verifiedTests/base/testSolvers/testSolveCobraLPCPLEXcard.m` |
| `src/base/solvers/cplex/solveCobraLPCPLEXcard.m` | wrong-result | theNorm 'zero' optimises the original objective in the wrong direction or reports it with the wrong sign | `test/verifiedTests/base/testSolvers/testSolveCobraLPCPLEXcard.m` |
| `src/base/solvers/entropicFBA/addExoMetToEFBA.m` | error | Data for a reaction not in the model, or duplicate data, stop with an error | `test/verifiedTests/base/testEntropicFBA/testAddExoMetToEFBA.m` |
| `src/base/solvers/entropicFBA/addExoMetToEFBA.m` | error | The default relaxBounds reads model fields that are not documented as required | `test/verifiedTests/base/testEntropicFBA/testAddExoMetToEFBA.m` |
| `src/base/solvers/entropicFBA/processConcConstraints.m` | cosmetic | Documented defaults for the concentration unit and the maximum concentration differ from the code | `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m` |
| `src/base/solvers/entropicFBA/processConcConstraints.m` | unusable-option | The case dxReplacement always stops with an error | `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m` |
| `src/base/solvers/entropicFBA/processConcConstraints.m` | wrong-result | The default row selection indexes the first row repeatedly | `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m` |
| `src/base/solvers/entropicFBA/processConcConstraints.m` | error | The parameter printLevel is required although it is documented as optional | `test/verifiedTests/base/testEntropicFBA/testProcessConcConstraints.m` |
| `src/base/solvers/gams/checkGAMSSolvers.m` | error | A problem type that GAMS does not list stops with an index error | `test/verifiedTests/base/testSolvers/testCheckGAMSSolvers.m` |
| `src/base/solvers/gams/checkGAMSSolvers.m` | cosmetic | The existence of licememo.gms is never checked | `test/verifiedTests/base/testSolvers/testCheckGAMSSolvers.m` |
| `src/base/solvers/getSetSolver/changeCobraSolver.m` | error | A call without input stops instead of listing the defined solvers | `test/verifiedTests/base/testSolvers/testChangeCobraSolver.m` |
| `src/base/solvers/getSetSolver/changeCobraSolver.m` | wrong-result | A failed validation with printLevel above 0 keeps the failed solver selected | `test/verifiedTests/base/testSolvers/testChangeCobraSolver.m` |
| `src/base/solvers/getSetSolver/changeCobraSolver.m` | wrong-result | The problem type is matched as a substring | `test/verifiedTests/base/testSolvers/testChangeCobraSolver.m` |
| `src/base/solvers/getSetSolver/getAvailableSolversByType.m` | cosmetic | The output of initCobraToolbox is not silenced | `test/verifiedTests/base/testSolvers/testGetAvailableSolversByType.m` |
| `src/base/solvers/getSetSolver/getCobraSolverVersion.m` | unusable-option | The documented input rootPathSolver has no effect | `test/verifiedTests/base/testSolvers/testGetCobraSolverVersion.m` |
| `src/base/solvers/init/configEnvVars.m` | cosmetic | GUROBI_PATH from an environment variable ending in linux64 or mac64 gets a double separator | `test/verifiedTests/base/testSolvers/testConfigEnvVars.m` |
| `src/base/solvers/init/configEnvVars.m` | error | The call stops with an error when ENV_VARS.STATUS is not set | `test/verifiedTests/base/testSolvers/testConfigEnvVars.m` |
| `src/base/solvers/isCompatible.m` | wrong-result | The distributed compatibility matrix is not understood by the parser | `test/verifiedTests/base/testSolvers/testIsCompatible.m` |
| `src/base/solvers/minos/DQQCleanup.m` | limitation | fort.* and *.sol files are kept when the results folder is missing | `test/verifiedTests/base/testSolvers/testDQQCleanup.m` |
| `src/base/solvers/mosek/setMosekParam.m` | wrong-result | The strict option never switches MOSEK to a free solve form | `test/verifiedTests/base/testSolvers/testSetMosekParam.m` |
| `src/base/solvers/param/changeCobraSolverParams.m` | cosmetic | The error for a parameter that is not allowed always names LP solvers | `test/verifiedTests/base/testSolvers/testChangeCobraSolverParams.m` |
| `src/base/solvers/param/parseSolverParameters.m` | cosmetic | The invalid-parameters error message shows literal \n instead of line breaks | `test/verifiedTests/base/testSolvers/testParseSolverParameters.m` |
| `src/base/solvers/rescale/liftCouplingConstraints.m` | error | A row with more than two variables cannot be lifted with the default options | `test/verifiedTests/base/testLifting/testLiftCouplingConstraints.m` |
| `src/base/solvers/rescale/liftCouplingConstraints.m` | cosmetic | The model identifier gets two suffixes | `test/verifiedTests/base/testLifting/testLiftCouplingConstraints.m` |
| `src/base/solvers/rescale/liftRows.m` | error | A well-scaled matrix stops with an error instead of being returned | `test/verifiedTests/base/testLifting/testLiftRows.m` |
| `src/base/solvers/solveCobraLP.m` | unusable-option | The option lifting stops on an undefined variable | `test/verifiedTests/base/testSolvers/testSolveCobraLP.m` |
| `src/base/solvers/solveCobraMILP.m` | error | The legacy mps interface returns no output | `test/verifiedTests/base/testSolvers/testSolveCobraMILP.m` |
| `src/base/solvers/solveCobraMILP.m` | error | gurobi does not accept an empty csense | `test/verifiedTests/base/testSolvers/testSolveCobraMILP.m` |
| `src/base/solvers/solveCobraMIQP.m` | unusable-option | The option saveInput stops the call | `test/verifiedTests/base/testSolvers/testSolveCobraMIQP.m` |
| `src/base/solvers/solveCobraQP.m` | error | A nonconvex QP solved to optimality by gurobi stops the function | `test/verifiedTests/base/testSolvers/testSolveCobraQP.m` |
| `src/base/solvers/solveCobraQP.m` | error | The qpng interface reads the problem after it was cleared | `test/verifiedTests/base/testSolvers/testSolveCobraQP.m` |
| `src/base/solvers/varKin/BDCAmethods/BDCA.m` | cosmetic | The display format is switched to longG and the status is printed | `test/verifiedTests/base/testSolvers/testBDCA.m` |
| `src/base/solvers/varKin/BDCAmethods/BDCA.m` | unusable-option | The documented line search Quadratic_interpolation cannot be used | `test/verifiedTests/base/testSolvers/testBDCA.m` |
| `src/base/solvers/varKin/BDCAmethods/BDCA.m` | unusable-option | The option flag_psi_error cannot be used | `test/verifiedTests/base/testSolvers/testBDCA.m` |
| `src/base/solvers/varKin/BDCAmethods/BDCA.m` | wrong-result | x_error and Time have a spurious zero in position 2 | `test/verifiedTests/base/testSolvers/testBDCA.m` |
| `src/base/solvers/varKin/BDCAmethods/DCA.m` | cosmetic | The display format is switched to longG and Niter and the status are printed | `test/verifiedTests/base/testSolvers/testDCA.m` |
| `src/base/solvers/varKin/BDCAmethods/DCA.m` | unusable-option | The option flag_psi_error cannot be used | `test/verifiedTests/base/testSolvers/testDCA.m` |
| `src/base/solvers/varKin/BDCAmethods/DCA.m` | wrong-result | x_error and Time have a spurious zero in position 2 | `test/verifiedTests/base/testSolvers/testDCA.m` |
| `src/base/solvers/varKin/derFreeMethods/BDF.m` | cosmetic | The display format is switched to longG and the status is printed | `test/verifiedTests/base/testSolvers/testBDF.m` |
| `src/base/solvers/varKin/derFreeMethods/BDF.m` | unusable-option | The option flag_psi_error cannot be used | `test/verifiedTests/base/testSolvers/testBDF.m` |
| `src/base/solvers/varKin/derFreeMethods/BDF.m` | wrong-result | out.Xk holds only the starting point | `test/verifiedTests/base/testSolvers/testBDF.m` |
| `src/base/solvers/varKin/derFreeMethods/BDF.m` | wrong-result | x_error and Time have a spurious zero in position 2 | `test/verifiedTests/base/testSolvers/testBDF.m` |
| `src/base/solvers/varKin/derFreeMethods/CSDF.m` | cosmetic | The display format is switched to longG and Niter and the status are printed | `test/verifiedTests/base/testSolvers/testCSDF.m` |
| `src/base/solvers/varKin/derFreeMethods/CSDF.m` | unusable-option | The option flag_psi_error cannot be used | `test/verifiedTests/base/testSolvers/testCSDF.m` |
| `src/base/solvers/varKin/derFreeMethods/CSDF.m` | wrong-result | x_error and Time have a spurious zero in position 2 | `test/verifiedTests/base/testSolvers/testCSDF.m` |
| `src/base/solvers/varKin/derFreeMethods/DBDF.m` | cosmetic | The display format is switched to longG and the status is printed | `test/verifiedTests/base/testSolvers/testDBDF.m` |
| `src/base/solvers/varKin/derFreeMethods/DBDF.m` | unusable-option | The option flag_psi_error cannot be used | `test/verifiedTests/base/testSolvers/testDBDF.m` |
| `src/base/solvers/varKin/derFreeMethods/DBDF.m` | wrong-result | x_error and Time have a spurious zero in position 2 | `test/verifiedTests/base/testSolvers/testDBDF.m` |
| `src/base/solvers/varKin/levMarMethods/GLM_FY.m` | cosmetic | The display format is switched to longG and the status is printed | `test/verifiedTests/base/testSolvers/testGLM_FY.m` |
| `src/base/solvers/varKin/levMarMethods/GLM_FY.m` | unusable-option | The option flag_psi_error cannot be used | `test/verifiedTests/base/testSolvers/testGLM_FY.m` |
| `src/base/solvers/varKin/levMarMethods/GLM_FY.m` | wrong-result | x_error and Time have a spurious zero in position 2 | `test/verifiedTests/base/testSolvers/testGLM_FY.m` |
| `src/base/solvers/varKin/levMarMethods/GLM_YF.m` | cosmetic | The display format is switched to longG and the status is printed | `test/verifiedTests/base/testSolvers/testGLM_YF.m` |
| `src/base/solvers/varKin/levMarMethods/GLM_YF.m` | unusable-option | The option flag_psi_error cannot be used | `test/verifiedTests/base/testSolvers/testGLM_YF.m` |
| `src/base/solvers/varKin/levMarMethods/GLM_YF.m` | wrong-result | x_error and Time have a spurious zero in position 2 | `test/verifiedTests/base/testSolvers/testGLM_YF.m` |
| `src/base/solvers/varKin/levMarMethods/LLM.m` | cosmetic | The display format is switched to longG and the status is printed | `test/verifiedTests/base/testSolvers/testLLM.m` |
| `src/base/solvers/varKin/levMarMethods/LLM.m` | unusable-option | The option flag_psi_error cannot be used | `test/verifiedTests/base/testSolvers/testLLM.m` |
| `src/base/solvers/varKin/levMarMethods/LLM.m` | wrong-result | x_error and Time have a spurious zero in position 2 | `test/verifiedTests/base/testSolvers/testLLM.m` |
| `src/base/solvers/varKin/levMarMethods/LMLS.m` | cosmetic | The display format is switched to longG and the status is printed | `test/verifiedTests/base/testSolvers/testLMLS.m` |
| `src/base/solvers/varKin/levMarMethods/LMLS.m` | unusable-option | The option flag_psi_error cannot be used | `test/verifiedTests/base/testSolvers/testLMLS.m` |
| `src/base/solvers/varKin/levMarMethods/LMLS.m` | wrong-result | x_error and Time have a spurious zero in position 2 | `test/verifiedTests/base/testSolvers/testLMLS.m` |
| `src/base/solvers/varKin/levMarMethods/LMTR.m` | cosmetic | The display format is switched to longG and the status is printed | `test/verifiedTests/base/testSolvers/testLMTR.m` |
| `src/base/solvers/varKin/levMarMethods/LMTR.m` | unusable-option | The option flag_psi_error cannot be used | `test/verifiedTests/base/testSolvers/testLMTR.m` |
| `src/base/solvers/varKin/levMarMethods/LMTR.m` | wrong-result | x_error and Time have a spurious zero in position 2 | `test/verifiedTests/base/testSolvers/testLMTR.m` |
| `src/base/solvers/varKin/levMarMethods/LevMar.m` | cosmetic | The display format is switched to longG and the status is printed | `test/verifiedTests/base/testSolvers/testLevMar.m` |
| `src/base/solvers/varKin/levMarMethods/LevMar.m` | wrong-result | The number of gradient evaluations is always reported as 1 | `test/verifiedTests/base/testSolvers/testLevMar.m` |
| `src/base/solvers/varKin/levMarMethods/LevMar.m` | unusable-option | The option flag_psi_error cannot be used | `test/verifiedTests/base/testSolvers/testLevMar.m` |
| `src/base/solvers/varKin/levMarMethods/LevMar.m` | wrong-result | x_error and Time have a spurious zero in position 2 | `test/verifiedTests/base/testSolvers/testLevMar.m` |
| `src/base/solvers/varKin/optimizeVKmodel0.m` | error | F equal to R with a moiety basis returns without the output | `test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m` |
| `src/base/solvers/varKin/optimizeVKmodel0.m` | cosmetic | The display format is switched to long E and never restored | `test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m` |
| `src/base/solvers/varKin/optimizeVKmodel0.m` | unusable-option | The option flag_psi_error cannot be used | `test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m` |
| `src/base/solvers/varKin/optimizeVKmodel0.m` | wrong-result | The steady state is dropped when the QR factor is a vector with a negative entry | `test/verifiedTests/base/testSolvers/testOptimizeVKmodel0.m` |
| `src/base/solvers/verifyCobraProblem.m` | error | A NaN in x stops a call with more than one output | `test/verifiedTests/base/testSolvers/testVerifyCobraProblem.m` |
| `src/base/solvers/verifyCobraProblem.m` | wrong-result | invalidConstraints names the wrong rows when senses are mixed | `test/verifiedTests/base/testSolvers/testVerifyCobraProblem.m` |
| `src/base/utilities/duplicates.m` | wrong-result | A cell array with more than one column is compared element by element, so M is not m x m | `test/verifiedTests/base/testTools/testDuplicates.m` |
| `src/base/utilities/generateStructFunction.m` | wrong-result | A char matrix with more than one row is written column by column | `test/verifiedTests/base/testUtilities/testGenerateStructFunction.m` |
| `src/base/utilities/generateStructFunction.m` | wrong-result | A char value with a quote gives a script that cannot run | `test/verifiedTests/base/testUtilities/testGenerateStructFunction.m` |
| `src/base/utilities/generateStructFunction.m` | error | A numeric array with more than two dimensions stops with an error and leaves the file open | `test/verifiedTests/base/testUtilities/testGenerateStructFunction.m` |
| `src/base/utilities/generateStructFunction.m` | wrong-result | Numeric values lose their class and digits beyond the 15th | `test/verifiedTests/base/testUtilities/testGenerateStructFunction.m` |
| `src/base/utilities/getGlobalValue.m` | limitation | The value of a global named globalName cannot be read | `test/verifiedTests/base/testUtilities/testGetGlobalValue.m` |
| `src/base/utilities/issueConfirmationWarning.m` | wrong-result | The confirmation is asked only on a jenkins home, the opposite of the documentation | `test/verifiedTests/base/testUtilities/testIssueConfirmationWarning.m` |
| `src/base/utilities/restoreEnvironment.m` | cosmetic | The printed path is cut at a folder name with a % sign | `test/verifiedTests/base/testUtilities/testRestoreEnvironment.m` |
| `src/base/utilities/setGlobal.m` | limitation | A global named globalName cannot be set | `test/verifiedTests/base/testUtilities/testSetGlobal.m` |
| `src/base/utilities/updateStructData.m` | limitation | A structure update is ignored when the original field is not a structure | `test/verifiedTests/base/testTools/testUpdateStructData.m` |
| `src/dataIntegration/XomicsToModel/analysis/coreMetRxnAnalysis.m` | wrong-result | A given list of deleted metabolites is discarded when the old model is empty and no deleted reactions are given | `test/verifiedTests/dataIntegration/testXomicsToModel/testCoreMetRxnAnalysis.m` |
| `src/dataIntegration/XomicsToModel/analysis/plotOverlapResults.m` | unusable-option | The optional input savepath cannot be used | `test/verifiedTests/dataIntegration/testXomicsToModel/testPlotOverlapResults.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m` | error | A reaction listed three times stops the constraint step | `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m` | wrong-result | A tiny bound of the unusual sign changes sign | `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m` | error | An unknown varID stops the mode allConstraints on a model without extra variables | `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m` | limitation | The default eta is below the noise of the fit | `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m` | wrong-result | The fitted exometabolomic relaxation is not applied to a feasible model | `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m` | cosmetic | The message about a feasible fit is never printed | `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m` | error | The mode allConstraints needs the extra variable fields it treats as optional | `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m` | cosmetic | The session display format is changed | `test/verifiedTests/dataIntegration/testConstrainRxns/testConstrainRxns.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/plotPredictedExchange.m` | unusable-option | The option saveFigures cannot be used | `test/verifiedTests/dataIntegration/testXomicsToModel/testPlotPredictedExchange.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/plotPredictedExchange.m` | error | extraFluxes without otherFluxes stops with an error | `test/verifiedTests/dataIntegration/testXomicsToModel/testPlotPredictedExchange.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/plotPredictedExchange.m` | limitation | predictedFluxes without lb and ub stops with an error | `test/verifiedTests/dataIntegration/testXomicsToModel/testPlotPredictedExchange.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/summaryConcentrations.m` | wrong-result | A compound whose name contains another compound's name receives that metabolite | `test/verifiedTests/dataIntegration/testXomicsToModel/testSummaryConcentrations.m` |
| `src/dataIntegration/XomicsToModel/metabolomics/summaryConcentrations.m` | error | param.metLookupTable without param.model stops with an undefined variable | `test/verifiedTests/dataIntegration/testXomicsToModel/testSummaryConcentrations.m` |
| `src/dataIntegration/XomicsToModel/proteomics/activeProteinList.m` | cosmetic | The histogram marks the threshold at 2 whatever threshold is given | `test/verifiedTests/dataIntegration/testXomicsToModel/testActiveProteinList.m` |
| `src/dataIntegration/XomicsToModel/proteomics/activeProteinList.m` | wrong-result | The inactive proteins are those above the threshold | `test/verifiedTests/dataIntegration/testXomicsToModel/testActiveProteinList.m` |
| `src/dataIntegration/chemoInformatics/RXN/writeRxnfile.m` | cosmetic | The reaction equation drops every "1 " it contains, not only unit coefficients | `test/verifiedTests/dataIntegration/testChemoInformatics/testWriteRxnfile.m` |
| `src/dataIntegration/chemoInformatics/checkChemoinformaticDependencies.m` | error | A system without java stops with an undefined variable options | `test/verifiedTests/dataIntegration/testChemoInformatics/testCheckChemoinformaticDependencies.m` |
| `src/dataIntegration/chemoInformatics/deleteProtons.m` | wrong-result | Reactions that carried only protons are removed from the reaction fields but not from S | `test/verifiedTests/dataIntegration/testChemoInformatics/testDeleteProtons.m` |
| `src/dataIntegration/chemoInformatics/editChemicalFormula.m` | cosmetic | Element with zero atoms stays in the formula | `test/verifiedTests/dataIntegration/testChemoInformatics/testEditChemicalFormula.m` |
| `src/dataIntegration/chemoInformatics/inchi/compareInchis.m` | wrong-result | A model formula made only of R groups is not treated as H | `test/verifiedTests/dataIntegration/testChemoInformatics/testCompareInchis.m` |
| `src/dataIntegration/chemoInformatics/inchi/compareInchis.m` | wrong-result | The R groups of the model formula are replaced by R instead of removed, so the formula never matches | `test/verifiedTests/dataIntegration/testChemoInformatics/testCompareInchis.m` |
| `src/dataIntegration/chemoInformatics/inchi/getChargeFromInChI.m` | error | An empty component of a multi-component charge layer stops with an error | `test/verifiedTests/dataIntegration/testChemoInformatics/testGetChargeFromInChI.m` |
| `src/dataIntegration/chemoInformatics/inchi/getFormulaFromInChI.m` | wrong-result | A formula that loses all its hydrogen atoms keeps one H | `test/verifiedTests/dataIntegration/testChemoInformatics/testGetFormulaFromInChI.m` |
| `src/dataIntegration/chemoInformatics/inchi/getFormulaFromInChI.m` | wrong-result | Element counts are assigned to the wrong elements on the combining path | `test/verifiedTests/dataIntegration/testChemoInformatics/testGetFormulaFromInChI.m` |
| `src/dataIntegration/chemoInformatics/inchi/getInchiData.m` | wrong-result | Negative charge layer gives NaN | `test/verifiedTests/dataIntegration/testChemoInformatics/testGetInchiData.m` |
| `src/dataIntegration/chemoInformatics/metabolites/addMetInfoInCBmodel.m` | unusable-option | A struct as inputData stops with an error | `test/verifiedTests/dataIntegration/testChemoInformatics/testAddMetInfoInCBmodel.m` |
| `src/dataIntegration/chemoInformatics/metabolites/addMetInfoInCBmodel.m` | unusable-option | replace = true stops with an error for every matched metabolite | `test/verifiedTests/dataIntegration/testChemoInformatics/testAddMetInfoInCBmodel.m` |
| `src/dataIntegration/chemoInformatics/metabolites/metDatabaseStatus.m` | wrong-result | A metabolite whose identifier contains mol after another character is reported missing | `test/verifiedTests/dataIntegration/testChemoInformatics/testMetDatabaseStatus.m` |
| `src/dataIntegration/chemoInformatics/metabolites/metDatabaseStatus.m` | wrong-result | The labels inconsistentCharge and inconsistentFormula are swapped | `test/verifiedTests/dataIntegration/testChemoInformatics/testMetDatabaseStatus.m` |
| `src/dataIntegration/chemoInformatics/metabolites/metaboliteStructuresTable.m` | wrong-result | A file name containing a character followed by mol loses that part of the metabolite name | `test/verifiedTests/dataIntegration/testChemoInformatics/testMetaboliteStructuresTable.m` |
| `src/dataIntegration/chemoInformatics/metabolites/obtainMetStructures.m` | error | A model without an HMDB field stops with an error | `test/verifiedTests/dataIntegration/testChemoInformatics/testObtainMetStructures.m` |
| `src/dataIntegration/chemoInformatics/metabolites/obtainMetStructures.m` | wrong-result | The SMILES source is used only for metabolites that have an InChI | `test/verifiedTests/dataIntegration/testChemoInformatics/testObtainMetStructures.m` |
| `src/dataIntegration/chemoInformatics/metabolites/obtainMetStructures.m` | unusable-option | The documented source name lipidmass stops with an error | `test/verifiedTests/dataIntegration/testChemoInformatics/testObtainMetStructures.m` |
| `src/dataIntegration/chemoInformatics/metabolites/standardiseMolDatabase.m` | error | No selected MOL file stops with an undefined variable standardised | `test/verifiedTests/dataIntegration/testChemoInformatics/testStandardiseMolDatabase.m` |
| `src/dataIntegration/chemoInformatics/openBabelConverter.m` | limitation | A scratch file named tmp is written into the current folder and left there | `test/verifiedTests/dataIntegration/testChemoInformatics/testOpenBabelConverter.m` |
| `src/dataIntegration/chemoInformatics/openBabelConverter.m` | error | Saving fails for every output format except mol | `test/verifiedTests/dataIntegration/testChemoInformatics/testOpenBabelConverter.m` |
| `src/dataIntegration/chemoInformatics/openBabelConverter.m` | unusable-option | The documented output format rxn returns nothing | `test/verifiedTests/dataIntegration/testChemoInformatics/testOpenBabelConverter.m` |
| `src/dataIntegration/chemoInformatics/openBabelConverter.m` | error | saveFileDir is documented as a directory but opened as a file | `test/verifiedTests/dataIntegration/testChemoInformatics/testOpenBabelConverter.m` |
| `src/dataIntegration/fluxomics/c13solver/scoreC13Fit.m` | unusable-option | The input method is ignored, method 1 (cumomer) cannot be selected | `test/verifiedTests/dataIntegration/testFitC13Data/testScoreC13Fit.m` |
| `src/dataIntegration/fluxomics/calcMDVfromSamp.m` | error | A non-empty substrate label distribution glc stops with an error | `test/verifiedTests/dataIntegration/testFluxomics/testCalcMDVfromSamp.m` |
| `src/dataIntegration/fluxomics/compareMultSamp.m` | error | calcMDVfromSamp is called with four arguments, every non-empty sample set stops with an error | `test/verifiedTests/dataIntegration/testFluxomics/testCompareMultSamp.m` |
| `src/dataIntegration/fluxomics/compareTwoSamp.m` | error | calcMDVfromSamp is called as calcMDVfromSamp(points, measuredMetabolites), every call stops with an error | `test/verifiedTests/dataIntegration/testFluxomics/testCompareTwoSamp.m` |
| `src/dataIntegration/fluxomics/getBinsOfFluxes.m` | error | Every call with at least 200 samples stops with an error instead of returning the bins | `test/verifiedTests/dataIntegration/testFluxomics/testGetBinsOfFluxes.m` |
| `src/dataIntegration/metaboAnnotator/analyseMetStruct/acceptIDsSuggested.m` | error | A suggestion list with fewer rows than columns stops with an index error | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testAcceptIDsSuggested.m` |
| `src/dataIntegration/metaboAnnotator/analyseMetStruct/acceptIDsSuggested.m` | wrong-result | IDsAdded keeps only the last accepted suggestion | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testAcceptIDsSuggested.m` |
| `src/dataIntegration/metaboAnnotator/analyseMetStruct/addAnnotations.m` | wrong-result | An empty field receives NaN with a source when the table cell is NaN | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testAddAnnotations.m` |
| `src/dataIntegration/metaboAnnotator/analyseMetStruct/addAnnotations.m` | unusable-option | The option annotationVerification has no effect | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testAddAnnotations.m` |
| `src/dataIntegration/metaboAnnotator/analyseMetStruct/addInfoFromMolFiles.m` | error | The documented output IDAdded is not assigned when nothing is added, so a call requesting it stops | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testAddInfoFromMolFiles.m` |
| `src/dataIntegration/metaboAnnotator/analyseMetStruct/check4DuplicatesInList.m` | cosmetic | A repeated entry is used as the format of its message | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testCheck4DuplicatesInList.m` |
| `src/dataIntegration/metaboAnnotator/buildMetStruct/convertModel2Metstructure.m` | wrong-result | A metabolite with a hyphen is overwritten by its next compartment | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testConvertModel2Metstructure.m` |
| `src/dataIntegration/metaboAnnotator/buildMetStruct/createNewMetaboliteStructure.m` | limitation | A table without a name column stops on an undefined variable | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testCreateNewMetaboliteStructure.m` |
| `src/dataIntegration/metaboAnnotator/buildMetStruct/createNewMetaboliteStructure.m` | wrong-result | The formula columns of the documented input format are dropped | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testCreateNewMetaboliteStructure.m` |
| `src/dataIntegration/metaboAnnotator/buildMetStruct/populateModelMetStr.m` | wrong-result | A field missing from the model is created with one entry per metabolite up to the last match only | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testPopulateModelMetStr.m` |
| `src/dataIntegration/metaboAnnotator/connect2resources/VMH2Metabolon.m` | error | A comma-separated VMH id that is not in the structure stops the function | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testVMH2Metabolon.m` |
| `src/dataIntegration/metaboAnnotator/connect2resources/VMH2Metabolon.m` | wrong-result | A row whose VMH id is not in the structure overwrites the metabolite of the previous matched row | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testVMH2Metabolon.m` |
| `src/dataIntegration/metaboAnnotator/connect2resources/VMH2Metabolon.m` | error | A table whose first row with a VMH id has no matching metabolite stops the function | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testVMH2Metabolon.m` |
| `src/dataIntegration/metaboAnnotator/connect2resources/VMH2Seed.m` | cosmetic | A blank SEED cell overwrites the SEED id with NaN and writes a source | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testVMH2Seed.m` |
| `src/dataIntegration/metaboAnnotator/connect2resources/convertOld2NewHMDB.m` | limitation | Identifiers of 12 or more characters give an empty result | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testConvertOld2NewHMDB.m` |
| `src/dataIntegration/metaboAnnotator/connect2resources/getIds2VMH.m` | wrong-result | A KEGG, BioCyc or BiGG id is never found when its column has a blank cell | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testGetIds2VMH.m` |
| `src/dataIntegration/metaboAnnotator/connect2resources/getIds2VMH.m` | cosmetic | The metabolite counter is printed for every identifier looked up | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testGetIds2VMH.m` |
| `src/dataIntegration/metaboAnnotator/connect2resources/getSeed2Kegg.m` | limitation | A blank KEGG cell read as NaN stops the mapping with an error | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testGetSeed2Kegg.m` |
| `src/dataIntegration/metaboAnnotator/connect2resources/parseBridgeDb.m` | wrong-result | A ChEBI cross-reference stops the processing of the answer | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testParseBridgeDb.m` |
| `src/dataIntegration/metaboAnnotator/connect2resources/parseBridgeDb.m` | wrong-result | A mismatch needs a field fullName and otherwise stops the processing of the answer | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testParseBridgeDb.m` |
| `src/dataIntegration/metaboAnnotator/connect2resources/parseBridgeDb.m` | wrong-result | Numeric identifiers are never queried | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testParseBridgeDb.m` |
| `src/dataIntegration/metaboAnnotator/connect2resources/parseBridgeDb.m` | cosmetic | The progress shown exceeds 100 percent when startSearch is above 1 | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testParseBridgeDb.m` |
| `src/dataIntegration/metaboAnnotator/generateMetInfo/generateInchiKeysSmilesFromInchiStrings.m` | cosmetic | The metabolite counter is printed for every metabolite | `test/verifiedTests/dataIntegration/testMetaboAnnotator/testGenerateInchiKeysSmilesFromInchiStrings.m` |
| `src/dataIntegration/metabotools/calculateQuantitativeDiffs.m` | error | An empty difference set is not assigned, so a call requesting it stops | `test/verifiedTests/dataIntegration/testMetaboTools/testCalculateQuantitativeDiffs.m` |
| `src/dataIntegration/metabotools/calculateQuantitativeDiffs.m` | wrong-result | Higher secretion is reported for the other condition, contrary to the code's own comments | `test/verifiedTests/dataIntegration/testMetaboTools/testCalculateQuantitativeDiffs.m` |
| `src/dataIntegration/metabotools/calculateQuantitativeDiffs.m` | wrong-result | Higher uptake is reported for the other condition for the slope ratio of defineUptakeSecretionProfiles | `test/verifiedTests/dataIntegration/testMetaboTools/testCalculateQuantitativeDiffs.m` |
| `src/dataIntegration/metabotools/calculateQuantitativeDiffs.m` | error | No uptake or no secretion exchange common to both conditions stops the call | `test/verifiedTests/dataIntegration/testMetaboTools/testCalculateQuantitativeDiffs.m` |
| `src/dataIntegration/metabotools/defineUptakeSecretionProfiles.m` | error | Fewer than four exchanges stop the call with an index error | `test/verifiedTests/dataIntegration/testMetaboTools/testDefineUptakeSecretionProfiles.m` |
| `src/dataIntegration/metabotools/defineUptakeSecretionProfiles.m` | error | The documented essAA_excl flag and its default stop the call | `test/verifiedTests/dataIntegration/testMetaboTools/testDefineUptakeSecretionProfiles.m` |
| `src/dataIntegration/metabotools/illustrate_ppp.m` | error | More than two metabolite pairs stop the call with an index error | `test/verifiedTests/dataIntegration/testMetaboTools/testIllustrate_ppp.m` |
| `src/dataIntegration/metabotools/illustrate_ppp.m` | error | The mets of performPPP (one pair per row) do not select its results | `test/verifiedTests/dataIntegration/testMetaboTools/testIllustrate_ppp.m` |
| `src/dataIntegration/metabotools/make3Dplot.m` | wrong-result | Only the first two phenotypes are plotted | `test/verifiedTests/dataIntegration/testMetaboTools/testMake3Dplot.m` |
| `src/dataIntegration/metabotools/make3Dplot.m` | cosmetic | The colour order is changed for every later figure of the session | `test/verifiedTests/dataIntegration/testMetaboTools/testMake3Dplot.m` |
| `src/dataIntegration/metabotools/make3Dplot.m` | cosmetic | The coordinates of every phenotype are printed to the console | `test/verifiedTests/dataIntegration/testMetaboTools/testMake3Dplot.m` |
| `src/dataIntegration/metabotools/mkTableOfAddedExchanges.m` | error | An exchange list with fewer rows than columns stops the function | `test/verifiedTests/dataIntegration/testMetaboTools/testMkTableOfAddedExchanges.m` |
| `src/dataIntegration/metabotools/setSemiQuantConstraints.m` | error | An empty cond1_upt_higher list stops with an error | `test/verifiedTests/dataIntegration/testMetaboTools/testSetSemiQuantConstraints.m` |
| `src/dataIntegration/metabotools/statisticsAddedExchanges.m` | cosmetic | The sample counter is printed for every sample | `test/verifiedTests/dataIntegration/testMetaboTools/testStatisticsAddedExchanges.m` |
| `src/dataIntegration/metabotools/statisticsAddedExchanges.m` | wrong-result | The table is not ordered by frequency as documented; the sorted copy goes to a differently spelled variable | `test/verifiedTests/dataIntegration/testMetaboTools/testStatisticsAddedExchanges.m` |
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
| `src/design/TrimGdel/readGeneRules.m` | error | A model without any gene rule stops with an error | `test/verifiedTests/design/testTrimGdel/testReadGeneRules.m` |
| `src/design/TrimGdel/readGeneRules.m` | error | A rule enclosed in parentheses stops with an error | `test/verifiedTests/design/testTrimGdel/testReadGeneRules.m` |
| `src/design/TrimGdel/readGeneRules.m` | wrong-result | reactionKO2term points into the term list before it is reordered | `test/verifiedTests/design/testTrimGdel/testReadGeneRules.m` |
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
| `src/design/optForce/saveInputsMustSetsSecondOrder.m` | cosmetic | the error messages for empty inputs name the first order function | `test/verifiedTests/design/testOptForce/testSaveInputsMustSetsSecondOrder.m` |
| `src/design/optForce/saveInputsOptForce.m` | wrong-result | k.mat and nSets.mat are not written | `test/verifiedTests/design/testOptForce/testSaveInputsOptForce.m` |
| `src/design/optForceGAMS/exportInputsMustOrder2ToGAMS.m` | error | Every call stops with the error that not all inputs are given | `test/verifiedTests/design/testOptForce/testExportInputsMustOrder2ToGAMS.m` |
| `src/design/optForceGAMS/exportInputsMustToGAMS.m` | error | Every call stops with the error that not all inputs are given | `test/verifiedTests/design/testOptForce/testExportInputsMustToGAMS.m` |
| `src/design/optForceGAMS/exportInputsOptForceToGAMS.m` | error | Every call stops on the undefined variable nSets and leaves the current folder changed | `test/verifiedTests/design/testOptForce/testExportInputsOptForceToGAMS.m` |
| `src/design/simpleOptKnock.m` | limitation | Single-deletion growth is stored in the first column in double-deletion mode | `test/verifiedTests/design/testSimpleOptKnock.m` |
| `src/design/simpleOptKnock.m` | wrong-result | The wild-type minimum production is the maximum | `test/verifiedTests/design/testSimpleOptKnock.m` |
| `src/reconstruction/comparison/modelBorgifier/TmodelStats.m` | wrong-result | The share of metabolites with a compartment ('Total' row) is inverted | `test/verifiedTests/reconstruction/testModelBorgifier/testTmodelStats.m` |
| `src/reconstruction/comparison/modelBorgifier/charpos.m` | wrong-result | The letters i and j count as digits | `test/verifiedTests/reconstruction/testModelBorgifier/testCharpos.m` |
| `src/reconstruction/comparison/modelBorgifier/cleanTmodel.m` | wrong-result | Lengthening a short lb, ub or c array overwrites its last value with 0 | `test/verifiedTests/reconstruction/testModelBorgifier/testCleanTmodel.m` |
| `src/reconstruction/comparison/modelBorgifier/compareAllMets.m` | error | Models with no positively scored metabolite pair stop with an undefined-function error | `test/verifiedTests/reconstruction/testModelBorgifier/testCompareAllMets.m` |
| `src/reconstruction/comparison/modelBorgifier/countC.m` | wrong-result | Elements whose symbol starts with C are counted as carbon | `test/verifiedTests/reconstruction/testModelBorgifier/testCountC.m` |
| `src/reconstruction/comparison/modelBorgifier/findMetMatch.m` | limitation | A SEED identifier given as a cell stops the function | `test/verifiedTests/reconstruction/testModelBorgifier/testFindMetMatch.m` |
| `src/reconstruction/comparison/modelBorgifier/findMetMatch.m` | wrong-result | Names and identifiers are used as regular expressions without escaping | `test/verifiedTests/reconstruction/testModelBorgifier/testFindMetMatch.m` |
| `src/reconstruction/comparison/modelBorgifier/makeNamesUnique.m` | error | An empty list stops with an error | `test/verifiedTests/reconstruction/testModelBorgifier/testMakeNamesUnique.m` |
| `src/reconstruction/comparison/modelBorgifier/makeNamesUnique.m` | wrong-result | Positions of duplicates are printed as character codes | `test/verifiedTests/reconstruction/testModelBorgifier/testMakeNamesUnique.m` |
| `src/reconstruction/comparison/modelBorgifier/mapMatch.m` | wrong-result | 'noSeed' score of a single-metabolite compared reaction uses the minimum over the template metabolites | `test/verifiedTests/reconstruction/testModelBorgifier/testMapMatch.m` |
| `src/reconstruction/comparison/modelBorgifier/optimalScores.m` | error | A training list with exactly one matched reaction stops with an index error | `test/verifiedTests/reconstruction/testModelBorgifier/testOptimalScores.m` |
| `src/reconstruction/comparison/modelBorgifier/readCbTmodel.m` | wrong-result | rules and rxnGeneMat are never built | `test/verifiedTests/reconstruction/testModelBorgifier/testReadCbTmodel.m` |
| `src/reconstruction/comparison/modelBorgifier/readCbTmodel.m` | wrong-result | rxnID and metID entries are shifted when an entry has no ID of the model | `test/verifiedTests/reconstruction/testModelBorgifier/testReadCbTmodel.m` |
| `src/reconstruction/demeter/src/debugging/conditionSpecificGapFilling.m` | wrong-result | A rule with a present- and an absent-condition applies when only the absent reaction is missing | `test/verifiedTests/reconstruction/testDemeter/testConditionSpecificGapFilling.m` |
| `src/reconstruction/demeter/src/debugging/conditionSpecificGapFilling.m` | wrong-result | The lower bound is not changed for a rule whose present-condition uses OR | `test/verifiedTests/reconstruction/testDemeter/testConditionSpecificGapFilling.m` |
| `src/reconstruction/demeter/src/integration/createRBioNetDBFromVMHDB.m` | limitation | A metabolite without time stamp stops the conversion with an error | `test/verifiedTests/reconstruction/testDemeter/testCreateRBioNetDBFromVMHDB.m` |
| `src/reconstruction/demeter/src/integration/createRBioNetDBFromVMHDB.m` | cosmetic | The call saves the whole MATLAB path to pathdef.m | `test/verifiedTests/reconstruction/testDemeter/testCreateRBioNetDBFromVMHDB.m` |
| `src/reconstruction/demeter/src/integration/gapfillRefinedGenomeReactions.m` | wrong-result | The first gap-filled row overwrites the last annotation row | `test/verifiedTests/reconstruction/testDemeter/testGapfillRefinedGenomeReactions.m` |
| `src/reconstruction/demeter/src/integration/getCurationStatus.m` | wrong-result | Data entries 1 and -1 cancel out and the organism is reported without experimental data | `test/verifiedTests/reconstruction/testDemeter/testGetCurationStatus.m` |
| `src/reconstruction/demeter/src/integration/getUnannotatedReactionsFromPubSeedSpreadsheets.m` | error | Spreadsheets with no unannotated reaction stop with an index error | `test/verifiedTests/reconstruction/testDemeter/testGetUnannotatedReactionsFromPubSeedSpreadsheets.m` |
| `src/reconstruction/demeter/src/integration/getUnannotatedReactionsFromPubSeedSpreadsheets.m` | unusable-option | The documented default of inputDataFolder is not implemented | `test/verifiedTests/reconstruction/testDemeter/testGetUnannotatedReactionsFromPubSeedSpreadsheets.m` |
| `src/reconstruction/demeter/src/integration/getUnannotatedReactionsFromPubSeedSpreadsheets.m` | cosmetic | The loop counter i is printed for every spreadsheet and every organism | `test/verifiedTests/reconstruction/testDemeter/testGetUnannotatedReactionsFromPubSeedSpreadsheets.m` |
| `src/reconstruction/demeter/src/integration/mapKBaseToVMHReactions.m` | wrong-result | A KBase reaction irreversible where the VMH reaction is reversible is not reported as similar | `test/verifiedTests/reconstruction/testDemeter/testMapKBaseToVMHReactions.m` |
| `src/reconstruction/demeter/src/integration/printRefinedModelIDs.m` | wrong-result | files that are not SBML or .mat files are returned as model identifiers | `test/verifiedTests/reconstruction/testDemeter/testPrintRefinedModelIDs.m` |
| `src/reconstruction/demeter/src/integration/writeReactionsFromPubSeedSpreadsheets.m` | unusable-option | The documented default of inputDataFolder is not implemented | `test/verifiedTests/reconstruction/testDemeter/testWriteReactionsFromPubSeedSpreadsheets.m` |
| `src/reconstruction/demeter/src/properties/computeMetabolicDistance.m` | error | the blocks of 100 rows run past the last strain | `test/verifiedTests/reconstruction/testDemeter/testComputeMetabolicDistance.m` |
| `src/reconstruction/demeter/src/properties/computeMetabolicDistance.m` | error | the distances are stored in comDistTmp but read from the undefined comDist | `test/verifiedTests/reconstruction/testDemeter/testComputeMetabolicDistance.m` |
| `src/reconstruction/demeter/src/properties/getSubsystemPresence.m` | unusable-option | The documented default of propertiesFolder is not implemented | `test/verifiedTests/reconstruction/testDemeter/testGetSubsystemPresence.m` |
| `src/reconstruction/demeter/src/properties/plotMetaboliteProducersConsumers.m` | unusable-option | the default metsToAnalyze analyses no metabolite | `test/verifiedTests/reconstruction/testDemeter/testPlotMetaboliteProducersConsumers.m` |
| `src/reconstruction/demeter/src/properties/plotMetaboliteProducersConsumers.m` | error | the header row of a numeric flux file is dropped by readtable | `test/verifiedTests/reconstruction/testDemeter/testPlotMetaboliteProducersConsumers.m` |
| `src/reconstruction/demeter/src/properties/plotMetaboliteProducersConsumers.m` | cosmetic | the metabolite counter is printed | `test/verifiedTests/reconstruction/testDemeter/testPlotMetaboliteProducersConsumers.m` |
| `src/reconstruction/demeter/src/properties/producetSNEPlots.m` | error | 16 to 19 taxa with few singletons raise an index error | `test/verifiedTests/reconstruction/testDemeter/testProducetSNEPlots.m` |
| `src/reconstruction/demeter/src/properties/producetSNEPlots.m` | cosmetic | the custom-feature branch filters on the taxa of the last taxon level | `test/verifiedTests/reconstruction/testDemeter/testProducetSNEPlots.m` |
| `src/reconstruction/demeter/src/properties/producetSNEPlots.m` | error | the custom-feature branch reads perpl, which only the taxon branch sets | `test/verifiedTests/reconstruction/testDemeter/testProducetSNEPlots.m` |
| `src/reconstruction/demeter/src/properties/producetSNEPlots.m` | error | three t-SNE coordinates are stored in two columns | `test/verifiedTests/reconstruction/testDemeter/testProducetSNEPlots.m` |
| `src/reconstruction/demeter/src/properties/rankFeaturesByIncidence.m` | wrong-result | metabolite and uptake/secretion features are looked up in the reaction database | `test/verifiedTests/reconstruction/testDemeter/testRankFeaturesByIncidence.m` |
| `src/reconstruction/demeter/src/properties/rankFeaturesByIncidence.m` | wrong-result | the percentage of reconstructions is divided by the count of the most common feature | `test/verifiedTests/reconstruction/testDemeter/testRankFeaturesByIncidence.m` |
| `src/reconstruction/demeter/src/properties/summarizeFeaturesOnTaxonLevels.m` | wrong-result | numeric presence values become NaN on R2020a and newer | `test/verifiedTests/reconstruction/testDemeter/testSummarizeFeaturesOnTaxonLevels.m` |
| `src/reconstruction/demeter/src/properties/summarizeFeaturesOnTaxonLevels.m` | error | the row range is built from size(getTax), a two-element vector | `test/verifiedTests/reconstruction/testDemeter/testSummarizeFeaturesOnTaxonLevels.m` |
| `src/reconstruction/demeter/src/properties/summarizeFeaturesOnTaxonLevels.m` | error | the table of taxon level i is named with the file prefix of row i | `test/verifiedTests/reconstruction/testDemeter/testSummarizeFeaturesOnTaxonLevels.m` |
| `src/reconstruction/demeter/src/properties/summarizeFeaturesOnTaxonLevels.m` | error | undefined variable ddataByFeature | `test/verifiedTests/reconstruction/testDemeter/testSummarizeFeaturesOnTaxonLevels.m` |
| `src/reconstruction/demeter/src/refinement/rebuildBiomassReaction.m` | limitation | Biomass coefficients are rounded to about five significant digits | `test/verifiedTests/reconstruction/testDemeter/testRebuildBiomassReaction.m` |
| `src/reconstruction/demeter/src/refinement/rebuildBiomassReaction.m` | error | Rebuilding the biomass of Archaea stops with an error | `test/verifiedTests/reconstruction/testDemeter/testRebuildBiomassReaction.m` |
| `src/reconstruction/demeter/src/refinement/rebuildBiomassReaction.m` | wrong-result | The model has no objective after rebuilding the biomass of Tenericutes | `test/verifiedTests/reconstruction/testDemeter/testRebuildBiomassReaction.m` |
| `src/reconstruction/demeter/suite/reports/compareVersions.m` | error | Every comparison stops at a test function that does not exist in the toolbox | `test/verifiedTests/reconstruction/testDemeter/testCompareVersions.m` |
| `src/reconstruction/demeter/suite/reports/compareVersions.m` | wrong-result | Metabolite content is reported as identical whenever the reactions are identical | `test/verifiedTests/reconstruction/testDemeter/testCompareVersions.m` |
| `src/reconstruction/demeter/suite/reports/printRefinementReport.m` | wrong-result | Aromatic amino acid results are reported as bile acids, bile acids as drugs, drugs are left out | `test/verifiedTests/reconstruction/testDemeter/testPrintRefinementReport.m` |
| `src/reconstruction/demeter/suite/tests/plotTestSuiteResults.m` | wrong-result | growth on the defined medium is lost when the file holds only numbers | `test/verifiedTests/reconstruction/testDemeter/testPlotTestSuiteResults.m` |
| `src/reconstruction/demeter/suite/tests/plotTestSuiteResults.m` | cosmetic | the sensitivity column header loses its blank | `test/verifiedTests/reconstruction/testDemeter/testPlotTestSuiteResults.m` |
| `src/reconstruction/growthExpMatch/growthExpMatch.m` | error | A SUX structure without exchange reactions cannot be solved | `test/verifiedTests/reconstruction/testGrowthExpMatch/testGrowthExpMatch.m` |
| `src/reconstruction/growthExpMatch/growthExpMatch.m` | error | An empty objective stops with an undefined variable | `test/verifiedTests/reconstruction/testGrowthExpMatch/testGrowthExpMatch.m` |
| `src/reconstruction/growthExpMatch/printSolutionGEM.m` | error | A log file name shorter than four characters stops the function | `test/verifiedTests/reconstruction/testGrowthExpMatch/testPrintSolutionGEM.m` |
| `src/reconstruction/metaboRePort/generateMetaboReport.m` | cosmetic | Every template line is printed twice to the console | `test/verifiedTests/reconstruction/testMetaboRePort/testGenerateMetaboReport.m` |
| `src/reconstruction/metaboRePort/generateMetaboReport.m` | wrong-result | Template lines are written as fprintf formats, so a percent sign cuts the line | `test/verifiedTests/reconstruction/testMetaboRePort/testGenerateMetaboReport.m` |
| `src/reconstruction/metaboRePort/generateMetaboReport.m` | wrong-result | The first template line is not written | `test/verifiedTests/reconstruction/testMetaboRePort/testGenerateMetaboReport.m` |
| `src/reconstruction/modelGeneration/checkDuplicateRxn.m` | wrong-result | the 'FR' method removes the last reaction of a group after testing the first two | `test/verifiedTests/reconstruction/testCheckDuplicateRxn/testCheckDuplicateRxn.m` |
| `src/reconstruction/modelGeneration/checkDuplicateRxn.m` | wrong-result | the 'rxnAbbr' method returns the unique reactions as the duplicates | `test/verifiedTests/reconstruction/testCheckDuplicateRxn/testCheckDuplicateRxn.m` |
| `src/reconstruction/modelGeneration/fastLeakTest.m` | error | an error when every tested reaction leaks | `test/verifiedTests/reconstruction/testFastLeakTest/testFastLeakTest.m` |
| `src/reconstruction/modelGeneration/massBalance/elementalMatrixToFormulae.m` | wrong-result | A count equal to 10^-dMax or smaller is dropped, so dMax = 0 drops every count of 1 | `test/verifiedTests/reconstruction/testModelGeneration/testElementalMatrixToFormulae.m` |
| `src/reconstruction/modelGeneration/massBalance/getElementalComposition.m` | cosmetic | Formula numbers in error messages lose their zero padding inside parentheses | `test/verifiedTests/reconstruction/testModelGeneration/testGetElementalComposition.m` |
| `src/reconstruction/modelGeneration/massBalance/ispolymer.m` | error | Every formula stops with an error because the group name FULLR2 contains a digit | `test/verifiedTests/reconstruction/testModelGeneration/testIspolymer.m` |
| `src/reconstruction/modelGeneration/massBalance/numAtomsOfElementInFormula.m` | cosmetic | A formula given as a cell or number stops with a MATLAB error, not the class error | `test/verifiedTests/reconstruction/testModelGeneration/testNumAtomsOfElementInFormula.m` |
| `src/reconstruction/modelGeneration/massBalance/numAtomsOfElementInFormula.m` | cosmetic | Output is printed at printLevel 0 | `test/verifiedTests/reconstruction/testModelGeneration/testNumAtomsOfElementInFormula.m` |
| `src/reconstruction/modelGeneration/massBalance/numAtomsOfElementInFormula.m` | limitation | Zero counts are replaced only when the formula holds a single zero | `test/verifiedTests/reconstruction/testModelGeneration/testNumAtomsOfElementInFormula.m` |
| `src/reconstruction/modelGeneration/massBalance/pHbalanceProtons.m` | wrong-result | A proton-driven reaction uses an undefined or stale proton index | `test/verifiedTests/reconstruction/testModelGeneration/testPHbalanceProtons.m` |
| `src/reconstruction/modelGeneration/massBalance/pHbalanceProtons.m` | error | The default of massImbalance uses nRxn before it is defined | `test/verifiedTests/reconstruction/testModelGeneration/testPHbalanceProtons.m` |
| `src/reconstruction/modelGeneration/massBalance/pHbalanceProtons.m` | error | The missing-formula warning tests the whole formula list | `test/verifiedTests/reconstruction/testModelGeneration/testPHbalanceProtons.m` |
| `src/reconstruction/modelGeneration/massBalance/pHbalanceProtons.m` | cosmetic | The report file is never closed | `test/verifiedTests/reconstruction/testModelGeneration/testPHbalanceProtons.m` |
| `src/reconstruction/modelGeneration/modelProperties/checkModelProperties.m` | wrong-result | minSij is zero for every model with a zero in S | `test/verifiedTests/reconstruction/testCheckModelProperties/testCheckModelProperties.m` |
| `src/reconstruction/modelGeneration/modelProperties/checkModelProperties.m` | error | the randomised thermodynamic test can stop with an error | `test/verifiedTests/reconstruction/testCheckModelProperties/testCheckModelProperties.m` |
| `src/reconstruction/modelGeneration/modelProperties/checkModelProperties.m` | wrong-result | the sanity checks after the rank computation never fire | `test/verifiedTests/reconstruction/testCheckModelProperties/testCheckModelProperties.m` |
| `src/reconstruction/modelGeneration/modelProperties/checkModelProperties.m` | cosmetic | the thermodynamic consistency counts vary between runs | `test/verifiedTests/reconstruction/testCheckModelProperties/testCheckModelProperties.m` |
| `src/reconstruction/modelGeneration/modelProperties/makeModelPropertiesTable.m` | error | A results directory given without a trailing separator cannot be loaded | `test/verifiedTests/reconstruction/testModelGeneration/testMakeModelPropertiesTable.m` |
| `src/reconstruction/modelGeneration/modelProperties/makeModelPropertiesTable.m` | limitation | A results model without balancedRxnBool stops with an error | `test/verifiedTests/reconstruction/testModelGeneration/testMakeModelPropertiesTable.m` |
| `src/reconstruction/modelGeneration/modelProperties/makeModelPropertiesTable.m` | cosmetic | The progress message of each model column prints nothing | `test/verifiedTests/reconstruction/testModelGeneration/testMakeModelPropertiesTable.m` |
| `src/reconstruction/modelGeneration/modelProperties/plotModelConsistency.m` | wrong-result | The fraction of stoichiometrically consistent rows is inverted | `test/verifiedTests/reconstruction/testModelGeneration/testPlotModelConsistency.m` |
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
| `src/reconstruction/modelGeneration/stoichConsistency/maxEntConsVector.m` | wrong-result | The entropy maximiser is resolved only to the pdco optimality tolerance | `test/verifiedTests/reconstruction/testStoichiometricConsistency/testMaxEntConsVector.m` |
| `src/reconstruction/modelGeneration/stoichConsistency/maxEntConsVector.m` | wrong-result | The objective passed to pdco does not match its gradient and Hessian | `test/verifiedTests/reconstruction/testStoichiometricConsistency/testMaxEntConsVector.m` |
| `src/reconstruction/modelGeneration/stoichConsistency/maxEntConsVector.m` | cosmetic | printLevel is ignored and pdco always prints its iteration log | `test/verifiedTests/reconstruction/testStoichiometricConsistency/testMaxEntConsVector.m` |
| `src/reconstruction/modelGeneration/test4HumanFctExt.m` | error | an error when no test carried flux | `test/verifiedTests/reconstruction/testModelGeneration/testTest4HumanFctExt.m` |
| `src/reconstruction/modelGeneration/test4HumanFctExt.m` | cosmetic | the diary is opened in the current folder and never closed | `test/verifiedTests/reconstruction/testModelGeneration/testTest4HumanFctExt.m` |
| `src/reconstruction/modelGeneration/test4HumanFctExt.m` | unusable-option | the documented option 'IECori' is not recognised | `test/verifiedTests/reconstruction/testModelGeneration/testTest4HumanFctExt.m` |
| `src/reconstruction/modelGeneration/test4HumanFctExt.m` | unusable-option | the option 'IECOri' stops with an error for every model | `test/verifiedTests/reconstruction/testModelGeneration/testTest4HumanFctExt.m` |
| `src/reconstruction/modelGeneration/test4HumanFctExt.m` | error | three tests stop with an error when their objective reaction is missing | `test/verifiedTests/reconstruction/testModelGeneration/testTest4HumanFctExt.m` |
| `src/reconstruction/rBioNet/LegalRxnFormula.m` | wrong-result | An empty formula is accepted when more than one formula is checked | `test/verifiedTests/reconstruction/testRBioNet/testLegalRxnFormula.m` |
| `src/reconstruction/rBioNet/LegalRxnFormula.m` | cosmetic | The message has a spelling error | `test/verifiedTests/reconstruction/testRBioNet/testLegalRxnFormula.m` |
| `src/reconstruction/rBioNet/ReactionChecks.m` | error | A metabolite without charged formula raises an error after BalancePrep's message | `test/verifiedTests/reconstruction/testRBioNet/testReactionChecks.m` |
| `src/reconstruction/rBioNet/ReactionChecks.m` | cosmetic | A new reaction identical to a database reaction leaves an empty row in data | `test/verifiedTests/reconstruction/testRBioNet/testReactionChecks.m` |
| `src/reconstruction/rBioNet/ReactionChecks.m` | cosmetic | The balance check prints ans = [] for every new reaction | `test/verifiedTests/reconstruction/testRBioNet/testReactionChecks.m` |
| `src/reconstruction/rBioNet/ReactionChecks.m` | error | The missing-formula message is never shown; an empty formula raises an index error | `test/verifiedTests/reconstruction/testRBioNet/testReactionChecks.m` |
| `src/reconstruction/rBioNet/balancecheck.m` | wrong-result | Elements outside the fixed list of twelve are not checked | `test/verifiedTests/reconstruction/testRBioNet/testBalancecheck.m` |
| `src/reconstruction/rBioNet/model2data.m` | error | A model whose description is missing or is not a text or a structure of seven fields stops | `test/verifiedTests/reconstruction/testRBioNet/testModel2data.m` |
| `src/reconstruction/rBioNet/model2data.m` | wrong-result | A model without grRules is reported as incomplete although the field is created | `test/verifiedTests/reconstruction/testRBioNet/testModel2data.m` |
| `src/reconstruction/rBioNet/model2data.m` | error | The two exits with a message box leave the output unassigned | `test/verifiedTests/reconstruction/testRBioNet/testModel2data.m` |
| `src/reconstruction/rBioNet/rBioNetSaveLoad.m` | error | A wrong path of the compartment database is not detected | `test/verifiedTests/reconstruction/testRBioNet/testRBioNetSaveLoad.m` |
| `src/reconstruction/rBioNet/rBioNetSaveLoad.m` | cosmetic | Saving prints the whole database | `test/verifiedTests/reconstruction/testRBioNet/testRBioNetSaveLoad.m` |
| `src/reconstruction/rBioNet/rBioNet_search.m` | limitation | The default of exact is applied only when str is also missing | `test/verifiedTests/reconstruction/testRBioNet/testRBioNet_search.m` |
| `src/reconstruction/refinement/GPRLogic/AndNode.m` | wrong-result | A numeric literal ID is not deleted | `test/verifiedTests/reconstruction/testGPRLogic/testAndNode.m` |
| `src/reconstruction/refinement/GPRLogic/AndNode.m` | limitation | convertToDNF of an AndNode without children stops with an error | `test/verifiedTests/reconstruction/testGPRLogic/testAndNode.m` |
| `src/reconstruction/refinement/GPRLogic/FormulaParser.m` | limitation | An empty rule stops with an error | `test/verifiedTests/reconstruction/testGPRLogic/testFormulaParser.m` |
| `src/reconstruction/refinement/GPRLogic/FormulaParser.m` | limitation | createNodeStructure fails for a text with spaced operators that is not a stored key | `test/verifiedTests/reconstruction/testGPRLogic/testFormulaParser.m` |
| `src/reconstruction/refinement/GPRLogic/Node.m` | limitation | contains stops with an error on a node without children | `test/verifiedTests/reconstruction/testGPRLogic/testNode.m` |
| `src/reconstruction/refinement/GPRLogic/Node.m` | wrong-result | isequal is false for a tree with a repeated clause, and not symmetric | `test/verifiedTests/reconstruction/testGPRLogic/testNode.m` |
| `src/reconstruction/refinement/GPRLogic/Node.m` | wrong-result | isequal is false for equivalent trees with different literals | `test/verifiedTests/reconstruction/testGPRLogic/testNode.m` |
| `src/reconstruction/refinement/GPRLogic/Node.m` | wrong-result | removeDuplicateLiterals removes the wrong children when a child that is not a literal comes before a literal | `test/verifiedTests/reconstruction/testGPRLogic/testNode.m` |
| `src/reconstruction/refinement/GPRLogic/NormaliseGPRs.m` | wrong-result | The rules are not reduced to the minimal DNF form: absorbed clauses are kept | `test/verifiedTests/reconstruction/testGPRLogic/testNormaliseGPRs.m` |
| `src/reconstruction/refinement/GPRLogic/OrNode.m` | wrong-result | A numeric literal ID is not deleted | `test/verifiedTests/reconstruction/testGPRLogic/testOrNode.m` |
| `src/reconstruction/refinement/GPRLogic/OrNode.m` | limitation | convertToCNF of an OrNode without children returns an empty AndNode, which evaluates to true, while the empty OrNode evaluates to false | `test/verifiedTests/reconstruction/testGPRLogic/testOrNode.m` |
| `src/reconstruction/refinement/GPRLogic/combineChildren.m` | wrong-result | Identical generated clauses delete the earlier clause | `test/verifiedTests/reconstruction/testModelManipulation/testCombineChildren.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | error | A formula whose first metabolite has no coefficient stops with an error | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | wrong-result | A new metabolite used twice in one call is added twice or loses a coefficient | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | wrong-result | A proteins field of another size than the gene list discards the result | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | wrong-result | Appended reactions get no identifier, so rxns is shorter than the other fields | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | error | Appending a reaction whose first metabolite is already in the model stops with an error | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | wrong-result | The default gene list removes all genes of the model | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/addReactionGEM.m` | wrong-result | The subsystem of every filled reaction is stored as a cell inside a cell | `test/verifiedTests/reconstruction/testModelManipulation/testAddReactionGEM.m` |
| `src/reconstruction/refinement/annotateSBOTerms.m` | wrong-result | metSBOTerms and geneSBOTerms are created as rows, not m x 1 and g x 1 | `test/verifiedTests/reconstruction/testRefinement/testAnnotateSBOTerms.m` |
| `src/reconstruction/refinement/assignGPRA.m` | error | Every call stops because parseSimPhenyGPRA does not exist | `test/verifiedTests/reconstruction/testRefinement/testAssignGPRA.m` |
| `src/reconstruction/refinement/assignSubSystems.m` | error | Every call stops because parseSimPhenyGPRA does not exist | `test/verifiedTests/reconstruction/testRefinement/testAssignSubSystems.m` |
| `src/reconstruction/refinement/changeCOBRAConstraints.m` | error | The documented constraint index cannot be used as constraintID | `test/verifiedTests/reconstruction/testRefinement/testChangeCOBRAConstraints.m` |
| `src/reconstruction/refinement/changeCOBRAVariable.m` | unusable-option | The documented option Name stops with an error | `test/verifiedTests/reconstruction/testRefinement/testChangeCOBRAVariable.m` |
| `src/reconstruction/refinement/changeCOBRAVariable.m` | error | The documented variable index cannot be used as variableID | `test/verifiedTests/reconstruction/testRefinement/testChangeCOBRAVariable.m` |
| `src/reconstruction/refinement/changeRxnMets.m` | cosmetic | A partly unknown reaction list is not reported | `test/verifiedTests/reconstruction/testModelManipulation/testChangeRxnMets.m` |
| `src/reconstruction/refinement/changeRxnMets.m` | wrong-result | The extra reactions are drawn from a set that already contains the selected ones | `test/verifiedTests/reconstruction/testModelManipulation/testChangeRxnMets.m` |
| `src/reconstruction/refinement/changeRxnMets.m` | wrong-result | With one metabolite to change, the random selection reduces the S row to a scalar | `test/verifiedTests/reconstruction/testModelManipulation/testChangeRxnMets.m` |
| `src/reconstruction/refinement/extractSubSysModel.m` | wrong-result | A single subsystem name given as text selects almost every reaction | `test/verifiedTests/reconstruction/testModelManipulation/testExtractSubSysModel.m` |
| `src/reconstruction/refinement/isSameCobraModel.m` | wrong-result | Logical fields are never compared | `test/verifiedTests/reconstruction/testRefinement/testIsSameCobraModel.m` |
| `src/reconstruction/refinement/isSameCobraModel.m` | wrong-result | Text fields are compared with every non-word character removed, not only white space | `test/verifiedTests/reconstruction/testRefinement/testIsSameCobraModel.m` |
| `src/reconstruction/refinement/isSameCobraModel.m` | cosmetic | The message for differing nested subSystems names prints 0 positions | `test/verifiedTests/reconstruction/testRefinement/testIsSameCobraModel.m` |
| `src/reconstruction/refinement/isSameCobraModel.m` | error | Two models with different numbers of reactions stop with an error | `test/verifiedTests/reconstruction/testRefinement/testIsSameCobraModel.m` |
| `src/reconstruction/refinement/mergeModelFieldPositions.m` | error | A cell field that does not hold text or cell arrays cannot be merged | `test/verifiedTests/base/testTools/testMergeModelFieldPositions.m` |
| `src/reconstruction/refinement/mergeTwoModels.m` | wrong-result | A field that cannot be concatenated is dropped with a debug message | `test/verifiedTests/reconstruction/testModelManipulation/testMergeTwoModels.m` |
| `src/reconstruction/refinement/removeFieldEntriesForType.m` | error | removing genes from a model that has grRules but no rules field fails | `test/verifiedTests/reconstruction/testRemoveFieldEntriesForType/testRemoveFieldEntriesForType.m` |
| `src/reconstruction/refinement/updateFieldOrderForType.m` | limitation | An order that repeats indices is accepted | `test/verifiedTests/reconstruction/testModelManipulation/testUpdateFieldOrderForType.m` |
| `src/reconstruction/refinement/updateFieldOrderForType.m` | unusable-option | The type proteins is accepted but always stops with an error | `test/verifiedTests/reconstruction/testModelManipulation/testUpdateFieldOrderForType.m` |
| `src/reconstruction/refinement/updateGenes.m` | wrong-result | With two duplicated genes, different genes are merged | `test/verifiedTests/reconstruction/testModelManipulation/testUpdateGenes.m` |
| `src/visualization/SAMMIM/expa.m` | wrong-result | The collapsed model does not match the input model: its objective is zero and its reactions are reordered | `test/verifiedTests/visualization/testSAMMIM/testExpa.m` |
| `src/visualization/cellDesigner/addAnnotation.m` | error | Annotating a reaction of a standard COBRA model stops with an error | `test/verifiedTests/visualization/testCellDesigner/testAddAnnotation.m` |
| `src/visualization/cellDesigner/addColour.m` | wrong-result | A reaction listed by an ID in the last row of r_info.ID is not coloured | `test/verifiedTests/visualization/testCellDesigner/testAddColour.m` |
| `src/visualization/cellDesigner/addColour.m` | wrong-result | The html colours of the second column of listRxn_Color are ignored | `test/verifiedTests/visualization/testCellDesigner/testAddColour.m` |
| `src/visualization/cellDesigner/addColour.m` | error | The second output is not assigned when no listed link has a non-zero width | `test/verifiedTests/visualization/testCellDesigner/testAddColour.m` |
| `src/visualization/cellDesigner/addFlux.m` | wrong-result | A reaction whose structure field is named by the reaction ID itself is left unchanged | `test/verifiedTests/visualization/testCellDesigner/testAddFlux.m` |
| `src/visualization/cellDesigner/addFlux.m` | wrong-result | Reaction IDs with (e) are not converted to the _e field name | `test/verifiedTests/visualization/testCellDesigner/testAddFlux.m` |
| `src/visualization/cellDesigner/addMiriam.m` | wrong-result | Every matched species receives the MIRIAM entries of the last infix entry | `test/verifiedTests/visualization/testCellDesigner/testAddMiriam.m` |
| `src/visualization/cellDesigner/addMiriam.m` | unusable-option | The documented option miriam_path stops with an error | `test/verifiedTests/visualization/testCellDesigner/testAddMiriam.m` |
| `src/visualization/cellDesigner/cmpMet.m` | wrong-result | A parsed species is reported present when one of its entries is a substring of a model metabolite ID | `test/verifiedTests/visualization/testCellDesigner/testCmpMet.m` |
| `src/visualization/cellDesigner/cmpMet.m` | cosmetic | Every comparison prints the searched name | `test/verifiedTests/visualization/testCellDesigner/testCmpMet.m` |
| `src/visualization/cellDesigner/cmpMet.m` | wrong-result | Model metabolites absent from the parsed model are returned in lower case | `test/verifiedTests/visualization/testCellDesigner/testCmpMet.m` |
| `src/visualization/cellDesigner/cmpRxn.m` | error | A parsed model with no reaction found in the COBRA model raises an error | `test/verifiedTests/visualization/testCellDesigner/testCmpRxn.m` |
| `src/visualization/cellDesigner/correctMetName.m` | cosmetic | Debug output of the species row numbers | `test/verifiedTests/visualization/testCellDesigner/testCorrectMetName.m` |
| `src/visualization/cellDesigner/parseCD.m` | limitation | A reaction written on one line makes the function loop forever | `test/verifiedTests/visualization/testCellDesigner/testParseCD.m` |
| `src/visualization/cellDesigner/parseCD.m` | cosmetic | Debug output of the keyword table, of every line read and of intermediate values | `test/verifiedTests/visualization/testCellDesigner/testParseCD.m` |
| `src/visualization/cellDesigner/parseCD.m` | limitation | The input file is left open | `test/verifiedTests/visualization/testCellDesigner/testParseCD.m` |
| `src/visualization/cellDesigner/position.m` | error | An attribute name that occurs more than once in the line stops the function | `test/verifiedTests/visualization/testCellDesigner/testPosition.m` |
| `src/visualization/cellDesigner/position.m` | cosmetic | Debug output of the start index, the rest of the line and the end index | `test/verifiedTests/visualization/testCellDesigner/testPosition.m` |
| `src/visualization/cellDesigner/readCD.m` | limitation | Attributes missing from the first reaction are dropped for all reactions | `test/verifiedTests/visualization/testCellDesigner/testReadCD.m` |
| `src/visualization/cellDesigner/readCD.m` | cosmetic | Debug output of the attribute list and of the whole partial result | `test/verifiedTests/visualization/testCellDesigner/testReadCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | error | A text without "<species " lines stops with an error | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | cosmetic | Debug output of internal variables | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | wrong-result | Every occurrence of the old name in the line is replaced | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | unusable-option | The documented default value of note stops with an error | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | wrong-result | The second round pairs name lines with species rows by position and stops early | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | wrong-result | changedStrLines lists only the lines changed in the second round | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/updateCD.m` | wrong-result | number lists only the lines found in the second round | `test/verifiedTests/visualization/testCellDesigner/testUpdateCD.m` |
| `src/visualization/cellDesigner/writeTXT.m` | wrong-result | A '#RRGGBB' colour containing 'FF' is truncated | `test/verifiedTests/visualization/testCellDesigner/testWriteTXT.m` |
| `src/visualization/cellDesigner/writeTXT.m` | error | A colour code without '#' or 'FF' in the first row stops with an error | `test/verifiedTests/visualization/testCellDesigner/testWriteTXT.m` |
| `src/visualization/cellDesigner/writeTXT.m` | error | A one-column para stops with an error at the default colour | `test/verifiedTests/visualization/testCellDesigner/testWriteTXT.m` |
| `src/visualization/createMetIntrcNetwork/hit_node.m` | unusable-option | The node-degree exclusion range excNodesWithDeg has no effect | `test/verifiedTests/visualization/testCreateMetIntrcNetwork/testHit_node.m` |
| `src/visualization/efmviz/efmEnrichmentAnalysis.m` | error | Expression data without significance values stops with an error | `test/verifiedTests/visualization/testEFMviz/testEfmEnrichmentAnalysis.m` |
| `src/visualization/efmviz/efmSubsystemsExtraction.m` | error | Every call with valid inputs stops with an error | `test/verifiedTests/visualization/testEFMviz/testEfmSubsystemsExtraction.m` |
| `src/visualization/entropicFBA/calculateGeneWeight.m` | cosmetic | A model without SConsistentRxnBool fails before the function's own check | `test/verifiedTests/visualization/testEntropicFBA/testCalculateGeneWeight.m` |
| `src/visualization/entropicFBA/calculateGeneWeight.m` | wrong-result | Reactions without expressed genes keep weight 0 when any reaction is inconsistent | `test/verifiedTests/visualization/testEntropicFBA/testCalculateGeneWeight.m` |
| `src/visualization/maps/ReconMap/buildFluxDistLayout.m` | wrong-result | The largest flux gets line width 0 and the smallest the maximum width | `test/verifiedTests/visualization/testReconMap/testBuildFluxDistLayout.m` |
| `src/visualization/maps/ReconMap/buildFluxDistLayout.m` | unusable-option | The maxThickness input is ignored | `test/verifiedTests/visualization/testReconMap/testBuildFluxDistLayout.m` |
| `src/visualization/maps/ReconMap/generateSubsytemsLayout.m` | wrong-result | The overlay content is truncated to 'name' before it is sent | `test/verifiedTests/visualization/testReconMap/testGenerateSubsytemsLayout.m` |
| `src/visualization/maps/ReconMap/makeColorGradient.m` | wrong-result | A channel that is equal in both colours becomes 0 | `test/verifiedTests/visualization/testReconMap/testMakeColorGradient.m` |
| `src/visualization/maps/ReconMap/printInRecon3Dmap.m` | cosmetic | The line width is written with a stray digit | `test/verifiedTests/visualization/testReconMap/testPrintInRecon3Dmap.m` |
| `src/visualization/metabolicCartography/addFluxFBA.m` | wrong-result | A flux of exactly 1e-3 of the largest flux keeps width 0.001 | `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxFBA.m` |
| `src/visualization/metabolicCartography/addFluxFBA.m` | wrong-result | A flux vector of zeros gives NaN widths | `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxFBA.m` |
| `src/visualization/metabolicCartography/addFluxFBA.m` | wrong-result | fluxMap holds the widths of the input map, not the flux widths | `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxFBA.m` |
| `src/visualization/metabolicCartography/addFluxFBAdirectionAndColor.m` | wrong-result | A flux of exactly 1e-3 of the largest flux keeps width 0.001 | `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxFBAdirectionAndColor.m` |
| `src/visualization/metabolicCartography/addFluxFBAdirectionAndColor.m` | wrong-result | A flux vector of zeros gives NaN widths | `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxFBAdirectionAndColor.m` |
| `src/visualization/metabolicCartography/addFluxFromFileWidthAndColor.m` | wrong-result | Numeric reaction IDs of different lengths do not match the map | `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxFromFileWidthAndColor.m` |
| `src/visualization/metabolicCartography/addFluxWidthAndColor.m` | limitation | Map reactions without flux data get no colour entry | `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxWidthAndColor.m` |
| `src/visualization/metabolicCartography/addNotes.m` | cosmetic | A metabolite shown twice in the map gets its note twice in each copy | `test/verifiedTests/visualization/testMetabolicCartography/testAddNotes.m` |
| `src/visualization/metabolicCartography/addNotes.m` | wrong-result | Numeric confidence scores are written as control characters | `test/verifiedTests/visualization/testMetabolicCartography/testAddNotes.m` |
| `src/visualization/metabolicCartography/addNotes.m` | error | Subsystems stored as cells of cells raise an error | `test/verifiedTests/visualization/testMetabolicCartography/testAddNotes.m` |
| `src/visualization/metabolicCartography/changeNodesArea.m` | error | The optional areaWidth is not defaulted when areaHeight is given | `test/verifiedTests/visualization/testMetabolicCartography/testChangeNodesArea.m` |
| `src/visualization/metabolicCartography/colorProtein.m` | error | The default colour 'Red' is not a key of createColorsMap | `test/verifiedTests/visualization/testMetabolicCartography/testColorProtein.m` |
| `src/visualization/metabolicCartography/colorSubsystemCD.m` | wrong-result | Reactions with several subsystems shift the selection to the wrong reactions | `test/verifiedTests/visualization/testMetabolicCartography/testColorSubsystemCD.m` |
| `src/visualization/metabolicCartography/defaultColorCD.m` | error | Secondary reaction lines are coloured with the undefined function Colors | `test/verifiedTests/visualization/testMetabolicCartography/testDefaultColorCD.m` |
| `src/visualization/metabolicCartography/defaultLookMap.m` | wrong-result | An included species named as an ion makes the main species of the same index an ION | `test/verifiedTests/visualization/testMetabolicCartography/testDefaultLookMap.m` |
| `src/visualization/metabolicCartography/findRxnsInMap.m` | error | A list with a reaction name absent from the map is an error | `test/verifiedTests/visualization/testMetabolicCartography/testFindRxnsInMap.m` |
| `src/visualization/metabolicCartography/findRxnsInMap.m` | error | A single reaction name found once leaves the output rxnIDref unassigned | `test/verifiedTests/visualization/testMetabolicCartography/testFindRxnsInMap.m` |
| `src/visualization/metabolicCartography/mapFormula.m` | error | Fails instead of returning empty lists when no listed reaction is in the map | `test/verifiedTests/visualization/testMetabolicCartography/testMapFormula.m` |
| `src/visualization/metabolicCartography/removeCDReactions.m` | cosmetic | A name listed twice is reported as not present in the map | `test/verifiedTests/visualization/testMetabolicCartography/testRemoveCDReactions.m` |
| `src/visualization/metabolicCartography/removeCDReactions.m` | wrong-result | A species still used as modifier by a kept reaction is removed, leaving dangling references | `test/verifiedTests/visualization/testMetabolicCartography/testRemoveCDReactions.m` |
| `src/visualization/metabolicCartography/removeCDReactions.m` | wrong-result | A species that only modifies removed reactions is kept | `test/verifiedTests/visualization/testMetabolicCartography/testRemoveCDReactions.m` |
| `src/visualization/metabolicCartography/removeMapMol.m` | wrong-result | Aliases of a removed reaction are removed even when kept reactions use them | `test/verifiedTests/visualization/testMetabolicCartography/testRemoveMapMol.m` |
| `src/visualization/metabolicCartography/removeMapMol.m` | limitation | Reactions keep a removed alias of a species that has other aliases | `test/verifiedTests/visualization/testMetabolicCartography/testRemoveMapMol.m` |
| `src/visualization/metabolicCartography/transformFullMap2XML.m` | error | A map with exactly one complex or one included species cannot be written | `test/verifiedTests/visualization/testMetabolicCartography/testTransformFullMap2XML.m` |
| `src/visualization/metabolicCartography/transformFullMap2XML.m` | cosmetic | Included species without notes are written with empty notes | `test/verifiedTests/visualization/testMetabolicCartography/testTransformFullMap2XML.m` |
| `src/visualization/metabolicCartography/transformFullMap2XML.m` | wrong-result | The complex aliases and complex species of the map are not written | `test/verifiedTests/visualization/testMetabolicCartography/testTransformFullMap2XML.m` |
| `src/visualization/metabolicCartography/transformFullMap2XML.m` | cosmetic | The run time is printed on every call | `test/verifiedTests/visualization/testMetabolicCartography/testTransformFullMap2XML.m` |
| `src/visualization/metabolicCartography/transformFullXML2Map.m` | error | A map with exactly one complex species alias cannot be read | `test/verifiedTests/visualization/testMetabolicCartography/testTransformFullXML2Map.m` |
| `src/visualization/metabolicCartography/transformFullXML2Map.m` | error | Reaction notes written inside XHTML elements cannot be read | `test/verifiedTests/visualization/testMetabolicCartography/testTransformFullXML2Map.m` |
| `src/visualization/metabolicCartography/transformFullXML2Map.m` | wrong-result | The field compartName is missing for a map without compartments | `test/verifiedTests/visualization/testMetabolicCartography/testTransformFullXML2Map.m` |
| `src/visualization/metabolicCartography/transformFullXML2Map.m` | cosmetic | The run time is printed on every call | `test/verifiedTests/visualization/testMetabolicCartography/testTransformFullXML2Map.m` |
| `src/visualization/metabolicCartography/transformMap2XML.m` | wrong-result | A reaction set to reversible 'true' in the map stays reversible="false" in the file | `test/verifiedTests/visualization/testMetabolicCartography/testTransformMap2XML.m` |
| `src/visualization/metabolicCartography/transformMap2XML.m` | wrong-result | Emptied notes and compartment aliases of the map are not removed from the file | `test/verifiedTests/visualization/testMetabolicCartography/testTransformMap2XML.m` |
| `src/visualization/metabolicCartography/transformMap2XML.m` | limitation | Every '~' of the file name is replaced by the home folder | `test/verifiedTests/visualization/testMetabolicCartography/testTransformMap2XML.m` |
| `src/visualization/metabolicCartography/transformMap2XML.m` | wrong-result | The check for a removed only reactant or product compares with the whole alias list | `test/verifiedTests/visualization/testMetabolicCartography/testTransformMap2XML.m` |
| `src/visualization/metabolicCartography/transformMap2XML.m` | cosmetic | The error for a single secondary reactant or product link with several map aliases says 'should not be cell' | `test/verifiedTests/visualization/testMetabolicCartography/testTransformMap2XML.m` |
| `src/visualization/metabolicCartography/unifyMetabolicPPImapCD.m` | wrong-result | Secondary links are recoloured by position, not by the index of the non-empty entries | `test/verifiedTests/visualization/testMetabolicCartography/testUnifyMetabolicPPImapCD.m` |
| `src/visualization/metabolicCartography/visualizeNormalizedRxnPresence.m` | error | A custom colour scheme in the documented format stops with an index error | `test/verifiedTests/visualization/testMetabolicCartography/testVisualizeNormalizedRxnPresence.m` |
| `src/visualization/metabolicCartography/visualizeNormalizedRxnPresence.m` | wrong-result | A second call on the same folder counts the previous heatmap as a map | `test/verifiedTests/visualization/testMetabolicCartography/testVisualizeNormalizedRxnPresence.m` |
| `src/visualization/metabolicCartography/visualizeNormalizedRxnPresence.m` | wrong-result | Reaction colours written in lower case are not counted as present | `test/verifiedTests/visualization/testMetabolicCartography/testVisualizeNormalizedRxnPresence.m` |
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

#### CPLEX 12.10 and later 12.1x versions are classed as older than 12.8

- **Severity**: limitation
- **Trigger**: generateMexFastFVA(root, 0) with ILOG_CPLEX_PATH and root under .../CPLEX_Studio1210/cplex (version string 1210)
- **Observed**: MATLAB R2025a 2026-11-17: lines 54-56 turn 1210 into 121, which is below 128, so versionFlag is -DLOWER_THAN_128 and versionVS is vs2013 (lines 80-86). On Linux and macOS this changes nothing (stand-in mex: the command is that of 12.8 apart from the output name cplexFVA1210) because the flag never reaches mex (defect above); on Windows the library is looked for in lib\x64_windows_vs2013\stat_mda (line 97; read from the code, not run)
- **Expected**: 12.10 classed as 12.8 or later (-DHIGHER_THAN_128 and the library folder of that CPLEX release)
- **Source lines**: 54-56, 80-86, 97
- **Documented in**: `test/verifiedTests/analysis/testFVA/testGenerateMexFastFVA.m`

#### printLevel 2 prints a truncated compilation command and a warning

- **Severity**: cosmetic
- **Trigger**: generateMexFastFVA(root, 2) with a CPLEX installation (include and library folders present)
- **Observed**: MATLAB 2026-11-13 (scratch run, mex stubbed): "Warning: Escaped character '\$' is not valid." and the printed command stops at CFLAGS=" because the command text is passed to fprintf as its format
- **Expected**: the whole compilation command printed, without a warning
- **Source lines**: 141-143
- **Documented in**: `test/verifiedTests/analysis/testFVA/testGenerateMexFastFVA.m`

#### the CPLEX root stays on the MATLAB path when the function stops with an error

- **Severity**: cosmetic
- **Trigger**: any call that ends with the errors of lines 89 or 102 (the error sections described above)
- **Observed**: MATLAB 2026-11-13: rootPathCPLEX, added to the path at line 66, is still on the path after the error; the path saved at line 63 is restored only at lines 163 and 173
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

#### the version flag and the compiler options are never passed to mex

- **Severity**: wrong-result
- **Trigger**: generateMexFastFVA(root, 0) with a complete CPLEX installation (include and library folders and libcplex.a), any CPLEX version
- **Observed**: MATLAB R2025a 2026-11-17 (mex replaced by a stand-in that records its arguments): the compilation call receives the eight arguments -output, cplexFVA128, -largeArrayDims, -ldl, CFLAGS="\$CFLAGS", -I"<include>", "<source>", <library>; the variable CFLAGS of line 138 (with -DHIGHER_THAN_128 or -DLOWER_THAN_128, -O3, -Werror, ...) is never used, because line 139 writes the literal text \$CFLAGS. cplexFVA.c is therefore compiled with neither version macro, which leaves out its CPLEX log-file code (lines 1140-1153 of cplexFVA.c), so the MEX file writes no CPLEX log file (inferred from the C source; nothing compiled here, CPLEX is not installed)
- **Expected**: mex called with the flags of line 138 (CFLAGS="$CFLAGS <flags>"), so that the version switch of lines 79-86 takes effect
- **Source lines**: 79-86, 138-139
- **Documented in**: `test/verifiedTests/analysis/testFVA/testGenerateMexFastFVA.m`

### `src/analysis/KLdistance/KLdistance.m`

#### The two densities are compared on different grids, so distinct populations get a zero distance

- **Severity**: wrong-result
- **Trigger**: x = [1.0; 2.0; 2.5; 4.0; 5.5; 6.0]; KLdistance(x, x + 100, 1, {'a'}) (two populations with disjoint supports); also KLdistance(x, 3 * x, 1, {'a'})
- **Observed**: (R2025a, 2026-11-17) dist = 1.32646e-30 for x and x + 100 and 2.08731e-31 for x and 3 * x, i.e. zero up to rounding: cobraKsdensity evaluates each density on 100 points spanning its own sample (grids [-4.76, 11.76] and [95.24, 111.76] here) and lines 34-35 and 47-48 discard the grid (xi); the two density vectors are equal (max difference 3.2e-16), so KLDis (lines 36 and 50) compares values at unrelated x points. The permutation distances (lines 39-51) share the error
- **Expected**: the Kullback-Leibler distance between the two distributions, i.e. the two densities evaluated on one common grid: a clearly positive distance for disjoint or rescaled populations
- **Source lines**: 34-36, 47-50
- **Documented in**: `test/verifiedTests/analysis/testKLdistance/testKLdistance.m`

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

### `src/analysis/ecosystem/getQualitativeFluxStates.m`

#### Zero band applied inconsistently to the maximum and to max - min

- **Severity**: wrong-result
- **Trigger**: getQualitativeFluxStates([-1 2 -2], [0 2 -2], 0); with the default band getQualitativeFluxStates(-1, 1e-9); and at the edge of a band that is exact in binary, getQualitativeFluxStates([-1 2 -2.5], [0.5 2.5 -2], 0.5)
- **Observed**: (R2025a, 2026-11-17) [5 2 -2] ({'err', '++', '--'}) for delta = 0, 5 for the default band, and [5 2 -2] for delta = 0.5 (just inside that band, getQualitativeFluxStates([-1 2 -2.5], [0.4 2.4 -2.1], 0.5) gives [-1 3 -3]): the state -1 requires max < delta (not <= delta) and the fixed states -3 and 3 require |max - min| < delta (not <= delta), so with delta = 0 they cannot occur. A difference of exactly 1e-9 is hard to produce in double precision ((2 + 1e-9) - 2 is 1.000000082740371e-09), so the edge of the fixed states is shown with delta = 0.5
- **Expected**: [-1 3 -3] ({'-0', '+', '-'}), -1 and [-1 3 -3]: the documented table treats |x| <= delta, and a difference max - min within delta, as zero
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

### `src/analysis/exploration/findCarbonRxns.m`

#### Two-letter element symbols beginning with C are counted as carbon

- **Severity**: wrong-result
- **Trigger**: a metabolite whose formula contains Ca, Cl, Co, Cu, Cr, Cd, Ce or Cs; for example model.mets = {'cl[c]'; 'ca2[c]'; 'caox[c]'}, model.metFormulas = {'Cl'; 'Ca'; 'CaC2O4'}, model.S = sparse([-1; -1; 1]), model.rxns = {'R1'}; [hiCarbonRxns, zeroCarbonRxns, nCarbon] = findCarbonRxns(model, 1)
- **Observed**: (R2025a, 2026-11-17) nCarbon = [1 1 1], hiCarbonRxns = {'R1'} and zeroCarbonRxns empty: the regular expression C(\d*) of line 42 matches the C of the element symbol, only the first match is used (line 47) and an empty digit group counts as one carbon (line 50); calcium oxalate counts 1 carbon instead of 2
- **Expected**: nCarbon = [0 0 2] (the header: "The number of carbons in each metabolite", from the "metabolite elemental formulas"); a reaction that acts only on chloride or calcium belongs in zeroCarbonRxns, not in hiCarbonRxns
- **Source lines**: 42, 47-50
- **Documented in**: `test/verifiedTests/analysis/testExploration/testFindCarbonRxns.m`

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

#### A gene that no reaction uses stops the call with onlyOneSub

- **Severity**: error
- **Trigger**: findSubSystemsFromGenes(model, 'onlyOneSub', true) (the call findSubSysGen makes), or with that gene as the gene list, on a model with a gene in model.genes that no reaction uses, for example model = createModel({'R1'; 'R2'; 'R3'; 'EX_A'}, {'reaction 1'; 'reaction 2'; 'reaction 3'; 'A exchange'}, {'A[c] -> B[c]'; 'B[c] + C[c] <=> D[c]'; 'D[c] -> E[c]'; 'A[e] <=> '}, 'subSystemList', {'S1'; 'S2'; 'S3'; 'S4'}, 'grRuleList', {'g1 or g2'; 'g2 and g3'; ''; ''}, 'printLevel', 0); model.genes{end + 1} = 'g4'; model.rxnGeneMat(:, end + 1) = 0
- **Observed**: MATLAB R2025a: "Insufficient number of outputs from right hand side of equal sign to satisfy assignment." in @(x)model.subSystems{find(relAssocs(:,x),1)} at line 90: find returns [] for the unused gene, so the indexing yields no value for arrayfun; without onlyOneSub the same model gives the gene an empty (0 x 1) entry and the call succeeds
- **Expected**: an empty sub-system entry for the unused gene, as without onlyOneSub
- **Source lines**: 90
- **Documented in**: `test/verifiedTests/analysis/testExploration/testFindSubSystemsFromGenes.m`

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

### `src/analysis/exploration/generateHyperlinkedModel.m`

#### A model without rules and without grRules stops at a reference to the missing field rules

- **Severity**: error
- **Trigger**: generateHyperlinkedModel(model) with a model that has rxns, mets and genes but neither rules nor grRules
- **Observed**: MATLAB R2025a: "Unrecognized field name "rules"." at line 48, where numel(model.rules) sizes the empty rules from the very field that was just found missing
- **Expected**: one empty rule per reaction (numel(model.rxns), as generateGrRules line 36 does), then the hyperlinked fields
- **Source lines**: 48
- **Documented in**: `test/verifiedTests/analysis/testExploration/testGenerateHyperlinkedModel.m`

#### Every call stops at the undefined variable addGrRulesLinked

- **Severity**: error
- **Trigger**: any call, for example generateHyperlinkedModel(model) with model = getDistributedModel('ecoli_core_model.mat'), or with a two-reaction model with fields rxns, mets, genes and rules (with or without metNameFlag and hyperlinkCommand, with grRules instead of rules)
- **Observed**: MATLAB R2025a: "Unrecognized function or variable 'addGrRulesLinked'." at line 57 for every one of these calls; which('addGrRulesLinked') is empty. The name is defined only in generateGrRules (src/analysis/exploration/surfNetSubfunctions), from which this function was derived, as ~isempty(hyperlinkCommand)
- **Expected**: the model with the fields grRules, grRulesLinked, metsLinked, rxnsLinked and genesLinked listed under OUTPUT
- **Source lines**: 57, 72
- **Documented in**: `test/verifiedTests/analysis/testExploration/testGenerateHyperlinkedModel.m`

#### The hyperlink format string is read from the undefined variable command

- **Severity**: error
- **Trigger**: any call that passes line 57 (none can while the first defect stands)
- **Observed**: lines 92, 95, 98 and 100 use command, which the function never assigns and which is not on the path (MATLAB R2025a after initCobraToolbox: which('command') is empty, exist('command') is 0); the documented input hyperlinkCommand is used only at line 73. Not observed at run time because every call stops at line 57
- **Expected**: the hyperlinks built with the documented hyperlinkCommand format string
- **Source lines**: 92, 95, 98, 100
- **Documented in**: `test/verifiedTests/analysis/testExploration/testGenerateHyperlinkedModel.m`

### `src/analysis/exploration/getMIRIAMAnnotations.m`

#### A character vector for the ids option stops the call

- **Severity**: error
- **Trigger**: getMIRIAMAnnotations(model, 'rxn', 'ids', 'R1') on a two-reaction model with rxnBRENDAID = {'1.1.1.1'; '2.2.2.2'}; the option is documented as "A specific ID or IDs" and its validator accepts a character vector
- **Observed**: MATLAB R2025a: "Dimensions of arrays being concatenated are not consistent." at line 92, because numElements = length(ids) counts the two characters of 'R1' while relPos selects one reaction; a one-character id 'R' stops at the same line with "Unable to perform assignment because the size of the left side is 1-by-1-by-4 and the size of the right side is 1-by-3."; the cell form {'R1'} returns the brenda term 1.1.1.1 as expected
- **Expected**: the annotations of that one reaction, as for the cell form {'R1'}
- **Source lines**: 54, 92, 138
- **Documented in**: `test/verifiedTests/analysis/testExploration/testGetMIRIAMAnnotations.m`

#### Resources of an earlier controlled-vocabulary term leak into a later term with fewer identifiers

- **Severity**: wrong-result
- **Trigger**: any call in which a later term (a later element, or a later qualifier of the same element) has fewer identifiers than an earlier one, for example a two-reaction model (rxns R1, R2) with rxnBRENDAID = {'1.1.1.1; 2.2.2.2'; '3.3.3.3'} and getMIRIAMAnnotations(model, 'rxn')
- **Observed**: MATLAB R2025a: R2 reports two resources, 3.3.3.3 twice, instead of one (R1 correctly 1.1.1.1 and 2.2.2.2); with rxnBRENDAID = {'1.1.1.1; 2.2.2.2; 3.3.3.3'; '4.4.4.4; 5.5.5.5'} the call stops with "The number of outputs should match the number of inputs." (deal, called from line 172); within one reaction, rxnBRENDAID {'1.1.1.1; 2.2.2.2'} with rxnReferences {'12345'} gives the isDescribedBy term the resources 12345, 12345. Line 170 assigns the empty template to cRessourcestruct (lower-case s) while lines 171-174 fill cRessourceStruct, which keeps the elements of the previous term; with increasing sizes ({'1.1.1.1'; '2.2.2.2; 3.3.3.3'}) and with one identifier per term everywhere the result is correct
- **Expected**: one resource per identifier of the term, as documented for .annotation.cvterms.ressources
- **Source lines**: 170-174
- **Documented in**: `test/verifiedTests/analysis/testExploration/testGetMIRIAMAnnotations.m`

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

- **Severity**: wrong-result
- **Trigger**: plotEssentialRxns(T, [0 100], 1) with the table above
- **Observed**: {'R_1'; 'R2'} (class cell), from table2cell of the rxn column
- **Expected**: per the OUTPUT section, a table with the fluxes of the reactions of interest (rows) across models (columns); the code and the tutorial use the identifiers, so the header is the likely error. Severity audit 2026-11-15: OUTPUT documents "Table with reaction fluxes ... for reactions of interest (rows) across models (columns)"; a cell array of reaction identifiers is returned (line 52) - a different type and content from the documented result
- **Source lines**: 52
- **Documented in**: `test/verifiedTests/analysis/testExploration/testPlotEssentialRxns.m`

### `src/analysis/exploration/printCouplingConstraints.m`

#### The documented output is not assigned with the default printLevel, so a call requesting it stops

- **Severity**: error
- **Trigger**: coupledRxnReport = printCouplingConstraints(model), or with printLevel 0, on a model with a field C, for example the three-reaction model (rxns R1, R2, R3; S = [-1 1 0; 0 -1 1]) with C = [1 -2 0; -1 0 1], d = [0; 1], dsense = ['G'; 'L'] and ctrs = {'c1'; 'c2'}
- **Observed**: MATLAB R2025a: Output argument "coupledRxnReport" (and possibly others) not assigned a value in the execution with "printCouplingConstraints" function. The report is only built inside if printLevel > 0 (line 34) and the else branch of line 87 only covers a model without C. Without an output the same call returns silently; with printLevel 1 the same model gives the two-row table (c1 'R1 - R2 >= 0', c2 '- R1 + R3 <= 1'), with printLevel 2 the six-row table with the reaction formulas, and a model without C gives [] for every printLevel
- **Expected**: the summary report of the USAGE line, coupledRxnReport = printCouplingConstraints(model, printLevel) with "Default = 0", for every printLevel, with only the display gated behind printLevel > 0 as the documentation says
- **Source lines**: 34, 85
- **Documented in**: `test/verifiedTests/analysis/testExploration/testPrintCouplingConstraints.m`

### `src/analysis/exploration/printFluxBounds.m`

#### The documented calls without rxnNameFlag stop with an error

- **Severity**: error
- **Trigger**: printFluxBounds(model) or printFluxBounds(model, {'R1'}) for any model (the usage line is printFluxBounds(model, rxns) and rxnNameFlag is listed as optional)
- **Observed**: after the header line 'Reaction ID  Lower Bound  Upper Bound', "Not enough input arguments." at line 36 (MATLAB R2025a; model with two reactions R1, R2 built with createModel): rxnNameFlag has no default value
- **Expected**: the bounds printed without reaction names, as with rxnNameFlag false
- **Source lines**: 36
- **Documented in**: `test/verifiedTests/analysis/testExploration/testPrintFluxBounds.m`

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

### `src/analysis/gMCS/calculateMCS.m`

#### A row cell array rxn_set together with KO stops with an error

- **Severity**: error
- **Trigger**: model = createModel({'R1', 'R2', 'R3', 'R4'}, {'R1', 'R2', 'R3', 'R4'}, {' -> A', 'A <=> B', 'A -> B', 'B -> '}); model.c(4) = 1; calculateMCS(model, 10, 2, 'KO', 'R2', 'rxn_set', {'R1', 'R3'}) with IBM CPLEX installed and working (here: global SOLVERS with SOLVERS.ibm_cplex.installed = 1 and .working = 1, restored afterwards)
- **Observed**: (R2025a, 2026-11-17; the error comes before any CPLEX call) "Dimensions of arrays being concatenated are not consistent." (MATLAB:catenate:dimensionMismatch) at line 139, rxn_set = [rxn_set; {KO}]; the column {'R1'; 'R3'} reaches the Cplex call, and the row form without KO too
- **Expected**: OPTIONAL INPUTS document rxn_set as a "Cell array containing the set of reactions" (validated by iscell), so a row cell array is accepted and KO is added to the set
- **Source lines**: 139
- **Documented in**: `test/verifiedTests/analysis/testGeneMCS/testCalculateMCS.m`

#### The enumeration writes tmp.mat into the current folder

- **Severity**: cosmetic
- **Trigger**: any call that reaches the enumeration loop (IBM CPLEX installed)
- **Observed**: (R2025a, 2026-11-17, with a stand-in Cplex class whose populate returns an empty pool) calculateMCS(model, 10, 2, 'printLevel', 0) on the model above leaves tmp.mat (mcs = [], mcs_time 4 x 2) in the current folder; lines 305 and 521 save it after every populate round, overwriting a file of that name, and never remove it
- **Expected**: no undocumented file in the user's current folder
- **Source lines**: 305, 521
- **Documented in**: `test/verifiedTests/analysis/testGeneMCS/testCalculateMCS.m`

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

- **Severity**: wrong-result
- **Trigger**: source sheet A (g1 = 1, g2 = 5, g3 = 3) and target sheet with the same genes in the order g3 = 3, g2 = 4, g1 = 2, or a target sheet with only g1 = 2
- **Observed**: reordered target: {'g1', 1, 3, 'Up'; 'g2', 5, 4, 'Down'; 'g3', 3, 2, 'Down'} (the target values of g3 and g1 are swapped); shorter target: MATLAB:badsubscript is caught and displayed and {'g1', 1, 2, 'Up'; 'g2', 5, [], []} is returned
- **Expected**: g1 compared with 2 and g3 with 3; a missing gene reported or rejected. The function assumes both sheets list the same genes in the same order; OUTPUTS documents each row as "geneId, source dataset expression value, target dataset expression value" and the header puts no ordering requirement on the sheets, so a target sheet in another order is a documented input that silently returns another gene's value (severity audit T009a)
- **Source lines**: 30-32
- **Documented in**: `test/verifiedTests/analysis/testFindUpDownRegulatedGenes/testFindUpDownRegulatedGenes.m`

### `src/analysis/multiSpecies/SteadyCom/subroutines/SteadyComSubroutines.m`

#### 'initialize' reads modelCom.indCom before building it from infoCom

- **Severity**: error
- **Trigger**: SteadyComSubroutines('initialize', modelCom) with modelCom having S, b, c, lb, ub, rxns, mets and infoCom (fields spBm, EXcom, EXsp, spAbbr, rxnSps, metSps) but no indCom, e.g. a one-reaction model with infoCom.spBm = {'r'}
- **Observed**: 'Unrecognized field name "indCom".' at line 72 (MATLAB R2025a): lines 72-73 use modelCom.indCom before the test of line 76, so lines 76-83 never build it
- **Expected**: indCom is derived from infoCom (line 82), as the header says (at least one of infoCom and indCom is needed)
- **Source lines**: 72-73, 76-83
- **Documented in**: `test/verifiedTests/analysis/testSteadyCom/testSteadyComSubroutines.m`

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

- **Severity**: wrong-result
- **Trigger**: a row of sampleData whose values sum below 1e-4, for example {'EX_glc_D[fe]', -1, -2, -3, -4, -5, -6}
- **Observed**: the row is removed (line 63 tests sum(...) < 0.0001) and no plot is drawn; likewise a group whose values sum to zero is overwritten with 1e-7 (lines 188-189)
- **Expected**: only features that are all zero removed (code comment "remove fluxes that are all zeros"); data of any sign plotted: the header admits any "input data to analyze (e.g., fluxes)" as sampleData, so a feature with negative fluxes is a documented input whose documented result (a plot) is not produced (severity audit T009a)
- **Source lines**: 63, 188-189
- **Documented in**: `test/verifiedTests/analysis/testAdditionalAnalysis/testMakeViolinPlots.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/performStatisticalAnalysis.m`

#### Fecal exchange features never get a metabolite description

- **Severity**: wrong-result
- **Trigger**: the call above; the metabolite ac (Acetate) is in the VMH database
- **Observed**: the Description of EX_ac[fe] is 'NA'. The condition on line 230 includes the header 'Feature' of Statistics(:,1), which never contains '[fe]', so the prefix and suffix are never stripped.
- **Expected**: 'Acetate'. Severity audit 2026-11-15: the code comment "add reaction/metabolite annotations if possible" and the EX_/[fe] stripping (lines 231-232) show the Description column is meant to be filled; the test on line 230 includes the header row so it is always false and every [fe] feature gets NA in the returned Statistics table - a wrong value in a result, not in a message
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

- **Severity**: error
- **Trigger**: the first call above with two samples {'S1'; 'S2'} (cells of S1 and S2 only)
- **Observed**: cobraCmdscale: D must have a zero diagonal (or ones for a similarity matrix). cobraPdist of two samples returns one distance, a scalar that is read as a 1-by-1 matrix; the check on line 125 ("too few individuals to plot") is not reached.
- **Expected**: no PCoA, as for too few individuals, and the flux tables written. Severity audit 2026-11-15: sampNames is documented as "nx1 cell array ... names of individuals" with no minimum, and the comment "catch if there are too few individuals to plot" (line 124) shows few individuals are intended; n = 2 stops with an error in cobraCmdscale (lines 119-120) before that check - a documented input that fails when used
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

- **Severity**: wrong-result
- **Trigger**: parsave(fullfile(tempname, 'x.mat'), struct('a', 1))
- **Observed**: no file is written and no warning or error is raised (the isfield test on line 15 has no else branch)
- **Expected**: per the header ('Saves a data variable (e.g., model)'), the structure is saved; the callers in the toolbox pass only models or cell arrays. Severity audit 2026-11-15: INPUTS document data as "name of variable"; a struct without a rxns field is a documented data variable and is silently not saved (no else branch at line 15)
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

### `src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/retrieveModelStats.m`

#### The size plot is never produced without a stratification file

- **Severity**: wrong-result
- **Trigger**: retrieveModelStats(modelPath, modelList, abunFilePath, 1, '-dpng') with three models microbiota_model_samp_S1..S3 of 2, 3 and 4 reactions (and metabolites) and an abundance table with the columns S1, S2, S3
- **Observed**: no figure is opened and no file MicrobiomeModel_Sizes.png is written (MATLAB R2025a): the condition of line 108, ~numel(unique(data(:,1)))==1 && ..., is parsed as (~numel(...)) == 1 and is false whenever the data has a row, so lines 109-117 never run; modelStats (2, 3, 4 reactions and metabolites; 2, 1, 2 microbes) and summary (mean 3, 3, 1.6667; median 3, 3, 2; min 2, 2, 1; max 4, 4, 2) are returned correctly
- **Expected**: the violin plot of reactions, metabolites and microbes saved in the figForm format unless all values of a column are equal, as the comment of line 107 says
- **Source lines**: 108-117
- **Documented in**: `test/verifiedTests/analysis/testMgPipe/testRetrieveModelStats.m`

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

### `src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/getMultiSpeciesModelId.m`

#### The compartmentalization error never names the species

- **Severity**: cosmetic
- **Trigger**: getMultiSpeciesModelId(modelJoint, {'Org1'; 'Org2A'}) on the two-species model of this test (the second tag matches metabolites but no reaction)
- **Observed**: the message reads 'The model for species %s is not correctly compartmentalized. Check the name tags.' (MATLAB R2025a): error is called with a format specifier but without the argument, so %s is printed literally
- **Expected**: the tag of the species in the message
- **Source lines**: 118
- **Documented in**: `test/verifiedTests/analysis/testMultiSpeciesModelling/testGetMultiSpeciesModelId.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/joinModelsPairwiseFromList.m`

#### Two models whose file names start with the same model name stop the function

- **Severity**: error
- **Trigger**: a modelFolder holding toyA.mat and toyA2.mat, with toyA in modelList
- **Observed**: the search by name prefix returns both files, models{findModID,1} expands to two arguments of contains, and the call stops with "Incorrect number of arguments"
- **Expected**: the file named exactly after the model is used
- **Source lines**: 111, 113-114, 139, 141-142, 157, 159-160
- **Documented in**: `test/verifiedTests/analysis/testMultiSpeciesModelling/testJoinModelsPairwiseFromList.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/printUptakeBoundCom.m`

#### A model without indCom cannot be printed

- **Severity**: limitation
- **Trigger**: printUptakeBoundCom(model) for a model with infoCom but without indCom
- **Observed**: (R2025a, 2026-11-17) "Undefined function 'infoCom2indCom' for input arguments of type 'struct'." at line 37: infoCom2indCom is a local function of src/analysis/multiSpecies/SteadyCom/subroutines/SteadyComSubroutines.m and not on the path. The input is not documented: the header lists both fields as required fields of the model ("model: the community COBRA model, with fields: * .infoCom - struct of community exchange reaction/metabolite names, obtained from getMultiSpeciesModelId * .indCom - struct of the corresponding community exchange indices"), and getMultiSpeciesModelId returns both; only the code (lines 33-37 and the message of line 35) treats either field alone as enough, so the branch is a convenience that never works
- **Expected**: indCom derived from infoCom, as the branch intends
- **Source lines**: 37
- **Documented in**: `test/verifiedTests/analysis/testMultiSpeciesModelling/testPrintUptakeBoundCom.m`

#### A model without infoCom fails after the default abbreviations are built

- **Severity**: limitation
- **Trigger**: printUptakeBoundCom(model) for a model with indCom but without infoCom
- **Observed**: (R2025a, 2026-11-17) 'Unrecognized field name "infoCom".' at line 62 although line 46 builds the default abbreviations Org1, Org2, ... for this case. The input is not documented: the header lists .infoCom and .indCom as required fields of the model (see the entry above)
- **Expected**: the bounds printed with the default abbreviations, from indCom alone
- **Source lines**: 46, 62
- **Documented in**: `test/verifiedTests/analysis/testMultiSpeciesModelling/testPrintUptakeBoundCom.m`

#### Continuation lines of long names are printed as the literal text %30s in the host layout

- **Severity**: cosmetic
- **Trigger**: printUptakeBoundCom(model, true, true) on a model with a host whose community metabolite name has more than 30 characters
- **Observed**: after the first line of the row, each continuation line reads '%30s' (MATLAB R2025a): the format of line 121 starts with '%%', so the text argument is not consumed; the layout without host (line 106) prints the remaining characters
- **Expected**: the remaining characters of the name, 30 per line
- **Source lines**: 121
- **Documented in**: `test/verifiedTests/analysis/testMultiSpeciesModelling/testPrintUptakeBoundCom.m`

### `src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/useDiet.m`

#### A diet with fewer rows than columns stops with an index error

- **Severity**: error
- **Trigger**: useDiet(model, {'EX_a(e)', '-5', '10'}) or useDiet(model, {'EX_a(e)', '-5', '10'; 'EX_b(e)', '-2', '3'}) on a model with the exchanges EX_a(e), EX_b(e), EX_c(e) (createModel); likewise one constraint with two columns
- **Observed**: "Index in position 1 exceeds array bounds. Index must not exceed 1." (two rows: "... must not exceed 2.") at line 54 (MATLAB R2025a): the loop of line 52 runs to length(dietConstraints), the larger dimension of the cell array, so it reads rows the diet does not have; a diet with three rows and three columns is applied correctly (lower bounds -5, -2, -1 and upper bounds 10, 3, 1)
- **Expected**: the bounds of the listed exchanges set, whatever the number of rows
- **Source lines**: 52-54
- **Documented in**: `test/verifiedTests/analysis/testMultiSpeciesModelling/testUseDiet.m`

#### Numeric bounds become NaN

- **Severity**: limitation
- **Trigger**: useDiet(model, {'EX_a(e)', -5; 'EX_b(e)', -2}), bounds given as numbers
- **Observed**: the lower bounds of EX_a(e) and EX_b(e) are NaN (MATLAB R2025a): str2double of a double is NaN; the same bounds as text ('-5', '-2') give -5 and -2
- **Expected**: numeric bounds applied as they are, or rejected with a message
- **Source lines**: 54, 57, 62, 65
- **Documented in**: `test/verifiedTests/analysis/testMultiSpeciesModelling/testUseDiet.m`

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

- **Severity**: error
- **Trigger**: M and s as in the first entry; meta = table((1:10)', [repmat({'a'}, 5, 1); repmat({'b'}, 5, 1)], 'VariableNames', {'V2', 'Group'}, 'RowNames', s'); (text as a cellstr, as readtable returns it by default) called with varOfInterest 'Group'
- **Observed**: MATLAB:math:mustBeNumericCharOrLogical, Invalid data type. Argument must be numeric, char, or logical. (line 162 compares cells with ==); string and categorical variables pass this line
- **Expected**: groups of a text variable are plotted as those of a categorical one. Severity audit 2026-11-15: metadataTable is documented as "metadata for the samples (e.g. sex), with columns = variables (e.g. Sex)" and varOfInterest as a "variable (e.g. Sex or disease status) contained in the metadata"; a text variable as readtable returns it (cellstr) stops at line 162 - a documented input that fails when used
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

- **Severity**: error
- **Trigger**: generatePanDatabase()
- **Observed**: MATLAB:minrhs, Not enough input arguments. (line 18 reads inputDir); generatePanDatabase([]) uses the default 'AGORA2'
- **Expected**: the call without argument uses the default 'AGORA2' given in the header. Severity audit 2026-11-15: INPUT documents "inputDir: directory with the AGORA2 models (default: 'AGORA2')" but the argument cannot be omitted (line 18 reads it) - a documented optional argument that cannot be omitted
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

### `src/analysis/persephone/additionalFunctions/physiologicalConstraintsHMDBbasedTEMP.m`

#### Blood uptake constraints of organs other than the kidney are never applied

- **Severity**: wrong-result
- **Trigger**: physiologicalConstraintsHMDBbasedTEMP(model, IndividualParameters, {}, 'direct', {'glc_D', 4000, 6000}, 'bc') on a model with Liver_EX_glc_D(e)_[bc] (Liver_glc_D[e] <=> glc_D[bc]), parameters as above with liver blood flow 0.27
- **Observed**: the bounds stay at -1000 and 1000 (MATLAB R2025a): line 440 compares the identifier without the '[bc]' suffix with the metabolite 'glc_D[bc]', so X is always empty and the uptake bound of lines 447-457 is never set (the second lookup of line 442 is not used either)
- **Expected**: lb = -(5000/1000) * 868.3 * 60 * 24 / 1000 = -6251.8 mmol/day/person (line 449: the mean of the two concentrations and the liver plasma flow 0.27 * 5360 * (1 - 0.4) ml/min)
- **Source lines**: 440-443
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testPhysiologicalConstraintsHMDBbasedTEMP.m`

#### Measured concentrations are never matched when the data has more than one row

- **Severity**: wrong-result
- **Trigger**: physiologicalConstraintsHMDBbasedTEMP(model, IndividualParameters) (HMDB tables) on a model with the reaction Kidney_EX_glc_D(e)_[bc] (Kidney_glc_D[e] <=> glc_D[bc]); hand-built parameters: male, CardiacOutput 5360 ml/min, Hematocrit 0.4, kidney blood flow fraction 0.19 (glomerular filtration rate 122.2 ml/min)
- **Observed**: lb = -3.5196 and ub = 0 (MATLAB R2025a), the values of the default range MConMin = 0, MConMax = MConDefaultBc = 20 uM (lines 376-378); every kidney, cerebrospinal-fluid and urine exchange gets the default range; in 'direct' mode with InputData {'glc_D', 4000, 6000; 'ala_L', 300, 500} and Biofluid 'bc' no bound changes at all, while the single row {'glc_D', 4000, 6000} does set the kidney bounds. Cause: strcat(metConcDataBc{:,VMHIDCol},'[bc]') (and the CSF, urine and organ variants) expands the cell column into separate arguments, so strcat joins all identifiers into one string ({'a';'b';'c'} gives 'abc[bc]') and ismember never finds a metabolite; the original physiologicalConstraintsHMDBbased.m indexes with parentheses, metConcDataBc(:,VMHIDCol)
- **Expected**: from the HMDB blood range of glc_D (1100-20880 uM): ub = -193.58 and lb = -3674.5 mmol/day/person (the formulas of lines 408 and 433)
- **Source lines**: 374, 440, 513, 603
- **Documented in**: `test/verifiedTests/analysis/testPersephone/testPhysiologicalConstraintsHMDBbasedTEMP.m`

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

- **Severity**: error
- **Trigger**: calculateEPSILON([1 2 3 4; 0 0 1 1], [0; 0], 'unique_epsilon', true)
- **Observed**: error 'Array indices must be positive integers or logical values.' (calculateEPSILON:51): int64(0 * 0.7) = 0 is used as an index
- **Expected**: epsilon = [0; 0] (no reaction is changed); the header documents rxnFBS as an "Array that contains the desired change: Forward, Backward and Unchanged (+1;-1;0)" and 'unique_epsilon' as an option, so an all-zero rxnFBS (no reaction changed) with unique_epsilon true is a documented input that fails when used (severity audit T009a)
- **Source lines**: 51
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

- **Severity**: unusable-option
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

### `src/analysis/rumba/classifyRxns.m`

#### The documented defaults of maxMetConn, maxNumPnts and LoopRxnsToIgnore are not implemented, so these arguments cannot be omitted

- **Severity**: error
- **Trigger**: classifyRxns(completeModel, sampledModel) and every call with fewer than six arguments, e.g. with completeModel = createModel({'r1', 'r2', 'r3'}, {'r1', 'r2', 'r3'}, {' -> A', 'A -> B', 'B -> '}, 'printLevel', 0), sampledModel.rxns = completeModel.rxns, sampledModel.points = [1 1 1; 2 2 2]'
- **Observed**: (R2025a, 2026-11-17) two arguments: "Not enough input arguments." at line 63 (maxMetConn); three, four and five arguments: "Not enough input arguments." at line 85 (LoopRxnsToIgnore). The same call with all six arguments (30, [], 0, {}) returns two scored metabolites. maxNumPnts = [] keeps every point instead of min(points, 500); no default is computed anywhere (only line 48 tests nargin)
- **Expected**: the documented defaults: maxMetConn = 30, maxNumPnts = minimum of the number of points and 500, LoopRxnsToIgnore = reaction loops found by FVA
- **Source lines**: 48-49, 63-64, 85
- **Documented in**: `test/verifiedTests/analysis/testRumba/testClassifyRxns.m`

### `src/analysis/rumba/compareConditions.m`

#### Sample-point count taken from the first metabolite of the first list

- **Severity**: limitation
- **Trigger**: metabolites with different numbers of sample points
- **Observed**: MinNumPts is computed once from the first metabolite of the first list and used for all
- **Expected**: the minimum over all compared metabolites
- **Source lines**: 52
- **Documented in**: `test/verifiedTests/analysis/testRumba/testCompareConditions.m`

### `src/analysis/sampling/ACHR/ACHRSampler.m`

#### The time-limit exit leaves the error log open

- **Severity**: cosmetic
- **Trigger**: any call whose time limit is exceeded before the last point, for example ACHRSampler(model, warmupPoints, 'achr', 1, 3, 2, [], [], -1)
- **Observed**: the function returns at line 200 after saving the points without closing the file ACHRerror.txt opened at line 72; its identifier is still listed by openedFiles after the call (MATLAB R2025a; this test closes it)
- **Expected**: the log closed on every exit, as at line 221
- **Source lines**: 200
- **Documented in**: `test/verifiedTests/analysis/testSampling/testACHRSampler.m`

#### printLevel 0 does not silence the header and the step warnings

- **Severity**: cosmetic
- **Trigger**: ACHRSampler(model, warmupPoints, 'achr', 1, 4, 5, initPoint, 3, 36000, 0, minFlux, maxFlux) (printLevel 0, documented as silent)
- **Observed**: the line 'File #  Point #  Step #  Time  #Time left' (line 80), the progress bar title (line 76) and 'Warning <minStep> <maxStep>' (line 132) are printed whatever printLevel is (MATLAB R2025a)
- **Expected**: no console output with printLevel 0
- **Source lines**: 76, 80, 132
- **Documented in**: `test/verifiedTests/analysis/testSampling/testACHRSampler.m`

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

### `src/analysis/sampling/CHRR/chrrExpSampler.m`

#### A model without metabolites and a reaction of zero width stops in preprocess

- **Severity**: limitation
- **Trigger**: the model above with S = zeros(0, 6), b = zeros(0, 1), mets = cell(0, 1), csense = char(zeros(0, 1)) and lb(1) = ub(1) = 5 (gurobi): chrrExpSampler(box, 5, 10, [1; 0; 0; 0; 0; 0])
- **Observed**: MATLAB R2025a: preprocess prints 'Found 1 degenerate reactions' and stops at its line 173 (P.A = P.A*N) with 'Incorrect dimensions for matrix multiplication.' Line 105 replaces the empty 0 x 6 equality matrix with a 0 x 0 one, so preprocess builds the equality row of the fixed reaction with the wrong number of columns. chrrSampler has the same lines.
- **Expected**: the fixed reaction is added as an equality and the remaining box sampled
- **Source lines**: 105-106
- **Documented in**: `test/verifiedTests/analysis/testSampling/testChrrExpSampler.m`

#### minFlux and maxFlux cannot be requested together with a rounded polytope

- **Severity**: error
- **Trigger**: model = createModel({'R_in'; 'R1'; 'R2'; 'R3'; 'R_outB'; 'R_outC'}, {'in'; 'r1'; 'r2'; 'r3'; 'ob'; 'oc'}, {' -> A'; 'A -> B'; 'A -> C'; 'B -> C'; 'B -> '; 'C -> '}, [], zeros(6, 1), 10 * ones(6, 1)); model.c = full(model.S(1, :))'; [~, P] = chrrExpSampler(model, 5, 10); [s, P2, minFlux, maxFlux] = chrrExpSampler(model, [], 5, model.c, 1, P)
- **Observed**: MATLAB R2025a (gurobi): error 'Output argument "minFlux" (and possibly others) not assigned a value in the execution with "chrrExpSampler" function.' The two outputs are only assigned when the polytope is pre-processed in the call (lines 119-120), although the rounded polytope carries them as fields (.minFlux, .maxFlux). The documented USAGE requests all four outputs.
- **Expected**: the flux minima and maxima stored in roundedPolytope
- **Source lines**: 119-120
- **Documented in**: `test/verifiedTests/analysis/testSampling/testChrrExpSampler.m`

### `src/analysis/sampling/CHRR/chrrSampler.m`

#### minFlux and maxFlux cannot be requested together with a rounded polytope

- **Severity**: error
- **Trigger**: [samples, P, minFlux, maxFlux] = chrrSampler(model, [], 5, [], P) with P the roundedPolytope of a previous call
- **Observed**: MATLAB R2025a: error 'Output argument "minFlux" (and possibly others) not assigned a value in the execution with "chrrSampler" function.' The two outputs are only assigned when the polytope is pre-processed in the call (lines 154-155), although the rounded polytope carries them as fields (.minFlux, .maxFlux). The documented USAGE with a roundedPolytope requests two outputs and works.
- **Expected**: the flux minima and maxima stored in roundedPolytope
- **Source lines**: 65-69
- **Documented in**: `test/verifiedTests/analysis/testSampling/testChrrSampler.m`

### `src/analysis/sampling/compareSampleTraj.m`

#### The documented default of nBins is never set, so a call without nBins fails

- **Severity**: error
- **Trigger**: compareSampleTraj({'r1'}, {[1 2 3; 4 5 6]}, {model}) with model = createModel({'r1','r2'}, {'r1','r2'}, {'A -> B','B ->'}) (nBins omitted, documented default nSamples/25)
- **Observed**: 'Not enough input arguments.' at line 50 (MATLAB R2025a): lines 17-20 assign the default to a variable named bins, and line 50 then reads the unset nBins
- **Expected**: nBins = round(nSamples/25) is used, as the header documents
- **Source lines**: 17-20, 50
- **Documented in**: `test/verifiedTests/analysis/testSampling/testCompareSampleTraj.m`

#### The fallback to the reversed reaction <name>_r never runs

- **Severity**: wrong-result
- **Trigger**: a reaction name that is not in a model whose reversed half <name>_r is: model = createModel({'r1_r','r2'}, {'r1_r','r2'}, {'A -> B','B ->'}, 'printLevel', 0); compareSampleTraj({'r1'}, {[1 2 3; 4 5 6]}, {model}, 5)
- **Observed**: 'Index in position 1 is invalid. Array indices must be positive integers or logical values.' at line 46 (MATLAB R2025a, 2026-11-17): findRxnIDs(model, 'r1') returns 0, not an empty array, for an absent name, so the isempty tests of lines 40 and 55 are never true and 0 is used as an index. A name absent in both forms ({'r1_'} with model.rxns {'r1'; 'r2'}) stops at the same line instead of line 43
- **Expected**: the samples of r1_r plotted with the sign -1 (lines 41, 56-57); for a name absent in both forms, the error 'Reaction does not exist' of line 43
- **Source lines**: 40-45, 55-58
- **Documented in**: `test/verifiedTests/analysis/testSampling/testCompareSampleTraj.m`

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

### `src/analysis/sampling/plotSampleHist.m`

#### A call in which no requested reaction is kept stops with an index error

- **Severity**: error
- **Trigger**: plotSampleHist({'r1'}, {rand(2, 50), rand(2, 50)}, {model1, model2}, 5) with model1 and model2 of the entry above (r1 is held as r1_r in model2); also plotSampleHist({'r1_x'}, {rand(2, 50)}, {model1}, 5) (a name absent from the model)
- **Observed**: (R2025a, 2026-11-17) 'Index exceeds array bounds.' at line 128: line 106 leaves rxnNameList empty (nRxns = 0) and the plotting loop still reads rxnNameList{1}; the empty figure of line 119 is left open
- **Expected**: no error (an empty plot, or the 'Reaction does not exist' warning that line 137 intends for an absent reaction)
- **Source lines**: 106-107, 119-128
- **Documented in**: `test/verifiedTests/analysis/testSampling/testPlotSampleHist.m`

#### A reaction held as its flipped copy <rxn>_r in one model is never plotted

- **Severity**: wrong-result
- **Trigger**: model1 = createModel({'r1', 'r2'}, {'r1', 'r2'}, {'A -> B', 'B -> C'}); modelBack = createModel({'r1', 'r2'}, {'r1', 'r2'}, {'A <=> B', 'B -> C'}) with lb(1) = -10, ub(1) = 0; model2 = convertToIrreversible(modelBack) (reactions r1_r, r2); rng(1); plotSampleHist({'r1', 'r2'}, {rand(2, 50), rand(2, 50)}, {model1, model2}, 5)
- **Observed**: (R2025a, 2026-11-17) one subplot only, 'Flux of r2': lines 91-106 drop every reaction that is absent under its plain name from any model, and findRxnIDs returns 0 (never empty) for an absent name, so the handling code of lines 130-138 and 158-165 that looks up <rxn>_r and plots it with sampleSign = -1 is never reached
- **Expected**: a subplot for r1 as well, with the histogram of -samples of r1_r for model 2, as the handling code of lines 130-138 and 158-165 intends
- **Source lines**: 91-106, 130-138, 158-165
- **Documented in**: `test/verifiedTests/analysis/testSampling/testPlotSampleHist.m`

#### The subplot grid is transposed for perScreen = [nY, nX]

- **Severity**: cosmetic
- **Trigger**: perScreen = [1 2] (documented as [nY, nX], one row of two plots)
- **Observed**: line 171 calls subplot(nX, nY, ...), so the plots are drawn in two rows of one (read from the code; not asserted)
- **Expected**: subplot(nY, nX, ...), one row of two plots
- **Source lines**: 171
- **Documented in**: `test/verifiedTests/analysis/testSampling/testPlotSampleHist.m`

### `src/analysis/sampling/printSampleStats.m`

#### With several samples only the first sample's mode is printed

- **Severity**: wrong-result
- **Trigger**: printSampleStats({[1 1 2; 3 4 4], [5 5 6; 7 8 8]}, struct('rxns', {{'r1'; 'r2'}}), {'A', 'B'})
- **Observed**: header 'Rxn A-mode B-mode A-mean B-mean A-median B-median A-std B-std' (8 value columns) but row 'r1 1.000000 1.333333 5.333333 1.000000 5.000000 0.577350 0.577350' (7 values: B-mode 5 is missing and every later value is shifted one column to the left; MATLAB R2025a). sampleStats.mode(i) (line 56) indexes the reactions x samples matrix linearly, so it is always the first sample's value.
- **Expected**: one mode per sample (sampleStats.mode(i, :)), as for mean, median and std (lines 59, 62, 65), matching the header of lines 36-38
- **Source lines**: 56
- **Documented in**: `test/verifiedTests/analysis/testSampling/testPrintSampleStats.m`

### `src/analysis/sampling/sampleScatterMatrix.m`

#### The documented optional inputs cannot be omitted one at a time

- **Severity**: error
- **Trigger**: model = createModel({'R1'; 'R2'; 'R3'}, {'r1'; 'r2'; 'r3'}, {' -> A'; 'A -> B'; 'B -> '}, [], zeros(3, 1), 10 * ones(3, 1)); rng(1); sample = rand(3, 50); sampleScatterMatrix({'R1', 'R2'}, model, sample, 20) or sampleScatterMatrix({'R1', 'R2'}, model, sample, 20, 12)
- **Observed**: MATLAB R2025a: both calls stop with 'Not enough input arguments.' at line 53, which reads dispRFlag although only nPoints (and fontSize) were given; line 71 reads fontSize in the same way. The calls with 3, 6 and 7 arguments run.
- **Expected**: the omitted optional inputs take their documented defaults (dispRFlag false, fontSize calculated from the number of reactions), as in the call with 3 arguments
- **Source lines**: 53, 71
- **Documented in**: `test/verifiedTests/analysis/testSampling/testSampleScatterMatrix.m`

#### The progress of the two-set layout exceeds 100 %

- **Severity**: cosmetic
- **Trigger**: the model and sample above: sampleScatterMatrix({'R1', 'R2'}, model, sample, 20, [], true, {'R3'})
- **Observed**: MATLAB R2025a: the progress bar printed by showprogress runs to 116 % and 133 %; line 84 computes ((i - 1) * nRxns + j) / (nRxns * nRxns2) with nRxns where the row length is nRxns2
- **Expected**: the progress ends at 100 % ((i - 1) * nRxns2 + j)
- **Source lines**: 84
- **Documented in**: `test/verifiedTests/analysis/testSampling/testSampleScatterMatrix.m`

### `src/analysis/subspaces/checkScaling.m`

#### A model whose lower bounds are all zero stops with an error

- **Severity**: error
- **Trigger**: model = createModel({'R1'; 'R2'; 'R3'}, {'r1'; 'r2'; 'r3'}, {' -> A'; 'A -> B'; 'B -> '}, [], zeros(3, 1), 10 * ones(3, 1)); checkScaling(model, 'fine', 0)
- **Observed**: MATLAB R2025a: 'Operands to the logical AND (&&) and OR (||) operators must be convertible to logical scalar values. Use the ANY or ALL functions to reduce operands to logical scalar values.' at line 305: without a non-zero lower bound minLB (line 219) and ratioL (line 222) are empty. The same model with lb(1) = -5 returns 'double'. A model whose upper bounds are all zero reaches the same test at line 321.
- **Expected**: the scaling summary and recommendation, with the lower-bound ratio left out (an all-irreversible model is a valid model)
- **Source lines**: 219-222, 305, 321
- **Documented in**: `test/verifiedTests/analysis/testSubspaces/testCheckScaling.m`

#### A model with C and d but without b stops with an error

- **Severity**: error
- **Trigger**: the model above with lb(1) = -5, the field b removed and C = [1 0 0], d = 5, dsense = 'L': checkScaling(model, 'fine', 0)
- **Observed**: MATLAB R2025a: 'Unrecognized field name "b".' at line 157; lines 136 and 157 assemble [S, b; C, d] whenever C and d are present, although the header lists b among the optional fields analysed if present
- **Expected**: the constraint matrix assembled from S, C and d with b taken as zero (the COBRA default right-hand side), as for a model without C and d (lines 165-171)
- **Source lines**: 136, 157
- **Documented in**: `test/verifiedTests/analysis/testSubspaces/testCheckScaling.m`

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

### `src/analysis/thermo/directionalityReport/directionalityChangeReport.m`

#### The descriptions of the bydGt0LHS and bydGt0RHS classes state the wrong probability bound

- **Severity**: wrong-result
- **Trigger**: the call above
- **Observed**: MATLAB R2025a: r_forward_to_reversible_DrG0t_spans_zero_probably_forward_StructuredView.txt (class forward2Reversible_bydGt0LHS, reaction R3) begins 'Metabolites which force 1 qualitatively  forward -> quantiatively reversible (DrG0t span the zero line). Forward with probability less than 0.3.'; directionalityStats defines bydGt0LHS as forwardProbability > 0.5 + cumNormProbCutoff and bydGt0RHS as < 0.5 - cumNormProbCutoff, so lines 124 and 132 swap the two bounds
- **Expected**: bydGt0LHS: forward with probability greater than 0.7; bydGt0RHS: less than 0.3
- **Source lines**: 124, 132
- **Documented in**: `test/verifiedTests/analysis/testThermo/testDirectionalityChangeReport.m`

#### Two pairs of classes are written to the same file, so one class of each pair is lost

- **Severity**: wrong-result
- **Trigger**: model = createModel({'R1'; 'R2'; 'R3'}, {'one'; 'two'; 'three'}, {'A[c] -> B[c]'; 'B[c] -> C[c]'; 'C[c] -> A[c]'}, [], zeros(3, 1), 10 * ones(3, 1)) with gasConstant = 8.3144621e-3, T = 298.15, DrGt0Min = [0; -4; -6], DrGt0Max = [0; -4; 2], DrGtMin = [-3; -9; -10], DrGtMax = [3; 1; 5], DfGt0 = [-10; -20; -30], DfG0_Uncertainty = [1; 2; 3], concMin = 1e-5 * ones(3, 1), concMax = 1e-2 * ones(3, 1); directions with every documented field false(3, 1) except forward2Reversible = true(3, 1), forward2Reversible_byConc_zero_fixed_DrG0 = [1; 0; 0], forward2Reversible_byConc_negative_fixed_DrG0 = [0; 1; 0], forward2Reversible_bydGt0 = forward2Reversible_bydGt0LHS = [0; 0; 1]; in an empty folder: directionalityChangeReport(model, directions, 0.2, 0, 'r_')
- **Observed**: MATLAB R2025a: 30 files for the 17 classes (34 expected); r_forward_to_reversible_negative_exact_DrG0t.txt lists only R2, R1 (the zero fixed DrGt0 class) is lost, and r_forward_to_reversible_DrG0t_spans_zero_possibly_reversible.txt lists no reaction although R3 is in forward2Reversible_bydGt0 (it is overwritten by the empty bydGt0Mid class): lines 138 and 142, and lines 121 and 129, give the same file name
- **Expected**: one pair of files per class: R1 in the zero fixed DrGt0 files and R3 in the files of forward2Reversible_bydGt0
- **Source lines**: 121, 129, 138, 142
- **Documented in**: `test/verifiedTests/analysis/testThermo/testDirectionalityChangeReport.m`

### `src/analysis/thermo/directionalityReport/directionalityStats.m`

#### The printed Reverse -> Reverse count is the number of reverse -> reversible reactions

- **Severity**: wrong-result
- **Trigger**: three internal reactions, R1 forward in the reconstruction and forward by thermodynamics, R2 reverse and reversible, R3 reversible and uncertain: model.S = [1 -1 0; 0 1 -1] (createModel for ' -> A', 'A -> B', 'B -> '); lb = [0; -10; -10], ub = [10; 0; 10], lb_reconThermo = lb, ub_reconThermo = ub, SIntRxnBool = true(3, 1), DrGtMin = [-20; -5; -3], DrGtMax = [-10; 5; 4], DrGt0Min = [-15; -1; -2], DrGt0Max = [-12; 1; 2]; directions.forwardProbability = [1; 0.5; 0.6], forwardRecon = [1; 0; 0], reverseRecon = [0; 1; 0], reversibleRecon = [0; 0; 1], forwardThermo = [1; 0; 0], reverseThermo = [0; 0; 0], reversibleThermo = [0; 1; 0], uncertainThermo = [0; 0; 1] (logical); directionalityStats(model, directions, 0.2, 1)
- **Observed**: MATLAB R2025a: the report prints '1 Reverse -> Reverse' and '1 Reverse -> Reversible', while the returned directions.reverse2Reverse has 0 and directions.reverse2Reversible 1 true entry: line 206 prints nnz(reverse2Reversible) under the label Reverse -> Reverse
- **Expected**: '0 Reverse -> Reverse', the count nnz(reverse2Reverse)
- **Source lines**: 206
- **Documented in**: `test/verifiedTests/analysis/testThermo/testDirectionalityStats.m`

#### The reverse -> uncertain count is labelled Reversible -> Uncertain

- **Severity**: cosmetic
- **Trigger**: the call above
- **Observed**: MATLAB R2025a: the last line of the Qualitative vs Quantitative block reads '0 Reversible -> Uncertain' (reverse2Uncertain), repeating the label of the reversible2Uncertain line printed above it with 1
- **Expected**: the label Reverse -> Uncertain
- **Source lines**: 209
- **Documented in**: `test/verifiedTests/analysis/testThermo/testDirectionalityStats.m`

### `src/analysis/thermo/directionalityReport/directionalityStatsFigures.m`

#### The forward -> reversible by standard Gibbs energy chart counts every reaction twice and doubles the percentage of its title

- **Severity**: wrong-result
- **Trigger**: directions from directionalityStats for a 2-reaction model (S = [-1 0; 1 -1], DrGtMin = [-5; -5], DrGtMax = [5; 5], DrGt0Min = [-1; -1], DrGt0Max = [1; 1], forwardProbability = [0.5; 0.5], reaction 1 forwardRecon, both reversibleThermo, cumNormProbCutoff 0.2), then directionalityStatsFigures(directions, name, 0)
- **Observed**: (R2025a, 2026-11-17) directionalityStats gives forward2Reversible_bydGt0 = [true; false] and forward2Reversible_bydGt0Mid = [true; false]; the chart title reads "(100 % of all reactions)" for one forward -> reversible reaction of two, and the pie shows that reaction in two slices: the bydGt0 vector is drawn beside its own subsets LHS, Mid and RHS (lines 126-129), which partition it, and the sum of the four counts is divided by the number of reactions (line 141)
- **Expected**: "(50 % of all reactions)" and each reaction in one slice: the share of distinct reactions, with bydGt0 not added to its subsets
- **Source lines**: 126-141
- **Documented in**: `test/verifiedTests/analysis/testThermo/testDirectionalityStatsFigures.m`

#### The title of the standard Gibbs energy chart names the formation energy

- **Severity**: cosmetic
- **Trigger**: any call with a non-empty forward2Reversible_bydGt0 (the trigger above)
- **Observed**: (R2025a, 2026-11-17) title "Forward -> Reversible (by \Delta_{f}G^{\primem}_0)" while the slices are labelled with the reaction energy \Delta_{r}G^{\primem}_0 and the vectors are built from DrGtMin and DrGtMax
- **Expected**: the reaction Gibbs energy \Delta_{r} in the title
- **Source lines**: 140
- **Documented in**: `test/verifiedTests/analysis/testThermo/testDirectionalityStatsFigures.m`

### `src/analysis/thermo/directionalityReport/forwardProbablyReverseFigures.m`

#### The structure array model.rxn is required but not documented

- **Severity**: limitation
- **Trigger**: the model above without the field rxn: forwardProbablyReverseFigures(model, false)
- **Observed**: MATLAB R2025a: 'Unrecognized field name "rxn".' at line 164; lines 164 and 169 label the reactions with model.rxn(n).officialName and model.rxn(n).equation, which the header does not list (the header lists only S and the energy fields)
- **Expected**: the header lists model.rxn, or the labels come from rxnNames and the formulas
- **Source lines**: 164, 169
- **Documented in**: `test/verifiedTests/analysis/testThermo/testForwardProbablyReverseFigures.m`

#### miliMolarStandard true stops with an error

- **Severity**: unusable-option
- **Trigger**: model.S = [1 -1 0; 0 1 -1] (createModel for ' -> A', 'A -> B', 'B -> ', reactions R1-R3), DrGt0Min = [-5; -1; -5], DrGt0Max = [-5; 3; 1], DrGt0Mean = (DrGt0Min + DrGt0Max) / 2, DrGtMin = [-10; -4; -8], DrGtMax = [2; 6; 4], DrGtMean = (DrGtMin + DrGtMax) / 2, dGt0Min = DrGt0Min, dGt0Max = DrGt0Max, dGtMin = DrGtMin, dGtMax = DrGtMax, directions.forwardReversible_bydGt0RHS = [0; 1; 0], .forwardReversible_byConc_positive_fixed_DrG0 = [0; 0; 0], .forwardReversible_byConc_positive_uncertain_DrG0 = [0; 0; 1] (logical), .forwardProbability = [NaN; 0.1; 0.05], rxn = struct('officialName', {'one', 'two', 'three'}, 'equation', {'A -> B', 'B -> C', 'C -> D'}): forwardProbablyReverseFigures(model, true)
- **Observed**: MATLAB R2025a: the figure is drawn and saved, then the call stops with 'Unrecognized function or variable 'dGt0Min'.' at line 181: lines 180-183 restore model.dGt0Min and dGt0Max from variables that are only assigned in the disabled horizontal-bar block (lines 190-197, horizontal = 0). The same call with false runs.
- **Expected**: the call with miliMolarStandard = true completes (the vertical figure changes nothing that needs restoring)
- **Source lines**: 180-183
- **Documented in**: `test/verifiedTests/analysis/testThermo/testForwardProbablyReverseFigures.m`

### `src/analysis/thermo/directionalityReport/forwardReversibleFigures.m`

#### Reactions with a fixed DrGt0 stop the figures with an error

- **Severity**: error
- **Trigger**: model.S = [1 -1 0; 0 1 -1] (createModel for ' -> A', 'A -> B', 'B -> ', reactions R1-R3), SIntRxnBool = true(3, 1), DrGt0 = [-5; 1; -2], DrG0_Uncertainty = [0; 2; 3], DrGt0Min = [-5; -1; -5], DrGt0Max = [-5; 3; 1], DrGtMin = [-10; -4; -8], DrGtMax = [2; 6; 4], DrGtMean = (DrGtMin + DrGtMax) / 2; directions with the nine forward2Reversible* fields false(3, 1) except forward2Reversible = true(3, 1), forward2Reversible_bydGt0 = forward2Reversible_bydGt0Mid = [0; 1; 1] and forward2Reversible_byConc_negative_fixed_DrG0 = [1; 0; 0]: forwardReversibleFigures(model, directions); likewise with forward2Reversible_byConc_positive_fixed_DrG0 = [1; 0; 0] instead
- **Observed**: MATLAB R2025a: 'Unrecognized function or variable 'P'.' at line 212 (negative fixed DrGt0) and 'Undefined function 'P' for input arguments of type 'logical'.' at line 327 (positive fixed DrGt0). P is never assigned: the forward probability is held in forwardProbability (lines 84-93), which the other figures use; lines 212, 230 and 283 (figure of the negative fixed class) and 327 and 381 (positive fixed class) use P.
- **Expected**: the figures of the two fixed-DrGt0 classes drawn with forwardProbability
- **Source lines**: 212, 230, 283, 327, 381
- **Documented in**: `test/verifiedTests/analysis/testThermo/testForwardReversibleFigures.m`

#### The warning about extra NaN probabilities is garbled

- **Severity**: cosmetic
- **Trigger**: the call above
- **Observed**: MATLAB R2025a: the warning of line 140 is shown as 'Extra category of NaN P(' preceded by the warning 'Escaped character '\D' is not valid. See 'doc sprintf' for supported special characters.': with an identifier, warning treats the TeX text \Delta_{r}G^{\primem} as a format. Line 638 has the same text.
- **Expected**: the full message (the backslashes escaped or the text passed as an argument of a %s format)
- **Source lines**: 140, 638
- **Documented in**: `test/verifiedTests/analysis/testThermo/testForwardReversibleFigures.m`

### `src/analysis/thermo/directionalityReport/forwardTransportQuantReverseFigures.m`

#### A model without a qualifying transport reaction stops with an error

- **Severity**: error
- **Trigger**: model = createModel({'glc_abc'; 'ACt2r'; 'R3'; 'Bt'; 'Ht'}, {'glc abc'; 'acetate symport'; 'internal'; 'B transport'; 'proton'}, {'A[e] -> A[c]'; 'A[e] + h[e] -> A[c] + h[c]'; 'A[c] -> B[c]'; 'B[c] -> B[e]'; 'h[e] -> h[c]'}, [], zeros(5, 1), 10 * ones(5, 1)) with transportRxnBool = [1; 1; 0; 1; 1], DrGt0Min = [-10; -3; -5; -2; 2], DrGt0Max = [4; -3; 1; 6; 2], DrGt0Mean = (DrGt0Min + DrGt0Max) / 2, DrGtMin = [-20; -12; -9; -8; -6], DrGtMax = [9; 5; 4; 12; 10], DrGtMean = (DrGtMin + DrGtMax) / 2, directions.forwardProbability = [0.8; NaN; 0.6; 0.4; NaN] and directions.forwardReversible = false(5, 1): forwardTransportQuantReverseFigures(model)
- **Observed**: MATLAB R2025a: "Error setting property 'BaseValue' of class 'Bar': Value not a numeric scalar" from barh at line 126: with no selected reaction minX (line 119) is empty; read from the code, line 185 (max of the never assigned textLen) would stop next. With directions.forwardReversible = true(5, 1) the same model draws the figure with the three selected reactions (ACt2r, glc_abc, Ht).
- **Expected**: an empty figure, or no figure, when no qualitatively forward transport reaction is quantitatively reversible (a valid model)
- **Source lines**: 119-126, 185
- **Documented in**: `test/verifiedTests/analysis/testThermo/testForwardTransportQuantReverseFigures.m`

#### The fields transportRxnBool and directions.forwardProbability are required but not documented

- **Severity**: limitation
- **Trigger**: the model above without transportRxnBool (or without directions.forwardProbability)
- **Observed**: read from the code: line 38 reads model.transportRxnBool and line 67 directions.forwardProbability, neither listed under INPUT; the header lists DrdGtMin, used only in the disabled branch of line 53
- **Expected**: the header lists the fields the function reads
- **Source lines**: 38, 67
- **Documented in**: `test/verifiedTests/analysis/testThermo/testForwardTransportQuantReverseFigures.m`

### `src/analysis/thermo/directionalityReport/plotFeasibleReactionEnergyRanges.m`

#### Every call fails when the error bars are adjusted

- **Severity**: error
- **Trigger**: any call, e.g. plotFeasibleReactionEnergyRanges(modelT) with modelT.rxns = {'r1'; 'r2'; 'r3'}, modelT.DrGtMin = [-10; -50; 5], modelT.DrGtMax = [10; -20; 30] (also with rxns as a row)
- **Observed**: "Index exceeds array bounds." at line 50 (MATLAB R2025a): get(errorbar1, 'Children') returns an empty array for an ErrorBar object, so hE_c(2) does not exist; the same code follows at lines 63-69
- **Expected**: the documented figure of the feasible reaction energy ranges
- **Source lines**: 49-55, 63-69
- **Documented in**: `test/verifiedTests/analysis/testThermo/testPlotFeasibleReactionEnergyRanges.m`

#### Only the first reaction is plotted for the documented n x 1 rxns

- **Severity**: wrong-result
- **Trigger**: modelT.rxns as the documented `n x 1` cell array with n > 1, e.g. the input above
- **Observed**: line 16 sets nRxn = size(modelT.rxns, 2), which is 1 for a column, so the loop of lines 23-27 reads only reaction 1 (read from the code; in MATLAB R2025a the call stops at line 50 first, see the defect above)
- **Expected**: one error bar per reaction, nRxn = n
- **Source lines**: 16
- **Documented in**: `test/verifiedTests/analysis/testThermo/testPlotFeasibleReactionEnergyRanges.m`

### `src/analysis/thermo/directionalityReport/singleMetaboliteThermoFigure.m`

#### Every call fails on the undefined variable directions

- **Severity**: error
- **Trigger**: any call, e.g. singleMetaboliteThermoFigure(model, false, 'a') with model.S = [-1 0; 1 -1], dGt0Min = [-1; -2], dGt0Max = [1; 2], dGtMin = [-3; -4], dGtMax = [3; 4]
- **Observed**: "Unable to resolve the name 'directions.ChangeForwardReversibleBool_dGfGC'." at line 34 (MATLAB R2025a): directions is neither an input nor assigned in the function
- **Expected**: the documented figure of the reactions involving metAbbr
- **Source lines**: 34-38
- **Documented in**: `test/verifiedTests/analysis/testThermo/testSingleMetaboliteThermoFigure.m`

#### The metabolite argument metAbbr is never read

- **Severity**: unusable-option
- **Trigger**: any value of metAbbr, e.g. singleMetaboliteThermoFigure(model, false, 'a')
- **Observed**: metAbbr appears only in the signature (line 1); the reactions are selected by the fields of directions, not by the metabolite (read from the code)
- **Expected**: the figure restricted to the reactions involving the metabolite given by the abbreviation, as the description says
- **Source lines**: 1
- **Documented in**: `test/verifiedTests/analysis/testThermo/testSingleMetaboliteThermoFigure.m`

### `src/analysis/thermo/directionalityReport/standardGibbsFormationEnergyStats.m`

#### The documented figures option always fails in pie

- **Severity**: unusable-option
- **Trigger**: standardGibbsFormationEnergyStats(modelT, 1) with modelT.S = [-1 0; 1 -1; 0 1; 0 1], mets {'a[c]'; 'b[c]'; 'c[c]'; 'd[e]'} and dGft0Source 'Keq', 'GC', 'GC', 'Keq'
- **Observed**: "Text labels must be a string or a cell array of character vectors." raised by pie from line 50 (MATLAB R2025a): each label is itself a cell array
- **Expected**: the pie chart saved as dfG0provinencePieChart.fig
- **Source lines**: 50-54
- **Documented in**: `test/verifiedTests/analysis/testThermo/testStandardGibbsFormationEnergyStats.m`

#### The returned counts are offset by eps

- **Severity**: wrong-result
- **Trigger**: standardGibbsFormationEnergyStats(modelT, 0) with the model above and dGft0Source 'Keq', 'GC', NaN, 'Keq'
- **Observed**: nKeq = 2, nGC = 1.000000000000000222, nNone = 1.000000000000000222 (nGC == 1 is false); with no NaN source nNone = eps (2.2204e-16) instead of 0 (MATLAB R2025a): lines 24-26 start every count at eps
- **Expected**: integer counts, as documented ("number of metabolites"), 0 when none
- **Source lines**: 24-26
- **Documented in**: `test/verifiedTests/analysis/testThermo/testStandardGibbsFormationEnergyStats.m`

### `src/analysis/thermo/directionalityReport/writeReactionListThermo.m`

#### No arrow for an irreversible exchange reaction that has a product

- **Severity**: wrong-result
- **Trigger**: writeReactionListThermo(model, 'out.txt') with a reaction 'EX_a' (or 'Exch_a') whose column of S has a positive entry and lb >= 0, e.g. S(:, 2) = [1; 0; 0], lb = 0, ub = 5
- **Observed**: the line "2<TAB>EX_a<TAB>name 2<TAB>1 a<TAB>0 <TAB>5 <TAB>" (MATLAB R2025a): the exchange branch of line 51 prints ' <==> ' only when there is no product (line 54) and nothing otherwise, so the equation has no arrow
- **Expected**: an arrow between the two sides (' --> ' as for other irreversible reactions, line 58)
- **Source lines**: 51-56
- **Documented in**: `test/verifiedTests/analysis/testThermo/testWriteReactionListThermo.m`

#### Non-integer stoichiometric coefficients are printed in exponent form

- **Severity**: cosmetic
- **Trigger**: a reaction with a coefficient 0.5, e.g. S(:, 5) = [-0.5; 0; 1]
- **Observed**: "5.000000e-01 a --> 1 c" (MATLAB R2025a): the format '%d' of lines 41 and 62 falls back to %e for non-integers
- **Expected**: "0.5 a --> 1 c"
- **Source lines**: 41, 62
- **Documented in**: `test/verifiedTests/analysis/testThermo/testWriteReactionListThermo.m`

### `src/analysis/thermo/experimentalData/alberty2006/adjustBaselinesInAlberty2006.m`

#### The reduced glutathione energies are halved together with the baseline

- **Severity**: wrong-result
- **Trigger**: an Alberty2006 entry glutathionered (with glutathioneox and the computed entry gthox)
- **Observed**: every species energy of glutathionered becomes (dfG0 + gc)/2, where gc is the group-contribution energy of the oxidized basic species, and its hydrogen numbers are shifted by the full hydrogen adjustment of the oxidized dimer; the tabulated energy of the reduced form relative to the oxidized form is halved
- **Expected**: dfG0 + gc/2 (and half the hydrogen adjustment): one reduced glutathione carries half the baseline of the dimer (GSSG + 2 e- = 2 GSH), while its tabulated energy keeps its value
- **Source lines**: 173, 175
- **Documented in**: `test/verifiedTests/analysis/testThermo/testAdjustBaselinesInAlberty2006.m`

### `src/analysis/thermo/experimentalData/readMetRxnBoundsFiles.m`

#### Omitting the optional printLevel fails when a metabolite file is read

- **Severity**: error
- **Trigger**: readMetRxnBoundsFiles(model, 1, 1, 1e-5, 0.02, 'met.txt') with model.S = [-1 0; 1 -1], mets {'a[c]'; 'b[c]'}, rxns {'R1'; 'R2'} and met.txt holding the line "a[c]<TAB>0.001<TAB>0.01"
- **Observed**: "Not enough input arguments." at line 87 (MATLAB R2025a): printLevel has no default although metBoundsFile and rxnBoundsFile get one (lines 45-50)
- **Expected**: the bounds read silently, printLevel documented as an OPTIONAL INPUT
- **Source lines**: 87
- **Documented in**: `test/verifiedTests/analysis/testThermo/testReadMetRxnBoundsFiles.m`

#### The concMax error message says Minimum

- **Severity**: cosmetic
- **Trigger**: a model whose concMax holds Inf, with setDefaultConc = 0
- **Observed**: line 136 raises "<met> :Minimum concentration bound is not finite" for a non-finite maximum (read from the code)
- **Expected**: "... :Maximum concentration bound is not finite"
- **Source lines**: 136
- **Documented in**: `test/verifiedTests/analysis/testThermo/testReadMetRxnBoundsFiles.m`

### `src/analysis/thermo/experimentalDesign/priorityKeqMeasurement.m`

#### A model whose metabolites all have Keq data fails

- **Severity**: error
- **Trigger**: the model above with dGft0Source 'Keq' for every metabolite
- **Observed**: "Unrecognized function or variable 'measuredMetRxnRatio'." at line 172 (MATLAB R2025a): the while loop of line 66 is skipped, so measuredMetRxnRatio and priorityKeq are never assigned
- **Expected**: nothing left to measure (empty priorityKeq, numNonKeqMet = 0)
- **Source lines**: 66, 172
- **Documented in**: `test/verifiedTests/analysis/testThermo/testPriorityKeqMeasurement.m`

#### The plot fails on an invalid line style, so no call returns

- **Severity**: error
- **Trigger**: priorityKeqMeasurement(modelT) with modelT.S = [-1 0 0; 1 -1 0; 0 1 0; -1 0 1], mets {'a[c]'; 'b[c]'; 'c[c]'; 'h[c]'}, rxns {'R1'; 'R2'; 'EX'}, SIntRxnBool = [true; true; false], dGft0Source 'Keq' for a[c] and 'GC' for the others, officialName and equation set
- **Observed**: the two rounds are printed, then "Error setting property 'LineStyle' of class 'Line': '.' is not a valid value." at line 173 (MATLAB R2025a); line 174 sets '*' in the same way
- **Expected**: the outputs priorityKeq and numNonKeqMet (here [2 1 0]) and the figure
- **Source lines**: 173-174
- **Documented in**: `test/verifiedTests/analysis/testThermo/testPriorityKeqMeasurement.m`

### `src/analysis/thermo/formulae/checkFormulae.m`

#### Elements other than C, H, O, P, S, K, Na and N are ignored

- **Severity**: limitation
- **Trigger**: two formulas that differ only in another element, for example C6H12O6Cl and C6H12O6
- **Observed**: the function returns 1 (equal)
- **Expected**: 0 (different)
- **Source lines**: 31-45
- **Documented in**: `test/verifiedTests/analysis/testThermo/testCheckFormulae.m`

### `src/analysis/thermo/formulae/compareMetaboliteFormulae.m`

#### The identifier and the reconstruction formula are not tab separated

- **Severity**: wrong-result
- **Trigger**: compareMetaboliteFormulae(modelT) with modelT.S = [-1; 1], mets {'a[c]'; 'averyveryverylongmetaboliteid[c]'}, metFormulas {'C6H12O6'; 'H2O'} and formulaMarvin 'C6H12O6', 'H2O'
- **Observed**: the lines "                a[c]             C6H12O6<TAB>             C6H12O6" and "averyveryverylongmetaboliteid[c]                 H2O<TAB>                 H2O" (MATLAB R2025a): the format '%20s%20s\t%20s\n' of line 21 has a tab only between the second and third field, so splitting a line on tabs gives two fields, not three
- **Expected**: a tab delimited file with the three columns, as the description says
- **Source lines**: 21
- **Documented in**: `test/verifiedTests/analysis/testThermo/testCompareMetaboliteFormulae.m`

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

### `src/analysis/thermo/groupContribution/jankowski/createGroupIncidenceMatrix_jankowski.m`

#### The documented arguments gcmOutputFile, gcmMetList and jankowskiGroupData are ignored

- **Severity**: unusable-option
- **Trigger**: createGroupIncidenceMatrix_jankowski(model, 'gcm.txt', {'a'; 'b'; 'c'}, groupData) with model.mets = {'a'; 'b'; 'c'; 'd'}, groupData.groups = {'G1'; 'G2'; 'G3'} and gcm.txt a valid output file
- **Observed**: "Unrecognized field name "jankowskiGroupData"." at line 26 (MATLAB R2025a); with model.gcmOutputFile, model.gcmMetList and model.jankowskiGroupData set, a call with the arguments 'nonexistent.txt', {} and an empty group list returns the matrix of the model fields: lines 26-28 read the model fields only
- **Expected**: the matrix built from the file, metabolite list and groups passed as arguments, as the INPUTS section documents them
- **Source lines**: 26-28
- **Documented in**: `test/verifiedTests/analysis/testThermo/testCreateGroupIncidenceMatrix_jankowski.m`

#### The function line names createGroupIncidenceMatrix_old, not the file name

- **Severity**: cosmetic
- **Trigger**: any use; the Code Analyzer reports the mismatch for the file
- **Observed**: line 1 declares "function G = createGroupIncidenceMatrix_old(...)" in createGroupIncidenceMatrix_jankowski.m; MATLAB calls the function by its file name, so calls work (recorded 2026-11-20 when the USAGE line was corrected to the file name by feature 20261120-151023-doc-matches-code)
- **Expected**: the function line names the file, createGroupIncidenceMatrix_jankowski
- **Source lines**: 1
- **Documented in**: `test/verifiedTests/analysis/testThermo/testCreateGroupIncidenceMatrix_jankowski.m`

### `src/analysis/thermo/groupContribution/jankowski/plotConcVSdGft0GroupContUncertainty.m`

#### An intermediate fraction is echoed to the command window

- **Severity**: cosmetic
- **Trigger**: any call, e.g. the model of the first section below
- **Observed**: "fraction2q = 0.5000" printed before the documented message (MATLAB R2025a): line 54 has no semicolon
- **Expected**: only the line "Fraction of metabolites where GC uncertainty is more significant: ..."
- **Source lines**: 54
- **Documented in**: `test/verifiedTests/analysis/testThermo/testPlotConcVSdGft0GroupContUncertainty.m`

### `src/analysis/thermo/groupContribution/jankowski/webCGMtoTabDelimitedFile.m`

#### A metabolite without group contribution data stops the call or is reported under another name

- **Severity**: error
- **Trigger**: a NONE line for the first mapped metabolite: model.S = zeros(2, 1), model.mets = {'a[c]'; 'b[c]'}, model.metFormulas = {'C2H4'; 'C3H6'}, a file with the lines 'header', 'NONE;no groups', '-10.5;1.2;g1|g2|-1;0;C2H3', and webCGMtoTabDelimitedFile(model, 'web.txt', {'a[c]'; 'b[c]'})
- **Observed**: MATLAB R2025a, 2026-11-16: "Unrecognized function or variable 'metAbbr'." (MATLAB:UndefinedFunction) at line 136; metAbbr is assigned only at line 138, in the other branch. With the two data lines swapped (NONE second) the call ends and line 136 prints "a[c]<tab>;no groups", the identifier of the previous metabolite instead of b[c]
- **Expected**: the metabolite without data is left out of the output file and its own identifier is printed with the reason, as the comments at lines 85 and 134-135 say
- **Source lines**: 136
- **Documented in**: `test/verifiedTests/analysis/testThermo/testWebCGMtoTabDelimitedFile.m`

### `src/analysis/thermo/inchi/addInchiToModel.m`

#### The method 'mol' stops with Too many input arguments

- **Severity**: unusable-option
- **Trigger**: addInchiToModel(model, molFileDir, 'mol', 0) with model.mets = {'a[c]'; 'b[c]'} and an empty folder molFileDir
- **Observed**: MATLAB R2025a, 2026-11-16: "Too many input arguments." (MATLAB:TooManyInputs) at line 64. The createInChIStruct on the MATLAB path is src/analysis/thermo/inchi/old/createInChIStruct.m with the signature inchiStruct = createInChIStruct(mets, sdfFileName); the form with three inputs and two outputs called at line 64 exists only in src/analysis/thermo/inchi/new, which initCobraToolbox removes from the path
- **Expected**: model.inchi and model.molBool built from the mol files in molFileDir, as the help text says for the method 'mol'
- **Source lines**: 64
- **Documented in**: `test/verifiedTests/analysis/testThermo/testAddInchiToModel.m`

### `src/analysis/thermo/inchi/getMolecularWeight.m`

#### Hydrogens are lost for an InChI whose formula starts with H

- **Severity**: wrong-result
- **Trigger**: an InChI whose formula layer begins with hydrogen, for example water, InChI=1S/H2O/h1H2
- **Observed**: the formula returned by getFormulaAndChargeFromInChI is O and the hydrogen count is returned separately, but only the formula is used, so water gets a molecular weight of 16 and 0 hydrogens
- **Expected**: a molecular weight of 18 and 2 hydrogens for water
- **Source lines**: 41-61
- **Documented in**: `test/verifiedTests/analysis/testThermo/testGetMolecularWeight.m`

### `src/analysis/thermo/molFiles/molFilesToCDFfile.m`

#### The share of metabolites without mol files is printed as a fraction labelled percentage

- **Severity**: cosmetic
- **Trigger**: model.mets = {'a[c]'; 'b[c]'; 'c[c]'; 'd[c]'} with only a.mol in the current folder, molFilesToCDFfile(model, 'x')
- **Observed**: MATLAB R2025a, 2026-11-16: "Percentage of metabolites without mol files: 0.75" (num2str(noMolFileCount/nMet)); the returned list and the .cdf file are correct, so no input is skipped and the console text is not asserted
- **Expected**: "Percentage of metabolites without mol files: 75" (or the value labelled as a fraction), as mol2sdf prints "75.0%"
- **Source lines**: 77
- **Documented in**: `test/verifiedTests/analysis/testThermo/testMolFilesToCDFfile.m`

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

### `src/analysis/thermo/protons/moleFractionStats.m`

#### Fewer than two cytoplasmic reactants with a spread distribution stop the call

- **Severity**: error
- **Trigger**: modelT.S = sparse([1 0; 0 1; 1 1]), modelT.mets = {'a[c]'; 'b[c]'; 'c[e]'}, modelT.metNames = {'A'; 'B'; 'C'} and modelT.mf = {[0.5; 0.5]; [0.0005; 0.9995]; 1} (one [c] reactant whose largest mole fraction is below 0.95), or modelT.mf = {1; 1; 1} (none)
- **Observed**: MATLAB R2025a, 2026-11-16: with one such reactant "Limits must be a 2-element vector of increasing numeric values." from ylim([0.5 0.5]) at line 117; with none "Unrecognized function or variable 'metInd'." at line 115 (metInd is assigned only inside the selection of line 90). With mf = {[0.5; 0.5]; [0.3; 0.3; 0.4]; 1} (two such reactants) the call ends normally
- **Expected**: the figures are drawn for any model with valid mole fractions, the mole-fraction chart with one bar or none
- **Source lines**: 115, 117
- **Documented in**: `test/verifiedTests/analysis/testThermo/testMoleFractionStats.m`

### `src/analysis/thermo/protons/plotActivityCoefficients.m`

#### The output lambda holds the ionic-strength curves, not the activity coefficients of the species

- **Severity**: wrong-result
- **Trigger**: any call, for example modelT.S = zeros(2, 1), modelT.mets = {'a'; 'b'}, modelT.metNames = {'A'; 'B'}, modelT.temp = 298.15, modelT.gasConstant = 8.314472e-3, modelT.met(1).lambda = [0.5 0.005], modelT.met(1).aveZi = -1, modelT.met(2).lambda = [], modelT.met(2).aveZi = 0, [n, edges, lambda] = plotActivityCoefficients(modelT)
- **Observed**: MATLAB R2025a, 2026-11-16: size(n) = size(edges) = [1 101] as expected, but size(lambda) = [4 1000] and lambda(1:4, 1) = [1; 1; 1; 1], lambda(1:4, 2) = [0.9820; 0.9300; 0.8494; 0.7482]: lines 62-66 reuse the variable lambda of lines 34-43 for the curves of charges 1 to 4, overwriting the species values
- **Expected**: lambda = [0.5 0.005], the activity coefficients of the metabolite species, as the OUTPUTS section says
- **Source lines**: 65
- **Documented in**: `test/verifiedTests/analysis/testThermo/testPlotActivityCoefficients.m`

### `src/analysis/thermo/reactantContribution/calcdGHT.m`

#### The standard transformed enthalpy dHf0 is always NaN

- **Severity**: wrong-result
- **Trigger**: any call, e.g. calcdGHT(-100, -50, -1, 3, 7, 0.25, 298.15)
- **Observed**: dHf0 = NaN; line 195 sets dHzero = [] before the enthalpy branch ("makes script faster to leave this out for now")
- **Expected**: the documented output "reactant standard transformed enthalpy of formation"; dHzero is a documented OPTIONAL INPUT ("`p x 1` standard enthalpy of formation at 298.15 K") and dHf0 a documented OUTPUT, so the documented input is ignored and the documented output is always NaN (severity audit T009a)
- **Source lines**: 195-196, 411
- **Documented in**: `test/verifiedTests/analysis/testThermo/testCalcdGHT.m`

### `src/analysis/thermo/reactantContribution/setCommonZeroStandardGibbsEnergyOfFormation.m`

#### Every call stops at getCompartment with Too many input arguments

- **Severity**: error
- **Trigger**: any call, for example model.S = sparse([1 -1; -1 1]) and model.mets = {'fad[c]'; 'fadh2[c]'}, setCommonZeroStandardGibbsEnergyOfFormation(model)
- **Observed**: MATLAB R2025a, 2026-11-16: "Too many input arguments." (MATLAB:TooManyInputs) at line 58: getCompartment(model.mets, numChar) passes a second argument, but src/analysis/thermo/vonBertalanffy/getCompartment.m, the only getCompartment on the path, takes one input (mets)
- **Expected**: the cofactor baselines are adjusted and model is returned, as the help text says
- **Source lines**: 57-58
- **Documented in**: `test/verifiedTests/analysis/testThermo/testSetCommonZeroStandardGibbsEnergyOfFormation.m`

### `src/analysis/thermo/reactantContribution/thermodynamicAdjustmentToStoichiometry.m`

#### An internal reaction with carbon dioxide stops with an index error

- **Severity**: error
- **Trigger**: the model above with mets {'a[c]'; 'co2[c]'; 'h2o[c]'}, metFormulas {'C'; 'CO2'; 'H2O'}, metNames {'a'; 'c'; 'w'} and S = sparse([-1; 1; 0]) (a -> co2)
- **Observed**: MATLAB R2025a, 2026-11-16: after "Formula for carbon dioxide [c] is now H2CO3 = CO2.H20" the call stops with "Index exceeds the number of array elements. Index must not exceed 1." (MATLAB:badsubscript) at line 124: model.mets(co2MatchBool) is a 1 x 1 cell, so abbr(4:6) indexes the cell, not the identifier; lines 106-107 and 113-114 (two carbon dioxide species in one reaction) use the same pattern
- **Expected**: S(h2o[c], r1) = -1, one H2O added to the substrate side for the CO2 produced, as the help text says
- **Source lines**: 106-107, 113-114, 123-124
- **Documented in**: `test/verifiedTests/analysis/testThermo/testThermodynamicAdjustmentToStoichiometry.m`

#### Every call stops at getCompartment with Too many input arguments

- **Severity**: error
- **Trigger**: any call that passes the carbon dioxide step, for example model.S = sparse([-1; 1]), mets {'a[c]'; 'b[c]'}, rxns {'r1'}, metFormulas {'C'; 'C'}, metNames {'a'; 'b'}, rxnNames {'r'}, subSystems {{''}}, SIntRxnBool true
- **Observed**: MATLAB R2025a, 2026-11-16: "Too many input arguments." (MATLAB:TooManyInputs) at line 153: getCompartment(model.mets, numChar) passes a second argument, but src/analysis/thermo/vonBertalanffy/getCompartment.m, the only getCompartment on the path, takes one input (mets)
- **Expected**: the model is returned with oldS, SIntRxnBool and SExRxnBool, unchanged otherwise (no carbon dioxide, no succinate dehydrogenase)
- **Source lines**: 152-153
- **Documented in**: `test/verifiedTests/analysis/testThermo/testThermodynamicAdjustmentToStoichiometry.m`

### `src/analysis/thermo/thermoDirectionality/deltaG0concFluxConstraintBounds.m`

#### every call stops with an undefined function createGroupIncidenceMatrix_old

- **Severity**: error
- **Trigger**: model = createModel({'r1'; 'r2'; 'EX_a'}, {'r1'; 'r2'; 'EX_a'}, {'a[e] -> a[c]'; 'a[c] -> b[c]'; 'a[e] <=> '}, 'lowerBoundList', [0; -10; -10], 'upperBoundList', [10; 10; 10], 'printLevel', 0); then model.concMin = 1e-5 * ones(3, 1); model.concMax = 1e-2 * ones(3, 1); model.dfGt0 = [-10; -10; -20]; model.dfGt0Source = {'GC'; 'GC'; 'GC'}; model.dfGt0GroupContUncertainty = ones(3, 1); model.T = 310.15; model.imBalancedMass = {''; ''; ''}; model.imBalancedCharge = zeros(3, 1); model.SIntRxnBool = [true; true; false]; model.metFormulas = {'C'; 'C'; 'C'}; model.metCharges = zeros(3, 1); deltaG0concFluxConstraintBounds(model, 0, 0, 'x.txt', model.mets, struct('groups', {{}}))
- **Observed**: "Undefined function 'createGroupIncidenceMatrix_old' for input arguments of type 'struct'." at line 307 (R2025a, 2026-11-20); which('createGroupIncidenceMatrix_old') is empty: the only function of that name is declared inside createGroupIncidenceMatrix_jankowski.m, and MATLAB resolves a function by its file name
- **Expected**: the group incidence matrix is computed and the function returns the model with the bounds and directionality documented in OUTPUT; no input can reach the lines after line 307
- **Source lines**: 307
- **Documented in**: `test/verifiedTests/analysis/testThermo/testDeltaG0concFluxConstraintBounds.m`

### `src/analysis/thermo/thermoDirectionality/thermoConstrainFluxBounds.m`

#### A Gibbs energy range with one bound at zero stops the call

- **Severity**: error
- **Trigger**: model.S = sparse([-1 0; 1 -1]), rxns {'r1'; 'r2'}, lb [-10; 0], ub [10; 10], SIntRxnBool [true; true], DrG0_Uncertainty [1; 1], DrGtMin [0; -5], DrGtMax [5; -1], DrGt0 [2; -3], thermoConstrainFluxBounds(model, 0.95, 10, 0)
- **Observed**: MATLAB R2025a, 2026-11-16: the call prints 5 and 0 (lines 136-137) and stops with "Some thermo reactions direction categories are not assigned." at line 138: a reaction with DrGtMin = 0 < DrGtMax (or DrGtMin < 0 = DrGtMax) fits none of the categories of lines 120-124, which use strict inequalities, so the sanity check of line 135 fails. With DrGtMin = [-1; -5] the call ends normally
- **Expected**: r1 classified (it cannot run forward with a negative Gibbs energy) and the bounds returned, since the categories are meant to cover every internal reaction
- **Source lines**: 120-124, 135-138
- **Documented in**: `test/verifiedTests/analysis/testThermo/testThermoConstrainFluxBounds.m`

#### A confidence level outside the built-in table stops the call

- **Severity**: limitation
- **Trigger**: the model above with DrGtMin = [-1; -5] and confidenceLevel 0.9
- **Observed**: MATLAB R2025a, 2026-11-16: "Unable to perform assignment because the left and right sides have a different number of elements." at line 167: only -1, 0.5, 0.7, 0.95 and 0.99 are in the table of lines 62-66, any other value gives an empty tValue
- **Expected**: the documentation of confidenceLevel is empty; an error naming the supported values
- **Source lines**: 68, 167
- **Documented in**: `test/verifiedTests/analysis/testThermo/testThermoConstrainFluxBounds.m`

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

### `src/analysis/thermo/thermoFBA/connectedRxnsByEFM.m`

#### The working directory is not restored when EFMtool fails

- **Severity**: cosmetic
- **Trigger**: an error inside the loop over components, e.g. CalculateFluxModes raising an error
- **Observed**: the catch block returns at line 68 without cd(p), so the caller is left in the EFMtool folder (MATLAB R2025a, with the stub below); rxnLink = [] as documented
- **Expected**: the working directory of the caller is restored, as at line 71
- **Source lines**: 68
- **Documented in**: `test/verifiedTests/analysis/testThermo/testConnectedRxnsByEFM.m`

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

### `src/analysis/thermo/thermoFBA/metaboliteMassBalancePlot.m`

#### The empty-producer branch labels the consumer axes

- **Severity**: cosmetic
- **Trigger**: a metabolite with no producing reaction in the flux vector
- **Observed**: line 79 sets the YTickLabel of h1 (consumer subplot) to NONE (read from the code)
- **Expected**: the producer subplot h2 is labelled NONE, as line 59 does for h1
- **Source lines**: 79
- **Documented in**: `test/verifiedTests/analysis/testThermo/testMetaboliteMassBalancePlot.m`

#### The reaction labels read an undocumented legacy field model.rxn(k).directionality

- **Severity**: error
- **Trigger**: model = createModel({'r1','r2','r3'}, {'r1','r2','r3'}, {'-> A','A ->','A -> B'}); solution.full = [3; 1; 2]; metaboliteMassBalancePlot(model, 'A[c]', solution, 2)
- **Observed**: 'Unrecognized field name "rxn".' at line 62 (MATLAB R2025a); the producer labels use the same field at line 82
- **Expected**: the documented fields only (S, mets, rxns) are used; the labels are the reaction identifiers of the top consumers and producers
- **Source lines**: 62-67, 82-87
- **Documented in**: `test/verifiedTests/analysis/testThermo/testMetaboliteMassBalancePlot.m`

### `src/analysis/thermo/vonBertalanffy/configureSetupThermoModelInputs.m`

#### A model with concMin or concMax fails unless concMinDefault and concMaxDefault are passed

- **Severity**: error
- **Trigger**: model = createModel({'r1'}, {'r1'}, {'A[c] -> B[c]'}) with metFormulas {'C'; 'C'}, metCharges [0; 0], concMin [1e-6; 1e-6], concMax [1e-3; 1e-3]; configureSetupThermoModelInputs(model)
- **Observed**: 'Not enough input arguments.' at line 188 (MATLAB R2025a): lines 63-68 default variables named concMin and concMax instead of concMinDefault and concMaxDefault; passing concMinDefault = [] raises the error of line 189 'concMinDefault must not be set if concentrations are provided', the opposite of its message
- **Expected**: all optional inputs are empty by default (header); the model's bounds are kept and an error is raised only when a default is set together with model bounds
- **Source lines**: 63-68, 188-190, 203-205
- **Documented in**: `test/verifiedTests/analysis/testVonBertalanffy/testConfigureSetupThermoModelInputs.m`

#### concMinDefault and concMaxDefault are ignored

- **Severity**: unusable-option
- **Trigger**: the model above without concMin and concMax; configureSetupThermoModelInputs(model, [], [], [], [], [], 1e-6, 1e-3)
- **Observed**: model.concMin = [1e-5; 1e-5] and model.concMax = [1e-2; 1e-2] (MATLAB R2025a): lines 192 and 207 overwrite the inputs with 1e-5 and 1e-2; lines 193-194 and 208-209 can never run
- **Expected**: model.concMin = [1e-6; 1e-6] and model.concMax = [1e-3; 1e-3] (the documented default bounds)
- **Source lines**: 192-197, 207-212
- **Documented in**: `test/verifiedTests/analysis/testVonBertalanffy/testConfigureSetupThermoModelInputs.m`

### `src/analysis/thermo/vonBertalanffy/estimateDrGt0.m`

#### a model with the field R (gas constant) stops with an undefined variable

- **Severity**: error
- **Trigger**: model = struct('S', sparse([-1; 1]), 'mets', {{'a[c]'; 'b[c]'}}, 'metFormulas', {{'C'; 'C'}}, 'metCharges', [0; 0], 'compartments', {{'c'}}, 'ph', 7, 'chi', 0, 'concMin', [1e-5; 1e-5], 'concMax', [1e-2; 1e-2], 'DfG0', [1; 2], 'DfGt0', [1; 2], 'DfGtMin', [0; 1], 'DfGtMax', [2; 3], 'SIntRxnBool', true, 'DrG0_Uncertainty', 1, 'DrGt0_Uncertainty', 1, 'lb', -10, 'ub', 10, 'R', 8.3144621e-3); estimateDrGt0(model)
- **Observed**: "Unrecognized function or variable 'gasConstant'." at line 118 (R2025a, 2026-11-16): lines 58-60 define gasConstant only when model has no field R and no branch takes it from model.R; without the field the same model runs
- **Expected**: the gas constant is taken from model.R (or the constant is defined in every case), as the isfield test on line 58 intends; setupThermoModel documents that a model may carry R
- **Source lines**: 58-60, 118
- **Documented in**: `test/verifiedTests/analysis/testVonBertalanffy/testEstimateDrGt0.m`

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

### `src/analysis/topology/FR/makeFRresultsTable.m`

#### A model missing from modelMetaData stops the function with an error

- **Severity**: error
- **Trigger**: FRresults with modelID 'm1' and 'm2'; makeFRresultsTable(FRresults, [], [], {'Species one', 'v1', 'm1', '1', ''}) (no row for m2), or the metadata row of m2 only (no row for m1)
- **Observed**: (R2025a, 2026-11-17) metadata for m1 only: "Unable to perform assignment with 0 elements on the right-hand side." (MATLAB:TooManyOutputsDueToMissingBraces) at line 85 when the column of m2 is filled; metadata for m2 only: "Unrecognized function or variable 'n'." at line 85: n is set only when the identifier is found (lines 71-74) and modelMetaData{bool, 1} is empty
- **Expected**: a column for every model of FRresults, with empty metadata cells (as without metadata) and the warning of line 77, since the header does not require every model to be in modelMetaData
- **Source lines**: 70-74, 85, 95, 105, 115-120
- **Documented in**: `test/verifiedTests/analysis/testTopology/testMakeFRresultsTable.m`

#### A resultsDirectory without a trailing file separator cannot be loaded

- **Severity**: error
- **Trigger**: FRresults saved as <folder>/saved.mat; makeFRresultsTable([], folder, 'saved') with folder = tempname (no trailing separator)
- **Observed**: (R2025a, 2026-11-17) "Unable to find file or directory '<folder>saved'." (MATLAB:load:couldNotReadFile) at line 36: the path is built by concatenation; the same call with [folder filesep] loads the file and returns the table
- **Expected**: the file <folder>/saved.mat loaded (fullfile)
- **Source lines**: 36
- **Documented in**: `test/verifiedTests/analysis/testTopology/testMakeFRresultsTable.m`

#### The optional resultsDirectory cannot be omitted: its default is one developer's personal folder

- **Severity**: error
- **Trigger**: makeFRresultsTable([]) (FRresults empty, resultsDirectory omitted)
- **Observed**: (R2025a, 2026-11-17) "Unable to change current folder to '<a Dropbox folder in one developer's home>' (Name is nonexistent or not a folder)." at line 35: line 33 sets that folder as the default, so the call fails on every other machine
- **Expected**: no machine-specific default (for example the current folder, or an error asking for resultsDirectory)
- **Source lines**: 32-35
- **Documented in**: `test/verifiedTests/analysis/testTopology/testMakeFRresultsTable.m`

### `src/analysis/topology/FR/plotFRresults.m`

#### Reconstructions with few stoichiometrically consistent rows are never reported

- **Severity**: wrong-result
- **Trigger**: plotFRresults(FRresults, 2, 2, [], [], 1, modelMetaData) with FRresults(1).model a 4 x 2 S with SConsistentMetBool = [1; 0; 0; 0] (25% consistent rows) and FRresults(2).model fully consistent
- **Observed**: the list under "Reconstructions with less than 90% stoichiometrically inconsistent rows..." is empty and MATLAB prints "2 models that are sufficiently stochiometrically consistent for plotting."; both models are plotted. Line 89 computes size(S,1)/nnz(SConsistentMetBool), which is never below 0.9, and reads FRresults(k), the last model, instead of FRresults(j)
- **Expected**: model m1 (1 of 4 rows consistent) listed and not plotted (lines 153-155), using nnz(SConsistentMetBool)/size(S,1) of model j
- **Source lines**: 89-92
- **Documented in**: `test/verifiedTests/analysis/testTopology/testPlotFRresults.m`

#### Row rank deficiency of [F,R] and [Fb,Rb] is misreported

- **Severity**: wrong-result
- **Trigger**: the call above, with FRresults(2).model.FRrows having 2 nonzeros and FRresults(2).rankFR = 2, and FRresults(1).model.Frb with 3 rows and rankBilinearFrRr = 2
- **Observed**: m2 is listed under "[F,R] does not have full row rank for:" (line 66 compares nnz(FRrows) with nnz(rankFR), which is 1 for any nonzero rank, and line 67 prints the whole FRrows vector); m1 is not listed under "[Fb,Rb] does not have full row rank" because line 75 loops over k=nReconstructions, the last model only
- **Expected**: [F,R] listed when nnz(FRrows) differs from rankFR; [Fb,Rb] checked for every model
- **Source lines**: 66-67, 75
- **Documented in**: `test/verifiedTests/analysis/testTopology/testPlotFRresults.m`

#### The optional input modelMetaData cannot be omitted

- **Severity**: error
- **Trigger**: plotFRresults(FRresults) or any call with fewer than seven inputs
- **Observed**: error "Not enough input arguments." at line 43, which passes modelMetaData to makeFRresultsTable without a default; the defaults of lines 21, 24, 29, 33 and 39 are only reached by such calls; line 33 is a folder in one developer's home
- **Expected**: modelMetaData defaulting to empty, as for makeFRresultsTable
- **Source lines**: 21, 24, 29, 33, 39, 43
- **Documented in**: `test/verifiedTests/analysis/testTopology/testPlotFRresults.m`

### `src/analysis/topology/FR/printFRdependencies.m`

#### Dependent rows are counted and displayed among the independent rows

- **Severity**: wrong-result
- **Trigger**: the same checkRankFR output as the entry above; printFRdependencies(fmOut)
- **Observed**: (R2025a, 2026-11-17) FRwrows of checkRankFR (its line 641) holds every nonzero FRW column, so wR = A, B, C, D includes the dependent row D; the report prints 'FR subset of dimension 5 x 4, of rank 3.', '4 independent rows:' (D among them) and '1 dependent rows:' (D again): row D appears twice in FRdisplay (lines 74 and 130). With two copies of the module: '10 x 8', '8 independent rows:', '2 dependent rows:'
- **Expected**: 3 independent rows (A, B, C) and 1 dependent row (D), a 4-row submatrix
- **Source lines**: 29, 73-74, 83-86, 129-130, 139-140
- **Documented in**: `test/verifiedTests/analysis/testTopology/testPrintFRdependencies.m`

#### Each dependent metabolite is reported as dependent on itself

- **Severity**: wrong-result
- **Trigger**: the model returned by checkRankFR for fm = createModel({'R1'; 'R2'; 'R3'; 'R4'}, {'R1'; 'R2'; 'R3'; 'R4'}, {'A + C -> E'; 'E -> A + D'; 'B + D -> G'; 'G -> B + C'}) with lb = -1000, ub = 1000 and SIntRxnBool, SIntMetBool, SConsistentRxnBool, SConsistentMetBool all true; printFRdependencies(fmOut). checkRankFR itself stops at its line 541 on this machine (method.solver 'gurobi5' and method.interface 'solveCobraLP' are hard-coded at its lines 534-535), so the fields were produced by a copy of checkRankFR with only those two names changed to 'gurobi' and 'SDCCO'
- **Observed**: (R2025a, 2026-11-17) checkRankFR gives rankFR = 5, FRdrows = D[c], FRW = [A:1, B:1, C:-1, D:-1] (lines 636-655 of checkRankFR put -1 at the dependent row) and the report prints 'D[c] is dependent on: A[c] and B[c] and C[c] and D[c].' (lines 38 and 97 list every nonzero FRW column, the dependent row included); the same for two copies of the module (C[c] and Cx[c] each listed as dependent on themselves)
- **Expected**: 'D[c] is dependent on: A[c] and B[c] and C[c].' (the documented FRW expresses dependent rows as combinations of independent rows)
- **Source lines**: 37-38, 96-97
- **Documented in**: `test/verifiedTests/analysis/testTopology/testPrintFRdependencies.m`

### `src/analysis/topology/conservedMoieties/classifyMoieties.m`

#### isSecondary is returned as a row vector, not m x 1

- **Severity**: wrong-result
- **Trigger**: [~, isSecondary] = classifyMoieties([1 1 0 0; 0 0 1 0], [-1 0; 1 0; 0 -1; 0 0])
- **Observed**: size(isSecondary) is [1 4] (MATLAB R2025a): any(..., 1) returns a row
- **Expected**: an m x 1 Boolean vector, as the OUTPUTS documentation says. Severity audit 2026-11-15: OUTPUTS documents "isSecondary: `m x 1` Boolean vector"; any(..., 1) at line 27 returns 1 x m and nothing in the code shows a row is intended
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

- **Severity**: wrong-result
- **Trigger**: [f, M] = estimateMoietyFormulas([1 0; 1 1; 0 1], [2 4 1 0; 4 6 1 1; 2 2 0 1], {'e', 'H', 'C', 'O'})
- **Observed**: M = [1 4 0; 0 2 1] (R2025a, 2026-11-15): the electron column is removed and the columns are sorted to C, H, O (lines 26 and 29), so M is r x 3 and its columns no longer follow the input elements
- **Expected**: OUTPUT: "M: An r x p estimated elemental matrix for moieties" (here 2 x 4 in the order e, H, C, O), or a documentation that says M follows the sorted elements without 'e'. Severity audit 2026-11-15: p = numel(elements) in input order; M is returned r x (p-1) with "e" removed and columns sorted (lines 24-29), so a caller indexing M by the input elements reads wrong columns; no src caller uses M
- **Source lines**: 26, 29
- **Documented in**: `test/verifiedTests/analysis/testConservedMoieties/testEstimateMoietyFormulas.m`

### `src/analysis/topology/conservedMoieties/identifyConservedMoieties.m`

#### the default sanity checks stop when an atom transition has two instances

- **Severity**: error
- **Trigger**: model with mets {A, B, C, D, E}, rxns {R1, R2, R3, R4}, S = [-1 1 0 0; 1 -1 0 0; 0 0 -1 0; 0 0 1 0; 0 0 0 -1]; dATM = digraph with atoms A#1#C, A#2#C, B#1#C, B#2#C, C#1#O, D#1#O (AtomIndex 1-6) and edges R1: 1->3, 2->4, R2: 3->1, 4->2, R3: 5->6 (the tables of buildAtomTransitionMultigraph); identifyConservedMoieties(model, dATM)
- **Observed**: "Error using strcmp / Too many input arguments." at line 442 (R2025a, 2026-11-16): dATM.Edges.HeadAtom{A2Ti(i,:)~=0} expands to two arguments when the atom transition A#1#C-B#1#C has the instances of R1 and R2; the default is sanityChecks = 1 (line 169) although the header documents (0); with sanityChecks = 0 the same call returns L = [1 1 0 0; 0 0 1 1] and the formulae {'C2', 'O'}
- **Expected**: the sanity check compares every instance of the atom transition and passes
- **Source lines**: 169, 442-446
- **Documented in**: `test/verifiedTests/analysis/testConservedMoieties/testIdentifyConservedMoieties.m`

#### the moiety index of a non-canonical component follows its atom order

- **Severity**: wrong-result
- **Trigger**: the model above without R2 (rxns {R1, R3, R4}) and a dATM whose atoms are A#1#C, B#2#C, B#1#C, A#2#C, C#1#O, D#1#O with edges R1: 1->3, 4->2, R3: 5->6; identifyConservedMoieties(model, dATM, struct('sanityChecks', 0))
- **Observed**: arm.ATG.Nodes.MoietyIndex = [1; 1; 2; 2; 3; 4] (R2025a, 2026-11-16): atom 2 (in B) gets moiety 1, which is the moiety of A, because lines 883-889 copy the moiety indices of the first component position by position to the isomorphic component, whose atoms are listed in the order B, A; with sanityChecks = 1 the call stops with "Matrix mapping metabolites to moieties is incorrect" (line 961) after the warning "single moiety incident in more than one metabolite"
- **Expected**: MoietyIndex = [1; 2; 2; 1; 3; 4] (each atom takes the moiety of the metabolite it belongs to), as for the same network with the atoms in the order A, B
- **Source lines**: 883-890
- **Documented in**: `test/verifiedTests/analysis/testConservedMoieties/testIdentifyConservedMoieties.m`

### `src/analysis/topology/conservedMoieties/representativeMoiety.m`

#### MMN.moi is required but not documented

- **Severity**: error
- **Trigger**: representativeMoiety(rmfield(MMN, 'moi')) with MMN as above
- **Observed**: error 'Unrecognized field name "moi".' (line 39)
- **Expected**: INPUT lists only .L and .mol and OUTPUT calls .moi an "added or updated field"; either the input documentation names .moi (a table with one row per moiety) or the field is created when absent. Severity audit 2026-11-15: INPUT lists only ".L" and ".mol" and OUTPUT calls ".moi" an "added or updated field"; the documented input without .moi errors at line 39 - a documented input that fails when used
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

### `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsReadHalfspace.m`

#### a row with rational coefficients is read as a row of zeros

- **Severity**: wrong-result
- **Trigger**: a file r.ine holding "r / H-representation / begin / 2 3 rational / 1/2 1 0 / 0 0 1 / end", then [A, b, csense] = lrsReadHalfspace('r.ine', struct('inequality', 0))
- **Observed**: A = [0 0; 0 1], b = [0; 0], csense = 'GG' (R2025a, 2026-11-16): the branch for rows with '/' converts the scanned values (and divides the integer part by the fractional part, 1/2 -> 1.2 -> 1 / 0.2) but never stores them in A, so the row stays zero; the integer file "-2 1 1 / 0 0 1" with linearity 1 1 is read correctly
- **Expected**: A = [1 0; 0 1], b = [-1/2; 0] (the H-representation 1/2 + x1 >= 0, x2 >= 0)
- **Source lines**: 163-176
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsReadHalfspace.m`

### `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsReadRay.m`

#### a row with rational coefficients is lost

- **Severity**: error
- **Trigger**: v2.ext holding "v2 / V-representation / begin / 3 3 rational / 1 0 0 / 1 1/2 0 / 0 0 1 / end", then lrsReadRay('v2', struct('inequality', 0))
- **Observed**: "Index exceeds array bounds." at line 159 (R2025a, 2026-11-16): the branch for rows with '/' never stores the converted values, so the row stays zero, is classed as a ray (first entry 0), removed as a zero ray at line 157, and the sort index of line 158, computed over all rays, exceeds the remaining columns
- **Expected**: Q = [1/2 0; 0 1] with vertexBool = [true; false]
- **Source lines**: 123-136, 157-159
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsReadRay.m`

#### a vertex whose coordinates sum to zero is removed

- **Severity**: wrong-result
- **Trigger**: w.ext holding "w / V-representation / begin / 3 3 integer / 1 1 -1 / 1 2 0 / 0 0 1 / end", then [Q, vertexBool] = lrsReadRay('w', struct('inequality', 0))
- **Observed**: Q = [2 0; 0 1], vertexBool = [1 0] (R2025a, 2026-11-16): line 144 keeps the vertices with sum(V, 1) ~= 0, so the vertex (1, -1) is dropped
- **Expected**: Q = [1 2 0; -1 0 1], vertexBool = [1 1 0] (only the zero vertex may be removed, as the comment "remove zero vertices" says)
- **Source lines**: 144
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsReadRay.m`

#### the optional param cannot be omitted

- **Severity**: error
- **Trigger**: any .ext file w.ext, then lrsReadRay('w') or lrsReadRay('w', struct())
- **Observed**: "Unrecognized field name "inequality"." at line 43 (R2025a, 2026-11-16): line 34 sets param.positivity where the missing field is param.inequality
- **Expected**: param.inequality defaults to 0 (OPTIONAL INPUT param) and the file is read
- **Source lines**: 33-35, 43
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsReadRay.m`

### `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsWriteHalfspace.m`

#### the documented default positivity = 1 is implemented as 0

- **Severity**: wrong-result
- **Trigger**: lrsWriteHalfspace([1 -1], 0, 'E', 'pz', struct('inequality', 0)) (positivity omitted), i.e. x1 - x2 = 0, then system('lrs pz.ine')
- **Observed**: (R2025a, lrslib 7.1, 2026-11-17) pz.ine has "linearity 1 1 / begin / 1 3 integer / 0 1 -1 / end" (lines 39-41 set param.positivity = 0); lrs returns vertex (0, 0) and linearity (1, 1), the whole line x1 = x2. With positivity = 1 given explicitly the file has "3 3 integer" with the rows 0 1 0 and 0 0 1, and lrs returns vertex (0, 0) and ray (1, 1)
- **Expected**: the documented default "{0, (1)} if param.positivity == 1, then positive orthant base" (line 18): x >= 0 added, so the file and lrs result equal those of the explicit positivity = 1 call
- **Source lines**: 39-41
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsWriteHalfspace.m`

#### the optional param cannot be omitted

- **Severity**: error
- **Trigger**: lrsWriteHalfspace([1 1]) or lrsWriteHalfspace([1 1], 2, 'E', 'm', struct())
- **Observed**: "Unrecognized field name "inequality"." at line 87 (R2025a, 2026-11-16): line 43 sets param.positivity where the missing field is param.inequality
- **Expected**: the documented default of param.inequality is used and the file is written
- **Source lines**: 42-44, 87
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsWriteHalfspace.m`

#### the shell-script option fails

- **Severity**: unusable-option
- **Trigger**: lrsWriteHalfspace([1 1], 2, 'E', 'sh', struct('positivity', 0, 'inequality', 0, 'sh', 1))
- **Observed**: line 323 reads filenameSuffix, which is assigned nowhere in the file (not run: the error "Unrecognized function or variable 'filenameSuffix'" follows from the code), and line 326 would write to a fixed personal cluster folder (/nas/...)
- **Expected**: a script next to the .ine file (OPTIONAL INPUTS: "sh: output a shell script for submitting a qsub job")
- **Source lines**: 322-328
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsWriteHalfspace.m`

#### with no equality and inequality = 1 the column count is 1

- **Severity**: wrong-result
- **Trigger**: lrsWriteHalfspace([1 1], 2, 'G', 'di', struct('positivity', 0, 'inequality', 1)), then system('lrs di_neg_ineq.ine')
- **Observed**: "begin / 1 1 integer / -2 1 1 / end" (line 286 writes clt + 1 = 1); lrs answers "No feasible solution" for a feasible half-plane
- **Expected**: "1 3 integer" (Dclt + 1 columns) and the V-representation of x1 + x2 >= 2
- **Source lines**: 286
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsWriteHalfspace.m`

#### with no equality and positivity = 1 the row count omits the x >= 0 rows

- **Severity**: wrong-result
- **Trigger**: lrsWriteHalfspace([1 1], 2, 'G', 'de', struct('positivity', 1, 'inequality', 0)), i.e. x1 + x2 >= 2, x >= 0, then system('lrs de.ine')
- **Observed**: de.ine has "begin / 1 3 integer / -2 1 1 / 0 1 0 / 0 0 1 / end" (R2025a, lrslib 7.1, 2026-11-16): line 156 counts Drlt + clt = 1 + 0 (clt is 0 when A has no equality) but Dclt = 2 positivity rows follow; lrs reads one row and returns vertex (2, 0), ray (1, 0) and linearity (-1, 1), the half-plane without x >= 0
- **Expected**: "3 3 integer" and the V-representation of {x >= 0, x1 + x2 >= 2}
- **Source lines**: 156
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsWriteHalfspace.m`

### `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsWriteRay.m`

#### the positivity rows are not counted

- **Severity**: wrong-result
- **Trigger**: lrsWriteRay([2 0 1 0; 0 2 0 1], 'mix', [1; 1; 0; 0], struct('positivity', 1)), or any Q with param.positivity = 1, then system('lrs mix.ext')
- **Observed**: the count stays "4 3 integer" while the rows "1 1 0" and "1 0 1" follow (lines 101 and 124 count only the columns of Q); lrs ignores the extra rows
- **Expected**: the row count includes the nMonomial positivity rows
- **Source lines**: 101, 124, 138-150
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsWriteRay.m`

#### vertices are written as lrs linearities

- **Severity**: wrong-result
- **Trigger**: lrsWriteRay([2 0 1 0; 0 2 0 1], 'mix', [1; 1; 0; 0], struct()), i.e. vertices (2, 0), (0, 2) and rays (1, 0), (0, 1), then system('lrs mix.ext')
- **Observed**: mix.ext has "linearity 2 1 2" before "begin / 4 3 integer / 1 2 0 / 1 0 2 / 0 1 0 / 0 0 1 / end" (R2025a, lrslib 7.1, 2026-11-16); lrs returns the single facet "-2 1 1", i.e. x1 + x2 >= 2 without x >= 0
- **Expected**: no linearity line (a vertex is not a line), and lrs returns x1 + x2 >= 2, x1 >= 0, x2 >= 0, as for the same file without the linearity line
- **Source lines**: 87-96
- **Documented in**: `test/verifiedTests/analysis/testLrsInterface/testLrsWriteRay.m`

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

### `src/analysis/topology/reactingMoieties/createMoietyGraph.m`

#### Edge weights are shifted when a metabolite lies off the cycle

- **Severity**: wrong-result
- **Trigger**: model.mets = {'A';'B';'C'}; BG = graph([], [], [], 7); BG.Nodes.mets = {'A';'A';'B';'C';'C';'C';'C'}; arm.L = sparse([2 1 4]); arm.I2A = sparse(ones(1,7)); arm.ATG = graph([], [], [], 7); arm.ATG.Nodes.MoietyIndex = (1:7)'; arm.MTG = graph([1 3], [2 2], [], 3) with Nodes.IsomorphismClass = [1;1;1], Nodes.mets = {'A';'B';'C'}, Nodes.MoietyIndex = [1;2;3]; G = createMoietyGraph(model, BG, arm)
- **Observed**: inclusion rates are C 0.25, A 0.5, B 1; A is not on the path from C to B, and G.Edges lists two edges (2,3) with mets C and B and Weight 0.25 and 0.5: B carries the rate of A. Line 66 filters inclusionOrder first, so line 67 builds its mask from the already filtered list and keeps the first entries of A instead of the matching ones; both stay filtered for the next starting node
- **Expected**: B with its own inclusion rate 1 (A and inclusionOrder filtered with the same mask, from the unfiltered lists for every starting node)
- **Source lines**: 66-67
- **Documented in**: `test/verifiedTests/analysis/testReactingMoieties/testCreateMoietyGraph.m`

### `src/analysis/topology/reactingMoieties/identifyAtomEquivalenceClasses.m`

#### The check for a duplicate bond never fires

- **Severity**: limitation
- **Trigger**: identifyAtomEquivalenceClasses([1; 2], {'C'; 'C'}, [1; 1], [2; 2], [1; 1], 'met') with two bonds between one atom pair
- **Observed**: graph keeps parallel edges, so numedges(G) always equals numel(headAtoms); classes are returned without the warning
- **Expected**: the input is detected as a duplicate bond and the function falls back to the identity map with a warning
- **Source lines**: 110
- **Documented in**: `test/verifiedTests/analysis/testReactingMoieties/testIdentifyAtomEquivalenceClasses.m`

### `src/analysis/topology/reactingMoieties/identifyConservedReactingSubgraphs.m`

#### reaction nodes are removed from RBG with their node indices in dBTM

- **Severity**: wrong-result
- **Trigger**: dBTM with nodes 1 (A bond, atoms 5-6, conserved, no edge), 2 (A bond, atoms 1-2), 3 (reaction R1), 4 (B bond, atoms 3-4), edges 2->3 (HeadMet A, TailMet R1) and 3->4 (HeadMet R1, TailMet B); dATM with atoms 1-6; model.rxns = {'R1'}
- **Observed**: MATLAB R2025a: RAG holds atoms 1-2 only and CAG holds atoms 3-6; line 105 calls rmnode(RBG, reactionNodes) with reactionNodes = 3, an index into dBTM (line 63), which in RBG (nodes 2-4 of dBTM) is the B bond, so the reaction node stays and the reacting B bond is dropped
- **Expected**: RAG holds the atoms of every reacting bond (1-4) and CAG the others (5-6), as for the same graph with the conserved node listed last
- **Source lines**: 63, 105-114
- **Documented in**: `test/verifiedTests/analysis/testReactingMoieties/testIdentifyConservedReactingSubgraphs.m`

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

### `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/getDietComposition.m`

#### A whole-body model (struct) input is rejected

- **Severity**: error
- **Trigger**: getDietComposition(struct('rxns', {{'Food_EX_x[d]'}}, 'lb', -1, 'ub', -1))
- **Observed**: (R2025a, 2026-11-15) error MATLAB:InputParser:ArgumentFailedValidation "The value of 'input' is invalid. It must satisfy the function: iscell." - line 68 declares the required input with @iscell, so the model branch (lines 98-111) is never reached
- **Expected**: the composition of the diet set by the model's Food_EX_ reactions, as the help text documents "Either a whole-body metabolic model (struct) or a diet given as an n x 2 cell array" and lines 98-111 handle a struct
- **Source lines**: 68, 98-111
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testGetDietComposition.m`

### `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/getMetaboliteFlux.m`

#### addStarch fails for every food of the shipped USDA database

- **Severity**: unusable-option
- **Trigger**: getMetaboliteFlux({'167512', 100}, 'addStarch', true) with the shipped papers/2025_nutritionToolbox/usdaDatabase (edition 2024)
- **Observed**: (R2025a, 2026-11-15) error MATLAB:TooManyOutputsDueToMissingBraces "Unable to perform assignment with 0 elements on the right-hand side." at line 222: the starch flux is looked up as Diet_EX_strch1[d], but the shipped USDA2024_100gFluxValue table names starch starch1200 (usda2024_infoFile: nutrient 1009 Starch, vmhID starch1200) and has no strch1 row; the same error for food 169951
- **Expected**: the metabolite fluxes with the unmeasured starch added to the starch flux, as the help text documents for addStarch
- **Source lines**: 222, 231
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testGetMetaboliteFlux.m`

#### addStarch fails when a macro value of the food equals a looked-up nutrient id

- **Severity**: error
- **Trigger**: flux = table({'strch1'; 'glc_D'}, [10; 20], 'VariableNames', {'VMHID', '100001'}); macro = table([1009; 1005; 1063; 1079; 1104], [NaN; 50; 10; 5; 1009], 'VariableNames', {'nutrient_id', '100001'}); getMetaboliteFlux({'100001', 100}, 'addStarch', true, 'fluxTableUsda', flux, 'foodMacroUsda', macro)
- **Observed**: (R2025a, 2026-11-15) error MATLAB:badsubscript "The logical indices in position 1 contain a true value outside of the array bounds." at line 272: macrosSpef == 1009 is compared over both columns [nutrient_id, value], so a value of 1009 selects a row beyond the table. With the value 7 instead of 1009 the call returns strch1 29.438 (10 + (50 - 10 - 5) / 1.8006). In the shipped USDA 2024 macros, food 169951 holds the value 1009 and food 167780 the value 2000 (nutrient 1104)
- **Expected**: the comparison on the nutrient_id column only, and the starch flux computed
- **Source lines**: 272, 278, 285-287, 299-301
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testGetMetaboliteFlux.m`

### `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/getNutritionDatabaseFile.m`

#### The documented file type 'foodItems' of the USDA database is not found

- **Severity**: error
- **Trigger**: getNutritionDatabaseFile('usda', 'foodItems') with the papers submodule checked out ('foodItems' (usda) is a documented value of fileType, header lines 12-14)
- **Observed**: (R2025a, 2026-11-17) error "Could not find USDA2024_foodItems.mat in <toolbox>/papers/2025_nutritionToolbox/usdaDatabase or on the MATLAB path." at line 90: line 85 builds USDA<edition>_foodItems.mat (the name createUSDAdatabase writes), while the shipped folder holds USDA2024_100gFluxValue.mat, USDA2024_100gMacros.mat, usda2024_infoFile.mat and USDAFoodItems.mat (the same at the submodule commit the toolbox records and on the submodule's origin/master)
- **Expected**: the path of the shipped USDA food items file
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

### `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/makeDietFormatConsistant.m`

#### the food tables fdTable.mat and fdCategoriesTable.mat are not in the repository

- **Severity**: error
- **Trigger**: any call, e.g. makeDietFormatConsistant(createModel({'Diet_EX_glc[d]'}, {'x'}, {'glc[d] <=> '}), {'glc', 1})
- **Observed**: MATLAB R2025a: "Unable to find file or directory 'fdTable.mat'." at line 21; neither file is tracked by git or present anywhere in the working tree
- **Expected**: the diet {'Diet_EX_glc[d]', 1} (documented renaming for a metabolite with a Diet_EX_ reaction in the model)
- **Source lines**: 21-29
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testMakeDietFormatConsistant.m`

### `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/normalizeDiet.m`

#### Every call fails because fdTable.mat is not shipped

- **Severity**: error
- **Trigger**: any call, for example normalizeDiet({'167512', 100}, 2000, {})
- **Observed**: (R2025a, 2026-11-15) error MATLAB:load:couldNotReadFile "Unable to find file or directory 'fdTable.mat'." at line 20; no fdTable.mat exists in the repository (getDietEnergy, which normalizeDiet calls, dropped the fdTable food names in 2024 and now reads USDA, Frida or BLS food IDs)
- **Expected**: the diet with the amounts of its food items scaled so that its energy equals the calories argument
- **Source lines**: 20-54
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testNormalizeDiet.m`

### `src/analysis/wholeBody/Nutrition_Modelling_Toolbox/searcher.m`

#### Non-iterative search type cannot run

- **Severity**: unusable-option
- **Trigger**: searchType other than iterative
- **Observed**: the input parser requires database to be a cell array, but this branch reads database.description, a property of tables, so every call errors
- **Expected**: a search that works with the database type the branch needs
- **Source lines**: 33, 90-133
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testSearcher.m`

### `src/analysis/wholeBody/PSCMToolbox/annotateModel.m`

#### every non-transport reaction gets the exchange SBO term when any reaction is an exchange

- **Severity**: wrong-result
- **Trigger**: model = createModel({'EX_a', 'PGI', 'biomass'}, {'', '', ''}, {'a <=> ', 'a -> b', 'b -> '}); model.subSystems = {''; ''; ''}; out = annotateModel(model, 0, 0)
- **Observed**: MATLAB R2025a: out.rxnSBOTerms = {'SBO:0000628'; 'SBO:0000628'; 'SBO:0000628'}; lines 167 and 169 test strfind on the whole list model.rxns instead of model.rxns{i}, so the loop of lines 164-174 overwrites every reaction, including the biomass term SBO:0000629 set at line 155
- **Expected**: SBO:0000629 for biomass (line 155) and the exchange term only for EX_a; PGI is not an exchange reaction
- **Source lines**: 164-174
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testAnnotateModel.m`

#### modelID without modelName stops the call

- **Severity**: error
- **Trigger**: annotateModel(model, 0, 0, 'myID') with the model above
- **Observed**: MATLAB R2025a: "Not enough input arguments." at line 67; line 66 tests exist('modelID') instead of exist('modelName') before reading modelName
- **Expected**: model.modelID = 'myID' and modelName left out (both are documented as optional)
- **Source lines**: 66-67
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testAnnotateModel.m`

### `src/analysis/wholeBody/PSCMToolbox/calcOrganFract.m`

#### The lung of a whole-body model keeps the reference weight instead of the lung polynomial

- **Severity**: wrong-result
- **Trigger**: calcOrganFract(model, struct('sex', 'male', 'bodyWeight', 100, 'CardiacOutput', 5360, 'OrgansWeights', {{}})) for a model with the reaction Lung_biomass_maintenance, e.g. struct('rxns', {{'Lung_biomass_maintenance'}}) or the rxns of the shipped Harvey_1_03d (test/models/mat), whose only lung reaction is Lung_biomass_maintenance (no reaction starts with Lungs_)
- **Observed**: (R2025a, 2026-11-17) the polynomials name the lung 'Lungs' (lines 70 and 88) while the whole-body models and the reference table name it 'Lung' (OrganLists.m, getOrganWeightFraction), so lines 174-188 treat the model's Lung as an organ without polynomial: the output lists both 'Lungs' (1079.05 g at 70 kg, 1405.00 g at 100 kg) and 'Lung' (536 g at every body weight, the reference man's value); the same with the Harvey reactions at 100 kg
- **Expected**: the model's lung weighted by the lung polynomial of Table 3 (the header, lines 4-8, and the comment of lines 167-171 keep only organs not given there constant), listed once
- **Source lines**: 70, 88, 174-188
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testCalcOrganFract.m`

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

### `src/analysis/wholeBody/PSCMToolbox/getStatsOrganComp.m`

#### The metabolite presence matrices keep entries of the compartment-free metabolite list

- **Severity**: wrong-result
- **Trigger**: mk = @(r, m, g) struct('modelAllComp', struct('rxns', {r}, 'mets', {m}, 'genes', {g}, 'grRules', {repmat({'g1'}, numel(r), 1)}, 'S', sparse(numel(m), numel(r)), 'subSystems', {repmat({'s'}, numel(r), 1)})); OC.sex = 'male'; OC.Liver = mk({'Liver_R1'; 'Liver_EX_glc(e)_[bc]'}, {'a[c]'; 'b[c]'}, {'1.1'; '2.1'}); OC.Brain = mk({'Brain_R2'}, {'b[m]'}, {'2.1'}); wbm.mets = {'a[bc]'; 'b[u]'; 'slack_1'; 'c[bp]'; 'd[bd]'; 'e[csf]'; 'f[d]'; 'g[fe]'; 'h[sw]'; 'i[a]'; 'j[mi]'}; wbm.rxns = {'R1'; 'R2'}; wbm.genes = {'1.1'}; wbm.subSystems = {'s'; 't'}; [~, ~, ~, TMf, TMm] = getStatsOrganComp(wbm, wbm, OC, OC)
- **Observed**: (R2025a, 2026-11-15) TMm = TMf = [0 1 0; 0 1 1; 0 0 1] for the metabolites {'a[c]'; 'b[c]'; 'b[m]'} and the columns sex, Liver, Brain: b[c] is marked present in Brain. The matrix is first filled for the compartment-free list {'a'; 'b'} (lines 600, 1287) and is not cleared before it is filled again for the list with compartments (line 627 clears only TableMets_male, the female section clears nothing), so row 2 keeps the Brain entry of 'b'
- **Expected**: [0 1 0; 0 1 0; 0 0 1] - b[c] is a metabolite of the Liver only; the metabolite counts in TableGRM (core / organ-specific / others) derive from it too
- **Source lines**: 600, 627, 646, 654-672, 1287, 1315-1337
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testGetStatsOrganComp.m`

#### The results file named in the help text is never written

- **Severity**: wrong-result
- **Trigger**: any call, e.g. the call above
- **Observed**: (R2025a, 2026-11-15) no Results_StatsOrganComp.mat is created: the save is inside "if 0" (lines 1508-1515); the call only sets the global resultsPath
- **Expected**: Results_StatsOrganComp.mat "created at the end of this function", as the help text says, or a help text that does not announce it. Severity audit 2026-11-15: the header promises "Results_StatsOrganComp.mat, which is created at the end of this function"; the save is inside "if 0" (lines 1508-1515), so the documented output file is never written
- **Source lines**: 1508-1515
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testGetStatsOrganComp.m`

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

### `src/analysis/wholeBody/PSCMToolbox/setConstraints/physiologicalConstraintsHMDBbased.m`

#### ExclList is ignored for the blood exchanges of every organ but the kidney

- **Severity**: wrong-result
- **Trigger**: a model with the reaction Liver_EX_xyz(e)_[bc] (Liver_xyz[e] <=> xyz[bc], bounds -1000/1000, xyz not in the HMDB table); physiologicalConstraintsHMDBbased(model, IndividualParameters, {'Liver_EX_xyz(e)_[bc]'})
- **Observed**: MATLAB R2025a: the lower bound becomes -21.6 (default concentration 20 uM x liver plasma flow), the same as without ExclList; the general blood branch (lines 447-525) never consults ExclList, which only the kidney (line 425), CSF (line 605, HMDB input only) and urine (line 749) branches merge into their exclusion lists
- **Expected**: the bounds of a reaction in ExclList unchanged (documented: "list of reaction identifiers that should not receive an updated bound")
- **Source lines**: 447-525, 602-603
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testPhysiologicalConstraintsHMDBbased.m`

### `src/analysis/wholeBody/PSCMToolbox/setConstraints/physiologicalConstraintsHMDBbased_old.m`

#### ExclList is ignored for the blood exchanges of every organ but the kidney

- **Severity**: wrong-result
- **Trigger**: a model with Liver_EX_xyz(e)_[bc] (Liver_xyz[e] <=> xyz[bc], bounds -1000/1000, xyz not in the HMDB table) and the eight reactions of the literature constraints (Muscle_EX_glc_D(e)_[bc], Muscle_EX_ala_L(e)_[bc], RBC_EX_glc_D(e)_[bc], Brain_EX_glc_D(e)_[csf], Brain_EX_o2(e)_[csf], Liver_EX_ala_L(e)_[bc], Liver_EX_glc_D(e)_[bc], Adipocytes_EX_glyc(e)_[bc]); IndividualParameters with gender 'male', CardiacOutput 5000, Hematocrit 0.4, MConDefaultBc 20, liver blood flow '"0.25"'; physiologicalConstraintsHMDBbased_old(model, IndividualParameters, {'Liver_EX_xyz(e)_[bc]'})
- **Observed**: MATLAB R2025a: the lower bound of Liver_EX_xyz(e)_[bc] becomes -21.6 (20 uM x liver plasma flow 750 ml/min x 1440 / 1e6), the same as without ExclList; the general blood branch (lines 398-472) never reads ExclList, which only the kidney (line 376), CSF (line 551, HMDB input only) and urine (line 695) branches use
- **Expected**: the bounds of a reaction in ExclList unchanged (documented: reactions to be excluded from receiving updated bounds)
- **Source lines**: 398-472, 548-549
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testPhysiologicalConstraintsHMDBbased_old.m`

### `src/analysis/wholeBody/PSCMToolbox/setConstraints/readInDietFromVMH.m`

#### Flux values are rounded to the default precision of num2str

- **Severity**: limitation
- **Trigger**: a spreadsheet with the header row {'Flux', 'b', 'c', 'd', 'e', 'Reaction'} and the rows {0.123456789, 'x', 'y', 'z', 'w', 'EX_glc_D(e)'} and {0.5, 'x', 'y', 'z', 'w', 'EX_o2(e)'}, then readInDietFromVMH({fileName})
- **Observed**: (R2025a, 2026-11-15) {'Diet_EX_glc_D[d]', '0.12346'; 'Diet_EX_o2[d]', '    0.5'}: num2str of the flux column keeps about five significant digits (relative to the largest value) and pads the shorter values with leading spaces
- **Expected**: the flux values as given in the spreadsheet (e.g. '0.123456789')
- **Source lines**: 32
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testReadInDietFromVMH.m`

### `src/analysis/wholeBody/PSCMToolbox/setConstraints/setDietConstraints.m`

#### A user diet with numeric flux values stops with an error

- **Severity**: error
- **Trigger**: model = struct('rxns', {{'Diet_EX_glc_D[d]'; 'Diet_EX_na1[d]'; 'Diet_EX_thm[d]'}}, 'lb', [-1; -1; -1], 'ub', [1; 1; 1]); setDietConstraints(model, {'Diet_EX_glc_D[d]', 10}); also setDietConstraints(model, {'Diet_EX_thm[d]', 1}) (a micronutrient)
- **Observed**: (R2025a, 2026-11-17) error "Input must be a character vector or string scalar." from str2num, called at line 166 (glucose) and at line 156 (thiamin); the header (lines 18-22) documents Diet as "a diet cell array whose first column holds diet exchange reaction identifiers and whose second column holds the corresponding flux values", without restricting the values to text; the same diet with the value '10' (text) gives lb = -12, ub = -8 for glucose
- **Expected**: numeric flux values accepted as documented, giving the same bounds as the same values written as text
- **Source lines**: 156-166, 174-178
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testSetDietConstraints.m`

### `src/analysis/wholeBody/PSCMToolbox/setConstraints/setFeedingFastingConstraints.m`

#### The list of storable amino acids is printed on every call

- **Severity**: cosmetic
- **Trigger**: any call, for example setFeedingFastingConstraints(model, 'feeding')
- **Observed**: the script AAStorage, run at line 52, ends its storageAA assignment (AAStorage.m line 23) without a semicolon, so the 20 x 1 cell array storageAA is displayed
- **Expected**: no output
- **Source lines**: 52
- **Documented in**: `test/verifiedTests/analysis/testWholeBody/testSetFeedingFastingConstraints.m`

### `src/base/ci/addKeyToKnownHostsCT.m`

#### The documented host name ' ' does not select github.com and the call fails

- **Severity**: error
- **Trigger**: addKeyToKnownHostsCT(' ') with ssh-keyscan installed (reproduced with HOME in a tempname folder and a fake ssh-keyscan first on PATH)
- **Observed**: (R2025a, 2026-11-17) with gitCmd set: error ">> [addKeyToKnownHostsCT]  could not be added to the known hosts file in ~/.ssh/known_hosts"; with gitCmd empty: "Dot indexing is not supported for variables of this type."; known_hosts stays empty. Lines 26-31 replace only an empty name, so ' ' is passed on: grep "^  " finds nothing and 'ssh-keyscan   >> known_hosts' runs without a host (usage message, status 1)
- **Expected**: github.com is checked and added, as for no input or '' (the help text: "If not provided or empty or ' ' then it checks for the host: github.com"); true is returned
- **Source lines**: 26-31, 52-63
- **Documented in**: `test/verifiedTests/base/testCi/testAddKeyToKnownHostsCT.m`

#### The error messages fail with a dot-indexing error when gitCmd is not set

- **Severity**: cosmetic
- **Trigger**: with the global gitCmd empty (no toolbox function sets it) and a fake ssh-keyscan that prints nothing for the host: addKeyToKnownHostsCT('unreachable.invalid'); likewise with an ssh-keyscan that does not print its usage message
- **Observed**: (R2025a, 2026-11-15) the call stops with "Dot indexing is not supported for variables of this type." instead of its own message
- **Expected**: the error "... unreachable.invalid could not be added to the known hosts file in ~/.ssh/known_hosts" (or "... ssh-keyscan is not installed."), without depending on gitCmd
- **Source lines**: 63, 72
- **Documented in**: `test/verifiedTests/base/testCi/testAddKeyToKnownHostsCT.m`

### `src/base/cobrarrow/COBRArrowSolver.m`

#### Copies of a solver object share one parameter map

- **Severity**: wrong-result
- **Trigger**: o1 = COBRArrowSolver('GLPK'); o2 = o1; o2 = o2.setParameter('k', 1); o1.parameters.keys (likewise removeParameter on a copy, or any of them on an object passed to a function)
- **Observed**: (R2025a, 2026-11-17) o1.parameters.keys is {'k'} after o2.setParameter; after o1 = o1.setParameter('m', 2); o3 = o1; o3 = o3.removeParameter('m') o1 has lost 'm'; f = @(s) s.setParameter('fromFunction', 3); f(o1) adds 'fromFunction' to o1. COBRArrowSolver is a value class, but its parameters property is a containers.Map, which is a handle (only clearParameters gives the copy a new map)
- **Expected**: the original keeps its parameters: a value object whose methods return the updated instance changes only the object the caller assigns the result to
- **Source lines**: 36, 60, 72
- **Documented in**: `test/verifiedTests/base/testCobrarrow/testCOBRArrowSolver.m`

### `src/base/codeConsistency/printFunctionIO.m`

#### Fields of a variable whose name ends with an input name are listed as fields of the input

- **Severity**: wrong-result
- **Trigger**: a function file probeIoTarget.m on the path with the lines "function [a, b] = probeIoTarget(model, x)", "submodel.rxns = 1;", "b.field = 2;", "a = x.y;", "end", then [inputs, outputs] = printFunctionIO('probeIoTarget', {}, 0)
- **Observed**: (R2025a, 2026-11-15) inputs = {'model.rxns'; 'x.y'}: the pattern pattern('model') + '.' + alphanumerics matches inside "submodel.rxns"
- **Expected**: inputs = {'model'; 'x.y'} - the source references no field of the input model
- **Source lines**: 71-72
- **Documented in**: `test/verifiedTests/base/testCodeConsistency/testPrintFunctionIO.m`

#### Fields of the second and later outputs are missed when the reference starts a line

- **Severity**: wrong-result
- **Trigger**: the same call as above (signature "[a, b]" with a space after the comma, the layout the openCOBRA style guide requires, and "b.field = 2;" at the start of a line)
- **Observed**: (R2025a, 2026-11-15) outputs = {'a'; 'b'}: split at line 115 keeps ' b' with its leading space and the search pattern at line 131 then needs a space before "b."
- **Expected**: outputs = {'a'; 'b.field'}
- **Source lines**: 115, 131-132
- **Documented in**: `test/verifiedTests/base/testCodeConsistency/testPrintFunctionIO.m`

### `src/base/generateSystemConfigReport.m`

#### A short answer from curl stops the report at the summary

- **Severity**: error
- **Trigger**: a curl command whose output of --version has fewer than three words
- **Observed**: the warning at line 66 leaves result_curlVersion undefined, so line 95 stops the function with an undefined-variable error, with the diary still on and the current folder left at the toolbox root
- **Expected**: the report finishes and shows that the curl version is not known
- **Source lines**: 65-66
- **Documented in**: `test/verifiedTests/base/testTools/testGenerateSystemConfigReport.m`

### `src/base/getExchangedMetaboliteTable.m`

#### exRxnsOrdered = {} stops the call

- **Severity**: error
- **Trigger**: model = createModel({'EX_a', 'EX_b', 'R1'}, {'', '', ''}, {'a <=> ', 'b <=> ', 'a -> b'}); model.metNames = model.mets; getExchangedMetaboliteTable(model, {}, eye(2))
- **Observed**: MATLAB R2025a: "Unrecognized function or variable 'exchangeMetsL'." at line 85; exchangeMetsL is assigned only inside the reordering branch (lines 66-82) but always plotted (lines 84-85)
- **Expected**: the table and the model returned (documented: "pass {} to skip reordering")
- **Source lines**: 66-85
- **Documented in**: `test/verifiedTests/base/testTools/testGetExchangedMetaboliteTable.m`

### `src/base/install/adaptMacPath.m`

#### pre-Sierra macOS versions with a patch number or a one-digit minor select postSierra

- **Severity**: wrong-result
- **Trigger**: CBTDIR set to a temporary folder holding binary/maci64/bin/preSierra and postSierra (both on the MATLAB path), a fake sw_vers first on PATH that prints "ProductName:\tMac OS X\nProductVersion:\t10.11.6\nBuildVersion:\t15G31\n", then adaptMacPath()
- **Observed**: (R2025a, 2026-11-15) postSierra on the path and preSierra removed for ProductVersion 10.11.6, 10.9.5 and 10.9; preSierra only for 10.11. Line 20 gives str2double('10.11.6') = NaN, and NaN < 10.12 is false; '10.9' becomes 10.9, which is larger than 10.12 as a decimal number
- **Expected**: preSierra for every macOS version below 10.12 (the help text: "Sierra/High Sierra or higher and Anything below"), e.g. 10.11.6 (the last El Capitan release) and 10.9.5; the version should be compared component by component
- **Source lines**: 20-21
- **Documented in**: `test/verifiedTests/base/testInstall/testAdaptMacPath.m`

### `src/base/install/prepareTest.m`

#### needsLinux makes every test skip on Linux

- **Severity**: unusable-option
- **Trigger**: prepareTest('needsLinux', true) on a 64-bit Linux machine
- **Observed**: error COBRA:RequirementsNotMet "This test only works on Linux Systems" although isunix is 1; computer('arch') returns 'glnxa64' (probe output: "isunix=1 arch=glnxa64"), and line 177 compares it with 'glnx64', so the check always fails
- **Expected**: no requirement error on Linux, as the help text says ("needsLinux: Whether the test only works on a Linux system")
- **Source lines**: 177-179
- **Documented in**: `test/verifiedTests/base/testInstall/testPrepareTest.m`

### `src/base/install/updateCobraToolbox.m`

#### A commit count that git cannot compute stops the function with an undefined variable instead of the intended warning

- **Severity**: error
- **Trigger**: updateCobraToolbox(true) in a clone whose remote.origin.url contains opencobra/cobratoolbox, on a branch, with a local master branch, where 'git rev-list --left-right --count master...origin/master' fails (for example when origin/master was never fetched); reproduced with a stand-in git executable first on PATH (fetch and show-ref succeed, that rev-list exits with status 128)
- **Observed**: (R2025a, 2026-11-15) "Unrecognized function or variable 'commitsAheadBehindMaster'." at line 85: the counts are assigned only when rev-list succeeds (lines 56-58). With the master count 0/0 and a failing develop count the error is "Unrecognized function or variable 'commitsAheadBehindDevelop'." (line 85); the warning of lines 157-158 is reached only when master is ahead, because || stops before the develop count is read
- **Expected**: the message of line 157 and the warning 'Eventual changes of the <master> branch of The COBRA Toolbox could not be counted.' (lines 157-158)
- **Source lines**: 56-58, 73-75, 85, 157-158
- **Documented in**: `test/verifiedTests/base/testInstall/testUpdateCobraToolbox.m`

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

### `src/base/io/convertCbModelToCNAModel.m`

#### Ordinary metabolite names stop the conversion with an index error

- **Severity**: error
- **Trigger**: with the CellNetAnalyzer stand-ins startcna and CNAgenerateMFNetwork (empty functions) on the path: model = createModel({'R1'; 'R2'}, {'first'; 'second'}, {'a -> b'; 'b <=> '}); model.metNames = {'glucose'; 'fructose'}; convertCbModelToCNAModel(model, 0)
- **Observed**: (R2025a, 2026-11-17) 'Index in position 1 exceeds array bounds. Index must not exceed 2.' in external/analysis/CnaCobraInterface/CNAcobra2cna.m line 37, called from line 32: the loop of CNAcobra2cna.m lines 36-43 runs i = 1:size(cnap.specLongName, 2) (8, the longest name) over the rows specLongName(i, :) (2 metabolites); the fault is in the read-only interface submodule
- **Expected**: the project of the documented COBRA model input (metNames of any length)
- **Source lines**: 32
- **Documented in**: `test/verifiedTests/base/testIO/testConvertCbModelToCNAModel.m`

#### Whitespace in metabolite names is replaced only in the first rows

- **Severity**: wrong-result
- **Trigger**: with the same stand-ins: model = createModel({'R1'; 'R2'; 'R3'}, {'R1'; 'R2'; 'R3'}, {'a -> b'; 'b -> c + d'; 'c + d <=> '}); model.metNames = {'x y'; 'u v'; 'p'; 'q r'}; convertCbModelToCNAModel(model, 0)
- **Observed**: (R2025a, 2026-11-17) specLongName rows 'x_y', 'u_v', 'p', 'q r': the same loop (CNAcobra2cna.m lines 36-43, reached from line 32) visits only as many rows as the longest name has characters (3 of 4), so the fourth name keeps its space
- **Expected**: 'q_r' as well, as the warning and replacement of CNAcobra2cna.m lines 38-41 intend for every metabolite name
- **Source lines**: 32
- **Documented in**: `test/verifiedTests/base/testIO/testConvertCbModelToCNAModel.m`

#### without CellNetAnalyzer a call with an output stops with an unassigned-output error

- **Severity**: cosmetic
- **Trigger**: cnaModel = convertCbModelToCNAModel(model) when startcna is not on the path
- **Observed**: MATLAB R2025a: 'Output argument "cnaModel" (and possibly others) not assigned a value in the execution with "convertCbModelToCNAModel" function.' after the message of checkCNAinstallation; the call cannot succeed without CellNetAnalyzer, only the message is unhelpful
- **Expected**: an error that says CellNetAnalyzer is needed
- **Source lines**: 31-33
- **Documented in**: `test/verifiedTests/base/testIO/testConvertCbModelToCNAModel.m`

### `src/base/io/convertCobraLP2mps.m`

#### only the first column of a 'G' row is negated

- **Severity**: wrong-result
- **Trigger**: LP.A = sparse([1 2; 3 4]); LP.b = [5; 6]; LP.c = [1; 1]; LP.lb = [0; 0]; LP.ub = [10; 10]; LP.csense = ['G'; 'L']; LP.osense = 1; convertCobraLP2mps(LP, 'conv')
- **Observed**: (R2025a, 2026-11-15) conv.mps holds row LE1 = -1*X1 + 2*X2 with RHS -5, that is -x1 + 2*x2 <= -5. Line 72 indexes A2 with the m x 1 logical G, which selects elements of the first column only (linear indexing), while line 73 negates b correctly
- **Expected**: -x1 - 2*x2 <= -5 (the G row x1 + 2*x2 >= 5 multiplied by -1, as the comment "need to change sign of A*x >= b constraints" says); writeLPProblem writes LE2 = -1*X1 - 2*X2 <= -5 for the same problem (whole row negated)
- **Source lines**: 72
- **Documented in**: `test/verifiedTests/base/testIO/testConvertCobraLP2mps.m`

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

### `src/base/io/python/initPythonEnvironment.m`

#### The default environment CPython3 rejects every Python newer than 3.8

- **Severity**: unusable-option
- **Trigger**: initPythonEnvironment() with python3 3.12.3 on the system path (MATLAB R2025a)
- **Observed**: error "MATLAB >=R2020b is only stated to be compatible with Python 3.6,3.7,3.8" at line 123; in the same session pyenv('Version', <which python3>, 'ExecutionMode', 'OutOfProcess') loads that Python 3.12 and py.sys.version returns "3.12.3 ...". The test of line 120 is contains(response, '3.6') || '3.7' || '3.8' on the output of python3 --version
- **Expected**: the Python versions supported by the running MATLAB are accepted (R2025a supports 3.9 to 3.12, R2023b and later no longer support 3.8), so the default option can load Python
- **Source lines**: 119-124
- **Documented in**: `test/verifiedTests/base/testPython/testInitPythonEnvironment.m`

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

### `src/base/io/utilities/creategrRulesField.m`

#### unknown reaction names in positions are not reported as intended

- **Severity**: cosmetic
- **Trigger**: creategrRulesField(model, {'R1', 'notInModel'}) and creategrRulesField(model, {'notInModel'}) on a model with a grRules field
- **Observed**: MATLAB R2025a: the mixed list raises no error and silently updates R1 only, because the test of line 45 reads (~sum(pos)) == numel(unique(positions)), which is true only when no name matches and exactly one name is given; the all-unknown list then stops in the error call of line 46 with "Unrecognized function or variable 'postions'" (misspelt variable) instead of the intended message. The test below only checks that the all-unknown list raises an error.
- **Expected**: the error "The following reactions are not part of this model: notInModel" for both lists
- **Source lines**: 45-46
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testCreategrRulesField.m`

### `src/base/io/utilities/getDefinedFieldProperties.m`

#### A requested field without definition raises an error instead of being left out

- **Severity**: error
- **Trigger**: getDefinedFieldProperties('SpecificFields', {'lb', 'notAField'})
- **Observed**: error "The following requesteds fields have no Specifications: notAField"
- **Expected**: the documented OUTPUTS: "if fields without definitions are requested, they will not be contained in the result" (i.e. only the row of lb); a documented input that fails when used (severity audit T009a)
- **Source lines**: 192-194
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testGetDefinedFieldProperties.m`

#### SpecificFields is ignored together with Descriptions or DataBaseFields

- **Severity**: unusable-option
- **Trigger**: getDefinedFieldProperties('Descriptions', true, 'SpecificFields', {'lb'})
- **Observed**: all 82 description rows are returned
- **Expected**: only the row of lb (SpecificFields: "only obtain definitions for a specific set of fields", documented with no restriction on combining it with the other options); both branches return before the selection of lines 190-196, so the documented option has no effect when used (severity audit T009a)
- **Source lines**: 102-103, 135-136
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testGetDefinedFieldProperties.m`

### `src/base/io/utilities/getDistributedModelFolder.m`

#### the warning shows a literal \n

- **Severity**: cosmetic
- **Trigger**: getDistributedModelFolder('noSuch.mat')
- **Observed**: MATLAB R2025a: "Requested Model not present in the model directory.\n This is either due to ..." - warning is called with the message only, so the escape sequence is not interpreted
- **Expected**: a line break in the warning text
- **Source lines**: 37
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testGetDistributedModelFolder.m`

### `src/base/io/utilities/initFBAFields.m`

#### The documented osense and csense fields are not created

- **Severity**: limitation
- **Trigger**: initFBAFields(model) on a model without osense or csense, for example a model with only S
- **Observed**: only S, mets, rxns, lb, ub, c, genes and rules are created; csense and osense are not added because the field definitions do not mark them for flux balance analysis
- **Expected**: osense (-1) and csense (one E per metabolite) added, as the help text states
- **Source lines**: 41-42
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testInitFBAFields.m`

### `src/base/io/utilities/model2xls.m`

#### compSymbols without compNames stops the call

- **Severity**: error
- **Trigger**: model2xls(model, fileName, compSymbols) with compSymbols given and compNames omitted; for example model2xls(createModel({'R1'}, {''}, {'a[c] -> b[c]'}), [tempname '.xls'], {'c'})
- **Observed**: (R2025a, 2026-11-17) "Not enough input arguments." (MATLAB:minrhs) at line 173: the defaults of lines 87-94 are set only when compSymbols is missing, so compNames is never defined when compSymbols alone is given, and line 173 reads it
- **Expected**: the call to succeed, as the header lists compSymbols and compNames as two separate entries under OPTIONAL INPUT (lines 31-34), for example with compNames defaulting to compSymbols (as writeCbModel does)
- **Source lines**: 87-94, 171, 173
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testModel2xls.m`

### `src/base/io/utilities/readBooleanRegModel.m`

#### A file without a rule of every type stops with an error

- **Severity**: limitation
- **Trigger**: readBooleanRegModel(model, file) with a file that has xcm and reg rows only
- **Observed**: error "Unrecognized field name "icmRules"." at line 131; files without metabolite, pool, regulator or target rows fail the same way at lines 98, 146, 150 and 177, because those fields are created only inside the loops
- **Expected**: empty fields for the rule types the file does not contain
- **Source lines**: 98, 131, 146, 150, 177
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testReadBooleanRegModel.m`

#### Pool members written with spaces around + are not found

- **Severity**: limitation
- **Trigger**: an xcp row with the rule 'a[e] + b[e] + zz'
- **Observed**: the members are split with the spaces kept ('a_e ', ' b_e ', ' zz'), so none matches a metabolite name ("pool1: metabolite a_e  not in regulatory network model") and the pool is empty; the test writes the members without spaces
- **Expected**: the members trimmed and matched (pool [2; 1])
- **Source lines**: 76, 139
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testReadBooleanRegModel.m`

#### The default file iMHruletest.xls is not distributed

- **Severity**: limitation
- **Trigger**: readBooleanRegModel(model) in a folder without iMHruletest.xls
- **Observed**: no file of that name exists in the repository, so the call with one argument fails in xlsread unless the user provides the file in the current folder
- **Expected**: a distributed example file, or a required fileName argument
- **Source lines**: 47
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testReadBooleanRegModel.m`

#### The message for a missing exchange reaction names the wrong metabolite

- **Severity**: cosmetic
- **Trigger**: an xcm row whose exchange reaction is in the model followed by one whose reaction is not
- **Observed**: line 110 indexes the xcm rows with the position i in the list of missing reactions, so the name of the first xcm row is printed with the missing reaction; the test lists the missing reaction first, where both positions agree
- **Expected**: the name of the row whose reaction is missing
- **Source lines**: 110
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testReadBooleanRegModel.m`

#### The message for a missing internal reaction has no line break

- **Severity**: cosmetic
- **Trigger**: an icm rule naming a reaction that is not in the model
- **Observed**: "d_c: rxn R9 not found in the metabolic model" is followed on the same line by the next message
- **Expected**: one message per line, as the other messages
- **Source lines**: 125
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testReadBooleanRegModel.m`

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

- **Severity**: wrong-result
- **Trigger**: a line whose eighth field is "adenosine triphosphate / ATP"
- **Observed**: altNames is {'adenosine triphosphate'; ' ATP'} (deblank removes trailing blanks only)
- **Expected**: {'adenosine triphosphate'; 'ATP'}, the names without the blanks around the separator that the deblank loop is meant to remove. Severity audit 2026-11-15: the deblank loop (lines 39-40) shows the names are meant to be stripped of the blanks around "/"; " ATP" is returned in metInfo.altNames - a wrong value in a result field, not in a message
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

### `src/base/io/utilities/readSimPhenyGprText.m`

#### the rules of reactions with several genes refer to the wrong genes

- **Severity**: wrong-result
- **Trigger**: a GPR text file with 11 tab-separated columns and one header line whose rows have R1 / b1, R2 / b2+b3 and R3 / b3,b1 in the reaction name (third) and GPRA (ninth) columns; gpraModel = readSimPhenyGprText(file)
- **Observed**: MATLAB R2025a: gpraModel.genes = {b1; b2; b3} and gpraModel.rules = {'x(1)'; 'x(3) & x(3)'; 'x(3) | x(1)'} while gpraModel.rxnGeneMat is right ([1 0 0; 0 1 1; 1 0 1]). Line 62 renumbers the local gene indices with strrep one gene at a time: for R2 the first step turns x(1) into x(2) and the second step turns both x(2) into x(3). Every reaction whose genes are not the first genes of the sorted gene list in order is affected (and x(1) would also match inside x(10)); the rules merged into a model (line 82) carry the same error
- **Expected**: gpraModel.rules = {'x(1)'; 'x(2) & x(3)'; 'x(3) | x(1)'}, consistent with rxnGeneMat and grRules ('b2 and b3')
- **Source lines**: 61-63
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testReadSimPhenyGprText.m`

### `src/base/io/utilities/write4ti2.m`

#### The optional input uni has no default, so it cannot be omitted

- **Severity**: error
- **Trigger**: write4ti2([1 -1; 0 1], fullfile(<tempname folder>, 'y')), reached once line 17 passes the matrix (the real integerizeS stops the call at line 17 first)
- **Observed**: (R2025a, 2026-11-17, same stand-in integerizeS) "Not enough input arguments." (MATLAB:minrhs) at line 21 (if uni == 0); no file is written
- **Expected**: OPTIONAL INPUT documents "uni: {(0),1}", i.e. a default of 0: the matrix is written to <filename>_Bi.4ti2in
- **Source lines**: 21
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testWrite4ti2.m`

#### With uni = 0 the file is closed twice and the call stops after writing it

- **Severity**: error
- **Trigger**: write4ti2([1 -1; 0 1], fullfile(<tempname folder>, 'x'), 0), reached once line 17 passes the matrix (the real integerizeS stops the call at line 17 first)
- **Observed**: (R2025a, 2026-11-17, with a stand-in integerizeS on a temporary path that returns its matrix input) x_Bi.4ti2in is written completely ("2 2", "1 -1 ", "0 1 ") and the call then stops with "Invalid file identifier.  Use fopen to generate a valid file identifier." at line 45: line 32 closes fid inside the uni == 0 branch and line 45, after the if/else, closes it again; with uni = 1 the same call returns normally
- **Expected**: the file written and the call returning, as for uni = 1
- **Source lines**: 32, 45
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testWrite4ti2.m`

#### integerizeS is called with a matrix but needs a model structure

- **Severity**: error
- **Trigger**: write4ti2([1 -1; 0 1], 'x', 0) (also with uni = 1)
- **Observed**: (R2025a, 2026-11-15) error "Dot indexing is not supported for variables of this type." raised in integerizeS line 39 (size(model.S)); line 17 passes the matrix SeFull, and the comment there says integerizeS is not defined in the toolbox, while src/analysis/topology/integerizeS.m now takes a model and returns a model
- **Expected**: the documented input "SeFull: full stoichiometric matrix" is integerised and written, e.g. integerizeS(struct('S', SeFull), 0, 0) and its .S field
- **Source lines**: 17
- **Documented in**: `test/verifiedTests/base/testIO/testUtilities/testWrite4ti2.m`

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

### `src/base/io/writeLPProblem.m`

#### the outputFormat option always fails validation

- **Severity**: unusable-option
- **Trigger**: LP.A = sparse([1 2; 3 4]); LP.b = [5; 6]; LP.c = [1; 1]; LP.lb = [0; 0]; LP.ub = [10; 10]; LP.csense = ['G'; 'L']; LP.osense = 1; writeLPProblem(LP, 'outputFormat', 'mps')
- **Observed**: (R2025a, 2026-11-15) error "The value of 'outputFormat' is invalid. Not enough input arguments."; the same error for the positional form writeLPProblem(LP, 'p1', 'f1', struct(), 'mps'). The validator on line 84 calls strcmpi(acceptedTypes) with one argument
- **Expected**: 'mps' is accepted (OPTIONAL INPUT: "Currently only 'mps' is supported (and default)"), i.e. any(strcmpi(x, acceptedTypes))
- **Source lines**: 84
- **Documented in**: `test/verifiedTests/base/testIO/testWriteLPProblem.m`

#### writeMatrix given as the first option is taken for a positional problem name

- **Severity**: unusable-option
- **Trigger**: writeLPProblem(LP, 'writeMatrix', false) with LP as above
- **Observed**: (R2025a, 2026-11-15) error "The value of 'fileName' is invalid. It must satisfy the function: ischar."; 'writeMatrix' is missing from optionalArgumentList (line 57), so lines 66-75 rewrite the call to problemName = 'writeMatrix', fileName = false
- **Expected**: writeMatrix is a documented name-value parameter and is accepted in any position
- **Source lines**: 57, 66-75
- **Documented in**: `test/verifiedTests/base/testIO/testWriteLPProblem.m`

### `src/base/parseMetNames.m`

#### Mixed or longer compartment notations are not parsed

- **Severity**: limitation
- **Trigger**: a list that mixes name[c] and name(c), names without brackets, or a compartment symbol longer than one character
- **Observed**: the last pattern is used: the whole text is the base name and the compartment is empty
- **Expected**: name and compartment separated
- **Source lines**: 36-38
- **Documented in**: `test/verifiedTests/base/testTools/testParseMetNames.m`

### `src/base/paths/comparePaths.m`

#### Python path entries with blanks, commas or quotes are reported as differences

- **Severity**: wrong-result
- **Trigger**: [common, system_not_matlab, matlab_not_system] = comparePaths('PYTHON') when an entry of sys.path contains a blank (also a comma or a quote); for example setenv('PYTHONPATH', fullfile(d, 'a b')) before MATLAB's Python is loaded, so that both the system python and MATLAB's Python have <d>/a b in sys.path
- **Observed**: (R2025a, 2026-11-17) <d>/a b is in sys.path of both pythons but is returned in matlab_not_system and not in common, and system_not_matlab holds <d>/ab: line 39 deletes every blank of every system entry (meant for the blanks after the commas of the printed list), and lines 32-40 split the printed list at every comma and remove every quote, also inside entries
- **Expected**: <d>/a b in common (INPUTS: NAME 'PYTHON' compares the MATLAB and system python paths; OUTPUTS: common holds the entries common to system and MATLAB), as for any path entry; blanks are valid in paths (Program Files, Application Support)
- **Source lines**: 31-40
- **Documented in**: `test/verifiedTests/base/testPaths/testComparePaths.m`

### `src/base/paths/editCobraToolboxPath.m`

#### The default basePath does nothing on Windows

- **Severity**: unusable-option
- **Trigger**: editCobraToolboxPath([], '', 'add') (or any call that omits basePath or passes it empty) on Windows, where which('initVonBertalanffy') returns a path with backslashes; reproduced on Linux with a stand-in which in the current folder that returns the real path with every '/' replaced by '\'
- **Observed**: (R2025a, 2026-11-17) "new folders on path after add: 0 of 6; path changed: 0", no error and no message; with the real which the same call adds 6 of 6. Line 21 strips 'vonBertalanffy/initVonBertalanffy.m' with a hard-coded '/', so basePath stays the path of the .m file and dir() lists no folder below it
- **Expected**: basePath is the thermo folder on every platform (strip ['vonBertalanffy' filesep 'initVonBertalanffy.m'] or use fileparts), and the folders below it that contain the pattern are added or removed as documented
- **Source lines**: 20-21, 31-32
- **Documented in**: `test/verifiedTests/base/testPaths/testEditCobraToolboxPath.m`

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

### `src/base/solvers/cardOpt/smoothConcave/SparseLP_old.m`

#### Diagnostic output is printed unconditionally

- **Severity**: cosmetic
- **Trigger**: any call, e.g. the first trigger above
- **Observed**: (R2025a, Gurobi, 2026-11-17) "err_init = 0", "err_l1 = 0" and "Elapsed time is ... seconds." are printed (statements without semicolon and toc)
- **Expected**: no console output, or output gated behind a printLevel argument
- **Source lines**: 43, 61, 87
- **Documented in**: `test/verifiedTests/base/testSmoothConcave/testSparseLP_old.m`

#### Empty inequality (or equality) block errors when the LP optimum is zero

- **Severity**: error
- **Trigger**: P = struct('Aeq', [1 -1], 'beq', 0, 'Ain', [], 'bin', [], 'lb', [-10; -10], 'ub', [10; 10]); SparseLP_old([1; -1], P, 1e-8, 5) (findMinimalSetOfRxns passes Ain = [], bin = []; Ain = zeros(0, 2), bin = zeros(0, 1) fails as well)
- **Observed**: (R2025a, Gurobi, 2026-11-17) "Incorrect dimensions for matrix multiplication" at line 49 for Ain = []; "Operands to the logical AND (&&) and OR (||) operators must be convertible to logical scalar values" at line 49 for the 0-by-2 Ain
- **Expected**: the empty block is ignored as in LPSolve, L1Solve and ThetaL0, which test isempty, and z = [0; 0] is returned (zero is feasible and optimal)
- **Source lines**: 49
- **Documented in**: `test/verifiedTests/base/testSmoothConcave/testSparseLP_old.m`

#### Output z is not assigned when every entry of the LP solution is below zeps

- **Severity**: error
- **Trigger**: P = struct('Aeq', 1, 'beq', 1e-12, 'Ain', 0, 'bin', 0, 'lb', -1, 'ub', 1); [rt, ec, nw, z] = SparseLP_old(1, P, 1e-9, 5)
- **Observed**: (R2025a, Gurobi, 2026-11-17) "Output argument "z" (and possibly others) not assigned a value in the execution with "SparseLP_old" function.": the optimum 1e-12 is not exactly 0, so the shortcut of line 49 is not taken, and the loop of line 71 does not run because init_result = 0
- **Expected**: z = 1e-12 (or the LP solution x0) with result_tab = [0, 0]
- **Source lines**: 71
- **Documented in**: `test/verifiedTests/base/testSmoothConcave/testSparseLP_old.m`

#### The zero vector is returned as the solution although it violates Aeq*x = beq

- **Severity**: wrong-result
- **Trigger**: P = struct('Aeq', eye(2), 'beq', [0; 5], 'Ain', [0 0], 'bin', 0, 'lb', [-10; -10], 'ub', [10; 10]); [rt, ec, nw, z] = SparseLP_old([1; 0], P, 1e-8, 5)
- **Observed**: (R2025a, Gurobi, 2026-11-17) rt = 0, ec = 0, nw = 0, z = [0; 0]: the zero-optimum shortcut tests max(Aeq*0 - beq) == 0, which holds when beq >= 0 has one zero entry, instead of testing that every residual is zero
- **Expected**: z = [0; 5] (the only feasible point, objective 0), result_tab = [1, 1]
- **Source lines**: 49-50
- **Documented in**: `test/verifiedTests/base/testSmoothConcave/testSparseLP_old.m`

#### Theta L0 iteration errors when the l1 solution has no positive entry

- **Severity**: error
- **Trigger**: P = struct('Aeq', 1, 'beq', -1, 'Ain', 0, 'bin', 0, 'lb', -10, 'ub', 10); SparseLP_old(0, P, 1e-8, 5)
- **Observed**: (R2025a, Gurobi, 2026-11-17) "Operands to the logical AND (&&) and OR (||) operators must be convertible to logical scalar values" in ThetaL0 at line 149: min(sol(sol > zero_precision)) is empty
- **Expected**: z = -1, result_tab = [1, 1] (the only feasible point); the smoothing function theta1 uses abs(t), so negative entries are allowed
- **Source lines**: 142, 149
- **Documented in**: `test/verifiedTests/base/testSmoothConcave/testSparseLP_old.m`

### `src/base/solvers/cplex/solveCobraLPCPLEX_2018.m`

#### An LPProblem without csense stops with an error

- **Severity**: error
- **Trigger**: LP = struct('A', sparse([1 -1 0; 0 1 -1]), 'b', [0; 0], 'c', [0; 0; 1], 'lb', zeros(3, 1), 'ub', 10 * ones(3, 1), 'osense', -1); solveCobraLPCPLEX_2018(LP)
- **Observed**: (R2025a, 2026-11-17; no CPLEX needed, the error comes before any solver call) "Colon operands must be real scalars." (MATLAB:colon:operandsNotRealScalar) at line 170: line 165 sets nMet = size(LPProblem.A), the vector [2 3], and 1:nMet is then evaluated
- **Expected**: INPUTS document .csense as optional; the code (comment "assuming equality constraints") fills one 'E' per row of A and solves
- **Source lines**: 165, 170
- **Documented in**: `test/verifiedTests/base/testSolvers/testSolveCobraLPCPLEX_2018.m`

#### The documented solution fields solver (every interface) and stat (ILOGsimple) are missing

- **Severity**: wrong-result
- **Trigger**: the LP above with LP.csense = ['E'; 'E']: solveCobraLPCPLEX_2018(LP) with TOMLAB CPLEX, and solveCobraLPCPLEX_2018(LP, 0, 0, 0, [], 0, 'ILOGsimple') with IBM ILOG CPLEX
- **Observed**: (R2025a, 2026-11-17, with stand-in cplex, Cplex, cplexlp and cplexoptimset functions on a temporary path that solve with gurobi; CPLEX is not installed) tomlab_cplex returns the fields full, dual, rcost, obj, nInfeas, sumInfeas, origStat, time, stat (no solver); ILOGsimple returns obj, full, dual, rcost, nInfeas, sumInfeas, origStat, time (no stat, no solver), obj = 10 in both. The ILOGsimple and tomlab_cplex branches never set solver, and the status block (line 519) runs only for 'tomlab_cplex'
- **Expected**: OUTPUT documents .stat (COBRA status 1/2/0/-1) and .solver for every solution
- **Source lines**: 363-421, 422-464, 519
- **Documented in**: `test/verifiedTests/base/testSolvers/testSolveCobraLPCPLEX_2018.m`

### `src/base/solvers/cplex/solveCobraLPCPLEXcard.m`

#### An LPProblem without csense stops with an error

- **Severity**: error
- **Trigger**: LP = struct('A', sparse([1 -1 0; 0 1 -1]), 'b', [0; 0], 'c', [0; 0; 1], 'lb', zeros(3, 1), 'ub', 10 * ones(3, 1), 'osense', -1); solveCobraLPCPLEXcard(LP)
- **Observed**: (R2025a, 2026-11-17; no CPLEX needed, the error comes before any solver call) "Colon operands must be real scalars." (MATLAB:colon:operandsNotRealScalar) at line 160: line 155 sets nMet = size(LPProblem.A), the vector [2 3], and 1:nMet is then evaluated
- **Expected**: INPUTS document .csense as optional; the code (comment "assuming equality constraints") fills one 'E' per row of A and solves
- **Source lines**: 155, 160
- **Documented in**: `test/verifiedTests/base/testSolvers/testSolveCobraLPCPLEXcard.m`

#### The IBM ILOG branch returns the objective of a maximisation with the wrong sign

- **Severity**: wrong-result
- **Trigger**: the LP above with LP.csense = ['E'; 'E'], IBM ILOG CPLEX (cplexlp) on the path: solveCobraLPCPLEXcard(LP)
- **Observed**: (R2025a, 2026-11-17, with stand-in Cplex and cplexlp functions on a temporary path that solve the Cplex model with gurobi; CPLEX is not installed) solution.obj = -10 with solution.full = [10; 10; 10] and stat 1. Line 331 sets the Cplex objective to -c = LPProblem.c with sense 'maximize' (line 327), so objval is LPProblem.c'*x = 10, and line 362 multiplies it by osense = -1
- **Expected**: solution.obj = LPProblem.c'*solution.full = 10, as the TOMLAB branch returns (f_k*osense, line 702)
- **Source lines**: 331, 362
- **Documented in**: `test/verifiedTests/base/testSolvers/testSolveCobraLPCPLEXcard.m`

#### The cardinality solve prints the solution structure and a minimum-Euclidean-norm note

- **Severity**: cosmetic
- **Trigger**: solveCobraLPCPLEXcard(LP, 0, 0, 0, [], 1, 'zero') with IBM ILOG CPLEX on the path (printLevel 0)
- **Observed**: (R2025a, 2026-11-17, same stand-in) "solution = struct with fields: obj: 0" is printed (line 433 has no semicolon), followed by "This objective corresponds to a flux with minimum Euclidean norm." (lines 806-809 print it for every nonzero minNorm, also for theNorm 'zero' and printLevel 0)
- **Expected**: console output gated by printLevel; no Euclidean-norm note for 'zero'
- **Source lines**: 433, 806-809
- **Documented in**: `test/verifiedTests/base/testSolvers/testSolveCobraLPCPLEXcard.m`

#### With osense = 1 the IBM ILOG branch optimises in the wrong direction

- **Severity**: wrong-result
- **Trigger**: LP = struct('A', sparse([1 -1 0; 0 1 -1]), 'b', [0; 0], 'c', [0; 0; 1], 'lb', zeros(3, 1), 'ub', 10 * ones(3, 1), 'osense', 1, 'csense', ['E'; 'E']); solveCobraLPCPLEXcard(LP) with IBM ILOG CPLEX (cplexlp) on the path (theNorm 'two', the default; also with minNorm ~= 0); the same with LP.c = [0; 0; -1]
- **Observed**: (R2025a, 2026-11-17, with stand-in Cplex and cplexlp on a temporary path that solve the Cplex model with gurobi; CPLEX is not installed) solution.full = [10; 10; 10], solution.obj = -10, stat 1, where solveCobraLP with gurobi returns the minimum full = [0; 0; 0], obj 0; with LP.c = [0; 0; -1] it returns full = [0; 0; 0], obj 0 instead of the minimum -10. Line 182 sets c = osense*LPProblem.c = LPProblem.c and line 331 passes -c with the sense 'minimize' of line 325, so -LPProblem.c is minimised and line 362 reports -LPProblem.c'*x
- **Expected**: the minimum of LPProblem.c'*x (obj 0 at x = 0; obj -10 at x = [10; 10; 10] for c = [0; 0; -1]) with solution.obj = LPProblem.c'*solution.full
- **Source lines**: 324-331, 362
- **Documented in**: `test/verifiedTests/base/testSolvers/testSolveCobraLPCPLEXcard.m`

#### theNorm 'zero' optimises the original objective in the wrong direction or reports it with the wrong sign

- **Severity**: wrong-result
- **Trigger**: the LP above with LP.csense = ['E'; 'E'] and IBM ILOG CPLEX on the path: solveCobraLPCPLEXcard(LP, 0, 0, 0, [], 1, 'zero') (maximisation); the same with minNorm = -1; and with LP.osense = 1, LP.c = [0; 0; -1] (minimisation)
- **Observed**: (R2025a, 2026-11-17, same stand-in) maximisation: solution.obj = 0 for minNorm 1 and -1, the minimum of v3 instead of the maximum 10: line 402 passes c = osense*LPProblem.c with the sense 'maximize' of line 397, so the first solve minimises v3 and line 536 (473) bounds v3 below by 0 instead of 10*beta; minimisation: solution.obj = 10 although LPProblem.c'*solution.full = -10 (line 587 negates x'*c)
- **Expected**: the first solve optimises LPProblem.c in the sense osense (as the 'two' branch does), the second solve keeps that optimum, and solution.obj is LPProblem.c'*x of the optimum
- **Source lines**: 394-398, 402, 515, 587
- **Documented in**: `test/verifiedTests/base/testSolvers/testSolveCobraLPCPLEXcard.m`

### `src/base/solvers/entropicFBA/addExoMetToEFBA.m`

#### Data for a reaction not in the model, or duplicate data, stop with an error

- **Severity**: error
- **Trigger**: addExoMetToEFBA(model, exoMet) with exoMet.rxns = {'EX_a'; 'EX_zz'} where EX_zz is not in model.rxns (or with exoMet.rxns = {'EX_a'; 'EX_a'})
- **Observed**: error "Unrecognized function or variable 'printLevel'." - lines 69 and 75 read the undefined variable printLevel instead of param.printLevel
- **Expected**: the unmatched (or duplicate) entries ignored and the penalty built from the matched data, as the help text says (exoMet.rxns "matched against model.rxns") and as lines 68-77 and 82 intend
- **Source lines**: 69, 75
- **Documented in**: `test/verifiedTests/base/testEntropicFBA/testAddExoMetToEFBA.m`

#### The default relaxBounds reads model fields that are not documented as required

- **Severity**: error
- **Trigger**: model = struct('S', [1 -1 0; 0 1 -1], 'rxns', {{'EX_a'; 'R1'; 'EX_b'}}) (the documented fields; also with model.lb and model.ub added); exoMet = struct('rxns', {{'EX_a'}}, 'mean', -1, 'SD', 0.1); addExoMetToEFBA(model, exoMet)
- **Observed**: (R2025a, 2026-11-17) Unrecognized field name "lb_preconstrainRxns". (line 123); lines 123-124 read model.lb_preconstrainRxns and model.ub_preconstrainRxns, which only metabolomicsTomodel sets; with param.relaxBounds = 0 the same call returns h = [-1; NaN; NaN] and diag(H) = [5000; 0; 0]
- **Expected**: the documented call (model with .S and .rxns, default param) returns the model with .H, .h and the relaxed bounds, or INPUTS list .lb_preconstrainRxns and .ub_preconstrainRxns as required while relaxBounds is true
- **Source lines**: 121-124
- **Documented in**: `test/verifiedTests/base/testEntropicFBA/testAddExoMetToEFBA.m`

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

### `src/base/solvers/gams/checkGAMSSolvers.m`

#### A problem type that GAMS does not list stops with an index error

- **Severity**: error
- **Trigger**: checkGAMSSolvers('MINLP') when getAvailableGAMSSolvers returns problem types {'LP', 'MIP', 'NLP'} (stubs of gams and getAvailableGAMSSolvers on a temporary path)
- **Observed**: Index in position 2 is invalid. Array indices must be positive integers or logical values. (MATLAB:badsubscript, line 50; R2025a, 2026-11-15): ismember returns position 0, never an empty position, so line 49 is always true
- **Expected**: an empty cell array, the else branch of line 52
- **Source lines**: 48-52
- **Documented in**: `test/verifiedTests/base/testSolvers/testCheckGAMSSolvers.m`

#### The existence of licememo.gms is never checked

- **Severity**: cosmetic
- **Trigger**: any call with GAMS on the MATLAB path
- **Observed**: line 41 tests whether the concatenated path string is empty, which it never is, so the error of line 42 cannot be raised
- **Expected**: the error licememo.gms in not in MATLAB path. when the file is missing
- **Source lines**: 41-42
- **Documented in**: `test/verifiedTests/base/testSolvers/testCheckGAMSSolvers.m`

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

### `src/base/solvers/getSetSolver/getCobraSolverVersion.m`

#### The documented input rootPathSolver has no effect

- **Severity**: unusable-option
- **Trigger**: getCobraSolverVersion(solverName, printLevel, rootPathSolver) with a third argument; for example global GUROBI_PATH; GUROBI_PATH = ''; getCobraSolverVersion('gurobi', 0, '/opt/gurobi1103/linux64/matlab')
- **Observed**: (R2025a, 2026-11-17) '' for GUROBI_PATH = '', and '950' for GUROBI_PATH = '/opt/gurobi950/linux64/matlab' with the same third argument: rootPathSolver is only defaulted (lines 38-40) and then overwritten (lines 88, 91, 94); the version always comes from the global path variable
- **Expected**: the version detected from the given solver installation path (INPUT rootPathSolver: "Path to the solver installation"), e.g. '1103'
- **Source lines**: 38-40, 88, 91, 94
- **Documented in**: `test/verifiedTests/base/testSolvers/testGetCobraSolverVersion.m`

### `src/base/solvers/init/configEnvVars.m`

#### GUROBI_PATH from an environment variable ending in linux64 or mac64 gets a double separator

- **Severity**: cosmetic
- **Trigger**: environment variable GUROBI_PATH = /x/gurobi1000/linux64 on Linux (no gurobi folder at a standard location on the MATLAB path)
- **Observed**: GUROBI_PATH = /x/gurobi1000//linux64/matlab (R2025a, 2026-11-15): in the regular expression \/(win64$)|(mac64$)|(linux64$) the separator belongs to the first alternative only, so only linux64 (not /linux64) is removed before /linux64/matlab is appended
- **Expected**: /x/gurobi1000/linux64/matlab
- **Source lines**: 240-241
- **Documented in**: `test/verifiedTests/base/testSolvers/testConfigEnvVars.m`

#### The call stops with an error when ENV_VARS.STATUS is not set

- **Severity**: error
- **Trigger**: configEnvVars(printLevel) when the global ENV_VARS has no field STATUS; for example clear global ENV_VARS; configEnvVars(0) (ENV_VARS = []), or global ENV_VARS; ENV_VARS = struct('printLevel', 0); configEnvVars(0)
- **Observed**: (R2025a, 2026-11-17) "Dot indexing is not supported for variables of this type." (MATLAB:structRefFromNonStruct) for ENV_VARS = [], and "Unrecognized field name "STATUS"." (MATLAB:nonExistentField) for the struct, both at line 33: exist('ENV_VARS.STATUS', 'var') is always 0 (ENV_VARS.STATUS is not a variable name), so the first test of line 33 never holds and ENV_VARS.STATUS is always read
- **Expected**: the solver paths configured, as the first test of line 33 (STATUS not yet set) intends; the USAGE configEnvVars(printLevel) states no condition on ENV_VARS
- **Source lines**: 33
- **Documented in**: `test/verifiedTests/base/testSolvers/testConfigEnvVars.m`

### `src/base/solvers/isCompatible.m`

#### The distributed compatibility matrix is not understood by the parser

- **Severity**: wrong-result
- **Trigger**: any call, with documentation/source/installation/compatMatrix.rst as distributed
- **Observed**: the file is a reStructuredText list-table, the parser only reads grid tables whose rows start with a vertical bar, so every solver gets status 2 (unverified)
- **Expected**: the status of the table: 1 for the solvers marked as tested
- **Source lines**: 98-116
- **Documented in**: `test/verifiedTests/base/testSolvers/testIsCompatible.m`

### `src/base/solvers/minos/DQQCleanup.m`

#### fort.* and *.sol files are kept when the results folder is missing

- **Severity**: limitation
- **Trigger**: DQQCleanup(tmpPath, originalDirectory) with fort.81 and a.sol in tmpPath and no folder tmpPath/results
- **Observed**: rmdir of the missing results folder raises an error that the first try block catches, so the deletion of the fort.* and *.sol files (lines 19-30) is skipped and the files stay in tmpPath
- **Expected**: the temporary solver output removed (help text: fort.* and *.sol output files to be deleted)
- **Source lines**: 18-30
- **Documented in**: `test/verifiedTests/base/testSolvers/testDQQCleanup.m`

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

### `src/base/solvers/param/parseSolverParameters.m`

#### The invalid-parameters error message shows literal \n instead of line breaks

- **Severity**: cosmetic
- **Trigger**: parseSolverParameters('LP', 'feasTol', 1e-3, 'x')
- **Observed**: the message reads "Invalid Parameters supplied.\nParameters have to be supplied ..." with the two characters \n (MATLAB R2025a); error is called with a single argument, so escape sequences are not converted
- **Expected**: three lines, as the '\n' in the message text intends
- **Source lines**: 54-56
- **Documented in**: `test/verifiedTests/base/testSolvers/testParseSolverParameters.m`

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

### `src/base/solvers/rescale/liftRows.m`

#### A well-scaled matrix stops with an error instead of being returned

- **Severity**: error
- **Trigger**: [Clifted, newcon] = liftRows([1 -1], 'L', 1000, log(1000), 0, {'c1'}, {'r1'; 'r2'})
- **Observed**: the function prints "Model.C is well scaled. Nothing to do." and returns before any output is set, so the call stops with Output argument "Clifted" (and possibly others) not assigned a value (MATLAB:unassignedOutputs; R2025a, 2026-11-15). liftCouplingConstraints(model, 1000, 0) with model.C = [1, -10], model.d = 0, model.dsense = 'L' stops with the same error at its line 386
- **Expected**: C returned unchanged with no new rows or variables (newcon, ctrs_new and evars empty, ndum = nEvars = 0), as the printed message says there is nothing to do
- **Source lines**: 44-47
- **Documented in**: `test/verifiedTests/base/testLifting/testLiftRows.m`

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

### `src/base/solvers/varKin/BDCAmethods/BDCA.m`

#### The display format is switched to longG and the status is printed

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: format longG at the start changes the display format of the session after the call, and the line Status without semicolon prints the termination reason
- **Expected**: the display format left unchanged and output gated by a print level
- **Source lines**: 61, 213
- **Documented in**: `test/verifiedTests/base/testSolvers/testBDCA.m`

#### The documented line search Quadratic_interpolation cannot be used

- **Severity**: unusable-option
- **Trigger**: options.flag_line_search = 'Quadratic_interpolation', for example with F = [1 0; 0 1], R = [0 1; 1 0], kin = zeros(4, 1), x0 = [0.5; -0.3] and mapp = @(x) [F - R, R - F] * exp(kin + [F, R]' * x)
- **Observed**: the first iteration stops with "Unrecognized function or variable 'lambda'." (MATLAB:UndefinedFunction, line 153; R2025a, 2026-11-15); the branch also uses the undefined f, nfyk and, through df, p
- **Expected**: a step length from the quadratic interpolation of the merit function along dk
- **Source lines**: 112, 151-161
- **Documented in**: `test/verifiedTests/base/testSolvers/testBDCA.m`

#### The option flag_psi_error cannot be used

- **Severity**: unusable-option
- **Trigger**: options.flag_psi_error = 1 with options.psi_opt = 0 (same model as above)
- **Observed**: the first iteration stops with "Unrecognized function or variable 'psi_opt'." (MATLAB:UndefinedFunction, line 196); options.psi_opt is never read and psi0 is never set
- **Expected**: out.psi_error, the relative error (psi_k - psi_opt)/(psi_0 - psi_opt) of each iteration
- **Source lines**: 99-101, 195-197, 227-229
- **Documented in**: `test/verifiedTests/base/testSolvers/testBDCA.m`

#### x_error and Time have a spurious zero in position 2

- **Severity**: wrong-result
- **Trigger**: options.flag_x_error = 1, options.x_opt = [1; 1], options.flag_time = 1, options.MaxNumIter = 3, options.Stopping_Crit = 2 (same model as above)
- **Observed**: out.Niter = 3, out.Xk has 3 columns, out.x_error = [0.9849 0 0.9774 0.9767] and out.Time = [0 0 0.0163 0.0221]: Niter starts at 1 and is incremented before x_error(Niter + 1) and Time(Niter + 1) are written, so element 2 is never assigned
- **Expected**: one entry per point of out.Xk (x0 and each iterate), x_error(k) the relative error of Xk(:, k)
- **Source lines**: 186-193
- **Documented in**: `test/verifiedTests/base/testSolvers/testBDCA.m`

### `src/base/solvers/varKin/BDCAmethods/DCA.m`

#### The display format is switched to longG and Niter and the status are printed

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: format longG at the start changes the display format of the session after the call, and the lines Niter = Niter+1 and Status without semicolon print the iteration counter at every iteration and the termination reason
- **Expected**: the display format left unchanged and output gated by a print level
- **Source lines**: 61, 144, 175
- **Documented in**: `test/verifiedTests/base/testSolvers/testDCA.m`

#### The option flag_psi_error cannot be used

- **Severity**: unusable-option
- **Trigger**: options.flag_psi_error = 1 with options.psi_opt = 0, for example with F = [1 0; 0 1], R = [0 1; 1 0], kin = zeros(4, 1), x0 = [0.5; -0.3] and mapp = @(x) [F - R, R - F] * exp(kin + [F, R]' * x)
- **Observed**: the first iteration stops with "Unrecognized function or variable 'psi_opt'." (MATLAB:UndefinedFunction, line 158; R2025a, 2026-11-15); options.psi_opt is never read and psi0 is never set
- **Expected**: out.psi_error, the relative error (psi_k - psi_opt)/(psi_0 - psi_opt) of each iteration
- **Source lines**: 99-101, 157-159, 189-191
- **Documented in**: `test/verifiedTests/base/testSolvers/testDCA.m`

#### x_error and Time have a spurious zero in position 2

- **Severity**: wrong-result
- **Trigger**: options.flag_x_error = 1, options.x_opt = [1; 1], options.flag_time = 1, options.MaxNumIter = 3, options.Stopping_Crit = 2 (same model as above)
- **Observed**: (R2025a, 2026-11-15) out.Niter = 3, out.Xk has 3 columns, out.x_error = [0.9849 0 0.9603 0.9449] and out.Time = [0 0 0.00429 0.00608]: Niter starts at 1 and is incremented before x_error(Niter + 1) and Time(Niter + 1) are written, so element 2 is never assigned
- **Expected**: one entry per point of out.Xk (x0 and each iterate), x_error(k) the relative error of Xk(:, k)
- **Source lines**: 148-155, 186-188, 192-194
- **Documented in**: `test/verifiedTests/base/testSolvers/testDCA.m`

### `src/base/solvers/varKin/derFreeMethods/BDF.m`

#### The display format is switched to longG and the status is printed

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: format longG at the start changes the display format of the session after the call, and the line Status without semicolon prints the termination reason
- **Expected**: the display format left unchanged and output gated by a print level
- **Source lines**: 51, 168
- **Documented in**: `test/verifiedTests/base/testSolvers/testBDF.m`

#### The option flag_psi_error cannot be used

- **Severity**: unusable-option
- **Trigger**: options.flag_psi_error = 1 with options.psi_opt = 0, for example with F = [1 0; 0 1], R = [0 1; 1 0], kin = zeros(4, 1), x0 = [0.5; -0.3] and mapp = @(x) [F - R, R - F] * exp(kin + [F, R]' * x)
- **Observed**: the first iteration stops with "Unrecognized function or variable 'psi_opt'." (MATLAB:UndefinedFunction, line 151; R2025a, 2026-11-15); options.psi_opt is never read and psi0 is never set
- **Expected**: out.psi_error, the relative error (psi_k - psi_opt)/(psi_0 - psi_opt) of each iteration
- **Source lines**: 89-91, 150-152, 182-184
- **Documented in**: `test/verifiedTests/base/testSolvers/testBDF.m`

#### out.Xk holds only the starting point

- **Severity**: wrong-result
- **Trigger**: options.MaxNumIter = 3, options.Stopping_Crit = 2 (same model as above): [x_best, psi_best, out] = BDF(mapp, x0, options)
- **Observed**: (R2025a, 2026-11-17) out.Niter = 3 but out.Xk = [0.5; -0.3] (2 x 1), i.e. x0, while x_best = [0.16495; 0.035046]: line 99 sets Xk = x0 and the loop never appends an iterate, so line 171 returns x0
- **Expected**: out.Xk holds the iterates, one column per iteration, as the sibling methods DCA, BDCA and LLM of src/base/solvers/varKin store them (Xk(:, Niter) = xk)
- **Source lines**: 99, 135-140, 171
- **Documented in**: `test/verifiedTests/base/testSolvers/testBDF.m`

#### x_error and Time have a spurious zero in position 2

- **Severity**: wrong-result
- **Trigger**: options.flag_x_error = 1, options.x_opt = [1; 1], options.flag_time = 1, options.MaxNumIter = 3, options.Stopping_Crit = 2 (same model as above)
- **Observed**: (R2025a, 2026-11-15) out.Niter = 3, out.x_error = [0.9849 0 0.9154 0.9023] and out.Time = [0 0 0.000576 0.00144]: Niter starts at 1 and is incremented before x_error(Niter + 1) and Time(Niter + 1) are written, so element 2 is never assigned
- **Expected**: one entry per point (x0 and each iterate), x_error(k) the relative error of the k-th point
- **Source lines**: 141-148, 179-181, 185-187
- **Documented in**: `test/verifiedTests/base/testSolvers/testBDF.m`

### `src/base/solvers/varKin/derFreeMethods/CSDF.m`

#### The display format is switched to longG and Niter and the status are printed

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: format longG at the start changes the display format of the session after the call, and the lines Niter = Niter+1 and Status without semicolon print the iteration counter at every iteration and the termination reason
- **Expected**: the display format left unchanged and output gated by a print level
- **Source lines**: 53, 123, 158
- **Documented in**: `test/verifiedTests/base/testSolvers/testCSDF.m`

#### The option flag_psi_error cannot be used

- **Severity**: unusable-option
- **Trigger**: options.flag_psi_error = 1 with options.psi_opt = 0, for example with F = [1 0; 0 1], R = [0 1; 1 0], kin = zeros(4, 1), x0 = [0.5; -0.3] and mapp = @(x) [F - R, R - F] * exp(kin + [F, R]' * x)
- **Observed**: the first iteration stops with "Unrecognized function or variable 'psi_opt'." (MATLAB:UndefinedFunction, line 141; R2025a, 2026-11-15); options.psi_opt is never read and psi0 is never set
- **Expected**: out.psi_error, the relative error (psi_k - psi_opt)/(psi_0 - psi_opt) of each iteration
- **Source lines**: 91-93, 140-142, 172-174
- **Documented in**: `test/verifiedTests/base/testSolvers/testCSDF.m`

#### x_error and Time have a spurious zero in position 2

- **Severity**: wrong-result
- **Trigger**: options.flag_x_error = 1, options.x_opt = [1; 1], options.flag_time = 1, options.MaxNumIter = 3, options.Stopping_Crit = 2 (same model as above)
- **Observed**: (R2025a, 2026-11-15) out.Niter = 3, out.x_error = [0.9849 0 0.9777 0.971] and out.Time = [0 0 9.8e-05 0.000397]: Niter starts at 1 and is incremented before x_error(Niter + 1) and Time(Niter + 1) are written, so element 2 is never assigned
- **Expected**: one entry per point (x0 and each iterate), x_error(k) the relative error of the k-th point
- **Source lines**: 131-138, 169-171, 175-177
- **Documented in**: `test/verifiedTests/base/testSolvers/testCSDF.m`

### `src/base/solvers/varKin/derFreeMethods/DBDF.m`

#### The display format is switched to longG and the status is printed

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: format longG at the start changes the display format of the session after the call, and the line Status without semicolon prints the termination reason
- **Expected**: the display format left unchanged and output gated by a print level
- **Source lines**: 55, 176
- **Documented in**: `test/verifiedTests/base/testSolvers/testDBDF.m`

#### The option flag_psi_error cannot be used

- **Severity**: unusable-option
- **Trigger**: options.flag_psi_error = 1 with options.psi_opt = 0, for example with F = [1 0; 0 1], R = [0 1; 1 0], kin = zeros(4, 1), x0 = [0.5; -0.3] and mapp = @(x) [F - R, R - F] * exp(kin + [F, R]' * x)
- **Observed**: the first iteration stops with "Unrecognized function or variable 'psi_opt'." (MATLAB:UndefinedFunction, line 159; R2025a, 2026-11-15); options.psi_opt is never read and psi0 is never set
- **Expected**: out.psi_error, the relative error (psi_k - psi_opt)/(psi_0 - psi_opt) of each iteration
- **Source lines**: 93-95, 158-160, 190-192
- **Documented in**: `test/verifiedTests/base/testSolvers/testDBDF.m`

#### x_error and Time have a spurious zero in position 2

- **Severity**: wrong-result
- **Trigger**: options.flag_x_error = 1, options.x_opt = [1; 1], options.flag_time = 1, options.MaxNumIter = 3, options.Stopping_Crit = 2 (same model as above)
- **Observed**: (R2025a, 2026-11-15) out.Niter = 3, out.x_error = [0.9849 0 0.9016 0.9] and out.Time = [0 0 0.000214 0.00115]: Niter starts at 1 and is incremented before x_error(Niter + 1) and Time(Niter + 1) are written, so element 2 is never assigned
- **Expected**: one entry per point (x0 and each iterate), x_error(k) the relative error of the k-th point
- **Source lines**: 149-156, 187-189, 193-195
- **Documented in**: `test/verifiedTests/base/testSolvers/testDBDF.m`

### `src/base/solvers/varKin/levMarMethods/GLM_FY.m`

#### The display format is switched to longG and the status is printed

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: format longG at the start changes the display format of the session after the call, and the line Status without semicolon prints the termination reason; the line Niter = Niter+1 without semicolon in the line-search branch prints the iteration count
- **Expected**: the display format left unchanged and output gated by a print level
- **Source lines**: 60, 173, 211
- **Documented in**: `test/verifiedTests/base/testSolvers/testGLM_FY.m`

#### The option flag_psi_error cannot be used

- **Severity**: unusable-option
- **Trigger**: options.flag_psi_error = 1 with options.psi_opt = 0, for example with F = [1 0; 0 1], R = [0 1; 1 0], opt = struct('FR', [F, R], 'FR_RF', [F - R, R - F], 'k', zeros(4, 1)), mapp = @(varargin) Rate_function1(opt, varargin{:}), lin_sym_solver = @(varargin) lin_sym_solver_mldivide(varargin{:}), x0 = [0.5; -0.3], options = struct('MaxNumIter', 50, 'lambda', 1, 'xi_k', 1, 'adaptive', 0)
- **Observed**: the first iteration stops with "Unrecognized function or variable 'psi_opt'." (MATLAB:UndefinedFunction, line 194; R2025a, 2026-11-15); options.psi_opt is never read and psi0 is never set
- **Expected**: out.psi_error, the relative error (psi_k - psi_opt)/(psi_0 - psi_opt) of each iteration
- **Source lines**: 108-110, 193-195, 225-227
- **Documented in**: `test/verifiedTests/base/testSolvers/testGLM_FY.m`

#### x_error and Time have a spurious zero in position 2

- **Severity**: wrong-result
- **Trigger**: options.flag_x_error = 1, options.x_opt = [1; 1], options.flag_time = 1, options.MaxNumIter = 4, options.Stopping_Crit = 3 (same model and start as above)
- **Observed**: out.Niter = 4, out.x_error = [0.9849 0 1.02 1.024 1.024] and out.Time = [0 0 5.1e-05 0.00149 0.00203]: Niter starts at 1 and is incremented before x_error(Niter + 1) and Time(Niter + 1) are written, so element 2 is never assigned and the vectors hold one entry more than the points x0, x_2, ..., x_Niter
- **Expected**: one entry per point (x0 and each iterate), x_error(k) the relative error of the k-th point and Time(k) its time
- **Source lines**: 117, 153, 173, 184-191
- **Documented in**: `test/verifiedTests/base/testSolvers/testGLM_FY.m`

### `src/base/solvers/varKin/levMarMethods/GLM_YF.m`

#### The display format is switched to longG and the status is printed

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: format longG at the start changes the display format of the session after the call, and the line Status without semicolon prints the termination reason; the line Niter = Niter+1 without semicolon in the line-search branch prints the iteration count
- **Expected**: the display format left unchanged and output gated by a print level
- **Source lines**: 60, 173, 211
- **Documented in**: `test/verifiedTests/base/testSolvers/testGLM_YF.m`

#### The option flag_psi_error cannot be used

- **Severity**: unusable-option
- **Trigger**: options.flag_psi_error = 1 with options.psi_opt = 0, for example with F = [1 0; 0 1], R = [0 1; 1 0], opt = struct('FR', [F, R], 'FR_RF', [F - R, R - F], 'k', zeros(4, 1)), mapp = @(varargin) Rate_function1(opt, varargin{:}), lin_sym_solver = @(varargin) lin_sym_solver_mldivide(varargin{:}), x0 = [0.5; -0.3], options = struct('MaxNumIter', 50, 'lambda', 1, 'xi_k', 1, 'adaptive', 0)
- **Observed**: the first iteration stops with "Unrecognized function or variable 'psi_opt'." (MATLAB:UndefinedFunction, line 194; R2025a, 2026-11-15); options.psi_opt is never read and psi0 is never set
- **Expected**: out.psi_error, the relative error (psi_k - psi_opt)/(psi_0 - psi_opt) of each iteration
- **Source lines**: 108-110, 193-195, 225-227
- **Documented in**: `test/verifiedTests/base/testSolvers/testGLM_YF.m`

#### x_error and Time have a spurious zero in position 2

- **Severity**: wrong-result
- **Trigger**: options.flag_x_error = 1, options.x_opt = [1; 1], options.flag_time = 1, options.MaxNumIter = 4, options.Stopping_Crit = 3 (same model and start as above)
- **Observed**: out.Niter = 4, out.x_error = [0.9849 0 1.01 1.018 1.018] and out.Time = [0 0 0.00131 0.00264 0.00305]: Niter starts at 1 and is incremented before x_error(Niter + 1) and Time(Niter + 1) are written, so element 2 is never assigned and the vectors hold one entry more than the points x0, x_2, ..., x_Niter
- **Expected**: one entry per point (x0 and each iterate), x_error(k) the relative error of the k-th point and Time(k) its time
- **Source lines**: 117, 153, 173, 184-191
- **Documented in**: `test/verifiedTests/base/testSolvers/testGLM_YF.m`

### `src/base/solvers/varKin/levMarMethods/LLM.m`

#### The display format is switched to longG and the status is printed

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: format longG at the start changes the display format of the session after the call, and the line Status without semicolon prints the termination reason
- **Expected**: the display format left unchanged and output gated by a print level
- **Source lines**: 61, 201
- **Documented in**: `test/verifiedTests/base/testSolvers/testLLM.m`

#### The option flag_psi_error cannot be used

- **Severity**: unusable-option
- **Trigger**: options.flag_psi_error = 1 with options.psi_opt = 0, for example with F = [1 0; 0 1], R = [0 1; 1 0], opt = struct('FR', [F, R], 'FR_RF', [F - R, R - F], 'k', zeros(4, 1)), mapp = @(varargin) Rate_function1(opt, varargin{:}), lin_sym_solver = @(varargin) lin_sym_solver_mldivide(varargin{:}), x0 = [0.5; -0.3], options = struct('MaxNumIter', 50, 'lambda', 1, 'xi_k', 1, 'adaptive', 0)
- **Observed**: the first iteration stops with "Unrecognized function or variable 'psi_opt'." (MATLAB:UndefinedFunction, line 183; R2025a, 2026-11-15); options.psi_opt is never read and psi0 is never set
- **Expected**: out.psi_error, the relative error (psi_k - psi_opt)/(psi_0 - psi_opt) of each iteration
- **Source lines**: 109-111, 182-184, 216-218
- **Documented in**: `test/verifiedTests/base/testSolvers/testLLM.m`

#### x_error and Time have a spurious zero in position 2

- **Severity**: wrong-result
- **Trigger**: options.flag_x_error = 1, options.x_opt = [1; 1], options.flag_time = 1, options.MaxNumIter = 4, options.Stopping_Crit = 3 (same model and start as above)
- **Observed**: out.Niter = 4, out.x_error = [0.9849 0 1.02 1.024 1.024] and out.Time = [0 0 4.9e-05 0.00212 0.00262]: Niter starts at 1 and is incremented before x_error(Niter + 1) and Time(Niter + 1) are written, so element 2 is never assigned and the vectors hold one entry more than the points x0, x_2, ..., x_Niter
- **Expected**: one entry per point (x0 and each iterate), x_error(k) the relative error of the k-th point and Time(k) its time
- **Source lines**: 120, 153, 173-180
- **Documented in**: `test/verifiedTests/base/testSolvers/testLLM.m`

### `src/base/solvers/varKin/levMarMethods/LMLS.m`

#### The display format is switched to longG and the status is printed

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: format longG at the start changes the display format of the session after the call, and the line Status without semicolon prints the termination reason
- **Expected**: the display format left unchanged and output gated by a print level
- **Source lines**: 62, 225
- **Documented in**: `test/verifiedTests/base/testSolvers/testLMLS.m`

#### The option flag_psi_error cannot be used

- **Severity**: unusable-option
- **Trigger**: options.flag_psi_error = 1 with options.psi_opt = 0, for example with F = [1 0; 0 1], R = [0 1; 1 0], opt = struct('FR', [F, R], 'FR_RF', [F - R, R - F], 'k', zeros(4, 1)), mapp = @(varargin) Rate_function1(opt, varargin{:}), lin_sym_solver = @(varargin) lin_sym_solver_mldivide(varargin{:}), x0 = [0.5; -0.3], options = struct('MaxNumIter', 50, 'lambda', 1, 'xi_k', 1, 'adaptive', 0)
- **Observed**: the first iteration stops with "Unrecognized function or variable 'psi_opt'." (MATLAB:UndefinedFunction, line 205; R2025a, 2026-11-15); options.psi_opt is never read and psi0 is never set
- **Expected**: out.psi_error, the relative error (psi_k - psi_opt)/(psi_0 - psi_opt) of each iteration
- **Source lines**: 110-112, 204-206, 239-241
- **Documented in**: `test/verifiedTests/base/testSolvers/testLMLS.m`

#### x_error and Time have a spurious zero in position 2

- **Severity**: wrong-result
- **Trigger**: options.flag_x_error = 1, options.x_opt = [1; 1], options.flag_time = 1, options.MaxNumIter = 4, options.Stopping_Crit = 3 (same model and start as above)
- **Observed**: out.Niter = 4, out.x_error = [0.9849 0 1.02 1.024 1.024] and out.Time = [0 0 3.7e-05 0.00186 0.00231]: Niter starts at 1 and is incremented before x_error(Niter + 1) and Time(Niter + 1) are written, so element 2 is never assigned and the vectors hold one entry more than the points x0, x_2, ..., x_Niter
- **Expected**: one entry per point (x0 and each iterate), x_error(k) the relative error of the k-th point and Time(k) its time
- **Source lines**: 119, 174, 195-202
- **Documented in**: `test/verifiedTests/base/testSolvers/testLMLS.m`

### `src/base/solvers/varKin/levMarMethods/LMTR.m`

#### The display format is switched to longG and the status is printed

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: format longG at the start changes the display format of the session after the call, and the line Status without semicolon prints the termination reason
- **Expected**: the display format left unchanged and output gated by a print level
- **Source lines**: 62, 244
- **Documented in**: `test/verifiedTests/base/testSolvers/testLMTR.m`

#### The option flag_psi_error cannot be used

- **Severity**: unusable-option
- **Trigger**: options.flag_psi_error = 1 with options.psi_opt = 0, for example with F = [1 0; 0 1], R = [0 1; 1 0], opt = struct('FR', [F, R], 'FR_RF', [F - R, R - F], 'k', zeros(4, 1)), mapp = @(varargin) Rate_function1(opt, varargin{:}), lin_sym_solver = @(varargin) lin_sym_solver_mldivide(varargin{:}), x0 = [0.5; -0.3], options = struct('MaxNumIter', 50, 'lambda', 1, 'xi_k', 1, 'adaptive', 0)
- **Observed**: the first iteration stops with "Unrecognized function or variable 'psi_opt'." (MATLAB:UndefinedFunction, line 227; R2025a, 2026-11-15); options.psi_opt is never read and psi0 is never set
- **Expected**: out.psi_error, the relative error (psi_k - psi_opt)/(psi_0 - psi_opt) of each iteration
- **Source lines**: 110-112, 226-228, 258-260
- **Documented in**: `test/verifiedTests/base/testSolvers/testLMTR.m`

#### x_error and Time have a spurious zero in position 2

- **Severity**: wrong-result
- **Trigger**: options.flag_x_error = 1, options.x_opt = [1; 1], options.flag_time = 1, options.MaxNumIter = 4, options.Stopping_Crit = 3 (same model and start as above)
- **Observed**: out.Niter = 4, out.x_error = [0.9849 0 1.028 1.031 1.031] and out.Time = [0 0 0.00158 0.00329 0.00373]: Niter starts at 1 and is incremented before x_error(Niter + 1) and Time(Niter + 1) are written, so element 2 is never assigned and the vectors hold one entry more than the points x0, x_2, ..., x_Niter
- **Expected**: one entry per point (x0 and each iterate), x_error(k) the relative error of the k-th point and Time(k) its time
- **Source lines**: 119, 194, 217-224
- **Documented in**: `test/verifiedTests/base/testSolvers/testLMTR.m`

### `src/base/solvers/varKin/levMarMethods/LevMar.m`

#### The display format is switched to longG and the status is printed

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: format longG at the start changes the display format of the session after the call, and the line Status without semicolon prints the termination reason
- **Expected**: the display format left unchanged and output gated by a print level
- **Source lines**: 61, 229
- **Documented in**: `test/verifiedTests/base/testSolvers/testLevMar.m`

#### The number of gradient evaluations is always reported as 1

- **Severity**: wrong-result
- **Trigger**: any call that iterates, for example the model and options of the first entry
- **Observed**: out.Niter = 7, out.Nmap = 13 and out.Ngmap = 1, although the Jacobian is evaluated in every iteration ([hxk, ghxk] = mapp(xk)) without Ngmap being incremented, so the stopping rule MaxNumGmapEval (Stopping_Crit = 5) never stops the solver
- **Expected**: out.Ngmap, the documented total number of mapping gradient evaluations
- **Source lines**: 128, 194-195, 237
- **Documented in**: `test/verifiedTests/base/testSolvers/testLevMar.m`

#### The option flag_psi_error cannot be used

- **Severity**: unusable-option
- **Trigger**: options.flag_psi_error = 1 with options.psi_opt = 0, for example with F = [1 0; 0 1], R = [0 1; 1 0], opt = struct('FR', [F, R], 'FR_RF', [F - R, R - F], 'k', zeros(4, 1)), mapp = @(varargin) Rate_function1(opt, varargin{:}), lin_sym_solver = @(varargin) lin_sym_solver_mldivide(varargin{:}), x0 = [0.5; -0.3], options = struct('MaxNumIter', 50, 'lambda', 1, 'xi_k', 1, 'adaptive', 0)
- **Observed**: the first iteration stops with "Unrecognized function or variable 'psi_opt'." (MATLAB:UndefinedFunction, line 212; R2025a, 2026-11-15); options.psi_opt is never read and psi0 is never set
- **Expected**: out.psi_error, the relative error (psi_k - psi_opt)/(psi_0 - psi_opt) of each iteration
- **Source lines**: 109-111, 211-213, 243-245
- **Documented in**: `test/verifiedTests/base/testSolvers/testLevMar.m`

#### x_error and Time have a spurious zero in position 2

- **Severity**: wrong-result
- **Trigger**: options.flag_x_error = 1, options.x_opt = [1; 1], options.flag_time = 1, options.MaxNumIter = 4, options.Stopping_Crit = 3 (same model and start as above)
- **Observed**: out.Niter = 4, out.x_error = [0.9849 0 1 1.008 1.009] and out.Time = [0 0 3e-05 0.000579 0.000734]: Niter starts at 1 and is incremented before x_error(Niter + 1) and Time(Niter + 1) are written, so element 2 is never assigned and the vectors hold one entry more than the points x0, x_2, ..., x_Niter
- **Expected**: one entry per point (x0 and each iterate), x_error(k) the relative error of the k-th point and Time(k) its time
- **Source lines**: 125, 177, 182, 202-209
- **Documented in**: `test/verifiedTests/base/testSolvers/testLevMar.m`

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

- **Severity**: wrong-result
- **Trigger**: [M, duplicateBool] = duplicates({'a', 'a', 'b'})
- **Observed**: M = [0 1] (1 x 2) and duplicateBool = [0; 1] (2 x 1) for an input with one row
- **Expected**: M of size m x m and duplicateBool of size m x 1 (m = 1 here), as documented. Severity audit 2026-11-15: INPUT documents "A: m x n array (compatible with `unique`)" and OUTPUTS "M: m x m", "duplicateBool: m x 1"; for a 1 x 3 cell (a documented m x n input) M is 1 x 2 and duplicateBool 2 x 1 because line 50 calls unique element-wise
- **Source lines**: 50
- **Documented in**: `test/verifiedTests/base/testTools/testDuplicates.m`

### `src/base/utilities/generateStructFunction.m`

#### A char matrix with more than one row is written column by column

- **Severity**: wrong-result
- **Trigger**: generateStructFunction(struct('h', ['ab'; 'cd']), 'myStruct')
- **Observed**: the line myStruct.h = 'acbd'; is written (fprintf reads the matrix in column order), so the script recreates a different 1 x 4 value (R2025a, 2026-11-15)
- **Expected**: the 2 x 2 char matrix recreated, for example through mat2str; the header promises that "running the generated file recreates those field values" (severity audit T009a)
- **Source lines**: 33
- **Documented in**: `test/verifiedTests/base/testUtilities/testGenerateStructFunction.m`

#### A char value with a quote gives a script that cannot run

- **Severity**: wrong-result
- **Trigger**: generateStructFunction(struct('f', 'it''s'), 'myStruct')
- **Observed**: the line myStruct.f = 'it's'; is written without doubling the quote, and running the script stops with "Invalid expression. Check for missing multiplication operator, missing or unbalanced delimiters, or other syntax error." (R2025a, 2026-11-15)
- **Expected**: the quote doubled (myStruct.f = 'it''s';), so that the value is recreated; the header promises that "running the generated file recreates those field values" (severity audit T009a)
- **Source lines**: 33
- **Documented in**: `test/verifiedTests/base/testUtilities/testGenerateStructFunction.m`

#### A numeric array with more than two dimensions stops with an error and leaves the file open

- **Severity**: error
- **Trigger**: generateStructFunction(struct('z', ones(2, 2, 2)), 'nd')
- **Observed**: "Input matrix must be 2-D." (MATLAB:mat2str:TwoDInput, line 30; R2025a, 2026-11-15); the file nd_init.m opened at line 24 stays open (openedFiles lists it)
- **Expected**: the field written (for example through reshape) or skipped, and the file closed; S is documented as a "struct whose numeric and char fields are written out", so a numeric field with three dimensions is a documented input that fails when used (severity audit T009a)
- **Source lines**: 24, 30, 36
- **Documented in**: `test/verifiedTests/base/testUtilities/testGenerateStructFunction.m`

#### Numeric values lose their class and digits beyond the 15th

- **Severity**: wrong-result
- **Trigger**: generateStructFunction(struct('d', pi, 'e', int8(5)), 'myStruct')
- **Observed**: the lines myStruct.d = 3.14159265358979; and myStruct.e = 5; are written (mat2str with its default precision of 15 digits and without the 'class' option), so the script recreates pi - 3.2e-15 and a double 5 (R2025a, 2026-11-15)
- **Expected**: the values recreated as they were (mat2str(val, 17, 'class')); the header promises that "running the generated file recreates those field values" (severity audit T009a, borderline: precision)
- **Source lines**: 30
- **Documented in**: `test/verifiedTests/base/testUtilities/testGenerateStructFunction.m`

### `src/base/utilities/getGlobalValue.m`

#### The value of a global named globalName cannot be read

- **Severity**: limitation
- **Trigger**: getGlobalValue('globalName')
- **Observed**: the function declares its own argument variable global, so the text it then evaluates is no longer the name; MATLAB raises MATLAB:m_illegal_character
- **Expected**: the value of the global variable globalName, as for any other name
- **Source lines**: 13-14
- **Documented in**: `test/verifiedTests/base/testUtilities/testGetGlobalValue.m`

### `src/base/utilities/issueConfirmationWarning.m`

#### The confirmation is asked only on a jenkins home, the opposite of the documentation

- **Severity**: wrong-result
- **Trigger**: any call, for example issueConfirmationWarning('probe message') on a machine whose HOME does not contain 'jenkins'
- **Observed**: the warning is issued and the function returns at once without asking for a confirmation; with HOME set to '/var/lib/jenkins' (setenv) it calls input and, in a -batch session, stops with "Support for user input is required, which is not available on this platform." (MATLAB:services:MissingRequiredCapability, line 22; R2025a, 2026-11-15)
- **Expected**: as the help text ("blocks execution until confirmation by the user") and the comment of line 21 ("stall only if we are NOT on jenkins! I.e. not on the CI") say, ask for a confirmation outside jenkins and continue without asking on jenkins
- **Source lines**: 20-26
- **Documented in**: `test/verifiedTests/base/testUtilities/testIssueConfirmationWarning.m`

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

### `src/dataIntegration/XomicsToModel/analysis/plotOverlapResults.m`

#### The optional input savepath cannot be used

- **Severity**: unusable-option
- **Trigger**: plotOverlapResults(overlapResults, statistic, savepath) with [overlapResults, statistic] = compareXomicsModels(models), models.mA = struct('mets', {{'a'; 'b'; 'c'}}, 'rxns', {{'r1'; 'r2'}}, 'genes', {{'g1'}}), models.mB = struct('mets', {{'b'; 'c'; 'd'; 'e'}}, 'rxns', {{'r2'; 'r3'}}, 'genes', {{'g1'; 'g2'}}) and savepath an existing folder fullfile(tempname, 'models_test')
- **Observed**: the call stops with "Unrecognized function or variable 'ax'." (MATLAB:UndefinedFunction, line 64; R2025a, 2026-11-15): the axes handle ax exists only in the local function plotHeatmapWithLabels; before the error, cd(savepath) has changed the working directory of the session to savepath, and no file is written
- **Expected**: the figure saved as overlap_test.fig in savepath, with the working directory of the session unchanged
- **Source lines**: 60-65
- **Documented in**: `test/verifiedTests/dataIntegration/testXomicsToModel/testPlotOverlapResults.m`

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

### `src/dataIntegration/XomicsToModel/metabolomics/plotPredictedExchange.m`

#### The option saveFigures cannot be used

- **Severity**: unusable-option
- **Trigger**: plotPredictedExchange(predictedFluxes, [], [], struct('saveFigures', 1)) with predictedFluxes = table({'EX_a'; 'EX_b'; 'EX_c'}, [-2; 0; 3], [-5; -1; 0], [0; 1; 5], {'A'; 'B'; 'C'}, 'VariableNames', {'rxns', 'v', 'lb', 'ub', 'metNames'}) and predictedFluxes.Properties.Description = 'pred'
- **Observed**: after the plot is drawn the call stops with "Unrecognized function or variable 'names'." (MATLAB:UndefinedFunction, line 421; R2025a, 2026-11-15); the file name is built from a variable that is never set
- **Expected**: the figure saved as .fig and .png in the current directory
- **Source lines**: 420-423
- **Documented in**: `test/verifiedTests/dataIntegration/testXomicsToModel/testPlotPredictedExchange.m`

#### extraFluxes without otherFluxes stops with an error

- **Severity**: error
- **Trigger**: plotPredictedExchange(predictedFluxes, [], extraFluxes) with predictedFluxes as above and extraFluxes = table({'EX_a'; 'EX_b'; 'EX_c'}, [-1; 0; 2], [0.1; 0.1; 0.1], 'VariableNames', {'rxns', 'mean', 'SD'}), Description 'extra'
- **Observed**: "Unrecognized function or variable 'v2'." (MATLAB:UndefinedFunction, line 241; R2025a, 2026-11-15): the limits and the NaN filter of the extra fluxes use the transformed otherFluxes, which exist only when otherFluxes is given
- **Expected**: the predicted and the extra fluxes plotted (both inputs are documented as optional)
- **Source lines**: 241-244
- **Documented in**: `test/verifiedTests/dataIntegration/testXomicsToModel/testPlotPredictedExchange.m`

#### predictedFluxes without lb and ub stops with an error

- **Severity**: limitation
- **Trigger**: plotPredictedExchange(predictedFluxes(:, {'rxns', 'v', 'metNames'})) with predictedFluxes as above
- **Observed**: "Unable to resolve the name 'measuredFluxes.mean'." (MATLAB:undefinedVarOrClass, line 170; R2025a, 2026-11-15): the branch for tables without bounds uses the undefined variables measuredFluxes and x
- **Expected**: the documented input lists lb and ub; without them, a plot without bounds or an explicit error message
- **Source lines**: 170-173
- **Documented in**: `test/verifiedTests/dataIntegration/testXomicsToModel/testPlotPredictedExchange.m`

### `src/dataIntegration/XomicsToModel/metabolomics/summaryConcentrations.m`

#### A compound whose name contains another compound's name receives that metabolite

- **Severity**: wrong-result
- **Trigger**: the table above with param.model.mets = {'cit[e]'; 'icit[c]'} and param.model.metNames = {'Citrate'; 'Isocitrate'}
- **Observed**: summaryConc.avr_A.mets = ["cit[e]"; "cit[e]"] (R2025a, 2026-11-15): line 73 selects every compound that contains "citrate", including "isocitrate", and the isocitrate pass does not reset it because Isocitrate has no [e] form
- **Expected**: ["cit[e]"; ""] - isocitrate has no extracellular metabolite in the model
- **Source lines**: 73
- **Documented in**: `test/verifiedTests/dataIntegration/testXomicsToModel/testSummaryConcentrations.m`

#### param.metLookupTable without param.model stops with an undefined variable

- **Severity**: error
- **Trigger**: summaryConcentrations(T, param) with param.metLookupTable = table({'citrate'}, {'cit'}, {'cit[e]'}, 'VariableNames', {'ChemicalName', 'AlternativeName', 'Mets'}) and no param.model; T a table with string columns sample, type, compound, concentration, group, perturbation and compounds "citrate" and "isocitrate"
- **Observed**: Unrecognized function or variable 'model'. (line 97; R2025a, 2026-11-15)
- **Expected**: the documentation allows the lookup table alone ("either ... or/and"); the compound citrate mapped to cit[e]
- **Source lines**: 97, 102
- **Documented in**: `test/verifiedTests/dataIntegration/testXomicsToModel/testSummaryConcentrations.m`

### `src/dataIntegration/XomicsToModel/proteomics/activeProteinList.m`

#### The histogram marks the threshold at 2 whatever threshold is given

- **Severity**: cosmetic
- **Trigger**: activeProteinList(proteomicsEx, proteomicsGenes, 5, 3)
- **Observed**: the red line and the label Threshold are drawn at x = 2 (lines 29-30 use the constant 2)
- **Expected**: the line at x = treshold
- **Source lines**: 29-30
- **Documented in**: `test/verifiedTests/dataIntegration/testXomicsToModel/testActiveProteinList.m`

#### The inactive proteins are those above the threshold

- **Severity**: wrong-result
- **Trigger**: [active, inactive] = activeProteinList([1; 2; 3], {'a'; 'b'; 'c'}, 2, 0)
- **Observed**: active = {'b'; 'c'}, inactive = {'c'} (R2025a, 2026-11-15); line 39 uses proteomicsEx > treshold
- **Expected**: inactive = {'a'}, the proteins whose expression is below the threshold, the complement of the active set
- **Source lines**: 39
- **Documented in**: `test/verifiedTests/dataIntegration/testXomicsToModel/testActiveProteinList.m`

### `src/dataIntegration/chemoInformatics/RXN/writeRxnfile.m`

#### The reaction equation drops every "1 " it contains, not only unit coefficients

- **Severity**: cosmetic
- **Trigger**: writeRxnfile([-11; 1], {'met1'; 'met2'}, {'met1'; 'met2'}, d, 'r2', d)
- **Observed**: equation line "1met1 -> met2" (R2025a, 2026-11-15); a coefficient 11 or 21, or a metabolite id ending in 1 followed by " + ", loses the "1 "
- **Expected**: "11 met1 -> met2"; only the equation (comment) line is affected, the counts line and the $MOL blocks are right
- **Source lines**: 76, 80
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testWriteRxnfile.m`

### `src/dataIntegration/chemoInformatics/checkChemoinformaticDependencies.m`

#### A system without java stops with an undefined variable options

- **Severity**: error
- **Trigger**: checkChemoinformaticDependencies() when java is not on the system path (reproduced with setenv('PATH', <empty temporary folder>))
- **Observed**: Unable to resolve the name 'options.atomMapping'. (line 39; R2025a, 2026-11-15), after the messages cxcalc is not installed and obabel is not installed
- **Expected**: javaInstalled = false and the message java is not installed
- **Source lines**: 39-41
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testCheckChemoinformaticDependencies.m`

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

### `src/dataIntegration/chemoInformatics/inchi/compareInchis.m`

#### A model formula made only of R groups is not treated as H

- **Severity**: wrong-result
- **Trigger**: compareInchis(model, inchis, met) with model.metFormulas = 'X' for met; for example inchis = {'InChI=1S/p+1'}
- **Observed**: (R2025a, 2026-11-17) formulaOkBool false: regexprep({'X'}, ["X", "Y", "*", "FULLR"], '') returns a 1-by-1 cell holding '', so isempty at line 75 is false, line 76 is never reached and the formula becomes editChemicalFormula({'X'}) = 'R'
- **Expected**: the formula set to 'H' (line 76), so that it matches an InChI whose formula is hydrogen only
- **Source lines**: 75-76
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testCompareInchis.m`

#### The R groups of the model formula are replaced by R instead of removed, so the formula never matches

- **Severity**: wrong-result
- **Trigger**: compareInchis(model, inchis, met) when the model formula of met contains X, Y, * or FULLR together with other atoms; for example model.metFormulas = 'C6H12O6X' for met 'glcr' and inchis = {'InChI=1S/C6H12O6/c7-1-2/h2H/t2-/m1/s1'}
- **Observed**: (R2025a, 2026-11-17) formulaOkBool false and score 6 (the same InChI scores 16 with formulaOkBool true for a metabolite with formula C6H12O6): line 78 calls editChemicalFormula, which replaces X, Y, * and FULLR by R ('C6H12O6R'), so after the hydrogen is removed 'C6O6R' is compared with 'C6O6' and the 10 formula points are lost for every InChI
- **Expected**: the R groups removed before the comparison ("Remove the R groups from the formula", line 72; formulas compared "excluding hydrogen and non-chemical atoms", lines 109-111), so 'C6O6' matches and formulaOkBool is true
- **Source lines**: 72-83
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testCompareInchis.m`

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

### `src/dataIntegration/chemoInformatics/metabolites/addMetInfoInCBmodel.m`

#### A struct as inputData stops with an error

- **Severity**: unusable-option
- **Trigger**: addMetInfoInCBmodel(model, struct('mets', {{'a'}}, 'KEGG', {{'C00001'}}))
- **Observed**: error "Input path must be text." raised by isfile at line 29; line 32 would pass the struct to readtable, which also accepts only a file name
- **Expected**: the struct data integrated (help text: inputData "External file (path) or struct with the metabolite data to integrate")
- **Source lines**: 29-32
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testAddMetInfoInCBmodel.m`

#### replace = true stops with an error for every matched metabolite

- **Severity**: unusable-option
- **Trigger**: addMetInfoInCBmodel(model, csvFile, true) with model.mets = {'a[c]'; 'b[c]'} and a csv file with columns mets, KEGG and rows a, C00001 / b, C00002
- **Observed**: error "Conversion to cell from char is not possible." - line 88 assigns the character identifier to the cell field with () instead of {}
- **Expected**: the existing identifiers replaced (help text: replace "If the new ID should replace an existing ID")
- **Source lines**: 88
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testAddMetInfoInCBmodel.m`

### `src/dataIntegration/chemoInformatics/metabolites/metDatabaseStatus.m`

#### A metabolite whose identifier contains mol after another character is reported missing

- **Severity**: wrong-result
- **Trigger**: model met amol[c] and a file amol.mol in metDir
- **Observed**: status "missing", structureFormula "missing", structureCharge NaN and summary.missing = 1 - line 33 strips the extension with the regular expression '.mol', whose dot matches any character, so 'amol.mol' becomes '' (MATLAB: regexprep({'amol.mol'; 'glc.mol'}, '.mol', '') returns {''; 'glc'})
- **Expected**: the structure found and compared with the model
- **Source lines**: 33
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testMetDatabaseStatus.m`

#### The labels inconsistentCharge and inconsistentFormula are swapped

- **Severity**: wrong-result
- **Trigger**: model met glc[c] with metFormulas 'C6H12O6' and metCharges 0, and a file glc.mol with one carbon atom and no charge line
- **Observed**: status "inconsistentCharge" and summary.inconsistentCharge = 1, although the charges agree (modelCharge 0, structureCharge 0) and the formulas differ (modelFormula "C6H12O6", structureFormula "C"); case 1 (charge equal, formula different) is labelled inconsistentCharge and case 3 inconsistentFormula
- **Expected**: status "inconsistentFormula" for a formula mismatch with equal charges
- **Source lines**: 128-131
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testMetDatabaseStatus.m`

### `src/dataIntegration/chemoInformatics/metabolites/metaboliteStructuresTable.m`

#### A file name containing a character followed by mol loses that part of the metabolite name

- **Severity**: wrong-result
- **Trigger**: metaboliteStructuresTable(metDir) with a MOL file whose name has any character followed by mol before the extension; for example the files amol.mol and xmolecule.mol
- **Observed**: (R2025a, 2026-11-17, stand-in obabel) metTable.mets is "" for amol.mol and "ecule" for xmolecule.mol, while the InChIKey, InChI and SMILES of these rows are those of amol.mol and xmolecule.mol: line 39 removes every match of the regular expression '.mol' (any character followed by mol), not only the extension; two such files (amol.mol, bmol.mol) both get the name ""
- **Expected**: "amol" and "xmolecule", the file name without the extension .mol, which line 39 evidently intends (the column names the metabolite of each row)
- **Source lines**: 39
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testMetaboliteStructuresTable.m`

### `src/dataIntegration/chemoInformatics/metabolites/obtainMetStructures.m`

#### A model without an HMDB field stops with an error

- **Severity**: error
- **Trigger**: obtainMetStructures(model, [], outputDir, {'inchi'}) with a createModel model that has no field matching hmdb
- **Observed**: error "Unrecognized function or variable 'hmdbIDs'." at line 245 - lines 133-136 set hmdbIDs only when the field exists, while every other identifier field gets an empty default (lines 116-183)
- **Expected**: an empty HMDB list, as for the other identifier fields, and the requested sources processed
- **Source lines**: 133-136, 245
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testObtainMetStructures.m`

#### The SMILES source is used only for metabolites that have an InChI

- **Severity**: wrong-result
- **Trigger**: sources {'smiles'} and a metabolite with a SMILES string but no InChI
- **Observed**: line 358 tests inchis{idx(1)} instead of smiles{idx(1)}, so such a metabolite is skipped (found by reading; Open Babel cannot run from MATLAB on the reference machine, so the conversion itself was not observed)
- **Expected**: the SMILES string converted whenever it is present
- **Source lines**: 358
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testObtainMetStructures.m`

#### The documented source name lipidmass stops with an error

- **Severity**: unusable-option
- **Trigger**: obtainMetStructures(model, [], outputDir, {'lipidmass'}) with model.metHMDBID set to empty entries
- **Observed**: error "The VariableNames property must contain one name for each variable in the table." - the code knows only 'lipidmaps' (lines 74, 78, 315), so line 382 removes every column of idMatrix while the report table is built with the name lipidmass (lines 391-393)
- **Expected**: the LIPID MAPS source used, as the help text lists ("8.- 'lipidmass'")
- **Source lines**: 78, 382-396
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testObtainMetStructures.m`

### `src/dataIntegration/chemoInformatics/metabolites/standardiseMolDatabase.m`

#### No selected MOL file stops with an undefined variable standardised

- **Severity**: error
- **Trigger**: standardiseMolDatabase(molDir, {'nothing'}, outDir) where molDir holds met1.mol and met2.mol (or an empty molDir), PATH without obabel and cxcalc
- **Observed**: Standardizing 0 MOL files ... then Unrecognized function or variable 'standardised'. (line 221; R2025a, 2026-11-15); nonStandardised and InChIs are initialised at lines 108-109 but standardised is not
- **Expected**: a report with an empty standardised list
- **Source lines**: 221
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testStandardiseMolDatabase.m`

### `src/dataIntegration/chemoInformatics/openBabelConverter.m`

#### A scratch file named tmp is written into the current folder and left there

- **Severity**: limitation
- **Trigger**: any SMILES or InChI input, e.g. openBabelConverter('C[C@@H](C(=O)O)N', 'inchi')
- **Observed**: (R2025a, 2026-11-17) after the calls the current folder holds a file 'tmp' with the input string; an existing file of that name is overwritten
- **Expected**: a tempname file that is deleted after the conversion
- **Source lines**: 79-82
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testOpenBabelConverter.m`

#### Saving fails for every output format except mol

- **Severity**: error
- **Trigger**: openBabelConverter('InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1', 'smiles', outFile) with a non-empty third argument and outputFormat 'smiles', 'inchi', 'inchikey' or 'rinchi' (reproduced with a stand-in obabel first on PATH)
- **Observed**: (R2025a, 2026-11-17) MATLAB:cellRefFromNonCell "Brace indexing is not supported for variables of this type." for all four formats (the same calls without the third argument return the converted text): newFormat is a char for these formats and line 124 writes newFormat{:}
- **Expected**: the converted text is returned and written to the save location
- **Source lines**: 103-118, 124
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testOpenBabelConverter.m`

#### The documented output format rxn returns nothing

- **Severity**: unusable-option
- **Trigger**: openBabelConverter('C[C@@H](C(=O)O)N', 'rxn') with a stand-in obabel first on PATH that prints an RXN block
- **Observed**: (R2025a, 2026-11-17) returns [] without error or message: the output switch has no case 'rxn'
- **Expected**: the MDL RXN text produced by Open Babel ("Formats supported: smiles, mol, inchi, inchikey, rxn and rinchi")
- **Source lines**: 96-119
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testOpenBabelConverter.m`

#### saveFileDir is documented as a directory but opened as a file

- **Severity**: error
- **Trigger**: openBabelConverter('C[C@@H](C(=O)O)N', 'mol', existingFolder) with a stand-in obabel first on PATH
- **Observed**: (R2025a, 2026-11-17) MATLAB:FileIO:InvalidFid "Invalid file identifier. Use fopen to generate a valid file identifier.": fopen of the folder name returns -1
- **Expected**: the structure is saved in the given directory, as the help text says ("saveFileDir: String with the directory where the new format will be saved")
- **Source lines**: 123-125
- **Documented in**: `test/verifiedTests/dataIntegration/testChemoInformatics/testOpenBabelConverter.m`

### `src/dataIntegration/fluxomics/c13solver/scoreC13Fit.m`

#### The input method is ignored, method 1 (cumomer) cannot be selected

- **Severity**: unusable-option
- **Trigger**: with the fixtures of this folder, load('point.mat', 'v0'); load('model.mat', 'model'); load('expdata.mat', 'expdata'); expdata.inputfrag = convertCarbonInput(expdata.input); scoreC13Fit(v0, expdata, model, [], 1)
- **Observed**: (R2025a, 2026-11-16) the test "if nargin < 6" is always true for a function of five inputs, so method is set to 2 (EMU) on every call; the output for method = 1 is identical (isequal) to the output for the default, error 386.121954048192 in both cases. The cumomer branch runs only as the fallback when the EMU result has NaN
- **Expected**: method = 1 uses slvrCumomer_fast with expdata.input (documented "method 1 = cumomer, method 2 = CMU"); the default 2 applies only when method is not given
- **Source lines**: 50-52
- **Documented in**: `test/verifiedTests/dataIntegration/testFitC13Data/testScoreC13Fit.m`

### `src/dataIntegration/fluxomics/calcMDVfromSamp.m`

#### A non-empty substrate label distribution glc stops with an error

- **Severity**: error
- **Trigger**: with the fixtures of testFitC13Data, load('point.mat', 'v0'); load('expdata.mat', 'expdata'); calcMDVfromSamp(expdata.input, [v0 v0], expdata)
- **Observed**: (R2025a, 2026-11-15) "Undefined function 'convert_input' for input arguments of type 'double'." (MATLAB:UndefinedFunction) at line 34; no function convert_input exists in the toolbox, so every call with a non-empty glc fails; an empty experiment needs a non-empty glc, so the branches for an empty experiment cannot run either
- **Expected**: glc converted to the fragment label input of slvrEMU_fast (as convertCarbonInput does) and the MDVs of every sample returned
- **Source lines**: 34, 37-38, 54-57, 68
- **Documented in**: `test/verifiedTests/dataIntegration/testFluxomics/testCalcMDVfromSamp.m`

### `src/dataIntegration/fluxomics/compareMultSamp.m`

#### calcMDVfromSamp is called with four arguments, every non-empty sample set stops with an error

- **Severity**: error
- **Trigger**: with the fixtures of testFitC13Data, load('point.mat', 'v0'); load('model.mat', 'model'); compareMultSamp([], model, struct('points', v0))
- **Observed**: (R2025a, 2026-11-16) "Too many input arguments." at line 57, the call calcMDVfromSamp(model, xglc, samp, measuredMetabolites); calcMDVfromSamp takes (glc, points, experiment). Only an empty struct array of samples returns (totalz = 0, zscore = 0, empty ave and stdev)
- **Expected**: the MDVs of each sample set, e.g. calcMDVfromSamp(xglc, samps(i).points, experiment), collected in mdvs.ave and mdvs.stdev
- **Source lines**: 57
- **Documented in**: `test/verifiedTests/dataIntegration/testFluxomics/testCompareMultSamp.m`

### `src/dataIntegration/fluxomics/compareTwoSamp.m`

#### calcMDVfromSamp is called as calcMDVfromSamp(points, measuredMetabolites), every call stops with an error

- **Severity**: error
- **Trigger**: with the fixtures of testFitC13Data, load('point.mat', 'v0'); load('model.mat', 'model'); compareTwoSamp([], model, struct('points', v0), struct('points', v0)) (also with a fifth argument {'xalaL011'})
- **Observed**: (R2025a, 2026-11-16) "Undefined function 'convert_input' for input arguments of type 'double'." raised in calcMDVfromSamp line 34: the sampled points are passed as its first argument glc and measuredMetabolites as its argument points; with empty points (glc empty) it stops with "Not enough input arguments." at calcMDVfromSamp line 32 because no experiment structure is passed; xglc is never passed on
- **Expected**: calcMDVfromSamp(xglc, samp.points, experiment) for each sample, then the z-scores of compareTwoMDVs
- **Source lines**: 57-58
- **Documented in**: `test/verifiedTests/dataIntegration/testFluxomics/testCompareTwoSamp.m`

### `src/dataIntegration/fluxomics/getBinsOfFluxes.m`

#### Every call with at least 200 samples stops with an error instead of returning the bins

- **Severity**: error
- **Trigger**: samp.points = reshape(1:1200, 3, 400); getBinsOfFluxes(samp, 100, 2) (also getBinsOfFluxes(samp, [], 3))
- **Observed**: (R2025a, 2026-11-15) after printing the bins, "Unable to perform assignment because dot indexing is not supported for variables of this type." (MATLAB:structAssToNonStruct) at line 142: output is initialised as the number 0 at line 21 and line 142 assigns the field samps to it
- **Expected**: output.samps, a struct array with one element per bin holding the points of that bin
- **Source lines**: 21, 142
- **Documented in**: `test/verifiedTests/dataIntegration/testFluxomics/testGetBinsOfFluxes.m`

### `src/dataIntegration/metaboAnnotator/analyseMetStruct/acceptIDsSuggested.m`

#### A suggestion list with fewer rows than columns stops with an index error

- **Severity**: error
- **Trigger**: acceptIDsSuggested(ms, S(1:2, :)) with ms and S as above (2 rows, 6 columns)
- **Observed**: "Index in position 1 exceeds array bounds. Index must not exceed 2." (MATLAB:badsubscript, line 38): the loop runs to length(IDsSuggested), which is the number of columns (6) when the list has fewer rows than columns (R2025a, 2026-11-15)
- **Expected**: the two suggestions accepted, the loop running over the rows (size(IDsSuggested, 1))
- **Source lines**: 37-38
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testAcceptIDsSuggested.m`

#### IDsAdded keeps only the last accepted suggestion

- **Severity**: wrong-result
- **Trigger**: ms.VMH_glc_D = struct('keggId', NaN, 'hmdb', NaN); ms.VMH_atp = ms.VMH_glc_D; S = [{'VMH_glc_D', 'x', 'keggId:C00031', '', '', 'accepted'; 'VMH_atp', 'x', 'hmdb:HMDB0000538', '', '', 'accepted'}; repmat({'VMH_atp', 'x', 'keggId:C00002', '', '', 'rejected'}, 5, 1)]; [o, IDsAdded] = acceptIDsSuggested(ms, S, 'curator (test)')
- **Observed**: o.VMH_glc_D.keggId = 'C00031' and o.VMH_atp.hmdb = 'HMDB0000538' are both added, but IDsAdded = {'VMH_atp', 'hmdb', 'HMDB0000538', 'added based on accepted suggestion'} (1 x 4): the row counter a is set to 1 and never incremented, so each accepted suggestion overwrites row 1 (R2025a, 2026-11-15)
- **Expected**: one row of IDsAdded per accepted suggestion (two rows here)
- **Source lines**: 35, 42-45
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testAcceptIDsSuggested.m`

### `src/dataIntegration/metaboAnnotator/analyseMetStruct/addAnnotations.m`

#### An empty field receives NaN with a source when the table cell is NaN

- **Severity**: wrong-result
- **Trigger**: the call above (field hmdb = '' and table cell hmdb = NaN)
- **Observed**: o.VMH_glc_minus_D.hmdb = NaN and hmdb_source = 'src:manual:<date>': the test isempty(field) || hasNaN(field) && ~isnan(cell) applies the NaN check of the table cell only to NaN fields (&& binds tighter than ||), and NaN passes the text checks of line 60 (R2025a, 2026-11-15)
- **Expected**: missing table values not copied and no source written for them. Severity audit 2026-11-15: the condition on line 59 contains isempty(find(isnan(RAW{i,j}))), so the code evidently intends not to copy NaN cells, but && binds before ||, and an empty field receives NaN plus a <field>_source string (lines 61-62) - wrong values written into the returned metabolite structure for the common blank-cell input
- **Source lines**: 59-62
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testAddAnnotations.m`

#### The option annotationVerification has no effect

- **Severity**: unusable-option
- **Trigger**: ms.VMH_glc_minus_D = struct('keggId', NaN, 'hmdb', '', 'charge', NaN, 'lipidmaps', NaN, 'cheBIId', 'old', 'pubChemId', NaN); RAW = {'VMH', 'keggId', 'hmdb', 'charge', 'lmId', 'cheBlId', 'pubChemId'; 'glc-D', 'C00031', NaN, '0', 'LM1', 'CHEBI:1', '0'}; o = addAnnotations(ms, RAW, 'src', 'manual', 'verified by curator')
- **Observed**: o.VMH_glc_minus_D.keggId_source = 'src:manual:15-Nov-2026 19:29:05'; the verification given as fifth argument appears nowhere: it is set to a default (lines 42-44) and never read (R2025a, 2026-11-15)
- **Expected**: the verification recorded with each annotation, as acceptIDsSuggested records 'source:type:verification:date'
- **Source lines**: 42-44, 62
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testAddAnnotations.m`

### `src/dataIntegration/metaboAnnotator/analyseMetStruct/addInfoFromMolFiles.m`

#### The documented output IDAdded is not assigned when nothing is added, so a call requesting it stops

- **Severity**: error
- **Trigger**: [ms, IDAdded] = addInfoFromMolFiles(struct('VMH_h2o', struct('VMHId', 'h2o', 'inchiString', 'InChI=1S/H2O/h1H2', 'inchiKey', 'XLYOFNOQVPJJNP-UHFFFAOYSA-N', 'smile', 'O')), tempname)
- **Observed**: (R2025a, 2026-11-15) 'Output argument "IDAdded" (and possibly others) not assigned a value in the execution with "addInfoFromMolFiles" function.': IDAdded is assigned only inside the branches that add an identifier (lines 64-66, 82-84, 96-98) and is never initialised (line 46 initialises only the counter)
- **Expected**: IDAdded returned empty when nothing is added
- **Source lines**: 1, 46
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testAddInfoFromMolFiles.m`

### `src/dataIntegration/metaboAnnotator/analyseMetStruct/check4DuplicatesInList.m`

#### A repeated entry is used as the format of its message

- **Severity**: cosmetic
- **Trigger**: check4DuplicatesInList({'a%d'; 'b'; 'a%d'}) or check4DuplicatesInList({'a\nb'; 'a\nb'})
- **Observed**: the first prints only "a" (printing stops at the conversion %d, no newline); the second prints "a", a line break and "b appears more than once."; the returned list is right ({'a%d', '3'} and {'a\nb', '2'}) (R2025a, 2026-11-15)
- **Expected**: the entry printed verbatim, e.g. fprintf('%s appears more than once.\n', entry)
- **Source lines**: 25
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testCheck4DuplicatesInList.m`

### `src/dataIntegration/metaboAnnotator/buildMetStruct/convertModel2Metstructure.m`

#### A metabolite with a hyphen is overwritten by its next compartment

- **Severity**: wrong-result
- **Trigger**: a metabolite abbreviation with a hyphen in more than one compartment
- **Observed**: the check for an existing entry uses the name with the hyphen but the entry is stored with an underscore, so the last occurrence overwrites the entry (originalID a-b[e], not a-b[c])
- **Expected**: the first occurrence defines the entry, as for all other metabolites
- **Source lines**: 36, 38
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testConvertModel2Metstructure.m`

### `src/dataIntegration/metaboAnnotator/buildMetStruct/createNewMetaboliteStructure.m`

#### A table without a name column stops on an undefined variable

- **Severity**: limitation
- **Trigger**: createNewMetaboliteStructure({'VMH ID' 'HMDB'; 'cot' 'HMDB0001046'}, 'src')
- **Observed**: "Unrecognized function or variable 'metList'." (MATLAB:UndefinedFunction, line 64), in the branch written for a table without name column; the documentation requires the name column (R2025a, 2026-11-15)
- **Expected**: the branch adds the column metNames or reports the missing column
- **Source lines**: 62-64
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testCreateNewMetaboliteStructure.m`

#### The formula columns of the documented input format are dropped

- **Severity**: wrong-result
- **Trigger**: createNewMetaboliteStructure({'VMH ID' 'metabolite_name' 'HMDB' 'inchistring' 'neutral_formula' 'charged_formula' 'charge'; 'cot' 'Cotinine' 'HMDB0001046' '' 'C10H12N2O' 'C10H12N2O' '0'; 'coto' 'Cotinine n-oxide' 'HMDB0001411' '' '' '' ''}, 'test source'), the example of the function's documentation
- **Observed**: s.VMH_cot.neutralFormula = NaN and s.VMH_cot.chargedFormula = NaN although the table gives C10H12N2O; a header is used only when a field name of metaboliteStructureFieldNames contains it after blanks are replaced by '_' or removed, so 'neutral_formula' and 'charged_formula' match no field and their columns are ignored without notice; likewise the header 'smiles' that createrBioNetStructure passes does not match the field 'smile' (R2025a, 2026-11-15)
- **Expected**: the documented columns stored in neutralFormula and chargedFormula
- **Source lines**: 108-110
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testCreateNewMetaboliteStructure.m`

### `src/dataIntegration/metaboAnnotator/buildMetStruct/populateModelMetStr.m`

#### A field missing from the model is created with one entry per metabolite up to the last match only

- **Severity**: wrong-result
- **Trigger**: pm = createModel({'R1'}, {'R1'}, {'glc_D + atp + datp -> h2o + adp'}); n = numel(pm.mets); pm.metKEGGID = repmat({''}, n, 1); pm.metChEBIID = repmat({''}, n, 1); pm.metCharges = zeros(n, 1); ms.VMH_glc_D = struct('VMHId', 'glc_D', 'metNames', 'D-Glucose', 'keggId', 'C00031', 'cheBIId', '4167', 'charge', '-1', 'drugbank', NaN); ms.VMH_atp = struct('VMHId', 'atp', 'metNames', 'ATP', 'keggId', 'C00002', 'cheBIId', NaN, 'charge', -4, 'drugbank', 'DB00171'); out = populateModelMetStr(pm, ms)
- **Observed**: (R2025a, 2026-11-16) the model has 5 metabolites (adp, atp, datp, glc_D, h2o) but out.metDrugbank is 4-by-1 ({'DB00171'} for atp at index 2, {[NaN]} for glc_D at index 4, [] in between), same with replaceAllHits = 1: line 79 creates the field as [] and lines 83/87/90 grow it only up to the matched index; columnVector does not pad it, so the returned model is inconsistent (field length differs from mets)
- **Expected**: a created field with one (empty) entry per metabolite, filled at the matches
- **Source lines**: 79, 83, 87, 90
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testPopulateModelMetStr.m`

### `src/dataIntegration/metaboAnnotator/connect2resources/VMH2Metabolon.m`

#### A comma-separated VMH id that is not in the structure stops the function

- **Severity**: error
- **Trigger**: a table row with VMH ID 'h2o,zzz' and a structure holding only h2o
- **Observed**: (R2025a, 2026-11-15) "Unable to perform assignment with 0 elements on the right-hand side." (line 47)
- **Expected**: the ids found (h2o) receive the row, the others are skipped
- **Source lines**: 47
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testVMH2Metabolon.m`

#### A row whose VMH id is not in the structure overwrites the metabolite of the previous matched row

- **Severity**: wrong-result
- **Trigger**: a table (writecell, headers CHEM_ID, INCHIKEY, INCHISTRING, CAS, CHEMSPIDER, HMDB, KEGG, PUBCHEM, VMH ID) with the rows {35, 'KEY1', 'InChI=1S/H2O/h1H2', ..., 'h2o'} and {50, 'KEY2', 'InChI=X', ..., 'notInStruct'}, and VMH2Metabolon(struct('VMH_h2o', struct('VMHId', 'h2o', 'metNames', 'Water')))
- **Observed**: (R2025a, 2026-11-15) VMH_h2o.metabolon = 50, inchiKey = 'KEY2', inchiString = 'InChI=X' and the other identifiers of the second row: when no metabolite matches (line 54), vmhId keeps the value of the previous row and the loop of line 58 writes the row into that metabolite
- **Expected**: VMH_h2o keeps the identifiers of its own row (metabolon 35, KEY1); rows without a match change nothing
- **Source lines**: 53-58
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testVMH2Metabolon.m`

#### A table whose first row with a VMH id has no matching metabolite stops the function

- **Severity**: error
- **Trigger**: the same table with the two rows swapped, or the shipped table (its first row lists 1pyr5c) with VMH2Metabolon(struct('VMH_h2o', struct('VMHId', 'h2o', 'metNames', 'Water')))
- **Observed**: (R2025a, 2026-11-15) "Unrecognized function or variable 'vmhId'." (line 58)
- **Expected**: the row is skipped and the later matching rows are copied
- **Source lines**: 53-58
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testVMH2Metabolon.m`

### `src/dataIntegration/metaboAnnotator/connect2resources/VMH2Seed.m`

#### A blank SEED cell overwrites the SEED id with NaN and writes a source

- **Severity**: cosmetic
- **Trigger**: MetaboliteTranslationTable.xlsx written with writecell({'VMHmetabolite', 'seed'; 'h2o', ''}) and VMH2Seed(struct('VMH_h2o', struct('VMHId', 'h2o', 'metNames', 'Water', 'seed', 'cpd00001')))
- **Observed**: (R2025a, 2026-11-15) seed = NaN and seed_source = 'MetaboliteTranslationTable.xlsx:manual:<date>': xlsread returns NaN for the blank cell and line 39 only tests isempty, which is false for NaN. The shipped table has no blank SEED cell, so the shipped file does not trigger it; the input is skipped below.
- **Expected**: a blank SEED cell leaves the metabolite unchanged
- **Source lines**: 39-41
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testVMH2Seed.m`

### `src/dataIntegration/metaboAnnotator/connect2resources/convertOld2NewHMDB.m`

#### Identifiers of 12 or more characters give an empty result

- **Severity**: limitation
- **Trigger**: an identifier with 12 or more characters, for example HMDB00012345
- **Observed**: the result is an empty text instead of the identifier
- **Expected**: the identifier returned unchanged or an error
- **Source lines**: 19-28
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testConvertOld2NewHMDB.m`

### `src/dataIntegration/metaboAnnotator/connect2resources/getIds2VMH.m`

#### A KEGG, BioCyc or BiGG id is never found when its column has a blank cell

- **Severity**: wrong-result
- **Trigger**: with the shipped pnas.1401329111.sd01.xlsx on the path, getIds2VMH(struct('byKegg', struct('seed', NaN, 'keggId', 'C00080', 'biocyc', NaN, 'biggId', 'h'))) (biggId set so that no web request is made)
- **Observed**: IDsAdded is empty and seed and biocyc stay NaN (R2025a, 2026-11-15). xlsread returns NaN for the 10211 blank KEGG, 13988 blank BioCyc and 25171 blank BiGG cells, and strmatch('C00080', RAW(:, 5), 'exact') then returns [] although row 2 holds C00080; only the SEED column (no blank) is searched successfully. The same input with seed 'cpd00067' instead adds keggId C00080 and biocyc PROTON.
- **Expected**: seed 'cpd00067' and biocyc 'PROTON' added from row 2 of the Compounds sheet
- **Source lines**: 50
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testGetIds2VMH.m`

#### The metabolite counter is printed for every identifier looked up

- **Severity**: cosmetic
- **Trigger**: any metabolite with an identifier, e.g. the call above
- **Observed**: i = 1 is printed once per non-empty identifier (line 48 has no semicolon; R2025a, 2026-11-15)
- **Expected**: no console output
- **Source lines**: 48
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testGetIds2VMH.m`

### `src/dataIntegration/metaboAnnotator/connect2resources/getSeed2Kegg.m`

#### A blank KEGG cell read as NaN stops the mapping with an error

- **Severity**: limitation
- **Trigger**: compounds.xlsx written with writecell({'DATABASE', 'PRIMARY NAME', 'ABBREVIATION', 'NAMES', 'KEGG ID(S)'; 'cpd3', 'c', 'c', 'c', ''}) and getSeed2Kegg(struct('m3', struct('keggId', NaN, 'seed', 'cpd3')))
- **Observed**: First argument must be text. (line 43; R2025a, 2026-11-15): xlsread returns NaN for the blank cell and contains is called on it before the emptiness check of line 46. The shipped compounds.xlsx stores its 1743 blank KEGG cells as empty text, so the shipped file does not trigger it; the input is skipped below.
- **Expected**: the metabolite is left without KEGG id, as for an empty text cell
- **Source lines**: 43
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testGetSeed2Kegg.m`

### `src/dataIntegration/metaboAnnotator/connect2resources/parseBridgeDb.m`

#### A ChEBI cross-reference stops the processing of the answer

- **Severity**: wrong-result
- **Trigger**: s.VMH_glc_D with keggId = 'C00031' and NaN hmdb, wikidata, cheBIId, chemspider (plus the fields read by cleanUpMetabolite_structure), BridgeDb answer "C00031<TAB>KEGG Compound<TAB>Ch:HMDB0000122,Wd:Q37525,Ce:CHEBI:4167,Cs:5589" (stand-in curl); [o, IDsAdded] = parseBridgeDb(s)
- **Observed**: IDsAdded lists hmdb HMDB0000122 and wikidata Q37525 only; cheBIId and chemspider stay NaN: cheBIId is listed twice in the mapping table, so the code 'Ce' matches two rows, the dynamic field name of line 120 is a list and the error is swallowed by the try without catch (line 92), which skips every later item of the answer (R2025a, 2026-11-15)
- **Expected**: cheBIId = '4167' and chemspider = '5589' added
- **Source lines**: 58, 61, 92, 118-121
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testParseBridgeDb.m`

#### A mismatch needs a field fullName and otherwise stops the processing of the answer

- **Severity**: wrong-result
- **Trigger**: s.VMH_atp with keggId = 'C00002', hmdb = 'HMDB9999999' and no field fullName (metaboliteStructureFieldNames has none), answer "C00002<TAB>KEGG Compound<TAB>Ch:HMDB0000538,Wd:Q80863,Cs:5742"; [o, IDsAdded, IdsMismatch] = parseBridgeDb(s)
- **Observed**: IdsMismatch is empty and wikidata and chemspider of VMH_atp are not added: line 131 reads metabolite_structure.(met).fullName, the error is swallowed by the try (line 92); with a field fullName = 'ATP' the mismatch is listed and Q80863 and 5742 are added (R2025a, 2026-11-15)
- **Expected**: the mismatch listed (with metNames) and the other cross-references added
- **Source lines**: 92, 131
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testParseBridgeDb.m`

#### Numeric identifiers are never queried

- **Severity**: wrong-result
- **Trigger**: a metabolite whose pubChemId, cheBIId or chemspider is numeric, as cleanUpMetabolite_structure and sanityCheckMetIds make them
- **Observed**: regexprep(5793, ',', ';') at line 95 raises "The 'STRING' input must be either a char row vector, a cell array of char row vectors, or a string array.", swallowed by the try (line 92), so the identifier is skipped (R2025a, 2026-11-15)
- **Expected**: numeric identifiers converted to text and queried. Severity audit 2026-11-15: INPUT is the "metabolite structure ... each holding identifier fields" as the toolbox builds it (numeric pubChemId/cheBIId); line 90 tests isnan on the field, so numeric identifiers are anticipated, yet regexprep at line 95 fails and the try at line 92 swallows it - the documented result ("adding them to the metabolite structure") is silently not produced for those identifiers
- **Source lines**: 95
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testParseBridgeDb.m`

#### The progress shown exceeds 100 percent when startSearch is above 1

- **Severity**: cosmetic
- **Trigger**: parseBridgeDb(s, 2, 3) for a structure of three metabolites
- **Observed**: prints "100 percent ..." and "150 percent ..." (progress = i/(endSearch - startSearch + 1)) (R2025a, 2026-11-15)
- **Expected**: 50 and 100 percent ((i - startSearch + 1)/(endSearch - startSearch + 1))
- **Source lines**: 87
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testParseBridgeDb.m`

### `src/dataIntegration/metaboAnnotator/generateMetInfo/generateInchiKeysSmilesFromInchiStrings.m`

#### The metabolite counter is printed for every metabolite

- **Severity**: cosmetic
- **Trigger**: any call with a non-empty metabolite structure
- **Observed**: (R2025a, 2026-11-15) "i =" and the index are printed once per metabolite (line 40 has no semicolon)
- **Expected**: no console output, or output gated behind a printLevel
- **Source lines**: 40
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboAnnotator/testGenerateInchiKeysSmilesFromInchiStrings.m`

### `src/dataIntegration/metabotools/calculateQuantitativeDiffs.m`

#### An empty difference set is not assigned, so a call requesting it stops

- **Severity**: error
- **Trigger**: r = {'EX_a'; 'EX_b'}; [a, b] = calculateQuantitativeDiffs(r, [0.5; 1.5], r, [1; 2], {'EX_a'}, {'EX_a'}, {'EX_a'}, {'EX_a'}) (the only common uptake has ratio 0.5, so no exchange has higher uptake in condition 2); the documented call with all eight outputs fails whenever any of the four sets is empty
- **Observed**: Output argument "cond2_upt_higher" (and possibly others) not assigned a value in the execution with "calculateQuantitativeDiffs" function. (R2025a, 2026-11-15)
- **Expected**: an empty cell array for an empty difference set
- **Source lines**: 84, 90, 104, 110
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboTools/testCalculateQuantitativeDiffs.m`

#### Higher secretion is reported for the other condition, contrary to the code's own comments

- **Severity**: wrong-result
- **Trigger**: r = {'EX_a'; 'EX_c'; 'EX_b'; 'EX_d'}; A = [100 100 100 50; 100 100 100 80; 100 100 100 200; 100 100 100 150]; B = [100 100 100 80; 100 100 100 50; 100 100 100 150; 100 100 100 200]; [u1, u2, s1, s2, sr] = defineUptakeSecretionProfiles(A, B, r, 0.05, {'none'}, {}, {}, {}, {}); [o1, o2, o3, o4] = calculateQuantitativeDiffs(r, sr, r, [1; 2; 3; 4], u1, u2, s1, s2)
- **Observed**: (R2025a, 2026-11-17) sr = [1.6; 0.625; 0.75; 1.3333]; cond2_secr_higher = EX_b (25) and cond1_secr_higher = EX_d (133.333), although EX_b rises 2-fold in condition 1 and 1.5-fold in condition 2 (EX_d the reverse): the comment of line 102 says secretion is higher in cond1 when slopeRatio < 1 (as slope_Ratio = slope_cond2/slope_cond1 of defineUptakeSecretionProfiles implies), but lines 104-105 store those exchanges in cond2_secr_higher, and lines 110-111 store ratio >= 1 in cond1_secr_higher
- **Expected**: cond1_secr_higher = EX_b and cond2_secr_higher = EX_d (OUTPUTS: higher secretion in condition 1, in condition 2)
- **Source lines**: 102-112
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboTools/testCalculateQuantitativeDiffs.m`

#### Higher uptake is reported for the other condition for the slope ratio of defineUptakeSecretionProfiles

- **Severity**: wrong-result
- **Trigger**: the call of the entry above
- **Observed**: (R2025a, 2026-11-17) cond1_upt_higher = EX_c (37.5) and cond2_upt_higher = EX_a (0.6), although EX_a falls to 0.5 of its start in condition 1 and to 0.8 in condition 2 (more uptake in condition 1; EX_c the reverse): slope_Ratio is the ratio of the concentration fold changes slope_cond2/slope_cond1, which is < 1 when condition 2 depletes more, while lines 82-85 (comment and code) take ratio < 1 as higher uptake in cond1
- **Expected**: cond1_upt_higher = EX_a and cond2_upt_higher = EX_c (OUTPUTS: higher uptake in condition 1, in condition 2)
- **Source lines**: 82-92
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboTools/testCalculateQuantitativeDiffs.m`

#### No uptake or no secretion exchange common to both conditions stops the call

- **Severity**: error
- **Trigger**: r = {'EX_a'; 'EX_b'}; calculateQuantitativeDiffs(r, [0.5; 1.5], r, [1; 2], {'EX_a'}, {'EX_b'}, {'EX_a'}, {'EX_a'}) (no common uptake), or the same call with uptake {'EX_a'}, {'EX_a'} and secretion {'EX_a'}, {'EX_b'} (no common secretion)
- **Observed**: Unrecognized function or variable 'common_slope_upt'. (line 81), and Unrecognized function or variable 'common_slope_secr'. (line 101) (R2025a, 2026-11-15)
- **Expected**: empty difference sets for the side without common exchanges
- **Source lines**: 81, 101
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboTools/testCalculateQuantitativeDiffs.m`

### `src/dataIntegration/metabotools/defineUptakeSecretionProfiles.m`

#### Fewer than four exchanges stop the call with an index error

- **Severity**: error
- **Trigger**: defineUptakeSecretionProfiles(ones(3, 4), ones(3, 4), {'EX_a'; 'EX_b'; 'EX_c'}, 0.05, {'EX_x'})
- **Observed**: Index in position 1 exceeds array bounds. Index must not exceed 3. (line 57; R2025a, 2026-11-15): the loop runs to length(input_A), which is 4 for a 3 x 4 matrix
- **Expected**: the profiles of the three exchanges (one row per exchange)
- **Source lines**: 55
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboTools/testDefineUptakeSecretionProfiles.m`

#### The documented essAA_excl flag and its default stop the call

- **Severity**: error
- **Trigger**: A = ones(5, 4); defineUptakeSecretionProfiles(A, A, {'EX_a'; 'EX_b'; 'EX_c'; 'EX_d'; 'EX_e'}, 0.05) (default essAA_excl = 0), or the same call with essAA_excl 0 or 1
- **Observed**: Input A of class cell and input B of class double must be cell arrays of character vectors, unless one is a character vector. (ismember, called at line 89; R2025a, 2026-11-15). The flag is passed to ismember as the list of exchanges to remove; only a cell array of exchange names (as the MetaboTools tutorial passes) works.
- **Expected**: with 0 nothing removed; with 1 the nine essential amino acid exchanges of the help removed from the secretion profiles
- **Source lines**: 45-47, 87-92
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboTools/testDefineUptakeSecretionProfiles.m`

### `src/dataIntegration/metabotools/illustrate_ppp.m`

#### More than two metabolite pairs stop the call with an index error

- **Severity**: error
- **Trigger**: R.S1.modelPruned = struct('rxns', {{'EX_glc(e)'; 'EX_o2(e)'}}, 'lb', [-10; -20], 'ub', [0; 0]); R.S1.maxBiomass.f = 1; R.S1.<name> = struct('growthRates', [0.1 0.2; 0.3 0.4], 'bounds', [-1 -2; -2 -4]) for <name> phasePlane_EX_glc_EX_o2, phasePlane_EX_glc_EX_glc and phasePlane_EX_o2_EX_o2; illustrate_ppp(R, {'EX_glc(e)', 'EX_glc(e)', 'EX_o2(e)'; 'EX_o2(e)', 'EX_glc(e)', 'EX_o2(e)'}, tempname-folder, {'S1'}, {'x'; 'y'; 'z'}, 10, 1e-6)
- **Observed**: Index in position 1 exceeds array bounds. Index must not exceed 2. (line 28; R2025a, 2026-11-15) after the PDFs of the first two pairs: line 28 tests mets{p, 1} (row p) where the pair is column p (mets{1, p}, as lines 29-31 use)
- **Expected**: one PDF per pair
- **Source lines**: 28
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboTools/testIllustrate_ppp.m`

#### The mets of performPPP (one pair per row) do not select its results

- **Severity**: error
- **Trigger**: model = createModel({'EX_glc(e)'; 'EX_o2(e)'; 'EX_gln(e)'; 'BIO'}, {'glc ex'; 'o2 ex'; 'gln ex'; 'biomass'}, {'glc[e] <=> '; 'o2[e] <=> '; 'gln[e] <=> '; 'glc[e] + o2[e] + gln[e] -> '}) with lb = -10 and ub = 10 on the exchanges and c = 1 on BIO; R.S1.modelPruned = model; R.S1.maxBiomass.f = 10; mets = {'EX_glc(e)', 'EX_o2(e)'} (performPPP's layout, its help: pairs x 2); R = performPPP(R, mets, [1 1], {'S1'}, [3 3], [-1 -1]); illustrate_ppp(R, mets, <tempname folder>, {'S1'}, {'x'; 'y'; 'z'}, 10, 1e-6); the same with two pairs mets = {'EX_glc(e)', 'EX_o2(e)'; 'EX_gln(e)', 'EX_o2(e)'} and two-row step_size, step_num and direct
- **Observed**: (R2025a, 2026-11-17, gurobi) one pair: "Index in position 1 exceeds array bounds. Index must not exceed 1." (line 31); two pairs: Unrecognized field name "phasePlane_EX_glc_EX_gln". (line 34), although performPPP stored phasePlane_EX_glc_EX_o2 and phasePlane_EX_gln_EX_o2: performPPP reads pair p from row p (mets{p, 1}, mets{p, 2}), illustrate_ppp from column p (mets{1, p}, mets{2, p}); the transposed mets draws and saves the PDFs
- **Expected**: the header says illustrate_ppp shows "the results of the function performPPP" for the "Metabolites that were tested in the phase plane analysis", so the mets given to performPPP select its results and one PDF per pair is saved
- **Source lines**: 27, 29, 31, 44-45, 50, 96
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboTools/testIllustrate_ppp.m`

### `src/dataIntegration/metabotools/make3Dplot.m`

#### Only the first two phenotypes are plotted

- **Severity**: wrong-result
- **Trigger**: make3Dplot({'s1', 'A'; 's2', 'B'; 's3', 'C'}, rand(3, 7), 10, tempname-folder)
- **Observed**: the axes hold two scatter series (A and B); phenotype C is computed into x3, y3, z3 but never plotted and not in the legend (R2025a, 2026-11-15)
- **Expected**: one series per phenotype, as the commented-out loop of lines 48-55 intends; the header documents PHs as "Phenotypes = [samples PHENOTYPE]" and says "The phenotypes are defined as colors" with no limit on their number, and the colour order set at line 46 has seven entries, so a third phenotype is a documented input whose plot is not produced (severity audit T009a)
- **Source lines**: 60-64
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboTools/testMake3Dplot.m`

#### The colour order is changed for every later figure of the session

- **Severity**: cosmetic
- **Trigger**: any call, e.g. make3Dplot({'s1', 'B'; 's2', 'A'; 's3', 'B'}, [11:17; 21:27; 31:37], 10, tempname-folder)
- **Observed**: set(0, 'DefaultAxesColorOrder', ...) stays in force after the call (R2025a, 2026-11-15); a test has to restore the previous root default
- **Expected**: the colour order applied to this figure only
- **Source lines**: 46
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboTools/testMake3Dplot.m`

#### The coordinates of every phenotype are printed to the console

- **Severity**: cosmetic
- **Trigger**: any call, e.g. make3Dplot({'s1', 'B'; 's2', 'A'; 's3', 'B'}, [11:17; 21:27; 31:37], 10, tempname-folder)
- **Observed**: x1 = ..., y1 = ..., z1 = ... are printed for every phenotype (the eval strings have no semicolon; R2025a, 2026-11-15)
- **Expected**: no console output
- **Source lines**: 37-39
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboTools/testMake3Dplot.m`

### `src/dataIntegration/metabotools/mkTableOfAddedExchanges.m`

#### An exchange list with fewer rows than columns stops the function

- **Severity**: error
- **Trigger**: R.s1.Ex_RxnsAdded = {'EX_a'; 'EX_b'}; R.s1.MinMaxAddedRxns = [0 1; -1 0]; R.s2.Ex_RxnsAdded = {'EX_b'}; R.s2.MinMaxAddedRxns = [-1 0]; mkTableOfAddedExchanges(R, {'s1', 's2'}, statisticsAddedExchanges(R, {'s1', 's2'})) (a 2 x 4 list)
- **Observed**: (R2025a, 2026-11-15) "Unable to perform assignment because the size of the left side is 4-by-1 and the size of the right side is 2-by-1." (line 20): line 19 sizes the table with length(Ex_added_all_unique), the larger of its rows and columns (up to 6 columns from statisticsAddedExchanges)
- **Expected**: a 2 x 3 table, one row per exchange
- **Source lines**: 19-20
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboTools/testMkTableOfAddedExchanges.m`

### `src/dataIntegration/metabotools/setSemiQuantConstraints.m`

#### An empty cond1_upt_higher list stops with an error

- **Severity**: error
- **Trigger**: setSemiQuantConstraints(m, m, cell(0, 2), {'EX_a', 0.5}, {'EX_b', 10}, {'EX_b', 10}) with m = createModel({'EX_a', 'EX_b'}, {'EX_a', 'EX_b'}, {'a <=> ', 'b <=> '}); any call with an empty cond1_upt_higher and a non-empty cond2_secr_higher or cond1_secr_higher
- **Observed**: (R2025a, 2026-11-17) "Unrecognized function or variable 'c'." at line 76: the row counter c is first set inside the loop over cond1_upt_higher (line 62), so with zero rows the secretion loops (lines 76 and 91) read an undefined variable. With both secretion lists empty as well, the call succeeds
- **Expected**: no bound changed for the empty list and the other lists applied. The header (line 23) documents cond1_upt_higher as the "Exchange reactions and relative differences with higher uptake in condition 1 compared to condition 2", a set that can be empty, and the sibling list cond2_upt_higher works when empty
- **Source lines**: 62, 76, 91
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboTools/testSetSemiQuantConstraints.m`

### `src/dataIntegration/metabotools/statisticsAddedExchanges.m`

#### The sample counter is printed for every sample

- **Severity**: cosmetic
- **Trigger**: any call with at least one sample
- **Observed**: (R2025a, 2026-11-15) "i =" and the index are printed once per sample (line 32 has no semicolon)
- **Expected**: no console output, or output gated behind a printLevel
- **Source lines**: 32
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboTools/testStatisticsAddedExchanges.m`

#### The table is not ordered by frequency as documented; the sorted copy goes to a differently spelled variable

- **Severity**: wrong-result
- **Trigger**: R.s1.Ex_RxnsAdded = {'EX_a'; 'EX_b'}; R.s1.MinMaxAddedRxns = [0 1; -1 0]; R.s2.Ex_RxnsAdded = {'EX_b'}; R.s2.MinMaxAddedRxns = [-1 0]; statisticsAddedExchanges(R, {'s1', 's2'})
- **Observed**: (R2025a, 2026-11-15) rows {'EX_a', 1, 'secretion', []} then {'EX_b', 2, [], 'uptake'} (alphabetical order of unique): lines 74 and 76 assign to EX_added_all_unique, while the output is Ex_added_all_unique; sortrows(output, -2) itself returns the rows in the documented order
- **Expected**: EX_b (2 occurrences) before EX_a (1 occurrence)
- **Source lines**: 74-76
- **Documented in**: `test/verifiedTests/dataIntegration/testMetaboTools/testStatisticsAddedExchanges.m`

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

### `src/design/TrimGdel/readGeneRules.m`

#### A model without any gene rule stops with an error

- **Severity**: error
- **Trigger**: readGeneRules(model) with every model.grRules entry empty
- **Observed**: error "Unrecognized function or variable 'term2'." at line 115
- **Expected**: empty term and zero counts
- **Source lines**: 115
- **Documented in**: `test/verifiedTests/design/testTrimGdel/testReadGeneRules.m`

#### A rule enclosed in parentheses stops with an error

- **Severity**: error
- **Trigger**: readGeneRules(model) with model.rxns = {'r1'}, model.genes = {'g1'; 'g2'} and model.grRules = {'(g1 or g2)'} (also '(g1)', a single gene whose name contains "or" or "and" such as 'gor', and ecoli_core_model from getDistributedModel, many of whose rules, e.g. "(b3925 or b4232)" of FBP, are enclosed in parentheses)
- **Observed**: error "Index exceeds the number of array elements. Index must not exceed 1." at line 83: after the inner term is replaced, "(term_1)" (or "(g1)") is left, whose single word has no operator unit(2)
- **Expected**: parentheses around a whole rule or a single gene accepted, as in the grRules of the distributed models
- **Source lines**: 41-42, 75-89
- **Documented in**: `test/verifiedTests/design/testTrimGdel/testReadGeneRules.m`

#### reactionKO2term points into the term list before it is reordered

- **Severity**: wrong-result
- **Trigger**: model.rxns = {'r1';'r2';'r3';'r4';'r5'}, model.genes = {'g1';'g2';'g3';'g4'}, model.grRules = {'g1'; 'g1 and g2'; ''; '(g1 and g2) or g3'; 'g3 or g4'}
- **Observed**: reactionKO2term = [1 2 0 4 5] but the returned term lists term_2 first, so term(1).output is 'term_2', not 'reactionKO_1', and term(2) is reactionKO_1; lines 103-115 reorder term (internal terms first) after lines 48 and 93 set the map
- **Expected**: term(reactionKO2term(i)).output equal to reactionKO_<i> for every reaction i with a rule, as the help text documents
- **Source lines**: 48, 93, 103-115
- **Documented in**: `test/verifiedTests/design/testTrimGdel/testReadGeneRules.m`

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

### `src/design/optForce/saveInputsMustSetsSecondOrder.m`

#### the error messages for empty inputs name the first order function

- **Severity**: cosmetic
- **Trigger**: saveInputsMustSetsSecondOrder with an empty model, minFluxesW, maxFluxesW or inputFolder
- **Observed**: the messages end with "when running saveInputsMustFirstOrder"
- **Expected**: messages naming saveInputsMustSetsSecondOrder
- **Source lines**: 69, 72, 75, 78
- **Documented in**: `test/verifiedTests/design/testOptForce/testSaveInputsMustSetsSecondOrder.m`

### `src/design/optForce/saveInputsOptForce.m`

#### k.mat and nSets.mat are not written

- **Severity**: wrong-result
- **Trigger**: model = createModel({'R1'; 'R2'}, {'first'; 'second'}, {'a -> b'; 'b <=> '}, 'printLevel', 0); saveInputsOptForce(model, {'R2'}, {'R1'}, {'R2'}, [0;-5], [10;0], [1;-5], [10;-1], 3, 2, struct('rxnList', {{'R1'}}, 'values', 1), {}, {}, {}, folder)
- **Observed**: folder holds constrOpt, excludedKRxns, excludedLRxns, excludedURxns, maxFluxesM, maxFluxesW, minFluxesM, minFluxesW, model, mustL, mustU and targetRxn .mat; k.mat and nSets.mat do not exist (lines 136-147 never save k or nSets)
- **Expected**: k.mat and nSets.mat written, as the OUTPUTS section documents, so that the kept inputs of an optForce run are complete
- **Source lines**: 136-147
- **Documented in**: `test/verifiedTests/design/testOptForce/testSaveInputsOptForce.m`

### `src/design/optForceGAMS/exportInputsMustOrder2ToGAMS.m`

#### Every call stops with the error that not all inputs are given

- **Severity**: error
- **Trigger**: model with rxns {'R1'; 'R2'}, mets {'a'; 'b'}, S = sparse([-1 0; 1 -1]), lb = [0; -5], ub = [10; 0]; exportInputsMustOrder2ToGAMS(model, [0; -5], [10; 0], struct('rxnList', {{'R1'}}, 'values', 1), {}, {'R1'}, fullfile(tempname, 'f2')), all seven documented inputs given
- **Observed**: error 'Optforce: All inputs must be specified when using exportInputsMustOrder2ToGAMS' and no folder created; the function has seven inputs but line 76 tests nargin < 8, so no call can pass (R2025a, 2026-11-16). Lines 129 and 132 would fail next: the constraint names are fixed to {'EX_gluc', 'R75', 'EX_suc'} instead of constrOpt.rxnList, and setType is not defined
- **Expected**: the five text files and MtoG.gdx written to inputFolder when all seven inputs are given
- **Source lines**: 76-77, 129, 132
- **Documented in**: `test/verifiedTests/design/testOptForce/testExportInputsMustOrder2ToGAMS.m`

### `src/design/optForceGAMS/exportInputsMustToGAMS.m`

#### Every call stops with the error that not all inputs are given

- **Severity**: error
- **Trigger**: model with rxns {'R1'; 'R2'}, mets {'a'; 'b'}, S = sparse([-1 0; 1 -1]), lb = [0; -5], ub = [10; 0]; exportInputsMustToGAMS(model, [0; -5], [10; 0], struct('rxnList', {{'R1'}}, 'values', 1), fullfile(tempname, 'f1')), all five documented inputs given
- **Observed**: error 'OptForce: All inputs must be specified when running exportInputsMustToGAMS' and no folder created; the function has five inputs but line 58 tests nargin < 6, so no call can pass (R2025a, 2026-11-16). Lines 109 and 112 would fail next: the constraint names are fixed to {'EX_gluc', 'R75', 'EX_suc'} instead of constrOpt.rxnList, and setType is not defined
- **Expected**: the three text files and MtoG.gdx written to inputFolder when all five inputs are given
- **Source lines**: 58-59, 109, 112
- **Documented in**: `test/verifiedTests/design/testOptForce/testExportInputsMustToGAMS.m`

### `src/design/optForceGAMS/exportInputsOptForceToGAMS.m`

#### Every call stops on the undefined variable nSets and leaves the current folder changed

- **Severity**: error
- **Trigger**: model with rxns {'R1'; 'R2'}, mets {'a'; 'b'}, S = sparse([-1 0; 1 -1]), lb = [0; -5], ub = [10; 0]; exportInputsOptForceToGAMS(model, {'R2'}, {'R1'}, {'R2'}, [0; -5], [10; 0], [1; -5], [10; -1], 3, 2, struct('rxnList', {{'R1'}}, 'values', 1), {}, {}, {}, fullfile(tempname, 'f3'))
- **Observed**: error MATLAB:UndefinedFunction 'Unrecognized function or variable 'nSets'.' at line 179 (the input is named n_sets); the nine text files are written but MtoGOF.gdx is not, and the current folder stays inputFolder because line 183 is never reached (R2025a, 2026-11-16)
- **Expected**: nMax.val = n_sets, MtoGOF.gdx written and the current folder restored
- **Source lines**: 179, 183
- **Documented in**: `test/verifiedTests/design/testOptForce/testExportInputsOptForceToGAMS.m`

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

### `src/reconstruction/comparison/modelBorgifier/TmodelStats.m`

#### The share of metabolites with a compartment ('Total' row) is inverted

- **Severity**: wrong-result
- **Trigger**: a plain model in which some metabolite identifiers have no '[x]' compartment suffix, for example Stats = TmodelStats(struct('rxns', {{'R1'}}, 'mets', {{'a[c]'; 'b[c]'; 'glc'}}, 'S', sparse([1; -1; 0])))
- **Observed**: (R2025a, 2026-11-17) Stats.metsByComp{end, 2} = [2 1.5]: line 123 computes count \ nMets (left division, nMets / count = 3 / 2) instead of count / nMets. For identifiers such as {'a_c'; 'b_c'} (no '[x]' suffix at all) it is [0 Inf]. When every identifier has a suffix, count = nMets and both give 1, which hides the defect
- **Expected**: [2 0.6667] (2/3) and [0 0]: the comment of line 112 ("Total metabolite with compartment (should be 100%)") and line 120, which computes each compartment's share as nMetsInComp / nMets, give the intent; the header (line 2) says the function "Can also be used on a normal model"
- **Source lines**: 123
- **Documented in**: `test/verifiedTests/reconstruction/testModelBorgifier/testTmodelStats.m`

### `src/reconstruction/comparison/modelBorgifier/charpos.m`

#### The letters i and j count as digits

- **Severity**: wrong-result
- **Trigger**: a text containing the letter i or j (or other characters that str2double reads as numbers)
- **Observed**: each character is tested with str2double, which reads i and j as the imaginary unit, so charpos reports them as numeric
- **Expected**: only the digits 0 to 9 reported as numeric
- **Source lines**: 4-6
- **Documented in**: `test/verifiedTests/reconstruction/testModelBorgifier/testCharpos.m`

### `src/reconstruction/comparison/modelBorgifier/cleanTmodel.m`

#### Lengthening a short lb, ub or c array overwrites its last value with 0

- **Severity**: wrong-result
- **Trigger**: a template model with one model m1, rxns {'R1'; 'R2'; 'R3'}, mets {'a[c]'; 'b[c]'; 'd[c]'}, S = sparse([-1 0 -1; 1 -1 0; 0 1 1]), lb.m1 = [-10; -20] (one value short, as for the "old models" the code comment names), ub.m1 = [10; 20; 30], c.m1 = [0; 0; 1], Models.m1.rxns = true(3, 1), Models.m1.mets = true(3, 1), the other TmodelFields fields as empty texts, rxnID = rxns, metID = mets, metNames = {'A'; 'B'; 'D'}, metCharge = zeros(3, 1); out = cleanTmodel(T)
- **Observed**: out.lb.m1 = [-10; 0; 0]: the lower bound -20 of R2 is replaced by 0, because line 97 assigns nowArray(end:nRxns) = 0 instead of nowArray(end + 1:nRxns) = 0 (the membership arrays use end + 1, lines 108 and 115) (R2025a, 2026-11-15)
- **Expected**: out.lb.m1 = [-10; -20; 0]: the existing values kept and only the missing reaction padded with 0
- **Source lines**: 97
- **Documented in**: `test/verifiedTests/reconstruction/testModelBorgifier/testCleanTmodel.m`

### `src/reconstruction/comparison/modelBorgifier/compareAllMets.m`

#### Models with no positively scored metabolite pair stop with an undefined-function error

- **Severity**: error
- **Trigger**: C.mets = {'a[c]'}; C.metNames = {'alpha'}; C.metFormulas = {'C1'}; C.metCharge = 0; C.metKEGGID = {''}; C.metSEEDID = {''}; T.mets = {'b[e]'}; T.metID = {'b'}; T.metNames = {'beta'}; T.metFormulas = {'C2'}; T.metCharge = 1; T.metKEGGID = {''}; T.metSEEDID = {''}; compareAllMets(C, T)
- **Observed**: "Undefined function 'zeroes' for input arguments of type 'double'." at line 165: the only pair scores -1 - 100 - 1 - 5 - 1 < 0, is clipped to 0, and the else branch calls zeroes (R2025a, 2026-11-15)
- **Expected**: a zero score matrix of size 1 x 1 (zeros(size(metScores))), as the branch intends
- **Source lines**: 165
- **Documented in**: `test/verifiedTests/reconstruction/testModelBorgifier/testCompareAllMets.m`

### `src/reconstruction/comparison/modelBorgifier/countC.m`

#### Elements whose symbol starts with C are counted as carbon

- **Severity**: wrong-result
- **Trigger**: a formula with chlorine, calcium, cobalt, copper, ... and no carbon, for example Cl2 or CaCl2
- **Observed**: the pattern C followed by digits matches the first letter of Cl, Ca, Co, Cu, ..., so Cl2 gives 1 instead of 0
- **Expected**: 0 carbon atoms
- **Source lines**: 39-47
- **Documented in**: `test/verifiedTests/reconstruction/testModelBorgifier/testCountC.m`

### `src/reconstruction/comparison/modelBorgifier/findMetMatch.m`

#### A SEED identifier given as a cell stops the function

- **Severity**: limitation
- **Trigger**: global CMODEL TMODEL with TMODEL the six template metabolites of testMetCompare (glc_D[c], atp[c], adp[c], g6p[c], h[c], glc_D[e] with metID, metNames, metFormulas, metCharge, metKEGGID, metSEEDID, S); CMODEL.mets = {'glc_D[c]'}, metNames = {'D-Glucose'}, metFormulas = {'C6H12O6'}, metCharge = 0, metKEGGID = {'C00031'}, metSEEDID = {{'cpd00027'}}; findMetMatch(1)
- **Observed**: "Invalid data type. Argument must be numeric, char, or logical." at line 168: the KEGG branch converts a cell pipePos with cell2mat (lines 145-147) and accepts a cell identifier, the SEED branch does not (R2025a, 2026-11-15)
- **Expected**: a cell SEED identifier handled as a cell KEGG identifier is (an undocumented input: verifyModelBorg, its line 272, builds metSEEDID as a cell of char)
- **Source lines**: 164-169
- **Documented in**: `test/verifiedTests/reconstruction/testModelBorgifier/testFindMetMatch.m`

#### Names and identifiers are used as regular expressions without escaping

- **Severity**: wrong-result
- **Trigger**: a compared metabolite whose name (or identifier, formula, KEGG or SEED identifier) contains a regular-expression metacharacter, for example the name 'Water (pure)' against the identical template name 'Water (pure)'
- **Observed**: regexpi({'Water (pure)'}, '(\||\<)Water (pure)(\>|\|)') finds no match ('(pure)' is a group matching 'pure'); a name such as '(R)-3-Hydroxybutanoyl-[acyl-carrier protein]' does not match itself either, so the name criterion adds nothing for such metabolites; '.' or '+' match other characters (R2025a, 2026-11-15)
- **Expected**: the text matched literally (regexptranslate('escape', ...)), as the criterion compares names. Severity audit 2026-11-15: OUTPUTS documents "matchScores: Array of sorted, normalized scores for each met"; the name criterion (lines 84, 86, 113, 126, 151, 169) wraps names in \< \> to match them as whole words, i.e. literally, but metacharacters common in metabolite names (parentheses, brackets, +, .) are not escaped, so identical names do not match and the scores are wrong for a large class of valid inputs
- **Source lines**: 84, 86, 113, 126, 151, 169
- **Documented in**: `test/verifiedTests/reconstruction/testModelBorgifier/testFindMetMatch.m`

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

### `src/reconstruction/comparison/modelBorgifier/mapMatch.m`

#### 'noSeed' score of a single-metabolite compared reaction uses the minimum over the template metabolites

- **Severity**: wrong-result
- **Trigger**: C.mets = {'c1'; 'c2'}; C.rxns = {'R1'; 'R2'}; C.S = sparse([1 -1; 0 1]); T.mets = {'t1'; 't2'; 't3'}; T.rxns = {'Q1'; 'Q2'}; T.S = sparse([-1 1; 1 0; 1 0]); T.Models.m1.mets = true(3, 1); rmatch = mapMatch(C, T, 'noSeed')
- **Observed**: rmatch(1, 1) = 1. The differences in reaction counts between c1 and t1, t2, t3 are [0 1 1]; line 81 takes min(diffNumRxns(s1(:, ir1), s2(:, ir2))), which for one compared metabolite (a 1 x 3 row) is the minimum over the template metabolites (0) instead of the per-template-metabolite minimum over the compared metabolites that the same line computes for two or more compared metabolites; 0 * |3 - 1| gives 1 / (0 + 1) = 1 (R2025a, 2026-11-15)
- **Expected**: mean([0 1 1]) = 2/3, times the metabolite-count difference 2, gives rmatch(1, 1) = 1 / (4/3 + 1) = 3/7, the value of the documented "average of the minimum difference" computed as for reactions with several metabolites (min(..., [], 1))
- **Source lines**: 81
- **Documented in**: `test/verifiedTests/reconstruction/testModelBorgifier/testMapMatch.m`

### `src/reconstruction/comparison/modelBorgifier/optimalScores.m`

#### A training list with exactly one matched reaction stops with an index error

- **Severity**: error
- **Trigger**: global SCORE CMODEL TMODEL; SCORE = rand(3, 3, 2); CMODEL.metNums = zeros(3, 5); TMODEL.metNums = zeros(3, 5); optimalScores([1; 0; -1], 'none')
- **Observed**: "Index in position 1 exceeds array bounds. Index must not exceed 1." at line 75: hitPos is 1 x 2 ([row, match]) and length(hitPos) = 2 counts its columns, so the loop over the hits runs twice (also for 'svm', 'RF', 'linear' and 'exp', as the loop precedes the choice of optimizer) (R2025a, 2026-11-15)
- **Expected**: one hit: hitVec of size 2 x 1, missVec of size 2 x 2, the weights and the normalized scoreTotal returned (size(hitPos, 1) instead of length(hitPos))
- **Source lines**: 63, 68, 74-75
- **Documented in**: `test/verifiedTests/reconstruction/testModelBorgifier/testOptimalScores.m`

### `src/reconstruction/comparison/modelBorgifier/readCbTmodel.m`

#### rules and rxnGeneMat are never built

- **Severity**: wrong-result
- **Trigger**: any Tmodel whose model has genes, for example T above without the change of rxnID
- **Observed**: R has genes but neither rules nor rxnGeneMat: line 219 tests sum of the all-zero matrix made at line 216, so lines 220-242 never run (R2025a, 2026-11-16)
- **Expected**: rules and rxnGeneMat built from grRules and genes
- **Source lines**: 216, 219-242
- **Documented in**: `test/verifiedTests/reconstruction/testModelBorgifier/testReadCbTmodel.m`

#### rxnID and metID entries are shifted when an entry has no ID of the model

- **Severity**: wrong-result
- **Trigger**: m with rxns {'R1'; 'R2'; 'EX_a'}, mets {'a[c]'; 'B'; 'c[c]'}, S = sparse([-1 0 -1; 1 -1 0; 0 1 0]), lb = [0; -10; -10], ub = [10; 0; 10], c = [0; 1; 0], rxnNames, metNames {'A'; 'B[e]'; 'C'}, grRules {'g1 or g2'; ''; 'g3'}, genes {'g1'; 'g2'; 'g3'}, description 'modelA'; T = buildTmodel(verifyModelBorg(m, 'keepName')); T.rxnID{1} = ''; R = readCbTmodel('modelA', T, 'n')
- **Observed**: R.rxnID = {''; ''; 'r2'}: line 161 writes IDs{iRxn} to entry IDIndexes(iRxn), so the ID of the second reaction goes to the third and the second is blanked; line 188 does the same for metID (T.metID{1} = '' gives {''; ''; 'b[e]'} instead of {''; 'b[e]'; 'c[c]'}) (R2025a, 2026-11-16). buildTmodel keeps empty rxnID and metID entries (its line 46), so such a Tmodel is a valid input
- **Expected**: R.rxnID = {''; 'r2'; 'ex_a'} (IDs{IDIndexes(iRxn)})
- **Source lines**: 161, 188
- **Documented in**: `test/verifiedTests/reconstruction/testModelBorgifier/testReadCbTmodel.m`

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

### `src/reconstruction/demeter/src/integration/createRBioNetDBFromVMHDB.m`

#### A metabolite without time stamp stops the conversion with an error

- **Severity**: limitation
- **Trigger**: MetaboliteDatabase.txt with a row whose 12th column is empty, e.g. the rows 'atp ATP C C -4 C00002 5957 15422 . . H 19/09/2018 N' and 'h2o W H2O H2O 0 C00001 962 15377 . . H . .' (tab-separated, '.' an empty field), then createRBioNetDBFromVMHDB('rBioNetDBFolder', tempname-folder)
- **Observed**: Failed to convert date number to date vector. Date number out of range. (datestr of NaT at line 26; R2025a, 2026-11-15). The shipped database has a time stamp on every row read, so it does not trigger it; the input is skipped below.
- **Expected**: the missing time stamp kept, as lines 37-41 do for reactions
- **Source lines**: 26
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testCreateRBioNetDBFromVMHDB.m`

#### The call saves the whole MATLAB path to pathdef.m

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: savepath is called after addpath(rBioNetDBFolder) (line 61), so every folder on the path of the session is written to the user's pathdef.m; the help does not mention it
- **Expected**: the documented outputs only, or the side effect documented
- **Source lines**: 61
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testCreateRBioNetDBFromVMHDB.m`

### `src/reconstruction/demeter/src/integration/gapfillRefinedGenomeReactions.m`

#### The first gap-filled row overwrites the last annotation row

- **Severity**: wrong-result
- **Trigger**: a genome annotation to which at least one gap-filling rule applies
- **Observed**: the row counter starts at the number of rows instead of one more, so the first added row replaces the last row of the input
- **Expected**: all input rows kept and the new rows appended after them
- **Source lines**: 127
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testGapfillRefinedGenomeReactions.m`

### `src/reconstruction/demeter/src/integration/getCurationStatus.m`

#### Data entries 1 and -1 cancel out and the organism is reported without experimental data

- **Severity**: wrong-result
- **Trigger**: in a temporary folder d, info.txt with the lines MicrobeID, orgA, orgB, and CarbonSourcesTable.txt, FermentationTable.txt, GrowthRequirementsTable.txt, secretionProductTable.txt and uptakeTable.txt each with the tab-separated lines 'MicrobeID X1 X2 Ref1', 'orgA 1 -1 PMID:1', 'orgB 1 0 PMID:2'; getCurationStatus(fullfile(d, 'info.txt'), d, false)
- **Observed**: orgA gets 1 in every column and orgB gets 2: line 70 tests abs(sum(data)) > 0, and 1 + (-1) = 0 (R2025a, 2026-11-15). In the distributed GrowthRequirementsTable.txt (values 1, 0, -1) no strain has a zero sum (0 of 4750 strains with data), so the shipped resource is not affected
- **Expected**: 2 for orgA as for orgB (the documented "2 indicates that the reconstruction was refined against available experimental data"): any non-zero entry, for example any(cell2mat(...) ~= 0)
- **Source lines**: 70
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testGetCurationStatus.m`

### `src/reconstruction/demeter/src/integration/getUnannotatedReactionsFromPubSeedSpreadsheets.m`

#### Spreadsheets with no unannotated reaction stop with an index error

- **Severity**: error
- **Trigger**: in a temporary folder d (also the current folder): info2.txt with the tab-separated lines 'MicrobeID PubSeedID' and 'orgA Org A (1.1)'; InReactions.txt 'PubSEED Abreviation VMH Abbreviation' and 'GeneX RXN1'; ReactionTranslationTable.txt 'TranslatedReaction VMHreaction' and 'rxn1 RXN1'; gapfilledGenomeAnnotation.txt 'orgB RXN9 gap_filled'; d/ss/a.tsv 'Organism GeneX' and 'Org A (1.1) 123' (every gene annotated); getUnannotatedReactionsFromPubSeedSpreadsheets(fullfile(d, 'info2.txt'), d, fullfile(d, 'ss'))
- **Observed**: "Index in position 2 exceeds array bounds." at line 84: unannotatedRxns is the 0 x 0 cell {} and unannotatedRxns(:, 1) fails (R2025a, 2026-11-15)
- **Expected**: an empty list of unannotated reactions returned
- **Source lines**: 84
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testGetUnannotatedReactionsFromPubSeedSpreadsheets.m`

#### The documented default of inputDataFolder is not implemented

- **Severity**: unusable-option
- **Trigger**: the files of the entry above, with gapfilledGenomeAnnotation.txt moved to d/InputData, the line 'GeneY RXN2' added to InReactions.txt, 'rxn2 RXN2' added to ReactionTranslationTable.txt, and d/ss/a.tsv replaced by the tab-separated lines 'Organism GeneX GeneY', 'Org A (1.1) 123 <empty>' and 'Org B (2.1) 5 7'; from d, getUnannotatedReactionsFromPubSeedSpreadsheets(fullfile(d, 'info2.txt'), [], fullfile(d, 'ss')) (or '' for inputDataFolder); inputDataFolder cannot be omitted because spreadsheetFolder follows it, so an empty value is the only way to ask for the default
- **Observed**: (R2025a, 2026-11-17, Linux) "Unable to find or open '/gapfilledGenomeAnnotation.txt'." (readtable, called at line 75 through readInputTableForPipeline): [[] filesep 'gapfilledGenomeAnnotation.txt'] is a path in the root of the file system; there is no nargin or isempty handling. The same call with fullfile(d, 'InputData') returns {'orgA', 'RXN2'}
- **Expected**: d/InputData/gapfilledGenomeAnnotation.txt read, as the header documents ("inputDataFolder: ... (default: folder in current path called "InputData")", lines 14-15)
- **Source lines**: 75
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testGetUnannotatedReactionsFromPubSeedSpreadsheets.m`

#### The loop counter i is printed for every spreadsheet and every organism

- **Severity**: cosmetic
- **Trigger**: the call of the entry above with fullfile(d, 'InputData')
- **Observed**: (R2025a, 2026-11-17) "i = 1" is printed twice to the command window, by the statements without a semicolon of lines 47 and 86; the result is not affected
- **Expected**: no output other than the returned list (no progress output is documented)
- **Source lines**: 47, 86
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testGetUnannotatedReactionsFromPubSeedSpreadsheets.m`

### `src/reconstruction/demeter/src/integration/mapKBaseToVMHReactions.m`

#### A KBase reaction irreversible where the VMH reaction is reversible is not reported as similar

- **Severity**: wrong-result
- **Trigger**: current folder d holding MetaboliteDatabase.txt (one 13-column row) and ReactionDatabase.txt (12-column header and the rows RXNA 'a[c] + g[c] <=> b[c]' reversible 1, RXNB 'c[c] -> d[c]' reversible 0, RXNC 'e[c] <=> f[c] + h[c]' reversible 1); kb = {'k1', 'x', 'a[c] + g[c] -> b[c]'; 'k2', 'x', 'c[c] <=> d[c]'; 'k3', 'x', 'f[c] + h[c] <=> e[c]'}; [same, similar] = mapKBaseToVMHReactions(kb)
- **Observed**: same holds k3/RXNC and similar holds k2/RXNB (reversible in KBase, irreversible in VMH), but k1/RXNA is in neither table: a reversible VMH reaction is written only with '<=>' (lines 80-87) and an irreversible KBase reaction only with '->', so the two strings never meet in the intersect of line 154 (R2025a, 2026-11-15)
- **Expected**: k1/RXNA in similarReactions (irreversible in KBase, reversible in VMH: the documented "or vice versa" case)
- **Source lines**: 80-87, 138-149
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testMapKBaseToVMHReactions.m`

### `src/reconstruction/demeter/src/integration/printRefinedModelIDs.m`

#### files that are not SBML or .mat files are returned as model identifiers

- **Severity**: wrong-result
- **Trigger**: a folder holding the empty files A_b.sbml and notes.txt, then printRefinedModelIDs(folder); or a folder holding only notes.txt and other.csv
- **Observed**: (R2025a, 2026-11-15) {'A_b'; 'notes_txt'} for the first folder and {'other_csv'} for the second. Line 27 applies any() to the whole column returned by contains, so delInd is 1 when no file matches (only the first file is removed) and empty otherwise (no file is removed)
- **Expected**: {'A_b'} for the first folder and no identifier for the second: every file whose name contains neither 'sbml' nor 'mat' removed (the comment of line 26)
- **Source lines**: 27-28
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testPrintRefinedModelIDs.m`

### `src/reconstruction/demeter/src/integration/writeReactionsFromPubSeedSpreadsheets.m`

#### The documented default of inputDataFolder is not implemented

- **Severity**: unusable-option
- **Trigger**: writeReactionsFromPubSeedSpreadsheets(infoFilePath, [], spreadsheetFolder) (or '' for inputDataFolder) run from a folder that holds the information file, InReactions.txt and the VMH database; inputDataFolder cannot be omitted because spreadsheetFolder follows it, so an empty value is the only way to ask for the default
- **Observed**: (R2025a, 2026-11-17, Linux) "Unable to open file '/genomeAnnotation.txt' for writing" at line 129: [[] filesep 'genomeAnnotation'] is a path in the root of the file system; there is no nargin or isempty handling; ./InputData is not written
- **Expected**: the file written to the folder InputData of the current folder, as the header documents ("inputDataFolder: Folder to save propagated data to (default: folder in current path called "InputData")", lines 11-12)
- **Source lines**: 129
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testWriteReactionsFromPubSeedSpreadsheets.m`

### `src/reconstruction/demeter/src/properties/computeMetabolicDistance.m`

#### the blocks of 100 rows run past the last strain

- **Severity**: error
- **Trigger**: the same two files with 3 strains x 2 features, then computeMetabolicDistance(d, 'v', 0)
- **Observed**: (R2025a, 2026-11-15) error "Index in position 1 exceeds array bounds. Index must not exceed 4." at line 38 (the parfor over k = j:j+99 reads data(k, k+1:end))
- **Expected**: one distance per pair of the 3 strains; the loop limited to the rows that exist (and the distance taken between strains, not along a diagonal of the table)
- **Source lines**: 37-39
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testComputeMetabolicDistance.m`

#### the distances are stored in comDistTmp but read from the undefined comDist

- **Severity**: error
- **Trigger**: ComputedFluxes/UptakeSecretion_v.txt and ReactionPresence/ReactionPresence_v.txt in a folder d, each with a header row and 101 strains x 3 features of 0/1, then computeMetabolicDistance(d, 'v', 0) run from d
- **Observed**: (R2025a, 2026-11-15) error "Unrecognized function or variable 'comDist'." at line 52; comDistTmp.mat was written to the current folder first
- **Expected**: the pairwise distances of the first file stored in column 3 of the table
- **Source lines**: 38-41, 52, 54
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testComputeMetabolicDistance.m`

### `src/reconstruction/demeter/src/properties/getSubsystemPresence.m`

#### The documented default of propertiesFolder is not implemented

- **Severity**: unusable-option
- **Trigger**: getSubsystemPresence([], 'v') or getSubsystemPresence('', 'v') run in a folder that holds Reactions_v.txt and ReactionMetabolitePresence/ reactionPresence_v.txt; propertiesFolder is the first argument and reconVersion is required, so an empty value is the only way to ask for the default
- **Observed**: (R2025a, 2026-11-17, Linux) "Unable to find or open '/Reactions_v.txt'. Check the path and filename or file permissions." (readtable, called through readInputTableForPipeline from line 20): [[] filesep 'Reactions_v.txt'] is a path in the root of the file system; there is no nargin or isempty handling. The same call with propertiesFolder '.' writes the output
- **Expected**: the files read from and written to the current folder, as the header documents ("propertiesFolder: Folder where the retrieved subsystem presences will be stored (default: current folder)", lines 13-14)
- **Source lines**: 20, 23
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testGetSubsystemPresence.m`

### `src/reconstruction/demeter/src/properties/plotMetaboliteProducersConsumers.m`

#### the default metsToAnalyze analyses no metabolite

- **Severity**: unusable-option
- **Trigger**: plotMetaboliteProducersConsumers(d, info, 'v') without metsToAnalyze
- **Observed**: (code reading, R2025a source of 2026-11-15; not reachable while the defect above stops the function at line 79) the default {} makes setdiff of line 83 return every column, so line 84 deletes every metabolite column and nothing is listed or plotted
- **Expected**: all computed metabolites (the help: "default: all computed metabolites")
- **Source lines**: 30, 83-84
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testPlotMetaboliteProducersConsumers.m`

#### the header row of a numeric flux file is dropped by readtable

- **Severity**: error
- **Trigger**: in folder d, ComputedFluxes/uptakeFluxes_v.txt, secretionFluxes_v.txt and internalProduction_v.txt, each {'', 'EX_glc_D(e)', 'EX_lac_L(e)'; 's1', -1, 0; 's2', 0, -2} written tab-separated; info3.txt with MicrobeID and taxon columns for s1-s3; plotMetaboliteProducersConsumers(d, 'd/info3.txt', 'v', 'metsToAnalyze', {'glc_D', 'lac_L'})
- **Observed**: (R2025a, 2026-11-15) error "Cell elements must be character vectors." at line 79: readtable(..., 'ReadVariableNames', false) of line 74 detects the header line and skips it, so data(1, :) is {'s1', -1, 0} and strrep fails on the numbers; the current folder is left at d/Figures_Metabolites/uptakeFluxes
- **Expected**: the metabolite header kept as row 1 (as readInputTableForPipeline returns it) and the lists and plots written
- **Source lines**: 74-75, 79
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testPlotMetaboliteProducersConsumers.m`

#### the metabolite counter is printed

- **Severity**: cosmetic
- **Trigger**: any call that reaches line 115
- **Observed**: (code reading) "j = 2", "j = 3", ... printed for every metabolite (the statement j has no semicolon)
- **Expected**: no console output, or progress gated behind a print level
- **Source lines**: 115
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testPlotMetaboliteProducersConsumers.m`

### `src/reconstruction/demeter/src/properties/producetSNEPlots.m`

#### 16 to 19 taxa with few singletons raise an index error

- **Severity**: error
- **Trigger**: info.txt (tab-separated: MicrobeID, Phylum, Class, Order, Family, Genus, Species) for 32 strains m01..m32, every rank of strain k = P<ceil(k/2)> (16 taxa of 2 strains); ReactionMetabolitePresence/ReactionPresence_v.txt in folder d (header row, one row per strain, 3 positive features); producetSNEPlots(d, 'd/info.txt', 'v')
- **Observed**: (R2025a, 2026-11-15) error "Index exceeds the number of array elements. Index must not exceed 16." at line 160 (uniqueXX = uniqueXX(1:20) with 16 taxa), before tsne is reached; the folder tSNE_Plots was created
- **Expected**: all taxa kept when there are fewer than 20 (keep the min(20, n) largest)
- **Source lines**: 155-160
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testProducetSNEPlots.m`

#### the custom-feature branch filters on the taxa of the last taxon level

- **Severity**: cosmetic
- **Trigger**: producetSNEPlots(d, info, 'v', {'Gram'}) with at least 10 strains
- **Observed**: (code reading, R2025a source of 2026-11-15) lines 246-248 remove rows where taxa (the species list left by the taxon loop, already without 'N/A' and of another length) is 'N/A', so they never remove anything; the strains whose feature is 'N/A' are kept. Lines 66-67 already drop strains absent from the information table, so no 'N/A' feature arises unless the first header of the property file is itself an identifier of the information table
- **Expected**: the filter applied to feats (strains with no information on the feature removed from data, red_orgs and feats)
- **Source lines**: 246-248
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testProducetSNEPlots.m`

#### the custom-feature branch reads perpl, which only the taxon branch sets

- **Severity**: error
- **Trigger**: info.txt (tab-separated: MicrobeID, Phylum, Class, Order, Family, Genus, Species, Gram) for exactly 10 strains m01..m10 (ranks P1..Spec1 for m01-m05 and P2..Spec2 for m06-m10, Gram 'pos' or 'neg'); ReactionMetabolitePresence/ ReactionPresence_v.txt in folder d (header row, one row per strain, 3 positive features); producetSNEPlots(d, 'd/info.txt', 'v', {'Gram'})
- **Observed**: (R2025a, 2026-11-17) error "Unrecognized function or variable 'perpl'." at line 260, also with a stand-in tsne on the path, so the missing toolbox does not mask it; the same call without customFeatures returns normally. perpl is assigned only at lines 178-186, inside "if size(data,1) > 10" of the taxon loop, which no taxon level reaches with 10 strains, while the custom-feature branch runs from 10 strains on (line 250); the current folder is left at d (line 301 is not reached)
- **Expected**: a perplexity chosen for the custom-feature embedding as well (the rule of lines 178-186 applied to its own data), so that 10 strains with a custom feature are embedded
- **Source lines**: 175-186, 250, 260
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testProducetSNEPlots.m`

#### three t-SNE coordinates are stored in two columns

- **Severity**: error
- **Trigger**: customFeatures given and at least 10 strains with information, so that line 260 computes Y with 'NumDimensions' 3
- **Observed**: (R2025a, 2026-11-15; tsne is not installed, so the assignment of line 263 was run alone with a 10 x 3 Y) error "Unable to perform assignment because the size of the left side is 10-by-2 and the size of the right side is 10-by-3."
- **Expected**: columns 3:5 (or a two-dimensional embedding), as the header of line 296 names only an x and a y value
- **Source lines**: 263
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testProducetSNEPlots.m`

### `src/reconstruction/demeter/src/properties/rankFeaturesByIncidence.m`

#### metabolite and uptake/secretion features are looked up in the reaction database

- **Severity**: wrong-result
- **Trigger**: rankFeaturesByIncidence(d, 'v') with metabolite IDs (e.g. 'atp') in MetabolitePresence_v.txt and '<exchange>_uptake'/'<exchange>_secretion' columns (as computeUptakeSecretion writes them) in UptakeSecretion_v.txt
- **Observed**: (code reading, R2025a source of 2026-11-15) for i < 4 (line 46) every feature is searched in database.reactions, so metabolite presence and uptake/secretion features never get a description, formula or subsystem
- **Expected**: metabolite presence described from database.metabolites (as internal production is) and uptake/secretion features described from their exchange reaction
- **Source lines**: 46, 51-56
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testRankFeaturesByIncidence.m`

#### the percentage of reconstructions is divided by the count of the most common feature

- **Severity**: wrong-result
- **Trigger**: in folder d, ReactionMetabolitePresence/ReactionPresence_v.txt, ReactionMetabolitePresence/MetabolitePresence_v.txt, ComputedFluxes/UptakeSecretion_v.txt and ComputedFluxes/InternalProduction_v.txt, each with header {'Model_ID', 'ATPM', 'PGI'} and 20 strains, ATPM 1 in strains 1-10, PGI 1 in strains 1-4, 0 otherwise; rankFeaturesByIncidence(d, 'v')
- **Observed**: (R2025a, 2026-11-15) Ranked_features/Reaction_presence_ranked_v.xls: ATPM "Number of reconstructions" '10', "Percentage of reconstructions" '1'; PGI '4' and '0.4' (lines 59 and 75 divide by max(B)); the plot (ylabel "Fraction of presence in tested reconstructions") shows the same values
- **Expected**: 10/20 = 0.5 and 4/20 = 0.2, the fraction of the 20 reconstructions (or a percentage) as the column header and the plot label say
- **Source lines**: 59, 75
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testRankFeaturesByIncidence.m`

### `src/reconstruction/demeter/src/properties/summarizeFeaturesOnTaxonLevels.m`

#### numeric presence values become NaN on R2020a and newer

- **Severity**: wrong-result
- **Trigger**: the first call above once line 49 is fixed
- **Observed**: (R2025a, 2026-11-15) readInputTableForPipeline returns the presence values as numbers ({'m1', [1]}), and str2double({1, 0}) is [NaN NaN], so line 55 makes every taxon sum NaN, normalised to 0 by lines 72-78 (line 112 has the version branch that line 55 lacks)
- **Expected**: the sums of the 0/1 presence values of the strains of each taxon
- **Source lines**: 55
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testSummarizeFeaturesOnTaxonLevels.m`

#### the row range is built from size(getTax), a two-element vector

- **Severity**: error
- **Trigger**: in folder d, Refined/ReactionMetabolitePresence/reactionPresence_v_refined.txt ({'', 'r1', 'r2'; 's1', 1, 0; 's2', 1, 1; 's3', 0, 1}) and info3.txt (MicrobeID, Phylum, Class, Order, Family, Genus, Species, Gram for s1-s3); summarizeFeaturesOnTaxonLevels(d, 'd/info3.txt', 'v'); and, with an information table of one strain, summarizeFeaturesOnTaxonLevels(d, 'd/info1.txt', 'v', {'Gram'})
- **Observed**: (R2025a, 2026-11-15) error "Colon operands must be real scalars." at line 49 (taxon levels) and at line 105 (custom features)
- **Expected**: rows 2:numel(getTax)+1 filled with the taxa
- **Source lines**: 49, 105
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testSummarizeFeaturesOnTaxonLevels.m`

#### the table of taxon level i is named with the file prefix of row i

- **Severity**: error
- **Trigger**: the first call above once line 49 is fixed (more than 4 taxon levels)
- **Observed**: (code reading, R2025a source of 2026-11-15) line 91 indexes files{i,1} with the taxon-level index i = 1..6 although files has 4 rows: index error at the Class level, and the tables of every property file are written under the prefixes ReactionPresence_ to InternalProduction_ by taxon level, overwriting each other
- **Expected**: files{f,1} (the prefix of the property file being summarised); the same applies to line 151
- **Source lines**: 91, 151
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testSummarizeFeaturesOnTaxonLevels.m`

#### undefined variable ddataByFeature

- **Severity**: error
- **Trigger**: customFeatures given, once line 105 is fixed
- **Observed**: (code reading, R2025a source of 2026-11-15) line 126 reads size(ddataByFeature, 1); ddataByFeature is defined nowhere in the file, so the custom-feature branch raises "Unrecognized function or variable" and the heat map of line 140 is never drawn
- **Expected**: size(dataByFeature, 1)
- **Source lines**: 126
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testSummarizeFeaturesOnTaxonLevels.m`

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

### `src/reconstruction/demeter/suite/reports/compareVersions.m`

#### Every comparison stops at a test function that does not exist in the toolbox

- **Severity**: error
- **Trigger**: folders prev/ and new/ (passed with a trailing filesep) each holding mic1.mat with model = createModel({'EX_a', 'biomass_x'}, {'Ex a', 'biomass'}, {'a[e] <=>', 'a[e] ->'}) and model.genes = {'g1'} (lb of EX_a -5 in the new one), an existing report folder rep; compareVersions(prev, new, rep, 'mic1', [])
- **Observed**: "Undefined function 'Test_MassChargeBalance' for input arguments of type 'struct'." at line 278, after the report was written up to the section 'Mass and charge balance'; the report file stays open (fopen of line 46, fclose only at line 878). None of Test_MassChargeBalance, Test_LeakingMetabolites, Test_ATP, Test_Growth, Test_CarbonSources, Test_FermentationProducts, Test_NutrientRequirements, Test_BvitaminBiosynthesis, Test_VitaminSecretion or Test_BileAcidBiosynthesis exists anywhere in the repository (R2025a, 2026-11-15)
- **Expected**: the complete report, the summary table and the lists of the documented outputs
- **Source lines**: 278, 280, 383-384, 412-413, 436-437, 463-464, 521-522, 580, 582, 699-700, 760-761, 819-820
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testCompareVersions.m`

#### Metabolite content is reported as identical whenever the reactions are identical

- **Severity**: wrong-result
- **Trigger**: the two models of the entry above with the metabolite a[e] of the new model renamed b[e] (same reactions)
- **Observed**: line 166 compares modelNew.rxns with modelPrevious.rxns, so the report says 'Metabolites are identical in both models.' and outputSummary(2, 3) is 'Unchanged' although the metabolites differ (read from the code; the report text up to line 278 confirms the message, R2025a, 2026-11-15)
- **Expected**: metabolites compared (modelNew.mets with modelPrevious.mets), 'Changed' and the lists of metabolites only in one version
- **Source lines**: 166-168
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testCompareVersions.m`

### `src/reconstruction/demeter/suite/reports/printRefinementReport.m`

#### Aromatic amino acid results are reported as bile acids, bile acids as drugs, drugs are left out

- **Severity**: wrong-result
- **Trigger**: <reconVersion>_PercentagesAgreement.xls written as plotTestSuiteResults writes it (header Feature/StrainsWithData/PercentAgreeing, then the rows Carbon_sources, Fermentation_products, PutrefactionPathways, Secretion_products, Metabolite_uptake, AromaticAminoAcidDegradation, Bile_acid_biosynthesis, Drug_metabolism, growsOnDefinedMedium with the numbers 10, 20, ..., 90 and fractions 0.1, ..., 0.9), ATP_from_O2_proj.txt with three models, then printRefinementReport(testResultsFolder, 'proj')
- **Observed**: 'Bile acid pathways were refined for 60 reconstructions.' and the row 'Reconstructions with bile acids comparative genomic data' 60 / 0.6 (the AromaticAminoAcidDegradation row), 'Drug pathways were refined for 70 reconstructions.' and the row 'Reconstructions with drug comparative genomic data' 70 / 0.7 (the Bile_acid_biosynthesis row); the Drug_metabolism row (80) is not reported (R2025a, 2026-11-15)
- **Expected**: bile acids 70 / 0.7, drugs 80 / 0.8, and the aromatic amino acid degradation row reported under its own name or not at all
- **Source lines**: 85-96
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testPrintRefinementReport.m`

### `src/reconstruction/demeter/suite/tests/plotTestSuiteResults.m`

#### growth on the defined medium is lost when the file holds only numbers

- **Severity**: wrong-result
- **Trigger**: in folder d/res_refined, growsOnDefinedMedium_v.txt {'s1', 1; 's2', 0; 's3', 1}, Carbon_sources_TruePositives_v.txt {'s1', 'glc'; 's2', ''; 's3', 'lac'} and Carbon_sources_FalseNegatives_v.txt {'s1', ''; 's2', 'fru'; 's3', ''} (written tab-separated as batchTestAllReconstructionFunctions writes them); plotTestSuiteResults('d/res_refined', 'v')
- **Observed**: (R2025a, 2026-11-15) v_PercentagesAgreement.xls row growsOnDefinedMedium: StrainsWithData 0, PercentAgreeing missing (0/0 = NaN); readtable(..., 'format', 'auto') of line 46 reads the 0/1 column as numbers and str2double of a numeric cell is NaN (lines 68, 268-269); the violin plot of line 95 gets NaN data
- **Expected**: StrainsWithData 3 and PercentAgreeing 2/3 (the file holds 2 growing and 1 non-growing strain), as for a file that also holds 'NA' (read as text)
- **Source lines**: 46, 67-68, 268-269, 274
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testPlotTestSuiteResults.m`

#### the sensitivity column header loses its blank

- **Severity**: cosmetic
- **Trigger**: the call above
- **Observed**: (R2025a, 2026-11-15) v_Properties.xls header 'Sensitivityv': strcat removes the trailing blank of 'Sensitivity '
- **Expected**: 'Sensitivity v'
- **Source lines**: 120
- **Documented in**: `test/verifiedTests/reconstruction/testDemeter/testPlotTestSuiteResults.m`

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

### `src/reconstruction/growthExpMatch/printSolutionGEM.m`

#### A log file name shorter than four characters stops the function

- **Severity**: error
- **Trigger**: MatricesSUX.MatrixPart = [1 2 2], MatricesSUX.rxns = {'r1'; 'r2'; 'r3'}, solution.cont = [1; 0; 2.5], solution.obj = 3; printSolutionGEM(MatricesSUX, solution, 'abc', 1) in an empty folder
- **Observed**: "Array indices must be positive integers or logical values." at line 27 (logFile(end-3:end) of a 3-character name), after abc_solution_1.mat was saved and before anything was printed (R2025a, 2026-11-15); 'GEMLog' and 'GEMLog.txt' work
- **Expected**: the log written to abc.txt, as for any other name without '.txt'
- **Source lines**: 27
- **Documented in**: `test/verifiedTests/reconstruction/testGrowthExpMatch/testPrintSolutionGEM.m`

### `src/reconstruction/metaboRePort/generateMetaboReport.m`

#### Every template line is printed twice to the console

- **Severity**: cosmetic
- **Trigger**: the call above
- **Observed**: about 4,700 lines of HTML, and -1, printed for one model by the debugging disp calls (R2025a, 2026-11-16)
- **Expected**: no console output, or output gated by a verbose flag
- **Source lines**: 33, 35
- **Documented in**: `test/verifiedTests/reconstruction/testMetaboRePort/testGenerateMetaboReport.m`

#### Template lines are written as fprintf formats, so a percent sign cuts the line

- **Severity**: wrong-result
- **Trigger**: generateMetaboReport(mp, tempname folder) with mp.My_model.modelProp2 holding every field the function reads (numbers 1.234, Details lists {'r1'}, Scores 0.5) and the distributed reportTemplate.html, whose line 2315 ends in 'max-height:10%">'
- **Observed**: modelreport_My_model.html holds '... background-color:#3c85c9;max-height:10' followed directly by the next template line '<div class="row align-items-end ">': line 454 passes strcat(html{j}, '\n') to fprintf as the format, so '%"' ends the output of that line, its closing '">' and its line break (R2025a, 2026-11-16)
- **Expected**: every template line written verbatim apart from the replaced placeholders (for example fprintf(fid, '%s\n', html{j}))
- **Source lines**: 454
- **Documented in**: `test/verifiedTests/reconstruction/testMetaboRePort/testGenerateMetaboReport.m`

#### The first template line is not written

- **Severity**: wrong-result
- **Trigger**: the call above
- **Observed**: the report starts with '<html lang="en">'; the template's first line '<!DOCTYPE html>' read at line 30 is replaced at line 34 before it is stored, so the page renders in quirks mode (R2025a, 2026-11-16)
- **Expected**: the report starts with '<!DOCTYPE html>'
- **Source lines**: 30, 34
- **Documented in**: `test/verifiedTests/reconstruction/testMetaboRePort/testGenerateMetaboReport.m`

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

### `src/reconstruction/modelGeneration/massBalance/elementalMatrixToFormulae.m`

#### A count equal to 10^-dMax or smaller is dropped, so dMax = 0 drops every count of 1

- **Severity**: wrong-result
- **Trigger**: elementalMatrixToFormulae([1 4], {'C', 'H'}, 0) (methane, no decimal places); elementalMatrixToFormulae([0.1 2], {'C', 'H'}, 1)
- **Observed**: {'H4'} and {'H2'}: line 52 keeps a count only when abs(count) > 10^(-dMax), which is 1 for dMax = 0 and 0.1 for dMax = 1 (R2025a, 2026-11-15); with the default dMax the same call gives {'CH4'}
- **Expected**: {'CH4'} and {'C0.1H2'} (dMax is documented as the maximum number of decimal places, so 0 and 1 are valid and 1 and 0.1 are written exactly at those precisions)
- **Source lines**: 52
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testElementalMatrixToFormulae.m`

### `src/reconstruction/modelGeneration/massBalance/getElementalComposition.m`

#### Formula numbers in error messages lose their zero padding inside parentheses

- **Severity**: cosmetic
- **Trigger**: getElementalComposition({'H2O'; 'h2o'; 'H2O'; 'H2O'; 'H2O'; 'H2O'; '(cD)'; 'H2O'; 'H2O'; 'H2O'}) (ten or more formulae, one failing inside or next to a parenthesis)
- **Observed**: "#02:  h2o" but "#7:  (cD)" in the same message; the nested function uses the digit count of the recursive call that found the error (line 80 of that call: one formula, one digit)
- **Expected**: the same width for every formula number ("#07:  (cD)")
- **Source lines**: 252
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testGetElementalComposition.m`

### `src/reconstruction/modelGeneration/massBalance/ispolymer.m`

#### Every formula stops with an error because the group name FULLR2 contains a digit

- **Severity**: error
- **Trigger**: ispolymer('C6H12O6'), ispolymer('C6H10O5X') or ispolymer('CH2R')
- **Observed**: "Element must not contain numbers" from numAtomsOfElementInFormula (line 28), which rejects any element name with a digit before it translates FULLR2 and FULLR3; line 17 passes 'FULLR2' in the fourth turn of the loop for every formula (MATLAB prints 'FULLR2' before the error, R2025a, 2026-11-15)
- **Expected**: false for 'C6H12O6' and true for 'C6H10O5X' and 'CH2R'
- **Source lines**: 14, 17
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testIspolymer.m`

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

### `src/reconstruction/modelGeneration/massBalance/pHbalanceProtons.m`

#### A proton-driven reaction uses an undefined or stale proton index

- **Severity**: wrong-result
- **Trigger**: an internal reaction whose protons are in more compartments than its other metabolites, e.g. ATPS4r (adp[c] + 4 h[e] + pi[c] <=> atp[c] + h2o[c] + 3 h[c])
- **Observed**: line 248 reads indexHRxn, which is only set at line 270 for an earlier reaction, so it is undefined (error) or points to the proton of the previous reaction (read from the code)
- **Expected**: the proton of the compartment of the other metabolites is adjusted, as the comment above line 248 says
- **Source lines**: 248
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testPHbalanceProtons.m`

#### The default of massImbalance uses nRxn before it is defined

- **Severity**: error
- **Trigger**: model = createModel({'r1'}, {'r1'}, {'a[c] -> b[c]'}) with compartments {'c'}, metCompartments {'c'; 'c'}, SIntRxnBool true, aveHbound [1; 1], metFormulas {'CH'; 'CH'}, metCharges [0; 0]; pHbalanceProtons(model)
- **Observed**: 'Unrecognized function or variable 'nRxn'.' at line 57 (MATLAB R2025a); nRxn is set at line 72
- **Expected**: massImbalance is optional; every reaction is treated as mass balanced
- **Source lines**: 57
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testPHbalanceProtons.m`

#### The missing-formula warning tests the whole formula list

- **Severity**: error
- **Trigger**: a model in which some, but not all, metFormulas are empty
- **Observed**: line 108 strcmp(model.metFormulas, '') returns a vector, so the branch runs only when every formula is empty; otherwise line 115 calls numAtomsOfElementInFormula('', 'H') for an empty formula, which errors indexing formula(1) at its line 38 (read from the code)
- **Expected**: the formula of metabolite m is tested (model.metFormulas{m}) and the metabolite gets NaN with the warning (lines 109-113)
- **Source lines**: 108-115
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testPHbalanceProtons.m`

#### The report file is never closed

- **Severity**: cosmetic
- **Trigger**: printLevel < 0
- **Observed**: line 124 opens the file and no fclose follows (read from the code)
- **Expected**: the file is closed before returning
- **Source lines**: 124
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testPHbalanceProtons.m`

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

### `src/reconstruction/modelGeneration/modelProperties/makeModelPropertiesTable.m`

#### A results directory given without a trailing separator cannot be loaded

- **Severity**: error
- **Trigger**: modelResults saved as FRresults.mat in a folder d; makeModelPropertiesTable([], [], d, 'FRresults') with d not ending in a file separator (for example d = tempname)
- **Observed**: (R2025a, 2026-11-17) error "Unable to find file or directory '<d>FRresults'." at line 37: the directory and the file name are joined without a separator ([resultsDirectory resultsFileName])
- **Expected**: the results in d/FRresults.mat are loaded ("resultsDirectory: directory where output of checkModelProperties has been saved"; a directory name without a trailing separator is a valid reading), for example with fullfile
- **Source lines**: 37
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testMakeModelPropertiesTable.m`

#### A results model without balancedRxnBool stops with an error

- **Severity**: limitation
- **Trigger**: modelResults(k).model without the field balancedRxnBool, which is not an output of checkModelProperties (for example a structure built by hand); makeModelPropertiesTable(modelResults)
- **Observed**: (R2025a, 2026-11-17) error "Unrecognized field name "balancedRxnBool"." at line 194, after lines 184-188 found the field absent and wrote NaN. The documented input, the output of checkModelProperties, always has the field: checkModelProperties (lines 202-205) calls findStoichConsistentSubset with massBalanceCheck = 1, and every path of findStoichConsistentSubset lines 181-224 either sets model.balancedRxnBool or stops with "No model.metFormulas"
- **Expected**: the row of line 194 is NaN (or skipped) when balancedRxnBool is absent, as lines 184-188 do for the row before it
- **Source lines**: 187, 194
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testMakeModelPropertiesTable.m`

#### The progress message of each model column prints nothing

- **Severity**: cosmetic
- **Trigger**: any call with at least one model, makeModelPropertiesTable(modelResults)
- **Observed**: (R2025a, 2026-11-17) line 62 calls fprintf('%\n', modelID); the format "%\n" is not a valid conversion, so nothing is printed (no modelID, no newline)
- **Expected**: the modelID of each model column, one per line ('%s\n')
- **Source lines**: 62
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testMakeModelPropertiesTable.m`

### `src/reconstruction/modelGeneration/modelProperties/plotModelConsistency.m`

#### The fraction of stoichiometrically consistent rows is inverted

- **Severity**: wrong-result
- **Trigger**: one model result with S of 10 rows and SConsistentMetBool true for 1 row (10% consistent), the other Boolean vectors true, modelID 'toy'; plotModelConsistency(modelResults, {'sp', 'toy', 'f', 1, ''}, 1, 1, 2)
- **Observed**: (R2025a, 2026-11-16) the function prints "1 models that are sufficiently stochiometrically consistent for plotting." and plots the model: line 75 computes size(S, 1) / nnz(SConsistentMetBool) = 10, which is never below the tolerance 0.60, so lines 77-78 are unreachable and no model is flagged or skipped (line 78 would also read modelResults(j).modelID, a field the results do not have)
- **Expected**: the fraction nnz(SConsistentMetBool) / size(S, 1) = 0.1 < 0.60 flags the model as not sufficiently consistent (comment at line 67 and the printed heading)
- **Source lines**: 75-78
- **Documented in**: `test/verifiedTests/reconstruction/testModelGeneration/testPlotModelConsistency.m`

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

### `src/reconstruction/modelGeneration/stoichConsistency/maxEntConsVector.m`

#### The entropy maximiser is resolved only to the pdco optimality tolerance

- **Severity**: wrong-result
- **Trigger**: [m, bool] = maxEntConsVector(sparse([-1; 1]), 0)
- **Observed**: (R2025a, pdco5, 2026-11-17) m = [1.2284; 1.2284]; pdco reports Converged: the entropy term is weighted by alpha = 1e-6, the size of pdco's default OptTol (1e-6), so alpha*log(m) = 2e-7 is accepted as zero. For sparse([1; 1]) m = 4.0e-4 per entry where the minimiser is about 6e-6
- **Expected**: m = [0.9901; 0.9901], the root of 1e-6*log(x) + 1e-8*x = 0 (stationarity of the objective along the conservation law m(1) = m(2))
- **Source lines**: 34, 51
- **Documented in**: `test/verifiedTests/reconstruction/testStoichiometricConsistency/testMaxEntConsVector.m`

#### The objective passed to pdco does not match its gradient and Hessian

- **Severity**: wrong-result
- **Trigger**: any call, e.g. maxEntConsVector(sparse([-1; 1]), 0)
- **Observed**: by reading (independent review T021, 2026-11-17): pdcoObj returns obj = alpha*x'*(log(x) - x) = alpha*sum(x.*log(x) - x.^2) (line 74), while the gradient alpha*log(x) (line 75) and Hessian alpha./x (line 76) are those of alpha*sum(x.*log(x) - x)
- **Expected**: objective, gradient and Hessian of one function, e.g. obj = alpha*sum(x.*log(x) - x)
- **Source lines**: 74-76
- **Documented in**: `test/verifiedTests/reconstruction/testStoichiometricConsistency/testMaxEntConsVector.m`

#### printLevel is ignored and pdco always prints its iteration log

- **Severity**: cosmetic
- **Trigger**: maxEntConsVector(sparse([-1; 1]), 0)
- **Observed**: (R2025a, pdco5, 2026-11-17) the pdco banner, iteration table and distribution of x are printed although printLevel = 0
- **Expected**: no output for printLevel = 0 (options.Print = printLevel - 1 is commented out)
- **Source lines**: 34
- **Documented in**: `test/verifiedTests/reconstruction/testStoichiometricConsistency/testMaxEntConsVector.m`

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

### `src/reconstruction/rBioNet/ReactionChecks.m`

#### A metabolite without charged formula raises an error after BalancePrep's message

- **Severity**: error
- **Trigger**: a metab row {'nochg', 'no charged formula', 'H', '', '0'} (metab also holding {'h', 'Proton', 'H', 'H', '1'}) and ReactionChecks(rxn, metab, compartments, {'NOC', 'x', 'nochg[c] -> h[c]', 1, 0}, [])
- **Observed**: (R2025a, 2026-11-15) BalancePrep opens the box 'Reaction cannot be created with metabolites that are missing the charged formula.' and returns [], then ReactionChecks fails with 'Brace indexing is not supported for variables of this type.' at line 150
- **Expected**: the output [] after the box; BalancePrep returns [] after its message box by design (header of ReactionChecks, line 22: "If we return, empty is a good choice"), so a metabolite without charged formula is an intended input, which fails when used (severity audit T009a, borderline)
- **Source lines**: 149-150
- **Documented in**: `test/verifiedTests/reconstruction/testRBioNet/testReactionChecks.m`

#### A new reaction identical to a database reaction leaves an empty row in data

- **Severity**: cosmetic
- **Trigger**: newrxns {'ENO2', 'x', '2pg[c] -> h2o[c] + pep[c]', 0, 0; 'ENO_DUP', 'x', '2pg[c] <=> h2o[c] + pep[c]', 1, 0; 'GLCt', 'x', 'glc-D[e] <=> glc-D[c]', 1, 0; 'PGIe', 'x', 'g6p[c] <=> f6p[e]', 1, 0} with the database rows {'ENO', 'enolase', '2pg[c] <=> h2o[c] + pep[c]', 1, 0} and {'PGI', 'glucose-6-phosphate isomerase', 'g6p[c] <=> f6p[c]', 1, 0}
- **Observed**: (R2025a, 2026-11-15) data = {'ENO2', ENO row; [], []; 'PGIe', PGI row}: the rows of data follow the rows of the similarity list, and the row of the removed reaction ENO_DUP stays empty when a later new reaction has similar reactions
- **Expected**: one row of data per remaining new reaction with similar reactions
- **Source lines**: 318-319
- **Documented in**: `test/verifiedTests/reconstruction/testRBioNet/testReactionChecks.m`

#### The balance check prints ans = [] for every new reaction

- **Severity**: cosmetic
- **Trigger**: any call that reaches the balance check, for example a balanced new reaction {'GLCt', 'glucose transport', 'glc-D[e] <=> glc-D[c]', 1, 0} with glc-D in metab
- **Observed**: (R2025a, 2026-11-15) "ans =" and "[]" printed once per new reaction, because the call showprogress(i/S_nrxns(1)) has no semicolon and showprogress returns []
- **Expected**: only the progress bar printed
- **Source lines**: 142
- **Documented in**: `test/verifiedTests/reconstruction/testRBioNet/testReactionChecks.m`

#### The missing-formula message is never shown; an empty formula raises an index error

- **Severity**: error
- **Trigger**: ReactionChecks(rxn, metab, compartments, {'NOF', 'no formula', '', 1, 0}, []) with any reaction database rxn, metabolite table metab and compartment list, for example those of the wave 12 version of this test
- **Observed**: (R2025a, 2026-11-15) error 'Index exceeds array bounds.' at line 144: isempty(newrxns(i,3)) on line 117 tests a 1 x 1 cell, which is never empty, so the box 'is missing the formula' is never opened and LoadReaction returns an empty 0 x 6 cell for the empty formula
- **Expected**: the box of line 118 and the output []; the branch of lines 117-122 (message box "is missing the formula" and return) shows that an empty formula is an intended input, which fails when used (severity audit T009a, borderline)
- **Source lines**: 117-122
- **Documented in**: `test/verifiedTests/reconstruction/testRBioNet/testReactionChecks.m`

### `src/reconstruction/rBioNet/balancecheck.m`

#### Elements outside the fixed list of twelve are not checked

- **Severity**: wrong-result
- **Trigger**: a reaction unbalanced only in an element that is not in the list C, H, O, P, S, N, Mg, X, Fe, Zn, Co, R, for example balancecheck({'na1', 'Sodium', 1, 'c', 'Substrate', 'Na'; 'h2o', 'Water', 1, 'c', 'Substrate', 'H2O'; 'h2o', 'Water', 1, 'c', 'Product', 'H2O'}) (sodium consumed, nothing produced from it)
- **Observed**: [] (balanced), since Na, K, Cl, Ca, Cu, Mn, Se, I and every other element is never counted (R2025a, 2026-11-15)
- **Expected**: the reaction reported as unbalanced, or the documentation naming the elements that are checked. Severity audit 2026-11-15: OUTPUT documents "balance: is empty if balance checks out, if unbalanced it returns cell matrix"; a reaction unbalanced in Na, K, Cl or Ca (outside the hard-coded list at line 26, which the header does not mention) returns [] - reported balanced although unbalanced
- **Source lines**: 26
- **Documented in**: `test/verifiedTests/reconstruction/testRBioNet/testBalancecheck.m`

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

### `src/reconstruction/rBioNet/rBioNet_search.m`

#### The default of exact is applied only when str is also missing

- **Severity**: limitation
- **Trigger**: rBioNet_search(table, column, str) with three inputs
- **Observed**: (R2025a, 2026-11-15) the test is nargin < 3, so exact stays undefined and rBioNet_search({'a', 'Urea'}, 2, 'Urea') stops at line 45 with 'Not enough input arguments.' (all callers in the toolbox pass four inputs, as the USAGE line documents)
- **Expected**: exact = 0 (partial match) when only exact is omitted
- **Source lines**: 24-26
- **Documented in**: `test/verifiedTests/reconstruction/testRBioNet/testRBioNet_search.m`

### `src/reconstruction/refinement/GPRLogic/AndNode.m`

#### A numeric literal ID is not deleted

- **Severity**: wrong-result
- **Trigger**: n = AndNode(); n.addChild(LiteralNode('1')); n.addChild(LiteralNode('2')); n.deleteLiteral(1)
- **Observed**: n.toString() is still 'x(1) and x(2)' (no error); LiteralNode.contains compares the number with the text ID with strcmp
- **Expected**: 'x(2)', as for n.deleteLiteral('1'); the Node interface documents "literalID: The LiteralID (As string or number)". Severity audit 2026-11-15: Node.m line 78 documents that input, and deleteLiteral(1) leaves the literal in place because LiteralNode.contains uses strcmp - a documented input silently has no effect
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

### `src/reconstruction/refinement/GPRLogic/NormaliseGPRs.m`

#### The rules are not reduced to the minimal DNF form: absorbed clauses are kept

- **Severity**: wrong-result
- **Trigger**: model = createModel({'R1','R2','EX_A','EX_C'}, {'R1','R2','EX_A','EX_C'}, {'A -> B','B <=> C','A <=> ','C -> '}); model.genes = {'g1';'g2'}; model.rules = {'x(1) | (x(1) & x(2))'; ''; ''; ''}; out = NormaliseGPRs(model)
- **Observed**: out.rules{1} = '(x(1) | x(1) & x(2))' and out.grRules{1} = '(g1 or g1 and g2)' (only identical clauses are removed by removeDNFduplicates)
- **Expected**: x(1) (g1): x1 or (x1 and x2) = x1 by absorption (header: "reduce them to the minimal DNF Form"; OUTPUTS: "all GPRS in minimal DNF form")
- **Source lines**: 31-38
- **Documented in**: `test/verifiedTests/reconstruction/testGPRLogic/testNormaliseGPRs.m`

### `src/reconstruction/refinement/GPRLogic/OrNode.m`

#### A numeric literal ID is not deleted

- **Severity**: wrong-result
- **Trigger**: n = OrNode(); n.addChild(LiteralNode('1')); n.addChild(LiteralNode('2')); n.deleteLiteral(1)
- **Observed**: n.toString() is still '(x(1) or x(2))' (no error); LiteralNode.contains compares the number with the text ID with strcmp
- **Expected**: '(x(2))', as for n.deleteLiteral('1'); the Node interface documents "literalID: The LiteralID (As string or number)". Severity audit 2026-11-15: Node.m line 78 documents that input, and deleteLiteral(1) silently has no effect - a documented input silently has no effect, as for AndNode
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

### `src/reconstruction/refinement/annotateSBOTerms.m`

#### metSBOTerms and geneSBOTerms are created as rows, not m x 1 and g x 1

- **Severity**: wrong-result
- **Trigger**: model = getDistributedModel('ecoli_core_model.mat') (no metSBOTerms or geneSBOTerms field); model = annotateSBOTerms(model)
- **Observed**: (R2025a, 2026-11-16) size(model.metSBOTerms) = [1 72] and size(model.geneSBOTerms) = [1 137] while mets is 72 x 1 and genes 137 x 1; verifyModel reports "inconsistentFields: metSBOTerms: Size of metSBOTerms was 72. Expected 1". Lines 33 and 38 grow a new field along the second dimension; only rxnSBOTerms is turned into a column (line 84)
- **Expected**: m x 1 and g x 1 cell arrays, as the OUTPUT documentation says
- **Source lines**: 32-39
- **Documented in**: `test/verifiedTests/reconstruction/testRefinement/testAnnotateSBOTerms.m`

### `src/reconstruction/refinement/assignGPRA.m`

#### Every call stops because parseSimPhenyGPRA does not exist

- **Severity**: error
- **Trigger**: model = createModel({'r1', 'EX_a'}, {'r1', 'EX_a'}, {'A[c] -> B[c]', 'A[c] <=> '}); assignGPRA(model, 'gpra.txt') (any model and any file name)
- **Observed**: (R2025a, 2026-11-16) error "Undefined function 'parseSimPhenyGPRA' for input arguments of type 'char'." at line 24: parseSimPhenyGPRA is not part of the toolbox (no file of that name in the repository)
- **Expected**: the SimPheny GPRA file is parsed and the genes and rxnGeneMat of the model are set from it
- **Source lines**: 24-31
- **Documented in**: `test/verifiedTests/reconstruction/testRefinement/testAssignGPRA.m`

### `src/reconstruction/refinement/assignSubSystems.m`

#### Every call stops because parseSimPhenyGPRA does not exist

- **Severity**: error
- **Trigger**: model = createModel({'r1', 'EX_a'}, {'r1', 'EX_a'}, {'A[c] -> B[c]', 'A[c] <=> '}); assignSubSystems(model, 'gpra.txt') (any model and any file name)
- **Observed**: (R2025a, 2026-11-16) error "Undefined function 'parseSimPhenyGPRA' for input arguments of type 'char'." at line 23: parseSimPhenyGPRA is not part of the toolbox (no file of that name in the repository)
- **Expected**: the SimPheny GPRA file is parsed and the subSystems of the model are set from it
- **Source lines**: 23-35
- **Documented in**: `test/verifiedTests/reconstruction/testRefinement/testAssignSubSystems.m`

### `src/reconstruction/refinement/changeCOBRAConstraints.m`

#### The documented constraint index cannot be used as constraintID

- **Severity**: error
- **Trigger**: model = createModel({'R1','R2','EX_A','EX_C'}, {'R1','R2','EX_A','EX_C'}, {'A -> B','B <=> C','A <=> ','C -> '}); model = addCOBRAConstraints(model, {'R1','R2'}, 5, 'c', [1 1], 'dsense', 'L'); changeCOBRAConstraints(model, 1, 'd', 7)
- **Observed**: error "The value of 'constraintID' is invalid. It must satisfy the function: @(x)ischar(x)&&any(ismember(model.ctrs,x))." (the validator accepts only a char ID, so the numeric path after line 75 is never used)
- **Expected**: model.d(1) = 7 (INPUTS: "constraintID: The ID of the constraint (or the index in the ctrs field)")
- **Source lines**: 52
- **Documented in**: `test/verifiedTests/reconstruction/testRefinement/testChangeCOBRAConstraints.m`

### `src/reconstruction/refinement/changeCOBRAVariable.m`

#### The documented option Name stops with an error

- **Severity**: unusable-option
- **Trigger**: same model as above; changeCOBRAVariable(model, 'v1', 'Name', 'newName')
- **Observed**: error "Unrecognized field name "evarName"." (the option name is appended to 'evar', but addCOBRAVariables stores the names in evarNames)
- **Expected**: model.evarNames{1} = 'newName' (OPTIONAL INPUTS: "Name: The new, descriptive name of the variable.")
- **Source lines**: 51-54
- **Documented in**: `test/verifiedTests/reconstruction/testRefinement/testChangeCOBRAVariable.m`

#### The documented variable index cannot be used as variableID

- **Severity**: error
- **Trigger**: model = createModel({'R1','R2','EX_A','EX_C'}, {'R1','R2','EX_A','EX_C'}, {'A -> B','B <=> C','A <=> ','C -> '}); model = addCOBRAVariables(model, {'v1'}, 'lb', 0, 'ub', 3); changeCOBRAVariable(model, 1, 'lb', 1)
- **Observed**: error "The value of 'variableID' is invalid. It must satisfy the function: @(x)ischar(x)&&any(ismember(model.evars,x))."
- **Expected**: model.evarlb(1) = 1 (INPUTS: "variableID: The ID of the variable (or the index in the evars field)")
- **Source lines**: 32
- **Documented in**: `test/verifiedTests/reconstruction/testRefinement/testChangeCOBRAVariable.m`

### `src/reconstruction/refinement/changeRxnMets.m`

#### A partly unknown reaction list is not reported

- **Severity**: cosmetic
- **Trigger**: Rxn = {'r1', 'missing'}
- **Observed**: line 54 min(RxnsInd == 0) is true only when every reaction is missing, so the documented error is skipped and an indexing error follows (read from the code)
- **Expected**: the error 'A reaction wasn't found in your model!'
- **Source lines**: 54
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testChangeRxnMets.m`

#### The extra reactions are drawn from a set that already contains the selected ones

- **Severity**: wrong-result
- **Trigger**: the model above; rng(3); changeRxnMets(model, {'A[c]', 'C[c]'}, {'Z[c]', 'E[c]'}, 2)
- **Observed**: ModifiedRxns = {'r2'} only (MATLAB R2025a, seeds 3 and 4; seeds 1, 2 and 5 give r1 and r2): line 72 draws Rxn - numel(RxnsIndAll) reactions from RxnsIndAny, which includes RxnsIndAll, and the union drops repeats; line 67 adds the two counts, which double counts the same reactions
- **Expected**: 2 reactions modified (r1 and r2, the only reactions containing A[c] or C[c])
- **Source lines**: 67-72
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testChangeRxnMets.m`

#### With one metabolite to change, the random selection reduces the S row to a scalar

- **Severity**: wrong-result
- **Trigger**: model = createModel({'r1','r2','r3'}, {'r1','r2','r3'}, {'A -> B','A + C -> D','E -> F'}) plus metabolite Z[c]; changeRxnMets(model, {'A[c]'}, {'Z[c]'}, 2)
- **Observed**: ModifiedRxns = {'r1'} and two warnings that fewer reactions contain the metabolite (MATLAB R2025a): all() and any() of the 1 x n row at lines 63-64 return a scalar, so the indices found are 1 or empty instead of the reactions r1 and r2 that contain A[c]
- **Expected**: ModifiedRxns = {'r1'; 'r2'} (both reactions containing A[c]), no warning
- **Source lines**: 63-64
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testChangeRxnMets.m`

### `src/reconstruction/refinement/extractSubSysModel.m`

#### A single subsystem name given as text selects almost every reaction

- **Severity**: wrong-result
- **Trigger**: subSysNames given as a character vector, for example extractSubSysModel(model, 'Exchange')
- **Observed**: ismember compares the characters of the name with the characters of each subsystem, so every reaction whose subsystem shares one letter with the name is kept (94 of the 95 reactions of ecoli_core_model instead of the 20 exchange reactions)
- **Expected**: the reactions annotated with that subsystem only, as for {'Exchange'}
- **Source lines**: 20
- **Documented in**: `test/verifiedTests/reconstruction/testModelManipulation/testExtractSubSysModel.m`

### `src/reconstruction/refinement/isSameCobraModel.m`

#### Logical fields are never compared

- **Severity**: wrong-result
- **Trigger**: m1 as above; a = m1; a.myFlag = true(4,1); b = m1; b.myFlag = false(4,1); isSameCobraModel(a, b)
- **Observed**: isSame = true (a logical value is neither numeric, cellstr nor char, so nDiff stays 0)
- **Expected**: false: the common field myFlag differs in 4 positions (OUTPUTS: "True if all common fields are identical")
- **Source lines**: 108-124
- **Documented in**: `test/verifiedTests/reconstruction/testRefinement/testIsSameCobraModel.m`

#### Text fields are compared with every non-word character removed, not only white space

- **Severity**: wrong-result
- **Trigger**: a = m1; a.rxnNames{1} = 'R-1'; isSameCobraModel(m1, a)
- **Observed**: isSame = true ('R-1' and 'R1' are equal after regexprep(value, '[^\w'']', ''))
- **Expected**: false: rxnNames{1} differs (code comment: "replace all whitespaces")
- **Source lines**: 103-106
- **Documented in**: `test/verifiedTests/reconstruction/testRefinement/testIsSameCobraModel.m`

#### The message for differing nested subSystems names prints 0 positions

- **Severity**: cosmetic
- **Trigger**: a = m1; a.subSystems = {{'A'};{'B'};{'A'};{'A'}}; b = m1; b.subSystems = {{'A'};{'A'};{'A'};{'A'}}; isSameCobraModel(a, b, 1)
- **Observed**: prints "Field subSystems differs in 0 positions between the models" (nDiff(i) is printed before it is assigned)
- **Expected**: the number of differing subSystem names
- **Source lines**: 86
- **Documented in**: `test/verifiedTests/reconstruction/testRefinement/testIsSameCobraModel.m`

#### Two models with different numbers of reactions stop with an error

- **Severity**: error
- **Trigger**: m1 = createModel({'R1','R2','EX_A','EX_C'}, {'R1','R2','EX_A','EX_C'}, {'A -> B','B <=> C','A <=> ','C -> '}); m2 = createModel({'R1','R2','EX_A'}, {'R1','R2','EX_A'}, {'A -> B','B <=> C','A <=> '}); [isSame, nDiff] = isSameCobraModel(m1, m2)
- **Observed**: error "Arrays have incompatible sizes for this operation." (value1 == value2 on numeric fields of different sizes; strcmp on cell fields of different sizes fails in the same way)
- **Expected**: isSame = false with the differing fields counted ("Checks if two COBRA models are the same")
- **Source lines**: 109, 121
- **Documented in**: `test/verifiedTests/reconstruction/testRefinement/testIsSameCobraModel.m`

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

### `src/visualization/SAMMIM/expa.m`

#### The collapsed model does not match the input model: its objective is zero and its reactions are reordered

- **Severity**: wrong-result
- **Trigger**: [model, fullmodel] = expa(m) with m.c nonzero, or with reactions not already internal-first in name order; for example m.S = sparse([-1 0 -1 0 0; 1 -1 0 0 -1; 0 1 0 -1 0]), m.rxns = {'R1'; 'R2'; 'EX_A'; 'EX_C'; 'EX_B'}, m.mets = {'A'; 'B'; 'C'}, m.lb = [-10; 0; -10; 0; -10], m.ub = [10; 10; 0; 10; 10], m.rev = [1; 0; 0; 0; 1], m.c = [0; 1; 0; 0; 0]
- **Observed**: (R2025a, 2026-11-17) model.c is [0 0 0 0 0]' for the input c [0 1 0 0 0]', and model.rxns is {'R1'; 'R2'; 'EX_A'; 'EX_B'; 'EX_C'} for the input order {'R1'; 'R2'; 'EX_A'; 'EX_C'; 'EX_B'} (S, bounds, P and the optional reaction fields follow the new order); fullmodel.c is also all zero. A caller that indexes the output by the input's reaction order, or reads its objective, gets other values
- **Expected**: "The model output matches the original model input" (OUTPUTS): the input's reaction order and objective, with only P added
- **Source lines**: 184-198, 207
- **Documented in**: `test/verifiedTests/visualization/testSAMMIM/testExpa.m`

### `src/visualization/cellDesigner/addAnnotation.m`

#### Annotating a reaction of a standard COBRA model stops with an error

- **Severity**: error
- **Trigger**: fin: an XML file with the lines <sbml>, <listOfReactions>, <reaction metaid="re1" id="re1" name="R1">, </reaction>, </listOfReactions>, </sbml>; model = createModel({'R1','R2'}, {'R1','R2'}, {'A -> B','B -> '}); addAnnotation(fin, fullfile(tempname, 'o.xml'), {'R1'}, model)
- **Observed**: error "Index exceeds array bounds." in contructItems line 463 (model.rxnGeneMat is 2 x 0); with rmfield(model, 'rxnGeneMat') the error is "Cell elements must be character vectors." at line 465 (strrep on the nested cell model.subSystems), after the warnings "Inputs must be character vectors, cell arrays of character vectors, or string arrays." from strrep on the numeric fields
- **Expected**: the output file with a notes block holding the fields of reaction R1 (header: "Retrieves omics data from a COBRA model structure and add them to a CellDesginer XML file")
- **Source lines**: 463-467
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testAddAnnotation.m`

### `src/visualization/cellDesigner/addColour.m`

#### A reaction listed by an ID in the last row of r_info.ID is not coloured

- **Severity**: wrong-result
- **Trigger**: parsed.r_info.ID = {'re1', 're1', 'HEX1'; 're2', 're2', 'PGI'}, fields re1 and re2 with width {'2.0'} and {5} and color cells, then [ref, list] = addColour(parsed, {'PGI'})
- **Observed**: (R2025a, 2026-11-15) prints 'PGI' and 'error ! the listRxn{1}', re2.color is unchanged, and the call fails with 'Output argument "listRxnColour" (and possibly others) not assigned a value in the execution with "addColour" function.' The same call with {'HEX1'} (first row) maps to re1 and colours it 'ffdef595'. The strict comparisons id < m, id > rr*m and id < (rr+1)*m skip the last row of every column (and every row when r_info.ID has one row)
- **Expected**: re2 coloured like any other row ('ff81c828' for width 5 in palette 2) and listed in the second output
- **Source lines**: 110-118
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testAddColour.m`

#### The html colours of the second column of listRxn_Color are ignored

- **Severity**: wrong-result
- **Trigger**: the structure above, then [ref, list] = addColour(parsed, {'re1', '#123456'})
- **Observed**: (R2025a, 2026-11-15) re1.color becomes {'ffdef595', 'ffdef595'} (the palette colour for width 2) and list = {'re1', '#ffdef595'}; length(size(listRxn_Color)) is never below 2, so p is always 0 and the given colour is never read
- **Expected**: re1 coloured '123456' as the help text documents for the second column
- **Source lines**: 38-45, 179-180
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testAddColour.m`

#### The second output is not assigned when no listed link has a non-zero width

- **Severity**: error
- **Trigger**: the structure above with re1.width = {'0'}, then [ref, list] = addColour(parsed, {'re1'})
- **Observed**: (R2025a, 2026-11-15) 'Output argument "listRxnColour" (and possibly others) not assigned a value in the execution with "addColour" function.'; with one output re1 is coloured 'ffaed5fc'
- **Expected**: an empty list of newly coloured reactions
- **Source lines**: 173-177
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testAddColour.m`

### `src/visualization/cellDesigner/addFlux.m`

#### A reaction whose structure field is named by the reaction ID itself is left unchanged

- **Severity**: wrong-result
- **Trigger**: same call as above
- **Observed**: r.R2.width = {1} (when isfield(ref, listRxn{r}) holds nothing is done)
- **Expected**: r.R2.width = {4}, the width computed for R2 (0.5 / 2 = 0.25, class 4)
- **Source lines**: 140
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testAddFlux.m`

#### Reaction IDs with (e) are not converted to the _e field name

- **Severity**: wrong-result
- **Trigger**: ref.r_info.ID = {'re1','x','R1'; 're2','y',[]}; ref.re1.width = {1}; ref.R_EX_glc_e.width = {1}; ref.R2.width = {1}; m = createModel({'R1','EX_glc(e)','R2'}, {'R1','EX_glc(e)','R2'}, {'A -> B','B -> ','A <=> '}); sol.x = [2; 1; 0.5]; [r, nf] = addFlux(m, sol, ref, {'R1','EX_glc(e)','R2'})
- **Observed**: nf = [2 8; 1 4; 0.5 4] but r.R_EX_glc_e.width = {1} and the message "error ! the listRxn{2}" is printed (the condition isempty(strfind(newRxnName,'(e)')) is inverted, so '(e)' is never replaced)
- **Expected**: r.R_EX_glc_e.width = {4} (code: strrep(newRxnName,'(e)','_e'))
- **Source lines**: 142-144
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testAddFlux.m`

### `src/visualization/cellDesigner/addMiriam.m`

#### Every matched species receives the MIRIAM entries of the last infix entry

- **Severity**: wrong-result
- **Trigger**: fin: an XML file with <sbml>, <listOfSpecies>, then for A and B: <species metaid="s1" id="s1" name="A">, <celldesigner:extension>, </celldesigner:extension>, </species> (s2, B likewise), </listOfSpecies>, </sbml>; model = struct('S', sparse([-1 0; 1 -1]), 'rxns', {{'R1';'R2'}}, 'mets', {{'A';'B'}}, 'metChEBIID', {{'15422';'16027'}}); [f, v] = addMiriam(fin, fullfile(tempname, 'm.xml'), {'A','B'}, model, 'name', {'metChEBIID','ChEBI','bqbiol:is'})
- **Observed**: the block after species A is <rdf:Description rdf:about="#A"> with <rdf:li rdf:resource="urn:miriam:chebi:16027"/>, the ChEBI ID of B (constructItems is called with infix(in), where in is the last value of the earlier loop, not the matched entry)
- **Expected**: urn:miriam:chebi:15422 for A and urn:miriam:chebi:16027 for B
- **Source lines**: 280-298, 327
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testAddMiriam.m`

#### The documented option miriam_path stops with an error

- **Severity**: unusable-option
- **Trigger**: same file and model; addMiriam(fin, fullfile(tempname, 'm.xml'), {'A'}, model, 'name', {'metChEBIID','ChEBI','bqbiol:is'}, which('MIRIAM.mat'))
- **Observed**: error "Unrecognized function or variable 'miriam'." at line 327 (miriam is loaded only when nargin < 7)
- **Expected**: the registry loaded from miriam_path (OPTIONAL INPUT: "miriam_path: the file path of the miriam registry's dataset")
- **Source lines**: 49-60
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testAddMiriam.m`

### `src/visualization/cellDesigner/cmpMet.m`

#### A parsed species is reported present when one of its entries is a substring of a model metabolite ID

- **Severity**: wrong-result
- **Trigger**: parsed.r_info.species = {'h'; 'atp'}; model.mets = {'h2o[c]'; 'datp[c]'}; model.metNames = {'Water'; 'dATP'}; results = cmpMet(parsed, model)
- **Observed**: (R2025a, 2026-11-17) results.listOfFound holds both rows ({'h', [], 'Present in the Reference mode'; 'atp', [], 'Present in the Reference mode'}) and results has no field listOfNotFound: line 63 tests strfind(model IDs, entry), so 'h' matches h2o[c] and 'atp' matches datp[c], although neither species is in the model
- **Expected**: both rows in listOfNotFound ("A list of metabolites in the test model that are NOT present in the reference COBRA model"); an exact, case-insensitive match as in the second pass of line 99
- **Source lines**: 63
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testCmpMet.m`

#### Every comparison prints the searched name

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: line 53 has no semicolon, so 'met = 1x1 cell array {...}' is printed for every parsed entry compared
- **Expected**: no output, or output gated by a print level
- **Source lines**: 53
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testCmpMet.m`

#### Model metabolites absent from the parsed model are returned in lower case

- **Severity**: wrong-result
- **Trigger**: parsed.r_info.species = {'x'}; model.mets = {'A[c]'}; model.metNames = {'A'}; results = cmpMet(parsed, model)
- **Observed**: (R2025a, 2026-11-17) results.list_of_mets_not_present_in_ReferenceModel is {'a[c]'}: the IDs are lowered at line 42 for the search and returned lowered at line 101, so they no longer equal (or ismember) the IDs of model.mets
- **Expected**: the model's own IDs ({'A[c]'})
- **Source lines**: 42, 101
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testCmpMet.m`

### `src/visualization/cellDesigner/cmpRxn.m`

#### A parsed model with no reaction found in the COBRA model raises an error

- **Severity**: error
- **Trigger**: parsed.r_info.ID = {'re1', 'nomatch'}; model.rxns = {'R1'; 'R2'}; model.mets = {'a'; 'b'; 'c'}; model.S = sparse([-1 0; 1 -1; 0 1]); cmpRxn(parsed, model)
- **Observed**: (R2025a, 2026-11-16) error MATLAB:UndefinedFunction "Unrecognized function or variable 'rea_M'." at line 217: rea_M is only created when a reaction is found
- **Expected**: results with listOfNotFound holding the parsed reaction and list_of_rxns_not_present_in_ReferenceModel holding r1 and r2, as documented
- **Source lines**: 217
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testCmpRxn.m`

### `src/visualization/cellDesigner/correctMetName.m`

#### Debug output of the species row numbers

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: line 41 lacks a terminating semicolon, so r_listN is printed on every call
- **Expected**: no output
- **Source lines**: 41
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testCorrectMetName.m`

### `src/visualization/cellDesigner/parseCD.m`

#### A reaction written on one line makes the function loop forever

- **Severity**: limitation
- **Trigger**: a file in which a reaction's '<reaction ' and '</reaction>' are on the same line, e.g. '<reaction metaid="re1" id="re1" name="R1"></reaction>' (CellDesigner itself writes one element per line, so its files do not have this form)
- **Observed**: (by reading, 2026-11-17; not run, as the call would not return) line 245 finds '</reaction>' on the line just read, so the loop of lines 255-482, the only place in the reaction branch (lines 202-492) that reads a new line (line 260), is skipped; the outer loop of line 149 then handles the same line again, adding a reaction each time, without end
- **Expected**: the reaction parsed once and the next line read
- **Source lines**: 149, 245, 255
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testParseCD.m`

#### Debug output of the keyword table, of every line read and of intermediate values

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: lines 74, 75, 140, 163 and 343 lack a terminating semicolon and line 173 calls disp, so toFD, the growing text structure (once per line of the file), ans, the keyword list of every line and ind_rem_color are printed
- **Expected**: no output
- **Source lines**: 74-75, 140, 163, 173, 343
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testParseCD.m`

#### The input file is left open

- **Severity**: limitation
- **Trigger**: any call, e.g. parseCD('<file>.xml')
- **Observed**: the identifier opened at line 32 (or 30) still appears in openedFiles() after the call; the function has no fclose
- **Expected**: the file closed before the function returns
- **Source lines**: 30, 32
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testParseCD.m`

### `src/visualization/cellDesigner/position.m`

#### An attribute name that occurs more than once in the line stops the function

- **Severity**: error
- **Trigger**: position({'<reaction metaid="re1" id="re2">'}, 'id') (id also occurs inside metaid)
- **Observed**: (R2025a, 2026-11-15) prints 'p_st = 19 28' and fails with 'Colon operands must be real scalars.' at line 25: every match of strfind is kept, so p_st is a vector (older MATLAB releases took the first element of a colon operand and would return the value of metaid, 're1')
- **Expected**: the value of the attribute id, 're2'
- **Source lines**: 21-25, 33, 37
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testPosition.m`

#### Debug output of the start index, the rest of the line and the end index

- **Severity**: cosmetic
- **Trigger**: any call, e.g. position({'<celldesigner:line width="1.0" color="ff000000"/>'}, 'color')
- **Observed**: (R2025a, 2026-11-15) 'p_st = 39', 'ff000000"/>' and '46' are printed before the value 'ff000000' is returned
- **Expected**: no output
- **Source lines**: 23, 27, 34
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testPosition.m`

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

### `src/visualization/cellDesigner/writeTXT.m`

#### A '#RRGGBB' colour containing 'FF' is truncated

- **Severity**: wrong-result
- **Trigger**: text = writeTXT({'R1', '#00FF00'}, '<folder>/b.txt')
- **Observed**: (R2025a, 2026-11-15) text = {'name color'; 'R1 #00'}: the 'FF' inside the colour is taken for the CellDesigner prefix and everything up to it is removed
- **Expected**: {'name color'; 'R1 #00FF00'}
- **Source lines**: 57-60
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testWriteTXT.m`

#### A colour code without '#' or 'FF' in the first row stops with an error

- **Severity**: error
- **Trigger**: writeTXT({'R1', '00AA00'}, '<folder>/a.txt')
- **Observed**: (R2025a, 2026-11-15) 'Index in position 1 is invalid. Array indices must be positive integers or logical values.' at line 52: the branch without header row sets s = 1, so the loop reads para{0, 1}
- **Expected**: one row per reaction ('R1 00AA00' or 'R1 #00AA00')
- **Source lines**: 43-52
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testWriteTXT.m`

#### A one-column para stops with an error at the default colour

- **Severity**: error
- **Trigger**: writeTXT({'R1'; 'R2'}, '<folder>/c.txt')
- **Observed**: (R2025a, 2026-11-15) prints r = 2 and c = 1, then 'Colon operands must be real scalars.' at line 60: the default '#FF0000FF' (line 39) contains 'FF' twice, so st is [2 8]; the output file is left open
- **Expected**: the header row and one row per reaction with the default colour (red, as the comment of line 39 says)
- **Source lines**: 39, 57-60
- **Documented in**: `test/verifiedTests/visualization/testCellDesigner/testWriteTXT.m`

### `src/visualization/createMetIntrcNetwork/hit_node.m`

#### The node-degree exclusion range excNodesWithDeg has no effect

- **Severity**: unusable-option
- **Trigger**: model.mets = {'A'; 'B'; 'C'; 'D'; 'E'}; model.rxns = {'R1'; 'R2'; 'R3'}; model.S = [-1 0 -1; 1 -1 0; 0 1 -1; 0 0 1; 0 -1 0]; src = struct('String', 'B', 'Parent', struct('Parent', struct('SelectionType', 'normal'))); hit_node(src, [], [0 2 0 1; 0 0 3 0; 0 0 0 4; 0 0 0 0], {'A'; 'B'; 'C'; 'D'}, model, ones(3, 1), {}, 'Toy', [0 0 1], [1 0 0], 1, 0, 1e-6, 4, 6, 4, 1e-7, [2 2]); the same with SelectionType 'alt' and fluxes [2; 3; 1]
- **Observed**: (R2025a, 2026-11-17) the new figure labels A, B and C in both cases, although A and C have degree 1 (edges A -> B, B -> C) and the range is [2 2]: varargin{18} is read at line 74 and only passed on to the next callback (line 151); the only degree filter is the fixed removal of isolated nodes (lines 134-137)
- **Expected**: nodes whose total degree lies outside [minimum maximum] are removed, as the help text documents ("node-degree exclusion range") and createMetIntrcNetwork does for the main figure (its lines 210-218); the help text says the produced figure "has same property with main figure"
- **Source lines**: 74, 134-137
- **Documented in**: `test/verifiedTests/visualization/testCreateMetIntrcNetwork/testHit_node.m`

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

### `src/visualization/entropicFBA/calculateGeneWeight.m`

#### A model without SConsistentRxnBool fails before the function's own check

- **Severity**: cosmetic
- **Trigger**: a model with grRules and no SConsistentRxnBool field
- **Observed**: MATLAB's error "Unrecognized field name" at line 35; the check of line 39 and its message (which names grRules) are never reached
- **Expected**: the error of line 40 naming the missing field
- **Source lines**: 35, 39-41
- **Documented in**: `test/verifiedTests/visualization/testEntropicFBA/testCalculateGeneWeight.m`

#### Reactions without expressed genes keep weight 0 when any reaction is inconsistent

- **Severity**: wrong-result
- **Trigger**: model.grRules = {'g1 and g2'; ''; 'g3 or g1'; 'g4'}; model.SConsistentRxnBool = [true; true; true; false]; T = table({'g1'; 'g2'; 'g3'; 'g4'}, [5; 2; 7; 1], 'VariableNames', {'entrezID', 'val'}); calculateGeneWeight(model, T, 0)
- **Observed**: (R2025a, 2026-11-16) [2; 0; 12]: the test isEmptyFirstColumn(i) & model.SConsistentRxnBool combines a scalar with the whole n x 1 vector, so the if is false as soon as one reaction is inconsistent; with SConsistentRxnBool = true(4, 1) the same call gives [2; 1.5; 12; 1] (median 1.5 assigned to the empty rule)
- **Expected**: [2; 2; 12], the empty rule replaced by the median of [2 0 12] as the comment of the function says
- **Source lines**: 104
- **Documented in**: `test/verifiedTests/visualization/testEntropicFBA/testCalculateGeneWeight.m`

### `src/visualization/maps/ReconMap/buildFluxDistLayout.m`

#### The largest flux gets line width 0 and the smallest the maximum width

- **Severity**: wrong-result
- **Trigger**: the call above without the last two inputs
- **Observed**: (R2025a, 2026-11-16) content 'name%09reactionIdentifier%09lineWidth%09color%0D%09R2%095%09#57c657%0D%09R3%090%09#57c657%0D': flux 10 gets width 0 and flux 5 width 5, because normalizeFluxes returns thickness * (1 - (f - min) / range)
- **Expected**: width growing with the absolute flux (flux 10 the widest line), as the use of the width as a flux thickness implies
- **Source lines**: 136-140
- **Documented in**: `test/verifiedTests/visualization/testReconMap/testBuildFluxDistLayout.m`

#### The maxThickness input is ignored

- **Severity**: unusable-option
- **Trigger**: minerva.map = 'ReconMap-2.01'; model.rxns = {'R1'; 'R2'; 'R3'}; solution.v = [0; 5; 10]; buildFluxDistLayout(minerva, model, solution, 'id', '#ff0000', 4)
- **Observed**: (R2025a, 2026-11-16, postMINERVArequest replaced by a recording stand-in) content '...%09R2%095%09#ff0000%0D%09R3%090%09#ff0000%0D', the same widths as without maxThickness: line 46 tests exist('thickness', 'var'), which is always false, so maxThickness is always reset to 10
- **Expected**: widths scaled to the given maximum thickness 4
- **Source lines**: 46-48
- **Documented in**: `test/verifiedTests/visualization/testReconMap/testBuildFluxDistLayout.m`

### `src/visualization/maps/ReconMap/generateSubsytemsLayout.m`

#### The overlay content is truncated to 'name' before it is sent

- **Severity**: wrong-result
- **Trigger**: any call, e.g. a model with rxns {'R1'; 'R2'} in subsystem 'S1' and generateSubsytemsLayout(minerva, model, 'S1') with minerva.map = 'ReconMap-2.01'
- **Observed**: MATLAB R2025a: content = sprintf(content) on 'name%09reactionIdentifier%09lineWidth%09color%0D%09R1%095%09#009933%0D' returns 'name' (4 characters): '%09r' is read as an incomplete format specifier and sprintf stops there, so postMINERVArequest receives content 'name' and no reaction; buildFluxDistLayout sends the URL-encoded text unchanged.
- **Expected**: content holding the header and one line per subsystem reaction
- **Source lines**: 54-55
- **Documented in**: `test/verifiedTests/visualization/testReconMap/testGenerateSubsytemsLayout.m`

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

### `src/visualization/metabolicCartography/addFluxFBA.m`

#### A flux of exactly 1e-3 of the largest flux keeps width 0.001

- **Severity**: wrong-result
- **Trigger**: the call above with solution.v = [1e-3; 1; 0]
- **Observed**: (R2025a, 2026-11-16) map2.rxnWidth = {1.0000e-03; 8; 1}: the bands of lines 69-70 are > 1e-3 and < 1e-3, so the ratio 1e-3 itself is in neither
- **Expected**: width 1 or 3
- **Source lines**: 69-70
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxFBA.m`

#### A flux vector of zeros gives NaN widths

- **Severity**: wrong-result
- **Trigger**: the call above with solution.v = [0; 0; 0]
- **Observed**: (R2025a, 2026-11-16) map2.rxnWidth = {NaN; NaN; NaN} (0 / 0 at line 62)
- **Expected**: width 1 for every reaction without flux
- **Source lines**: 62
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxFBA.m`

#### fluxMap holds the widths of the input map, not the flux widths

- **Severity**: wrong-result
- **Trigger**: map.rxnName = {'R1'; 'R2'; 'R3'}; map.rxnWidth = {1; 1; 1}; map.rxnColor = {'X'; 'X'; 'X'}; model.rxns = {'R1'; 'R2'; 'R3'}; solution.v = [0; 5; -10]; [map2, flux3, fluxMap] = addFluxFBA(map, model, solution)
- **Observed**: (R2025a, 2026-11-16) map2.rxnWidth = {1; 4; 8} but fluxMap = {'R1', 1; 'R2', 1; 'R3', 1}: line 88 reads map.rxnWidth (the input) instead of map2.rxnWidth; addFluxFBAdirectionAndColor returns the new widths
- **Expected**: fluxMap = {'R1', 1; 'R2', 4; 'R3', 8}, the reactions with their width value as the header says
- **Source lines**: 88
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxFBA.m`

### `src/visualization/metabolicCartography/addFluxFBAdirectionAndColor.m`

#### A flux of exactly 1e-3 of the largest flux keeps width 0.001

- **Severity**: wrong-result
- **Trigger**: the map and model above with fbaSolution.v = [1e-3; 1]
- **Observed**: (R2025a, 2026-11-17) map.rxnWidth is {0.0010; 8}: the bands of lines 60-61 are '> 1e-3' and '< 1e-3', so the ratio 1e-3 is in neither and keeps its raw value
- **Expected**: one of the band widths (1 or 3) for R1
- **Source lines**: 60-61
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxFBAdirectionAndColor.m`

#### A flux vector of zeros gives NaN widths

- **Severity**: wrong-result
- **Trigger**: map.rxnName = {'R1'; 'R2'} (with the other documented map fields), model.rxns = {'R1'; 'R2'}, fbaSolution.v = [0; 0]; map = addFluxFBAdirectionAndColor(map, model, fbaSolution)
- **Observed**: (R2025a, 2026-11-17) map.rxnWidth is {NaN; NaN}: line 53 divides 0 by max(abs(v)) = 0, no band of lines 56-61 matches NaN, and line 74 stores NaN as the width of every map reaction in the model
- **Expected**: width 1 for every reaction without flux, as lines 61 and 72 give for a ratio below 1e-3 and for a reaction not in the model (fbaSolution.v is documented as any n x 1 flux vector)
- **Source lines**: 53, 74
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxFBAdirectionAndColor.m`

### `src/visualization/metabolicCartography/addFluxFromFileWidthAndColor.m`

#### Numeric reaction IDs of different lengths do not match the map

- **Severity**: wrong-result
- **Trigger**: CSV file 'rxnID,flux' / '1,5' / '10,10'; map.rxnName = {'1'; '10'} (aliases a -> b, b -> c); [map2, flux2, fluxMap] = addFluxFromFileWidthAndColor(map, csvFile)
- **Observed**: MATLAB R2025a: flux2 = {' 1', 5, 5; '10', 10, 10} (cellstr(num2str([1; 10])) keeps the leading blank of ' 1'), so map reaction '1' is not matched: fluxMap = {'1', 1; '10', 10} and its colour is unchanged.
- **Expected**: reaction '1' gets width 5 and colour 'FFff8787', and flux2 lists it as '1'. Severity audit 2026-11-15: csvFilePath documents "reaction IDs in the first column" and lines 44-45 convert numeric IDs on purpose; num2str pads " 1" so reaction "1" is never matched and keeps its width and colour - the documented result ("Rxn line width is proportional to flux magnitude") is not produced for it
- **Source lines**: 45
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxFromFileWidthAndColor.m`

### `src/visualization/metabolicCartography/addFluxWidthAndColor.m`

#### Map reactions without flux data get no colour entry

- **Severity**: limitation
- **Trigger**: a map with reactions that are not in the list of reaction IDs given with the fluxes
- **Observed**: rxnColor is filled only for reactions with flux data (zero or non-zero), so it can be shorter than rxnName and the other map reactions have no colour entry
- **Expected**: a default colour for every map reaction
- **Source lines**: 102-105, 133
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testAddFluxWidthAndColor.m`

### `src/visualization/metabolicCartography/addNotes.m`

#### A metabolite shown twice in the map gets its note twice in each copy

- **Severity**: cosmetic
- **Trigger**: the call above with map.specName = {'a[c]'; 'b[c]'; 'b[c]'; 'Glycolysis'} and four specNotes
- **Observed**: (R2025a, 2026-11-16) both b[c] notes hold the summary of b[c] twice: the metabolite is listed once per copy and each pass writes into every copy
- **Expected**: one summary per copy
- **Source lines**: 67-76
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testAddNotes.m`

#### Numeric confidence scores are written as control characters

- **Severity**: wrong-result
- **Trigger**: the call above with model.subSystems = {'S1'; 'S2'}
- **Observed**: (R2025a, 2026-11-16) the note of R1 reads 'Mechanical Confidence Score: ' followed by char(3) (a control character) and that of R2 by char(0): line 102 applies char to the numeric score (the COBRA field definition makes rxnConfidenceScores numeric); with scores {'3'; '0'} the notes read 'Score: 3' and 'Score: 0'
- **Expected**: 'Mechanical Confidence Score: 3' and 'Mechanical Confidence Score: 0'
- **Source lines**: 102
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testAddNotes.m`

#### Subsystems stored as cells of cells raise an error

- **Severity**: error
- **Trigger**: model = createModel({'R1'; 'R2'}, {'R one'; 'R two'}, {'a[c] -> b[c]'; 'b[c] <=> c[c]'}); model.metNames = {'Alpha'; 'Beta'; 'Gamma'}; model.metFormulas = {'C'; 'H2'; 'O'}; model.metCharge = [0; -1; 2]; model.rxnConfidenceScores = [3; 0]; model.subSystems = {{'S1'}; {'S2'}}; map.specName = {'a[c]'; 'b[c]'; 'Glycolysis'}; map.specNotes = {''; ''; ''}; map.rxnName = {'R1'; 'R2'}; map.rxnType = {'STATE_TRANSITION'; 'TRANSPORT'}; map.rxnNotes = {''; ''}; addNotes(model, map)
- **Observed**: (R2025a, 2026-11-16) error "Cell elements must be character arrays." from char(model.subSystems(idsModel)) at line 105; createModel writes subSystems in this format
- **Expected**: the reaction notes with 'Subsystem: S1' and 'Subsystem: S2'
- **Source lines**: 105
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testAddNotes.m`

### `src/visualization/metabolicCartography/changeNodesArea.m`

#### The optional areaWidth is not defaulted when areaHeight is given

- **Severity**: error
- **Trigger**: map.specID = {'s1';'s2'}; map.specName = {'A';'B'}; map.molID = {'s1';'s2';'s1'}; map.molHeight = {'40';'40';'40'}; map.molWidth = {'80';'80';'80'}; changeNodesArea(map, {'A'}, 30)
- **Observed**: MATLAB R2025a: error 'Not enough input arguments.' at changeNodesArea line 42; the default areaWidth = 70.0 is set only inside 'if nargin < 3', so it is never set for three inputs.
- **Expected**: heights of the aliases of A set to 30 and widths to the default 70
- **Source lines**: 24-27, 42
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testChangeNodesArea.m`

### `src/visualization/metabolicCartography/colorProtein.m`

#### The default colour 'Red' is not a key of createColorsMap

- **Severity**: error
- **Trigger**: map.specName = {'hk'}; map.specMetaID = {'s5'}; map.specIncName = cell(0, 1); map.specIncID = cell(0, 1); map.molID = {'s5'}; map.molColor = {'ffccff66'}; colorProtein(map, {'hk'})
- **Observed**: (R2025a, 2026-11-15) error 'The specified key is not present in this container.' raised by colorProtein line 49; the same call with 'RED' or 'BLUE' as third input returns molColor {'FF0000FF'} for 'BLUE'
- **Expected**: the protein node coloured 'FFFF0000' (RED), the documented default
- **Source lines**: 32
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testColorProtein.m`

### `src/visualization/metabolicCartography/colorSubsystemCD.m`

#### Reactions with several subsystems shift the selection to the wrong reactions

- **Severity**: wrong-result
- **Trigger**: model.rxns = {'R1'; 'R2'; 'R3'}; model.subSystems = {{'A', 'B'}; {'C'}; {'B'}}; map.rxnName = {'R1'; 'R2'; 'R3'}; map.rxnColor = {'X'; 'X'; 'X'}; map.rxnWidth = {1; 1; 1}; colorSubsystemCD(map, model, 'C')
- **Observed**: (R2025a, 2026-11-16) rxnColor = {'X'; 'X'; 'FFFF0000'}: R3 is coloured instead of R2, because [model.subSystems{:}] has 4 entries for 3 reactions; with subsystem 'B' the call fails with "The logical indices contain a true value outside of the array bounds."; subSystems given as a cell of char vectors (model.rxns = {'R1'; 'R2'}, model.subSystems = {'S1'; 'S2'}, subsystem 'S2') are concatenated into one character row 'S1S2', compared character by character, and fail with the same error
- **Expected**: rxnColor = {'X'; 'FFFF0000'; 'X'} for 'C', and R1 and R3 coloured for 'B'
- **Source lines**: 45
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testColorSubsystemCD.m`

### `src/visualization/metabolicCartography/defaultColorCD.m`

#### Secondary reaction lines are coloured with the undefined function Colors

- **Severity**: error
- **Trigger**: map.rxnName = {'R1'}; map.rxnColor = {'ffff0000'}; map.rxnWidth = {'3.0'}; map.rxnReactantLineColor = {{'ffff0000'}}; map.rxnReactantLineWidth = {{'3.0'}}; map.rxnProductLineColor = {''}; map.rxnProductLineWidth = {''}; defaultColorCD(map)
- **Observed**: (R2025a, 2026-11-15) error "Undefined function 'Colors' for input arguments of type 'char'." raised by defaultColorCD line 36 (line 42 for product lines); a map without the four line fields is returned with rxnColor {'ff000000'} and rxnWidth {1}
- **Expected**: the secondary reactant and product lines set to 'ff000000' with width 1, as the header and the comment of the function say
- **Source lines**: 36, 42
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testDefaultColorCD.m`

### `src/visualization/metabolicCartography/defaultLookMap.m`

#### An included species named as an ion makes the main species of the same index an ION

- **Severity**: wrong-result
- **Trigger**: a map with the complete structure (field rxnReactantLineColor present) with specID = {'s1'; 's2'; 's3'}, specName = {'glc[c]'; 'hk'; 'cplx'}, specType = {'SIMPLE_MOLECULE'; 'PROTEIN'; 'COMPLEX'}, specIncID = {'s4'}, specIncName = {'Na_plus_'}, specIncType = {'ION'} (full map in the notes of the feature's result record), then newmap = defaultLookMap(map)
- **Observed**: (R2025a, 2026-11-15) newmap.specType = {'ION', 'PROTEIN', 'COMPLEX'}: line 166 writes newmap.specType{m}, where m indexes specIncName, so glc[c] (species 1) becomes an ION; with more included ions than species, specType also grows
- **Expected**: newmap.specType{1} stays 'SIMPLE_MOLECULE' and newmap.specIncType{1} is 'ION' (as lines 188-190 do for included non-ions)
- **Source lines**: 165-167
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testDefaultLookMap.m`

### `src/visualization/metabolicCartography/findRxnsInMap.m`

#### A list with a reaction name absent from the map is an error

- **Severity**: error
- **Trigger**: the same map; [rxnID, rxnIDref] = findRxnsInMap(map, {'B'; 'Z'})
- **Observed**: (R2025a, 2026-11-15) error MATLAB:badsubscript 'Array indices must be positive integers or logical values.': ismember returns index 0 for 'Z' and line 24 indexes map.rxnID with it
- **Expected**: rxnID = [2; 0] without an error, as the single-name form returns 0 for a name that is not in the map
- **Source lines**: 23-24
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testFindRxnsInMap.m`

#### A single reaction name found once leaves the output rxnIDref unassigned

- **Severity**: error
- **Trigger**: map.rxnName = {'A'; 'B'; 'A'}; map.rxnID = {'r1'; 'r2'; 'r3'}; [rxnID, rxnIDref] = findRxnsInMap(map, 'B')
- **Observed**: (R2025a, 2026-11-15) error MATLAB:unassignedOutputs 'Output argument "rxnIDref" (and possibly others) not assigned a value in the execution with "findRxnsInMap" function.': the character-vector branch sets rxnIDref only when the name is absent or found more than once
- **Expected**: rxnID = 2 and rxnIDref = {'r2'}
- **Source lines**: 26-34
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testFindRxnsInMap.m`

### `src/visualization/metabolicCartography/mapFormula.m`

#### Fails instead of returning empty lists when no listed reaction is in the map

- **Severity**: error
- **Trigger**: a map without the reactions of rxnList, e.g. mapFormula(map, {'RX'}) with any map structure whose rxnName does not contain 'RX', such as the four-reaction map (HEX1, PGI, HEX1, PFK) of the wave 11 version of this test (also with the first output only)
- **Observed**: MATLAB R2025a prints 'Attention : 1 reaction(s) not present in the map!!!' and raises 'Output argument "formulaList" (and possibly others) not assigned a value in the execution with "mapFormula" function.'; formulaList and rxnsList are assigned only inside the loop over the present reactions.
- **Expected**: empty formulaList and rxnsList, absentRxns = {'RX'}, duplicatedRxns empty; absentRxns is a documented output and line 41 prints 'Attention : N reaction(s) not present in the map!!!', so absent reactions are an intended input, which fails when every listed reaction is absent (severity audit T009a)
- **Source lines**: 51, 99-100
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testMapFormula.m`

### `src/visualization/metabolicCartography/removeCDReactions.m`

#### A name listed twice is reported as not present in the map

- **Severity**: cosmetic
- **Trigger**: removeCDReactions(fileName, {'R3', 'R3'}) on a map that contains R3
- **Observed**: MATLAB R2025a prints 'R3 not present in the map' (ismember returns only the first position of R3 in the list, so the second position is counted as missing); R3 is removed.
- **Expected**: no message, as R3 is in the map
- **Source lines**: 46, 51
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testRemoveCDReactions.m`

#### A species still used as modifier by a kept reaction is removed, leaving dangling references

- **Severity**: wrong-result
- **Trigger**: removeCDReactions(fileName, {'R5'}) on a map with species A-F (s1-s6, aliases sa1-sa6), R1: A -> B catalysed by E (modifiers="s5" aliases="sa5"), R2: B -> C, R3: C -> D, R5: E -> F (re4, base reactant s5/sa5, product s6/sa6)
- **Observed**: (R2025a, 2026-11-17) the written _subset.xml has the reactions R1, R2, R3, the species s1-s4 and the aliases sa1-sa4: s5 and sa5 are deleted although R1 keeps its modification modifiers="s5" aliases="sa5" and its modifierSpeciesReference to s5. map.sID and map.sAlias (getMapMatrices) hold reactants and products only, so lines 62 and 65 see s5/sa5 used by R5 alone and lines 71 and 74-75 delete them
- **Expected**: "removing corresponding species and species aliases if necessary" (lines 2-3): a species or alias used by a remaining reaction (as modifier too) is kept
- **Source lines**: 62, 65, 71, 74-75
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testRemoveCDReactions.m`

#### A species that only modifies removed reactions is kept

- **Severity**: wrong-result
- **Trigger**: removeCDReactions(fileName, {'R1'}) on the map above without R5 and F, where species E (s5, alias sa5) is only the catalyst (modifier) of R1
- **Observed**: (R2025a, 2026-11-17) the written map has R2, R3, the species s2-s5 and the aliases sa2-sa5: A (s1, sa1) is removed with R1, but E and sa5 stay although no remaining reaction uses them (map.sID and map.sAlias hold reactants and products only, not modifiers)
- **Expected**: E and sa5 removed with R1, as for reactants and products: the map structure is used "to be able to delete isolated species and species aliases" (lines 37-38)
- **Source lines**: 62, 65
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testRemoveCDReactions.m`

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

### `src/visualization/metabolicCartography/transformFullMap2XML.m`

#### A map with exactly one complex or one included species cannot be written

- **Severity**: error
- **Trigger**: an xmlStruct whose listOfComplexSpeciesAliases holds one complexSpeciesAlias (a struct, as xml2struct returns a single element) and map.complexAlias = {'csa1'}; or one included species in both
- **Observed**: (R2025a, 2026-11-15) error MATLAB:cellRefFromNonCell 'Brace indexing is not supported for variables of this type.' at line 123; with one included species 'Unable to perform assignment because brace indexing is not supported for variables of this type.' A single species alias, species or reaction meets the same {k} indexing at lines 89, 106 and 159
- **Expected**: the file is written, as lines 272-274 do for a single compartment
- **Source lines**: 89, 106, 123, 143, 159
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testTransformFullMap2XML.m`

#### Included species without notes are written with empty notes

- **Severity**: cosmetic
- **Trigger**: a map with two included species, one with notes and one with specIncNotes{2} = ''
- **Observed**: (R2025a, 2026-11-15) line 148 tests the whole list, not the entry, so an empty notes element is written for the second species, read back as a 1x0 char instead of the 0x0 char read from the original file
- **Expected**: no notes element for an included species without notes (as lines 112-114 do for species)
- **Source lines**: 148-149
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testTransformFullMap2XML.m`

#### The complex aliases and complex species of the map are not written

- **Severity**: wrong-result
- **Trigger**: [xmlStruct, map] = transformFullXML2Map(fileName) for a file with two complexSpeciesAlias elements csa1 and csa2; map.complexAlias{2} = 'csaX'; map.complexColor{2} = 'ff123456'; transformFullMap2XML(xmlStruct, map, outFile); [~, mapBack] = transformFullXML2Map(outFile)
- **Observed**: (R2025a, 2026-11-15) mapBack.complexAlias = {'csa1', 'csa2'} while mapBack.complexColor = {'fff7f7f7', 'ff123456'}: lines 123-124 copy the values of xmlStruct into the local map instead of the map values into xmlStruct
- **Expected**: mapBack.complexAlias = {'csa1'; 'csaX'} (the map information is transferred)
- **Source lines**: 123-124
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testTransformFullMap2XML.m`

#### The run time is printed on every call

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: (R2025a, 2026-11-15) 'Elapsed time is 0.185330 seconds.' printed by tic/toc
- **Expected**: no console output, or output gated behind a printLevel
- **Source lines**: 84, 287
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testTransformFullMap2XML.m`

### `src/visualization/metabolicCartography/transformFullXML2Map.m`

#### A map with exactly one complex species alias cannot be read

- **Severity**: error
- **Trigger**: a CellDesigner file whose celldesigner:listOfComplexSpeciesAliases holds one celldesigner:complexSpeciesAlias (every other list with two or more entries), then [xmlStruct, map] = transformFullXML2Map(fileName)
- **Observed**: (R2025a, 2026-11-15) error MATLAB:cellRefFromNonCell 'Brace indexing is not supported for variables of this type.' at line 140: xml2struct returns a struct, not a cell, for a single element and the loop indexes it with {k}. A file with one species alias fails the same way at line 99 (observed); one species, included species or reaction meets the same indexing at lines 118, 171 and 194
- **Expected**: map.complexAlias = {'csa1'} and the other fields, as lines 344-346 do for a single compartment
- **Source lines**: 98-99, 117-118, 139-140, 170-171, 192-194
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testTransformFullXML2Map.m`

#### Reaction notes written inside XHTML elements cannot be read

- **Severity**: error
- **Trigger**: a reaction with the notes '<notes><html xmlns="http://www.w3.org/1999/xhtml"><body><p>hexokinase</p></body></html></notes>'
- **Observed**: (R2025a, 2026-11-15) error 'Unrecognized field name "Text".' at line 334; species notes of the same form are read as '' (lines 124-127)
- **Expected**: no error; rxnNotes read as the species notes are
- **Source lines**: 334
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testTransformFullXML2Map.m`

#### The field compartName is missing for a map without compartments

- **Severity**: wrong-result
- **Trigger**: a file with an empty celldesigner:listOfCompartmentAliases
- **Observed**: (R2025a, 2026-11-15) map.compartAlias = '' and map has no field compartName
- **Expected**: map.compartName = '' (documented as empty if no info). Severity audit 2026-11-15: OUTPUTS documents ".compartName - name of each compartment (empty if no info)"; for a map without compartments only compartAlias = '' is set (line 357), the field is missing and map.compartName errors
- **Source lines**: 356-357
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testTransformFullXML2Map.m`

#### The run time is printed on every call

- **Severity**: cosmetic
- **Trigger**: any call
- **Observed**: (R2025a, 2026-11-15) 'Elapsed time is 0.732667 seconds.' printed by tic/toc
- **Expected**: no console output, or output gated behind a printLevel
- **Source lines**: 91, 360
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testTransformFullXML2Map.m`

### `src/visualization/metabolicCartography/transformMap2XML.m`

#### A reaction set to reversible 'true' in the map stays reversible="false" in the file

- **Severity**: wrong-result
- **Trigger**: [x, m] = transformXML2Map(f) on a map whose reaction has reversible="false"; m.rxnReversibility{1} = 'true' (a documented value, line 40, as transformToReversibleMap writes it); transformMap2XML(x, m, out); [~, m2] = transformXML2Map(out)
- **Observed**: (R2025a, 2026-11-17) m2.rxnReversibility{1} is 'false': lines 162-164 write the attribute only when the map value is 'false', so the old value of xmlStruct stays
- **Expected**: 'true' in the written file: the map information "is then transferred to the xmlStruct" (lines 19-20)
- **Source lines**: 162-164
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testTransformMap2XML.m`

#### Emptied notes and compartment aliases of the map are not removed from the file

- **Severity**: wrong-result
- **Trigger**: the map above with species notes 'glucose', reaction notes 'hexokinase' and molecule compartment alias 'ca1'; m.specNotes{1} = ''; m.rxnNotes{1} = ''; m.molCompartAlias{1} = ''; transformMap2XML(x, m, out); [~, m2] = transformXML2Map(out)
- **Observed**: (R2025a, 2026-11-17) m2.specNotes{1} is 'glucose', m2.rxnNotes{1} 'hexokinase' and m2.molCompartAlias{1} 'ca1': these values are written only when non-empty, so the values of xmlStruct stay
- **Expected**: the file reflects the map (the INPUTS document these fields as "empty if no info")
- **Source lines**: 79-81, 99-101, 281-283
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testTransformMap2XML.m`

#### Every '~' of the file name is replaced by the home folder

- **Severity**: limitation
- **Trigger**: a file name starting with '~' that contains another '~', e.g. '~/maps/a~b.xml'
- **Observed**: strrep(fileName, '~', homePath) replaces each '~', not only the leading one
- **Expected**: only the leading '~' expanded
- **Source lines**: 69
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testTransformMap2XML.m`

#### The check for a removed only reactant or product compares with the whole alias list

- **Severity**: wrong-result
- **Trigger**: a reaction with one species reference of reactants (or products) whose alias was removed from map.molAlias and from the alias list of xmlStruct, in a map of two or more aliases; e.g. R3: C (sa3) -> D (sa4) with sa4 removed from a map of the aliases sa1-sa4
- **Observed**: (R2025a, 2026-11-17) no error; the written file has the three remaining aliases and R3 still references sa4 in its listOfProducts. strcmp(alias, map.molAlias) returns one logical per map alias and 'if' needs all of them true, so the handling code (error 'removing only substrate in reaction' or '... product ...') is never reached for a map of two or more aliases; by reading, it is reached for a one-alias map in which nothing was removed
- **Expected**: the error only when the single reference's alias is not in map.molAlias
- **Source lines**: 108-109, 126-127
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testTransformMap2XML.m`

#### The error for a single secondary reactant or product link with several map aliases says 'should not be cell'

- **Severity**: cosmetic
- **Trigger**: a map with two secondary reactants (or products) for a reaction whose XML has one link (a struct, not a cell)
- **Observed**: error 'should not be cell' although the link is not a cell
- **Expected**: a message naming the inconsistent reactant (product) aliases
- **Source lines**: 211, 245
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testTransformMap2XML.m`

### `src/visualization/metabolicCartography/unifyMetabolicPPImapCD.m`

#### Secondary links are recoloured by position, not by the index of the non-empty entries

- **Severity**: wrong-result
- **Trigger**: a map whose reactions with secondary links are not the first ones, as transformFullXML2Map produces ('' for reactions without links), e.g. map.rxnName = {'r1'; 'r2'; 'r3'}; map.rxnColor = {'FF000000'; 'FF000000'; 'FF000000'}; map.rxnWidth = {5; 5; 5}; map.molColor = {'FF00FF00'}; map.complexColor = {'FF0000FF'}; map.rxnProductLineColor = {''; {'FFFF0000'}; ''}; map.rxnProductLineWidth = {''; {5}; ''}; map.rxnReactantLineColor = {''; ''; {'FFFF0000'; 'FFFF0000'}}; map.rxnReactantLineWidth = {''; ''; {5; 5}}; map2 = unifyMetabolicPPImapCD(map)
- **Observed**: MATLAB R2025a: map2.rxnReactantLineColor{3} is still {'FFFF0000'; 'FFFF0000'} and map2.rxnProductLineColor{2} is still {'FFFF0000'}: the loops run t (r) = 1:length(index) and read entry t (r) instead of index(t) (index(r)), so they visit the empty first entries and never the non-empty ones
- **Expected**: every non-empty secondary link colour 'FFDCDCDC' with width 1 (OUTPUT)
- **Source lines**: 51-60, 67-76
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testUnifyMetabolicPPImapCD.m`

### `src/visualization/metabolicCartography/visualizeNormalizedRxnPresence.m`

#### A custom colour scheme in the documented format stops with an index error

- **Severity**: error
- **Trigger**: visualizeNormalizedRxnPresence(mapDir, {1, 'aaaaaa', 10; 0.5, 'bbbbbb', 5}, 1) on a folder of four maps with a reaction present in none of them (fraction 0), or any scheme whose last row's fraction is above a reaction's fraction
- **Observed**: (R2025a, 2026-11-17) error 'Index in position 1 exceeds array bounds. Index must not exceed 2.' at line 150, where the range test of the last row reads the fraction of the next row; the heatmap is not written
- **Expected**: a colour for every reaction: setColours is documented (lines 28-32) as rows {fraction, colour, line width} with an example list, without the requirement of a final row of fraction 0
- **Source lines**: 150
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testVisualizeNormalizedRxnPresence.m`

#### A second call on the same folder counts the previous heatmap as a map

- **Severity**: wrong-result
- **Trigger**: rxnPrsTable = visualizeNormalizedRxnPresence(mapDir, [], 1) called twice on a folder of four maps (R1 present in all four, R2 in three, R3 in one, R4 in none)
- **Observed**: (R2025a, 2026-11-17) the first call gives the columns m1.xml-m4.xml and the heatmap colours FFfbcaf3, FFf6a077, FF103f60, FFD3D3D3 (widths 10, 8, 3, 1); the second call adds the column normalisedReactionHeatmap.xml (written by the first call into mapDir, lines 169-170, and read as a map, line 67), divides by 5 (line 134) and gives FFf6a077, FF99882c, FF103f60, FFD3D3D3 (widths 8, 7, 3, 1): R1, present in every map, gets 0.8 instead of 1
- **Expected**: the presence "normalized over the total amount of maps used" (lines 7-8), the same heatmap on every call; the documented output location is the input folder
- **Source lines**: 67, 134, 169-170
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testVisualizeNormalizedRxnPresence.m`

#### Reaction colours written in lower case are not counted as present

- **Severity**: wrong-result
- **Trigger**: a map in the folder whose present reactions have the line colour 'ffff4500' (lower case, as CellDesigner writes colours when it saves a map: the CellDesigner files of tutorials/visualization/metabolicCartography/data use 'ff000000') instead of 'FFFF4500'
- **Observed**: (R2025a, 2026-11-17) a folder with one such map (R1 and R2 'ffff4500') gives the presence [false false false false]: strcmp with 'FFFF4500' is case-sensitive
- **Expected**: the reactions of that colour counted as present, as hexadecimal colour codes are case-insensitive and the function "extracts reactions with a specific colour" (lines 2-3)
- **Source lines**: 101, 117
- **Documented in**: `test/verifiedTests/visualization/testMetabolicCartography/testVisualizeNormalizedRxnPresence.m`

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
