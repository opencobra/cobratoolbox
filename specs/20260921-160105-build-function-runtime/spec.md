# Feature Specification: Cut the redundant RXN-file work and the per-bond element loop in buildAtomAndBondTransitionMultigraph, without changing its outputs

**Feature Branch**: `20260921-160105-build-function-runtime`

**Created**: 2026-09-21

**Status**: Draft

**Input**: User description: "Make `buildAtomAndBondTransitionMultigraph` faster on larger models, WITHOUT changing what it returns, based on a line-level MATLAB profile of the function (bileacid, chol, andest). Three changes: (1) `addBondMappingsRXNFile` builds a one-row `energy` table on every iteration of its per-row loop although only two branches use it, so build it only where it is used; (2) the loop that fills `dBTM.Nodes.BondElmts` one element at a time into a digraph's node table becomes a single vectorised assignment; (3) each RXN file is currently parsed five times per reaction (twice in `checkABRXNFiles`, once in the atom loop, twice in the bond loop, counting the parse inside `addBondMappingsRXNFile`), so each pass parses it at most once by handing the parsed result to `addBondMappingsRXNFile`. Decisions made with the user: (a) repeated parse-time messages (the same warning or diagnostic printed once per parse) MAY be printed fewer times, because repeating an identical message gives no benefit, but every distinct message MUST still appear at least once and nothing else may change; (b) the redundant-parse reduction MUST be memory-bounded: no structure that holds parsed results for many reactions at once, so that full-VMH scale is not exposed to a new memory cost. The most important requirement: this change MUST NOT break or alter the original functionality of the function."

