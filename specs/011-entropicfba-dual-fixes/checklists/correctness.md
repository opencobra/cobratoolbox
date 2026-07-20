# Correctness & Regression-Safety Checklist: 011-entropicfba-dual-fixes

**Purpose**: Validate that the requirements for the entropic-FBA fixes are complete, clear,
consistent, and measurable — a "unit test suite" for the spec before planning. Tests the
requirements, not the eventual implementation.
**Created**: 2026-07-16
**Feature**: [spec.md](../spec.md)

## Requirement Completeness

- [x] CHK001 - Are the infeasible-EP requirements specified for every status the internal LP
  diagnostic (`optimizeCbModel`) can return, not just 0 and 1? [Completeness, Spec §FR-001]
- [x] CHK002 - Is the requirement to not regress the non-enzyme dual residual stated against a
  measurable baseline (the pre-existing ~2 residual on Recon3D)? [Completeness, Spec §FR-006]
- [x] CHK003 - Does the spec require `prepareTest` requirement-declaration and graceful skip for the
  new infeasible-case assertion, matching existing EP tests? [Completeness, Spec §FR-010]
- [x] CHK004 - Are the MATLAB-standard obligations beyond warning visibility — try/catch `ME.stack`
  propagation (VII-C), no `evalc` suppression (VII-A), openCOBRA header on any new/revised function
  (VII-E) — stated as constraints on the edits? [Gap, Constitution VII]

## Requirement Clarity

- [x] CHK005 - Is "sized from the actual problem dimension" for the mosek diagnostic name arrays
  precise enough to verify (which arrays, which dimension)? [Clarity, Spec §FR-003]
- [x] CHK006 - Is the "informative message" required on an infeasible EP characterized beyond
  "non-empty" (does the spec say what it must convey)? [Clarity, Spec §FR-001]
- [x] CHK007 - Does the spec define the criterion for declaring a dual-residual fix "infeasible" —
  the trigger that permits the characterize-and-tolerate fallback? [Clarity, Spec §FR-006]
- [x] CHK008 - Is the allowed-edit scope unambiguous about the two distinct test locations
  (`base/testEntropicFBA` for the legacy test vs. `analysis/testEntropicFBAgecko` for the GECKO
  test)? [Clarity, Spec §FR-009]

## Requirement Consistency

- [x] CHK009 - Do the feasible-path invariance tolerances (FR-004/SC-004) agree with the tolerances
  the existing 010 tests actually assert (1e-6, 1e-4, 1e-3)? [Consistency, Spec §FR-004]
- [x] CHK010 - After the Session 2026-07-16 clarification, does FR-006 ("pursue the fix") stay
  consistent with the US3 acceptance scenarios that still cover both fix and characterize outcomes?
  [Consistency, Spec §Clarifications, §US3]
- [x] CHK011 - Are the solver status-string preservation requirements (`OPTIMAL`, `MSK_RES_OK`)
  stated consistently between FR-008 and the US3 characterize scenario? [Consistency, Spec §FR-008]

## Acceptance Criteria Quality (Measurability)

- [x] CHK012 - Is the "documented tolerance" the fixed mosek dual residual must fall below (FR-006)
  quantified, or is only `optTol = 5e-5` implied? [Measurability, Spec §FR-006]
- [x] CHK013 - Is SC-005 ("no NEW `check_matlab_code` flags") anchored to a defined pre-change
  baseline so it can be objectively evaluated? [Measurability, Spec §SC-005]
- [x] CHK014 - Are the regression guards (the exact existing tests that must still pass) enumerated
  so SC-004 is objectively checkable? [Measurability, Spec §SC-004]

## Scenario & Edge Case Coverage

- [x] CHK015 - Does the spec state which backend(s) the infeasible enzyme-constrained case must be
  validated under (mosek, where the crash occurs; pdco optional)? [Coverage, Spec §FR-002]
- [x] CHK016 - Does the spec address isolating the enzyme-cap cause — i.e. that the infeasible
  fixture is infeasible *because of* the enzyme bound and not some other reason? [Edge Case, Gap]
- [x] CHK017 - Is the non-enzyme infeasible path (existing clean `stat==0`) covered as an explicit
  no-regression scenario, not only the enzyme case? [Coverage, Spec §US1 scenario 3]

## Dependencies & Assumptions

- [x] CHK018 - Is the assumption that pdco is already clean on the GECKO dual condition marked as
  validated or to-be-confirmed during the investigation? [Assumption, Spec §Assumptions]
- [x] CHK019 - Does every functional requirement map to at least one discharging test in the
  Traceability table (no orphan FR, no test without a criterion)? [Traceability, Spec §Traceability]

## Notes

- Items are requirement-quality questions (is X specified / clear / consistent / measurable?), not
  implementation verifications. Unchecked items are addressed either by tightening the spec before
  planning or by explicitly deferring the decision to `/speckit-plan` (recording which).
