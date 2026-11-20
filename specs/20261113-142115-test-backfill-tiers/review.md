# Independent review (T021, research R9), 2026-11-17

## Method

Codex was tried first. The account rejects the configured model ("The 'gpt-5.5' model is not supported
when using Codex with a ChatGPT account"). So, as R9 provides, the review used seven reviewer agents
that got only the code and the tests (`inventory/review/review-brief.md`). They were told not to read
the ledger, results, confirmations or `test/known-defects.md`, and not to run MATLAB.

- Six reviewers read every QUARANTINED test: 258 tests in lists of 43 (`inventory/review/quarantine-1..6.txt`).
  They judged each header entry against the code and the severity rule.
- One reviewer read a sample of TESTED tests: one per source area, 40 tests in all
  (`inventory/review/tested-sample.txt`, drawn with seed 20261117).
- There are no Tier 5 references, because no Tier 4/5 row was testable.

The verdicts are in `inventory/review/*.jsonl`. Confirmed findings were reproduced in MATLAB by
resolution helpers (`inventory/review/resolution-brief.md`, `inventory/results/review-revisions-*.jsonl`).
The edits that changed only header severities are listed in `inventory/review/header-edits.json`.
Every changed test was re-run with coverage (`inventory/coverage/review-revisions.jsonl`; all
14 passed, nothing was left behind, and `--verify-coverage` found 0 problems).

## Quarantined tests: 469 entries in 258 tests

| Verdict | Entries |
|---|---|
| AGREE | 451 |
| Different severity | 15 |
| Not a defect | 1 |
| Unclear | 2 |

For 256 of the 258 functions, at least one entry that quarantines the function was AGREE.

Resolutions:

- **All 15 severity changes accepted** and applied to the headers. Raised to `wrong-result`: retrieveModelStats,
  compareSampleTraj, readCbTmodel, rankFeaturesByIncidence and addFluxFBA (two entries). Raised to
  `unusable-option`: rMTAsaveInExcel. Raised to `error`: plotFRresults, lrsReadRay, readGeneRules and
  pHbalanceProtons. Lowered to `limitation`: findMetMatch. Lowered to `cosmetic`:
  webCGMtoTabDelimitedFile and writeLPProblem. None of these changes a quarantine decision.
- **printFluxBounds:** the "fixed-point format" entry was removed. The `& 0` on line 37 switches that
  branch off on purpose, and no format is documented. The function stays quarantined.
- **makeModelPropertiesTable:** the reviewer was right. Its documented input is the output of
  checkModelProperties, which always sets `balancedRxnBool`, so the entry is a `limitation`. The
  function was un-quarantined, and a full test was written: every value worked out by hand, a real
  checkModelProperties run as a cross-check. Writing it exposed a separate `error`, reproduced in
  MATLAB: a `resultsDirectory` without a trailing separator cannot be loaded (line 37). This is rated
  the same as in makeFRresultsTable, so the function is quarantined again on that defect. The full
  test is kept at `inventory/review/testMakeModelPropertiesTable.full.m.txt` and can be restored
  when line 37 is fixed. No `src/` function calls it.
- **maxEntConsVector (unclear, kept):** the reviewer accepted the behaviour but questioned whether
  the result needs to be accurate. The lead kept the quarantine. The header documents the maximum-entropy
  vector, and on `[-1; 1]` the function returns 1.228 where the maximiser is 0.990. The reviewer also
  found that `pdcoObj` line 74 computes Σ(x log x − x²), while its gradient and Hessian belong to
  Σ(x log x − x). This was added as a `wrong-result` entry, observed by reading.
- **verifyPoints (unclear, kept):** reading cannot decide it, but the writer reproduced it in MATLAB.
  The reviewer notes that the entry's title over-generalises.

## Tested sample: 40 tests

| Verdict | Tests |
|---|---|
| OK | 27 |
| WEAK | 12 |
| WRONG | 1 |

Each finding was reproduced in MATLAB, with stand-ins where an external program or another platform
was the only obstacle:

| Function | Outcome |
|---|---|
| KLdistance (WRONG) | QUARANTINED, `wrong-result`: the two densities are compared on separate grids, so shifted or scaled copies give a distance of about 1e-30. The old test's reference values repeated the same mistake. |
| generateMexFastFVA | QUARANTINED, `wrong-result`: line 139 passes the literal `CFLAGS="\$CFLAGS"`, so the version flag the code works out never reaches mex. CPLEX 12.10 being read as older than 12.8 is a `limitation`. |
| classifyRxns | QUARANTINED, `error`: the defaults documented under INPUTS are not implemented. rumba always passes all six inputs, so the seed is NONE. |
| directionalityStatsFigures | QUARANTINED, `wrong-result`: the by-DrG0 pie counts each reaction twice. The only call site is inside `if 0` (seed NONE). |
| makeFRresultsTable | QUARANTINED, three `error` entries: the default directory is personal, a directory without a trailing separator fails, and missing metadata fails. Its caller plotFRresults is already quarantined. |
| addKeyToKnownHostsCT | QUARANTINED, `error`: hostName `' '`, documented as meaning github.com, fails. |
| COBRArrowSolver | QUARANTINED, `wrong-result`: copies of the value object share one parameter map (seed NONE). |
| editCobraToolboxPath | QUARANTINED, `unusable-option`: on Windows the default basePath adds no folder. Reproduced with a stand-in `which`; seed NONE. |
| openBabelConverter | QUARANTINED: saving fails for every output except mol, a folder given as saveFileDir fails, and `'rxn'` returns `[]`. Both callers use none of these forms (seed NONE). |
| expa | QUARANTINED, `wrong-result`: the collapsed model loses its objective and its reactions are reordered. |
| cmpMet | QUARANTINED, `wrong-result`: substring matching reports species as present when they are absent. |
| hit_node | QUARANTINED, `unusable-option`: excNodesWithDeg is read and never applied. The caller, createMetIntrcNetwork, had a test before this feature. |
| generateInchiKeysSmilesFromInchiStrings | Not reproduced, so it stays TESTED. The test was strengthened to cover lines 44–64 with a stand-in obabel. |

Net effect:
- 12 functions moved from TESTED to QUARANTINED.
- No caller had to be blocked, and no test had to be removed.
- TESTED is now 201 and QUARANTINED 270.
- Coverage of `src/` without the generated c13 solvers is 27.4%, down from 27.8%: the quarantined tests no longer count, because `coverage_summary.py` now reads the review re-runs last.

## For the human review (not resolved here)

1. **Miss rate in TESTED tests.** 12 of the 40 sampled TESTED functions had a defect that should have
   quarantined them, mostly defects nobody had recorded. That is 30%, with a 95% interval of about
   17–47%. The other 173 TESTED functions were not reviewed, and at that rate roughly 30–80 more
   would be expected. A full review of every TESTED test is recommended before merging. It uses the
   same brief, about 5 reviewer agents, then reproduction of each finding.
2. **Quarantines that rest only on help text.** These quarantines rest only on help text that
   contradicts code which looks deliberate:
   - parseSolverParameters, which blocks many functions
   - changeCobraSolverParams
   - getElementalWeightMatrix
   - getDefinedFieldProperties (entry 1)
   - getEcosystemClusterDescriptor
   - readSimPhenyCMPD
   - transportReactionBool

   They are correct under the campaign's rule (R5: a header that documents a result the code does
   not deliver), but each would clear with a documentation fix.
   **Resolved 2026-11-20** (feature `specs/20261120-151023-doc-matches-code/`): the help of
   parseSolverParameters, changeCobraSolverParams, getElementalWeightMatrix,
   getEcosystemClusterDescriptor and transportReactionBool now matches their code, and all five
   are TESTED. getDefinedFieldProperties keeps an `error` entry. readSimPhenyCMPD stays quarantined:
   its entry rests on the code's own intent, not on help text. Fixing the parseSolverParameters
   and getCobraSolverParams help would unblock the most functions.
