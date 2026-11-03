# Summary: tests for every safe untested function (Tier 2 batch and extension)

**Feature**: 20261103-105830-tier2-safe-batch · **Date**: 2026-11-03

## Outcome

- 52 functions probed (30 model-taking candidates + 22 from the scope extension); 8 more
  excluded before probing (spec "Scope extension").
- **36 tests written**, all passing through `runScriptFile` in one MATLAB session and again with
  the solver spies first on the path (no test reaches a solver). 20 are Tier 2 (a distributed
  model loaded once through `getDistributedModel`) and 16 are Tier 1 (no model).
- **16 functions dropped** with the reasons below.
- **59 defects recorded** in the new test headers; the registry now lists 110 defects in 65
  functions. No `src` file changed.
- After this batch, every untested function that takes a model either has a test, was dropped
  for a reason below, or reaches a solver, file or toolbox (Tier 3 or later) or a registered
  silent defect (`applyEFluxConstraints`, `findMetabolicJunctions`, `findNeighborRxns`,
  `addToTmodel`, `cleanTmodel`).

## Tests written

| Function | Test | Tier | Model | Line coverage | Defects |
|---|---|---|---|---|---:|
| generateGrRules | analysis/testExploration/testGenerateGrRules.m | 2 | ecoli_core | 33/33 | 1 |
| buildMDFBAProblem | analysis/testMDFBA/testBuildMDFBAProblem.m | 2 | ecoli_core | 31/31 | 0 |
| addMicrobeCommunityBiomass | analysis/testMultiSpeciesModelling/testAddMicrobeCommunityBiomass.m | 2 | ecoli_core + 2 metabolites | 15/15 | 1 |
| findCyclicRxns | analysis/testTopology/testFindCyclicRxns.m | 2 | ecoli_core | 2/2 | 1 |
| createModelNewCompartment | analysis/testWholeBody/testCreateModelNewCompartment.m | 2 | ecoli_core | 44/46 | 3 |
| addReactionsHH | analysis/testWholeBody/testAddReactionsHH.m | 2 | ecoli_core + 3 renamed biomass copies | 39/39 | 2 |
| mapKEGGID2Model | base/testIO/testKEGG/testMapKEGGID2Model.m | 2 | Recon2.v04 | 20/24 | 2 |
| mapMetName2KEGGID | base/testIO/testKEGG/testMapMetName2KEGGID.m | 2 | Recon2.v04 | 29/34 | 2 |
| makeSBMLAnnotationString | base/testIO/testUtilities/testMakeSBMLAnnotationString.m | 2 | AGORA Abiotrophia | 74/74 | 1 |
| mapAnnotationsToFields | base/testIO/testUtilities/testMapAnnotationsToFields.m | 2 | AGORA Abiotrophia | 18/19 | 0 |
| initFBAFields | base/testIO/testUtilities/testInitFBAFields.m | 2 | ecoli_core | 33/37 | 1 |
| regulariseMitochondrialReactions | dataIntegration/testXomicsToModel/testRegulariseMitochondrialReactions.m | 2 | Recon3DModel_301 | 33/33 | 0 |
| geneReactionMILP | design/testTrimGdel/testGeneReactionMILP.m | 2 | iAF1260 + hand-built | 52/52 | 0 |
| modelSetting | design/testTrimGdel/testModelSetting.m | 2 | iAF1260 | 20/20 | 1 |
| checkDatabaseIDs | reconstruction/testModelGeneration/testCheckDatabaseIDs.m | 2 | AGORA Abiotrophia | 15/15 | 1 |
| setFeedingFastingConstraints | analysis/testWholeBody/testSetFeedingFastingConstraints.m | 2 | Recon3DModel_301 + 17 whole-body-named reactions | 129/129 | 1 |
| optimizeVKmodel0 | base/testSolvers/testOptimizeVKmodel0.m | 2 | kinetic model from ecoli_core S | 290/306 | 4 |
| conditionSpecificGapFilling | reconstruction/testDemeter/testConditionSpecificGapFilling.m | 2 | AGORA Acidaminococcus + VMH database | 354/354 | 2 |
| rebuildBiomassReaction | reconstruction/testDemeter/testRebuildBiomassReaction.m | 2 | AGORA Acidaminococcus + VMH database | 106/189 | 3 |
| addReactionGEM | reconstruction/testModelManipulation/testAddReactionGEM.m | 2 | ecoli_core | 111/119 | 7 |
| constrainEcosystemPoint | analysis/testEcosystem/testConstrainEcosystemPoint.m | 1 | — | 28/28 | 0 |
| validatePersephoneInputs | analysis/testPersephone/testValidatePersephoneInputs.m | 1 | — | 64/64 | 1 |
| TwoSidedBarrier | analysis/testSampling/testTwoSidedBarrier.m | 1 | — | 110/110 | 1 |
| TableDisplay | analysis/testSampling/testTableDisplay.m | 1 | — | 102/104 | 2 |
| lsqrtest | analysis/testSubspaces/testLsqrtest.m | 1 | — | 16/16 | 1 |
| adjustBaselinesInAlberty2006 | analysis/testThermo/testAdjustBaselinesInAlberty2006.m | 1 | shipped Alberty2006.mat | 129/133 | 1 |
| createComputedSpeciesData | analysis/testThermo/testCreateComputedSpeciesData.m | 1 | — | 120/126 | 2 |
| connectedFR | analysis/testTopology/testConnectedFR.m | 1 | — | 24/25 | 1 |
| largestConnectedFR | analysis/testTopology/testLargestConnectedFR.m | 1 | — | 32/33 | 1 |
| descFileRead | base/testIO/testDescFileRead.m | 1 | shipped definitions file | 19/19 | 2 |
| removeIndicesInDimenion | base/testTools/testRemoveIndicesInDimenion.m | 1 | — | 5/5 | 1 |
| readRXNFile | dataIntegration/testChemoInformatics/testReadRXNFile.m | 1 | shipped .rxn files | 69/82 | 0 |
| makeNamesUnique | reconstruction/testModelBorgifier/testMakeNamesUnique.m | 1 | — | 10/55 | 2 |
| readCD | visualization/testCellDesigner/testReadCD.m | 1 | — | 15/15 | 2 |
| updateCD | visualization/testCellDesigner/testUpdateCD.m | 1 | — | 64/68 | 7 |
| removeMapMol | visualization/testMetabolicCartography/testRemoveMapMol.m | 1 | shipped glycolysisAndTCA.xml | 42/47 | 2 |

