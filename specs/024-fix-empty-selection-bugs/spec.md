# Feature Specification: Fix Empty-Selection Crashes in Reacting-Moieties Pipeline

**Feature Branch**: `024-fix-empty-selection-bugs`

**Created**: 2026-09-04

**Status**: Draft

**Input**: User description: "Fix two reactingMoieties pipeline bugs discovered during the broad positive-control health-check experiment (300-pair sample, 2026-09-04): (1) `RM_sets` undefined-variable crash in `identifyConservedReactingMoieties.m` when the MILP set-cover selects zero reactions, and (2) `BondChange` missing-column crash when a bare empty `table()` propagates from `buildReactingMoietyTables.m` through `constructCanonicalMoietySignature.m` into `compareMoietySignatures.m`. Both bugs are fully root-caused. Fix is cobratoolbox-root-cause only — no reconXmoieties changes (no defensive guard in `compareMoietySignatures.m`)."

<!--
  CHARACTERIZATION MODE (optional): if this feature back-fills a test for an
  EXISTING untested function (see Constitution Principle III, "Characterization:
  Legacy Back-Fill Mode"), fill the "Existing Contract" section (below, after
  Requirements) to capture CURRENT behaviour — existing inputs, outputs,
  invariants, tolerances — instead of net-new requirements. The Functional
  Requirements then describe the test's assertions of that existing contract, not
  new capabilities. Delete this block and the "Existing Contract" section for
  greenfield work. Do not restate the Principle III clause here — reference it.
-->

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Zero-selection reactions no longer crash the moiety pipeline (Priority: P1)

A researcher runs the reacting-moieties comparison pipeline (via reconXmoieties'
`constructCanonicalMoietySignature.m`, which calls into cobratoolbox's
`identifyConservedReactingMoieties.m`) over a batch of VMH/Rhea reaction pairs. For
some reactions, the MILP set-cover step (`solveCobraMILP`) legitimately selects zero
reactions (`selectedReactions` comes back empty). Today this crashes the whole pair
with `Unrecognized function or variable 'RM_sets'` instead of returning a normal
empty-result signature that downstream comparison logic can handle.

**Why this priority**: This is a hard crash (not a wrong answer) that aborts
processing for any reaction hitting this MILP outcome. It was observed on 4/300
Clean-category pairs in the broad positive-control run (1.3% of the full sample,
4/241 = 1.7% of Clean pairs) and blocks getting a verdict for those pairs at all.

**Independent Test**: Can be fully tested by running
`identifyConservedReactingMoieties` on a reaction where the MILP set-cover is known to
select zero reactions (e.g. VMH reaction MACACI, mapped to Rhea rh:14817) and
confirming it returns normally with empty `ReactMoietySets`/`ReactMoietyGraphs` fields
instead of throwing.

**Acceptance Scenarios**:

1. **Given** a reaction whose MILP set-cover selects zero reactions, **When**
   `identifyConservedReactingMoieties` runs on it, **Then** it completes without error
   and returns `reacting.ReactMoietySets` and `reacting.ReactMoietyGraphs` as empty
   cell arrays (`{}`), not undefined variables.
2. **Given** the four known-affected pairs from the broad positive-control run
   (MACACI/rh:14817, RPE/rh:13677, UDPG4E/rh:22168, UAG4E/rh:20517), **When** each is
   re-run through the full Stage 4→6 pipeline, **Then** none throws
   `Unrecognized function or variable 'RM_sets'`.
3. **Given** a reaction whose MILP set-cover selects one or more reactions (the common
   case), **When** `identifyConservedReactingMoieties` runs on it, **Then** its
   output is byte-for-byte unchanged from current behavior (no regression for the
   non-empty path).

---

### User Story 2 - Empty reacting-moiety tables carry the expected schema (Priority: P2)

For some selected reactions, both the "formed" and "broken" bond subtables are empty,
so `buildReactingMoietyTables.m` stores a bare `table()` (zero rows, zero columns) as
that reaction's `reactMoietyTables{k}`. This bare-empty table is then wrapped into a
canonical moiety signature by `constructCanonicalMoietySignature.m` and later compared
by `compareMoietySignatures.m`'s `reactingPatternSetEqual`, which unconditionally
accesses `reactA.BondChange` / `reactB.BondChange` once the row-count guard passes
(both sides are height 0, so the guard passes) — a column that a bare `table()` does
not have, throwing `Unrecognized table variable name 'BondChange'`.

