# Implementation Plan: Left-Nullspace Basis Conditioning And Bad-Scaling Diagnosis For `greedyExtremeRayBasis`

**Branch**: `20260914-204640-greedy-left-nullspace-conditioning` | **Date**: 2026-09-14 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/20260914-204640-greedy-left-nullspace-conditioning/spec.md`

## Summary

`greedyExtremeRayBasis` returns a non-negative left-nullspace basis whose rows are
accurate to roughly seven digits. Spliced into an augmented matrix, those rows close
the rank gap, and every independent rank routine returns a different integer — so a
consumer of `ker(S_cyc)` receives a confident, well-formed, wrong answer.

The spec requires two regimes: on reasonably well scaled input, a basis accurate
enough that the augmented matrix's rank is the same integer from `getRankLUSOL`,
`getNullSpace` and SVD across several orders of magnitude of tolerance (Regime A); on
badly scaled input, a graceful return with a machine-readable diagnosis and no basis
(Regime B). The accuracy target and the A/B boundary must both be **derived and
measured**, never chosen.

**The planned approach is measurement-first.** Phase 0 exists to find out *why* the
residual is what it is before any remedy is selected, because reading the code has
already produced a hypothesis that contradicts the seed's diagnosis (R1 below). No
remedy is committed to in this plan. Phase 1 designs the status object and contract
that every regime shares; Phase 2 sequences the work so the measurement that selects
the remedy happens before the remedy is written.

## Technical Context

**Language/Version**: MATLAB, supported baseline R2024b or newer.

**Primary Dependencies**: the COBRA solver abstraction (`solveCobraLP`,
`getCobraSolverParams`, `changeCobraSolver`); the rank instruments `getRankLUSOL` and
`getNullSpace`; MATLAB's `svd`. No new dependency is introduced.

**Storage**: N/A — no persisted state. Fixtures are small matrices constructed in the
test; the genome-scale case loads an existing model file.

**Testing**: `matlab.unittest` via the repository harness — `test/testAll.m` and the
GitHub Actions `testAllCI_*` pipelines, with `prepareTest` requirement declaration so
the test skips gracefully where a solver is unavailable.

**Target Platform**: headless Linux in Docker (`matlab -batch`), with Xvfb and, where
available, Gurobi. Must not depend on GUI functions, absolute paths, or internet
access.

**Project Type**: MATLAB library function within an existing toolbox domain
(`src/analysis/topology/`). Single project; no new language surface.

**Performance Goals**: none promised. The spec forbids promising a runtime, and
Principle IV subordinates performance to numerical correctness. Runtime is *reported*
(FR-016) so that a remedy's cost is visible, not so that it is optimised. If a remedy
turns out to be materially slower, that is a finding to report at Gate 3, not a reason
to weaken the accuracy target.

**Constraints**: non-negativity of `Zpos` is inviolable (FR-004); the routine must
return gracefully rather than raise in every diagnosed case (FR-008, FR-013); console
output stays gated behind the existing verbosity control while the status is complete
independently of it (FR-017); the two-output call syntax keeps working (FR-015).

**Scale/Scope**: one source function is named by the spec (191 lines) plus, contingent
on the R1 measurement, its 66-line LP worker — see "Scope decision" below. One new test
file. Genome-scale inputs reach ~1300 rows by ~2900 columns, sparse.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: the feature touches the boundary between an LP solve and
  a linear-algebra property (membership of `ker(S')`). The object at risk is the rank
  of a matrix the *caller* forms, so the contract must be stated in terms of the
  basis's fitness for that use, not in terms of the caller's matrix. Row/column
  correspondence of `S` to `mets`/`rxns` is untouched; no model field changes meaning.
  `Zpos` and `Z` keep their documented mathematical meaning — the change is to the
  accuracy to which that meaning holds, plus a new third output.
- **Testing and reproducibility**: narrowest test is a new
  `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m` (no test
  exists today; III-Naming gives exactly one file per function, so this is a clean
  create). It declares `prepareTest('needsLP', true)`, fixes the random seed around the
  greedy search, and uses justified tolerances. The `iDopaNeuroC` regression (SC-005)
  runs as a documented reproducibility check under this feature directory, **not** in
  CI, because `papers/` is a git submodule — Principle III sanctions this substitute
  and requires the reason stated, which it is.
- **User experience and diagnostics**: a third output carries a status on every call.
  Console output stays behind `param.printLevel`. Regime B says what is badly scaled,
  by how much, and what repair is indicated. Nothing new prints by default beyond what
  the existing verbosity control already permits.
- **Performance and numerical integrity**: the whole feature is a numerical-integrity
  change. No diagnostic is made skippable for speed. Residuals are reported absolute
  and scaled (FR-016). Verification of the returned object (FR-003) is default-on and
  not gated behind a debug flag — it is the requirement, not an optional check.
- **External-solver configuration audit**: **required and deferred to R5**, which
  enumerates the `solveCobraLP` configuration surface reached through
  `findExtremePool` and cross-checks each default against this problem's structural
  profile. Two configuration facts are already identified as suspect and are part of
  that audit, not incidental: the hard-coded `lb = -100` / `ub = 100` bounds
  (`findExtremePool.m:57-61`), and the appended `sum(x) = 1` normalisation row
  (`:53-54`) which drives entry magnitudes down on large models until they meet the
  `epsilon` truncation floor.
- **Spec-driven scope control**: paths to edit are
  `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m` and the new
  test file; `findExtremePool.m` is **contingent** — see "Scope decision", which is
  routed to Gate 2 rather than assumed. Read-only and explicitly not edited: the
  `varkin` repository (a separate repository entirely), `external/`, `deprecated/`,
  `papers/` (a submodule), and the rank routines `getRankLUSOL` / `getNullSpace`.
  No new dependency, framework, or abstraction is introduced.
- **MATLAB coding standards**: no `evalc`. Warnings stay visible (VII-B) — the Regime-B
  diagnosis is a returned status *plus* a warning, never a suppressed one. Any
  `try/catch ME` added propagates `ME.message` with `ME.stack(1).file` and
  `ME.stack(1).line` (VII-C). Optional arguments use
  `~exist(...) || isempty(...)`, not `nargin` (VII-D) — which is also the existing
  style in both files. The help header is updated in the same change as the behaviour
  (VII-E) and must carry the FR-015b migration statement. VII-F: the
  `matlab-core:matlab-review-code` and `matlab-core:matlab-testing` skills are
  registered in this environment and are to be consulted during implementation.
- **Parameter-setting fidelity**: N/A — this feature renders no ported or literate
  output into another language.
- **Artifact placement**: source change stays in the existing
  `src/analysis/topology/extremeRays/optimalRays/` subfolder (an existing, correct
  domain folder — Principle IX prefers a new subfolder for *new* code; this is a change
  to existing code, so it stays put). Test goes to
  `test/verifiedTests/analysis/testTopology/`, beside `testFindExtremePathway.m`.
  Small fixtures are constructed inline in the test rather than committed as files.
  All measurement records, the reproducibility check and its expected output stay under
  `specs/20260914-204640-greedy-left-nullspace-conditioning/`. Nothing generated is
  written under `src/`.

**Gate result: PASS.** One item (the external-solver audit) is deferred to Phase 0 by
design rather than unresolved, and one scope item is deliberately routed to Gate 2.
No violation requires Complexity Tracking.

## Scope decision routed to Gate 2 — do not assume it

Reading `findExtremePool.m` produced a hypothesis (R1) that the operative cause of the
soft rows is **not** where the seed placed it. `findExtremePool.m:66` executes
`x(abs(x) < epsilon) = 0` with `epsilon = 10 * feasTol = 1e-5` by default, *after* the
LP has solved, and never re-checks the perturbed vector against the constraints. The
seed's own measurement corroborates this: it reports the entries of `L` "reach
1.252e-05" — the smallest surviving entries sit just above that truncation floor — and
the 8.8e5 entry-magnitude ratio it set aside as a symptom is exactly what O(10)
stoichiometry against a 1e-5 floor produces.

If R1 confirms this, the fix lies in a **different file from the one the spec names**,
with two other callers. The options and their blast radius:

| Option | What changes | Blast radius | Trade-off |
|---|---|---|---|
| **(a)** Extend scope to `findExtremePool.m` | The truncation itself is fixed at source | `optimalExtremePoolDriver.m:119` and `testFindExtremePathway.m:75` also change behaviour | Fixes the defect for every caller; widens an approved scope and changes a second public function's numerical output |
| **(b) — recommended** New parameter on `findExtremePool` controlling the truncation, which `greedyExtremeRayBasis` sets | Truncation becomes caller-selectable; existing callers keep today's behaviour by default | Additive only; other callers unaffected | Fixes the defect where the spec requires it, leaves the same latent defect for the other two callers — which must then be recorded as a known follow-up, not forgotten |
| **(c)** Refine or re-solve each ray inside `greedyExtremeRayBasis` after `findExtremePool` returns | `findExtremePool` untouched | None outside the named function | Strictly inside the spec's scope, but repairs damage after the fact rather than avoiding it, and may be unable to recover information the truncation destroyed |

**Recommendation: (b)**, because it discharges the spec's requirement without silently
changing a second public function's results for callers this feature never examined,
while keeping the fix at the point where the damage is done rather than downstream of
it. Under Principle II the new parameter defaults to the historical behaviour, so
`optimalExtremePoolDriver` and `testFindExtremePathway` are unaffected.

**This is a Gate 2 decision.** It is recorded here, not taken here. If R1 refutes the
hypothesis — if raw and truncated residuals are comparable and the LP floor dominates —
the question is moot and the answer is R2's floor plus, very likely, Regime B for more
models than expected.

## Project Structure

### Documentation (this feature)

```text
specs/20260914-204640-greedy-left-nullspace-conditioning/
├── feature-request.md        # the seed (provenance; pre-existing)
├── spec.md                   # requirements (Bundle 1)
├── plan.md                   # this file
├── research.md               # Phase 0: questions, procedures, measurements to be taken
├── data-model.md             # Phase 1: status object, terminal outcomes, fixture set
├── quickstart.md             # Phase 1: how a reviewer reproduces every measurement
├── contracts/
│   └── greedyExtremeRayBasis.contract.md   # revised function contract
├── checklists/
│   ├── requirements.md       # spec quality (16/16)
│   └── numerical-integrity.md# requirements quality (46/46)
├── human-loop.md             # orchestration index
├── implementation-review.md  # Gate 2 packet (end of Bundle 2)
├── tasks.md                  # Phase 2 (/speckit-tasks — not created by /speckit-plan)
└── agent-runs/               # implementation receipts (constitution ledger)
```

### Source Code (repository root)

```text
src/analysis/topology/extremeRays/optimalRays/
├── greedyExtremeRayBasis.m      # EDIT — the function the spec names
├── findExtremePool.m            # EDIT CONTINGENT ON R1 + Gate 2 (see Scope decision)
└── optimalExtremePoolDriver.m   # READ ONLY — in-repo caller; calls with no param (FR-013 path)

src/base/solvers/                # READ ONLY — solver abstraction; audited in R5, not changed
src/analysis/topology/           # READ ONLY — getNullSpace / getRankLUSOL are instruments

test/verifiedTests/analysis/testTopology/
├── testGreedyExtremeRayBasis.m  # CREATE — clean create; no test exists today
└── testFindExtremePathway.m     # READ ONLY — existing caller of findExtremePool

papers/2023_iDopaNeuro/models/   # READ ONLY — git submodule; SC-005 reproducibility check only
```

**Structure Decision**: single MATLAB project, existing layout. The change is to
existing code in an existing correctly-placed domain folder, so Principle IX's
"new code goes in a new subfolder" rule does not apply — it governs new modules, and
creating a new folder for an edit to an existing function would fragment the domain.
The test goes beside the existing topology tests.

## What `varkin` would need to assert once this routine is fixed

**`varkin` MUST NOT be edited by this feature.** This section exists so that work can
be specified separately, in that repository. Its three current guards are inadequate,
and fixing this routine does not fix them:

1. `createCyclicModel.m:223-225` checks `norm(L*S,'inf') <= param.feasTol`. The intent
   is right and the tolerance is wrong: `1e-6` is roughly nine orders of magnitude too
   loose to certify a rank-defining property. Once this feature lands, the assertion
   should be made against the **scaled** residual — `norm(L*S,inf) / (norm(L)*norm(S))`
   — at the accuracy target derived in R3, not at a feasibility tolerance. A
   feasibility tolerance answers "is this point feasible"; the question here is "is this
   direction numerically in the nullspace", and those are different questions with
   different right answers.
2. `createCyclicModel.m:227-229` checks spanning one-sidedly, as
   `size(L,1) < size(S,1) - rankS`. At the measured rank that reads `104 < 83` and at
   the correct rank `104 < 104` — both false — so it cannot detect rank
   **over**-estimation, which is the failure that actually occurred. It should assert
   **equality** of the nullity implied by `L` against an independently computed rank,
   and should treat a mismatch in either direction as a failure.
3. `driver_optimizeVKmodel_VK1to3m.m:691-693` raises `'model.L does not span left
   nullspace'` on a row-count comparison alone and never evaluates `L*N`. It should
   evaluate the residual it names.

Additionally, once this routine returns a third output, `varkin` should **consume the
status** rather than re-deriving the same facts from the returned matrices — in
particular it should refuse to build `S_cyc` at all when the status reports Regime B or
an incomplete basis. That is the single highest-value change on the `varkin` side and
it is not available until this feature ships.

## Phase 0 — Research (measurement, not assertion)

See [research.md](./research.md). Seven questions, each with a stated procedure and an
explicitly empty results slot. R1 is sequenced first because it can overturn the seed's
diagnosis and because the answer selects the remedy. **No remedy is chosen in this
plan.** R3 and R4 produce the two numbers the spec forbids anyone from inventing: the
accuracy target (FR-002) and the regime boundary (FR-006).

## Phase 1 — Design & Contracts

See [data-model.md](./data-model.md) for the status object's fields and the five
terminal outcomes, the regime classification, and the fixture set; and
[contracts/greedyExtremeRayBasis.contract.md](./contracts/greedyExtremeRayBasis.contract.md)
for the revised signature and what each output holds in each outcome.
[quickstart.md](./quickstart.md) is the reviewer's reproduction guide.

Design is deliberately remedy-independent: the status object, the contract and the test
matrix are identical whichever of R1's outcomes obtains, so Phase 1 can be completed
and reviewed before Phase 0's measurements select the remedy.

## Complexity Tracking

> No Constitution Check violation requires justification. The one item that could
> become a violation — editing `findExtremePool.m`, a file outside the spec's named
> scope — is not taken in this plan; it is routed to Gate 2 with its blast radius
> stated and a default-preserving option recommended. If Gate 2 approves option (a)
> instead, this table must be filled in before implementation begins.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| *(none pending Gate 2)* | — | — |
