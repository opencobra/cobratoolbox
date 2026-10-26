# Research: greedyExtremeRayBasis initialBasis and sign retry

Feature: `specs/20261025-235131-greedy-initial-basis/` · Spec: [spec.md](spec.md)

Notation as in spec §Background: operative matrix `N` (`m x n`), `K = {w >= 0 : N'w = 0}`,
feasible polytope `P = K ∩ {1'w = 1}`, `G` the rows currently held, `g` the unit leading
direction of `ker(N')` orthogonal to `G` produced by the local function
`targetedObjective`.

---

## R1. The "`|g'w|` below tolerance" trigger (resolves checklist CHK017)

**Question.** Spec FR-008 (from the feature prompt) re-solves with `-g` when the `+g` vertex
is dependent on `G` *or* `|g'w|` is below a tolerance. What tolerance?

**Analysis.** From the proof of Proposition (c): every `w` in `span(G)` has `g'w = 0`, because
`g` is orthogonal to `span(G)`. Contrapositive: `g'w ≠ 0` implies `w ∉ span(G)`. The converse
fails. When the deficit `delta = nullity - rank(G)` exceeds 1, `g` is only ONE direction of
the orthogonal complement. A vertex with `g'w = 0` can then lie outside `span(G)`, and it is
a genuine new extreme ray. So:

- A *dependent* vertex always has `g'w ≈ 0`. The value test adds nothing to the rank test
  that the search already runs on every candidate.
- A *small-valued but independent* vertex is a valid new ray. A value tolerance used as a
  trigger would discard it, costing an extra LP and possibly a valid ray. It would also add
  a second tolerance, unrelated to the derived accuracy target, that the method would have
  to justify.

The rank test is already the authority for "outside `span(G)`". It uses the same routine
(`getRankLUSOL` on the support columns) as every other acceptance decision.

**Decision.** The retry fires when the `+g` vertex passes the accuracy test and FAILS the
independence test, i.e. when it would otherwise be counted as a dependence failure. No
separate value tolerance is introduced. `g'w` is still computed for each targeted solve,
but it is never used to decide anything: it is reported in a debug-level print
(`printLevel > 2`) so that the zero-valued case the prompt describes stays visible.

**Spec impact.** FR-008's phrase "or `|g' * w|` is below a stated tolerance" is replaced by
this rule, with a pointer to R1 (the spec is amended in the same planning pass; flagged for
the human at Gate 2). Behaviour on fixture 4 is unchanged: the `-g` vertex `(1/2,1/2,0)` is
both zero-valued and dependent, so it triggers the retry under either reading.

**Alternatives considered.**
- *Tolerance `1e-8`*, the scale of the existing `singularValues(1) <= 1e-8` cut in
  `targetedObjective`. Rejected because it discards valid zero-valued rays (above).
- *Tolerance relative to `acceptanceTarget`* (for example `sqrt(m) * acceptanceTarget`).
  Rejected for the same reason. It would also tie the trigger to a residual scale that
  measures something different (`N'w`, not `g'w`).
- *Value test as a pre-screen that skips the rank test.* Rejected: a pre-screen that is
  sometimes wrong cannot replace the authoritative test, and the saving (one LUSOL rank on
  `nBases + 1` rows) is negligible next to an LP.

---

## R2. Sign convention and the test-only hook (FR-008, FR-010)

**Facts.** Today `targetedObjective` takes `direction = leftVectors(:,1)` from `svd`. Its
sign is whatever LAPACK returns. It builds `obj = direction - min(0, min(direction))`, then
normalises. On `P` the shift is a constant, because `1'w = 1`, so the LP maximises
`direction'w`.

**Decision.**
1. `targetedObjective` returns the direction `d` exactly as today. The FIRST objective is
   built from `+d` with today's shift and normalisation, so the first targeted solve is
   bit-for-bit the current one (FR-013).
2. The retry builds the objective from `-d` with the same shift and normalisation, in the
   same local function, through a sign argument.