3. **Defects the reviewers report in already-quarantined functions.** These were not reproduced and
   are not in the registry:
   - write4ti2: the file is closed twice when `uni == 0`; `uni` has no default.
   - solveCobraLPCPLEXcard: with `osense = 1`, the non-card ILOG branch optimises in the wrong direction (line 331).
   - addExoMetToEFBA: it reads fields that are not documented as required.
   - BDF: `out.Xk` only ever holds `x0`.
   - calculateQuantitativeDiffs: its secretion labels contradict their own comments.
   - illustrate_ppp and performPPP: they disagree on the layout of `mets`.
   - producetSNEPlots: `perpl` can be undefined.
   - printSolutionGEM: with exactly 3 inputs, `itNum` is undefined.
   - mapMatch: the help names `seedMats` but the code uses `seedMets`, and the `noSeed` path is undocumented.
   - saveInputsOptForce: the help names the output file maxFluxes.mat, but the code writes maxFluxesW.mat.
   - getUnannotatedReactionsFromPubSeedSpreadsheets: a documented default is never implemented.
   - lrsWriteHalfspace: the help gives a default of 1 for positivity, but the code uses 0.
4. **Entries to look at again:**
   - compareSampleTraj, the `<name>_r` fallback (now `wrong-result`): the recorded trigger (`'r1_'`)
     does not reach that branch. The function is quarantined by other entries.
   - getQualitativeFluxStates: the second default-band trigger (2 against 2+1e-9) does not show the
     defect in double precision. The `delta = 0` case does.
   - solveCobraLPCPLEX_2018 and solveCobraLPCPLEXcard: the `csense` error depends on the MATLAB release.
     Older releases took the first element of a vector colon operand.
