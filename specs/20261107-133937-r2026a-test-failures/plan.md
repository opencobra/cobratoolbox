# Implementation Plan: Fix the R2026a fast-mode suite failures

**Branch**: `20261107-133937-r2026a-test-failures` | **Date**: 2026-11-12 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20261107-133937-r2026a-test-failures/spec.md`

## Summary

`upstream/develop` @ `5200aad48` fixes none of the failures, and it is merged here (`1357a49ec`). The plan
(research R0-R6):

- **Agent mode (US1)**: mark glpk, pdco, mosek and matlab installed only when the local file or license predicate
  that `changeCobraSolver` already uses holds. Set the EP, CLP and NLP defaults only for installed solvers. Remove
  the thermochemistry `new/` folders by filtering the path string.
- **`testFitC13Data` (US1)**: read `solvers.LP{1}` instead of the undefined `solverPkgs`.
- **Error-parity tests (US2)**: replace the exact identifier and message comparison with an exact comparison plus
  an explicit, release-annotated list of equivalent errors, and self-check that different errors are still
  rejected. The fixtures are not changed.
- **Ecosystem (US3)**: the mosek diagnosis found no `NaN` and no non-optimal solve. The 1e-9 zero threshold is
  below mosek's interior-point accuracy. By the maintainer's decision, the default `delta` of
  `ecosystemQualitativeFVA` becomes the LP solver's `feasTol`.
- **Worktree (US4)**: treat `.git` as a checkout whether it is a folder or a file.

## Technical Context

**Language/Version**: MATLAB R2026a Update 3 (reference); R2024b compatibility of the parity tests argued from the
recorded fixtures; RunMat-compatible source form (explicit `end`, `name()` calls) kept

**Primary Dependencies**: COBRA internals: `changeCobraSolver` predicates, `prepareTest` /
`getAvailableSolversByType`, `getCobraSolverParams`, `fluxVariability`. Solvers glpk, gurobi and mosek (LP).

**Storage**: N/A. The test fixtures (`.mat`) are read-only.

**Testing**: `runScriptFile`-style runs of the six named tests after each start-up mode; `testInitCobraToolbox`;
the four `testEcosystem*` tests with glpk, gurobi and mosek; fast-mode `testAll` for SC-004

**Target Platform**: Linux, local MATLAB via the MATLAB MCP server plus `matlab -batch` for fresh start-ups; CI
(default mode) unchanged

**Project Type**: MATLAB library (single project)

**Performance Goals**: agent start-up at most 1 s slower (SC-002); the added checks measure about 0.07 s

**Constraints**: `src/analysis/thermo/inchi/` read-only (FR-009); default-mode behaviour unchanged except for git
detection (FR-003); no `external/`, `deprecated/` or submodule edits

**Scale/Scope**: 2 source files (`initCobraToolbox.m`, `ecosystemQualitativeFVA.m`), 5 test files

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design: PASS.*

- **Scientific code quality**: `ecosystemQualitativeFVA` changes only its default zero threshold for qualitative
  states. FVA bounds (`fvaResults`) are untouched, and feasibility versus result is unchanged. Solver interfaces
  are untouched: only `initCobraToolbox`'s agent-mode bookkeeping of `SOLVERS`. Public default change approved in
  the spec (Principle II; Clarifications 2026-11-12); help text documents it and the old-behaviour recipe.
- **Testing and reproducibility**: narrowest tests first: the six named tests, `testInitCobraToolbox` (new
  assertions on solver flags, `new/` folders and conditional mosek), the parity tests' self-check (SC-003),
  `testEcosystemToy` with three solvers plus the other ecosystem tests (FR-007), then fast-mode `testAll` after
  both modes (SC-004). US4 uses a documented reproducibility check (quickstart step 6, reason in research R6).
  Fixed seeds are unaffected.
- **User experience and diagnostics**: agent mode still prints one summary line. Skipped tests name the missing
  solver via `prepareTest`. A rejected parity error keeps the full expected/actual diagnostic.
- **Performance and numerical integrity**: SC-002 bounded and measured (R1). No solver tolerance, status or
  verification step changes. The new `delta` default is tied to the solver's own feasibility tolerance (R5).
- **External-solver configuration audit**: research R5. No option changed. `feasTol` maps to glpk `tolbnd` and
  mosek `MSK_DPAR_INTPNT_TOL_PFEAS` (verified); the gurobi mapping is to be confirmed in implementation. The
  instance is the 23-reaction toy community LP.
- **Spec-driven scope control**: edit `initCobraToolbox.m`, `src/analysis/ecosystem/ecosystemQualitativeFVA.m`,
  `test/verifiedTests/base/testInstall/testInitCobraToolbox.m`,
  `test/verifiedTests/dataIntegration/testFitC13Data/testFitC13Data.m`,
  `test/verifiedTests/analysis/testReactingMoieties/{testExtractBondSubgraphs,testClassifySubgraphIsomorphism}.m`,
  `test/verifiedTests/analysis/testEcosystem/testEcosystemToy.m`. Read-only: `src/analysis/thermo/inchi/**`,
  fixtures under `testReactingMoieties/data/`, `changeCobraSolver.m`. No new files in `src/` or `test/`. The
  unrelated uncommitted edit to `findStoichConsistentSubset.m` is excluded from this feature's commits.
- **MATLAB coding standards**: no `evalc`; warnings stay visible; no new `try/catch`; optional arguments via the
  existing `inputParser` (`delta` default becomes `[]` and is resolved after parsing, no `nargin`); help text
  updated (VII-E). Skills: `matlab-core:matlab-testing` and `matlab-core:matlab-review-code` for review.
- **Parameter-setting fidelity**: N/A (no ported or literate output).
- **Alternative-runtime debt**: N/A. No runtime-only path is added. `runmat` mode inherits the agent changes using
  MATLAB built-ins (VIII-Runtime); quickstart step 8 checks RunMat if a binary is available.
- **Artifact placement**: only `specs/20261107-133937-r2026a-test-failures/**` (research, data model, contracts,
  quickstart, and later `agent-runs/<ts>/implementation-receipt.md`); verification output goes to `results/`
  (gitignored). No placement changes.

## Project Structure

### Documentation (this feature)

```text
specs/20261107-133937-r2026a-test-failures/
├── spec.md
├── plan.md              # this file
├── research.md          # R0-R6
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── initCobraToolbox-agent-mode.md
│   ├── ecosystemQualitativeFVA-delta.md
│   └── error-parity-check.md
├── checklists/requirements.md
└── tasks.md             # /speckit-tasks
```

### Source Code (repository root)

```text
initCobraToolbox.m                                   # agent solver predicates (local function), EP/CLP/NLP
                                                     # defaults, agent new/ path filter, .git file-or-folder
src/analysis/ecosystem/ecosystemQualitativeFVA.m     # default delta = LP feasTol; help text
test/verifiedTests/base/testInstall/testInitCobraToolbox.m        # agent-mode assertions; mosek conditional
test/verifiedTests/dataIntegration/testFitC13Data/testFitC13Data.m  # solvers.LP{1}
test/verifiedTests/analysis/testReactingMoieties/testExtractBondSubgraphs.m        # equivalence list + self-check
test/verifiedTests/analysis/testReactingMoieties/testClassifySubgraphIsomorphism.m # equivalence list + self-check
test/verifiedTests/analysis/testEcosystem/testEcosystemToy.m      # assert default delta = feasTol; explicit
                                                                  # 1e-9 keeps old states
```

**Structure Decision**: single MATLAB library; all edits are in place in existing files.

## Implementation order

1. US1: `initCobraToolbox.m` agent changes, `testInitCobraToolbox.m`, `testFitC13Data.m`.
2. US2: the two parity tests.
3. US3: `ecosystemQualitativeFVA.m` and `testEcosystemToy.m`.
4. US4: git detection, then quickstart step 6.
5. Verification: quickstart steps 1-5 and 7; implementation receipt.

## Complexity Tracking

No constitution violations.
