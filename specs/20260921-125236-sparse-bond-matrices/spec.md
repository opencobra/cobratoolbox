# Feature Specification: Return buildAtomAndBondTransitionMultigraph's bond matrices as sparse, without changing its original behaviour

**Feature Branch**: `20260921-125236-sparse-bond-matrices`

**Created**: 2026-09-21

**Status**: Draft

**Input**: User description: "Make buildAtomAndBondTransitionMultigraph.m scale to full-VMH-size inputs (~14,647 reactions, ~11,857 metabolites) by fixing its three dense-matrix memory blowups, WITHOUT changing the function's original behaviour. `M2BiE` and `M2BiW` are allocated as dense `length(model.mets)` x `nBonds` doubles and `BTi2R` as `full(sparse(...))` of size `nTransInstances` x `nMappedRxns`, so a full-VMH call runs out of memory; the two per-metabolite fill loops that populate `M2BiE`/`M2BiW` also scan every bond node once per metabolite. Decisions made with the user: (1) the three matrices are returned sparse by default, with a new `options.denseBondMatrices` (default 0) that restores today's exact dense output; (2) scope is those three matrices and the two fill loops only; (3) equivalence is evidenced by golden-snapshot comparison against the original function's outputs (the non-CI reproducibility-check pattern of features 021/022) plus the existing CI test passing unmodified. The most important requirement: this change MUST NOT break or alter the original functionality of the function."