5. **Outside the campaign:**
   - getCobraSolverVersion (tested earlier) ignores its documented third input `rootPathSolver`.
   - `test/verifiedTests/base/testInstall/testAddKeyToKnownHosts.m`, a legacy test, still asserts on
     calls to addKeyToKnownHostsCT, which is now quarantined.

## Follow-up: every remaining TESTED test (T027–T028), 2026-11-17

The T021 sample found a missed quarantine in 12 of 40 TESTED tests, so the other 173 TESTED tests were
reviewed in the same way. Five reviewer agents had only the code and the tests
(`inventory/review/review-brief.md`, lists `inventory/review/tested-full-1..5.txt`, verdicts in
`tested-full-1..5.jsonl`). Four resolution helpers reproduced every finding in MATLAB R2025a
(`inventory/review/resolution-brief.md`; records in `inventory/results/review-full-a/b/c/e.jsonl`).
The lead confirmed each quarantine as second reader and set its reach in `inventory/quarantine-seeds.tsv`.

| Verdict | Tests |
|---|---|
| OK | 147 |
| WEAK | 5 |
| WRONG | 21 |

Outcome:

| Function | Outcome |
|---|---|
| findCarbonRxns | QUARANTINED, `wrong-result`: formulas Cl, Ca and CaC2O4 give carbon counts [1 1 1] instead of [0 0 2]. Every call reaches it. Its caller multiProductionEnvelope had a test before this feature, so it is not in the ledger (see below). |
| setSemiQuantConstraints | QUARANTINED, `error`: an empty `cond1_upt_higher` list with a non-empty secretion list fails at line 76. No callers. |
| TmodelStats | QUARANTINED, `wrong-result`: line 123 computes the inverse of the share. Only ids without an `[x]` suffix reach it. mergeModelsBorg's models always carry the suffix (seed NONE). |
| writeReactionsFromPubSeedSpreadsheets, getSubsystemPresence | QUARANTINED, `unusable-option`: a documented default folder is not implemented. The only callers always pass a folder (seed NONE). |
| plotSampleHist | QUARANTINED, `wrong-result` and `error`: a reaction held only as `<rxn>_r` is dropped before the code meant for it. A call where no requested reaction is in every model fails. |
| getNutritionDatabaseFile | QUARANTINED, `error`: `('usda','foodItems')` looks for `USDA2024_foodItems.mat`, but the shipped file is `USDAFoodItems.mat`. This reverses the wave's lead decision (limitation). Both callers are already BLOCKED. |
| calcOrganFract | QUARANTINED, `wrong-result`: the code names the organ 'Lungs', but the models and organ lists call it 'Lung', so Lung stays at 536 g at any weight. |
| setDietConstraints | QUARANTINED, `error`: numeric flux values, which the header allows, fail in str2num. No src caller passes them (seed NONE). |
| convertCbModelToCNAModel | QUARANTINED, `error` and `wrong-result`, in the external CNAcobra2cna (lines 36-43): names longer than the number of metabolites cause an index error. |
| printFRdependencies | QUARANTINED (from WEAK), `wrong-result`: on real checkRankFR output it lists a dependent row as dependent on itself and among the independent rows. |
| model2xls | QUARANTINED, `error`: the documented 3-argument call fails at line 173. writeCbModel always passes 4 (seed NONE). |
| comparePaths | QUARANTINED, `wrong-result`: sys.path entries with a blank are misreported. Seed: initPythonEnvironment, already QUARANTINED. |
| getCobraSolverVersion | QUARANTINED, `unusable-option`: the documented `rootPathSolver` is never used, as for hit_node. Only generateMexFastFVA passes it, and that function is already QUARANTINED. |
| configEnvVars | QUARANTINED, `error`: line 33 fails when ENV_VARS has no STATUS field, and the check meant for that case (`exist('ENV_VARS.STATUS','var')`) is always 0. initCobraToolbox always sets STATUS (seed NONE). |
| compareInchis | QUARANTINED, `wrong-result`: line 78 turns X into R, so 'C6H12O6X' never matches glucose. Seed: generateChemicalDatabase, which had a test before this feature. |
| metaboliteStructuresTable | QUARANTINED (from WEAK), `wrong-result`: the unescaped '.mol' pattern at line 39 turns 'amol.mol' into "". The full test, with a stand-in obabel, is kept at `inventory/review/testMetaboliteStructuresTable.full.m.txt`. |
| addFluxFBAdirectionAndColor | QUARANTINED, `wrong-result`: a zero flux vector gives NaN widths, and a ratio of exactly 1e-3 gets no band. |
| removeCDReactions | QUARANTINED, `wrong-result`: a species still catalysing a kept reaction is deleted, which the comment "delete isolated species" contradicts. |
| transformMap2XML | QUARANTINED, `wrong-result`: reversibility 'true' is never written, and the single-reference check is unreachable. Its five tested callers use none of these forms (seed NONE). |
| visualizeNormalizedRxnPresence | QUARANTINED, `error` and `wrong-result`: a custom colour scheme without a 0 row fails at line 150. A second run counts its own earlier heatmap as a map. |
| transformKEGG2Model | BLOCKED, test removed: the triggers are in the callee mapMetName2KEGGID, whose test (written before this feature) already records an `error`. mapMetName2KEGGID is now in `inventory/existing-defective.tsv` (FR-012). |
| printUptakeBoundCom | stays TESTED: the header lists both indCom and infoCom without marking either as optional, so a model with only one is undocumented (`limitation`). |
| computeEcosystemDBSCAN, loadMinimalWBM, LP10cvx | stay TESTED, strengthened. LP10cvx's new section runs only when CVX is installed, so it has not run here. |

