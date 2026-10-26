---

description: "Task list for greedyExtremeRayBasis initialBasis and sign retry"
---

# Tasks: Complete a supplied partial non-negative nullspace basis in greedyExtremeRayBasis

**Input**: Design documents from `specs/20261025-235131-greedy-initial-basis/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/greedyExtremeRayBasis.md, quickstart.md

**Tests**: Required (constitution III; spec FR-017). Each story's test assertions are
written before or with the behaviour they verify, in the EXISTING
`test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m` (III-Naming).

**Organization**: grouped by user story. Shorthand used below:
- `SRC` = `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m`
- `TST` = `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m`
- `FD` = `specs/20261025-235131-greedy-initial-basis/`

Line numbers refer to `SRC` at commit `5e8170e12` and will shift as edits land.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1–US5 from spec.md

---

## Phase 1: Setup (baseline before any source edit)

**Purpose**: Freeze the pre-feature behaviour so SC-004 can be checked (research R8).

- [X] T001 Write `FD/baselineRecord.m`: a function `baselineRecord(mode)` with
  `mode ∈ {'record','compare'}`.
  - It runs `greedyExtremeRayBasis` with `printLevel 0`, gurobi, and `rng(20261025,'twister')`
    before each call, on:
    - (a) ecoli_core (`load('ecoli_core_model.mat')`, `SConsistentRxnBool = true`), left mode;
    - (b) right mode on `S'` (the same problem transposed, so it completes deterministically; right mode on `S` stops on its wall-clock budget at 1 of 28 rays and its counters vary run to run — measured 4816 vs 5431 targeted objectives — so it cannot be a bit-for-bit baseline);
    - (c) iDopaNeuroC (`papers/2023_iDopaNeuro/models/iDopaNeuroC.mat`; reuse the loading
      in `specs/20260914-204640-greedy-left-nullspace-conditioning/iDopaNeuroCReproducibilityCheck.m`), left mode.
  - `'record'` saves `Zpos`, `Z` and `status` per run to `FD/baseline/<run>.mat` and writes
    `FD/baseline-summary.md`: per run `raysFound`, `raysExpected`, `nTargetedObjectives`,
    `nRestarts`, and a SHA-256 of `full(Zpos)` bytes via `java.security.MessageDigest`.
  - `'compare'` re-runs and asserts `isequal(Zpos, Zpos0)` and `isequal(Z, Z0)`, and
    `isequal` on every field of the baseline `status` except `elapsedTime`, `spectrumTime`
    and `pairedComparison`. If a run differs, it reports whether
    `status.nSignRetries > 0` (the FR-013 exemption) and errors otherwise.
- [X] T002 Run `baselineRecord('record')` against the UNMODIFIED `SRC` (confirm with
  `git diff --quiet -- SRC` first). Commit `FD/baseline-summary.md`; the `.mat` files stay
  ignored by `FD/baseline/.gitignore`.

---

## Phase 2: Foundational (status scaffolding, inert)

**Purpose**: Add the new status fields and counters with neutral values on every return
path, changing no behaviour. All user stories depend on this.

- [X] T003 In `TST`, add a block asserting that the E5 fields (data-model.md) exist on:
  - the normal path (ecoli_core, no `initialBasis`), with `initialBasisSupplied 0`,
    `initialBasisKept 0`, empty index lists, `raysAdded == raysFound`, `nSignRetries 0`
    and `nLPSolves >= raysFound`;
  - each early-return path already exercised in the file (`statusBad`, `statusBare`,
    `statusEmptyPath`), with every count 0.
- [X] T004 In `SRC`, add the counters `nLPSolves = 0` and `nSignRetries = 0` beside
  `nTargetedObjectives` (l. 429). Increment `nLPSolves` once per nominated
  `findExtremePool` solve (the ordinary branch l. 508, and once per call of
  `compareSolversAtState`, not per compared solver).
  - Add every E5 field to the normal-path status (l. 726–782):
    - `initialBasisSupplied/Kept/Dependent/Rejected` = 0;
    - index lists `zeros(1,0)`;
    - reason `cell(1,0)`;
    - `raysAdded = nBases`.
  - Add the same fields to the three early-return structs (l. 273–289, 299–310, 354–390).
  - Do not touch the random stream.
