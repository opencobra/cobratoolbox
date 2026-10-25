# Interface & Equivalence-Testing Requirements Checklist: Conserved-Moieties-Only Option

**Purpose**: Unit-test the requirements themselves (not the implementation) for the parts of
this feature most likely to bite: interface stability and the equivalence-test claim.
**Created**: 2026-09-14
**Feature**: [spec.md](../spec.md)

## Requirement Completeness

- [x] CHK001 - Is the new option's default value, and the resulting behavior when it is
      unset, explicitly specified? [Completeness, Spec §FR-001]
- [x] CHK002 - Is the exact set of code this feature must skip (vs. must still run)
      identified precisely enough to implement against? [Completeness, Spec §FR-002/FR-003]
- [x] CHK003 - Is the required state of the third output (`reacting`) fully specified for
      the skipped-computation case, including how it must be distinguishable from a genuine
      (possibly empty) reacting-moiety result? [Completeness, Spec §FR-004]

## Requirement Clarity

- [x] CHK004 - Is "identical" for the equivalence check (User Story 2) quantified per field
      — exact match vs. a numerical tolerance, and which tolerance? [Clarity, Spec §SC-002]
- [x] CHK005 - Is the scope of "same results" clarified as the conserved-moiety-specific
      fields of `arm` rather than the entire struct, given some `arm` fields are expected to
      differ by construction between the two modes? [Clarity/Ambiguity, Spec §Assumptions]

## Requirement Consistency

- [x] CHK006 - Are the interface-stability requirement (signature unchanged, Spec §FR-005)
      and the "BG unused in conserved-only mode" requirement consistent with each other and
      with Constitution Principle II? [Consistency, Spec §FR-005]

## Scenario Coverage

- [x] CHK007 - Does the spec define behavior for a caller enabling the new option together
      with `options.sanityChecks`? [Coverage, Spec Edge Cases]
- [x] CHK008 - Does the spec define behavior on inputs where the (now-skipped)
      reacting-moiety section would otherwise have errored (e.g. missing MILP solver, known
      bond-subgraph edge cases)? [Coverage, Spec Edge Cases]
- [x] CHK009 - Is the no-regression requirement for existing (option-unset) callers stated
      as an explicit, separately-testable acceptance scenario? [Coverage, Spec §US2
      Acceptance Scenario 4]

## Non-Functional Requirements

- [x] CHK010 - Is the MILP-solver-independence claim for conserved-only mode stated as a
      testable requirement rather than an implied side effect? [Completeness, Spec §FR-002,
      §SC-001]

## Dependencies & Assumptions

- [x] CHK011 - Are the known, separately-tracked defects in the reacting-moiety code
      (CRB2R over-attribution, bond-node canonicalization) explicitly scoped out of this
      feature so implementers do not conflate fixing them with this change? [Assumption,
      Spec §Assumptions]
- [x] CHK012 - Is the pre-existing mismatch between this function's test-file name and the
      project's test-naming convention (Principle III-Naming) acknowledged as out of scope,
      so it is not silently "fixed" as a side effect? [Assumption, Spec §Assumptions]

## Traceability

- [x] CHK013 - Does every functional requirement map to a discharging test and the
      `src/<domain>/` function under test in the Traceability table? [Traceability, Spec
      §Traceability]

## Notes

- All items pass against the current spec (post-clarification). No [Gap]/[Ambiguity]/
  [Conflict] items remain open as of this checklist's creation.
