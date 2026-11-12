# Implementation Plan: Plain-MATLAB replacements for the remaining paid-toolbox functions

**Branch**: `20261111-152503-toolbox-free-remaining` | **Date**: 2026-11-11 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20261111-152503-toolbox-free-remaining/spec.md`

## Summary

Add 23 plain-MATLAB functions and classes in `src/base/utilities/toolboxFree/` (10 statistics,
3 fit/optimizer, 3 figure, 5 regression/SVM functions incl. the formula and design helpers, and
2 model classes), use exact base-MATLAB
substitutes where they exist, switch every call site in the inventory, remove licence guards that
no longer protect anything, and drop the toolbox requirements of 13 tests. Functions whose results
cannot be reproduced are left toolbox-gated (research R1). Each new function is tested against
MathWorks documentation numbers and SciPy / statsmodels / scikit-learn references, with a parity
section that runs where the toolbox is installed. Design decisions: [research.md](research.md);
per-function semantics: [mathworks-semantics.md](mathworks-semantics.md).

## Technical Context

**Language/Version**: MATLAB R2025a on this machine (supported baseline R2024b+); Python 3.12 with
SciPy 1.16.3, statsmodels 0.15.0, scikit-learn 1.9.1 (+ `firthlogist` if it installs cleanly) in a
virtual environment outside the repository, for reference values only.

**Primary Dependencies**: none new for the toolbox. Reuses `cobraNormcdf`, `cobraTcdf`,
`cobraTinv`, `cobraChi2cdf`, `cobraFcdf`, `cobraGrp2idx`, `cobraPdist` (first slice),
`fdrBHadjustment`, `computeEcosystemLinkage`, `isParallelToolboxAvailable`.

**Storage**: N/A (one call site writes a text file: `generateIsotopomerSolver`, byte-identical).

**Testing**: Tier-1 tests under `test/verifiedTests/base/testToolboxFree/`, run with
`runTestSuite`/`runScriptFile`; coverage per new function with the project coverage helper;
existing tests of changed call sites re-run; MATLAB runs on the maintainer's machine go through
its memory-capped wrapper (at most three sessions at a time).

**Target Platform**: headless Linux CI (Docker + Xvfb, Gurobi), any MATLAB ≥ R2024b.

**Project Type**: MATLAB library (scientific toolbox).

**Performance Goals**: within a small factor of the MathWorks function at the call-site sizes
(e.g. `cobraGa` on optGene's 4×125 population; `cobraKsdensity` on expression vectors of ~20k
values; `cobraFitglm` on PERSEPHONE subsets of ≤ a few thousand rows); subordinate to correctness.

**Constraints**: no MathWorks name shadowed (FR-001); no public interface change (FR-009); no
MathWorks code copied; `external/`, `old/`, `deprecated/` untouched; warnings visible and raised
only where MathWorks raises them (performRegressions discards a fit on any warning).

**Scale/Scope**: 23 new functions/classes, ~35 call-site files, ~16 changed tests, 23 new tests, 5 reference scripts. Estimated 3,000–3,500 source lines, ~2,500 test lines.

## Constitution Check

*GATE: passed before Phase 0; re-checked after Phase 1 design: still passes.*

- **Scientific code quality (I)**: no COBRA model semantics touched. Statistical and numerical
  semantics follow the MathWorks documentation with cited sources (semantics note); where a
  result cannot be reproduced the function is left gated (R1), so no call site silently changes
  its science. Optimizers are judged by reaching the same optimum (maintainer decision).
- **Backward compatibility (II)**: call-site signatures unchanged. `performRegressions`' second
  output keeps MathWorks property names, layouts and values through `cobraGeneralizedLinearModel`
  (maintainer decision 2026-11-11); the class name differs (documented in its help and the
  function's header). Results with the toolbox installed are unchanged in kind (parity sections).
- **Testing and reproducibility (III)**: one Tier-1 test per new function (III-Naming), declaring
  no requirement; references stated in headers with library and version; fixed seeds for random
  code; 100% line coverage or listed exemptions; pre-existing defects recorded under III-Defects
  and `test/known-defects.md` regenerated; 13 tests lose a toolbox requirement, 3 keep it with the
  reason in the header.
- **User experience and diagnostics**: unsupported options error with the option's name;
  model-class methods not reproduced error with the method's name; left-gated paths keep their
  toolbox error or guard with a message naming the toolbox.
- **Performance and numerical integrity (IV)**: tolerances justified per reference; no
  verification removed; solver layer untouched (the optional `matlab` backend stays). SVM
  training stays inside `cobraFitcsvm` (SMO) rather than `solveCobraQP` — not a COBRA model
  problem, and a solver requirement in a Tier-1 test is avoided (R7).
- **External-solver configuration audit**: N/A — no external solver is invoked. (Configuration
  surfaces of the replaced MathWorks optimizers — tolerances, iteration limits, stopping options —
  are enumerated in semantics note G2 §2.2 and §4.2 and mirrored as defaults.)
- **Spec-driven scope control (V)**: edits limited to the inventory call sites, the four licence
  guards, the listed tests and the new folder; read-only: `external/`, `old/`, `deprecated/`.
  New abstraction justified: two model classes (FR-005b) and formula/design helpers shared by
  `cobraFitglm` and `cobraFitlm`.
- **MATLAB coding standards (VII)**: openCOBRA headers (VII-E); `exist`/`isempty` optional
  arguments (VII-D); no `evalc` (VII-A); warnings never suppressed (VII-B); `try/catch` keeps
  `ME.stack` (VII-C). MATLAB best-practice skill: none registered for MATLAB conventions; the
  openCOBRA style guide (`documentation/source/guides/styleGuide.rst`) and MathWorks
  documentation are the sources, as in the first slice.
- **Parameter-setting fidelity (VIII)**: N/A — no ported or literate output.
- **Artifact placement (IX)**: source in `src/base/utilities/toolboxFree/`; tests
  and their small fixtures in `test/verifiedTests/base/testToolboxFree/`; reference scripts,
  semantics note, review and receipts in `specs/20261111-152503-toolbox-free-remaining/`. No
  generated output committed; the reference virtual environment lives outside the repository.
- **Single-sourcing (X)**: no rule restated; the semantics note is research, not guidance.

## Project Structure

### Documentation (this feature)

```text
specs/20261111-152503-toolbox-free-remaining/
├── spec.md, plan.md, research.md, data-model.md, quickstart.md
├── mathworks-semantics.md        # per-function semantics, call sites, references (G1–G4)
├── contracts/toolboxFree-api.md  # signatures and supported options of every new function
├── references/                   # scanUnresolved.m + one reference script per group (.py)
├── checklists/requirements.md
├── review.md                     # implementation phase
├── agent-runs/<UTC>-implement/implementation-receipt.md
└── tasks.md                      # /speckit-tasks
```

### Source Code (repository root)

```text
src/base/utilities/toolboxFree/
├── cobraAnova1.m  cobraKruskalwallis.m  cobraRanksum.m  cobraTtest2.m  cobraKstest2.m
├── cobraHygecdf.m  cobraTiedrank.m  cobraKsdensity.m  cobraCmdscale.m  cobraConfusionmat.m
├── cobraFitGauss1.m  cobraFminunc.m  cobraGa.m
├── cobraBoxplot.m  cobraClustergram.m  cobraOptimalLeafOrder.m
├── cobraFitglm.m  cobraFitlm.m  cobraFitcsvm.m  cobraParseModelFormula.m  cobraBuildModelDesign.m
└── cobraGeneralizedLinearModel.m  cobraLinearModel.m       # classdef