<!--
  Not a characterization-mode feature (Constitution Principle III, "Characterization:
  Legacy Back-Fill Mode"): the function already has CI coverage through
  testConservedReactingMoieties.m, and this feature changes an internal
  representation rather than back-filling a test. The "Existing Contract" section is
  therefore omitted; the current contract is captured under Requirements and
  Assumptions instead, because "preserve the existing contract exactly" is the
  feature's central requirement.
-->

## Background: what is measured, and why this matters

`buildAtomAndBondTransitionMultigraph` returns twelve outputs. Three of them are allocated as **full** matrices whose size is a product of two large counts, although each holds only about one non-zero value per row or column:

| Output | Shape | Non-zeros | Allocated as |
|---|---|---|---|
| `M2BiE` | metabolites x bonds | one per bond | dense double |
| `M2BiW` | metabolites x bonds | one per bond | dense double |
| `BTi2R` | bond transitions x mapped reactions | one per bond transition | `full(sparse(...))` |

For a full-VMH call (11,857 metabolites, 14,647 reactions) the atom-mapped corpus implies roughly 0.87 M bond nodes and 1.42 M bond transitions, so the three matrices would need about 82 GB + 82 GB + 167 GB (about 330 GB, 308 GiB) as allocated today, against about 65 MB if stored sparsely. (These are estimates from atom and bond counts measured over the corpus of atom-mapped reaction files, which includes explicit hydrogens, at about 72 atoms and 73 bonds per metabolite. The exact figures are not spec inputs; the ratio is.) Every other output of the function is between kilobytes and a few gigabytes. The dense allocations are what make a full-VMH call impossible on any ordinary machine.

## Clarifications

### Session 2026-09-21

- Q (raised during implementation, T005): the tyrosine fixture is already inconsistent in the original function (bond residual 3 and the bond inconsistency warning, caused by a tym[c]/34hpp[c] bond-count mismatch in the current RXN corpus, outside this feature's scope), so zero residual on tyrosine cannot be met. How should SC-003 treat it? → A: Require identical output: tyrosine's residuals, warnings and printed bond mismatch report must equal the original function's in both modes; zero residual remains required for the CI fixture.

- Q: How is the new sparse default and `options.denseBondMatrices` covered in CI, given Principle III requires an automated test and FR-011 forbids editing `testConservedReactingMoieties.m`? → A: Add a new CI test `test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m` on the self-contained CI fixture, asserting default-mode sparsity and value equality with dense mode, `denseBondMatrices = 1` giving full `double`, and zero decomposition residuals in both modes; the non-CI golden-snapshot check remains the evidence of equivalence to the original function.
- Q: How is the "not slower" fill-step timing (SC-005) measured, given run-to-run noise and that the original loops cannot be timed after replacement? → A: Time the `M2BiE`/`M2BiW` fill step only, as the median of 5 repeated `tic`/`toc` runs; the before median is recorded alongside the golden snapshot from the original function, the after median by the reproducibility check; pass if after median ≤ before median.
- Q: How is FR-007's requirement that the mismatch-report branch works and prints the same content with sparse matrices verified, given no current fixture triggers it? → A: The new CI test (FR-015) builds a small, deliberately stoichiometrically inconsistent fixture, asserts the "Inconsistent directed bond transition multigraph" warning fires in both modes, and asserts the printed report is identical between default and dense modes.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Every existing caller sees exactly the same results as before (Priority: P1)

A researcher, or an existing script or test, calls `buildAtomAndBondTransitionMultigraph` exactly as before, without knowing this feature exists. Every output has the same name, position, dimensions and values; both decompositions the function verifies still hold; every existing check, warning and error still behaves the same; and downstream code (`identifyConservedReactingMoieties` and the pipeline built on it) produces the same answers.

**Why this priority**: this is the feature's gating requirement. A memory saving that changes a single result is worthless to a toolbox whose value rests on reproducible published analyses (Constitution Principles II and IV: performance MUST preserve numerical meaning first). It is P1 and independently deliverable in the sense that it is the acceptance test for every other story.

**Independent Test**: run `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` unmodified and confirm it passes. Separately, run the golden-snapshot comparison (FR-012) on the tyrosine fixture and the CI fixture with default options and confirm all twelve outputs match the outputs captured from the original function, with the three matrices compared by value.

**Acceptance Scenarios**:

1. **Given** the CI fixture (`r0317`, `ACONTm`, `r0426` from Recon3D) and `options.sanityChecks = 1`, **When** the function is called with no new option, **Then** it returns without error and `testConservedReactingMoieties.m` passes with none of its assertions edited, loosened or removed.
2. **Given** a golden snapshot of the original function's twelve outputs on a fixture, **When** the modified function is called with default options on the same inputs, **Then** `dATM`, `metAtomMappedBool`, `rxnAtomMappedBool`, `M2Ai`, `Ti2R`, `dATME`, `BG`, `dBTM` and `TiE` are `isequal` to the snapshot, and `M2BiE`, `M2BiW` and `BTi2R` have the same dimensions and `isequal(full(new), snapshot)`.
3. **Given** any fixture, **When** the function is called with default options, **Then** the atomic decomposition `M2Ai*M2Ai'*N = M2Ai*Ti*Ti2R` and the bond decomposition `M2BiW*M2BiE'*N = M2BiE*BTiE*BTi2R` (over the bond-mapped metabolites) both hold with zero residual, and neither the "Inconsistent directed atom transition multigraph" nor the "Inconsistent directed bond transition multigraph" warning is raised.
4. **Given** `options.bondTransitionMultigraph = 0`, **When** the function is called, **Then** its behaviour is unchanged from today, including which outputs are produced, and the new option has no effect.
5. **Given** the ten existing call sites that destructure all twelve outputs (`testConservedReactingMoieties.m`, `tutorial_conservedAndReactingMoieties.m`, and eight reconXmoieties pilot scripts), **When** this feature is merged, **Then** none of them needs editing to keep working.

---

### User Story 2 - A full-size model can be built without exhausting memory on the three bond matrices (Priority: P2)

A researcher runs the function on a genome-scale, atom-mapped model. The three bond matrices are returned as sparse matrices, storing only their non-zero entries, and are filled in one pass over the bond nodes rather than by scanning every bond node once per metabolite.

**Why this priority**: it is the reason the feature exists, but it is second because it is only acceptable if User Story 1 holds. It is testable at fixture scale (storage ratio, time) without needing the multi-day full-VMH run.

**Independent Test**: on the tyrosine fixture (and any larger fixture available), call the function with default options; confirm the three matrices are sparse (`issparse`), and record their combined storage against the storage of the same matrices held dense.

**Acceptance Scenarios**:

1. **Given** a fixture with at least 50 metabolites and 50 reactions, **When** the function is called with default options, **Then** `M2BiE`, `M2BiW` and `BTi2R` are all sparse and their combined storage is at most 10% of their combined dense storage.
2. **Given** the tyrosine fixture, **When** the fill step for `M2BiE` and `M2BiW` is timed as the median of 5 repeated runs before this change (recorded with the golden snapshot) and after it, **Then** the after median is not greater than the before median, and both medians are reported.
3. **Given** a bond node whose `Met` is not a model metabolite (this reaction's energy pseudo-node), **When** `M2BiE` and `M2BiW` are built, **Then** its column is all zeros, exactly as today, and no error is raised.
4. **Given** a model metabolite with no bond nodes (for example a proton), **When** `M2BiE` and `M2BiW` are built, **Then** its row is all zeros, exactly as today.

---

### User Story 3 - A legacy caller can opt back into the exact dense output (Priority: P2)

A caller who depends on the three matrices being full (for example code that passes them to a routine that rejects sparse input) sets `options.denseBondMatrices = 1` and gets today's output exactly.

**Why this priority**: it is the migration path that makes changing the default acceptable under Constitution Principle II. It is independently testable on any fixture.

**Independent Test**: `testBuildAtomAndBondTransitionMultigraph.m` (FR-015) exercises both modes on the CI fixture in CI. Separately, call the function with `options.denseBondMatrices = 1` on the tyrosine fixture and the CI fixture, and compare against the golden snapshot with `isequal` and with an explicit check that the three matrices are class `double` and not sparse.

**Acceptance Scenarios**:

1. **Given** `options.denseBondMatrices = 1`, **When** the function is called, **Then** `M2BiE`, `M2BiW` and `BTi2R` are `isequal` to the original function's outputs, are class `double`, and are not sparse, and all other outputs are unchanged.
2. **Given** `options.denseBondMatrices` is absent or `0`, **When** the function is called, **Then** the three matrices are sparse.
3. **Given** the function's header documentation, **When** a user reads the options list, **Then** `options.denseBondMatrices` is documented next to `options.sanityChecks` and `options.bondTransitionMultigraph`, with its default, its effect, and a note that the default storage class of the three outputs changed.

---

### Edge Cases

- **Energy pseudo-nodes.** The bond loop adds one energy node per reaction whose `Met` is the reaction identifier, not a model metabolite. Their columns in `M2BiE` and `M2BiW` MUST remain all-zero, not error and not be dropped.
- **Column order.** Columns of `M2BiE`/`M2BiW` MUST follow `dBTM.Nodes` order exactly. A "faster" construction that reorders columns would silently corrupt every downstream product.
- **`BTi2R` column count.** Today's column count is `nMappedRxns`, taken from the atom-mapped stoichiometry, while its row-to-reaction lookup is against the bond-mapped reaction list. Dimensions and any resulting error for an out-of-range lookup MUST be preserved as they are, not "corrected".
- **Stored values.** `M2BiW` carries each bond node's `BondType`. Values (including any fractional or resonance-resolved type) MUST be reproduced exactly; a bond type of 0 or NaN must land identically in the sparse and dense forms.
- **Mismatch-report branch.** The branch that prints a per-reaction residual report when the bond decomposition fails uses expressions such as `diag(M2BiE*M2BiW')` and `M2BiE*BTiE*BTi2R`. It MUST keep working, and print the same values, when fed sparse matrices, even though it is otherwise out of scope. No production fixture triggers it, so it is exercised by a deliberately inconsistent fixture in the CI test (FR-015 (e)).
- **Empty or degenerate inputs.** Zero bond transitions, or a model with no bond-mapped reactions, MUST produce the same outcome as today (including any error raised earlier in the function), not a new failure introduced by sparse construction. Exercised by the reproducibility check's no-RXN-file fixture (FR-012).
- **Legacy dense mode at full scale.** With `options.denseBondMatrices = 1` a full-VMH call still needs the ~330 GB. That is intended: the option exists for small models and exact legacy reproduction, and this feature does not try to make it scale.
- **Callers that mutate or index the outputs.** Assigning into, indexing, or multiplying the sparse outputs works, but a routine that rejects sparse input will fail under the new default. That is the documented reason the opt-in exists.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001 (top-level, non-regression)**: This change MUST NOT break or alter the original functionality of `buildAtomAndBondTransitionMultigraph`. All twelve outputs MUST keep their names, order, dimensions and values; the function's signature and the default behaviour of every existing option MUST be unchanged; and the only observable difference under default options MUST be the storage class (`issparse`) of `M2BiE`, `M2BiW` and `BTi2R`, whose values are unchanged.
- **FR-002**: With `options.denseBondMatrices = 1`, the function's outputs MUST be identical to the pre-change function's: `isequal`, same class, and same sparsity, for all twelve outputs.
- **FR-003**: By default (`options.denseBondMatrices` absent or `0`), `M2BiE`, `M2BiW` and `BTi2R` MUST be returned as sparse matrices with the same dimensions as before and values equal to the pre-change function's (`isequal(full(new), old)`).
- **FR-004**: A new optional field `options.denseBondMatrices` MUST be added, defaulting to `0`, handled with the same "create the default if the field is absent" pattern as the existing options, and MUST be documented in the function's header alongside `options.sanityChecks` and `options.bondTransitionMultigraph`, including the change of default storage class and the migration path (set it to `1`).
- **FR-005**: The two per-metabolite loops that fill `M2BiE` and `M2BiW` MUST be replaced by a construction whose cost does not include one scan of all bond nodes per metabolite. Column order MUST follow `dBTM.Nodes`; energy pseudo-node columns and bond-less metabolite rows MUST be all zero; `M2BiW` MUST carry `BondType` values exactly.
- **FR-006**: `BTi2R` MUST keep its exact dimensions and its exact row-to-reaction assignment, and MUST NOT be materialised as a full matrix by default.
- **FR-007**: Both verified decompositions (atomic and bond) MUST continue to hold with zero residual under default and dense options, and the residual check and its mismatch-report branch MUST continue to work and print the same content when the three matrices are sparse.
- **FR-008**: Every existing sanity check, `fprintf` diagnostic, `warning` and `error` in the function MUST fire under the same conditions with the same text. None may be removed, weakened or silenced to make a comparison pass (Constitution Principle IV).
- **FR-009**: Scope MUST be limited to the three matrices and the two fill loops (plus the option and its documentation). The per-reaction `addnode(dATM, ...)` rebuild of `dATME`, the atom-side code, the table and graph construction, the mismatch-report expressions (beyond what FR-007 needs), and any other hotspot are explicitly OUT of scope. They MAY be recorded as candidate follow-up features but MUST NOT be changed here.
- **FR-010 (Principle II approval)**: Making sparse the default deliberately departs from Constitution Principle II's rule that a new optional argument default to the historical behaviour. This spec explicitly approves that departure, on the grounds that the historical default cannot run at the toolbox's target scale, that the values are unchanged, and that `options.denseBondMatrices = 1` is the documented migration path restoring the historical output exactly. The approval MUST be restated where the plan records its Constitution Check.
- **FR-011**: `testConservedReactingMoieties.m` MUST pass after this change with every existing assertion intact; that file MUST NOT be edited. No `src/` file other than `buildAtomAndBondTransitionMultigraph.m` MAY be modified by this feature; the only new or changed `test/` file is the one FR-015 adds; and the function's documented output names and order MUST NOT change.
- **FR-012**: The feature MUST include a documented, non-CI reproducibility check following the feature 021/022 pattern (`tyrosineReproducibilityCheck.m`), whose golden snapshot is captured from the **original, unmodified** function *before* any source change, and which then compares the modified function against it for all twelve outputs in both default and `denseBondMatrices = 1` modes. It MUST cover, at minimum, the tyrosine fixture and the CI fixture, and SHOULD cover the additional reconXmoieties fixtures where their model and corpus data are available. Each snapshot and results entry MUST record corpus provenance (corpus path, file count and a change indicator) so that a data change is never mistaken for a code regression.
- **FR-013**: The check MUST report, not merely assert, the measured storage of the three matrices (default versus dense) and the before/after fill-step time on the tyrosine fixture. The fill-step time covers only the construction of `M2BiE` and `M2BiW` and is the median of 5 repeated `tic`/`toc` runs; the before median MUST be measured on the original fill code (a verbatim copy whose output is checked against the unmodified function's `M2BiE`/`M2BiW`, timed at capture time before any source change) and recorded with the golden snapshot (FR-012), and the after median measured by the check on the modified function.
- **FR-015 (CI coverage, Principle III)**: The feature MUST add `test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m` (the single per-function test file under Principle III-Naming), runnable within `test/testAll.m` and CI on the self-contained CI fixture (`r0317`, `ACONTm`, `r0426` from Recon3D), with no external data. It MUST assert: (a) under default options `M2BiE`, `M2BiW` and `BTi2R` are sparse; (b) with `options.denseBondMatrices = 1` they are class `double` and not sparse; (c) the three matrices have the same dimensions in both modes and `isequal(full(default), dense)`, and the other nine outputs are `isequal` across modes; (d) the atomic and bond decompositions have zero residual in both modes; (f) with `options.bondTransitionMultigraph = 0`, the outputs are identical with and without `options.denseBondMatrices = 1` (US1 acceptance scenario 4); (e) on a small fixture derived from the CI fixture whose stoichiometry is deliberately made inconsistent with its bond mapping, the "Inconsistent directed bond transition multigraph" warning is raised in both modes (detected without suppressing it, Principle VII-B) and the printed mismatch report is identical between default and dense modes (captured text, where `evalc` is used, is permitted only as capture of otherwise-unobtainable output under Principle VII-A and stored in a uniquely named variable). It MUST declare its requirements with `prepareTest` and keep console output minimal. It does not replace the FR-012 golden-snapshot check, which remains the evidence of equivalence to the **original** function.
- **FR-014 (optional, not a gate)**: The feature MAY include a non-CI demonstration of a full-VMH-size call. Its outcome, including failure caused by the out-of-scope memory or time consumers listed in the Assumptions, MUST be recorded but MUST NOT gate acceptance.

### Key Entities

- **`M2BiE`**: metabolite-to-bond incidence matrix; entry (i, j) is 1 when bond node j belongs to metabolite i. Rows follow `model.mets`; columns follow `dBTM.Nodes`.
- **`M2BiW`**: as `M2BiE`, but the entry carries the bond's type (1 single, 2 double, 3 triple, or the resolved resonance type) instead of 1.
- **`BTi2R`**: bond-transition-to-reaction matrix; entry (k, r) is 1 when directed bond transition k belongs to mapped reaction r.
- **`options.denseBondMatrices`**: new optional flag, default `0`; `1` requests the historical full-matrix output.
- **Golden snapshot**: the twelve outputs of the original function per fixture, captured before any source change, with corpus provenance.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001 (top-level, non-regression)**: On every fixture the reproducibility check covers, with default options, the modified function's outputs match the golden snapshot: nine outputs `isequal`, three matrices with the same dimensions and `isequal(full(new), snapshot)`; and with `denseBondMatrices = 1` all twelve are `isequal` with class `double` and not sparse for the three matrices. Zero mismatches are permitted.
- **SC-002**: `testConservedReactingMoieties.m` passes and is not edited (verifiable by `git diff` showing no change to that file).
- **SC-003**: On the CI fixture, both decompositions have zero residual and neither inconsistency warning is raised, in default and dense modes; on every other covered fixture (including tyrosine), the residuals, inconsistency warnings and printed bond mismatch report are identical to the original function's, in both modes.
- **SC-004**: On every covered fixture with at least 50 metabolites and 50 reactions, the combined storage of the three matrices under default options is at most 10% of their combined dense storage, and the measured figures are reported.
- **SC-005**: On the tyrosine fixture, the median of 5 timed runs of the `M2BiE`/`M2BiW` fill step is reported before (recorded with the golden snapshot) and after the change, and the after median is not greater than the before median.
- **SC-006**: A `git diff` against `develop` shows changes to `buildAtomAndBondTransitionMultigraph.m` only within (a) the option default and header documentation and (b) the construction of the three matrices; no sanity check, warning or error statement is altered, and no other `src/` file changes.
- **SC-007**: The header of the function documents `options.denseBondMatrices`, its default, and the storage-class change (verifiable by inspection).
- **SC-009**: `testBuildAtomAndBondTransitionMultigraph.m` exists at the FR-015 path, runs in CI without external data, and passes with all FR-015 assertions (a)–(f), including the mismatch-report branch firing with identical output in both modes.
- **SC-008 (optional, not a gate)**: If a full-VMH demonstration is run, its outcome, peak memory and time are recorded.

## Assumptions

- **Base branch**: this feature is branched from `develop`, not from `029-vectorize-atm-loops`. Feature 029 is unmerged and touches different files (`identifyConservedReactingMoieties.m`, `createBIGraph.m`); `buildAtomAndBondTransitionMultigraph.m` is identical on both, so the two features are independent. Feature 029's eight-fixture harness is therefore not available on `develop` and is not depended on; this feature extends the feature 021/022 tyrosine harness that is.
- **Consumer inventory**: nothing in the repository reads `M2BiE`, `M2BiW` or `BTi2R` by name after the call; the only references are the destructuring call sites listed under User Story 1. The only observable consequence of the new default is therefore the storage class of the three outputs. Callers outside the repository cannot be inventoried, which is why the dense opt-in exists.
- **Equality semantics**: sparse and dense forms of the same values compare `isequal` in MATLAB, so golden snapshots MAY be stored sparse (avoiding very large snapshot files); storage class is asserted separately from value equality. Comparisons use `isequaln`, which is `isequal` except that NaN equals NaN; this is needed because the node tables contain NaN and would not be `isequal` even to themselves. `isequal` and `isequaln` ignore data type, so `class` and `issparse` are checked separately for every output.
- **Scale figures are estimates**: the atom, bond and transition counts behind the ~330 GB / ~65 MB comparison are extrapolated from a per-file scan of the atom-mapped reaction corpus, not from a completed full-VMH run; the ratio, not the absolute figures, is what matters.
- **Full-VMH completion is not promised**: after this change the remaining outputs (`dATM`, `dATME`, `BG`, `dBTM`) still occupy several gigabytes, and the per-reaction `dATME` rebuild and other hotspots remain slow. This feature removes the memory blocker on three matrices; it does not by itself guarantee a full-VMH call completes in reasonable time. Those hotspots are candidate follow-up features.
- **Fixture data are external**: the tyrosine fixture depends on model and corpus data outside the repository (as in features 021/022), so the reproducibility check is not CI-runnable; the CI fixture is self-contained.
- **Working-tree note**: at branching time the tracked path `binary` (a submodule) already showed as modified in the working tree; it is unrelated to this feature and is not touched by it.

## Traceability

| Acceptance criterion | Discharging test | src/analysis/topology/reactingMoieties/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-011, SC-002 | testConservedReactingMoieties.m (unmodified) | buildAtomAndBondTransitionMultigraph |
| US1 / FR-001, FR-003, FR-007, SC-001, SC-003 | golden-snapshot reproducibility check (021/022 pattern), default mode | buildAtomAndBondTransitionMultigraph |
| US1 / FR-008, SC-006 | -- (static `git diff` review of sanity-check, warning and error statements; no source function of its own) | -- (no source function) |
| US2 / FR-003, FR-005, FR-006, SC-004, SC-005 | golden-snapshot reproducibility check, storage and timing report | buildAtomAndBondTransitionMultigraph |
| US2 / FR-005 (energy-node columns, bond-less rows) | testConservedReactingMoieties.m (its fixture contains energy pseudo-nodes) and the reproducibility check | buildAtomAndBondTransitionMultigraph |
| US2, US3 / FR-003, FR-004, FR-007, FR-015, SC-009 (CI: sparse default, dense opt-in, cross-mode equality, zero residuals, mismatch-report branch, `bondTransitionMultigraph = 0` (US1 AS4)) | testBuildAtomAndBondTransitionMultigraph.m (new, CI fixture) | buildAtomAndBondTransitionMultigraph |
| US3 / FR-002, FR-004, SC-001, SC-007 | golden-snapshot reproducibility check, dense mode; header inspection | buildAtomAndBondTransitionMultigraph |
| FR-009, FR-010, FR-011 (scope, Principle II approval) | -- (static `git diff` and plan Constitution Check; no source function of its own) | -- (no source function) |
| FR-014, SC-008 (optional) | -- (non-CI demonstration; not a gate) | -- (no source function) |
