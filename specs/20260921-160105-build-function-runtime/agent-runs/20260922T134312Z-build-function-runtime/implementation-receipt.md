# Implementation receipt: 20260921-160105-build-function-runtime

## Prompt

`/speckit-implement` (no additional user input), run on branch
`20260921-160105-build-function-runtime` against `specs/20260921-160105-build-function-runtime/tasks.md`
(T001-T033), after `/speckit-plan`, `/speckit-tasks`, two `/speckit-analyze` runs and the
user-approved remediation edits of 2026-09-22.

## Final response

All 33 tasks are done, and the modified function's behaviour matches the original on every fixture. Nothing is committed.

**Changes** (three source files, 61 lines added, 18 removed):
- `addBondMappingsRXNFile.m`: two new optional inputs, `atoms` and `bonds`, so a caller can pass in a file it has already read. The two-input call works exactly as before. The `energy` table is now built only in the two branches that use it.
- `checkABRXNFiles.m`: each RXN file is read once per reaction and the result passed on.
- `buildAtomAndBondTransitionMultigraph.m`: the bond loop passes its parsed file on, and `BondElmts` is filled in one assignment instead of one table write per bond.
- Two new CI tests, `testAddBondMappingsRXNFile.m` and `testCheckABRXNFiles.m`, each with an expected-value `.mat` file captured from the unmodified functions.

**Verification:** golden snapshots were captured from the unmodified source on 10 fixtures (the seven subsystem fixtures, the CI fixture, and two copies of it with one RXN file missing or cut to its header lines).

| Fixture | Time (original → modified) | `readABRXNFile` calls | `energy` tables |
|---|---|---|---|
| bileacid | 126.3 → 73.0 s (1.73×) | 718 → 430 | 96,691 → 4,149 |
| chol | 48.6 → 30.8 s (1.58×) | 303 → 181 | 37,233 → 1,519 |
| tyr | 43.8 → 28.3 s (1.55×) | 633 → 379 | 35,435 → 2,479 |

The other fixtures speed up by 1.11× to 1.52×.
- On all 10 fixtures, all 12 outputs are identical in both default and dense mode, and so are the `checkABRXNFiles` results and all 446 per-file `bondMappings` tables.
- Console output is unchanged apart from the line numbers in stack traces.
- The fixture with the unreadable file raises the same error as the original.
- The diff changes no message, warning or error statement.
- All 9 tests in `testReactingMoieties` pass, including the two existing tests, which are unedited.

**Decision needed:** the golden snapshots in `specs/20260921-160105-build-function-runtime/snapshots/` total 19 MB, above the 10 MB threshold the tasks set before committing (bileacid alone is 8.7 MB). Do you want them committed, committed without bileacid, or left out of git?

**Things the evidence does not cover:**
- **Fewer repeated messages:** none of the fixtures' RXN files prints any `readABRXNFile` message, so the approved reduction was never exercised. Every console line was held to exact identity instead.
- **Decompartmentalisation:** every fixture takes the "names match" branch, so the two mismatch branches are untested.
- **`bondTransitionMultigraph = 0`:** covered only by the existing test, not by the snapshot comparison.
- **Peak memory:** within the gate everywhere, but the modified version measures 39–71 MB (2.3–4.5%) higher on every fixture. The offset is about the same on the 3-reaction fixture as on bileacid, so it looks like a quirk of how the measurement processes start, not memory the change holds. I haven't proven that.
- **tyr:** the bond residual of 3 that the spec assumed is gone in the current corpus; tyr is consistent in both versions.
- **`pufa`:** not run (optional).

Full results are in `specs/20260921-160105-build-function-runtime/reproducibility-results.md`, and the receipt is in `agent-runs/20260922T134312Z-build-function-runtime/`.

## Extension Hooks

**Optional Hook**: git
Command: `/speckit-git-commit`
Description: Auto-commit after implementation

Prompt: Commit implementation changes?
To execute: `/speckit-git-commit`

## Diff summary

Source (vs `64efe1dc8`; `git diff --stat`: 3 files, 61 insertions, 18 deletions):

