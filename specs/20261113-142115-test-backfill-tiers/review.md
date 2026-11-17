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
   not deliver), but each would clear with a documentation fix. Fixing the parseSolverParameters
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
