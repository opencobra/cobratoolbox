# Reproducibility results: 20260921-160105-build-function-runtime

Append-only record for `buildRuntimeReproducibilityCheck.m` (spec FR-011, FR-012; research R5-R7).

## Preconditions (T001, 2026-09-22)

- `git diff --quiet 64efe1dc8 -- addBondMappingsRXNFile.m checkABRXNFiles.m buildAtomAndBondTransitionMultigraph.m`: clean (source identical to baseline).
- `git diff --quiet 64efe1dc8 -- testConservedReactingMoieties.m testBuildAtomAndBondTransitionMultigraph.m`: clean.
- `~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/subsystemSubModels/subsystemSubModels.mat`: present.
- `/media/JACK/repos/ctf/rxns/atomMapped_std`: present, 17,072 top-level `.rxn` files at check time.
- `test/models/mat/Recon3D_301.mat`: present.
- MATLAB: 24.2.0.3157250 (R2024b) Update 8.

## Console comparison rule in force (T002)

Authority: spec FR-009, FR-011 and Clarifications (Session 2026-09-22); research R5.

1. Split each console text into lines. Remove stack-frame lines (`> In <fn> (line N)` / `In <fn> (line N)` warning backtrace frames; `Error in <fn> (line N)` frames and the indented source or caret lines that follow them) and list those separately.
2. A remaining line is a `readABRXNFile` line if it is one of the non-blank lines `readABRXNFile` itself prints for the fixture's RXN files (collected by parsing each file once under `diary` at capture time; this covers the templates at `readABRXNFile.m` lines 73, 115, 169, 212, 219, 222, 226 and 237). A blank line directly after such a line belongs to it.
3. PASS if (a) all other lines are identical as sequences, and (b) every distinct `readABRXNFile` line appears in both texts with `1 <= countModified <= countOriginal`.
4. Stack-frame lines that differ are reported, not failed.

## Capture run 2026-09-22 12:03:08 (source at 64efe1dc8)

| Fixture | Rxns | Mets | Corpus .rxn | decompBranch | readABRXNFile calls | addBondMappings calls | energy constructions | energy appends | median s (5 runs) | VmHWM kB | Build error |
|---|---|---|---|---|---|---|---|---|---|---|---|
| ci | 3 | 4 | 18 | match | 18 | 7 | 280 | 32 | 0.596 | 1.68668e+06 | none |
| ci_missing | 3 | 4 | 17 | match | 13 | 5 | 200 | 20 | 0.434 | NaN | none |
| ci_unparsable | 3 | 4 | 18 | match | 11 | 3 | 120 | 12 | 0.238 | NaN | MATLAB:graphfun:digraph:InvalidTableSize: First variable in edge information table must be a 2-column array (numeric, cell, or string) of node names. |

## CI expected-value capture 2026-09-22 12:03:52 (source at 64efe1dc8)

- addBondMappingsRXNFileExpected.mat: 18 RXN files
- checkABRXNFilesExpected.mat: base, missing (r0426.rxn deleted), unparsable (r0426.rxn cut to 4 header lines)
- readABRXNFile throws on the unparsable file: yes; checkABRXNFiles throws on firstBroken: yes

_Note: the CI-size captures above were a harness smoke run. The console normalisation was then fixed (MATLAB -batch warning markers, non-indented `getReport` source echo, environment path warnings, and error-report lines excluded from the `readABRXNFile` message set), and the three CI-size snapshots were deleted and re-captured below from the same unmodified source._

## Capture run 2026-09-22 12:05:08 (source at 64efe1dc8)

| Fixture | Rxns | Mets | Corpus .rxn | decompBranch | readABRXNFile calls | addBondMappings calls | energy constructions | energy appends | median s (5 runs) | VmHWM kB | Build error |
|---|---|---|---|---|---|---|---|---|---|---|---|
| ci | 3 | 4 | 18 | match | 18 | 7 | 280 | 32 | 0.499 | 1.70964e+06 | none |
| ci_missing | 3 | 4 | 17 | match | 13 | 5 | 200 | 20 | 0.383 | NaN | none |
| ci_unparsable | 3 | 4 | 18 | match | 11 | 3 | 120 | 12 | 0.220 | NaN | MATLAB:graphfun:digraph:InvalidTableSize: First variable in edge information table must be a 2-column array (numeric, cell, or string) of node names. |

