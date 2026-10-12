# Research: Tier-1 test coverage batch 2

Method: every candidate's source was read; each of the final 50 was called in MATLAB R2025a
(`matlab -batch`, toolbox initialised) with small hand-built input. The probe confirms the
function runs standalone with no model, solver, file, or MATLAB toolbox beyond base MATLAB.
Detailed behaviour per function (exact expected values) is recorded in each test's own
probe-then-write step during implementation, since expected values must be fixed together
with the assertions that use them.

## Eligibility decisions

| Outcome | Functions | Reason |
|---|---|---|
| Demoted, replaced | compareTwoSamplesStat | needs Statistics Toolbox |
| | normalizeDiet | loads fdTable.mat, depends on getDietEnergy |
| | parseSolverParameters | depends on CobraSolverState / initialized solver |
| | errorComputation2, errorComputation2_grad | call the C13 scorer, `save` a file, `pause` |
| | removeProblematicCharacters | non-ASCII source characters, encoding-dependent |
| Added (probed OK) | parseSBMLNotesField, logmod, InitialDuplo, cleanUpMetabolite_structure | pure string/number/struct |
| Added (conditional) | InitialBDCA | runs; raises its own error when `options.kin` is missing (testable branch) |
| Added (conditional) | searcher | iterative branch needs a 3-column cell database; the non-iterative branch needs a table with a `description` column; the first probe with a 2-column database errored, so the correct input shape is established at implementation |
| Excluded earlier | regulariseGroupIncidenceMatrix | its folder is named `new`, which `initCobraToolbox` removes from the path |
| Excluded earlier | createForestPlot, createVolcanoPlot, calculateSubsystemAbundance, readCD, retrieveMet, nullspaceLUSOLapply2Modes, Extended_rate_function, getMolecularWeight, sortAtomMappingIdx | plots, file input, mex/LUSOL, external tools, or function name differs from file name |

## Probe results that shape the tests (current behaviour, pinned not fixed)

- `StopCritBDCA` and `StopCritDuplo`: `Stopping_Crit == 1` references the undefined variable
  `nhxk` and errors (`MATLAB:UndefinedFunction`); the other cases work. Defect pinned.
- `InitialDuplo`: tests the field name `flag_\`x_error\`` (typo with backticks), so the
  `flag_x_error` option can never be set from `options`. Defect pinned.
- `buildRxnEquationsFromName`: for reversed-only reactions it assigns `products = educts`
  (an apparent swap that does nothing). Pinned. `buildRxnEquations` works on the toy model.
- `hyperlink`: `usejava('desktop')` is false under `-batch`/CI, so the HTML-link line is not
  reachable headless. Coverage exemption documented (GUI).
- `removeSmilesInchiKey`: the `generateSmiles`/`generateInchiKey` branches call an external
  InChI conversion tool; those lines are documented coverage exemptions; the remove-only
  branches are tested.
- `analyzeRxns` prints a progress bar (`showprogress`); `cleanUpMetabolite_structure` echoes the
  loop index; `Combination` prints for negative inputs. Console-noise exemptions.
- `getInchiData`, `editChemicalFormula`, `parseGPR`, `preparseGPR`, `parseMetNames`,
  `calcDist`, `numToFormattedString`, `findMatchingFieldEntries`, `gmscale`, `maxstar`,
  `reaction2sparse`, `solveLin`, `score_ridge`, `Combination`, `seperateTransposeJoinOE`,
  `compareConditions`, `calculateMetrics`, `createBIGraph`, `compareDiets`,
  `convertNutrientsToMmol`, `compareMaleFemale`, `checkInputData`, `mapMediumData2AGORA`,
  `convertIrrevFluxDistribution`, `reassignFwBwMatch`, `makeColorGradient`,
  `newCompsNewMets`, `removeDuplicateNames`, `evalObj`, `updateObj`, `Initialization`,
  `calculateBMR`, `getDataBases`, `parseSBMLAnnotationField(Rxn)`, `logmod`: probed, ran, and
  produced plausible results with small inputs.
- Suspected quirks to confirm in each test's probe step: `compareDiets` with
  `one2Two == false` multiplies a cell array by -1; `compareMaleFemale` uses `strmatch`
  (deprecated); `combineChildren` needs the `AndNode`/`OrNode`/`LiteralNode` classes (pure
  objects, no model).

## Decisions

- **Requirement-free**: all 50 open with `prepareTest()`; none declares a toolbox or solver.
- **Console noise**: documented, never suppressed with `evalc`.
- **Persistent/global state**: none of the 50 uses `persistent` or `global` (scanned and
  checked); tests still `clear` large variables.
- **Verification**: `runScriptFile` from `test/` plus `CodeCoveragePlugin.forFile` per
  function; the runner is a throwaway script kept outside the repo.
- **Expected values**: from source reading plus the probe; no first-run references (Tier 5
  not used).
- **Replacement policy**: a function found to need a model, file, solver or toolbox at
  implementation is replaced from the reserve list (probed first) and reported.
