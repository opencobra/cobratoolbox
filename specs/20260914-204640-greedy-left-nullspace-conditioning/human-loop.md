# Human Loop State

## Current State
- Status: Bundle 3 complete — **at Gate 3** (closeout). Approved slice T001-T021 implemented and verified.
- Active feature directory: `specs/20260914-204640-greedy-left-nullspace-conditioning`
- Last completed bundle: Bundle 3 (approved implementation)
- Source code modified by this workflow: **yes** — `greedyExtremeRayBasis.m` (+220/-19) and a new `testGreedyExtremeRayBasis.m`. `findExtremePool.m` deliberately NOT modified.

## Core Command Ledger
- constitution:   checked (v1.5.0 read in full; not invoked — no principle change requested)
- specify:        invoked — `spec.md` + `checklists/requirements.md` written
- clarify:        invoked — 3 questions asked and answered, integrated into spec.md (Session 2026-09-14)
- checklist:      invoked — `checklists/numerical-integrity.md`, 46 items, 36 pass / 10 open (6 FAIL, 4 AMBIGUOUS)
- plan:           invoked — plan.md, research.md, data-model.md, quickstart.md, contracts/
- tasks:          invoked — tasks.md, 47 tasks across 7 phases
- analyze:        invoked — 5 findings (1 HIGH, 2 MEDIUM, 2 LOW), 0 CRITICAL; 4 applied, 1 accepted; coverage 39/39
- implement:      invoked — `/speckit-implement`, tasks T001-T021 plus three recorded additions (T016a/b/c). Test passes headless: PASSED=1 FAILED=0.

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|
| 2026-09-14 | Bundle 0 setup — hooks | "No commits until Gate 1" | All optional git commit hooks deferred across Bundle 1; Spec Kit artifacts stay uncommitted in the working tree until Gate 1. |
| 2026-09-14 | Bundle 0 setup — feature dir | "Keep the seed's timestamp" | Feature directory and branch are `20260914-204640-greedy-left-nullspace-conditioning`, matching the seed. Aligns with `.specify/init-options.json` `branch_numbering: "timestamp"`. |
| 2026-09-14 | Clarify Q1 — default acceptance | "Tighten default, no opt-out" | Approved breaking change under Principle II. Obliges a documented migration path, written as FR-015b. |
| 2026-09-14 | Clarify Q2 — status delivery | "Third output `status`" | Signature becomes `[Zpos, Z, status]`; two-output callers unaffected. |
| 2026-09-14 | Clarify Q3 — Regime-B withholding | "Withhold both outputs" | Badly scaled input yields no basis of either kind; status explains. |
| 2026-09-14 | Gate 1 blocker CHK025 — right mode | "Same contract, both modes" | FR-020: every requirement applies in both nullspace modes. |
| 2026-09-14 | Gate 1 blocker CHK024 — failed ray | "Drop it, keep searching" | FR-003a: drop-and-continue, rejection count in status. |
| 2026-09-14 | Gate 1 blocker CHK032 — feasTol | "Retained but clamped" | FR-015a: accepted without error, may tighten, may never loosen. |
| 2026-09-14 | **Gate 1** — requirements decision | "Apply answers, continue to plan" | Bundle 2 ran: plan -> tasks -> analyze -> implementation review. No source modified. |
| 2026-09-14 | **Gate 2** — implementation approval | "Approve Phase 1-3 slice" | Scope T001-T021 approved. T022-T046 + T031a NOT approved; they return for a fresh decision. |
| 2026-09-14 | Gate 2 — findExtremePool scope | "Yes — via a defaulted parameter" | Option (b) only. T014 unblocked. Option (a) (direct edit for all callers) explicitly NOT approved. |
| 2026-09-14 | Gate 2 — implementation path | "/speckit-implement" | Core implementer, inline. Agent-assign pipeline not used. |
| 2026-09-14 | Gate 2 — commits | "Commit the planning artifacts now" | One commit of the planning artifacts before implementation, so the implementation diff reads cleanly on its own. |

## Deviations From Default Hook Behaviour (recorded, not silent)
- `before_specify` -> `speckit.git.feature` (mandatory) was **not fired**. Its effect —
  create and switch to the feature branch — was already satisfied: the branch
  `20260914-204640-greedy-left-nullspace-conditioning` was created by hand because
  `create-new-feature.sh` always generates a *fresh* timestamp prefix and therefore
  cannot reproduce the seed directory's `20260914-204640` name that the user chose.
  Firing the hook would have created a second, differently-named branch. The spec
  directory was supplied explicitly as `SPECIFY_FEATURE_DIRECTORY`, which is
  resolution-order item 1 in the `speckit-specify` skill — the sanctioned path, not a
  workaround.
- `after_specify` -> `speckit.git.commit` (optional): deferred per the user's Gate-1
  decision.
- `after_specify` -> `speckit.agent-context.update` (optional): deferred until after
  the plan phase, since it refreshes the agent context pointer to the active
  `plan.md`, which does not exist yet. `CLAUDE.md` currently points at the previous
  feature's plan (`specs/024-fix-empty-selection-bugs/plan.md`) and is stale.