- [X] T005 Run `TST` and `baselineRecord('compare')`; both must pass (inert scaffolding).

**Checkpoint**: status contract present everywhere; outputs unchanged.

---

## Phase 3: User Story 1 — Complete a supplied set of conserved moiety vectors (P1) 🎯 MVP

**Goal**: `param.initialBasis` is validated and partitioned; kept rows are immutable
leading rows; only `nullity - kept` rays are searched.

**Independent Test**: fixtures 1–3 in left mode (quickstart §2).

### Tests for User Story 1

- [X] T006 [US1] In `TST`, add a block after the existing solver loop, with
  `rng(20261025,'twister')`. Set `vertexSolvers = intersect({'gurobi','ibm_cplex','glpk'}, solvers.LP, 'stable')`.
  - Fixtures 1 and 3 (no LP) run unconditionally, with `param.solver = ''` (session solver).
  - Fixture 2 and the rejection case run once per solver in `vertexSolvers`, via
    `param.solver = thatSolver`, and skip with a printed note if `vertexSolvers` is empty. It builds
  `struct('S', sparse(N), 'SConsistentRxnBool', true(size(N,2),1))` for each fixture and
  asserts:
  - F1 dimer `N=[-1 0 2;1 -2 0;0 1 -1]`, `initialBasis=[1 1 2]`: `isequal(full(Zpos),[1 1 2])`,
    outcome `'complete'`, `raysAdded 0`, `nLPSolves 0`, `initialBasisKeptIndex == 1`.
  - F2 antiport: `N` and `L0` from spec US1-2.
    - `isequal(full(Zpos(1:2,:)), L0)`; `raysAdded 1`; complete.
    - The added row, scaled by its smallest nonzero entry and rounded to `1e-9`, equals
      `[0 0 1 1 0 0]` or `[1 1 0 0 1 1]`.
    - Exact rational check: `rats` of the scaled row has denominators 1.
  - F3 exchange/transport: `N` (8x6) and four-row `initialBasis` from spec US1-3.
    `initialBasisKeptIndex == [1 2 3]`, `initialBasisDependentIndex == 4`, complete,
    `raysAdded 0`, `nLPSolves 0`, `isequal(full(Zpos), B(1:3,:))`.
  - Rejection: F2 with
    `initialBasis = [L0; [1 1 1 -1e-20 0 0]; [1 0 0 0 0 0]]`.
    - Row 3 is `'negative'`: its residual is ~1e-20, so only the exact sign rule rejects it.
    - Row 4 (not in the nullspace) is `'accuracy'`.
    - Neither appears in `Zpos`; rows 1–2 are kept.
  - All-zero supplied row: reported dependent.
  - Wrong length: `verifyCobraFunctionError('greedyExtremeRayBasis', 'inputs', {model, paramWithBadSize})`.
  - SC-007 for every fixture: `Zpos >= 0`, `max(abs(Zpos*N),[],2) <= acceptanceTarget`,
    `rank(full(Zpos)) == raysFound`.

### Implementation for User Story 1

- [X] T007 [US1] In `SRC`, immediately after the `'badlyScaled'` early return (l. 397;
  `acceptanceTarget` is set at l. 341), add the orientation and validation block (research R3 steps 1–3, R4):
  - read `param.initialBasis` via `isfield`/`isempty`;
  - in right mode transpose it to `k x nVar`;
  - require numeric, real, `size(B,2) == nVar`, else
    `error('greedyExtremeRayBasis:initialBasisSize', ...)` naming the expected size and mode;
  - per row in supplied order:
    - any entry `< 0` → reject `'negative'`;
    - else `max(abs(B(i,:)*model.S)) > acceptanceTarget` → reject `'accuracy'`;
    - else independence: keep iff `getRankLUSOL` on the support columns of
      `[Zk; B(i,:)]` equals `size(Zk,1)+1`, else dependent.
  - Store `Zk`, `keptIndex`, `dependentIndex`, `rejectedIndex`, `rejectedReason`.