## Compare run 2026-09-22 12:05:45 (HEAD a4a9f6d70, working tree; original = 64efe1dc8 copies)

### ci (3 rxns, 4 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 3 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS
- timing (5 alternating runs): original median 1.303 s, modified median 1.278 s, speed-up 1.02x, noise 0.013 s: PASS
  - original runs: [1.309 1.29 1.282 1.304 1.303]; modified runs: [1.285 1.278 1.28 1.273 1.277]
- readABRXNFile calls: original 18, modified 18 (3r+1 = 10 for r = 3): FAIL
- addBondMappingsRXNFile calls: original 7, modified 7: PASS
- energy table constructions: original 280, modified 280; energy rows appended: modified 32: FAIL
- peak memory VmHWM: original 1.65505e+06 kB, modified 1.7714e+06 kB (capture 1.70964e+06 kB): FAIL

### ci_missing (3 rxns, 4 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 2 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS
- timing (5 alternating runs): original median 1.184 s, modified median 1.194 s, speed-up 0.99x, noise 0.013 s: PASS
  - original runs: [1.17 1.186 1.195 1.183 1.184]; modified runs: [1.184 1.194 1.198 1.205 1.189]
- readABRXNFile calls: original 13, modified 13 (3r+1 = 7 for r = 2): FAIL
- addBondMappingsRXNFile calls: original 5, modified 5: PASS
- energy table constructions: original 200, modified 200; energy rows appended: modified 20: FAIL
- peak memory: not measured (derived CI-size fixture)

### ci_unparsable (3 rxns, 4 mets, decompBranch match)
- build error (default): original MATLAB:graphfun:digraph:InvalidTableSize: First variable in edge information table must be a 2-column array (numeric, cell, or string) of node names., modified MATLAB:graphfun:digraph:InvalidTableSize: First variable in edge information table must be a 2-column array (numeric, cell, or string) of node names.: PASS
- outputs (default): none produced by either version: PASS
- outputs (dense): none produced by either version: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 3 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS
  - stack frame only in original: `runCapture(cfg, fixtureNames);`
  - stack frame only in original: `snapshot = captureOutputs(model, rxnDir);`
  - stack frame only in original: `Error in buildRuntimeReproducibilityCheck (line 56)`
  - stack frame only in original: `Error in buildRuntimeReproducibilityCheck>runCapture (line 618)`
  - stack frame only in original: `In buildRuntimeReproducibilityCheck (line 56)]`
  - stack frame only in original: `In buildRuntimeReproducibilityCheck>runCapture (line 618)`
  - stack frame only in modified: `now_ = captureOutputs(model, rxnDir);`
  - stack frame only in modified: `runCompare(cfg, fixtureNames);`
  - stack frame only in modified: `Error in buildRuntimeReproducibilityCheck (line 61)`
  - stack frame only in modified: `Error in buildRuntimeReproducibilityCheck>runCompare (line 723)`
  - stack frame only in modified: `In buildRuntimeReproducibilityCheck (line 61)]`
  - stack frame only in modified: `In buildRuntimeReproducibilityCheck>runCompare (line 723)`
- timing (5 alternating runs): original median 0.685 s, modified median 0.687 s, speed-up 1.00x, noise 0.038 s: PASS
  - original runs: [0.6768 0.7523 0.6851 0.6885 0.6799]; modified runs: [0.6953 0.7168 0.6761 0.6875 0.6724]
- readABRXNFile calls: original 11, modified 11 (3r+1 = 10 for r = 3): PASS
- addBondMappingsRXNFile calls: original 3, modified 3: PASS
- energy table constructions: original 120, modified 120; energy rows appended: modified 12: FAIL
- peak memory: not measured (derived CI-size fixture)


