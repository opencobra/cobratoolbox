# Specification Quality Checklist: Extreme-Ray Coverage Without Sacrificing Accuracy

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-09-15
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

- **Both clarifications resolved** in the Session 2026-09-15 record: a two-solver call is
  approved as approach A1 but only as a fallback behind the two single-solver approaches,
  and the deliverable-if-unclosable question is settled by the same three-way comparison.
  No markers remain. Checklist 16/16.

- **On "no implementation details"**: the spec names gurobi and mosek, and the tolerance
  span used for rank agreement. These are *measurements and instruments*, not design
  choices — naming them is what makes the problem statement checkable. No remedy is
  prescribed: the Assumptions section lists five candidate approaches and commits to none,
  and FR-004 requires the choice to be made by measurement.

- **On the headline criterion**: SC-001 is deliberately sharp. Both halves — 105-of-105
  coverage and residual at or below the target — have each been achieved individually on
  this exact model, so a failure means the combination is genuinely hard, not merely
  unattempted. That is the property that makes it a good test of the feature.

- **Deliberately NOT asserted**, per the parent feature's reporting discipline: that any
  candidate remedy will work, that any runtime is achievable, or that any named model will
  reach full coverage. Whether the gap is closable at all is stated as a finding of the
  work.

- **Two requirements added after the initial draft, on user instruction**: the solver
  comparison must be PAIRED at identical greedy state and instrumented inside the routine
  (FR-016 to FR-018), and the numerical-emphasis concept must have an analogue for every
  solver rather than CPLEX alone (FR-019 to FR-021). The second carries a much wider blast
  radius than the rest of the feature — it touches the shared solver parameter layer that
  every toolbox solve passes through — so the spec gives it its own section and routes the
  decision to implementation approval rather than letting it be approved by inheritance.

- **The distinction the spec is built around**: a *sampling* shortfall (reachable but not
  found) versus a *structural* one (not reachable with non-negative weights). Conflating
  them is how the parent feature's first hypothesis went wrong, and FR-005/FR-006 exist to
  prevent this feature repeating it.
