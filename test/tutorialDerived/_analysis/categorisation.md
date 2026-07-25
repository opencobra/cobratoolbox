# Tutorial repurposing categorisation (static analysis, 2026-07-13)

**Coverage** = # of `src/` functions the tutorial calls that NO current `verifiedTests` test names (static name-match; an over-estimate of true untested since indirect calls aren't credited).

Baseline: 1526 distinctively-named src functions; 383 named by tests; 1143 not. 212 distinct untested functions are reachable through the 98 analysed tutorials.

Flags: G=plot/figure · I=interactive · R=random/sampling · W=web · C=cplex/tomlab/GAMS.

- **A (prime):** coverage >=5, deterministic, no web/commercial-solver/interactive friction (plotting is fine, suppressible). Repurpose directly into a test with `assert`s on the tutorial's computed quantities.
- **B (adaptable):** worth repurposing with work — seed the RNG (sampling), or thinner coverage.
- **C (blocked/deferred):** needs online access, a commercial/GAMS solver, or interactive input; would skip locally, so low repurposing value here.

## Category A (11 tutorials, coverage 129)

| cov | loc | flags | tutorial |
|----:|----:|:--|:--|
| 21 | 61 | ..... | visualization/metabolicCartography/tutorial_metabolicCartography_part2.m |
| 19 | 278 | G.... | analysis/vonBertalanffy/tutorial_vonBertalanffy_Recon3DModel_301.m |
| 16 | 246 | G.... | analysis/vonBertalanffy/tutorial_vonBertalanffy.m |
| 15 | 192 | G.... | analysis/vonBertalanffy/tutorial_vonBertalanffy_iAF1260.m |
| 12 | 23 | G.... | visualization/cellDesigner/tutorial_cellDesigner.m |
| 10 | 59 | ..... | visualization/metabolicCartography/tutorial_metabolicCartography_part1.m |
| 9 | 135 | G.... | analysis/atomicallyResolveReconstruction/tutorial_atomicallyResolveReconstruction.m |
| 8 | 229 | G.... | dataIntegration/metabotools/tutorial_I/tutorial_metabotoolsI.m |
| 7 | 123 | G.... | analysis/reactingMoieties/tutorial_conservedAndReactingMoieties.m |
| 7 | 125 | ..... | analysis/conservedMoieties/tutorial_visualiseConservedMoieties.m |
| 5 | 53 | ..... | reconstruction/metaboRePort/tutorial_MetaboRePort.m |

## Category B (63 tutorials, coverage 57)