## Approved Implementation Scope
- Approved: **yes (Gate 2, 2026-09-14)**; implemented 2026-09-14/15 via `/speckit-implement`.
- Scope: **slice — Phase 1 + Phase 2 + Phase 3 (User Story 1)**
- Tasks approved: **T001-T021**
- Tasks deferred: **T022-T046 and T031a** (User Stories 2, 3, 4 and cross-cutting) —
  these return for a fresh decision, they are not implied by this approval
- Files allowed:
  - `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m`
  - `src/analysis/topology/extremeRays/optimalRays/findExtremePool.m` — **additive only**:
    a new truncation-control parameter defaulting to today's behaviour (option (b)).
    Editing the existing truncation behaviour for all callers is NOT approved.
  - `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m` (create)
  - `specs/20260914-204640-greedy-left-nullspace-conditioning/**` (research results,
    measurements, receipt)
- Files not allowed: the `varkin` repository; `optimalExtremePoolDriver.m`;
  `testFindExtremePathway.m`; `getRankLUSOL`; `getNullSpace`; `papers/` (submodule);
  `external/`; `deprecated/`; everything else under `src/` and `test/`
- Implementation path chosen: **`/speckit-implement`** (core implementer, inline)

## Pointers
- Feature seed: `feature-request.md` (this directory)
- Specification: `spec.md`
- Spec quality checklist: `checklists/requirements.md`
- Implementation receipt: `20260914-204640-greedy-left-nullspace-conditioning/agent-runs/20260914T235411Z-us1-regime-a-accuracy/implementation-receipt.md`
- Measurement record: `measurements/results.md`; environment: `measurements/environment.md`
- Implementation review: `implementation-review.md` (the Gate 2 packet)
- Plan / tasks / analysis: `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `contracts/`, `tasks.md`

## Findings From Reading The Repository (Bundle 1)
- **`iDopaNeuroC.mat` is present** at `papers/2023_iDopaNeuro/models/iDopaNeuroC.mat`
  (2.1 MB), so the SC-005 regression is reachable locally. But `papers/` is a **git
  submodule** (`.gitmodules`, mode 160000) pointing at `opencobra/COBRA.papers`, and
  submodule initialization is gated during toolbox init, so it may be absent in CI.
  Resolution: SC-005 runs as a documented reproducibility check (Principle III's
  sanctioned substitute where automation is not yet practical), while the CI-resident
  test uses fixtures that ship with the test suite.
- **In-repo caller found**: `src/analysis/topology/extremeRays/optimalRays/optimalExtremePoolDriver.m:121`
  calls `[B,L] = greedyExtremeRayBasis(model)` with **no `param` argument at all**.
  With default parameters this takes the FR-013 path exactly — an unconditional read
  of `model.SConsistentRxnBool`, a field only computed when the consistency option is
  on. This is an in-repo caller of the changed interface and evidence that FR-013 is a
  live defect, not a hypothetical one.
- **No existing test file** for this function, so `testGreedyExtremeRayBasis.m` is a
  clean create under Principle III-Naming (one test file per function).

## Open Risks and Ambiguities
- **All six clarifications resolved** (three at clarify, three at Gate 1). No
  [NEEDS CLARIFICATION] marker remains in spec.md.
- **A hypothesis that contradicts the seed.** Reading `findExtremePool.m` produced R1:
  the operative cause may be the post-solve truncation `x(abs(x)<epsilon)=0` at
  `findExtremePool.m:66` (epsilon = 10*feasTol = 1e-5), not the 1e-6 acceptance test the
  seed names. Corroborated by the seed's own measurements (L entries "reach 1.252e-05",
  just above the truncation floor; the 8.8e5 ratio it dismissed as a symptom). Carried
  as a hypothesis with a decision rule fixed in advance, not as a finding. No spec
  requirement depends on either diagnosis being correct.
- **Open scope question routed to Gate 2**: if R1 confirms, the fix lives in
  `findExtremePool.m`, outside the file spec.md names, with two other callers. Every
  task touching it is tagged [GATE2-SCOPE].
- The accuracy target required by FR-002 may be unreachable if the underlying
  optimization floors the attainable residual. This is an accepted possible finding,
  not a risk to be designed around.
- Three defects found while reading the source that the seed did not name (zero-padded
  incomplete basis; unconditional read of an optionally-computed field; unusable
  documented usage form) are in scope as User Story 4 / FR-010 to FR-014, and must be
  taken or deferred explicitly rather than fixed silently.

## Bundle 3 outcome

- **The Gate-2 `findExtremePool.m` scope extension was approved but NOT used.** R1
  refuted the hypothesis that motivated it, so the diff is narrower than authorised
  (research.md D1).
- **Three additions beyond the approved task list**, each recorded in `tasks.md` rather
  than folded in silently: T016a (restart on a dead end, on the user's explicit mid-run
  instruction), T016b (timeout defect that made a reject-everything run spin
  indefinitely — not optional, the change would otherwise have shipped a hang), T016c
  (the `maxTime` guard, pulled forward from T035 because T016a requires it).
- **Headline finding**: accuracy is dominated by which LP solver is installed
  (gurobi 1.185e-16 vs mosek 9.342e-09 on the same model), not by the acceptance
  tolerance or the truncation. Both prior diagnoses were refuted by measurement.
- **Known state**: the interactive MATLAB session is wedged and needs a manual
  interrupt; all verification was completed headless via `matlab -batch`, the CI path.
