# Reacting-moiety optimisation reproducibility results

Append-only record for feature `20260921-154310-reacting-moiety-optimisation`.

## Baseline (T001, 2026-09-22)

| Check | Result |
|---|---|
| `git diff --quiet develop -- src/ test/` | clean (exit 0) |
| `git rev-parse HEAD` | `2e3f1bcc983ad37a5f23befd2a5eb322dd89b5fc` (spec commit on top of `develop` @ `64efe1dc8`) |
| Corpus `/media/JACK/repos/ctf/rxns/atomMapped_std` | present (17075 entries) |
| `~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/subsystemSubModels/subsystemSubModels.mat` | present |
| `test/models/mat/Recon3D_301.mat` | present |
| `changeCobraSolver('gurobi','MILP',0)` | true; `CBT_MILP_SOLVER = gurobi` |
| MATLAB | 24.2.0.3157250 (R2024b) Update 8 |

### Unit-test reference capture (T005)

`captureBondSubgraphReferences.m` on unmodified `src/` wrote
`test/verifiedTests/analysis/testReactingMoieties/data/bondSubgraphReference.mat` (203.8 kB). The capture
breakpoint fired at `identifyConservedReactingMoieties.m` line 847. `BIG` has 54 nodes and 60 edges;
`ATG` has 54 nodes and 54 edges. CI case: 26 bond subgraphs (16 conserved, 10 reacting).

Outcomes of the unmodified `extractBondSubgraphs` on the fallback cases. These are what the rewrite must
reproduce:

| Case | Outcome |
|---|---|
| `duplicateAtomIndex` | error `MATLAB:sizeDimensionsMustMatch`: Arrays have incompatible sizes for this operation. (`extractBondSubgraphs.m:56`) |
| `nonIntegerAtomIndex` | error `MATLAB:sizeDimensionsMustMatch`: Arrays have incompatible sizes for this operation. (`extractBondSubgraphs.m:56`) |
| `componentLabelOutOfRange` | ok (26 subgraphs) |
| `namedBIGNodes` | error `MATLAB:UndefinedFunction`: Undefined function 'eq' for input arguments of type 'cell'. (`extractBondSubgraphs.m:52`) |
| `zeroBIGEdges` | ok (0 subgraphs) |


### Run 2026-09-22 08:59 UTC — fixtures: nglycan,phe,andest,chol,urea,tyr,bileacid,ci; modes: default,conservedOnly

| Fixture | Mode | Run | Status | arm eq | moietyFormulae eq | reacting eq (differing fields) | console eq | median s before -> after (ratio) | targeted stages s before -> after | Solver | Corpus (.rxn) | Snapshot | Commit | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| nglycan | default | CAPTURE | CAPTURED | - | - | - | - | 1.43 -> - | - | gurobi | 17072 | in repo (0.1 MB) | 2e3f1bcc983a |  |
| nglycan | conservedOnly | CAPTURE | CAPTURED | - | - | - | - | - | - | gurobi | 17072 | in repo (0.1 MB) | 2e3f1bcc983a |  |
| phe | default | CAPTURE | CAPTURED | - | - | - | - | 2.75 -> - | - | gurobi | 17072 | in repo (0.3 MB) | 2e3f1bcc983a |  |
| phe | conservedOnly | CAPTURE | CAPTURED | - | - | - | - | - | - | gurobi | 17072 | in repo (0.3 MB) | 2e3f1bcc983a |  |
| andest | default | CAPTURE | CAPTURED | - | - | - | - | 6.84 -> - | - | gurobi | 17072 | in repo (0.6 MB) | 2e3f1bcc983a |  |
| andest | conservedOnly | CAPTURE | CAPTURED | - | - | - | - | - | - | gurobi | 17072 | in repo (0.6 MB) | 2e3f1bcc983a |  |
| chol | default | CAPTURE | CAPTURED | - | - | - | - | 19.56 -> - | - | gurobi | 17072 | in repo (2.1 MB) | 2e3f1bcc983a |  |
| chol | conservedOnly | CAPTURE | CAPTURED | - | - | - | - | - | - | gurobi | 17072 | in repo (2.1 MB) | 2e3f1bcc983a |  |
| urea | default | CAPTURE | CAPTURED | - | - | - | - | 9.85 -> - | - | gurobi | 17072 | in repo (1.4 MB) | 2e3f1bcc983a |  |
| urea | conservedOnly | CAPTURE | CAPTURED | - | - | - | - | - | - | gurobi | 17072 | in repo (1.4 MB) | 2e3f1bcc983a |  |
| tyr | default | CAPTURE | CAPTURED | - | - | - | - | 15.66 -> - | - | gurobi | 17072 | in repo (2.4 MB) | 2e3f1bcc983a |  |
| tyr | conservedOnly | CAPTURE | CAPTURED | - | - | - | - | - | - | gurobi | 17072 | in repo (2.3 MB) | 2e3f1bcc983a |  |
| bileacid | default | CAPTURE | CAPTURED | - | - | - | - | 45.96 -> - | 09: 42.32; 14-17: 4.14 (profiled, relative) | gurobi | 17072 | in repo (4.2 MB) | 2e3f1bcc983a |  |
| bileacid | conservedOnly | CAPTURE | CAPTURED | - | - | - | - | - | - | gurobi | 17072 | in repo (4.1 MB) | 2e3f1bcc983a |  |
| ci | default | CAPTURE | CAPTURED | - | - | - | - | 0.17 -> - | - | gurobi | 18 | in repo (0.0 MB) | 2e3f1bcc983a |  |
| ci | conservedOnly | CAPTURE | CAPTURED | - | - | - | - | - | - | gurobi | 18 | in repo (0.0 MB) | 2e3f1bcc983a |  |

