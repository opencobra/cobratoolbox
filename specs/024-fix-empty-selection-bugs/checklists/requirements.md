# Specification Quality Checklist: Fix Empty-Selection Crashes in Reacting-Moieties Pipeline

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-09-04
**Feature**: [spec.md](./../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
  - Note: this is a code-level bug-fix feature in an existing MATLAB scientific
    codebase (per the repo's own spec-template, which already bakes MATLAB
    reproducibility/solver-behavior language into FR-006/007/008 as standard
    practice for this project). Function and variable names (`RM_sets`,
    `BondChange`, `identifyConservedReactingMoieties.m`) are the bug's identity,
    not incidental tech-stack detail — omitting them would make the spec
    untestable. No unrelated implementation choices (algorithms, data
    structures beyond what's needed to state the fix, refactors) are
    prescribed; the *how* of the fix (e.g. exact syntax for the cell-array
    initialization) is left to planning/implementation.
- [x] Focused on user value and business needs
  - Value: unblocks 9/300 (3%) of the broad positive-control sample that
    currently hard-crashes instead of producing a verdict, restoring pipeline
    completeness for researchers running moiety-comparison batches.
- [x] Written for non-technical stakeholders
  - Partially adapted for this repo's convention: each user story leads with
    the researcher-facing symptom (pipeline crash blocks a batch) before the
    technical root cause, per the pattern in FR-006/007/008 of the base
    template.
- [x] All mandatory sections completed
  - User Scenarios & Testing, Requirements, Success Criteria, Assumptions,
    Traceability all present and filled. Existing Contract section removed
    (not characterization-mode / not back-filling a test for an untested
    function — this is a net-new crash fix with new characterization tests
    proposed under FR-007).

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
  - None were introduced — both bugs are fully root-caused (exact file/line/
    mechanism known) and the scope decision (cobratoolbox-only, no
    reconXmoieties defensive guard) was already made explicitly by the user
    via AskUserQuestion before this spec was drafted.
- [x] Requirements are testable and unambiguous
  - FR-001 through FR-005 each name the exact function, exact variable/column,
    and exact before/after behavior.
- [x] Success criteria are measurable
  - SC-001/SC-002 name exact reaction pairs; SC-003/SC-004 name exact counts
    (10 errors -> 1, zero verdict regressions).
- [x] Success criteria are technology-agnostic (no implementation details)
  - Framed as pipeline outcomes (errors vs. verdicts reached), not internal
    code changes — SC-001 through SC-005 describe observable pipeline
    behavior, not the fix's implementation.
- [x] All acceptance scenarios are defined
  - 3 scenarios for US1, 4 for US2, covering the crash path, the known
    reproduction pairs, and the non-regression path for the already-working
    case.
- [x] Edge cases are identified
  - Partial-empty subtable case (already handled, must stay unaffected),
    both-bugs-at-once case (not observed but composable), and downstream
    typed-but-empty consumers (must keep working identically).
- [x] Scope is clearly bounded
  - Explicitly cobratoolbox-only (FR-005, Assumptions); explicitly excludes
    reconXmoieties' `compareMoietySignatures.m` defensive guard per the user's
    prior explicit choice.
- [x] Dependencies and assumptions identified
  - Assumptions section covers the MILP zero-selection case, the
    both-empty-subtables case, the scope decision, and the reproduction data
    source (`exp_positive_control_broad.mlx` and its 9 known-affected pairs).

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
  - See Traceability table: every FR maps to a discharging test and a
    src/<domain>/ function under test.
- [x] User scenarios cover primary flows
  - Both crash paths (MILP zero-selection, both-empty bond tables) and their
    non-regression counterparts are covered.
- [x] Feature meets measurable outcomes defined in Success Criteria
  - SC-001 through SC-005 are all directly verifiable against the existing
    300-pair broad positive-control dataset without further data collection.
- [x] No implementation details leak into specification
  - Same note as Content Quality above: function/variable names are the
    bug's identity in this code-fix context, not leaked implementation
    choices; no algorithmic "how" is prescribed.

## Notes

- All items pass. Both bugs were fully root-caused (exact file, line range, and
  mechanism) before this spec was drafted, and the cobratoolbox-only scope
  decision was already made explicitly by the user, so no [NEEDS CLARIFICATION]
  markers were needed.
- **Validation pass 2 (2026-09-04)**: the two root causes were re-verified
  directly against source —
  `identifyConservedReactingMoieties.m:1674-1682` assigns `RM_sets`/`RM_graph`
  only inside `for k = 1:length(selectedReactions)` while `:1703-1704` reads them
  unconditionally (confirms FR-001/FR-002); `buildReactingMoietyTables.m:38-41`
  stores a bare `table()` when `isempty(T)` (confirms FR-003/FR-004).
- **Correction made during pass 2**: the first Edge Cases bullet originally
  claimed the `~isempty(F)` / `~isempty(B)` guards already handle the
  one-empty-subtable case correctly. Source inspection shows otherwise:
  `formedBondsTable` and `brokenBondsTable` are both row slices of the same
  `dBTM.Edges` table (`identifyConservedReactingSubgraphs.m:58-59`), so adding
  `BondChange` to only the non-empty side leaves mismatched variable names and
  the `[F; B]` concatenation at `buildReactingMoietyTables.m:36` fails. The bullet
  was corrected and **FR-009** was added to require schema consistency in that
  branch too. This is a latent third crash, not one of the 10 observed errors,
  so it does not change SC-001 through SC-005.
- Ready to proceed to `/speckit-plan` (clarify is not needed given the above).
- **Amendment during `/speckit-plan` (2026-09-04)**: source inspection of
  reconXmoieties' `constructCanonicalMoietySignature.m:278-283` (performed while
  grounding the plan's Technical Context) found its `if isempty(T)` branch
  unconditionally overwrites `sig.reactingPattern` with a bare `table()` regardless
  of `T`'s column schema — meaning the originally-scoped cobratoolbox-only fix
  (FR-003/FR-004 alone) cannot prevent the `.BondChange` crash in
  `compareMoietySignatures.m`; it re-manifests one hop upstream. Presented to the
  user via AskUserQuestion with three options (widen scope to this one line / keep
  scope and document the gap / re-verify live first); user selected "widen scope to
  this one line". FR-005, FR-006, Assumptions, and Traceability were updated
  accordingly — `compareMoietySignatures.m` itself remains untouched per the
  original scope decision; only `constructCanonicalMoietySignature.m`'s empty-`T`
  branch is now in scope. This does not reopen Content Quality / Requirement
  Completeness items above (no new `[NEEDS CLARIFICATION]`, requirements remain
  testable) but is logged here for traceability since it changes the file set this
  feature touches.
- **Remediation during `/speckit-analyze` (2026-09-04)**: `/speckit-analyze` found
  three MEDIUM findings and the user approved fixing all three: (I1) spec.md's Key
  Entities section had not been updated for the FR-005 amendment — added a third
  entity, `sig.reactingPattern`; (U1) FR-007's test enumeration never named the
  FR-009 (one-empty-subtable) test even though FR-009 and its Traceability row
  already existed — added a clause naming it; (G1) SC-005's "no new warnings"
  clause had no explicit task-level check — added `lastwarn()` before/after checks
  to `tasks.md` T012, T022, and T023. All three are documentation-completeness
  fixes; no functional requirement, task, or scope changed as a result.