Also: runSeqC's test now restores PATH with onCleanup. plotQuantitativeFluxCoupling, correctMetName and
createColorsMap got `cosmetic` entries, and parseCD got a `limitation` entry: a reaction written on one
line loops forever (observed by reading only).

Net effect of T027–T028:
- 21 functions moved from TESTED to QUARANTINED and 1 to BLOCKED. That is 22 of 173 (13%), against
  30% in the T021 sample.
- Over both reviews, 34 of the 213 functions TESTED before T021 were quarantined or blocked.
- TESTED is now 179, QUARANTINED 291 and BLOCKED 430.
- The 30 changed tests were re-run together with coverage (`inventory/coverage/review-full.jsonl`):
  all passed, nothing was left behind, and `--verify-coverage` and `--check` found 0 problems.
- The registry lists 848 defects.
- Coverage of `src/` without the generated c13 solvers is 26.5%, down from 27.4%, because quarantined
  tests do not count.

For the human review (in addition to the list above):
- **Tests that predate this feature.** multiProductionEnvelope (testMultiProductionEnvelope,
  testMultiProductionEnvelopeInorg) calls the now-quarantined findCarbonRxns, and generateChemicalDatabase
  calls compareInchis. Like the hit_node caller, they are outside the ledger.
- **checkRankFR (BLOCKED)** hard-codes solver 'gurobi5' and interface 'solveCobraLP' at lines 534–535,
  so it fails on every input here. Its FRwrows (line 641) also contradicts its header. Its own future
  test should start there.
- **Moderate-confidence reaches:** TmodelStats (seed NONE rests on verifyModelBorg forcing `[x]`) and
  the visualizeNormalizedRxnPresence lower-case colour entry.

