# Known defects that need maintainer attention

**Feature**: 20261102-140321-tier1-safe-defect-fixes · **Date**: 2026-11-02

This document lists the known defects that were NOT fixed by this feature because a fix would
change results produced by existing toolbox code, tutorials or papers (spec table B), and the
problems found during the impact analysis that are not in the defect registry. Each entry says
where the defect is reached, what a fix would change, whether published results are affected,
why it cannot affect the Tier-2 (model-manipulation) tests, and what is recommended.

**Method.** A static caller graph over `src/`, the tutorials (`.m` and the code cells of `.mlx`)
and `papers/`; reading of each call site to see whether the defect's trigger can occur there;
and MATLAB R2025a runs comparing the current function with a one-line fix placed first on the
path (Gurobi 11 for LP, `pdco` for exponential-cone problems; the MOSEK licence of the test
machine had expired). Model sets: `ecoli_core_model`, `iAF1260`, `iJO1366`, 14 AGORA models,
`Recon1.0model`, `Recon3DModel_301` from `test/models/mat`, and Recon 2.2 from BioModels.

**Tier-2 exposure, in general.** Model-manipulation functions (`addReaction`, `removeRxns`,
`removeGenesFromModel`, `changeGeneAssociation`, ...) reach defective code only through
`checkPresentFields` and `getDefaultValue` (both fixed by this feature), `parseMetNames` (which
fails visibly) and `removeFieldEntriesForType` (which raises an error for a model with `grRules`
but no `rules`; see below). `mergeTwoModels` calls `checkDuplicateRxn` with the method `'S'`,
which neither `checkDuplicateRxn` defect affects. None of the entries below can SILENTLY change a
Tier-2 result; an error stops the test instead of producing a wrong reference value.

**Registry after this feature.** `test/known-defects.md` lists 33 defects in 28 functions: the
28 rows of spec table B, one defect moved from table A during implementation
(`compareBounds2Models`), one defect found during implementation (`coreMetRxnAnalysis`), and
three defects that were already written in test headers but were not in the registry because
their headers lacked the `- ` before `DEFECT:` (`checkDuplicateRxn` ×2,
`removeFieldEntriesForType`); this feature repaired those two headers.

## Summary

| Priority | Item | Severity | Changes results today in |
|---|---|---|---|
| 1 | `combineChildren` | wrong-result | E-Flux (default) and any `mapExpressionToReactions(..., minSum=true)` on AGORA and Recon models |
| 1 | `processConcConstraints` (4 entries) | wrong-result, error, unusable-option, cosmetic | entropic FBA `fluxConc`/`fluxConcNorm` with MOSEK |
| 1 | `bilinearDecomposition` | error (wider than registered) | `checkRankFR`, `checkModelProperties` |
| 1 | `gapfillRefinedGenomeReactions` | wrong-result | DEMETER (`tutorial_demeter`) |
| 1 | New problem N6: 2018 transcriptomic-decisions paper | not registered | `papers/2018_DecisionsTranscriptomicIntegration` |
| 2 | `getDataBases` (2 entries) | wrong-result, error | every SBML import (no change measured) |
| 2 | `getInchiData` (negative charge) | wrong-result | `generateChemicalDatabase`, `compareInchis` |
| 2 | `getMolecularWeight` (hydrogen) | wrong-result | `addThermoToModel` training-data balancing |
| 2 | `selectGeneFromGPR` | wrong-result | `gene_used` output with `minSum=true` |
| 2 | `convRevSamples` + new problem N4 | wrong-result | `sampleCbModel` with the ACHR sampler |
| 2 | `checkFormulae` | limitation | DEMETER `removeFutileCycles`, mgPipe `createPanModels` |
| 2 | `parseMetNames` | limitation | `extractCompModel`, `extractMetModel`, exploration functions |
| 2 | `setConstraintsIrrevModel` | wrong-result | `OptKnock` with reaction IDs of 1-2 characters |
| 2 | `setMosekParam` (strict) | wrong-result | MOSEK solves with `param.strict` |
| 2 | `updateStructData` | limitation | solver parameter merging |
| 2 | `editChemicalFormula` | cosmetic | chemoinformatics formula strings |
| 3 | `calculateMetrics`, `compareConditions`, `isValidVmhID`, `convertOld2NewHMDB`, `charpos`, `countC`, `makeColorGradient`, `addFluxWidthAndColor`, `searcher` | various | narrow or interactive paths |
| 2 | `checkDuplicateRxn` ('FR' method) | wrong-result | tutorials `modelManipulation`, `reconToFBAmodel`, `modelSanityChecks`; 2025 bioenergeticPD paper |
| 2 | `removeFieldEntriesForType` | error | gene removal from models with `grRules` but no `rules` (Tier-2 path, visible error) |
| 2 | `coreMetRxnAnalysis` (found during implementation) | wrong-result | `XomicsToModel`, `modelExtraction` |
| 3 | `checkDuplicateRxn` ('rxnAbbr' method), `compareBounds2Models` (missing reactions) | wrong-result, error | user calls only |
| — | New problems N1-N3, N5, N7-N16 | not registered | see section "New problems" |