- [X] T008 [US1] In `SRC`, seed the search from `Zk` (data-model E2; plan design steps 2–3):
  - `Zpos = sparse(max(nVar-rankS, nKept), nVar)`; `Zpos(1:nKept,:) = Zk`; `nBases = nKept`;
  - `nonZeroColumnsBool = full(any(Zk ~= 0, 1))` (or `false(1,nVar)` if `nKept == 0`);
  - `bestZpos = Zpos`; `bestNBases = nKept`;
  - in the restart block (l. 464–467), reset to the same kept-only state.
  - With `nKept == 0`, every one of these expressions must reduce to today's.
- [X] T009 [US1] In `SRC`:
  - Final verification (l. 648–654): if `any(failsTarget(1:nKept))`, raise
    `error('greedyExtremeRayBasis:keptRowFailedVerification', ...)` with the row indices and
    residuals, before dropping any row.
  - Outcome (l. 729–746): `complete` iff `nBases >= raysExpected`.
  - If `nKept > raysExpected`, raise
    `warning('greedyExtremeRayBasis:keptExceedsNullity', ...)` (FR-006a).
  - The `printLevel > 0` summary: add one line with supplied/kept/dependent/rejected/added.
  - The completeness print test (l. 615) becomes `nBases >= nVar-rankS`.