| cov | loc | flags | tutorial |
|----:|----:|:--|:--|
| 4 | 165 | G.... | analysis/entropicFBA/tutorial_entropicFluxBalanceAnalysisTradeoffs.m |
| 4 | 318 | G.... | analysis/vonBertalanffy/componentContribution/tutorial_analyseComponentContribution.m |
| 3 | 30 | G.... | base/cobrarrow/tutorial_COBRArrow.m |
| 3 | 39 | ..... | analysis/conservedMoieties/tutorial_buildAtomTransitionMultigraph.m |
| 3 | 90 | ..... | reconstruction/leakSiphonModes/tutorial_leakSiphonModes.m |
| 3 | 104 | G.... | reconstruction/modelManipulation/tutorial_modelManipulation.m |
| 3 | 288 | ..... | reconstruction/recon2FBAmodel/tutorial_reconToFBAmodel.m |
| 2 | 16 | ..... | design/TrimGdel/tutorial_TrimGdel.m |
| 2 | 19 | ..... | visualization/metabolicCartography/tutorial_metabolicCartogrphy_part3.m |
| 2 | 43 | G.... | reconstruction/ecoliCoreModel/part1/tutorial_ecoliCoreModel_part1.m |
| 2 | 77 | ..... | analysis/essentialRxns4MultipleModels/tutorial_essentialRxns4MultipleModels.m |
| 2 | 80 | G.... | reconstruction/fastGapFill/tutorial_fastGapFill.m |
| 2 | 98 | G.... | analysis/vonBertalanffy/combinedModel/tutorial_analyseCombinedModel.m |
| 2 | 157 | G.... | reconstruction/reconstructionSOP/tutorial_reconstructionSOP.m |
| 2 | 313 | G.... | analysis/conservedMoieties/tutorial_analyseConservedMoieties.m |
| 1 | 14 | ..... | analysis/ICONGEMs/tutorial_Icongems.m |
| 1 | 18 | G.... | reconstruction/rBioNet/tutorial_rBioNet.m |
| 1 | 39 | G.... | analysis/FBA/tutorial_FBA_part1.m |
| 1 | 45 | ..... | reconstruction/modelBorgifier/tutorial_modelBorgifier.m |
| 1 | 46 | G.... | analysis/sensitivityAnalysis/tutorial_sensitivityAnalysis.m |
| 1 | 48 | ..... | analysis/hostMicrobeInteractions/tutorial_hostMicrobeInteractions.m |
| 1 | 50 | ..... | reconstruction/fidelityTesting/tutorial_fidelityTesting.m |
| 1 | 59 | G.... | analysis/alternateOptimalSolutions/tutorial_alternateOptimalSolutions.m |
| 1 | 59 | ..... | reconstruction/recon2FBAmodel/tutorial_createSubnetworkRecon.m |
| 1 | 59 | G.... | visualization/EFMviz/tutorial_Efmviz_recon.m |
| 1 | 64 | ..... | dataIntegration/extractionTranscriptomic/tutorial_extractionTranscriptomic.m |
| 1 | 68 | G.... | analysis/atomicallyResolveReconstruction/old/tutorial_atomicallyResolveReconstruction.m |
| 1 | 70 | ..... | analysis/robustnessPhPP/tutorial_robustnessPhPP.m |
| 1 | 93 | G.... | analysis/simulateAGORAGrowthInDiets/tutorial_simulateAGORAGrowthInDiets.m |
| 1 | 117 | ..... | design/optGene/tutorial_optGene.m |
| 1 | 157 | ..... | analysis/sparseFBA/tutorial_sparseFBA_protonShuttle.m |
| 1 | 269 | ..... | design/optKnock/tutorial_optKnock.m |
| 1 | 352 | G.... | analysis/entropicFBA/tutorial_entropicFluxBalanceAnalysis.m |
| 0 | 1 | ..... | base/engagingWithTheCommunity/tutorial_engaging.m |
| 0 | 5 | ..... | base/initialize/tutorial_initialize.m |
| 0 | 6 | G.... | base/initializeAndVerify/tutorial_initializeAndVerify.m |
| 0 | 7 | G.... | base/verify/tutorial_verify.m |
| 0 | 12 | G.... | analysis/quadPrecisionFBA/tutorial_quadPrecisionFBA.m |
| 0 | 21 | ..... | analysis/genericKinetics/tutorial_genericKinetics.m |
| 0 | 22 | ..R.. | dataIntegration/uFBA/tutorial_uFBA.m |
| 0 | 23 | ..... | analysis/conservedMoieties/tutorial_identifyConservedMoieties.m |
| 0 | 24 | G.... | analysis/minSpan/tutorial_minSpan.m |
| 0 | 27 | ..... | reconstruction/modelCreation/tutorial_modelCreation.m |
| 0 | 32 | G.... | analysis/browseNetwork/tutorial_browseNetwork.m |
| 0 | 34 | ..... | base/IO/tutorial_IO.m |
| 0 | 36 | G.... | visualization/EFMviz/tutorial_Efmviz_ecoli.m |
| 0 | 41 | G.... | reconstruction/COBRAconcepts/tutorial_COBRAconcepts.m |
| 0 | 41 | ..R.. | visualization/SAMMIM/tutorial_Sammi.m |
| 0 | 43 | G.R.. | visualization/paint4Net/tutorial_bio_paint4net.m |
| 0 | 51 | ..R.. | reconstruction/constrainingModels/tutorial_AdditionalConstraintsAndVariables.m |
| 0 | 71 | G.... | analysis/numCharact/tutorial_numCharact.m |
| 0 | 71 | ..... | analysis/sparseFBA/tutorial_sparseLP.m |
| 0 | 72 | G.... | analysis/FBA/tutorial_FBA_part2.m |
| 0 | 73 | ..... | analysis/sparseFBA/tutorial_sparseFBA_freeATPtest.m |
| 0 | 78 | ..... | reconstruction/constrainingModels/tutorial_constrainingModels.m |
| 0 | 99 | G.... | analysis/sparseFBA/tutorial_sparseFBA.m |
| 0 | 107 | G.... | reconstruction/ecoliCoreModel/part2/tutorial_ecoliCoreModel_part2.m |
| 0 | 125 | ..... | analysis/relaxedFBABounds/tutorial_relaxedFBABounds.m |
| 0 | 129 | G.... | base/intro/tutorial_MATLAB_intro.m |
| 0 | 130 | G.... | reconstruction/ecoliCoreModel/part3/tutorial_ecoliCoreModel_part3.m |
| 0 | 132 | ..... | analysis/relaxedFBA/tutorial_relaxedFBA.m |
| 0 | 176 | G.... | analysis/numCharact/tutorial_numCharactWBM.m |
| 0 | 539 | ..... | reconstruction/modelATPYield/tutorial_modelATPYield.m |