3. Test-only hook: `param.testHook` (struct, default absent, so behaviour is unchanged).
   - `.targetedSignFirst` ∈ {+1, -1}: orient `d` canonically, so that its
     largest-magnitude entry is positive (ties broken by the lowest index), then try
     `targetedSignFirst * d` first. Without the hook there is no canonical re-orientation,
     to preserve FR-013.
   - `.forceTargeted` (logical): use the targeted objective on every iteration with
     `0 < nBases < raysExpected`, bypassing the `nfail >= nfailMax` gate.

   Both are needed for a deterministic fixture 4. With `initialBasis = [1 1 0]`, a random
   objective returns `(0,0,1)` on about half the draws, so the stall gate is usually never
   reached. Both fields are documented in the header as test-only, under `OPTIONAL INPUT`.

**Fixture 4 trace (expected).** Canonical `d = (0,0,1)`, so `-d` is tried first:
`obj ∝ (1,1,0)`. The vertex is `(1/2,1/2,0)`, which is dependent on `[1 1 0]`, so the
search retries. With `+d`, `obj = (0,0,1)` and the vertex is `(0,0,1)`, which is
independent and accepted. `nLPSolves = 2`, `nSignRetries = 1`, `nTargetedObjectives = 1`.

**Alternatives.** A separate unit-testable helper file in `src/` (rejected: adds a public
file for a local function; Principle V); exposing the local function via a function handle
(rejected: unusual in this codebase, still an interface).

---

## R3. Integrating `initialBasis` into the search (FR-001 – FR-007)

Read-and-map of the current loop (`greedyExtremeRayBasis.m` lines 399–612):

| Current state | Initial value today | With `nKept` kept rows |
|---|---|---|
| `Zpos` | `sparse(raysExpected, nVar)` | `sparse(max(raysExpected, nKept), nVar)`, with rows `1:nKept` set to the kept rows |
| `nBases` | 0 | `nKept` |
| `nonZeroColumnsBool` | `false(1, nVar)` | support of the kept rows |
| restart block (l. 452–470) | resets to empty | resets to the kept-only state above (FR-005) |
| `bestZpos/bestNBases` | empty / 0 | kept-only state / `nKept` |
| loop guard `nBases < raysExpected` | — | unchanged; if `nKept >= raysExpected` the loop body never runs (FR-006, `nLPSolves = 0`) |
| `nBases < 2` random branch | — | unchanged code. With `nKept >= 2` the support-zeroing branch is live from the first iteration (FR-005: kept rows count as accepted in every respect) |
| final per-row verification (l. 644–654) | drops failing rows | if a failing row index `<= nKept` → `error('greedyExtremeRayBasis:keptRowFailedVerification', ...)` (FR-007); otherwise as today |
| `status.outcome` | complete if `nBases == raysExpected` | complete if `nBases >= raysExpected`; if `nKept > raysExpected`, warning `greedyExtremeRayBasis:keptExceedsNullity` (FR-006a) |

**Validation pipeline (FR-002, FR-003)**, run once after `acceptanceTarget` is known and
before the loop. It runs only on the path that reaches the search, since the
`missingField`, `emptyNullspace` and `badlyScaled` early returns precede
`acceptanceTarget`.
1. Shape: after mode orientation (right mode: transpose the `n x k` input to `k x n`,
   R4), require `size(B, 2) == nVar`, real numeric. Otherwise
   `error('greedyExtremeRayBasis:initialBasisSize', ...)` naming the expected size.
2. Per vector, in supplied order: any entry `< 0` → rejected `'negative'`. Otherwise, if
   `max(abs(v * Sop)) > acceptanceTarget` → rejected `'accuracy'`. This is the same metric
   as the final verification (`max(abs(Zpos*model.S), [], 2)`) and the in-loop acceptance
   (`norm(model.S'*x, inf)`).
