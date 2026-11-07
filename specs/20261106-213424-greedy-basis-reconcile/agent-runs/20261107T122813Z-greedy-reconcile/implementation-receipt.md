# Implementation receipt — greedy-basis reconcile and upstream merge

## Prompt

`/speckit-implement` (no arguments), after Gate 2 approval on 2026-11-07: "Fix 3 items, then approve all"; testAll
fast mode; path `/speckit-implement`. Scope T001–T030, with T028 (push) and T029 (PR) each needing explicit
confirmation when reached.

## Final response

The merge is done locally, and nothing has been pushed. Local `develop` (`../fork-cobratoolbox-develop`) is now at
`42f9a21a2`, with `upstream/develop` and your fork's `develop` both merged in.

**What changed:**
- **`greedyExtremeRayBasis.m`:** it starts from upstream's version (PR #9's supplied initial basis, unchanged) and adds 089's `checkpointFile`/`checkpointInterval`. The checkpoint is saved in the caller's orientation, so `C = load(file); param.initialBasis = C.Zpos;` resumes in left and right mode. Every function now ends with `end`.
- **The three failing tests:** they had a single cause, 089's two local functions without `end`, which made the file unparsable. `testCheckNullspaceBasis` also calls `greedyExtremeRayBasis`; planning had missed that.
- **Other conflicts:** three files take upstream's content plus the RunMat `end`. `CLAUDE.md` and `feature.json` keep develop's.

**Verification:**
- **Narrow tests:** the three greedy tests pass, and so do 5 more that use the stoichiometric-consistency code.
- **No-option behaviour:** all 28 calls from the ancestor's test, replayed on the new function, give bit-identical `Zpos` and `Z`. Four calls differ in one status counter, and unmodified upstream differs in the same way: it counts how many LPs fit into a time budget.
- **Full suite (fast mode):** old `develop` 493/538 passed; upstream 567/605; merged 568/606. No regressions. The 6 tests that still fail also fail on upstream.

**Deviations from the plan:**
- **Test harness:** `COBRA_CI=1 testAll` drops gurobi from the path, so all three suite runs used one driver (`verification/runSuiteForBaseline.m`) with your startup's solver setup.
- **`develop` fast-forward:** this branch had started one commit behind `develop` (`2409e7fd5`, the whole-body EX_ change). I merged that in with no conflicts and re-ran the affected tests before the fast-forward.
- **Test-written file:** one test rewrites a tracked PDF; I restored it.

**Waiting on you:** the push to your fork and the upstream PR. SSH still fails; an HTTPS push using `gh`'s credentials works as a dry run.

## Diff summary

Merge `c5d173414` (upstream/develop `56dcc3064` into the feature branch), then `42f9a21a2` (develop tip `2409e7fd5`);
`develop` fast-forwarded to `42f9a21a2`. Against old develop, 294 files under `src/`+`test/` change, almost all
from upstream. Lines this feature authored, against `upstream/develop`:

| File | Change |
|---|---|
| `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m` | +130/−4: 089 checkpoint ported onto B; sparse Frobenius norms; `end` on all 14 functions; help text |
| `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasisResume.m` | +116 (new upstream): adapted to supplied-basis semantics; right-mode round trip; SC-002 resume |
| `waterGibbsEnergyOfFormation.m`, `compareBounds2Models.m`, `setSimulationConstraints.m` | +1 each: RunMat `end` on upstream content |
| `CLAUDE.md`, `.specify/feature.json` | develop's version (plan pointer → this feature) |
| `specs/20261106-213424-greedy-basis-reconcile/` | plan artifacts, `root-causes.md`, `verification/` scripts, this receipt |

## Tests

- `checkcode greedyExtremeRayBasis.m`: no terminator/parse issues; 2 info notes inherited from upstream.
- Terminator scan of 297 merged `.m` files: 0 `ENDCT`/`NOTERM` (2 upstream `FNDEF` name mismatches reported, not edited).
- `runtests`: testGreedyExtremeRayBasis, testGreedyExtremeRayBasisResume, testCheckNullspaceBasis — Passed (merged
  tree and again on `42f9a21a2`, with testCheckModelPreFBA, testExtremePools, testModelManipulationOri,
  testStoichiometricConsistency, testSubspaces — all Passed).
- Inertness (FR-007/FR-008/SC-003): 28/28 ancestor calls identical in `Zpos`, `Z` and every deterministic status
  field; `raysRejectedForAccuracy` differs in 4 time-budget runs (wall-clock dependent; upstream shows the same).
- Suite, fast mode, `runSuiteForBaseline`: old develop 538/493/9/36; upstream 605/567/6/32; merged 606/568/6/32
  (tests/passed/failed/skipped). Regressions: 0. Fixed: the 3 greedy tests. `results/…/regression.md`.

## Unresolved issues

- T028 push and T029 upstream PR: user chose "Don't push yet" and "Not now" (2026-11-07); both left open. SSH push fails (publickey); HTTPS via
  `gh auth git-credential` dry-runs as fast-forward `c8f02f273..42f9a21a2`.
- 6 tests fail on upstream and merged alike (testEcosystemToy, testClassifySubgraphIsomorphism,
  testExtractBondSubgraphs, testGetMolecularWeight, testOptimizeCbModelNLP, testFitC13Data) — out of scope.
- `initCobraToolbox` default mode runs `git init` / `git remote add origin` in a linked worktree (tests `.git` as a
  directory; a worktree has a `.git` file). Harmless here (remote add failed), worth a follow-up.
- An optKnock tutorial-derived test writes `test/tutorialDerived/design/optKnock/Results/EX_ac(e).pdf`, a tracked
  file, on every run (restored here).
- Spec SC-002's "interrupted after the search accepted k rays" is tested with a time-budget interruption holding
  k = 2 kept rays; a mid-search interruption is not deterministically testable without a new test hook.

## Other information

Deviations: suite harness (`runSuiteForBaseline` instead of `COBRA_CI=1 testAll`, which drops gurobi from the path);
baseline worktrees used symlinked submodules and agent-mode init; extra merge of develop tip `2409e7fd5` because the
feature branch started at `851c8e040`.
