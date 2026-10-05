# Feature Specification: Speed up identifyConservedReactingMoieties' bond-subgraph, reacting-bond-graph and CRB2R stages, without changing its results

**Feature Branch**: `20260921-154310-reacting-moiety-optimisation`

**Created**: 2026-09-21

**Status**: Draft

**Input**: User description: "Move the validated reacting-moiety optimisation prototype (`reconXmoieties/experiments/moietySizing/scripts/reactingOptimisation/`) into the toolbox so that `identifyConservedReactingMoieties` runs faster on large models WITHOUT changing its results. Three changes, all validated in the prototype: (1) the bond-subgraph extraction in `extractBondSubgraphs.m` and `findAndExtractMolecularGraphs.m` reads cached arrays instead of rebuilding graph tables on every step; (2) the two per-edge `find` loops that re-index the reacting bond graph (RBG) and the condensed reacting bond graph (Condensed_RBG) become one `ismember` each; (3) the per-bond scan that builds `CRB2R` becomes a sparse atom-to-reaction incidence look-up. Decisions made with the user: (a) all three prototype changes are in scope; (b) the optimised code replaces the function bodies in place and keeps their existing call forms, with no `*Fast` duplicates and no option flag to choose between old and new; (c) equivalence is evidenced by golden-snapshot comparison against the unmodified function on the seven fast fixtures plus the existing CI test passing unmodified, with `pufa` timed only as an optional demonstration. The most important requirement: this change MUST NOT break or alter the original functionality of `identifyConservedReactingMoieties`."