**Why this priority**: Also a hard crash, one tier less frequent than User Story 1 in
the observed sample (5/300 pairs, all Clean or SymmetryFlagged), and it can co-occur
with reactions unaffected by User Story 1, so it needs its own fix even though both
share the "empty output isn't schema-safe" root cause.

**Independent Test**: Can be fully tested by running the pipeline on a reaction pair
known to produce two empty reacting-moiety tables for comparison (e.g. VMH reaction
RETI3, mapped to Rhea rh:55352) and confirming `compareMoietySignatures` runs to a
verdict instead of throwing on the `.BondChange` access.

**Acceptance Scenarios**:

1. **Given** a reaction whose formed- and broken-bond subtables are both empty,
   **When** `buildReactingMoietyTables` stores that reaction's table, **Then** the
   stored table is empty (zero rows) but carries the same column schema as a
   non-empty result, including `BondChange`.
2. **Given** the five known-affected pairs from the broad positive-control run
   (RETI3/rh:55352, RETI2/rh:55348, RETI1/rh:19141, MMEm/rh:20553,
   RE2624M/rh:40455), **When** each is re-run through the full Stage 4→6 pipeline
   including `compareMoietySignatures`, **Then** none throws
   `Unrecognized table variable name 'BondChange'`, and each reaches a verdict
   (MATCH/TAUTOMER_MATCH/MATCH_REVERSED/PARTIAL_REVERSED/NO_MATCH) as appropriate to
   its underlying chemistry.
3. **Given** a reaction whose reacting-moiety table is non-empty, **When**
   `buildReactingMoietyTables` runs on it, **Then** its output is unchanged from
   current behavior.
4. **Given** two typed-but-empty reacting-moiety tables (same schema, zero rows) being
   compared by `reactingPatternSetEqual`, **When** the comparison runs, **Then** it
   returns `true` (trivially equal), without needing a reconXmoieties-side change to
   `compareMoietySignatures.m` — the fix must resolve this entirely by making
   cobratoolbox's output schema-consistent, per the explicit scope decision to keep
   this a cobratoolbox-only fix.

---

### Edge Cases

- A reaction with a non-empty MILP selection but where one (not both) of the formed/
  broken bond subtables is empty: `buildReactingMoietyTables.m`'s existing
  `~isempty(F)` / `~isempty(B)` per-subtable guards do **not** handle this safely.
  `formedBondsTable` and `brokenBondsTable` are both row slices of the same
  `dBTM.Edges` table, so they start with identical column sets; the guards then add
  `BondChange` to only the non-empty side, leaving the two sides with mismatched
  variable names, and the subsequent `[F; B]` concatenation fails. This is a latent
  third crash from the same "empty output isn't schema-safe" root cause. It was not
  observed in the 300-pair sample (no such reaction occurred there), so it is not a
  reproduction case, but the fix for User Story 2 MUST NOT leave it in place — see
  FR-009.
- A reaction hitting both bugs at once (zero MILP selection AND, hypothetically, an
  empty-table downstream step): not observed in the 300-pair sample, but the two
  fixes are independent and composable — fixing both should not require them to be
  mutually aware of each other's output shape.
- Downstream consumers that already handle empty cell arrays / empty tables
  correctly elsewhere in the pipeline (e.g. the `EndNodes`/`Weight` typed-but-empty
  table already built in `constructCanonicalMoietySignature.m`) must continue to work
  identically — the fix should follow that existing typed-but-empty convention rather
  than inventing a new one.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `identifyConservedReactingMoieties.m` MUST initialize `RM_sets` and
  `RM_graph` as empty cell arrays (`{}`) before the `for k = 1:length(selectedReactions)`
  loops that populate them, so both variables are always defined regardless of whether
  `selectedReactions` is empty.
- **FR-002**: `identifyConservedReactingMoieties.m` MUST assign
  `reacting.ReactMoietySets` and `reacting.ReactMoietyGraphs` successfully (no
  "Unrecognized function or variable" error) for any input, including one where the
  MILP set-cover selects zero reactions.
- **FR-003**: `buildReactingMoietyTables.m` MUST store a typed-but-empty table (zero
  rows, correct column schema including `BondChange`) for any reaction whose formed-
  and broken-bond subtables are both empty, matching the column set of the non-empty
  case (`BondChange` plus whatever columns `F`/`B` otherwise carry).