3. Greedy independence: append each surviving vector and keep it iff `getRankLUSOL` on
   the support columns of the kept set rises by one. This is the same construction as the
   in-loop test (l. 574–576). An all-zero vector never raises the rank → `'dependent'`.

**Early returns.** The three early-return status structs gain the new fields with
`initialBasisSupplied = k`, every other count 0 and empty index lists. They return no
basis, so nothing is kept.

**Known caveat (not fixed here).** The project memory records that `getRankLUSOL` hides
LUSOL's `inform` flag. The independence decision for supplied rows inherits exactly the
risk the in-loop decision already carries, so it is neither better nor worse. It stays an
open defect, out of scope.

---

## R4. Right-nullspace mode (FR-012)

The function transposes `model.S` at line 320 and transposes `Zpos` back at line 809. The
supplied basis follows the same pattern: right-mode input is `n x k` (one candidate per
column, as in the returned `Zpos`). It is transposed to `k x n` immediately after the
`model.S` transpose, and every later step is mode-agnostic. Indices in status refer to
supplied columns. Test: fixtures 1–3 with `S := N'` and `leftRight = 'right'` give results
equal to the left-mode results transposed (SC-005).

---

## R5. LP solver configuration-surface audit (resolves CHK032; Principle IV)

**Solver invoked.** gurobi, through `findExtremePool` → `solveCobraLP`. The routine
nominates it by default, and `param.solverSettings` forwards the tuned sets from feature
20260915-082551-extreme-ray-coverage.

**What this feature changes in the LP.** Only the objective vector `c` (the `-d` retry)
and the NUMBER of solves. The LP family is unchanged: `A = [N'; 1']` (sparse), `b = [0; 1]`,
`0 <= w <= 100`, all rows equality, maximise. Dimensions, sparsity, scale, bounds and
equality structure are identical to the existing targeted solves. `findExtremePool` is not
edited (FR-014).

**Configuration surface checked** (against `solveCobraLP`'s gurobi branch and the settings
audit of 20260915 research):

| Setting | Default in path | Fit to this LP | Action |
|---|---|---|---|
| Method | gurobi auto (concurrent/dual simplex for LP) | must return a VERTEX (basic solution); simplex does | none |
| Crossover | on by default if barrier is chosen | required for a vertex if barrier is used | none; already relied on |
| FeasibilityTol / OptimalityTol | from `getCobraSolverParams` (1e-6/…) | acceptance is judged by the function's own derived target, not by these | none |
| Presolve | auto | no effect on which vertex for a unique optimum (20260915 measurement) | none |
| Seed | default | measured in 20260915 to not change the vertex for a unique optimum | none |

The `-d` objective has the same magnitude (unit norm after the shift) and the same
density as `+d`. No default is mismatched to the profile, so nothing is overridden.

**Not used.** mosek stays rejected (`param.solver = 'mosek'` errors; it returns no
vertices). The shortfall-classification LP in `attainableNullspaceDimension` is untouched,
and it is excluded from `nLPSolves` (spec FR-011).

---

## R6. Where the change is recorded (resolves CHK035; FR-016)

The repository has no CHANGELOG/NEWS/release-notes file. Earlier features on this function
(20260914, 20260915, 20261003) recorded their default-behaviour changes in exactly these
places, so they are "the usual places":

1. The function help header: a `NOTE:` paragraph "CHANGE OF DEFAULT NUMERICAL BEHAVIOUR,
   October 2026, feature 20261025-235131-greedy-initial-basis", in the style of the two
   existing ones, plus the `OPTIONAL INPUT` entries (`initialBasis`, `testHook`) and the new
   `status` field lines.
2. This feature directory: spec, plan, contracts (status/param contract), the
   implementation receipt under `agent-runs/`, and `human-loop.md`.
3. The commit message(s) and the PR title and summary (constitution §Development Workflow).

No documentation-site page documents this function beyond the auto-generated header, so
none needs editing.

---

## R7. Real-model demonstration route (fixture 6, US5)

