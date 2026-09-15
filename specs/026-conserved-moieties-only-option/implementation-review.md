# Implementation Review

## Summary

Add `options.conservedMoietiesOnly` to `identifyConservedReactingMoieties.m` so callers can
get conserved moieties (`arm`, `moietyFormulae`) without the reacting-moiety bond-graph/
minimum-set-cover section running (and without needing a MILP solver), then extend the
function's existing test to prove the conserved-only path is numerically identical to the
existing full-computation path on the same inputs. Two files only; no new dependencies, no
new files besides Spec Kit artifacts.

## Embedded Core Commands Completed

- constitution: checked (v1.5.0, read in full)
- specify: invoked — spec.md written; one NEEDS CLARIFICATION marker resolved inline via
  AskUserQuestion during the specify quality-validation loop
- clarify: invoked — taxonomy scan of the finalized spec found no further material
  ambiguities beyond the one already resolved
- checklist: invoked — checklists/requirements.md (16/16) and checklists/interface-testing.md
  (13/13), both fully passing
- plan: invoked — plan.md, research.md, data-model.md, quickstart.md, contracts/function-interface.md written; agent-context (CLAUDE.md SPECKIT block) updated to point at this plan
- tasks: invoked — tasks.md written, 16 tasks across Setup / (empty Foundational) / US1 / US2 / Polish
- analyze: invoked (read-only) — see Cross-Artifact Analysis Summary below

## Cross-Artifact Analysis Summary

Full findings (spec.md / plan.md / tasks.md / constitution cross-check):

| ID | Category | Severity | Location(s) | Summary | Recommendation |
|----|----------|----------|-------------|---------|----------------|
| F1 | Underspecification / test-structure | **HIGH (RESOLVED — remediation task T007a added)** | tasks.md T007-T008; existing `testConservedReactingMoieties.m` top-of-file `prepareTest('needsMILP', true)` | The existing test file gates its **entire** script behind one top-level `prepareTest('needsMILP', true)` call, before `subModel`/`BG`/`dATM` are even built. As currently planned, T007/T008 add the new conserved-only assertions *later* in that same script — so on a CI runner with no MILP solver, the whole file (including the new, solver-independent assertions) is skipped at the top, never exercising them. This means SC-001 ("a user without a MILP solver installed can obtain conserved-moiety results... without a MILP-solver-required error") is not actually verified by this plan on such a runner — only on a runner that happens to have a MILP solver (which this repo's CI does, per the constitution's Gurobi note, so the feature is *not* untested in the repo's primary CI, but the specific solver-independence claim is untested wherever it matters most). | Two options for Gate 2: **(a)** accept as a documented, known limitation (the code path is still correct and manually verifiable per quickstart.md; CI with Gurobi does exercise it) — no tasks.md change; or **(b)** add one task to relocate the existing `prepareTest('needsMILP', true)` call from the top of the script to immediately before the pre-existing full-mode call/assertions that actually need it, so the new conserved-only assertions (and model-building) run regardless of MILP-solver availability. Option (b) is a small, in-scope, one-line-move change. |
| F2 | Underspecification | MEDIUM | tasks.md T008 | T008 verifies "no MILP solver required" only *structurally* (by not adding a second `prepareTest('needsMILP', true)` around the new assertions) — there is no positive runtime assertion that `intlinprog`/`solveCobraMILP` was never invoked. MATLAB has no simple built-in "assert function X was not called" primitive, so this is a reasonable, low-cost verification level for a feature this size. | Accept as-is; note in the implementation receipt that this is verified structurally (via code inspection: the `return` in T005 precedes all MILP-solver-invoking code) rather than via a runtime call-count assertion. |
| F3 | Coverage gap (minor) | LOW | spec.md FR-005; tasks.md | FR-005 ("signature MUST NOT change, BG remains required") has no task that *explicitly* asserts this — it is satisfied implicitly (no task in tasks.md touches the function's signature line), and T009's equivalence check indirectly requires both calls to already share the same `BG` input. | Accept — implicit satisfaction is sufficient for a requirement that is about what *doesn't* change; flagging here for traceability only, not blocking. |

**Coverage Summary**: 9/9 functional requirements (FR-001–FR-009) and 4/4 success criteria
(SC-001–SC-004) map to at least one task. 0 unmapped tasks (all 16 tasks trace to a
requirement, the Constitution's Principle V read-before-edit rule, or the Constitution's
Implementation Receipt Ledger). 0 CRITICAL findings (no constitution MUST is violated by the
plan as written — F1 is a test-effectiveness gap on a specific class of CI runner, not a
violation of a MUST principle). 1 HIGH, 1 MEDIUM, 1 LOW.

**Metrics**: Total Requirements: 13 (9 FR + 4 SC). Total Tasks: 16. Coverage: 100%.
Ambiguity Count: 0 (post-clarification). Duplication Count: 0. Critical Issues Count: 0.

## Proposed Implementation Scope

- **Tasks proposed**: All of T001-T016 (tasks.md), in order.
- **First independently testable slice**: Phase 3 (User Story 1, T004-T008) — the option
  itself, working and passing its own new assertions, before User Story 2's comparison
  assertions are added.
- **Files likely to change**:
  - `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`
  - `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
  - (if F1's option (b) is chosen) the same test file, one line relocated
- **Files that should NOT change**: everything else in
  `src/analysis/topology/reactingMoieties/` and `src/analysis/topology/conservedMoieties/`
  (per spec Assumptions — no bundled fix for the separately-tracked CRB2R/bond-node-
  canonicalization issues), and the test fixture data under
  `test/verifiedTests/analysis/testReactingMoieties/data/rxnFiles/`.

## Tests and Validation Expected

Narrowest relevant test first: run
`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` (extended
by T007-T011) via the MATLAB MCP server or `matlab -batch`; expected result is all assertions
pass (or the whole file skips cleanly with `COBRA:RequirementsNotMet` if no MILP solver is
present and F1's option (a) was chosen, or the whole file runs regardless of solver
availability if F1's option (b) was chosen). Secondary: the quickstart.md manual spot-check
(T014).

## Blocking Issues

None CRITICAL. F1 (HIGH) should be explicitly accepted or addressed at Gate 2 rather than
silently carried forward.

## Acceptable Risks

- F2 and F3 (see table) — both low-cost-to-accept, documented above.
- This feature does not fix the separately-tracked reacting-moiety defects (CRB2R
  over-attribution, bond-node head/tail canonicalization) — by design (spec Assumptions);
  conserved-only mode sidesteps that code rather than fixing it.

## Human Approval

- Approved: yes
- Approved option: Approve all proposed tasks (T001-T016, including T007a added in response to finding F1)
- Approved tasks/scope: all
- Required implementation invocation per constitution: /speckit-implement (user-selected)
- Date (UTC): 2026-09-14 10:51