<!--
  Not a characterization-mode feature (Constitution Principle III, "Characterization:
  Legacy Back-Fill Mode"): identifyConservedReactingMoieties already has CI coverage in
  testConservedReactingMoieties.m and this feature changes how results are computed, not
  what they are. The "Existing Contract" section is therefore omitted; the current
  contract is captured under Requirements instead, because "preserve the existing
  contract exactly" is the feature's central requirement.
-->

## Background: what is measured, and why this matters

`identifyConservedReactingMoieties(model, BG, dATM, options)` takes the atom and bond graphs produced by `buildAtomAndBondTransitionMultigraph` and returns `arm`, `moietyFormulae` and `reacting`. Stage timings of the current function (feature 029 is merged into `develop`) show that on the larger subsystems most of its time is in a few identifiable stages, and that the stages this feature targets grow with model size:

| Targeted stage | What it does | bileacid (217 mets x 145 rxns), before | after, in the prototype |
|---|---|---|---|
| Bond-subgraph extraction and molecular-graph extraction (`extractBondSubgraphs`, `findAndExtractMolecularGraphs`, plus the two bond-to-component loops) | peels the bond instance graph into sets of mapped bonds | 31.4 s | 13.4 s |
| Reacting bond graph and condensed reacting bond graph re-indexing (two per-edge `find` loops) | rewrites edge end nodes to node positions and component ids | 2.7 s | 0.009 s |
| `CRB2R` build (per-bond scan of all atom transitions) | condensed-reacting-bond x reaction incidence | 0.19 s | small (not itemised) |

In the prototype the whole-function median time of `identifyConservedReactingMoieties` improved by 1.4x to 2.0x on the seven fast fixtures (for example bileacid 97.4 s to 49.4 s, tyrosine 31.8 s to 17.5 s) with `arm`, `moietyFormulae` and every field of `reacting` `isequal` to the unmodified function on every fixture, and the side-by-side "shadow" run of the original stage-09 functions matched on every fixture. (These figures come from the prototype's own run, on a generated copy of the function, not from the code in `src/`; they are the motivation and the reference, not acceptance criteria.) For larger inputs the identification step dominates the pipeline: a pufa run on 18 September (before feature 029) spent 1,326 s in `identifyConservedReactingMoieties` against 285 s in the build at 450 reactions, and did not finish in 3 h 48 min at 682 reactions. This feature does not by itself make full-size runs finish; it removes three measured costs.

## Clarifications

### Session 2026-09-21

- Q: Which prototype changes are in scope? → A: All three (bond-subgraph and molecular-graph extraction; RBG/Condensed_RBG re-indexing; CRB2R build). Other hotspots (atom transition graph stage, moiety transition graph stage, `identifyIsomorphicClasses`) are out of scope.
- Q: How does the optimised code land in `src/`? → A: The bodies of `extractBondSubgraphs.m` and `findAndExtractMolecularGraphs.m` are rewritten in place and the two stage blocks in `identifyConservedReactingMoieties.m` are edited in place. Existing call forms are kept; no `extractBondSubgraphsFast` / `findAndExtractMolecularGraphsFast` files are added to the toolbox, and there is no option to select the old code path.
- Q: (plan phase) FR-010 limited `identifyConservedReactingMoieties.m` edits to the RBG/Condensed_RBG and `CRB2R` blocks, but the Background counts the two bond-to-component loops in the targeted stage and FR-003/FR-004 provide an edge-index cache that only pays off if the caller passes it. Are the stage-09 call sites and the two bond-to-component loops in scope? → A: Yes. The two stage-09 call lines may change to request and pass the edge-index cache, and the two bond-to-component loops (STEP B4) may read it instead of `BMG{i}.Edges.EdgeIndex`. FR-010 and SC-005 are amended to say so.
- Q: What is the verification gate? → A: Golden snapshots of `arm`, `moietyFormulae` and `reacting` from the unmodified function on nglycan, phe, andest, chol, urea, tyr and bileacid, plus `testConservedReactingMoieties.m` passing unmodified. `pufa` is timed as an optional, non-gating demonstration, because a full-length unmodified `pufa` identification did not complete in 3 h 48 min.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Every existing caller gets exactly the same results as before (Priority: P1)

A researcher, or an existing script or test, calls `identifyConservedReactingMoieties` exactly as before. `arm`, `moietyFormulae` and `reacting` are the same as the pre-change function returned, in both modes (`options.conservedMoietiesOnly` 0 and 1), and every diagnostic the function prints or warns is unchanged.

**Why this priority**: this is the feature's gating requirement. A speed-up that changes one moiety assignment is worthless to a toolbox whose value rests on reproducible published analyses (Constitution Principles II and IV: performance MUST preserve numerical meaning first). It is the acceptance test for every other story.

**Independent Test**: run `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` unmodified and confirm it passes; separately run the golden-snapshot comparison (FR-011) on each covered fixture in both modes.

**Acceptance Scenarios**:

1. **Given** the CI fixture (`r0317`, `ACONTm`, `r0426` from Recon3D), **When** the function is called as `testConservedReactingMoieties.m` calls it, **Then** the test passes with none of its assertions edited, loosened or removed.
2. **Given** a golden snapshot of the unmodified function's `arm`, `moietyFormulae` and `reacting` on a fixture, **When** the modified function is called with the same inputs and default options, **Then** all three outputs are `isequaln` to the snapshot (every field of the `reacting` structure included).
3. **Given** `options.conservedMoietiesOnly = 1`, **When** the function is called on a covered fixture, **Then** `arm` and `moietyFormulae` are `isequaln` to the unmodified function's and no reacting-moiety stage is run, as today.
4. **Given** `options.sanityChecks = 1`, **When** the function is called on the CI fixture and on the tyrosine fixture, **Then** the results and every sanity-check outcome equal the unmodified function's.

---

### User Story 2 - Large models identify their moieties faster (Priority: P2)

A researcher runs the function on a larger subsystem or a genome-scale model. The bond-subgraph and molecular-graph extraction reads cached data instead of rebuilding graph tables at every step, the reacting bond graph is re-indexed with one vectorised look-up per graph, and `CRB2R` is built from a sparse incidence.

**Why this priority**: it is the reason the feature exists, but it is second because it is acceptable only if User Story 1 holds. It is testable at fixture scale without needing a full-size run.

**Independent Test**: time the whole function on each covered fixture (median of 3 runs) on the unmodified function at snapshot capture and on the modified function, and report both.

**Acceptance Scenarios**:

1. **Given** each of the seven covered fixtures, **When** the whole-function median time is measured before (recorded at snapshot capture) and after, **Then** the after median is not greater than the before median on any fixture, and both medians and the ratio are reported.
2. **Given** the bileacid fixture, **When** the targeted stages are timed, **Then** their combined time is reported before and after (reference: about 34 s before, about 13 s after, in the prototype). This is reported, not a gate.
3. **Given** inputs that do not meet the preconditions of an optimised construction (see Edge Cases), **When** the function is called, **Then** it returns the same results as the unmodified function, not an error.

---

### User Story 3 - The rewritten functions are covered by CI (Priority: P2)

A maintainer changing `extractBondSubgraphs.m` or `findAndExtractMolecularGraphs.m` later has an automated test that fails if their outputs drift.

**Why this priority**: neither function has a test file today, and Constitution Principle III requires automated coverage for changed behaviour. It is independently deliverable.

**Independent Test**: run the two new test files in CI; each passes on the self-contained fixture with no external data.

**Acceptance Scenarios**:

1. **Given** the CI fixture, **When** `testExtractBondSubgraphs.m` runs, **Then** `bondSubgraphs` and `BMG` equal the values captured from the unmodified function, and the optional extra output (if any) is consistent with `BMG`.
2. **Given** the CI fixture, **When** `testFindAndExtractMolecularGraphs.m` runs, **Then** its six outputs equal the values captured from the unmodified function.
3. **Given** inputs that violate an optimised construction's precondition, **When** the tests call the functions, **Then** the outputs equal the unmodified function's outputs on the same inputs (FR-007).

---

### Edge Cases

- **Non-integer or duplicated `AtomIndex`, or component labels outside `1..max(conncomp)`.** The prototype's extraction falls back to the original algorithm when its lookup-array preconditions fail. The modified function MUST produce the original results in that case, not an error and not a silently different answer.
- **Non-integer or non-positive atom indices when building `CRB2R`.** The prototype keeps the original loop as a fallback. The modified function MUST return the original `CRB2R` in that case.
- **A `BondIndex` that is not found.** The original prints `BondIndex %d not found.` once per missing bond and continues. This warning MUST fire under the same conditions with the same text.
- **Empty inputs.** Zero bond edges, zero reacting bonds, or zero reactions MUST produce the same outcome as today (including any error raised earlier in the function), not a new failure from vectorised construction. `createBIGraph` already returns an empty graph for zero-edge input (feature 029).
- **Order of results.** The order of cells in `bondSubgraphs`/`BMG`, of edges within each graph, and the numbering of groups feed later stages and the final `reacting` tables. Any order the original produces MUST be reproduced, except where the original order is demonstrably irrelevant downstream and the plan says so (the prototype compares edge-index sets sorted, because only set membership is used downstream).
- **Set-cover solver.** The reacting-moiety selection uses a MILP set cover. If a solver returned a different but equally optimal cover, `reacting` would differ. The golden snapshots MUST be captured and compared with the same solver and settings, and a mismatch on the selection MUST be investigated, not tolerated.
- **Legacy back-compat options.** `options.useOpenSourceMoietyTools = 0` and `options.conservedMoietiesOnly = 1` MUST keep behaving as they do today.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001 (top-level, non-regression)**: This change MUST NOT break or alter the original functionality of `identifyConservedReactingMoieties`. Its signature, the names and order of its outputs, the default behaviour of every existing option, and the values of `arm`, `moietyFormulae` and every field of `reacting` MUST be unchanged.
- **FR-002**: `arm`, `moietyFormulae` and `reacting` MUST be `isequaln` to the pre-change function's on every covered fixture, for default options and for `options.conservedMoietiesOnly = 1` (where `reacting` is not produced), and with `options.sanityChecks = 1` on at least the CI fixture and the tyrosine fixture.
- **FR-003**: `extractBondSubgraphs` MUST keep its call form `[bondSubgraphs, BMG] = extractBondSubgraphs(BIG, ATG)` and return `bondSubgraphs` and `BMG` identical to the pre-change function's. An additional optional trailing output for the per-graph edge-index cache MAY be added if the plan needs it; callers using two outputs MUST be unaffected.
- **FR-004**: `findAndExtractMolecularGraphs` MUST keep its call form `[CMTG, RMTG, CMG, RMG, conservedGroup, reactingGroups] = findAndExtractMolecularGraphs(BIG, BMG, bondSubgraphs)` and return all six outputs identical to the pre-change function's. An optional trailing input carrying the edge-index cache MAY be added; a call without it MUST behave as before.
- **FR-005**: The bond-subgraph and molecular-graph extraction MUST NOT rebuild graph edge tables inside its per-edge and per-bond loops (the measured cost of the original); the plan MUST state which data-access change replaces it. The peeling algorithm itself (component-pair peeling, then layer-by-layer peeling of repeated bond instances) is unchanged.
- **FR-006**: The two per-edge `find` loops that re-index the RBG and Condensed_RBG end nodes MUST be replaced by a construction whose cost does not include one node-table scan per edge endpoint, and MUST give the same end-node arrays as before.
- **FR-007**: Every optimised construction whose correctness relies on a precondition (unique integer `AtomIndex`, component labels in `1..max(conncomp)`, positive integer atom indices) MUST fall back to, or otherwise reproduce, the original result when the precondition does not hold, and this MUST be exercised by a test where a small input can trigger it.
- **FR-008**: The `CRB2R` build MUST return the same matrix (same dimensions, same non-zeros, same sparsity class) as before, including for bonds that are not found in `BG.Edges`, for which the existing warning MUST still fire with the same text.
- **FR-009**: Every existing sanity check, `fprintf` diagnostic, `warning` and `error` in the three modified functions MUST fire under the same conditions with the same text. None may be removed, weakened or silenced to make a comparison pass (Constitution Principle IV).
- **FR-010**: Scope MUST be limited to `extractBondSubgraphs.m`, `findAndExtractMolecularGraphs.m`, and, in `identifyConservedReactingMoieties.m`, the two stage-09 call lines (to request and pass the edge-index cache of FR-003/FR-004), the two bond-to-component loops of STEP B4, and the RBG/Condensed_RBG re-indexing and `CRB2R` blocks, plus the new tests. The atom transition graph stage, the moiety transition graph stage, `identifyIsomorphicClasses`, `createBIGraph` and `buildAtomAndBondTransitionMultigraph` are OUT of scope and MUST NOT be changed; they MAY be recorded as candidate follow-up features. The prototype's `*Fast` files MUST NOT be added to `src/`, and no option to select old versus new code MUST be added. `testConservedReactingMoieties.m` MUST NOT be edited, and its assertions MUST all pass.
- **FR-011**: The feature MUST include a documented, non-CI reproducibility check following the feature 029 pattern (`specs/029-vectorize-atm-loops/vectorizationReproducibilityCheck.m` on `develop`), with golden snapshots captured from the **unmodified** function on `develop` BEFORE any source change. It MUST cover nglycan, phe, andest, chol, urea, tyr and bileacid, in default mode and in `conservedMoietiesOnly = 1` mode, and MUST compare `arm`, `moietyFormulae` and every field of `reacting` with `isequaln`. Each snapshot MUST record corpus and model provenance (corpus path, file count, subsystem model file) and the solver used, so that a data change is never mistaken for a code regression.
- **FR-012**: The check MUST report, not merely assert, the whole-function median time of `identifyConservedReactingMoieties` over 3 runs on each fixture, before (recorded with the snapshot from the unmodified function) and after (measured by the check on the modified function), and MUST fail if the after median exceeds the before median on any fixture. It MUST also report the time of the targeted stages on bileacid, before and after.
- **FR-013 (CI coverage, Principle III)**: The feature MUST add `test/verifiedTests/analysis/testReactingMoieties/testExtractBondSubgraphs.m` and `testFindAndExtractMolecularGraphs.m` (one test file per function under Principle III-Naming), runnable within `test/testAll.m` and CI on the self-contained CI fixture, with no external data. Expected values MUST come from the unmodified functions, captured before the change. They MUST declare their requirements with `prepareTest`, keep console output minimal, and MUST NOT suppress warnings or use `evalc` except as Principle VII permits.
- **FR-014 (optional, not a gate)**: The feature MAY include a non-CI timing of `pufa` (682 reactions) on the modified function. Its outcome, including non-completion, MUST be recorded but MUST NOT gate acceptance.

### Key Entities

- **Bond instance graph (BIG) and atom transition graph (ATG)**: the inputs to `extractBondSubgraphs`; BIG holds every bond instance, ATG's connected components group atoms that map onto each other.
- **`bondSubgraphs`, `BMG`**: cell arrays of sets of mapped bonds and the graphs of those sets.
- **RBG, Condensed_RBG**: the reacting bond graph on atoms and its condensed form on atom-transition components.
- **`CRB2R`**: matrix of condensed reacting bonds by reactions.
- **Golden snapshot**: the outputs of the unmodified function per fixture and mode, captured before any source change, with provenance and the before timings.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001 (top-level, non-regression)**: On each of the seven covered fixtures, in default and `conservedMoietiesOnly = 1` modes, `arm`, `moietyFormulae` and (default mode) every field of `reacting` are `isequaln` to the golden snapshot. Zero mismatches are permitted.
- **SC-002**: `testConservedReactingMoieties.m` passes and is not edited (verifiable by `git diff` showing no change to that file).
- **SC-003**: `testExtractBondSubgraphs.m` and `testFindAndExtractMolecularGraphs.m` exist at the FR-013 paths, run in CI without external data, and pass, including the precondition-fallback cases.
- **SC-004**: On every covered fixture, the after median whole-function time is not greater than the before median, and all before and after medians and ratios are reported. (The prototype's reference range is 1.4x to 2.0x; that is reported for comparison and is not a pass threshold.)
- **SC-005**: A `git diff` against `develop` shows changes only to `extractBondSubgraphs.m`, `findAndExtractMolecularGraphs.m`, the stage-09 call lines, the two STEP B4 bond-to-component loops and the RBG/Condensed_RBG and `CRB2R` blocks of `identifyConservedReactingMoieties.m`, and the added tests, their fixture file `test/verifiedTests/analysis/testReactingMoieties/data/bondSubgraphReference.mat`, the spec artefacts and Spec Kit metadata (`CLAUDE.md` plan pointer, `.specify/feature.json`); no sanity check, warning or error statement is altered.
- **SC-006**: The console output (printed lines and warnings) of the modified function on each covered fixture equals the unmodified function's, recorded with the snapshots.
- **SC-007 (optional, not a gate)**: If a `pufa` timing is run, its outcome and time are recorded.

## Assumptions

- **Base branch**: this feature is branched from `develop` at `64efe1dc8`, which contains feature 029 (`createBIGraph` and stage-02 vectorisation), the sparse bond matrices feature, and the 026/027 conserved-only option and equivalence test. The prototype was derived from commit `1080f0be5` (029), which is an ancestor of `develop`, so the code being optimised matches the prototype's base.
- **Prototype status**: the prototype (`identifyConservedAndReactingMoietiesOptimised.m`, `extractBondSubgraphsFast.m`, `findAndExtractMolecularGraphsFast.m`, generated by `patch_reacting_optimisations.py`) is reference material for the plan, not source to be copied unreviewed. It is a generated, instrumented copy and lives in `reconXmoieties`, outside this repository.
- **Fixture data are external**: the seven fixtures depend on the subsystem submodels (`subsystemSubModels.mat`) and the atom-mapped RXN corpus outside the repository, so the reproducibility check is not CI-runnable; the CI fixture is self-contained.
- **Solver determinism**: the prototype's `reacting` output matched the unmodified function on all seven fixtures with the same solver; the check assumes the same solver and settings are used for the snapshot and the comparison.
- **Timing noise**: whole-function timings vary a few percent run to run, so "not slower" is judged on the median of 3 runs, and a shortfall inside that noise is investigated by repeating the measurement before being treated as a failure.
- **Remaining hotspots**: after this change the atom transition graph stage (superlinear in the prototype's timings), the moiety transition graph stage and the `addBondInfoToMTG` stage remain, and the per-reaction graph rebuild inside `buildAtomAndBondTransitionMultigraph` is unchanged. They are candidate follow-up features.

## Traceability

| Acceptance criterion | Discharging test | src/analysis/topology/reactingMoieties/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-010, SC-002 | testConservedReactingMoieties.m (unmodified) | identifyConservedReactingMoieties |
| US1 / FR-002, FR-011, SC-001, SC-006 | golden-snapshot reproducibility check (029 pattern), default and conserved-only modes | identifyConservedReactingMoieties, extractBondSubgraphs, findAndExtractMolecularGraphs |
| US1 / FR-009, SC-005 | -- (static `git diff` review of sanity-check, warning and error statements; no source function of its own) | -- (no source function) |
| US2 / FR-005, FR-006, FR-012, SC-004 | golden-snapshot reproducibility check, timing report | identifyConservedReactingMoieties, extractBondSubgraphs, findAndExtractMolecularGraphs |
| US1 / FR-008 | testConservedReactingMoieties.m and the reproducibility check (strict class/sparsity comparison) | identifyConservedReactingMoieties |
| US3 / FR-003, FR-007, FR-013, SC-003 | testExtractBondSubgraphs.m (new, CI fixture) | extractBondSubgraphs |
| US3 / FR-004, FR-007, FR-013, SC-003 | testFindAndExtractMolecularGraphs.m (new, CI fixture) | findAndExtractMolecularGraphs |
| FR-010 (scope) | -- (static `git diff` and plan Constitution Check; no source function of its own) | -- (no source function) |
| FR-014, SC-007 (optional) | -- (non-CI timing; not a gate) | -- (no source function) |
