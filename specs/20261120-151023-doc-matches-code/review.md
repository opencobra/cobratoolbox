# Review: help text matches the code

## Cosmetic entries: 146 classified

Five helper agents classified the 144 entries of their slices, working by
`inventory/cosmetic-brief.md` and seeing only the code, the tests and the brief. The lead classified
the other 2 (testParseSolverParameters and testChangeCobraSolverParams) and checked every class-A
fix against the code as second reader. The records are in `inventory/results/cosmetic-slice-1..5.jsonl`.

| Class | Entries | Meaning |
|---|---|---|
| A, text fixed | 21 | help or comment contradicted deliberate code; comment lines reworded, entry removed |
| B, out of scope | 121 | messages, printing, figures, files, validation or behaviour (119 + the 2 message entries of parseSolverParameters and changeCobraSolverParams) |
| C, code is the slip | 4 | kept as defects |

The guard `tools/comment_only_check.py` compares the files byte for byte against the branch start.
It reports 0 problems: only full comment lines of 26 `src/` files changed, and every file kept its
number of lines and its line endings. The 21 tests of the class-A source files pass.

**Second reading.** Every class-A fix was checked against the code:
- **removeIndicesInDimenion:** keeps the given indices. Its only caller passes `~indicesToRemove`.
- **writeLPProblem:** integer markers reach the MPS writer only on the full-problem path.
- **extremePools:** the transposing branch is dead (`if 0`), and the live branch checks `P*N' = 0`.
- **hit_node:** `fcont = 1` marks the default all-ones fluxes.
- **calculateEPSILON:** 0 marks an unchanged reaction.
- **printSolutionGEM:** the `logFile` handling is now described as the code does it.

**Class C, kept as defects:**
- **plotSampleHist:** the subplot call transposes perScreen.
- **liftCouplingConstraints:** the model identifier gets two suffixes.
- **optForce:** exclusion type L or D in the recording.
- **processConcConstraints:** the default `concUnit = 10-3` evaluates to 7.

**Follow-ups noticed, not changed:**
- **createGroupIncidenceMatrix_jankowski:** its function line names `createGroupIncidenceMatrix_old`.
  This is now recorded as a cosmetic entry, because the USAGE line was corrected to the file name.
- **extremePools:** vertexBool refers to the columns of the lrs output Q, not of P.
- **cmpMet:** its EXAMPLE calls `cmpM`.
- **saveInputsOptForce:** the help still lists `k.mat` and `nSets.mat`, which the code never writes
  (its separate wrong-result entry).

## Quarantines that rested only on help text

| Function | Help corrected to | New test | Coverage |
|---|---|---|---|
| parseSolverParameters | param holds only the COBRA parameters; solver-specific ones are only in solverOnlyParams | full (from the wave 13 version) | 37/37 |
| changeCobraSolverParams | solverType is required | full (from the wave 03 version) | 9/9 |
| getElementalWeightMatrix | no printWarning input; an unknown element raises an error | full, new; weights from the NIST file | 70/70 |
| getEcosystemClusterDescriptor | the column is `status_c<clusterId>` | full (from the wave 03 version) | 24/24 |
| transportReactionBool | with unidirectionalBool = 0 the compartments restrict the result in either direction | full, new | 27/27 |

The cosmetic message entries of parseSolverParameters and changeCobraSolverParams stay; they do
not quarantine.

**readSimPhenyCMPD stays quarantined.** Its entry rests on the intent of its own code: the deblank
loop misses the blank after '/'. It is not a help-text mismatch.

**deltaG0concFluxConstraintBounds** was blocked only by transportReactionBool. Writing its test found
an `error` of its own: every call stops at line 307, which calls `createGroupIncidenceMatrix_old`,
a name MATLAB cannot resolve (`which` is empty). The helper reproduced it and the lead confirmed it.
It is QUARANTINED with that entry. Notes for whoever fixes it:
- line 297 calls `transportReactionBool(model, 1)`, an old calling form, which returns all false;
- the callee createGroupIncidenceMatrix_jankowski is itself quarantined;
- the help names fields (`xmin`, `xmax`, `dfG0GroupContUncertainty`) that the code does not read.

## Ledger and registry

- **Ledger statuses:** TESTED 184 (+5), QUARANTINED 287 (−4), BLOCKED 429 (−1), EXCLUDED 185.
- **Blocked reasons:** the five cleared functions were removed from 300 rows. None became unblocked,
  because each still has other blockers.
- **Checks:** `--check` and `--verify-coverage` (`coverage.jsonl`) both report 0 problems.
- **Registry:** 837 defects. That is 861, minus 21 text fixes, plus 1 re-recorded name mismatch,
  minus 5 help-text quarantine entries, plus 1 new defect.