## Capture run 2026-09-22 12:07:38 (source at 64efe1dc8)

| Fixture | Rxns | Mets | Corpus .rxn | decompBranch | readABRXNFile calls | addBondMappings calls | energy constructions | energy appends | median s (5 runs) | VmHWM kB | Build error |
|---|---|---|---|---|---|---|---|---|---|---|---|
| nglycan | 3 | 9 | 17072 | match | 13 | 5 | 1202 | 28 | 2.039 | 1.57272e+06 | none |
| phe | 14 | 42 | 17072 | match | 68 | 27 | 4814 | 298 | 6.367 | 1.58396e+06 | none |
| andest | 29 | 69 | 17072 | match | 143 | 57 | 13149 | 683 | 16.622 | 1.59646e+06 | none |
| chol | 61 | 125 | 17072 | match | 303 | 121 | 37233 | 1519 | 48.121 | 1.61629e+06 | none |
| urea | 67 | 132 | 17072 | match | 333 | 133 | 15703 | 1175 | 21.250 | 1.6062e+06 | none |
| tyr | 127 | 197 | 17072 | match | 633 | 253 | 35435 | 2479 | 43.315 | 1.61776e+06 | none |
| bileacid | 145 | 217 | 17072 | match | 718 | 287 | 96691 | 4149 | 126.394 | 1.66341e+06 | none |

## Self-check (equality and console only) run 2026-09-22 13:05:52 (HEAD a4a9f6d70, working tree; original = 64efe1dc8 copies)

### nglycan (3 rxns, 9 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 2 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS


## T010 gate notes (capture, 2026-09-22)

- bileacid: `readABRXNFile` calls 718 (= 5r + 3, r = 143) and `energy` table constructions 96,691 (one per iterated `bondMappings` row), matching the spec's profile: PASS.
- `decompBranch`: every fixture takes `match`; the two mismatch branches are reached by no fixture (not verified here).
- tyr: the captured console contains no "Inconsistency between reaction stoichiometry and bond mapped reactions" report and no "Inconsistent directed bond transition multigraph" warning. The spec's assumption of a pre-existing tyr bond residual of 3 no longer holds for the corpus as captured (17,072 `.rxn` files). The requirement "unchanged" is checked against this capture.
- No fixture's RXN files print any `readABRXNFile` warning or message, so on these fixtures every console line is held to the strict identical-sequence rule; FR-009's permitted reduction is not exercised.
- `ci_unparsable`: the unmodified function itself raises `MATLAB:graphfun:digraph:InvalidTableSize` after skipping the unparsable reaction; this error is the captured expected outcome.
- `snapshots/` totals 19 MB (bileacid 8.7 MB), above the 10 MB threshold: **user decision required before the snapshots are committed** (T010).
- Peak memory: single `VmHWM` runs of identical code differed by up to ~7% (116 MB on `ci`); the harness therefore compares the minimum of 3 fresh-process runs per version.

## T013: new CI tests against the unmodified source (2026-09-22)

- `testCheckABRXNFiles`: PASS.
- `testAddBondMappingsRXNFile`: FAIL at line 47, "Too many input arguments." — the first four-input call, as expected before the edit (proves the test exercises the new call form).
### phe (14 rxns, 42 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 13 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS

### andest (29 rxns, 69 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 28 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS

### chol (61 rxns, 125 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 60 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS

### urea (67 rxns, 132 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 66 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS

### tyr (127 rxns, 197 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 126 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS

### bileacid (145 rxns, 217 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 143 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS

### ci (3 rxns, 4 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 3 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS

### ci_missing (3 rxns, 4 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 2 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS

### ci_unparsable (3 rxns, 4 mets, decompBranch match)
- build error (default): original MATLAB:graphfun:digraph:InvalidTableSize: First variable in edge information table must be a 2-column array (numeric, cell, or string) of node names., modified MATLAB:graphfun:digraph:InvalidTableSize: First variable in edge information table must be a 2-column array (numeric, cell, or string) of node names.: PASS
- outputs (default): none produced by either version: PASS
- outputs (dense): none produced by either version: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 3 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS


