# Implementation Plan: Reconcile the two greedyExtremeRayBasis initial-basis features and merge upstream

**Branch**: `20261106-213424-greedy-basis-reconcile` | **Date**: 2026-11-07 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20261106-213424-greedy-basis-reconcile/spec.md`

## Summary

Merge `upstream/develop` (which already contains `origin/develop` and feature B, research R1) into this feature
branch. Resolve `greedyExtremeRayBasis.m` by taking B's published file and porting A's checkpoint machinery and
sparse norms onto it, with the checkpoint stored in the caller's orientation so it is directly resumable
(research R3). Resolve the five mechanical conflicts (R2). Fix the three failing tests (two share the confirmed
missing-`end` parse error; the third is diagnosed at run time, R4). Verify against two `testAll` baselines, then
fast-forward `develop` and, on explicit confirmation, push and open the upstream PR.

## Technical Context

**Language/Version**: MATLAB R2026a (reference); RunMat-compatible source form (explicit `end` terminators)

**Primary Dependencies**: COBRA Toolbox internals (`findExtremePool`, `getRankLUSOL`, `changeCobraSolver`); LP solver gurobi (default of the existing tests)

**Storage**: checkpoint MAT-file (`-v7.3`) at a caller-chosen path; test baselines under `results/` (gitignored)

**Testing**: `runtests` on `test/verifiedTests/analysis/testTopology/{testGreedyExtremeRayBasis,testGreedyExtremeRayBasisResume,testCheckNullspaceBasis}.m`; full `testAll` for FR-012

**Target Platform**: Linux, local MATLAB via MATLAB MCP server; CI unchanged

**Project Type**: MATLAB library (single project)

**Performance Goals**: none new; checkpoint writes bounded by `checkpointInterval` (default 300 s)

**Constraints**: B's API is published upstream (Principle II); no `external/`, `deprecated/` or submodule edits; `git fetch`/push over SSH currently fails (R6)

**Scale/Scope**: 1 function reconciled (~1200 lines), 1 test adapted, 5 mechanical conflicts, 357-file upstream merge

## Constitution Check

- **Scientific code quality**: touches the extreme-ray basis search only at its seeding/checkpoint boundary; B's acceptance rule, partition and sign retry are taken verbatim. Help text gains the checkpoint parameters and the resume recipe.
- **Testing and reproducibility**: narrowest first — `checkcode` (form), `testGreedyExtremeRayBasis` (B contract + inertness), `testGreedyExtremeRayBasisResume` (checkpoint/resume, adapted), `testCheckNullspaceBasis`; then `testAll` against two baselines. Existing `prepareTest('needsLP', true)` declarations kept. Fixed `rng` for inertness comparison against `467094a5d`.
- **User experience and diagnostics**: B's partition summary line and warnings (`keptExceedsNullity`, `keptRowFailedVerification`) unchanged; A's `checkpointFailed` warning kept; `status.checkpointFile` on every return path.
- **Performance and numerical integrity**: sparse Frobenius norms equal the dense values (FR-008); no verification step is made skippable; the final kept-row verification of B stays mandatory.
- **External-solver configuration audit**: N/A — no solver call or option is added or changed; the solver nomination/restore logic is taken from B unchanged.
- **Spec-driven scope control**: edit `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m`, `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasisResume.m`, the three RunMat-conflict files (resolution only), `CLAUDE.md` (plan pointer only), `.specify/feature.json`; plus whatever the `testCheckNullspaceBasis` diagnosis requires if small (spec clarification 3). Read-only: `external/`, `deprecated/`, submodules, the other session's `findStoichConsistentSubset.m`, `specs/20261104-134231-runmat-init-exploration/`.
- **MATLAB coding standards**: no `evalc`, warnings visible, `onCleanup` writer catches and re-reports via `warning` without swallowing the original error, no `nargin`; `matlab-core:matlab-review-code` consulted for the reconciled file.
- **Parameter-setting fidelity**: N/A (no ported/literate output).
- **Alternative-runtime debt**: the explicit `end` terminators are the VIII-Runtime form already adopted repo-wide; no new register entry.
- **Artifact placement**: spec artifacts under the feature dir; `testAll` outputs to `results/` (gitignored); receipt under `agent-runs/`. No source file moves.
- **Backward compatibility (Principle II)**: B's contract unchanged; A's parameters are new and optional, defaulting to no checkpoint; `status.raysSeeded` was never published, so dropping it breaks nothing.

**Gate result**: PASS, no violations.

## Project Structure

### Documentation (this feature)

```text
specs/20261106-213424-greedy-basis-reconcile/
├── spec.md, plan.md, research.md, data-model.md, quickstart.md
├── contracts/greedyExtremeRayBasis.md   # delta over B's contract
├── checklists/requirements.md
├── tasks.md                             # /speckit-tasks
└── agent-runs/<UTC>-<name>/implementation-receipt.md
```

### Source Code (repository root)

```text
src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m      # reconciled
test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasisResume.m  # adapted
test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m        # from upstream, unchanged
src/analysis/thermo/reactantContribution/waterGibbsEnergyOfFormation.m      # conflict: upstream + end
src/analysis/wholeBody/PSCMToolbox/compareBounds2Models.m                   # conflict: upstream + end
src/analysis/wholeBody/PSCMToolbox/hostMicrobeInteraction/setSimulationConstraints.m  # conflict: upstream + end
CLAUDE.md, .specify/feature.json                                            # conflict: develop's + pointer
```

**Structure Decision**: existing COBRA layout; no new files outside the feature directory.

## Execution order

1. Record baseline `testAll` on old `develop` (in `../fork-cobratoolbox-develop`) and on `upstream/develop` (a detached temporary worktree) — can run in background while 2–4 proceed.
2. `git merge --no-ff upstream/develop` on the feature branch; resolve the five mechanical conflicts.
3. Resolve `greedyExtremeRayBasis.m` per research R3 porting map; adapt the resume test.
4. Narrow tests (quickstart 1–5); diagnose `testCheckNullspaceBasis`.
5. `testAll` on the merged tree; compare (FR-012).
6. `git merge --ff-only` the feature branch into `develop`; verify ancestry (FR-011).
7. On explicit user confirmation: push, open PR (FR-013).

## Complexity Tracking

None.