test/verifiedTests/base/testToolboxFree/
└── testCobra<Name>.m (one per file above, III-Naming), fixtures/ (small text/CSV inputs)

Call sites changed (src/, see spec inventory): analysis/{fluxEnrichmentAnalysis/FEA,
  multiSpecies/microbiomeModelingToolbox/{additionalAnalysis/{performStatisticalAnalysis (BH and
  kruskalwallis/ranksum/anova1 only), makeViolinPlots, correlateFluxWithTaxonAbundance},
  mgPipe/{retrieveModelStats, mgSimResCollect, plotMappingInfo}}, multiSpecies/SteadyCom/
  subroutines/SteadyComPOAgr, persephone/{performRegressions, runNonparametricTests, analyseWBMsol,
  initPersephone, additionalFunctions/{CreateClusterAndRAtables,
  dimensionalityReductionAndMultivariateAnalysis}}, sampling/compareTwoSamplesStat,
  KLdistance/KLdistance, igemRNA/modelCreation/createContextSpecificModel,
  thermo/vonBertalanffy/{estimateDfGt0, estimateDrGt0}, exploration/plotEssentialRxns,
  FVA/fastFVA/fastFVA}; base/solvers/varKin/BDCAmethods/{BDCA, DCA}; dataIntegration/
  {modelPredictiveCapacity, XomicsToModel/{analysis/quanQualAcc, thermoKernel/
  {plotThermoKernelExtractStats, plotThermoKernelStats}}, fluxomics/{score_KS,
  c13solver/generateIsotopomerSolver}, transcriptomics/{eFlux/eFlux, SWIFTCORE/{core, partition},
  rFASTCORMICS/{createFitL, createFitR, discretizeFPKM}}}; design/optGene;
  reconstruction/{comparison/modelBorgifier/optimalScores (fitcsvm, ttest2 only), rBioNet/model_stats,
  demeter/src/properties/summarizeFeaturesOnTaxonLevels}; visualization/paint4net/bio_paint4Net/
  bio_draw_by_rxn/bio_draw_by_rxn.