Every uncovered line is listed with its reason in the test header (defective input skipped,
branch unreachable, a toolbox that is not installed, or user interaction).

## Functions dropped

| Function | Reason |
|---|---|
| generateHyperlinkedModel | every call errors (undefined `addGrRulesLinked`, line 57; undefined `command`, lines 92-100; `numel(model.rules)` on an absent field, line 48) |
| estimateDfGt0, estimateDrGt0 | need component-contribution fields (DfG0, pseudoisomers, uncertainties) that no distributed model has |
| setCommonZeroStandardGibbsEnergyOfFormation | needs Alberty/group-contribution metabolite data; also every call errors (`getCompartment` called with two inputs, line 58) |
| thermodynamicAdjustmentToStoichiometry | every call errors (`getCompartment` with two inputs, line 153; `abbr(4:6)` on a cell, lines 106-107, 123-124) |
| physiologicalConstraintsHMDBbased, physiologicalConstraintsHMDBbasedTEMP | act only on whole-body reaction names; whole-body models are not distributed |
| setDietConstraints | acts only on `Diet_EX_` reactions; no distributed model has them |
| assignGPRA, assignSubSystems | call `parseSimPhenyGPRA`, which does not exist in the repository or its history |
| performRegressions | needs the Statistics and Machine Learning Toolbox (`fitglm`, `fitglme`) |
| createFitL, createFitR | need the Curve Fitting Toolbox (`fittype`, `prepareCurveData`) |
| issueConfirmationWarning | documented to wait for user confirmation (its condition is inverted, so it waits only on Jenkins) |
| getBinsOfFluxes | every valid call errors (`output` is the number 0, then `output.samps`, line 142) |
| ispolymer | every call errors (`numAtomsOfElementInFormula` rejects the element 'FULLR2', line 17) |

The defects of dropped functions are not in the registry (they have no test file); they are
listed here for the maintainer.

## Decisions to review

1. **Derived fixtures on distributed models.** Three tests add whole-body-style reactions to a
   distributed model so whole-body code paths run (`addReactionsHH`: three renamed biomass
   copies; `setFeedingFastingConstraints`: 17 reactions on Recon3D; `addMicrobeCommunityBiomass`:
   two metabolites). Each header says so. If a whole-body model should be required instead, drop
   these three.
2. **`addReactionGEM` accumulation.** Filling a reaction slot whose column is not empty adds the
   new coefficients to the old ones. The first draft pinned this; it was removed because it may
   be a defect. Decide whether it is intended.
3. **`addReactionGEM` subSystems.** Every call stores subSystems doubly nested (recorded as a
   defect); the test checks every other field and leaves those entries out.
4. **`removeIndicesInDimenion`.** Its help says the indices are removed, but they are kept, and its
   only caller (`removeFieldEntriesForType`) relies on keeping them. The test pins the code; the
   help text is recorded as a cosmetic defect.
5. **Exact iteration counts** in `testOptimizeVKmodel0` (Niter/Nmap per solver) are deterministic
   here but could differ with another BLAS at a stopping threshold.
6. **Shipped data from submodules.** The DEMETER tests read the VMH database from
   `papers/2021_demeter/input`; CI must initialise the `papers` submodule.
7. **Console volume.** `setFeedingFastingConstraints` prints thousands of "Reaction ... not in
   model" warnings and `readCD`/`updateCD` print debug output (recorded as cosmetic defects);
   not suppressed, per Constitution VII.
8. **Possibly broken callers outside scope.** `lewisCenter`, `analyticCenter` and
   `ConvexProgram` call `TableDisplay`/`TwoSidedBarrier` in the style of the copies under
   `papers/`, not the `src/` classes; not probed.