- [X] T010 [US1] In `SRC`, populate the E5 status fields from the stored partition:
  - counts; index lists in supplied order (columns in right mode);
  - reasons aligned with the indices;
  - `raysAdded = nBases - nKept` after final verification;
  - on the early returns, `initialBasisSupplied = k` (the number of supplied vectors,
    computed from the raw input's row or column count per mode, without validation).
- [X] T011 [US1] Run `TST`; fixtures 1–3 left mode pass. Run `baselineRecord('compare')`;
  it must still pass (no sign retry exists yet).

**Checkpoint**: MVP — a supplied partial basis is completed (Prop. (a)/(b)).

---

## Phase 4: User Story 2 — Recover when the targeted objective has the wrong sign (P1)

**Goal**: a dependent `+d` targeted vertex triggers one `-d` re-solve (FR-008/008a/009/010).

**Independent Test**: fixture 4 with the test hook (quickstart §2).

### Tests for User Story 2

- [X] T012 [US2] In `TST` (per solver in `vertexSolvers`, as T006), add fixture 4: `S=[1;-1;0]`,
  `initialBasis=[1 1 0]`, `param.testHook = struct('targetedSignFirst', -1, 'forceTargeted', true)`.
  Assert:
  - the added row ∝ `[0 0 1]`;
  - `nSignRetries == 1`, `nLPSolves == 2`, `nTargetedObjectives == 1`;
  - `raysRejectedForDependence == 1`; outcome complete;
  - `Zpos(1,:) == [1 1 0]`.

  Add the control `targetedSignFirst = +1`: `nSignRetries == 0`, `nLPSolves == 1`, same
  added ray.

### Implementation for User Story 2

- [X] T013 [US2] In `SRC`, extract the two-branch solve (l. 506–532) into a local function
  `solveCandidate(model, obj, param, positive, Zpos, nBases, acceptanceTarget, nTry, nonZeroColumnsBool)`
  returning `[x, sol, pairedRows]`. The ordinary branch calls `findExtremePool` and
  `untruncatedRay` exactly as now; the paired branch calls `compareSolversAtState`.
  - The loop appends `pairedRows` as before and increments `nLPSolves` per call.
  - Pure refactor: re-run `baselineRecord('compare')` and `TST`, both must pass.
- [X] T014 [US2] In `SRC`, change `targetedObjective(Z, Zpos, nBases, nVar)` to
  `[obj, direction] = targetedObjective(Z, Zpos, nBases, nVar, sign, canonical)`:
  - with `canonical` true, flip `direction` so that its largest-magnitude entry (lowest
    index on ties) is positive;
  - then apply `direction = sign*direction`;
  - then today's shift and normalisation.
  - With `sign = +1` and `canonical = false`, the returned `obj` must equal today's to
    the bit.
  - Parse `param.testHook` (`isfield` checks; defaults `targetedSignFirst = []`,
    `forceTargeted = false`).
  - Extend the targeted gate (l. 498) to
    `(nfail >= nfailMax || forceTargeted) && nBases > 0 && nBases < (nVar - rankS)`.
- [X] T015 [US2] In `SRC`, implement the retry (data-model E4):
  - Record `wasTargeted`, `signUsed` and `targetDirection` when the targeted objective is
    used.
  - In the independence branch (l. 587), when `wasTargeted` and the candidate is
    dependent:
    1. `nRejectedForDependence++`, `nSignRetries++`;
    2. rebuild `obj` with `-signUsed`;
    3. call `solveCandidate` (`nLPSolves++`), take `untruncatedRay`;
    4. apply the same WARNING / empty / accuracy / non-negativity / independence sequence
       as the first candidate (factor that sequence into a local function
       `judgeCandidate` if needed to avoid duplication);
    5. count one failure via `countFailure` only if the retried candidate also fails.
  - Print `g'*x` for both signs at `printLevel > 2`.
  - The retry consumes no `rand` draw.
- [X] T016 [US2] Run `TST` (fixture 4 both signs) and `baselineRecord('compare')`. If any
  baseline run diverges, it must report `nSignRetries > 0`; record that in `FD/baseline-summary.md`.

**Checkpoint**: Prop. (c) sign recovery live on every call.

---

## Phase 5: User Story 3 — Unchanged behaviour for existing callers (P1)

**Goal**: SC-004 evidence.

**Independent Test**: regression tests plus the baseline comparison.

- [X] T017 [US3] Run `TST` in full and `runtests` of
  `test/verifiedTests/analysis/testTopology/testCheckNullspaceBasis.m` and
  `test/verifiedTests/analysis/testTopology/testNullspaceAccuracyTarget.m`, unchanged.
  All must pass.
- [X] T018 [US3] Run `baselineRecord('compare')` on the final `SRC`. Append the result
  (identical / divergent-with-retry, per run) to `FD/baseline-summary.md`.

---

## Phase 6: User Story 4 — Right-nullspace mode (P2)

**Goal**: identical behaviour on the transposed problem with `n x k` input (FR-012).

**Independent Test**: fixtures 1–3 posed on `N'` with `leftRight = 'right'`.

- [X] T019 [US4] In `TST` (same gating as T006), repeat F1–F3 with
  `model.S = sparse(N')`, `leftRight = 'right'` and `initialBasis = B'` (`n x k`). Assert:
  - `Zpos` equals the left-mode `Zpos` transposed for F1/F3;
  - for F2, columns 1–2 equal `L0'`, with 1 added column of the expected form;
  - index fields equal the left-mode ones;
  - a `k x n` input in right mode errors with `initialBasisSize`.
- [X] T020 [US4] Run T019. If it fails, fix the orientation in `SRC`'s T007 block or the
  status index mapping, then re-run `TST`.

---

## Phase 7: User Story 5 — Real-model demonstration (P2)

**Goal**: SC-006 evidence on iDopaNeuroC (primary) and Recon3D (secondary), research R7.

- [X] T021 [P] [US5] Write `FD/fixture6RealModelCheck.m`.
  - iDopaNeuroC (loaded as in T001):
    - compute `Zpos0` (`rng(20261026)`);
    - choose 50 rows with `randperm` (`rng(20261027)`);
    - append the sum of the first two chosen rows;
    - call with `initialBasis`;
    - assert kept rows value-identical, `initialBasisDependentIndex == 51`, outcome complete;
    - print supplied/kept/dependent/rejected/added/nSignRetries/nLPSolves, nullity,
      elapsed time, solver.
  - Recon3D, if `~/drive/sbgCloud/projects/variationalKinetics/data/Recon3T/Recon3DModel_301_xomics_input_VK_withL.mat`
    exists (built from a path, never committed data):
    - `internalStoichiometriMatrixLeftNullspace = true`;
    - supply 125 random rows of `model.L` (`rng(20261028)`);
    - report the same counts, including any `'accuracy'` rejections, as data.
  - Skip with a printed message if a file is absent.
- [X] T022 [US5] Run `FD/fixture6RealModelCheck.m` and write
  `FD/fixture6RealModelCheck-expected.md`: the commands, the counts with their scope
  (model, supply route, solver, MATLAB version, elapsed) and the verdicts.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [ ] T023 In `SRC`'s help header:
  - add `OPTIONAL INPUT` entries for `.initialBasis` (shape per mode, validation, kept
    rows first and unchanged) and `.testHook` (marked test only, both fields);
  - add `status` lines for every E5 field;
  - add an `EXAMPLE` line completing a supplied basis;
  - add a `NOTE` paragraph "CHANGE OF DEFAULT NUMERICAL BEHAVIOUR, October 2026, feature
    20261025-235131-greedy-initial-basis" (sign retry on every call, no random draw, outputs
    identical when `nSignRetries = 0`; new `initialBasis` capability, Prop. prop:mr:left-basis).

  Follow the openCOBRA header format (VII-E).