## Category C (24 tutorials, coverage 88)

| cov | loc | flags | tutorial |
|----:|----:|:--|:--|
| 21 | 150 | ...W. | dataIntegration/metaboAnnotator/tutorial_MetaboAnnotator.m |
| 13 | 57 | G...C | reconstruction/demeter/tutorial_demeter.m |
| 11 | 147 | ..R.C | dataIntegration/metabotools/tutorial_II/tutorial_metabotoolsII.m |
| 7 | 78 | G...C | design/optForceGAMS/tutorial_optForceGAMS.m |
| 6 | 46 | ..RWC | analysis/microbiomeModelingToolbox/tutorial_mgPipe.m |
| 6 | 118 | ....C | dataIntegration/thermoKernel/tutorial_thermoKernel.m |
| 5 | 81 | ....C | analysis/vonBertalanffy/findThermoConsistentFluxSubset/tutorial_findThermoConsistentFluxSubset.m |
| 4 | 39 | ....C | dataIntegration/XomicsToModel/tutorial_XomicsToModel.m |
| 4 | 77 | G...C | analysis/nutritionAlgorithm/tutorial_NutritionAlgorithm.m |
| 2 | 95 | G.R.C | analysis/rMTA/tutorial_rMTA.m |
| 2 | 101 | G.RW. | analysis/microbeMicrobeInteractions/tutorial_microbeMicrobeInteractions.m |
| 1 | 40 | ....C | analysis/gMCS/tutorial_gMCS.m |
| 1 | 55 | ....C | dataIntegration/fitExperimentalFlux/tutorial_fitExperimentalFlux.m |
| 1 | 72 | G...C | analysis/FVA/tutorial_FVA.m |
| 1 | 75 | ....C | analysis/FBA_variants/tutorial_FBA_variants.m |
| 1 | 199 | ....C | reconstruction/modelSanityChecks/tutorial_modelSanityChecks.m |
| 1 | 229 | G...C | analysis/steadyCom/tutorial_steadyCom.m |
| 1 | 303 | G...C | base/benchmarkSolvers/tutorial_benchmarkWBMsolvers.m |
| 0 | 39 | ....C | visualization/remoteVisualisation/tutorial_remoteVisualisation.m |
| 0 | 58 | ....C | reconstruction/modelProperties/tutorial_modelProperties.m |
| 0 | 81 | G.R.C | analysis/uniformSampling/tutorial_uniformSampling_Ecore.m |
| 0 | 87 | G...C | design/optForce/tutorial_optForce.m |
| 0 | 104 | G.R.C | analysis/uniformSampling/tutorial_uniformSampling_genomeScale.m |
| 0 | 126 | G...C | analysis/pFBA/tutorial_pFBA.m |

## Category A — untested functions each would newly cover