## Follow-up: defects reported in already-quarantined functions (T031–T032), 2026-11-17

Two helpers reproduced in MATLAB R2025a the findings listed above under "For the human review", items 3
and 4. Their records are `inventory/results/review-extra-a/b.jsonl`. All 14 functions were already
QUARANTINED, so no status changes. New header entries:

| Function | Entries |
|---|---|
| write4ti2 | 2 `error`: with uni = 0 the file is closed a second time at l.45; omitting uni fails at l.21 |
| solveCobraLPCPLEXcard | `wrong-result`: with osense = 1 the non-card ILOG branch maximises (stand-in Cplex). findMinCardModel uses 'zero', so it is unaffected |
| addExoMetToEFBA | `error`: the default relaxBounds reads lb_preconstrainRxns at l.123 |
| BDF | `wrong-result`: out.Xk only ever holds x0. The field is undocumented, but the sibling methods store their iterates |
| calculateQuantitativeDiffs | 2 `wrong-result`: the secretion and uptake sets name the wrong condition. setSemiQuantConstraints reads them with the swapped meaning, so a fix must change both functions together |
| illustrate_ppp | `error`: with performPPP's layout of mets (one pair per row) it fails at l.31 or l.34 |
| producetSNEPlots | `error`: with exactly 10 strains and a custom feature, perpl is undefined at l.260. computeModelProperties (BLOCKED) reaches it |
| getUnannotatedReactionsFromPubSeedSpreadsheets | `unusable-option`: the documented default inputDataFolder is not implemented, as in its sibling. Also 1 `cosmetic` entry |
| lrsWriteHalfspace | `wrong-result`: with positivity omitted, x >= 0 is left out. extremePools passes 1 |
| printSolutionGEM, mapMatch, saveInputsOptForce | `cosmetic` (help text versus code). printSolutionGEM's three-input finding is not a documented call, because itNum has no default |
| compareSampleTraj, getQualitativeFluxStates | triggers corrected; both entries hold |

All 14 tests stay in quarantine layout and pass with coverage, leaving nothing behind
(`inventory/coverage/review-extra.jsonl`); `--verify-coverage` and `--check` found 0 problems. The registry lists
863 defects. Items 3 and 4 of "For the human review" are resolved, apart from the csense release-dependence,
which needs another MATLAB release.

## Follow-up: CI failures of the pull request (T034–T037), 2026-11-20

The CI run of the pull request failed ten tests of this feature that had passed locally. The local
runs could not show any of the three causes:

| Tests | Cause | Fix |
|---|---|---|
| testLrsRun | `redund` (lrslib) is not installed on the CI machine; the facet-enumeration section runs it (exit status 127). The header listed it, but `prepareTest` declared only `lrs` | `prepareTest('requiredSoftwares', {'lrs', 'redund'})`. Checked with a `PATH` holding only `lrs`: the test is skipped, naming redund |
| testConvertCarbonInput, testErrorComputation2, testErrorComputation2_grad, testGradtest, testSlvrCumomer, testSlvrCumomer_fast, testSlvrEMU, testSlvrEMU_fast | `convertCarbonInput` and `slvr*.m` are written by `generateIsotopomerSolver` and kept out of the repository by `.gitignore`, on develop as here. Locally they were present from an earlier run of testFitC13Data, which needs an NLP solver and is skipped on CI | Each test generates the solver for `model.mat` of testFitC13Data (as testFitC13Data does: an LP solver for the flux variability step, and Perl; both declared, so the tests are now Tier 3). Solver files present before are copied away and put back; files the test generated are removed. testConvertCarbonInput moved to `testFitC13Data/`, beside the fixtures it now loads |
| testParse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elements | The name is 67 characters; MATLAB's limit is 63 (`namelengthmax`). The CI coverage run (MOcov) cuts it and fails with "Unrecognized function or variable" | Renamed to `testParse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elem.m`, the 63-character name MATLAB itself uses for it |

**Generated files depend on Perl's hash order.** The Perl scripts list fields and pools in hash
order, which changes from one generation to the next: the files differ every time, with the same
lines in another order or with the internals renumbered. One assertion depended on that order:
testConvertCarbonInput compared the field names of the output in order. It now compares them without
their order. The other tests passed against every generation tried, including the Tier 5 reference
values of testSlvrCumomer_fast and testSlvrEMU_fast.

