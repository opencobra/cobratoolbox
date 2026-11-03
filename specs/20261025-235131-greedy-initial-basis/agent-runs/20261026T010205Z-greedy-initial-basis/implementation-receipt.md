# Implementation Receipt — 20261025-235131-greedy-initial-basis

## Prompt

`/speckit-implement` (no arguments), after Gate 2 approval of T001–T026 with the core
implementer path (human-loop.md, 2026-10-26). At the checklist gate, the user chose
"Yes, proceed" with the standing Completion Integrity item open.

## Final response

`greedyExtremeRayBasis` can now complete a basis you supply, and it retries a wrong-sign targeted ray. All 26 tasks are done and every check passes. Commits on `20261025-235131-greedy-initial-basis`, from `6fe3fe171` to `e1def8983`; nothing is pushed.

**What the function now does**
- **Supplied basis.** `param.initialBasis` takes rows in left mode (`k x m`) or columns in right mode (`n x k`).
  - A vector with any negative entry is rejected as `'negative'`. One that misses the same accuracy target the search's rays must meet is rejected as `'accuracy'`.
  - The rest are kept in your order while they raise the rank; the others are reported as dependent.
  - Kept vectors come back unchanged as the first rows of `Zpos`, survive restarts, and only the missing rays are searched for.
- **Sign retry.** A targeted ray that is accurate but dependent is re-solved once with the opposite sign before a failure is counted. This is on for every call and draws no random numbers.
- **New `status` fields** on every return path: what was kept, dependent and rejected (indices and reasons), `raysAdded`, `nSignRetries` and `nLPSolves`.
- **Documentation.** The help header gains the new options, the status fields, an example, and a NOTE in the style of the earlier ones.

**Evidence**
- **Small fixtures** (`testGreedyExtremeRayBasis`, both modes), all passing:
  - Dimer: complete with 0 LPs solved.
  - Antiport: the two supplied rows are kept and one ray is added. It is either the cytosolic or the outer total; gurobi returned the outer total, (1,1,0,0,1,1)/4.
  - Exchange/transport: rows 1–3 kept, row 4 reported dependent, 0 LPs.
  - Sign recovery: with the wrong sign forced first, (0,0,1) is recovered after 1 retry and 2 LPs. With the right sign first, 0 retries and 1 LP.
  - Rejection reasons and the wrong-orientation error.
- **Unchanged outputs without a supplied basis.** The unmodified function's outputs were recorded first. `Zpos`, `Z` and the status are value-identical after every phase on ecoli_core (left, and right on `S'`) and on iDopaNeuroC. No sign retry fired on those runs.
- **Other tests.** `testCheckNullspaceBasis` and `testNullspaceAccuracyTarget` pass unchanged.
- **Real models** (`fixture6RealModelCheck`):
  - iDopaNeuroC: 50 of 50 supplied rows are kept unchanged and the sum row is reported as dependent; 55 rays are added to reach 105, in 3.0 s.
  - Recon3D: of 125 `model.L` rows, 49 are rejected for accuracy, which matches the 101 of 251 rows of that pre-2026-09 basis that miss today's target. The remaining 76 are kept unchanged and 175 rays are added to reach 251, in 21.6 s.

**Not verified**
- Fixtures 2 and 4 have only run with gurobi. This MATLAB has no glpk or CPLEX, so the non-gurobi paths those tests allow are untested locally.
- The `keptExceedsNullity` warning and the `keptRowFailedVerification` error are defensive and unreachable from any fixture.
- No real-model run fired the sign retry. Fixture 4 is the only evidence for it.
- The moiety route (`identifyConservedMoieties` `L` as input) is untested at genome scale, because the repo has no atom-mapped Recon3D or iDopaNeuroC.

**Departures from tasks.md**
- **Baseline right-mode run.** The baseline's right-mode run uses `S'`. Right mode on ecoli_core's own `S` stops on its 60 s wall-clock budget at 1 of 28 rays, and its counters differed between two runs (4816 vs 5431 targeted objectives), so it can't be a bit-for-bit baseline. tasks.md T001 records this.
- **Hit fraction print.** The printed "Hit fraction" now excludes kept vectors. Without a supplied basis it prints the same value as before.
- **Stale cache.** MATLAB served a stale copy of an edited file from this drive once, so every run is now preceded by `clear functions; rehash`.

## Diff summary

`git diff --stat develop...` (excluding the feature directory):

| File | Change |
|---|---|
| `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m` | `param.initialBasis` (orientation, size error, partition into kept/dependent/rejected); search seeded from the kept rows and restored on restart; final-verification guard for kept rows; `>=` completeness rule with the `keptExceedsNullity` warning; inner sign-retry loop; `param.testHook` (test only); local functions `solveCandidate`, `objectiveFromDirection`, `partitionInitialBasis`, `keptSupport`, `emptyInitialBasisPartition`, `addInitialBasisStatus`; `targetedObjective` returns its direction and supports canonical orientation; new status fields on all four return paths; header OPTIONAL INPUT, status, EXAMPLE and NOTE |
| `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m` | new-field assertions on normal and early-return paths; fixtures 1–4 left mode, rejection reasons, all-zero row, size error; fixtures 1–3 right mode and orientation error |
| `CLAUDE.md` | SPECKIT plan pointer updated (planning phase) |

Feature directory: `baselineRecord.m`, `baseline-summary.md`, `baseline/.gitignore`,
`fixture6RealModelCheck.m`, `fixture6RealModelCheck-expected.md`, and the Spec Kit artifacts.
Unchanged, as verified by `git diff --quiet`: `findExtremePool.m`, `src/base/solvers/`.

## Tests

MATLAB R2026a Update 3 (`matlab` MCP server), gurobi.

| Check | Result |
|---|---|
| `testGreedyExtremeRayBasis` | PASS (74.5 s) |
| `testCheckNullspaceBasis` | PASS |
| `testNullspaceAccuracyTarget` | PASS |
| `baselineRecord('compare')`, after T005, T011, T016 and T025 | identical on all 3 runs each time |
| `fixture6RealModelCheck` | iDopaNeuroC PASS, Recon3D PASS |
| Code Analyzer, all four files | no issues except 2 info-level sparse-indexing notes in SRC, one pre-existing |
| Diff scope vs develop | SRC, TST, CLAUDE.md and the feature directory only |

## Unresolved issues

- Fixtures 2 and 4 were not run with glpk or ibm_cplex (none installed here); CI will exercise them where present.
- FR-006a (`keptExceedsNullity`) and FR-007 (`keptRowFailedVerification`) are not reached by any fixture (analyze U1).
- The sign retry fired only on fixture 4, never on a real model.
- Recorded follow-ups, out of scope: exact integer rays from vertex support; the entrywise faithful-accounting check in `identifyConservedMoieties`; `getRankLUSOL` hiding LUSOL's `inform` flag (project memory).
- The pre-existing `warning('off', ...)` calls in `testGreedyExtremeRayBasis.m` (not added here) conflict with constitution VII-B; this feature leaves them unchanged.