- **FR-004**: The typed-but-empty table produced under FR-003 MUST follow the same
  construction convention already used in
  `constructCanonicalMoietySignature.m` for its `EndNodes`/`Weight` case (an explicit
  `table(..., 'VariableNames', {...})` with zero rows), not a bare `table()`.
- **FR-005**: `reactingPatternSetEqual` in reconXmoieties' `compareMoietySignatures.m`
  MUST require no source change to correctly compare two typed-but-empty reacting
  tables — this is an acceptance condition on the upstream fix's output shape.
  **Amended during planning (2026-09-04)**: source inspection of
  `constructCanonicalMoietySignature.m:278-283` found that its `if isempty(T)`
  branch unconditionally replaces `T` (regardless of column schema) with a bare
  `table()` before `sig.reactingPattern` ever reaches `compareMoietySignatures.m` —
  so a cobratoolbox-only fix to `buildReactingMoietyTables.m` cannot by itself
  prevent the `.BondChange` crash; the crash re-manifests one hop upstream inside
  reconXmoieties. Per explicit user decision (AskUserQuestion, 2026-09-04), scope is
  widened by exactly this one branch: `constructCanonicalMoietySignature.m:278-283`
  MUST preserve `T`'s column schema (not discard it to a bare `table()`) when `T` is
  empty. `compareMoietySignatures.m` itself remains untouched (original scope
  decision preserved for that file specifically).
- **FR-006**: System MUST preserve documented public interfaces, diagnostic
  semantics, and file-location conventions affected by this feature — specifically,
  the field names `reacting.ReactMoietySets`, `reacting.ReactMoietyGraphs`, and
  `reacting.reactMoietyTables` are unchanged by this fix, and
  `constructCanonicalMoietySignature.m`'s consumption of them is unchanged for every
  case except the one narrow empty-schema branch amended under FR-005 (its non-empty
  path, its field names, and `sig.reactingPattern`'s column set for non-empty results
  are all unaffected).
- **FR-007**: System MUST define the narrowest reproducibility check or test that
  proves the feature behavior: for User Story 1, a unit/characterization test that
  drives `identifyConservedReactingMoieties` (or a minimal harness around its MILP
  set-cover step) to the zero-selection branch and asserts no error and empty
  `{}` outputs; for User Story 2, a unit/characterization test that drives
  `buildReactingMoietyTables` to the both-empty-subtable branch and asserts the
  returned table has zero rows and a `BondChange` variable, a unit/characterization
  test that drives `buildReactingMoietyTables` to the one-empty-subtable branch
  (FR-009) and asserts the `[F; B]` concatenation succeeds with a uniform
  `BondChange` column regardless of which side was empty, plus a test that feeds two
  typed-but-empty tables into `reactingPatternSetEqual` and asserts it returns
  `true`.
- **FR-008**: System MUST state measurable performance or numerical-integrity
  constraints when the feature affects solver behavior, scaling, residuals,
  diagnostics, or generated output volume: this feature does not change MILP solver
  behavior, numerical results, or output volume for any already-succeeding reaction
  (non-empty-selection / non-empty-table cases) — it only changes behavior on inputs
  that previously threw an uncaught error.
- **FR-009**: `buildReactingMoietyTables.m` MUST produce a schema-consistent table for
  a reaction where exactly one of the formed- and broken-bond subtables is empty: both
  sides MUST carry the `BondChange` column before they are combined, so the combined
  table always has one uniform column set regardless of which side is empty. This
  closes the latent concatenation failure described in Edge Cases and is satisfied by
  the same schema-consistency change that discharges FR-003.

### Key Entities

- **`RM_sets` / `RM_graph`** (in `identifyConservedReactingMoieties.m`): per-selected-
  reaction cell arrays of reacting-bond index sets and their induced subgraphs;
  currently only ever assigned inside a loop over `selectedReactions`, with no
  pre-loop initialization.
- **`reactMoietyTables{k}`** (in `buildReactingMoietyTables.m`, consumed by
  `constructCanonicalMoietySignature.m`): per-reaction table of bond changes
  (`BondChange`, plus formed/broken bond details); currently stored as a bare
  `table()` (no columns) when both the formed- and broken-bond subtables are empty,
  instead of a typed-but-empty table matching the non-empty schema.
