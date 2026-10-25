# Implementation Receipt

## Prompt

`/speckit-implement` (no additional arguments), for the active feature `specs/20261015-173504-prepare-recon3d-fr`, after Gate 2 approval of T001–T054 ("Fix E1, approve all (Recommended)", recorded in human-loop.md).

## Final response

I've implemented `generateFullRowRankFR`: all 54 tasks are done and its test passes. Nothing is committed yet.

**What was built**
- `src/analysis/topology/FR/generateFullRowRankFR.m` (new). Each pass applies the first remedy that fits:
  1. remove zero rows;
  2. lump identical rows into one representative (or, with `remedy = 'removeRxns'`, remove their reactions);
  3. remove the dead-end reactions behind a sum dependency, once a left-null vector of `[F,R]` confirms that dependency.

  If none fits, it stops and reports that vector as evidence. With your opt-in `irreducibleRemedy = 'removeMetabolites'`, it instead removes the problem species with all its reactions and carries on. Every removal is reported, including side effects of the toolbox functions it calls. Each rank comes from `getRankLUSOL`, checked against a sparse QR.
- `test/verifiedTests/analysis/testTopology/testGenerateFullRowRankFR.m` (new): 9 hand-built fixture models, each checked numerically before use, about 20 test cases, plus the in-repo Recon3D, iDopaNeuroC and Recon3T.

**Results**
- **Test:** `runTestSuite('testGenerateFullRowRankFR')` passes in 37 s. Nothing was skipped, because all three large models are on this machine.
- **Recon3T** (`measurements/reproduceRecon3T.m`): m 5824 → 5795 and rank 5809 → 5795, in 5 passes and 15.8 s. It found exactly the 5 zero rows, the 6 identical-row groups and the 14 dead-end reactions. It flagged exactly HEPDECETH/PENDECAETH and DIDECAETH/TETDECAETH for review, and `verifyModel` passes.
- **In-repo Recon3D:** rank 5826 → 5812, full rank, from 5835 metabolites.
- **iDopaNeuroC:** rank 1243 → 1243, full rank, from 1244 metabolites; `r0698` keeps its subsystem.
- **Rank checks:** LUSOL and QR agreed on every rank calculation; the LUSOL storage failure (`inform = 7`) never occurred.
- **Code Analyzer:** the source is clean. The test has 5 style hints left, all deliberate transposes before `sort`.

**Things you should know**
- **Two problems found in the first run:**
  - `addReaction` needs a `model.c` field when it rewrites a reaction. The function now adds a temporary zero objective if the model has none and removes it afterwards.
  - A test helper compared two empty cell arrays of different shapes; that was a test bug, and I fixed it.
- **No per-story failing run:** I wrote the tests before the source, but wrote the source in one go rather than story by story. So there was no deliberate failing run for each story.
- **The contract overstates one guarantee:** it says external reactions are only ever removed whole. But removing a zero-row metabolite (FR-005) also strips it from any external reaction it appears in. If that reaction has other metabolites, such as a biomass reaction, its stoichiometry changes. This didn't happen on any of the three models: all 29 (Recon3T) and 23 (Recon3D) external reactions touched had a single metabolite and were removed whole. I suggest correcting the contract, or adding a report flag for this case.
- **Lint:** for T010 and T049 I ran Code Analyzer (`checkcode`), not the `matlab-review-code` skill.
- **Fixture table location:** the T003 fixture checks are in `measurements/testGenerateFullRowRankFR.log`, not a separate `fixtureCheck.log`.
- **Logs and commits:** `.gitignore` excludes `*.log`, so the measurement logs need `git add -f` when you commit.

The receipt is `specs/20261015-173504-prepare-recon3d-fr/agent-runs/20261015T213143Z-prepare-recon3d-fr/implementation-receipt.md`. The optional commit hook after implementation is turned off in the project's git settings.

Next is closeout (Gate 3): accept the feature, or first correct the contract wording.

## Diff summary

New files (no existing file modified outside `specs/`, apart from `CLAUDE.md` and `.specify/feature.json`, which were updated in the planning phase):
- `src/analysis/topology/FR/generateFullRowRankFR.m` (595 lines): main function plus local functions `initReport`, `computeFR`, `decideRank`, `getRankQR`, `repairPass`, `findIdenticalGroups`, `differenceVectors`, `lumpGroup`, `removeNewInternalDuplicates`, `leftNullWitnesses`, `chooseGeneralRemoval`, `recordWitness`, `recordEdit`, `flagSharedSubstrates`, `removeGenesAfterRxnRemoval`, `printEdit`.
- `test/verifiedTests/analysis/testTopology/testGenerateFullRowRankFR.m` (573 lines).
- `specs/20261015-173504-prepare-recon3d-fr/measurements/reproduceRecon3T.m`, `reproduceRecon3T.log`, `testGenerateFullRowRankFR.log`.
- `specs/20261015-173504-prepare-recon3d-fr/tasks.md`: all 54 tasks marked `[X]`.

Reused toolbox functions were not modified (FR-014): `git status` shows only the two new source/test files outside `specs/`.

## Tests

- `runTestSuite('testGenerateFullRowRankFR')` (MATLAB R2026a, MCP session): **passed**, 37.1 s, 0 failed, 0 skipped. It covers the fixture sanity checks (T003), US1–US5 cases, error paths, determinism, printLevel-0 silence (diary capture), in-repo Recon3D (SC-002b), iDopaNeuroC (SC-003) and Recon3T (SC-002). Log: `measurements/testGenerateFullRowRankFR.log`.
- `measurements/reproduceRecon3T.m`: SC-002 reproduced exactly; `verifyModel` simple check true. Log: `measurements/reproduceRecon3T.log`.
- `checkcode` on the source: no messages. On the test: 5 intentional "transposing the input to sort" hints (row cell arrays from `{s.f}` turned into columns for comparison with column literals).
- Earlier failing runs (not kept): run 1 failed on a test-helper empty-cell shape comparison; a bare model without `.c` failed inside `addReaction`. Both were fixed before the passing runs.
- Not run: the full `testAll` suite (only the new test, through the same `runTestSuite` entry point that `testAll` uses).

## Unresolved issues

1. Contract item 5 overstates the guarantee. Zero-row removal (FR-005) strips the metabolite from multi-metabolite external reactions, changing their stoichiometry. This was not observed on Recon3T, Recon3D or iDopaNeuroC. Reconcile at Gate 3.
2. Follow-up defects in reused functions (plan § Follow-ups; project memory `reused-function-defects-fr-rank`):
   - `addReaction` blanks legacy char `subSystems` entries, and requires `.c` when updating a reaction;
   - `checkDuplicateRxn('FR')` treats empty columns as duplicates;
   - `getRankLUSOL` hides the LUSOL `inform` code.
3. Testing was not strict red/green per story (the source was written in one pass after the tests).
4. The `matlab-review-code` skill was not invoked; Code Analyzer was used instead.

## Other information

- Implementation path: core implementer (`/speckit-implement`), inline; no subagents.
- An unrelated message, "Each model.subSystems{x} is a character array, and this format is retained.", is printed by a reused toolbox function during the iDopaNeuroC case. It is not output of `generateFullRowRankFR`.