- **visualization/metabolicCartography/tutorial_metabolicCartography_part2.m** (21): `addFluxFBA`, `addFluxFBAdirectionAndColor`, `addNotes`, `changeNodesArea`, `changeRxnType`, `colorProtein`, `colorRxnType`, `colorRxnsFromGenes`, `colorSubsystemCD`, `defaultColorCD`, `defaultLookMap`, `findMetsFromCompartInMap`, `findMetsInMap`, `findRxnsFromCompartInMap`, `findRxnsInMap`, `findRxnsPerTypeInMap`, `getMapMatrices`, `modifyReactionsMetabolites`, `transformFullMap2XML`, `unifyMetabolicMapCD`, `unifyMetabolicPPImapCD`
- **analysis/vonBertalanffy/tutorial_vonBertalanffy_Recon3DModel_301.m** (19): `addInchiToModel`, `addPseudoisomersToModel`, `componentContribution`, `configureSetupThermoModelInputs`, `createGroupIncidenceMatrix`, `directionalityChangeReport`, `directionalityStats`, `directionalityStatsFigures`, `driver_createTrainingModel`, `editCobraToolboxPath`, `forwardReversibleFigures`, `generateThermodynamicTables`, `initVonBertalanffy`, `numAtomsOfElementInFormula`, `pHbalanceProtons`, `readMetRxnBoundsFiles`, `setupThermoModel`, `thermoConstrainFluxBounds`, `transportReactionBool`
- **analysis/vonBertalanffy/tutorial_vonBertalanffy.m** (16): `componentContribution`, `configureSetupThermoModelInputs`, `directionalityChangeReport`, `directionalityStats`, `directionalityStatsFigures`, `editCobraToolboxPath`, `forwardReversibleFigures`, `generateThermodynamicTables`, `initVonBertalanffy`, `numAtomsOfElementInFormula`, `pHbalanceProtons`, `prepareTrainingData`, `readMetRxnBoundsFiles`, `setupComponentContribution`, `setupThermoModel`, `thermoConstrainFluxBounds`
- **analysis/vonBertalanffy/tutorial_vonBertalanffy_iAF1260.m** (15): `componentContribution`, `configureSetupThermoModelInputs`, `directionalityChangeReport`, `directionalityStats`, `directionalityStatsFigures`, `forwardReversibleFigures`, `generateThermodynamicTables`, `initVonBertalanffy`, `numAtomsOfElementInFormula`, `pHbalanceProtons`, `prepareTrainingData`, `readMetRxnBoundsFiles`, `setupComponentContribution`, `setupThermoModel`, `thermoConstrainFluxBounds`
- **visualization/cellDesigner/tutorial_cellDesigner.m** (12): `addAnnotation`, `addColour`, `addFlux`, `addMiriam`, `cmpMet`, `cmpRxn`, `colourNode`, `correctMetName`, `parseCD`, `repairXML`, `writeCD`, `writeTXT`
- **visualization/metabolicCartography/tutorial_metabolicCartography_part1.m** (10): `addColourNode`, `changeMetColor`, `changeRxnColorAndWidth`, `checkCDerrors`, `correctMetNameCD`, `correctRxnNameCD`, `mapFormula`, `transformFullXML2Map`, `transformToIrreversibleMap`, `transformToReversibleMap`
- **analysis/atomicallyResolveReconstruction/tutorial_atomicallyResolveReconstruction.m** (9): `compareInchis`, `findBondsBrokenAndFormed`, `findEnthalpyChange`, `metDatabaseStatus`, `obtainAtomMappingsRDT`, `obtainMetStructures`, `openBabelConverter`, `readAtomMappingFromRxnFile`, `standardiseMolDatabase`
- **dataIntegration/metabotools/tutorial_I/tutorial_metabotoolsI.m** (8): `calculateQuantitativeDiffs`, `defineUptakeSecretionProfiles`, `integrateGeneExpressionData`, `networkTopology`, `performSampling`, `setQualitativeConstraints`, `setSemiQuantConstraints`, `summarizeSamplingResults`
- **analysis/reactingMoieties/tutorial_conservedAndReactingMoieties.m** (7): `buildAtomAndBondTransitionMultigraph`, `buildReactingMoietyTables`, `createMoietyGraph`, `displayReactingMoieties`, `getMetMoietySubgraphs`, `identifyConservedReactingMoieties`, `identifyConservedReactingSubgraphs`
- **analysis/conservedMoieties/tutorial_visualiseConservedMoieties.m** (7): `checkCDerrors`, `getCompartment`, `rankMetabolicConnectivity`, `removeMapReactions`, `removeMapSpecies`, `removeMapSpeciesOnly`, `writeNewtExperiment`
- **reconstruction/metaboRePort/tutorial_MetaboRePort.m** (5): `annotateSBOTerms`, `generateMetaboReport`, `generateMetaboScore`, `populateModelMetStr`, `populateModelwithRxnIDs`