## Priority 1

### combineChildren — Identical generated clauses delete the earlier clause
- Severity: wrong-result
- Reached from: `GPRparser(model, true)` (conversion of GPR rules to conjunctive normal form)
  ← `mapExpressionToReactions(model, data, minSum=true)` ← `applyEFluxConstraints` (whose
  default is `minSum = true`), `efmEnrichmentAnalysis`, `diffexprs2rxnFBS` option. No tutorial
  calls it with `minSum = true`.
- Effect of a fix (measured; fix = an identical clause counts as existing, not as superseded):
  the conjunctive form differs in 1-11 reactions of each of 14 AGORA models, 17 reactions of
  Recon1, 15 of Recon3D, 0 of `ecoli_core_model`, `iAF1260`, `iJO1366`. On 200 random gene
  states the original form disagrees with the rule every time it differs; the fixed form never
  does. The original form is often empty, so the reaction gets no expression value (NaN).
  Reaction expression changes by up to 866% (AGORA), 99% (Recon1), 86% (Recon3D). Triggering
  rules are the redundant shapes DEMETER writes, e.g. `(g1 and g1) or g2`, `g or (g and g)`, and
  `a or b or (a and b)` in Recon (`AHEXASEly`, `ALCD22_D`).
- Published results affected: present since 2018. The only published user found is
  `papers/2018_DecisionsTranscriptomicIntegration` (Recon 2.2): 3 reactions with a different
  form, 1-2 reactions per tissue change value (median 78%). No tutorial is affected.
- Tier-2 exposure: none; no model-manipulation function converts rules to conjunctive form.
- Recommendation: fix (one line in `combineChildren.m`, verified above) in a dedicated feature
  with a release note that E-Flux and min/sum expression mapping change for models with
  redundant GPR rules. Not urgent for a community-wide notice.

### processConcConstraints — The default row selection indexes the first row repeatedly
- Severity: wrong-result
- Reached from: `entropicFluxBalanceAnalysis` only when `param.entropicFBAMethod` is
  `fluxConc` or `fluxConcNorm` (e.g. `modelMultipleObjectives`, `modelPredictiveCapacity`).
- Effect of a fix (measured; `model.pp = true(m,1)` instead of `ones(m,1)`): the external
  stoichiometric matrix B returned to the solver is wrong whenever the model has no `pp` field:
  on E. coli core it is 72×21 with 0 non-zeros (every row is metabolite 1) instead of 43. The
  default `fluxes` method never calls this function: the tutorial set-up and the pinned
  reference of `testEntropicFluxBalanceAnalysis` are bit-identical with and without the fix.
- Published results affected: no; introduced on 2026-02-08 (commit 037ff70962), after the
  papers that use entropic FBA. Concentration-mode runs on current `develop` with MOSEK are
  affected (with `pdco` they error, see N2).
- Tier-2 exposure: none.
- Recommendation: fix soon, together with the three entries below, in one feature that also
  adds a `fluxConc` test (needs a working MOSEK licence).

### processConcConstraints — The parameter printLevel is required although it is documented as optional
- Severity: error
- Reached from: the same concentration path, when `param.printLevel` is absent.
- Effect of a fix: a default of 0; only removes an error.
- Published results affected: no. Tier-2 exposure: none.
- Recommendation: fix with the entry above (kept here so the function is changed once).