<!--
  Not a characterization-mode feature (Constitution Principle III, "Characterization:
  Legacy Back-Fill Mode"): the function already has CI coverage
  (testConservedReactingMoieties.m, testBuildAtomAndBondTransitionMultigraph.m) and this
  feature changes how the outputs are computed, not what they are. The "Existing Contract"
  section is therefore omitted; the current contract is captured under Requirements
  instead, because "preserve the existing contract exactly" is the central requirement.
-->

## Background: what is measured, and why this matters

The whole-function benchmark of the previous feature (sparse bond matrices) showed that the function's wall-clock time is dominated by work outside the three matrices it changed. A line-level profile of the current `develop` (MATLAB R2024b, one profiled run per fixture) shows where that time goes. Percentages are shares of the *profiled* time, which is 1.7x to 2.2x the unprofiled time because the profiler inflates call-heavy table code (profiled versus unprofiled seconds: andest 23.6 versus 10.7, chol 65.9 versus 31.8, bileacid 140.3 versus 82.9). They rank the costs; they are not predictions of wall-clock savings.

| Cost on bileacid (217 metabolites x 145 reactions) | Profiled seconds | Share | This feature |
|---|---|---|---|
| `checkABRXNFiles` (parses every RXN file twice; runs even with `sanityChecks = 0`) | 41.1 | 29% | fewer parses |
| `addBondMappingsRXNFile` call in the bond loop | 28.5 | 20% | energy table + fewer parses |
| of which, `energy = table(...)` built on every one of 96,691 row iterations, though used in two branches only | 21.6 | 15% | build where used |
| `dBTM.Nodes.BondElmts(i) = ...` per-bond loop (16,671 assignments into a digraph's node table) | 15.1 | 11% | vectorise |
| `readABRXNFile` overall: 718 calls for 143 reactions (five parses per reaction) | 53.8 | 38% | at most three parses per reaction |
| `identifyAtomEquivalenceClasses` (once per metabolite) | 14.6 | 10% | out of scope |

The per-bond cost of the `BondElmts` loop grows with model size (about 0.34 ms, 0.61 ms and 0.91 ms per bond node at 3,189, 7,397 and 16,671 bond nodes), so the loop is worse than linear; how much worse at pufa or full-VMH size has not been measured. The per-reaction `addnode(dATM, ...)` graph copy and the per-reaction `ismember` scans, which an earlier reading of the code suggested, fall below the profiler's 0.3% reporting threshold at these sizes and are not targeted.

Summing the three targeted costs (about 21.6 s for the energy table, 15 s for the `BondElmts` loop, and about two of the five parses, roughly 21 s) gives about 58 of the 140 profiled seconds on bileacid. The wall-clock gain will be smaller because of profiler inflation; it is measured, not assumed, by the gate below.

## Clarifications

### Session 2026-09-21

- Q: Repeated parse-time messages: the same warning or diagnostic from `readABRXNFile` currently prints up to five times per reaction, once per parse. Keep the exact repetition, or accept fewer repeats? → A: Accept fewer repeats. Every distinct message must still appear at least once and no other console output or warning may change.
- Q: Memory at full-VMH scale: how should redundant parses be removed? → A: Memory-bounded. Do not keep parsed results for all reactions (a cache that grows with the number of reactions). Hand the result of one parse to `addBondMappingsRXNFile` within the same pass; each pass may still parse a reaction once.
- Q: Which further costs are in scope? → A: Only the three above. The per-bond loops inside `readABRXNFile` (about two thirds of that function's time), `identifyAtomEquivalenceClasses`, the atom loop and the per-reaction graph handling are candidate follow-ups.

### Session 2026-09-22

- Q: The console lines that give source locations (warning backtrace lines such as `> In readABRXNFile (line 73)`, and `getReport`'s `Error in <file> (line N)` lines plus the source line it echoes) change when code moves or when a parse moves out of `addBondMappingsRXNFile`. Do they count as altered console lines? → A: No. They are location information, not message text. They are removed from both texts before FR-009's rule is applied, and every one that differs is listed in the results for review.
- Q: The first mapped reaction is also read once by the atom-side decompartmentalisation check, which lies outside the three passes. Does "at most 3 per reaction" include that read? → A: No. Each pass reads each reaction at most once; the one decompartmentalisation read is extra, so the total is at most 3r + 2.
- Q: What is the "small constant" allowed for peak memory? → A: 5% of the original's peak resident memory (`VmHWM`) or 50 MB, whichever is larger.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Every existing caller sees exactly the same results as before (Priority: P1)

A researcher, or an existing script or test, calls `buildAtomAndBondTransitionMultigraph` exactly as before. All twelve outputs are the same, both decompositions still hold, and every check, warning and error behaves as before, except that an identical parse-time message from an RXN file may now be printed fewer times.

**Why this priority**: this is the gating requirement. A speed-up that changes one output is worthless to a toolbox whose value rests on reproducible published analyses (Constitution Principles II and IV: performance MUST preserve numerical meaning first). It is the acceptance test for every other story.

**Independent Test**: run `testConservedReactingMoieties.m` and `testBuildAtomAndBondTransitionMultigraph.m` unmodified and confirm both pass; separately run the golden-snapshot comparison (FR-011) on each covered fixture.

**Acceptance Scenarios**:

1. **Given** the CI fixture and `options.sanityChecks = 1`, **When** the function is called with no new option, **Then** it returns without error, and `testConservedReactingMoieties.m` and `testBuildAtomAndBondTransitionMultigraph.m` pass with none of their assertions edited.
2. **Given** a golden snapshot of the original function's twelve outputs on a fixture, **When** the modified function is called on the same inputs in default mode and with `options.denseBondMatrices = 1`, **Then** all twelve outputs are `isequaln` to the snapshot (the three bond matrices compared by value, with class and sparsity checked separately as in the previous feature).
3. **Given** any covered fixture, **When** the function is called, **Then** both verified decompositions hold, and the same inconsistency warnings fire as for the original function (including tyrosine's pre-existing bond residual of 3, whose printed report is unchanged).
4. **Given** an RXN file that fails to parse, is missing, or is decompartmentalised, **When** the function is called, **Then** the outcome (skipped reaction, message text, which outputs are produced) is the same as the original function's for each of the three passes.
5. **Given** `options.bondTransitionMultigraph = 0`, **When** the function is called, **Then** its behaviour is unchanged.

---

### User Story 2 - Building the graphs takes less time on larger models (Priority: P2)

A researcher runs the function on a larger subsystem or a genome-scale model. The energy pseudo-node table is built only where it is used, the bond-element column is filled in one assignment, and each RXN file is parsed at most once per pass instead of up to twice within a pass.

**Why this priority**: it is the reason the feature exists, but it is second because it is acceptable only if User Story 1 holds. It is testable at fixture scale without a multi-hour run.

**Independent Test**: time the original and the modified function on each covered fixture with the alternating-order benchmark method of the previous feature and report both.

**Acceptance Scenarios**:

1. **Given** each covered fixture, **When** the whole-function median time is measured for the original and the modified function (alternating order), **Then** the modified median is not greater than the original median on any fixture beyond the measured run-to-run noise (repeat before treating a shortfall as failure), and both medians and the ratio are reported.
2. **Given** the bileacid fixture, **When** the number of `readABRXNFile` calls is counted, **Then** it is at most once per reaction with an RXN file in each pass, plus the one decompartmentalisation read (≤ 431 in total for 143 reactions, expected 430, down from 718), and no data structure holding parsed results for more than one reaction at a time exists.
3. **Given** the bileacid fixture, **When** the per-row `energy` table constructions in `addBondMappingsRXNFile` are counted, **Then** they equal the number of reacting-bond rows that use one, not the number of rows.

---

### User Story 3 - The changed helpers are covered by CI (Priority: P2)

A maintainer changing `addBondMappingsRXNFile.m` or `checkABRXNFiles.m` later has an automated test that fails if their outputs drift.

**Why this priority**: neither function has a test file today, and Constitution Principle III requires automated coverage for changed behaviour. It is independently deliverable.

**Independent Test**: run the two new test files in CI; each passes on the self-contained CI fixture with no external data.

**Acceptance Scenarios**:

1. **Given** each RXN file of the CI fixture, **When** `testAddBondMappingsRXNFile.m` calls `addBondMappingsRXNFile` with and without a pre-parsed `atoms`/`bonds` input, **Then** both calls return `bondMappings` tables that are `isequaln` to each other and to the table captured from the unmodified function.
2. **Given** the CI fixture, **When** `testCheckABRXNFiles.m` runs `checkABRXNFiles`, **Then** every quality-check field of `modelOut` and both transition counts equal the values captured from the unmodified function.
3. **Given** a reaction whose RXN file is absent or unparsable in a small derived fixture, **When** the tests run, **Then** the outcomes equal the unmodified function's.

---

### Edge Cases

- **Unparsable or missing RXN files.** Each of the three passes (check, atom loop, bond loop) currently parses independently and reports a failure in its own words. That per-pass behaviour MUST be kept: a file that fails to parse still produces the same messages in each pass and the reaction is skipped exactly as before.
- **Decompartmentalised RXN files.** The decompartmentalisation test is made once from the first reaction; its outcome and the resulting metabolite handling MUST be unchanged.
- **Pre-parsed inputs to `addBondMappingsRXNFile`.** When atoms and bonds already parsed from the same file are supplied, the result MUST equal what the function returns when it parses the file itself. Supplying nothing MUST behave exactly as today (existing two-argument callers are unaffected).
- **Energy table state.** Today a fresh `energy` row is built on every loop iteration, so nothing carries from one iteration to the next. Building it inside each branch MUST give the same rows, values, order and table variable types.
- **`BondElmts` indexing.** Today the assignment indexes `dATME.Nodes.Element` with each node's `BondHeadAtomIndex` and `BondTailAtomIndex` (the variable names are swapped in the source; the element order in the resulting string, tail-index element then head-index element, MUST be reproduced exactly). An invalid or `NaN` index MUST still raise an error, and an empty node table MUST behave as today.
- **Message repetition.** A message printed by `readABRXNFile` for a file may now appear fewer times, never zero times. Console lines printed by `checkABRXNFiles`, the atom and bond loops and the end-of-function checks (including the "RXN file with atom mapping summary" block and the per-reaction "Reading RXN file for reaction" line) MUST be unchanged in text and order.
- **Large models.** Peak memory of the modified function MUST NOT exceed that of the original by more than 5% of the original's peak resident memory (`VmHWM`) or 50 MB, whichever is larger, on any covered fixture, and MUST NOT grow with the number of reactions through a retained parse cache.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001 (top-level, non-regression)**: This change MUST NOT break or alter the original functionality of `buildAtomAndBondTransitionMultigraph`. Its signature, the names, order, dimensions and values of its twelve outputs, and the default behaviour of every existing option MUST be unchanged; the only permitted observable difference is that an identical parse-time message from an RXN file MAY be printed fewer times (FR-009).
- **FR-002**: With default options and with `options.denseBondMatrices = 1`, all twelve outputs MUST be `isequaln` to the pre-change function's, with class and sparsity checked separately.
- **FR-003**: In `addBondMappingsRXNFile`, the `energy` row MUST be constructed only where it is used (the two reacting-bond branches), not on every row iteration. The returned `bondMappings` MUST be `isequaln` to the pre-change function's for every RXN file, including variable names, order and types.
- **FR-004**: In `buildAtomAndBondTransitionMultigraph`, the per-bond loop that fills `dBTM.Nodes.BondElmts` MUST be replaced by a construction whose cost does not include one digraph node-table assignment per bond. The resulting `BondElmts` column MUST be identical to the pre-change function's, including for nodes whose atom indices are invalid (which MUST still raise an error).
- **FR-005**: Each of the three passes over the reactions (the quality-check pass in `checkABRXNFiles`, the atom loop and the bond loop) MUST parse a reaction's RXN file at most once. `addBondMappingsRXNFile` MAY gain optional trailing inputs carrying an already-parsed `atoms` and `bonds`; its existing call form MUST keep working unchanged.
- **FR-006**: The redundant-parse reduction MUST be memory-bounded: parsed results MUST NOT be retained across reactions or across passes (no cache that grows with the number of reactions), so that peak memory does not grow with model size because of this change. The plan MUST state how this is met.
- **FR-007**: The quality-check outputs of `checkABRXNFiles` (every field added to `modelOut`, `nTotalAtomTransitions`, `nTotalBondTransitions`) MUST be identical to the pre-change function's, and its call form MUST be unchanged.
- **FR-008**: Every existing sanity check, `fprintf` diagnostic, `warning` and `error` in the modified functions MUST fire under the same conditions with the same text, except as FR-009 allows. None may be removed, weakened or silenced to make a comparison pass (Constitution Principle IV).
- **FR-009 (approved change of console output)**: A message that the original function emitted once per parse of the same RXN file (for example from `readABRXNFile`) MAY be emitted fewer times, provided it is still emitted at least once. No other console line, warning or error may be added, removed or altered, and the order of the unaffected lines MUST be unchanged. The header of each modified function MUST NOT claim otherwise. Stack-frame location lines (warning backtrace frames, and `getReport`'s `Error in … (line N)` frames with the source line it echoes) are not message text. They are exempt from this rule and are reported instead (see Clarifications, Session 2026-09-22).
- **FR-010**: Scope MUST be limited to the three changes above. `readABRXNFile.m`, `identifyAtomEquivalenceClasses.m`, the atom-loop body, the per-reaction graph handling and every other `src/` file are OUT of scope and MUST NOT be changed; they MAY be recorded as candidate follow-ups. `testConservedReactingMoieties.m` and `testBuildAtomAndBondTransitionMultigraph.m` MUST NOT be edited and MUST pass.
- **FR-011**: The feature MUST include a documented, non-CI reproducibility check following the previous feature's pattern, with golden snapshots captured from the **unmodified** function on `develop` BEFORE any source change. It MUST cover, at minimum, the seven fast fixtures (nglycan, phe, andest, chol, urea, tyr, bileacid) and the CI fixture, and MUST compare all twelve outputs in default and dense modes, the `checkABRXNFiles` outputs, and `addBondMappingsRXNFile`'s `bondMappings` for every RXN file of the fixtures. It MUST also capture the console output of the unmodified function and compare it under FR-009's rule, after removing stack-frame location lines from both texts and listing any that differ: every distinct line present in both, no line only in one, each line's count in the modified output not greater than in the original and at least 1 where the original count is at least 1, and identical counts for every line not printed by `readABRXNFile`. Each snapshot MUST record corpus and model provenance (corpus path, file count, subsystem model file).
- **FR-012**: The check MUST report, not merely assert, per fixture: the whole-function median time of the original and the modified function (alternating order, method of the previous feature's benchmark), the count of `readABRXNFile` calls, and the count of `energy` table constructions, before and after.
- **FR-013 (CI coverage, Principle III)**: The feature MUST add `test/verifiedTests/analysis/testReactingMoieties/testAddBondMappingsRXNFile.m` and `testCheckABRXNFiles.m` (one test file per function under Principle III-Naming), runnable in `test/testAll.m` and CI on the self-contained CI fixture with no external data. Expected values MUST come from the unmodified functions, captured before the change. They MUST declare requirements with `prepareTest`, keep console output minimal, and MUST NOT suppress warnings or use `evalc` except as Principle VII permits. Both MUST cover the with/without pre-parsed input equality (FR-005) and the missing or unparsable file behaviour (Edge Cases).
- **FR-014 (optional, not a gate)**: The feature MAY include a non-CI timing of `pufa` (682 reactions). Its outcome MUST be recorded but MUST NOT gate acceptance.

### Key Entities

- **RXN file parse (`atoms`, `bonds`)**: the tables `readABRXNFile` returns for one reaction; the unit of redundant work.
- **`bondMappings`**: `addBondMappingsRXNFile`'s table of bond transitions for one reaction, including the appended energy row for each reacting bond.
- **`BondElmts`**: the column of `dBTM.Nodes` giving each bond's element pair as a string.
- **Golden snapshot**: the outputs and console text of the unmodified function per fixture, captured before any source change, with provenance and the before timings.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001 (top-level, non-regression)**: On every covered fixture, all twelve outputs of the modified function are `isequaln` to the golden snapshot in default and dense modes; `checkABRXNFiles`'s outputs and every `bondMappings` table match; zero mismatches are permitted.
- **SC-002**: `testConservedReactingMoieties.m` and `testBuildAtomAndBondTransitionMultigraph.m` pass and are not edited (verifiable by `git diff`).
- **SC-003**: `testAddBondMappingsRXNFile.m` and `testCheckABRXNFiles.m` exist at the FR-013 paths, run in CI without external data, and pass, including the pre-parsed-input equality and the missing or unparsable file cases.
- **SC-004**: On every covered fixture the modified function's whole-function median time is not greater than the original's beyond measured run-to-run noise, and all medians and ratios are reported. The profile-based reference (a fraction of the profiled time) is reported for comparison and is not a pass threshold.
- **SC-005**: On bileacid, each of the three passes calls `readABRXNFile` at most once per reaction. The only other call is the one atom-side decompartmentalisation read, so the total is ≤ 3r + 2 (at most 431, expected 430, down from 718). The number of `energy` table constructions equals the number of rows that use one.
- **SC-006**: Console output under FR-009's rule holds on every covered fixture: the differences between the original's and the modified function's console text are only reduced repetitions of parse-time messages, each still present at least once.
- **SC-007**: A `git diff` against `develop` shows changes only to `buildAtomAndBondTransitionMultigraph.m`, `checkABRXNFiles.m`, `addBondMappingsRXNFile.m` and the added tests and spec artefacts, and none alters a sanity-check, warning or error statement other than as FR-009 allows.
- **SC-008 (optional, not a gate)**: If a `pufa` timing is run, its outcome and time are recorded.

## Assumptions

- **Base branch**: this feature is branched from `develop` at `64efe1dc8`, which contains feature 029, the sparse bond matrices and the 026/027 changes. It does not overlap in files with the separately specified reacting-moiety optimisation (which changes `identifyConservedReactingMoieties.m`, `extractBondSubgraphs.m` and `findAndExtractMolecularGraphs.m`), so the two can be developed and merged independently.
- **Profile status**: the profile is one run per fixture, so its percentages are indicative. The sizes at which the per-reaction graph handling starts to matter are unknown; it is not targeted here because it measured below 0.3% at bileacid size.
- **Expected effect**: with a memory-bounded design each reaction is still parsed three times (one per pass) instead of five, so the reduction of read time is about two fifths, not the four fifths a full cache would give. This is the price of FR-006 and is accepted.
- **Fixture data are external**: the seven fixtures depend on the subsystem submodels and the atom-mapped RXN corpus outside the repository, so the reproducibility check is not CI-runnable; the CI fixture is self-contained.
- **Tyrosine**: the pre-existing tyrosine bond inconsistency (residual 3, from `tym[c]` and `34hpp[c]` bond-count mismatches in the current corpus) is outside this feature; its results and printed report MUST simply be unchanged.
- **Candidate follow-ups (not in scope)**: the per-bond `sprintf`/map loops inside `readABRXNFile` (about two thirds of its time), `identifyAtomEquivalenceClasses` (about 10% profiled on bileacid), and the quality-check pass being skippable when only counts are needed.

## Traceability

| Acceptance criterion | Discharging test | src/analysis/topology/reactingMoieties/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-010, SC-002 | testConservedReactingMoieties.m and testBuildAtomAndBondTransitionMultigraph.m (unmodified) | buildAtomAndBondTransitionMultigraph |
| US1 / FR-002, FR-007, FR-011, SC-001, SC-006 | golden-snapshot reproducibility check (outputs, `checkABRXNFiles` fields, `bondMappings`, console text) | buildAtomAndBondTransitionMultigraph, checkABRXNFiles, addBondMappingsRXNFile |
| US1 / FR-008, FR-009, SC-007 | -- (static `git diff` review of messages, warnings and errors; no source function of its own) | -- (no source function) |
| US2 / FR-003, FR-004, FR-005, FR-006, FR-012, SC-004, SC-005 | golden-snapshot reproducibility check, timing and call-count report | buildAtomAndBondTransitionMultigraph, checkABRXNFiles, addBondMappingsRXNFile |
| US3 / FR-003, FR-005, FR-013, SC-003 | testAddBondMappingsRXNFile.m (new, CI fixture) | addBondMappingsRXNFile |
| US3 / FR-005, FR-007, FR-013, SC-003 | testCheckABRXNFiles.m (new, CI fixture) | checkABRXNFiles |
| FR-010 (scope), FR-006 (memory bound) | -- (static `git diff` and plan Constitution Check; no source function of its own) | -- (no source function) |
| FR-014, SC-008 (optional) | -- (non-CI timing; not a gate) | -- (no source function) |