- **`sig.reactingPattern`** (in reconXmoieties' `constructCanonicalMoietySignature.m`,
  amended under FR-005): per-signature table of canonicalized bond changes
  (`BondChange`, `CanonicalBondElmts`, `IntraInterMoiety`), built from
  `reactMoietyTables{k}`; currently replaced with a bare `table()` (no columns)
  whenever `reactMoietyTables{k}` is empty — regardless of that table's own column
  schema — instead of a typed-but-empty table matching the non-empty schema. This is
  what `compareMoietySignatures.m`'s `reactingPatternSetEqual` reads as `reactA`/
  `reactB`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 4 pairs from the broad positive-control run that previously threw
  `Unrecognized function or variable 'RM_sets'` (MACACI, RPE, UDPG4E, UAG4E) complete
  the full Stage 4→6 pipeline without error after the fix.
- **SC-002**: All 5 pairs from the broad positive-control run that previously threw
  `Unrecognized table variable name 'BondChange'` (RETI3, RETI2, RETI1, MMEm,
  RE2624M) complete the full Stage 4→6 pipeline without error after the fix, reaching
  a verdict rather than an error.
- **SC-003**: Re-running the existing `exp_positive_control_broad` 300-pair sample (or
  an equivalent reproduction pilot over the same 9 pairs) after the fix shows an error
  count of 1 (only the unrelated, not-in-scope "sparse inputs" issue on ACACT1rm) down
  from 10 in the pre-fix run.
- **SC-004**: No previously-passing pair in the 300-pair sample changes verdict as a
  result of this fix (the fix only affects the previously-erroring pairs' code paths).
- **SC-005**: The specified MATLAB reproducibility commands (FR-007's
  characterization tests) complete with the expected pass/fail status and no new
  warnings.

## Assumptions

- The MILP set-cover (`solveCobraMILP`) legitimately returning zero selected
  reactions is a valid, expected outcome of the solver for some inputs — not itself a
  bug to be prevented; the fix treats it as a normal case to be handled, not
  suppressed.
- A reaction whose formed- and broken-bond subtables are both empty legitimately has
  "no reacting bonds" as a meaningful, valid result for that reaction — the fix
  represents that outcome faithfully with a typed-but-empty table rather than treating
  it as an error condition.
- Per the user's explicit scope decision, this feature does not modify
  reconXmoieties' `compareMoietySignatures.m` (no defensive guard there). The fix is
  primarily within cobratoolbox's `identifyConservedReactingMoieties.m` and
  `buildReactingMoietyTables.m`, plus — per the amendment under FR-005 — one narrow,
  explicitly-scoped change to reconXmoieties' `constructCanonicalMoietySignature.m`
  (its empty-`T` branch only, `constructCanonicalMoietySignature.m:278-283`), needed
  because that branch was found during planning to discard `T`'s schema
  independently of the cobratoolbox fix.
- The 9 known-affected reaction pairs (4 for Bug 1, 5 for Bug 2) from the
  2026-09-04 broad positive-control run are available as reproduction cases (via
  `reconXmoieties/experiments/notebooks/exp_positive_control_broad.mlx` and its
  staged RXN files) for verification; a full notebook re-run is not required to
  verify the fix, but is a recommended follow-up (see project memory
  `exp_positive_control_broad.md`, "Suggested next steps").

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002 | characterization test: zero-selection branch returns `{}` without error | `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` |
| US1 / SC-001 | reproduction over MACACI, RPE, UDPG4E, UAG4E | `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` |
| US2 / FR-003, FR-004 | characterization test: both-empty-subtable branch returns typed-but-empty table with `BondChange` | `src/analysis/topology/reactingMoieties/buildReactingMoietyTables.m` |
| US2 / FR-005 | characterization test: `reactingPatternSetEqual` on two typed-but-empty tables returns `true`; plus a characterization test on reconXmoieties' `constructCanonicalMoietySignature.m` empty-`T` branch asserting it preserves schema instead of collapsing to `table()` | `src/analysis/topology/reactingMoieties/buildReactingMoietyTables.m`, and reconXmoieties' `moietySignature/functions/constructCanonicalMoietySignature.m:278-283` (amended, narrow scope — see FR-005) |
| US2 / SC-002 | reproduction over RETI3, RETI2, RETI1, MMEm, RE2624M | `src/analysis/topology/reactingMoieties/buildReactingMoietyTables.m` |
| US2 / FR-009 | characterization test: one-empty-subtable branch combines without error and yields a uniform `BondChange` column | `src/analysis/topology/reactingMoieties/buildReactingMoietyTables.m` |
| US1+US2 / SC-003, SC-004 | full `exp_positive_control_broad` re-run (or 9-pair reproduction pilot) | both functions above (end-to-end via reconXmoieties pipeline) |
