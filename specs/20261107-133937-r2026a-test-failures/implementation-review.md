# Implementation Review

## Summary

Fixes the six R2026a fast-mode failures and the worktree start-up finding. Three groups of change:

- **Agent-mode start-up**: honest solver flags and removal of the thermochemistry `new/` folders.
- **Test-only fixes**: `testFitC13Data`'s undefined name, and release-tolerant error parity in two tests.
- **Approved default change**: `ecosystemQualitativeFVA`'s zero threshold follows the LP solver's `feasTol`. The
  maintainer chose this after the plan-phase mosek diagnosis.

Upstream (`5200aad48`, merged as `1357a49ec`) fixes none of these.

## Embedded Core Commands Completed

- constitution: checked
- specify: invoked (`9f33a1482`, 2026-11-07)
- clarify: session 2026-11-12 (plan-phase US3 decision, recorded in spec Clarifications)
- checklist: `checklists/requirements.md` (from specify)
- plan: invoked 2026-11-12 (`cb1fb7394`)
- tasks: invoked 2026-11-13 (26 tasks)
- analyze: invoked 2026-11-13. 0 critical findings; 2 medium (I1 baseline wording, C1 legacy test headers); 4 low.

## Cross-Artifact Analysis Summary

- **I1 (medium)**: the spec's regression baseline names `develop` `2363a5a71`; the tasks use the pre-edit tip
  `cb1fb7394`, which includes upstream. Fix: edit the spec wording.
- **C1 (medium)**: three touched tests predate the III-Coverage header format. This is not caused by this
  feature; decide at Gate 2 whether it is in scope.
- **U1, A1 (low)**: stale SC-006/US3-1 wording; spec status still "Draft".
- **E1, E2 (low)**: two edge cases that cannot be exercised here; to be listed in the receipt.

## Proposed Implementation Scope

- **Tasks proposed**: T001-T026.
- **First independently testable slice**: US1 = Phase 1 baselines (T001-T003), Phase 2 (T004-T005), then
  T006-T013.
- **Files likely to change**:
  - `initCobraToolbox.m`
  - `src/analysis/ecosystem/ecosystemQualitativeFVA.m`
  - `test/verifiedTests/base/testInstall/testInitCobraToolbox.m`
  - `test/verifiedTests/dataIntegration/testFitC13Data/testFitC13Data.m`
  - `test/verifiedTests/analysis/testReactingMoieties/testExtractBondSubgraphs.m`
  - `test/verifiedTests/analysis/testReactingMoieties/testClassifySubgraphIsomorphism.m`
  - `test/verifiedTests/analysis/testEcosystem/testEcosystemToy.m`
  - `specs/20261107-133937-r2026a-test-failures/**`
- **Files that should NOT change**:
  - `src/analysis/thermo/inchi/**`
  - `test/verifiedTests/analysis/testReactingMoieties/data/**`
  - `src/base/solvers/getSetSolver/changeCobraSolver.m`
  - `src/analysis/ecosystem/getQualitativeFluxStates.m`
  - `external/`, `deprecated/` and submodules
  - `src/reconstruction/modelGeneration/stoichConsistency/findStoichConsistentSubset.m` (unrelated uncommitted
    edit, not staged)

## Tests and Validation Expected (narrowest first)

1. `checkcode` on the edited files.
2. `testInitCobraToolbox.m`; quickstart step 1 (fresh agent start-up).
3. `testFitC13Data`, `testOptimizeCbModelNLP`, `testGetMolecularWeight` after each start-up mode.
4. `testExtractBondSubgraphs`, `testClassifySubgraphIsomorphism` (self-checks: 8 and 4 synthetic rejections).
5. `testEcosystemToy` (glpk, gurobi, mosek), plus `testEcosystemClustering`, `testEcosystemScenarios` and
   `testConstrainEcosystemPoint`; the R5 flip comparison (0 with the default threshold, 28 with an explicit 1e-9).
6. Agent start-up timing, before and after (SC-002).
7. Worktree reproducibility check (quickstart step 6).
8. Fast-mode `testAll` after both start-up modes, before and after (SC-004). About 30 minutes per run, 4 runs.

## Blocking Issues

None.

## Acceptable Risks

- R2024b behaviour of the parity tests is argued, not run (R2024b not installed).
- The Optimization-Toolbox-present path (agent mode reporting `matlab` installed) cannot be exercised on this
  machine.
- The new `ecosystemQualitativeFVA` default may change qualitative states for users of mosek or other
  interior-point solvers. This is intended and approved, and documented in the help text.
- RunMat check only if a binary is available.

## Human Approval

- Approved: yes (2026-11-13)
- Approved option: Fix I1/U1/A1 in spec, then approve all (Recommended)
- Approved tasks/scope: T001-T026; C1 (legacy test headers) recorded as a receipt follow-up, not edited
- Required implementation invocation per constitution: `/speckit-implement`
- Date (UTC): 2026-11-13