Tests changed: testBiomassPrecursorCheck, testCreatePanModels, testRFASTCORMICS, testFEA,
  testSteadyCom, testMgPipe, testSWIFTCORE, testPartition, testEFlux, testOptGene, testSammi,
  testPaint4Net_bio_draw_by_rxn, testPaint4Net_bio_draw_by_met, testMoieties (dead block),
  testSampleCbModel, testSampleCbModelRHMC, testConnectedComponents (header reason only).
```

**Structure Decision**: same layout as the first slice (`toolboxFree/` + `testToolboxFree/`). No
`private/` folder: every helper is a public `cobra*` function with its own test (III-Naming;
analyze C1).

## Implementation order (input to /speckit-tasks)

1. **Setup**: reference scripts per group (`references/g1_stats.py`, `g2_fit_optim.py`,
   `g3_regression.py`, `g4_figures.py`), each printing the values pasted into tests.
2. **US1 statistics** (P1): `cobraAnova1` → `cobraKruskalwallis` (ANOVA on ranks); `cobraTiedrank` →
   `cobraRanksum`; `cobraTtest2`, `cobraKstest2`, `cobraHygecdf`, `cobraKsdensity`, `cobraCmdscale`,
   `cobraConfusionmat`; base substitutions (R3); call sites; licence guards (FR-008a).
3. **US2 fit/optimizers** (P1): `cobraFitGauss1` + createFitL/R + discretizeFPKM;
   `cobraFminunc` + BDCA/DCA; `cobraGa` + optGene.
4. **US6 tests** (P1): requirement changes and direct-call switches as each dependency lands; full
   suite run for SC-003 at the end.
5. **US3 regression** (P2): `cobraParseModelFormula`, `cobraBuildModelDesign` → `cobraLinearModel`, `cobraFitlm` →
   `cobraGeneralizedLinearModel`, `cobraFitglm` (IRLS, Firth, warnings) → performRegressions and
   the fitlm call sites; `cobraFitcsvm` + optimalScores.
6. **US4 figures** (P2): `cobraBoxplot`, `cobraOptimalLeafOrder` → `cobraClustergram`; HeatMap →
   `heatmap`; `gname` → data tips; bio_paint4Net drawing block; plotconfusion dead branch.
7. **US5 parallel** (P2): fastFVA guard; SteadyComPOAgr guard; testSteadyCom `parWorks`.
8. **US7 review** (P3) and polish: review, defects registry, SC-001 scan, coverage, receipt, commit.

## Complexity Tracking

No constitution violation. Two justified additions (Principle V): the model classes (required by
the maintainer's decision that user scripts reading `performRegressions`' models keep working)
and the formula/design helpers (shared by `cobraFitglm` and `cobraFitlm` instead of being
duplicated; public with their own tests per III-Naming).