### Run 2026-09-22 09:13 UTC — fixtures: ci,tyr; modes: sanity

| Fixture | Mode | Run | Status | arm eq | moietyFormulae eq | reacting eq (differing fields) | console eq | median s before -> after (ratio) | targeted stages s before -> after | Solver | Corpus (.rxn) | Snapshot | Commit | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ci | sanity | CAPTURE | CAPTURED (error outcome) | - | - | - | - | - | - | gurobi | 18 | in repo (0.0 MB) | 2e3f1bcc983a | : Inconsistent mapping of atoms to connected components. (identifyIsomorphicClasses:34) |
| tyr | sanity | CAPTURE | CAPTURED (error outcome) | - | - | - | - | - | - | gurobi | 17072 | in repo (0.0 MB) | 2e3f1bcc983a | : Inconsistent mapping of atom transition instances to each atom transition in A2Ti (identifyConservedReactingMoieties:499) |

### Notes on the sanity-mode capture (T007) and the CI baseline (T008)

- Both `sanity` captures (`sanityChecks = 1`) raise an error on unmodified `src/`. This is the crash that
  predates this feature, and the snapshot records it as the expected outcome.
  - `ci` fails in `identifyIsomorphicClasses:34` ("Inconsistent mapping of atoms to connected
    components."). That is the STEP B3 call, after `extractBondSubgraphs` and
    `findAndExtractMolecularGraphs` have run, so the `ci`/`sanity` comparison does exercise the rewritten
    stage-09 functions up to that point.
  - `tyr` fails at `identifyConservedReactingMoieties:499` ("Inconsistent mapping of atom transition
    instances to each atom transition in A2Ti"), which comes before any changed block. Its `sanity`
    comparison therefore only confirms that the early failure is unchanged; it does not exercise the
    rewrite.
- T008: `testConservedReactingMoieties.m` **passes** on unmodified `src/` (gurobi, R2024b), which is the
  SC-002 baseline.

### US3 tests on unmodified code (T012)

- `testExtractBondSubgraphs.m`: **PASS** on unmodified `src/`, covering the CI case and the 5 fallback cases.
- `testFindAndExtractMolecularGraphs.m`: **PASS** on unmodified `src/` (three-input form).
- CI selection dry run: `python3 .github/scripts/select_tests.py --changed <file listing extractBondSubgraphs.m>`
  gives `mode=selective`, 10/282 tests selected, including `testExtractBondSubgraphs`,
  `testFindAndExtractMolecularGraphs` and `testConservedReactingMoieties`.

### Run 2026-09-22 09:18 UTC — fixtures: ci,tyr,bileacid; modes: default,conservedOnly (timing gate off)

| Fixture | Mode | Run | Status | arm eq | moietyFormulae eq | reacting eq (differing fields) | console eq | median s before -> after (ratio) | targeted stages s before -> after | Solver | Corpus (.rxn) | Snapshot | Commit | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ci | default | COMPARE | TIMING (not gated) | yes | yes | yes | yes | 0.17 -> 0.23 (0.72x) | - | gurobi | 18 | in repo | 4081fb6d1c84+src-uncommitted |  |
| ci | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 18 | in repo | 4081fb6d1c84+src-uncommitted |  |
| tyr | default | COMPARE | EQUAL | yes | yes | yes | yes | 15.66 -> 10.20 (1.54x) | - | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |
| tyr | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |
| bileacid | default | COMPARE | EQUAL | yes | yes | yes | yes | 45.96 -> 28.63 (1.61x) | 09: 42.32 -> 21.57; 14-17: 4.14 -> 3.86 (profiled, relative) | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |
| bileacid | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |

### Synthetic re-indexing section — 2026-09-22 09:25 UTC

| Case | Block | Original outcome | Optimised outcome | Result |
|---|---|---|---|---|
| 1. condensed RBG, one edge | 14b | ok, double [1 2] | ok, double [1 2] | EQUAL |
| 2. condensed RBG, three edges | 14b | ok, double [3 2] | ok, double [3 2] | EQUAL |
| 3. condensed RBG, zero edges | 14b | ok, double [0 2] | ok, double [0 2] | EQUAL |
| 4. RBG re-index, zero edges | 14a | ok, double [0 2] | ok, double [0 2] | EQUAL |
| 5. RBG re-index, one edge | 14a | ok, double [1 2] | ok, double [1 2] | EQUAL |
| 6. CRB2R, zero condensed bonds | STEP3 | ok, double [0 2] | ok, double [0 2] | EQUAL |
| 7. CRB2R, BondIndex not found | STEP3 | ok, double [3 3], warning: BondIndex 2 not found. | ok, double [3 3], warning: BondIndex 2 not found. | EQUAL |
| 8. CRB2R, untouched bond (zero row) | STEP3 | ok, double [2 2] | ok, double [2 2] | EQUAL |
| 9. condensed RBG, NaN component | 14b | error MATLAB:subsassigndimmismatch | error MATLAB:subsassigndimmismatch | EQUAL |
| 10. CRB2R, headATM as a cell array | STEP3 | error MATLAB:UndefinedFunction | error MATLAB:UndefinedFunction | EQUAL |

### Run 2026-09-22 09:26 UTC — fixtures: nglycan,phe,andest,chol,urea,tyr,bileacid,ci; modes: default,conservedOnly

| Fixture | Mode | Run | Status | arm eq | moietyFormulae eq | reacting eq (differing fields) | console eq | median s before -> after (ratio) | targeted stages s before -> after | Solver | Corpus (.rxn) | Snapshot | Commit | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| nglycan | default | COMPARE | EQUAL | yes | yes | yes | yes | 1.43 -> 1.12 (1.27x) | - | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |
| nglycan | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |
| phe | default | COMPARE | EQUAL | yes | yes | yes | yes | 2.75 -> 1.98 (1.39x) | - | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |
| phe | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |
| andest | default | COMPARE | EQUAL | yes | yes | yes | yes | 6.84 -> 4.70 (1.46x) | - | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |
| andest | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |
| chol | default | COMPARE | EQUAL | yes | yes | yes | yes | 19.56 -> 13.46 (1.45x) | - | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |
| chol | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |
| urea | default | COMPARE | EQUAL | yes | yes | yes | yes | 9.85 -> 6.30 (1.56x) | - | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |
| urea | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |
| tyr | default | COMPARE | EQUAL | yes | yes | yes | yes | 15.66 -> 9.54 (1.64x) | - | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |
| tyr | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |
| bileacid | default | COMPARE | EQUAL | yes | yes | yes | yes | 45.96 -> 24.88 (1.85x) | 09: 42.32 -> 20.01; 14-17: 4.14 -> 0.06 (profiled, relative) | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |
| bileacid | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted |  |
| ci | default | COMPARE | TIMING (not gated) | yes | yes | yes | yes | 0.17 -> 0.13 (1.27x) | - | gurobi | 18 | in repo | 4081fb6d1c84+src-uncommitted |  |
| ci | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 18 | in repo | 4081fb6d1c84+src-uncommitted |  |

### Run 2026-09-22 09:36 UTC — fixtures: ci,tyr; modes: sanity

| Fixture | Mode | Run | Status | arm eq | moietyFormulae eq | reacting eq (differing fields) | console eq | median s before -> after (ratio) | targeted stages s before -> after | Solver | Corpus (.rxn) | Snapshot | Commit | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ci | sanity | COMPARE | EQUAL | - | - | same error | yes | - | - | gurobi | 18 | in repo | 4081fb6d1c84+src-uncommitted | error outcome:  |
| tyr | sanity | COMPARE | EQUAL | - | - | same error | yes | - | - | gurobi | 17072 | in repo | 4081fb6d1c84+src-uncommitted | error outcome:  |

## Scope review (T026; FR-009, FR-010, SC-005)

Reviewed against `develop` @ `64efe1dc8` on the working tree:

1. **Files.** The only `src/` files changed are `extractBondSubgraphs.m`, `findAndExtractMolecularGraphs.m`
   and `identifyConservedReactingMoieties.m`. Tests: `testExtractBondSubgraphs.m`,
   `testFindAndExtractMolecularGraphs.m` and `data/bondSubgraphReference.mat` are added;
   `testConservedReactingMoieties.m` is unchanged (`git diff --quiet develop -- <file>` exits 0). Everything
   else is under `specs/20260921-154310-reacting-moiety-optimisation/`, plus `CLAUDE.md` (plan pointer)
   and `.specify/feature.json`.
2. **Diagnostics.** `git diff develop -U0 -- src/` removes only one diagnostic line:
   `warning('BondIndex %d not found.', b);`. It reappears word for word, re-indented, in the STEP 3
   fallback loop, and the fast path emits the same text (`warning('BondIndex %d not found.', bondIdx(iMissing));`).
   No `error`, `fprintf` or `sanityChecks` line is removed or edited. The `verLessThan` guard and
   `error('Requires matlab R2015b+')` in `extractBondSubgraphs.m` are unchanged, and the original
   algorithm is kept word for word in the local function `extractBondSubgraphsByComponentScan`.
3. **Where `identifyConservedReactingMoieties.m` changed.** All hunks are inside the four permitted
   blocks: the stage-09 call lines 847 and 855, the STEP B4 loops (872–905), stage 14a/14b (1530–1571),
   and STEP 3 (1642–1661).
4. **No new files or options.** There are no `*Fast.m` files and no new `options.` field.
5. **Lint.** `checkcode` reports 38 messages on the modified file against 39 on `develop`, so there are no
   new ones. In `extractBondSubgraphs.m` all lint messages are inside the verbatim original fallback.
6. **Fallbacks unreachable from the public function.** The stage 14a, 14b and STEP 3 fallbacks cannot be
   reached through `identifyConservedReactingMoieties` (research R8). The evidence for them is: (a) each
   `else`/fallback branch is the original loop, moved word for word (checked above); and (b) the T022
   synthetic section, which runs word-for-word copies of the original and new blocks on 10 cases
   (zero rows, one row, a missing BondIndex, an untouched bond, a `NaN` component, a cell `headATM`).
   All 10 are `EQUAL`, and the two fallback cases raise the same error.

## Timing summary (T027, T028; FR-012, SC-004)

Whole-function time of `identifyConservedReactingMoieties`, `default` mode, median of 3 runs, gurobi,
MATLAB R2024b. "Before" is from unmodified `develop` (T006 capture); "after" is from the T024 COMPARE run.

| Fixture | Reactions | Before median s | After median s | Speed-up |
|---|---|---|---|---|
| nglycan | 3 | 1.43 | 1.12 | 1.27x |
| phe | 14 | 2.75 | 1.98 | 1.39x |
| andest | 29 | 6.84 | 4.70 | 1.46x |
| chol | 61 | 19.56 | 13.46 | 1.45x |
| urea | 67 | 9.85 | 6.30 | 1.56x |
| tyr | 127 | 15.66 | 9.54 | 1.64x |
| bileacid | 145 | 45.96 | 24.88 | 1.85x |
| ci (not gated) | 3 | 0.17 | 0.13 | 1.27x |

- **Gate (SC-004):** the after median is at or below the before median on all 7 subsystem fixtures.
  No fixture was `SLOWER`, so no re-measurement was needed (T027).
- **Prototype reference (not a gate):** 1.4x–2.0x on the same seven fixtures; bileacid 97.4 s → 49.4 s
  (1.97x) and tyrosine 31.8 s → 17.5 s (1.82x). The absolute times here are about half the prototype's.
  That is consistent with feature 029 and the sparse-bond-matrices feature being in `develop`, and with
  this run not being instrumented. The ratios fall within the prototype's range, except nglycan and phe,
  whose run times are dominated by stages this feature does not touch.
- **Targeted stages, bileacid (profiled, relative; FR-012):** stage 09 (bond-subgraph and
  molecular-graph extraction, STEP B1–B4) went from 42.32 s to 20.01 s, and stages 14–17 (RBG and
  Condensed_RBG re-indexing, CRB2R build, and the rest of the reacting-bond section up to STEP 4) from
  4.14 s to 0.06 s. Prototype reference: about 34 s → 13 s.
- **US2 scenario 3** (inputs outside the fast-path preconditions give the original result, not an error):
  covered by the US3 fallback cases in `testExtractBondSubgraphs.m` (T010, T015) and by T022 cases 9–10.

## Optional pufa timing (T029; FR-014, SC-007)

Not run in this implementation session. It is an optional, non-gating run of up to 4 h
(`CBT_RMO_FIXTURES=pufa CBT_RMO_TIMING_ONLY=1 CBT_RMO_TIMING_RUNS=1`, under `timeout 4h`). The user has
been offered it, and its outcome will be appended here if it is run.

## Polish checks (T030–T033)

- **T030, help headers:** `extractBondSubgraphs.m` and `findAndExtractMolecularGraphs.m` use the openCOBRA
  keyword blocks (`USAGE:`, `INPUTS:`, `OUTPUTS:`, `OPTIONAL OUTPUT:` / `OPTIONAL INPUT:`, `NOTE:`) with
  one space after `%`, argument lines indented four spaces with a colon, blank comment lines around
  keywords, and canonical signature spacing. They contain no agent-specific wording.
- **T031, Constitution VII:** no `evalc`, `nargin`, `warning('off')` or `warning off` in any new or changed
  line. The only `evalc` hit is a comment in the check script explaining that `diary` is used instead.
  Every `catch ME` in the new files records `ME.stack(1)`: via `describeError`, `errorTopFrame`, the
  synthetic-section diagnostic line, and the assert message in `testExtractBondSubgraphs.m`. No absolute
  path appears in `src/` or `test/`; the non-CI check scripts under `specs/` use the fixed external data
  paths, as feature 029 did. No MATLAB-conventions skill is registered, so adding a project skill is a
  proposed follow-up (research R12).
- **T032, harness:** `runTestSuite` with CI's selective filter for this change (10 tests): **8 passed,
  0 failed, 2 skipped**. `testMoieties` and `testBiomassPrecursorCheck` were skipped by `prepareTest`
  because this machine has no `statistics_toolbox` licence, which is unrelated to this feature. Passed:
  `testBuildAtomAndBondTransitionMultigraph`, `testCanonicalBondKey`, `testClassifySubgraphIsomorphism`,
  `testConservedReactingMoieties`, `testExtractBondSubgraphs`, `testFindAndExtractMolecularGraphs`,
  `testIdentifyAtomEquivalenceClasses`, `testResolveAtomNodeIndex`.
- **T033, quickstart:** step 1 (the three CI tests) was re-run as part of T032 and passed. Step 2 is the T024
  and T025 COMPARE runs above, all `EQUAL`; it was not repeated a second time, since no source changed
  after T024. Step 3 is the T026 scope review above.

## Follow-ups (T034; research R13; recorded only, none implemented)

- Atom transition graph stage (superlinear in the prototype's timings).
- Moiety transition graph stage and `addBondInfoToMTG`.
- `identifyIsomorphicClasses` on `CBSubgrahs`.
- `subgraph`/`addedge` construction inside `extractBondSubgraphs`, which is now the larger part of stage 09
  (about 20 s of the profiled bileacid run).
- The per-reaction graph rebuild inside `buildAtomAndBondTransitionMultigraph`.
- The `sanityChecks = 1` crashes that predate this feature: `identifyIsomorphicClasses:34` on the CI
  fixture, and `identifyConservedReactingMoieties:499` on tyr.
- A project skill for MATLAB coding conventions (Constitution VII-F).

### Run 2026-09-29 08:24 UTC — fixtures: nglycan,phe,andest,chol,urea,tyr,bileacid,ci; modes: default,conservedOnly (timing gate off)

| Fixture | Mode | Run | Status | arm eq | moietyFormulae eq | reacting eq (differing fields) | console eq | median s before -> after (ratio) | targeted stages s before -> after | Solver | Corpus (.rxn) | Snapshot | Commit | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| nglycan | default | COMPARE | EQUAL | yes | yes | yes | yes | 1.43 -> 0.86 (1.66x) | - | gurobi | 17072 | in repo | b5740477376f+src-uncommitted |  |
| nglycan | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | b5740477376f+src-uncommitted |  |
| phe | default | COMPARE | EQUAL | yes | yes | yes | yes | 2.75 -> 1.68 (1.64x) | - | gurobi | 17072 | in repo | b5740477376f+src-uncommitted |  |
| phe | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | b5740477376f+src-uncommitted |  |
| andest | default | COMPARE | EQUAL | yes | yes | yes | yes | 6.84 -> 3.76 (1.82x) | - | gurobi | 17072 | in repo | b5740477376f+src-uncommitted |  |
| andest | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | b5740477376f+src-uncommitted |  |
| chol | default | COMPARE | EQUAL | yes | yes | yes | yes | 19.56 -> 9.38 (2.08x) | - | gurobi | 17072 | in repo | b5740477376f+src-uncommitted |  |
| chol | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | b5740477376f+src-uncommitted |  |
| urea | default | COMPARE | EQUAL | yes | yes | yes | yes | 9.85 -> 4.89 (2.02x) | - | gurobi | 17072 | in repo | b5740477376f+src-uncommitted |  |
| urea | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | b5740477376f+src-uncommitted |  |
| tyr | default | COMPARE | EQUAL | yes | yes | yes | yes | 15.66 -> 8.73 (1.79x) | - | gurobi | 17072 | in repo | b5740477376f+src-uncommitted |  |
| tyr | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | b5740477376f+src-uncommitted |  |
| bileacid | default | COMPARE | EQUAL | yes | yes | yes | yes | 45.96 -> 18.63 (2.47x) | 09: 42.32 -> 11.82; 14-17: 4.14 -> 0.06 (profiled, relative) | gurobi | 17072 | in repo | b5740477376f+src-uncommitted |  |
| bileacid | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | b5740477376f+src-uncommitted |  |
| ci | default | COMPARE | TIMING (not gated) | yes | yes | yes | yes | 0.17 -> 0.13 (1.28x) | - | gurobi | 18 | in repo | b5740477376f+src-uncommitted |  |
| ci | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 18 | in repo | b5740477376f+src-uncommitted |  |

### Run 2026-09-30 08:12 UTC — fixtures: nglycan,phe,andest,chol,urea,tyr,bileacid,ci; modes: default,conservedOnly (timing gate off)

| Fixture | Mode | Run | Status | arm eq | moietyFormulae eq | reacting eq (differing fields) | console eq | median s before -> after (ratio) | targeted stages s before -> after | Solver | Corpus (.rxn) | Snapshot | Commit | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| nglycan | default | COMPARE | SLOWER (not gated) | yes | yes | yes | yes | 1.43 -> 1.56 (0.92x) | - | gurobi | 17072 | in repo | 858feabc15bc+src-uncommitted |  |
| nglycan | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | 858feabc15bc+src-uncommitted |  |
| phe | default | COMPARE | EQUAL | yes | yes | yes | yes | 2.75 -> 1.72 (1.60x) | - | gurobi | 17072 | in repo | 858feabc15bc+src-uncommitted |  |
| phe | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | 858feabc15bc+src-uncommitted |  |
| andest | default | COMPARE | EQUAL | yes | yes | yes | yes | 6.84 -> 4.28 (1.60x) | - | gurobi | 17072 | in repo | 858feabc15bc+src-uncommitted |  |
| andest | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | 858feabc15bc+src-uncommitted |  |
| chol | default | COMPARE | EQUAL | yes | yes | yes | yes | 19.56 -> 9.08 (2.15x) | - | gurobi | 17072 | in repo | 858feabc15bc+src-uncommitted |  |
| chol | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | 858feabc15bc+src-uncommitted |  |
| urea | default | COMPARE | EQUAL | yes | yes | yes | yes | 9.85 -> 3.79 (2.60x) | - | gurobi | 17072 | in repo | 858feabc15bc+src-uncommitted |  |
| urea | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | 858feabc15bc+src-uncommitted |  |
| tyr | default | COMPARE | EQUAL | yes | yes | yes | yes | 15.66 -> 5.41 (2.90x) | - | gurobi | 17072 | in repo | 858feabc15bc+src-uncommitted |  |
| tyr | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | 858feabc15bc+src-uncommitted |  |
| bileacid | default | COMPARE | EQUAL | yes | yes | yes | yes | 45.96 -> 11.86 (3.88x) | 09: 42.32 -> 11.33; 14-17: 4.14 -> 0.06 (profiled, relative) | gurobi | 17072 | in repo | 858feabc15bc+src-uncommitted |  |
| bileacid | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 17072 | in repo | 858feabc15bc+src-uncommitted |  |
| ci | default | COMPARE | TIMING (not gated) | yes | yes | yes | yes | 0.17 -> 0.12 (1.42x) | - | gurobi | 18 | in repo | 858feabc15bc+src-uncommitted |  |
| ci | conservedOnly | COMPARE | EQUAL | yes | yes | yes | yes | - | - | gurobi | 18 | in repo | 858feabc15bc+src-uncommitted |  |

### Run 2026-09-30 08:18 UTC — fixtures: nglycan,phe,andest,chol,urea,tyr,bileacid,ci; modes: sanity (timing gate off)

| Fixture | Mode | Run | Status | arm eq | moietyFormulae eq | reacting eq (differing fields) | console eq | median s before -> after (ratio) | targeted stages s before -> after | Solver | Corpus (.rxn) | Snapshot | Commit | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| nglycan | sanity | CAPTURE | ERROR | - | - | - | - | - | - | gurobi | 17072 | - | 858feabc15bc+src-uncommitted | reactingOptimisationCheck:srcModified: Refusing to CAPTURE: src/ differs from develop. (/home/jackmcgoldrick/cobratoolbox/specs/20260921-154310-reacting-moiety-optimisation/reactingOptimisationReproducibilityCheck.m:160) |
| phe | sanity | CAPTURE | ERROR | - | - | - | - | - | - | gurobi | 17072 | - | 858feabc15bc+src-uncommitted | reactingOptimisationCheck:srcModified: Refusing to CAPTURE: src/ differs from develop. (/home/jackmcgoldrick/cobratoolbox/specs/20260921-154310-reacting-moiety-optimisation/reactingOptimisationReproducibilityCheck.m:160) |
| andest | sanity | CAPTURE | ERROR | - | - | - | - | - | - | gurobi | 17072 | - | 858feabc15bc+src-uncommitted | reactingOptimisationCheck:srcModified: Refusing to CAPTURE: src/ differs from develop. (/home/jackmcgoldrick/cobratoolbox/specs/20260921-154310-reacting-moiety-optimisation/reactingOptimisationReproducibilityCheck.m:160) |
| chol | sanity | CAPTURE | ERROR | - | - | - | - | - | - | gurobi | 17072 | - | 858feabc15bc+src-uncommitted | reactingOptimisationCheck:srcModified: Refusing to CAPTURE: src/ differs from develop. (/home/jackmcgoldrick/cobratoolbox/specs/20260921-154310-reacting-moiety-optimisation/reactingOptimisationReproducibilityCheck.m:160) |
| urea | sanity | CAPTURE | ERROR | - | - | - | - | - | - | gurobi | 17072 | - | 858feabc15bc+src-uncommitted | reactingOptimisationCheck:srcModified: Refusing to CAPTURE: src/ differs from develop. (/home/jackmcgoldrick/cobratoolbox/specs/20260921-154310-reacting-moiety-optimisation/reactingOptimisationReproducibilityCheck.m:160) |
| tyr | sanity | COMPARE | EQUAL | - | - | same error | yes | - | - | gurobi | 17072 | in repo | 858feabc15bc+src-uncommitted | error outcome:  |
| bileacid | sanity | CAPTURE | ERROR | - | - | - | - | - | - | gurobi | 17072 | - | 858feabc15bc+src-uncommitted | reactingOptimisationCheck:srcModified: Refusing to CAPTURE: src/ differs from develop. (/home/jackmcgoldrick/cobratoolbox/specs/20260921-154310-reacting-moiety-optimisation/reactingOptimisationReproducibilityCheck.m:160) |
| ci | sanity | COMPARE | EQUAL | - | - | same error | yes | - | - | gurobi | 18 | in repo | 858feabc15bc+src-uncommitted | error outcome:  |
