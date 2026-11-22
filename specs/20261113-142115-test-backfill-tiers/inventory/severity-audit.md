# Severity consistency audit (T009a, 2026-11-15)

Rule (research R5): a documented input, option or argument that fails when used is `error` or
`unusable-option`; behaviour that contradicts the documented result (or the code's evident intent,
stated in a comment or in handling code that is never reached) on a valid input is `wrong-result`;
documentation that misdescribes something without changing what a caller gets is `cosmetic`; an
input the documentation does not allow is a `limitation` or no defect.

An independent reviewer read every `cosmetic`/`limitation` entry written in waves 01–13
(138 entries in 95 tests; `severity-audit-candidates.tsv`) and proposed 38 raises. Lead decisions:

## Raised (36 entries): the function is quarantined, or its entry corrected if already quarantined

Tested functions converted to the quarantine layout (20): getDefinedFieldProperties (2 entries),
calculateEPSILON, generateStructFunction (4), mapFormula, ReactionChecks (2), makeViolinPlots,
getEcosystemClusterDescriptor, findUpDownRegulatedGenes, calcdGHT, make3Dplot, AndNode, OrNode,
classifyMoieties, estimateMoietyFormulas, parseSolverParameters, parsave, readSimPhenyCMPD,
duplicates, balancecheck, addFluxFromFileWidthAndColor.

Already quarantined, header entry raised only (12): representativeMoiety, generatePanDatabase,
mgSimResCollect, dimensionalityReductionAndMultivariateAnalysis, performStatisticalAnalysis,
addAnnotations, transformFullXML2Map, plotEssentialRxns, getCobraSolverParams, getStatsOrganComp,
parseBridgeDb, findMetMatch.

Borderline raises accepted for consistency with earlier decisions (getCobraSolverParams: a header
that documents a result the code does not deliver is a defect even where the header is probably
stale): parseSolverParameters, plotEssentialRxns, getStatsOrganComp, parsave, readSimPhenyCMPD,
duplicates, balancecheck, addFluxFromFileWidthAndColor, classifyMoieties, estimateMoietyFormulas,
ReactionChecks, parseBridgeDb, findMetMatch.

## Kept (2 entries)

- getNutritionDatabaseFile, `('usda', 'foodItems')` not found: the function builds the file name
  that `createUSDAdatabase` writes; the mismatch is the name of the file shipped in the `papers`
  submodule, not the function's behaviour. Stays `limitation`.
- All other 100 KEEP verdicts of the reviewer accepted.

## Reach of the new quarantines (constitution 1.8.1)

- getDefinedFieldProperties: both defects need `SpecificFields` (an undefined name, or the option
  combined with `Descriptions`/`DataBaseFields`). The only caller that passes `SpecificFields` is
  `createEmptyFields`; see `quarantine-seeds.tsv` for which of its callers can pass an undefined
  name.
- AndNode, OrNode: `deleteLiteral` with a numeric id; every caller passes text (`num2str`, literals
  from `getLiterals`): seed NONE.
- duplicates: multi-column input; the only such caller is the excluded
  `regulariseGroupIncidenceMatrix`.
- Default seed (every call reaches the defect) for the rest; measured before applying: calcdGHT
  blocks 4 thermo functions, mapFormula 2, the others 0 pending rows. addFluxFromFileWidthAndColor
  is reached by `visualizeFluxFromFile` (tested in wave 13): its test is removed and the row
  blocked (FR-009).