- [ ] T024 Run `check_matlab_code` (MATLAB MCP) on `SRC` and `TST`, apply
  `matlab-core:matlab-review-code`, and fix any new Code Analyzer warning introduced by this
  feature. Confirm there is no `evalc`, no `nargin`, no suppressed warning and no new
  `try/catch`.
- [ ] T025 Final run: `TST`, `testCheckNullspaceBasis`, `testNullspaceAccuracyTarget`,
  `baselineRecord('compare')`. Then a diff-scope check: `git diff --stat develop` must list
  only `SRC`, `TST`, `CLAUDE.md` (SPECKIT pointer) and `FD/`. In particular,
  `findExtremePool.m` and the solver files must be unchanged (FR-014, FR-015). Record the
  outputs for the receipt, and list FR-006a/FR-007's defensive branches as "not verified
  by a fixture" (analyze U1).
- [ ] T026 Write the implementation receipt
  `FD/agent-runs/<UTC-timestamp>-greedy-initial-basis/implementation-receipt.md` (Prompt,
  Final response, Diff summary, Tests, Unresolved issues) and update `FD/human-loop.md`
  (ledger, receipt pointer, source-modified = yes).

---

## Dependencies & Execution Order

- Phase 1 (T001–T002) → Phase 2 (T003–T005) → US1 (T006–T011) → US2 (T012–T016) → US3
  (T017–T018) → US4 (T019–T020) → US5 (T021–T022) → Polish (T023–T026).
- US2 depends on US1: fixture 4 needs `initialBasis`. US4 depends on US1's T007 block. US3
  must follow US2, since it certifies the final code. US5 needs US1 and US2.
- T002 MUST precede every `SRC` edit, because the baseline is recorded on unmodified code.
- Almost everything edits the same two files, so parallelism is limited.

## Parallel Opportunities

- T021 (new script in `FD/`) can be written in parallel with T017–T020. It cannot RUN
  before US1+US2 land.
- T001 can be written while the MATLAB session is being prepared.
- The MATLAB MCP session is shared and single-threaded (project memory): do not run two
  MATLAB-executing tasks concurrently.

## Implementation Strategy

- **MVP** = Phases 1–3 (baseline, scaffolding, US1): completes a supplied basis.
- **Increment 2** = US2 (sign retry) + US3 certification. This is the point at which the
  default-behaviour change exists, so US3 runs after it.
- **Increment 3** = US4, US5, polish, receipt.
- Natural first independently testable slice for Gate 2: **Phases 1–3 (T001–T011)**.