## Compare run 2026-09-22 13:17:26 (HEAD a4a9f6d70, working tree; original = 64efe1dc8 copies)


## Source-edit checkpoints (2026-09-22)

- T016 (after `addBondMappingsRXNFile` edits T014/T015): `testAddBondMappingsRXNFile` PASS, `testCheckABRXNFiles` PASS.
- T018 (after `checkABRXNFiles` edit T017): both PASS.
- T021 (after `buildAtomAndBondTransitionMultigraph` edits T019/T020): `testConservedReactingMoieties`, `testBuildAtomAndBondTransitionMultigraph`, `testCheckABRXNFiles`, `testAddBondMappingsRXNFile` all PASS; the two existing tests are unedited (`git diff 64efe1dc8` empty, SC-002). Warnings emitted by the three pre-existing-function tests are identical in text and count to a run of the same tests on the `64efe1dc8` copies (2x inconsistent atom multigraph, 2x inconsistent bond multigraph, 1x `syntheticMet[c]` bond-count — all from the tests' deliberately inconsistent fixtures); `rh_14817.rxn` identifier warnings come from that shipped fixture file via `readABRXNFile`.

## Static review (T024, T027 cache check, T028, T031; 2026-09-22)

- `git diff 64efe1dc8 -- src | grep -E '^[-+].*(warning|error|fprintf|disp|rethrow)\('`: **no hits** — not one message, warning, error or rethrow statement was added, removed or altered (FR-008).
- No `warning('off'`, `evalc`, `lastwarn`, `nargin`, `containers.Map`, `persistent` or `global` added to `src/` (FR-006, VII).
- The `BondElmts` block in `buildAtomAndBondTransitionMultigraph.m` is character-for-character identical to the block exercised by the harness's T022 check (`diff` of the two `if height(dBTM.Nodes) > 0 ... end` blocks is empty).
- Headers: `addBondMappingsRXNFile` `USAGE:` gains the four-input form, `OPTIONAL INPUT:` documents `atoms:`/`bonds:` (four-space indent, colon), a `NOTE:` states the contract limits; `Author`/`Authors` lines appended in all three files; none claims more than FR-009 allows.
- Scope: `git diff --stat 64efe1dc8 -- src test` lists only the three source files; new files are the two tests, their two `.mat` expected-value files, and `specs/` artefacts; `readABRXNFile.m`, `identifyAtomEquivalenceClasses.m` and the untracked `.asv` are untouched. `CLAUDE.md` and `.specify/feature.json` changed as Spec Kit machinery (expected exception to SC-007's list).
### nglycan (3 rxns, 9 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 2 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS
- timing (5 alternating runs): original median 3.021 s, modified median 2.289 s, speed-up 1.32x, noise 0.072 s: PASS
  - original runs: [3.002 2.983 3.089 3.127 3.021]; modified runs: [2.281 2.289 2.293 2.29 2.26]
- readABRXNFile calls: original 13, modified 7 (3r+1 = 7 for r = 2): PASS
- addBondMappingsRXNFile calls: original 5, modified 5: PASS
- energy table constructions: original 1202, modified 28; energy rows appended: modified 28: PASS
- peak memory VmHWM: original 1.5842e+06 kB, modified 1.63059e+06 kB (capture 1.57272e+06 kB): PASS

### phe (14 rxns, 42 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 13 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS
- timing (5 alternating runs): original median 7.683 s, modified median 5.393 s, speed-up 1.42x, noise 0.092 s: PASS
  - original runs: [7.606 7.629 7.683 7.706 7.789]; modified runs: [5.328 5.365 5.417 5.393 5.447]
- readABRXNFile calls: original 68, modified 40 (3r+1 = 40 for r = 13): PASS
- addBondMappingsRXNFile calls: original 27, modified 27: PASS
- energy table constructions: original 4814, modified 298; energy rows appended: modified 298: PASS
- peak memory VmHWM: original 1.59458e+06 kB, modified 1.63826e+06 kB (capture 1.58396e+06 kB): PASS

### andest (29 rxns, 69 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 28 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS
- timing (5 alternating runs): original median 17.783 s, modified median 11.687 s, speed-up 1.52x, noise 0.130 s: PASS
  - original runs: [17.78 17.77 18 17.74 17.99]; modified runs: [11.73 11.69 11.68 11.7 11.66]
- readABRXNFile calls: original 143, modified 85 (3r+1 = 85 for r = 28): PASS
- addBondMappingsRXNFile calls: original 57, modified 57: PASS
- energy table constructions: original 13149, modified 683; energy rows appended: modified 683: PASS
- peak memory VmHWM: original 1.59293e+06 kB, modified 1.63956e+06 kB (capture 1.59646e+06 kB): PASS

### chol (61 rxns, 125 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 60 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS
- timing (5 alternating runs): original median 48.568 s, modified median 30.759 s, speed-up 1.58x, noise 0.206 s: PASS
  - original runs: [48.54 48.68 48.42 48.83 48.57]; modified runs: [30.57 30.76 30.52 30.82 30.76]
- readABRXNFile calls: original 303, modified 181 (3r+1 = 181 for r = 60): PASS
- addBondMappingsRXNFile calls: original 121, modified 121: PASS
- energy table constructions: original 37233, modified 1519; energy rows appended: modified 1519: PASS
- peak memory VmHWM: original 1.58986e+06 kB, modified 1.66127e+06 kB (capture 1.61629e+06 kB): PASS

### urea (67 rxns, 132 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 66 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS
- timing (5 alternating runs): original median 23.039 s, modified median 15.499 s, speed-up 1.49x, noise 0.104 s: PASS
  - original runs: [22.93 22.95 23.08 23.04 23.14]; modified runs: [15.34 15.53 15.45 15.5 15.63]
- readABRXNFile calls: original 333, modified 199 (3r+1 = 199 for r = 66): PASS
- addBondMappingsRXNFile calls: original 133, modified 133: PASS
- energy table constructions: original 15703, modified 1175; energy rows appended: modified 1175: PASS
- peak memory VmHWM: original 1.59765e+06 kB, modified 1.64938e+06 kB (capture 1.6062e+06 kB): PASS

### tyr (127 rxns, 197 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 126 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS
- timing (5 alternating runs): original median 43.768 s, modified median 28.288 s, speed-up 1.55x, noise 0.480 s: PASS
  - original runs: [43.77 44.48 43.52 43.61 43.89]; modified runs: [28.08 28.57 28.45 28.29 27.99]
- readABRXNFile calls: original 633, modified 379 (3r+1 = 379 for r = 126): PASS
- addBondMappingsRXNFile calls: original 253, modified 253: PASS
- energy table constructions: original 35435, modified 2479; energy rows appended: modified 2479: PASS
- peak memory VmHWM: original 1.6198e+06 kB, modified 1.66821e+06 kB (capture 1.61776e+06 kB): PASS

### bileacid (145 rxns, 217 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 143 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS
- timing (5 alternating runs): original median 126.272 s, modified median 73.046 s, speed-up 1.73x, noise 0.690 s: PASS
  - original runs: [126 125.8 126.3 126.9 127.2]; modified runs: [72.41 73.16 73.25 73 73.05]
- readABRXNFile calls: original 718, modified 430 (3r+1 = 430 for r = 143): PASS
- addBondMappingsRXNFile calls: original 287, modified 287: PASS
- energy table constructions: original 96691, modified 4149; energy rows appended: modified 4149: PASS
- peak memory VmHWM: original 1.66114e+06 kB, modified 1.71519e+06 kB (capture 1.66341e+06 kB): PASS

### ci (3 rxns, 4 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 3 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS
- BondElmts block (T022): reproduces the returned column PASS; raises an error for index NaN, 0 and out of range: 3 of 3: PASS
- timing (5 alternating runs): original median 1.331 s, modified median 1.154 s, speed-up 1.15x, noise 0.010 s: PASS
  - original runs: [1.331 1.328 1.323 1.342 1.338]; modified runs: [1.15 1.154 1.147 1.168 1.161]
- readABRXNFile calls: original 18, modified 10 (3r+1 = 10 for r = 3): PASS
- addBondMappingsRXNFile calls: original 7, modified 7: PASS
- energy table constructions: original 280, modified 32; energy rows appended: modified 32: PASS
- peak memory VmHWM: original 1.67852e+06 kB, modified 1.71773e+06 kB (capture 1.70964e+06 kB): PASS

### ci_missing (3 rxns, 4 mets, decompBranch match)
- build error (default): original none, modified none: PASS
- outputs (default): all 12 isequaln: PASS
- outputs (dense): all 12 isequaln: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 2 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS
- timing (5 alternating runs): original median 1.235 s, modified median 1.093 s, speed-up 1.13x, noise 0.007 s: PASS
  - original runs: [1.223 1.23 1.235 1.237 1.238]; modified runs: [1.093 1.116 1.116 1.08 1.077]
- readABRXNFile calls: original 13, modified 7 (3r+1 = 7 for r = 2): PASS
- addBondMappingsRXNFile calls: original 5, modified 5: PASS
- energy table constructions: original 200, modified 20; energy rows appended: modified 20: PASS
- peak memory: not measured (derived CI-size fixture)

### ci_unparsable (3 rxns, 4 mets, decompBranch match)
- build error (default): original MATLAB:graphfun:digraph:InvalidTableSize: First variable in edge information table must be a 2-column array (numeric, cell, or string) of node names., modified MATLAB:graphfun:digraph:InvalidTableSize: First variable in edge information table must be a 2-column array (numeric, cell, or string) of node names.: PASS
- outputs (default): none produced by either version: PASS
- outputs (dense): none produced by either version: PASS
- class/sparsity of outputs: PASS
- checkABRXNFiles fields and counts: PASS
- bondMappings for 3 RXN files: 0 mismatches: PASS
- console rule (FR-009/R5): non-readABRXNFile sequence PASS, readABRXNFile counts PASS: PASS
  - stack frame only in original: `Error in buildAtomAndBondTransitionMultigraph (line 172)`
  - stack frame only in original: `Error in buildAtomAndBondTransitionMultigraph (line 260)`
  - stack frame only in original: `Error in checkABRXNFiles (line 154)`
  - stack frame only in original: `[> In buildAtomAndBondTransitionMultigraph (line 362)`
  - stack frame only in modified: `Error in buildAtomAndBondTransitionMultigraph (line 176)`
  - stack frame only in modified: `Error in buildAtomAndBondTransitionMultigraph (line 264)`
  - stack frame only in modified: `Error in checkABRXNFiles (line 164)`
  - stack frame only in modified: `[> In buildAtomAndBondTransitionMultigraph (line 366)`
- timing (5 alternating runs): original median 0.716 s, modified median 0.644 s, speed-up 1.11x, noise 0.007 s: PASS
  - original runs: [0.7116 0.7253 0.7262 0.716 0.7153]; modified runs: [0.642 0.6481 0.6438 0.6378 0.6489]
- readABRXNFile calls: original 11, modified 7 (3r+1 = 10 for r = 3): PASS
- addBondMappingsRXNFile calls: original 3, modified 3: PASS
- energy table constructions: original 120, modified 12; energy rows appended: modified 12: PASS
- peak memory: not measured (derived CI-size fixture)


## T030: every test in testReactingMoieties (2026-09-22, modified source)

All 9 PASS: testAddBondMappingsRXNFile, testBuildAtomAndBondTransitionMultigraph, testCanonicalBondKey, testCheckABRXNFiles, testClassifySubgraphIsomorphism, testConservedReactingMoieties, testCreateBIGraph, testIdentifyAtomEquivalenceClasses, testResolveAtomNodeIndex.

## T029: pufa (optional, FR-014)

Not run: no `pufa` snapshot was captured before the source edit (T010), and capture mode refuses to run on modified source.

## Summary (T032)

| Fixture | Speed-up (median, 5 alternating runs) | readABRXNFile calls | energy tables | Equality + console |
|---|---|---|---|---|
| nglycan | 3.021 -> 2.289 s (1.32x) | 13 -> 7 | 1,202 -> 28 | PASS |
| phe | 7.683 -> 5.393 s (1.42x) | 68 -> 40 | 4,814 -> 298 | PASS |
| andest | 17.783 -> 11.687 s (1.52x) | 143 -> 85 | 13,149 -> 683 | PASS |
| chol | 48.568 -> 30.759 s (1.58x) | 303 -> 181 | 37,233 -> 1,519 | PASS |
| urea | 23.039 -> 15.499 s (1.49x) | 333 -> 199 | 15,703 -> 1,175 | PASS |
| tyr | 43.768 -> 28.288 s (1.55x) | 633 -> 379 | 35,435 -> 2,479 | PASS |
| bileacid | 126.272 -> 73.046 s (1.73x) | 718 -> 430 | 96,691 -> 4,149 | PASS |
| ci | 1.331 -> 1.154 s (1.15x) | 18 -> 10 | 280 -> 32 | PASS |
| ci_missing | 1.235 -> 1.093 s (1.13x) | 13 -> 7 | 200 -> 20 | PASS |
| ci_unparsable | 0.716 -> 0.644 s (1.11x) | 11 -> 7 | 120 -> 12 | PASS (same digraph error as original) |

Per requirement:

- FR-001, FR-002, SC-001: PASS — all 12 outputs `isequaln` in default and dense mode, class and sparsity equal, on all 10 fixtures; the build error on `ci_unparsable` has the same identifier and message.
- FR-003: PASS — every `bondMappings` table equal (446 per-file tables across the 10 fixtures); energy tables built only where used (constructions = energy rows appended).
- FR-004: PASS — outputs equal; the `BondElmts` block reproduces the returned column and errors for NaN, 0 and out-of-range indices (T022).
- FR-005, SC-005: PASS — `readABRXNFile` calls = 3r + 1 on every fixture (bileacid 430 <= 431); `addBondMappingsRXNFile` call counts unchanged.
- FR-006: PASS — no cache constructs added; peak memory within the gate on all seven measured fixtures (see note).
- FR-007: PASS — `checkABRXNFiles` fields and counts equal on all fixtures and in `testCheckABRXNFiles`.
- FR-008, FR-009, SC-006, SC-007: PASS — no message statement changed in the diff; console rule PASS on all fixtures; the only console differences are stack-frame line numbers (listed under `ci_unparsable`).
- FR-010, SC-002: PASS — only the three source files changed; the two existing tests are unedited and pass.
- FR-011, FR-012: PASS — snapshots captured before the edit with provenance; timing, counts and memory reported above.
- FR-013, SC-003: PASS — both new tests pass on the modified source, and failed as expected (only at the four-input call) before it.
- SC-004: PASS — modified median below original median on every fixture (1.11x to 1.73x).
- FR-014, SC-008: not run (optional).

Not verified, or verified only partly:

- The two decompartmentalisation mismatch branches: no fixture reaches them (all fixtures take `match`).
- FR-009's permitted reduction of repeated `readABRXNFile` messages: no fixture's RXN files print any such message, so it is not exercised; every console line of every fixture was held to exact identity instead.
- `options.bondTransitionMultigraph = 0` is covered only by the existing `testBuildAtomAndBondTransitionMultigraph`, not by the golden-snapshot comparison.
- Peak memory: the modified version's minimum `VmHWM` is 39-71 MB (2.3-4.5%) above the original's on every fixture, within the 5% / 50 MB gate. The offset is about the same on the 3-reaction CI fixture as on bileacid, so it does not scale with model size. That points to a difference in process setup in the measurement (the "original" process loads the baseline copies and clears the function cache first), not to data retained by the change, but this has not been proven.
- tyr: the spec's assumed pre-existing bond residual of 3 is not present in the current corpus; tyr is consistent in both versions.
- `snapshots/` is 19 MB, above the 10 MB threshold: user decision pending before commit.