**Availability.** No atom-mapped Recon3D or iDopaNeuroC exists in the repository. Atom-mapped
reaction files exist only for tutorial-scale models (`tutorials/analysis/conservedMoieties/
data/mini-ctf*`, DAS, an *E. coli* subset). So the prompt's first route
(`identifyConservedMoieties` `L` on iDopaNeuroC/Recon3D) is unavailable, and its fallback
applies: a random subset of rows of a previously computed `Zpos`.

**Decision.**
- **Primary: iDopaNeuroC** (in-repo, `papers/2023_iDopaNeuro/models/iDopaNeuroC.mat`; the
  model used by feature 20260914's reproducibility check; nullity 105, about 5 s for a full
  basis). Compute `Zpos0` with the function at a fixed seed. Supply a random subset of 50
  rows (fixed seed), plus one extra row equal to the sum of the first two chosen rows,
  which must be reported dependent. Assert the kept rows are value-identical, the outcome
  is `'complete'`, and the dependent index is correct.
- **Secondary: Recon3D** (`Recon3DModel_301_xomics_input_VK_withL.mat`, the file feature
  20261003 used, outside the repo under the VK data directory). Its field `model.L` is
  251 x 5824. That equals the internal left nullity 251 that 20261003 measured, so it is a
  previously computed non-negative basis, not a moiety matrix. Supply a random subset of
  125 of its rows. If `model.L` fails the current accuracy target, the run reports those
  rows as rejected with reason `'accuracy'`. That is itself the behaviour FR-002 requires
  and is recorded, not hidden.
- Both run as a reproducibility script under this feature directory
  (`fixture6RealModelCheck.m`), with expected output recorded in
  `fixture6RealModelCheck-expected.md`, following 20260914's
  `iDopaNeuroCReproducibilityCheck` pattern. It is not a CI test, because of model size and
  data availability (spec §Assumptions).

**Alternative noted, not adopted.** `identifyConservedMoieties` on the tutorial mini-ctf
model would exercise the moiety route end-to-end, but on a toy model. That is outside the
prompt's "iDopaNeuroC or Recon3D" scope. It is recorded as an optional extension only.

---

## R8. Reproducibility baseline for SC-004

Before any source edit, a script (`baselineRecord.m` in this feature directory) runs the
UNMODIFIED function at fixed seeds on:
(a) ecoli_core, left mode, the configuration used by `testGreedyExtremeRayBasis`;
(b) ecoli_core, right mode;
(c) iDopaNeuroC, left mode.

It saves `Zpos`, `Z` and the `status` struct to `baseline/` (gitignored `.mat` under the
feature directory, plus a committed markdown summary of hashes and counts). After
implementation, the same script in compare mode asserts `Zpos` and `Z` are value-identical
and every pre-existing status field is equal except `elapsedTime`, `spectrumTime` and
`pairedComparison`. If a run legitimately diverges because a dependent `+g` vertex occurred
(the FR-013 exemption), the comparison must show `nSignRetries > 0` for that run. Without
it, divergence is a defect.

---

## R9. MATLAB standards (Principle VII)

- The `matlab-core:matlab-review-code` and `matlab-programming` skills are registered and
  are applied at implementation. The openCOBRA style guide controls where they disagree.
- Optional fields are checked with `isfield`/`isempty`, never `nargin`. No `evalc`. The two
  new warnings (`keptExceedsNullity`, plus the existing ones) are raised with identifiers
  and never suppressed. No new `try/catch` is introduced.
- The test file already declares `solvers = prepareTest('needsLP', true)` and loops over
  `solvers.LP`. The new fixture blocks run inside that file, gated on
  `any(strcmp(solvers.LP, 'gurobi'))` so that they skip gracefully without gurobi. The
  function nominates gurobi by default, and the fixtures rely on vertex solutions. Each
  fixture block fixes `rng`. Rays are
  compared in exact rational form via `rats`/`round` after scaling by the smallest nonzero
  entry.