**Checks.**

- All ten tests pass with coverage (`inventory/coverage/ci-fix.jsonl`, `ci-fix-seed0.jsonl`), leaving
  nothing behind. The user's solver files present before the run were put back byte for byte.
- For the four generated solvers, coverage was measured with `PERL_HASH_SEED=0` in the environment
  of the measurement only. A test regenerates the file it covers, and the coverage plugin maps lines
  from the file present when the run starts, so an unseeded run shows false misses. With the seed,
  generation is deterministic (two generations compared byte for byte) and every line is reached.
- The ten tests were run twice the way CI runs them (`runScriptFile` by name), after removing the
  generated files from `src/`. All 20 runs passed, so the eight c13 tests passed against 16
  generations in different hash orders, and no generated file was left in `src/` afterwards.
- `--verify-coverage` and `--check` found 0 problems.

**Exception to III-Naming.** `parse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elements` is the
only source name over 59 characters. It is therefore the only function whose `test<Name>` exceeds
MATLAB's limit, and no test file can follow III-Naming for it. The test header records this. A
constitution amendment (`/speckit-constitution`) could make the rule itself say "cut to
`namelengthmax`".

**After constitution 1.9.0 (Principle XI, same day, T039).** The maintainer added the goal of
minimal dependence on third-party toolboxes and proprietary applications to the constitution.
Two of the requirements above were checked against it:

- **Perl in the eight c13 tests:** declared now only outside Windows. On Windows, MATLAB's `perl`
  runs the Perl that ships with MATLAB, so declaring it would skip the tests needlessly. The tests
  pass with coverage (`inventory/coverage/ci-fix-perl.jsonl`; `--verify-coverage` 0 problems). The
  LP solver they need is served by GLPK, which COBRA ships.
- **`redund` in testLrsRun:** avoidable, but only in `src/`. `redund` is not needed as a separate
  program: since lrslib 7, `lrs` removes redundant inequalities itself when the input file carries
  the option `redund 0 0`. Checked on a two-variable example with the system lrs and with the lrs
  COBRA bundles for Linux (`binary/glnxa64`, lrslib 7.3, which has no `redund`): each gives the same
  irredundant H-representation as `redund`. `lrsRun` already contains this route (lines 133-135),
  switched off at line 128, and that route's `sed` edit would also rewrite every `end` in the file.
  No task of this feature changes `src/`, so the requirement stays declared here. A separate feature
  that makes `lrsRun` use `lrs` alone would let testLrsRun drop `redund` and run on CI again.

**testLrsRun no longer needs redund (feature 20261120-140123-lrsrun-without-redund, same day).**
The maintainer accepted the source change into this pull request. `lrsRun` now removes redundant
facets with `lrs` itself: it runs `lrs` a second time on a temporary copy of the facet output that
ends with the option `redund 0 0`. It no longer runs the separate program `redund`, and the dead
`sed` route is gone. `testLrsRun` declares only `lrs`, and checks that route four ways:
- with `redund` installed;
- with a `PATH` holding only `lrs`, `which` and `sed`;
- with an `lrs` that fails in the redundancy step;
- that the facet output and the temporary folder are left clean.

The test passes with coverage of every line except the non-Unix branch (line 156), and also passes
when the whole test runs on a `PATH` without `redund`. The ten tests of `testLrsInterface/` and
`testTopology/` that use lrs pass as before.
`lrsSpecifyRows`, which `lrsRun` calls, ran GNU-style `sed -i`, which BSD `sed` on macOS rejects.
It is fixed in a second feature, `specs/20261120-144501-lrsspecifyrows-without-sed/`. The
function now reads the file, replaces the `*****` placeholders with `regexprep`, and writes the
file back, with no external program; on the test's inputs the output is byte for byte what GNU
`sed` wrote. That change also fixed the two defects recorded in its test: the undefined-variable
error for a file that cannot be opened, and the file identifier left open. The registry lists 861
defects. testLrsSpecifyRows now declares no requirement, so it runs on every platform, and it
reaches every line of the function, also with an empty `PATH`. testLrsRun's minimal `PATH` now
holds only `lrs` and `which`.
These two functions are the only changes to `src/` in this pull request.