### processConcConstraints — The case dxReplacement always stops with an error
- Severity: unusable-option
- Reached from: `param.externalNetFluxBounds = 'dxReplacement'`, which is also the default when
  `model.dcl`/`model.dcu` exist.
- Effect of a fix: needs the intended formulation (the code says "revise how net initial and
  final conc bounds are dealt with"); a design decision by the author.
- Published results affected: no. Tier-2 exposure: none.
- Recommendation: decide the formulation with the author; until then, document the option as
  unavailable.

### processConcConstraints — Documented defaults for the concentration unit and the maximum concentration differ from the code
- Severity: cosmetic (registered), but the code default `10-3` evaluates to 7, which is used
  as a concentration unit; a fix to 1e-3 changes concentration-mode results.
- Reached from: the concentration path when `param.concUnit`/`param.maxConc` are absent.
- Published results affected: no. Tier-2 exposure: none.
- Recommendation: decide whether code or header is right (very likely `1e-3`), then fix with
  the entries above.

### bilinearDecomposition — A lone reaction with one substrate and three products gives inconsistent sizes
- Severity: error (registered); the underlying defect is wider.
- Reached from: `checkRankFR`, `checkModelProperties`.
- Effect of a fix: in the branches "0 substrates, 3 or more products" and "1 substrate, 3 or
  more products" the real reaction produces the fake metabolite `nMet+x+1` while every fake
  reaction consumes `nMet+x` (the convention of all other branches). Because `A = [I 0]` hides
  fake metabolites, the built-in check `S = A*B*C` passes and the defect only errors when the
  index exceeds the matrix. Correcting the index changes `B` for inputs that succeed today.
- Published results affected: unknown; FR-rank results depend on `B`.
- Tier-2 exposure: none (topology analysis, not model manipulation).
- Recommendation: fix in the checkModelProperties scalability feature or a dedicated one, with
  a test that checks the fake-metabolite chain, not only `S = A*B*C`.

### gapfillRefinedGenomeReactions — The first gap-filled row overwrites the last annotation row
- Severity: wrong-result
- Reached from: DEMETER `prepareInputData` when `spreadsheetFolder` is given, as in
  `tutorial_demeter`.
- Effect of a fix (assessed from the code; end-to-end run not possible on the test machine,
  which lacks the Statistics Toolbox needed by `tdfread`): exactly one row, the last genome
  annotation row of the input, is lost per run; the fix (`cnt = size(...,1) + 1`) keeps it.
- Published results affected: the DEMETER tutorial output; whether AGORA2 was built with this
  code version is unknown.
- Tier-2 exposure: none.
- Recommendation: fix with a DEMETER maintainer (one character), and check whether the lost
  row matters for AGORA2.

## Priority 2

### getDataBases — Mixed matching and non-matching resources return nothing
- Severity: wrong-result
- Reached from: every SBML import (`readSBML` → `parseCVTerms`).
- Effect of a fix (measured on 6 SBML models of `test/models/xml` and the fastGapFill test
  model): no field changes. A model whose annotation mixes identifiers.org/urn:miriam URIs with
  other URIs would gain the annotations that are dropped today.
- Published results affected: none found. Tier-2 exposure: none (Tier-2 tests load `.mat`).
- Recommendation: fix with the entry below, with an SBML test file that has mixed resources.

### getDataBases — Third output unassigned when nothing matches
- Severity: error
- Reached from: as above, when three outputs are requested.
- Effect of a fix: removes an error. Kept with the entry above so the function changes once.
- Recommendation: fix with the entry above.

### getInchiData — Negative charge layer gives NaN
- Severity: wrong-result
- Reached from: `generateChemicalDatabase` (hydrogen count: `numList(hBool) + netCharge`) and
  `compareInchis` (charge check).
- Effect of a fix: InChIs with a `/q-` layer get a numeric charge instead of NaN, which changes
  hydrogen counts and charge checks for such metabolites.
- Published results affected: unknown. Tier-2 exposure: none.
- Recommendation: fix with a chemoinformatics maintainer and re-run `generateChemicalDatabase`
  on a reference set.

### getMolecularWeight — Hydrogens are lost for an InChI whose formula starts with H
- Severity: wrong-result
- Reached from: `addThermoToModel` → `balanceReactionsInTrainingData` (the `old/` training
  folder stays on the path).
- Effect of a fix: water and other H-first formulas get the correct molecular weight (18 rather
  than 16 for water), which can change training-data balancing.
- Published results affected: unknown. Tier-2 exposure: none.
- Recommendation: fix with the thermodynamics maintainers.

### selectGeneFromGPR — With minSum the reported gene does not belong to the selected alternative
- Severity: wrong-result
- Reached from: `mapExpressionToReactions(..., minSum=true)`.
- Effect of a fix: only the `gene_used` output changes; reaction expression values and
  significance are already correct.
- Published results affected: only reported gene labels. Tier-2 exposure: none.
- Recommendation: fix together with `combineChildren`.

### convRevSamples — Bounds of a reverse-only reaction are not exchanged correctly
- Severity: wrong-result
- Reached from: `sampleCbModel` with the ACHR sampler (not the default; tutorials use CHRR),
  for reactions whose identifier ends in `_r`.
- Effect of a fix: only the bounds of the returned `modelSampling` change; the samples are
  already negated correctly. See also N4.
- Published results affected: no. Tier-2 exposure: none.
- Recommendation: fix together with N4 in `sampleCbModel`.

### checkFormulae — Elements other than C, H, O, P, S, K, Na and N are ignored
- Severity: limitation
- Reached from: DEMETER `removeFutileCycles`, mgPipe `createPanModels`, applied to reaction
  equation strings to decide whether a periplasmic variant matches the database.
- Effect of a fix (measured on 1693 database pairs): no genuine change; one artefact (the
  equations of `COF420H` are identical but a widened element list counts `F` in `coF420`).
- Published results affected: no. Tier-2 exposure: none.
- Recommendation: leave as is; if changed, compare metabolite formulas rather than equation
  strings.

### parseMetNames — Mixed or longer compartment notations are not parsed
- Severity: limitation
- Reached from: `readCbModel` (SimPheny format only), `extractCompModel`, `extractMetModel`,
  `findCarbonRxns`, `findNeighborRxns`, `findTrspRxnFromMet`, `findTransRxns`,
  `outputNetworkCytoscape`.
- Effect of a fix: lists with mixed or multi-character compartments would be parsed instead of
  returning empty compartments; `extractCompModel` would then return a model instead of `[]`
  with a warning.
- Published results affected: no. Tier-2 exposure: none silent (failure is visible).
- Recommendation: fix in a Tier-2 follow-up together with the tests of `extractCompModel`.

### setConstraintsIrrevModel — Reactions with names of one or two characters get the wrong sign
- Severity: wrong-result
- Reached from: `OptKnock`.
- Effect of a fix: constraint values keep their sign for reactions with 1-2 character IDs
  (toy models only).
- Published results affected: no. Tier-2 exposure: none (OptKnock is Tier 3).
- Recommendation: fix with an OptKnock test on a toy model.

### setMosekParam — The strict option never switches MOSEK to a free solve form
- Severity: wrong-result
- Reached from: `solveCobraLP`, `solveCobraQP`, `solveCobraEP` with MOSEK when the user sets
  `param.strict`; no toolbox code sets it.
- Effect of a fix: MOSEK would solve in free form instead of primal form for such calls.
- Published results affected: no. Tier-2 exposure: none.
- Recommendation: fix with a MOSEK-licensed test (solver layer, Principle IV).

### updateStructData — A structure update is ignored when the original field is not a structure
- Severity: limitation
- Reached from: parameter merging in `solveCobraLP/QP/MILP/MIQP/NLP`.
- Effect of a fix: a solver parameter given as a structure where the default is not would be
  applied instead of silently dropped.
- Published results affected: unknown, unlikely. Tier-2 exposure: none.
- Recommendation: fix with a solver-layer test.

### editChemicalFormula — Element with zero atoms stays in the formula
- Severity: cosmetic
- Reached from: `generateChemicalDatabase`, `compareInchis`, `metDatabaseStatus`.
- Effect of a fix: formulas such as `C2H6O0` become `C2H6`, which changes string comparisons
  of formulas downstream.
- Published results affected: unknown. Tier-2 exposure: none.
- Recommendation: fix with `getInchiData`.

### checkDuplicateRxn — the 'FR' method removes the last reaction of a group after testing the first two
- Severity: wrong-result (registered in 2026-10-22 but missing from the registry until this
  feature repaired the header format).
- Reached from: `checkDuplicateRxn(model, 'FR', ...)` in `tutorial_modelManipulation`,
  `tutorial_reconToFBAmodel`, `tutorial_modelSanityChecks`, `performSanityChecksonRecon`,
  `papers/2025_bioenergeticPD/functions/reconToFBAmodel_FAD.m`, `generateFullRowRankFR`. The
  default method is `'S'`.
- Effect of a fix: only for groups of three or more reactions that are equal up to scale and
  direction; the reported duplicate would be one of the kept reaction.
- Published results affected: possibly, in the tutorials and paper above, only if such groups
  exist in the models they use; not measured.
- Tier-2 exposure: none (`mergeTwoModels` uses `'S'`).
- Recommendation: measure on Recon3D (count groups of 3 or more) before fixing; fix with a test.

### removeFieldEntriesForType — removing genes from a model that has grRules but no rules field fails
- Severity: error (registered 2026-10-22, missing from the registry until this feature).
- Reached from: every gene removal through `removeFieldEntriesForType` (`removeGenesFromModel`,
  `removeUnusedGenes`, `updateGenes`, ...) on a model without `model.rules`.
- Effect of a fix: such calls return a model instead of an error.
- Published results affected: no (the call errors). Tier-2 exposure: VISIBLE ONLY — a Tier-2
  test on a model without `rules` would error; Tier-2 tests use models with `rules`.
- Recommendation: fix early in the Tier-2 work (it is a model-manipulation function).

### coreMetRxnAnalysis — A given list of deleted metabolites is discarded when the old model is empty and no deleted reactions are given
- Severity: wrong-result (found and registered during this feature).
- Reached from: `XomicsToModel`, `modelExtraction` (they pass `deletedRxns`/`deletedMets`).
- Effect of a fix: the deleted-metabolite list passed by the caller would be used; this changes
  results when a "deleted" metabolite is still in the model, and a row/column shape mismatch
  would start to error.
- Published results affected: unknown. Tier-2 exposure: none.
- Recommendation: fix with an XomicsToModel maintainer.

## Priority 3

### calculateMetrics — Bray-Curtis wrong for a single taxon
- Severity: wrong-result. Reached from: `runMars` (Persephone). Effect of a fix: Bray-Curtis
  values for a one-taxon table. Published results: no. Tier-2: none.
- Recommendation: fix with a Persephone maintainer.

### compareConditions — Sample-point count taken from the first metabolite of the first list
- Severity: limitation. Reached from: `rumba`. Effect of a fix: comparisons when metabolites
  have different numbers of sample points. Published results: unknown. Tier-2: none.
- Recommendation: fix with a sampling test.

### isValidVmhID — Identifiers with surrounding blanks are rejected although they are trimmed for the other checks
- Severity: limitation. Reached from: `createBLSdatabase`, `createFridaDatabase`,
  `createUSDAdatabase`, `getDietEnergy`. Effect of a fix: blank-padded identifiers become
  valid. Published results: unknown. Tier-2: none.
- Recommendation: fix with the nutrition toolbox maintainers.

### convertOld2NewHMDB — Identifiers of 12 or more characters give an empty result
- Severity: limitation. Reached from: `checkAbbrExists` (metaboAnnotator). Effect of a fix:
  long identifiers returned instead of empty. Tier-2: none.
- Recommendation: fix with the metaboAnnotator maintainers.

### charpos — The letters i and j count as digits
- Severity: wrong-result. Reached from: modelBorgifier `cleanTmodel`, `mergeTrxns`. Effect of
  a fix: identifier clean-up in model merging. Tier-2: none.
- Recommendation: fix with a modelBorgifier test.

### countC — Elements whose symbol starts with C are counted as carbon
- Severity: wrong-result. Reached from: modelBorgifier `reactionCompareGUI` (interactive
  matching score). Tier-2: none.
- Recommendation: fix with `charpos`.

### makeColorGradient — A channel that is equal in both colours becomes 0
- Severity: wrong-result. Reached from: ReconMap `buildFluxDistLayout`. Effect of a fix: map
  colours. Tier-2: none.
- Recommendation: fix; visual only.

### addFluxWidthAndColor — Map reactions without flux data get no colour entry
- Severity: limitation. Reached from: `visualizeFluxTimeseriesFromFile`. Effect of a fix: map
  colours. Tier-2: none.
- Recommendation: fix; visual only.

### searcher — Non-iterative search type cannot run
- Severity: unusable-option (moved from table A during planning, FR-007).
- Reached from: `vmhFoodFinder`.
- Effect of a fix: the cumulative branch reads `database` as a table (`database.description`,
  `database{...,3}`) and then as a cell array (`database(:,1)`), and its exclusion filter edits
  `selection` instead of `totGroup`; the intended database format cannot be determined.
- Published results affected: no (the branch always errors). Tier-2: none.
- Recommendation: the author decides the database format; then fix and test.

### checkDuplicateRxn — the 'rxnAbbr' method returns the unique reactions as the duplicates
- Severity: wrong-result. Reached from: no toolbox code, tutorial or paper uses `'rxnAbbr'`.
  Tier-2: none. Recommendation: fix with the 'FR' entry.

### compareBounds2Models — Reactions missing from a model are collected in a character matrix, which fails for names of different lengths
- Severity: error (moved from table A during implementation, FR-007): returning a cell array
  would change the output type for calls that work today (`''`, a char row, or a char matrix of
  equal-length names). No caller. Tier-2: none.
- Recommendation: decide whether a type change of this output is acceptable; then use `{}` and
  `[R1_missing; R12(i)]`.

## New problems (not in the registry)

### N1 — prepareFastGapFill errors on the tutorial example models
- Location: `src/reconstruction/fastGapFill/prepareFastGapFill.m` lines 157 (`iTZ479_v2`,
  `iJN678_Published`) and 178 (`IEC1907`): "Matrix index is out of range for deletion".
- Reproduction: `cd tutorials/reconstruction/fastGapFill/example`, load a model, set exchange
  bounds to ±100, call `prepareFastGapFill(model)`.
- Effect: the fastGapFill tutorial cannot be reproduced with the current code.
- Recommendation: fix in a fastGapFill feature with a test on one example model.

### N2 — entropic FBA concentration methods error with pdco
- Location: `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` line 1781
  ("Unrecognized function or variable 'z_ve'"); `z_ve` is set only in the MOSEK branches.
- Reproduction: `entropicFluxBalanceAnalysis(model, struct('solver','pdco','entropicFBAMethod','fluxConc'))`
  on a stoichiometrically consistent E. coli core.
- Effect: `fluxConc`/`fluxConcNorm` work only with MOSEK.
- Recommendation: fix with the `processConcConstraints` entries.

### N3 — numAtomsOfElementInFormula errors on MATLAB R2025a
- Location: `src/reconstruction/modelGeneration/massBalance/numAtomsOfElementInFormula.m` line
  51: `formula(indZero-1:indZero)` with a vector `indZero` raises "Colon operands must be real
  scalars" (older releases used the first element with a warning).
- Effect: 15 of 1693 reaction pairs compared by DEMETER `removeFutileCycles` / mgPipe
  `createPanModels` make those functions error.
- Recommendation: fix (handle each zero position) with a test on a formula with two zeros.

### N4 — sampleCbModel (ACHR) undoes its own protection of reactions ending in `_r`
- Location: `src/analysis/sampling/sampleCbModel.m` lines 147-150: identifiers ending in `_r`
  are renamed to `_bladibla` before `reduceModel` and renamed back before `convRevSamples`,
  which then strips `_r` and negates them.
- Effect: such reactions are renamed and flipped in the ACHR output.
- Recommendation: rename back after `convRevSamples`; fix with `convRevSamples`.

### N5 — GPRparser errors on Recon2.v04 from test/models
- Location: `Node/getFunctionalGeneSets` line 288 (`cellfun(@str2num, ...)` on a literal that is
  not a scalar), even after regenerating `rules` from `grRules`.
- Effect: `mapExpressionToReactions` cannot be used on `test/models/mat/Recon2.v04.mat`.
- Recommendation: find the offending rule and either fix the model file or make the parser
  report the rule.

### N6 — papers/2018_DecisionsTranscriptomicIntegration passes minSum as text
- Location: `papers/2018_DecisionsTranscriptomicIntegration/Code_Preprocessing.m` (calls with
  `'false'` and `'true'`).
- Effect (measured on Recon 2.2 with the paper's HPA data): MATLAB treats the text `'false'` as
  true, so the GM1 (min/max) arm runs the GM2 (min/sum) path: GM1-as-written equals
  `minSum = true` and differs from `minSum = false` in 1419 of 7785 reactions (first tissue).
  The toolbox handled `minSum` the same way in December 2018.
- Published results affected: possibly the GM1/GM2 comparison of the paper, if its figures were
  produced by this script.
- Recommendation: ask the authors (Richelle, Lewis) whether the published figures came from this
  script; fix the script to pass logical values.

### N7 — Stale registry line numbers
- `processConcConstraints`, "The default row selection indexes the first row repeatedly", lists
  lines 116-118; the code is now at lines 137-138 (header edits in commit 82cb11eaa0). The
  entry is otherwise current. Recommendation: correct the test header when the function is fixed.
- Entries fixed by this feature also had stale lines (`augmentBOF`, `findRxnMatch`, `cdv2idv`,
  `mapExpressionToModel`, `sortAtomMappingIdx`, `calcSampleDifference`,
  `setSimulationConstraints`); two were already fixed upstream before this feature
  (`createBIGraph` by feature 029, `compareModels` by commit 231b9f548b), so their entries were
  stale. The registry is a snapshot (Constitution III-Defects); re-check entries before use.

### N8 — Conversion of GPR rules to conjunctive form grows exponentially
- Location: `OrNode.convertToCNF` / `combineChildren`.
- Effect: 0-25 rules per model would exceed 512 clauses; the uncapped conversion of Recon1 did
  not finish in about 15 minutes, so E-Flux's default `minSum = true` is impractical on such
  models.
- Recommendation: consider computing min/sum expression directly from the rule tree instead of
  through the conjunctive form.

### N9 — Two test headers were not in the registry format
- `testCheckDuplicateRxn.m` and `testRemoveFieldEntriesForType.m` (feature
  20261021-112509-recon-ci-scalability) wrote `DEFECT:` without the leading `- `, so the registry
  generator failed for the whole repository on `upstream/develop`. Repaired by this feature
  (format only).

### N10 — compareBounds2Models leaves R12_bounds unassigned
- When no bound is identical in the two models, `R12_bounds` is never initialised and the call
  errors ("output R12_bounds not assigned"). No caller. Recommendation: initialise to `{}`.

### N11 — setSimulationConstraints switches all warnings off while it runs
- Fixed by this feature: the caller's warning state is now restored on return. The function still
  runs `warning off` internally, against Constitution VII-B. Recommendation: remove the blanket
  `warning off` and silence only specific identifiers if any are known to be noise.

### N12 — projectOntoSubspace compares vnet(colBool) with the full vf and vr
- With a `colBool` that selects some columns, the net-flux sanity check compares vectors of
  different length: it errors, or silently broadcasts when one column is selected. No caller.
  Recommendation: compare `vnet(colBool)` with `vf(colBool) - vr(colBool)`.

### N13 — assignQualDir: a reaction with lb < 0 and ub = 0 gets 0
- The header defines -1 for reactions irreversible in the reverse direction; `lb < 0, ub = 0`
  returns 0 and the existing test asserts 0. No caller. Recommendation: decide the intended
  value and align header, code and test.

### N14 — createBIGraph has two test files
- `test/verifiedTests/analysis/testReactingMoieties/testCreateBIGraph.m` and
  `test/verifiedTests/analysis/testTopology/testCreateBIGraph.m` violate Constitution III-Naming
  (one test file per function); `which('testCreateBIGraph')` resolves to the first.
  Recommendation: merge the two files.

### N15 — Unchecked verifyCobraFunctionError calls
- `testAssignQualDir.m` and `testCalcSampleDifference.m` call `verifyCobraFunctionError` without
  `assert(...)`, so those checks can never fail. Recommendation: wrap them in `assert`.

### N16 — sortAtomMappingIdx declares another function name
- The file `sortAtomMappingIdx.m` declares `sortAtomMappingIndexes` (MATLAB dispatches by file
  name, so calls work). Recommendation: make the names equal, as was done for
  `convertATPflux2StepNumer`.