- `src/analysis/topology/reactingMoieties/addBondMappingsRXNFile.m`: signature gains optional
  `atoms, bonds`; `USAGE:`/`OPTIONAL INPUT:`/`NOTE:`/`Author` header updates; read guarded by
  `~exist(...) || isempty(...)`; `energy = table(...)` moved from the loop top into the two
  reacting-bond branches (T014, T015).
- `src/analysis/topology/reactingMoieties/checkABRXNFiles.m`: `rxnParsedInBlock1` flag;
  block 2 reuses block 1's parse for the first reaction; both `addBondMappingsRXNFile` calls
  pass `atoms, bonds`; `Authors` line (T017).
- `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m`: bond-loop
  call passes `atoms, bonds`; per-bond `BondElmts` loop replaced by one `cellfun` assignment
  guarded by `height(dBTM.Nodes) > 0`; `Authors` line (T019, T020).

New tests and data:

- `test/verifiedTests/analysis/testReactingMoieties/testAddBondMappingsRXNFile.m` (T011)
- `test/verifiedTests/analysis/testReactingMoieties/testCheckABRXNFiles.m` (T012)
- `test/verifiedTests/analysis/testReactingMoieties/data/addBondMappingsRXNFileExpected.mat` (T009)
- `test/verifiedTests/analysis/testReactingMoieties/data/checkABRXNFilesExpected.mat` (T009)

Spec Kit artefacts (`specs/20260921-160105-build-function-runtime/`):

- `buildRuntimeReproducibilityCheck.m` (harness, T003-T009, T022)
- `snapshots/*.mat` (10 golden snapshots, 19 MB)
- `reproducibility-results.md`, `tasks.md` (all tasks checked), this receipt.

Also modified earlier in the workflow (not by implementation): `spec.md`, `CLAUDE.md`,
`.specify/feature.json`.

## Tests

- New CI tests before the edit (T013): `testCheckABRXNFiles` PASS; `testAddBondMappingsRXNFile`
  FAIL only at its first four-input call ("Too many input arguments"), as expected.
- After each edit (T016, T018, T021): the new tests and then all four relevant tests PASS;
  warnings identical to a run on the baseline copies.
- Every test in `test/verifiedTests/analysis/testReactingMoieties/` (T030): 9/9 PASS.
- Harness self-check on the unmodified source (T010): 72/72 equality and console items PASS.
- Golden-snapshot comparison on the modified source (T023, T025-T027): every item PASS on all
  10 fixtures (outputs default and dense, class/sparsity, `checkABRXNFiles`, `bondMappings`,
  console rule, T022 index check, timing, `readABRXNFile` count = 3r + 1, energy tables =
  energy rows, peak memory within 5% / 50 MB).
- Static checks (T024, T027, T028, T031): no message statement changed; no suppression, cache,
  `nargin`, `persistent` or `global` added; `BondElmts` block identical to the one tested;
  scope limited to the three source files.

## Unresolved issues

- `snapshots/` is 19 MB, above the 10 MB threshold: user decision required before committing.
- Not exercised by any fixture: FR-009's reduction of repeated `readABRXNFile` messages; the two
  decompartmentalisation mismatch branches.
- `options.bondTransitionMultigraph = 0` covered only by the existing test.
- Peak memory: systematic +39-71 MB offset of the modified version (within the gate), attributed
  to measurement process setup but not proven.
- tyr's spec-assumed bond residual of 3 is absent in the current corpus.
- `pufa` (optional FR-014) not run.
- Analysis items not addressed in this run: research.md R8 (i) still describes the older
  "missing" construction (I6); `CLAUDE.md`/`AGENTS.md` override-phrase drift from the
  constitution (I5, outside this feature).

## Other information

- The harness's console rule identifies `readABRXNFile` lines empirically: the messages
  `readABRXNFile` prints when each fixture file is read once under `diary` at capture time.
  The tasks listed regex templates instead; the empirical set covers the same statements
  without the ambiguity between `readABRXNFile.m:237` and `checkABRXNFiles.m:268`, and
  keeps callers' error-report lines under the strict check.
- The harness also filters the environment's "Name is nonexistent or not a directory" path
  warnings and MATLAB's `[\b...]\b` warning markers from console text; and measures peak
  memory as the minimum of three fresh-process runs because single runs of identical code
  differed by about 7%.
