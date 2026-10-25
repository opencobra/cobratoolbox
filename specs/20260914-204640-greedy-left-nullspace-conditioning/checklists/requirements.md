# Specification Quality Checklist: Left-Nullspace Basis Conditioning And Bad-Scaling Diagnosis For `greedyExtremeRayBasis`

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-09-14
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details)
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [x] No implementation details leak into specification

## Notes

- **All three clarifications resolved** in the Session 2026-09-14 record in spec.md:
  tightened acceptance becomes the default with no opt-out (an approved breaking change
  under Principle II, carrying the migration-path obligation now written as FR-015b);
  the status is delivered as a third positional output; and Regime B withholds both
  bases. No [NEEDS CLARIFICATION] markers remain. Checklist: 15/16 -> 16/16.

- **On "no implementation details"**: the spec names `getRankLUSOL`, `getNullSpace`
  and singular-value decomposition. These are not implementation choices for the
  feature; they are the **measurement instruments** the acceptance criterion is
  written in terms of ("the same integer from all three"), and naming them is what
  makes FR-001 and SC-002 testable. No remedy, algorithm, tolerance value, data
  structure or control flow is prescribed anywhere in the spec — the Assumptions
  section explicitly lists four candidate remedies and commits to none.

- **On "written for non-technical stakeholders"**: the stakeholder for this feature is
  a computational modeller. Domain vocabulary (rank, nullspace, residual, scaling) is
  the subject matter, not jargon layered over it; the spec defines the consequence of
  each in plain terms (a "confident, well-formed, wrong answer") before relying on it.

- **On measurable success criteria**: SC-002, SC-003, SC-006 and SC-009 are stated as
  agreement between independent measurements and as properties of returned objects, so
  each is checkable without knowing how the routine was changed.

- Deliberately NOT asserted in this spec, per the seed's reporting discipline: any
  particular attainable residual, any runtime, and which regime any named model falls
  into. These are findings of the work; asserting them here would prejudge it.
