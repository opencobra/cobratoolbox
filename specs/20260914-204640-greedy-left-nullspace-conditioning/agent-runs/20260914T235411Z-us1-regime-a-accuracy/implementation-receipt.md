# Implementation Receipt

**Feature**: `specs/20260914-204640-greedy-left-nullspace-conditioning`
**Run**: US1 slice (Regime-A accuracy, T001-T021) and, after Gate 3 approved continuation twice, US2 (Regime-B diagnosis, T022-T031a) and US3 (truthful completeness, T032-T034)
**Date (UTC)**: 2026-09-14T23:54Z
**Path**: `/speckit-implement` (core implementer, inline) — the path approved at Gate 2
**Branch**: `20260914-204640-greedy-left-nullspace-conditioning`

## Prompt

`/speckit-implement`, invoked by the user after Gate 2 approved:

- scope **T001-T021** (Phase 1 Setup, Phase 2 Foundational measurement, Phase 3 User
  Story 1). T022-T046 and T031a explicitly **not** approved.
- the `findExtremePool.m` scope extension, **option (b) only** — a new parameter
  defaulting to today's behaviour.
- implementation path `/speckit-implement`.
- commit the planning artifacts first (done, `78d4eade5`).

At Gate 3 the user chose **"Continue with US2"** (T022-T031a), and at the following
Gate 3 **"US3 - stop the zero padding"** (T032-T034), each approving further scope
within the same run.

One further instruction arrived mid-run, from the user, in their own words:

> Generation of greedy left nullspace vectors is stochastic. If it times out an
> alternative is to randomly start again rather than persist in a dead end.

## Diff summary

| File | Change | Lines |
|---|---|---|
| `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m` | modified | US1 +220/-19, then US2 on top |
| `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m` | **created** | US1 +239, then US2 tests added |
| `specs/.../research.md` | Phase-0 results filled in | +276 / -60 |
| `specs/.../tasks.md` | task states + 3 added tasks | +46 / -18 |
| `specs/.../measurements/` | **created** — environment.md, results.md, 6 probe/driver scripts, 3 .mat result files | new |

**`src/analysis/topology/extremeRays/optimalRays/findExtremePool.m` is UNCHANGED.**
The Gate-2 scope extension was approved but deliberately not exercised: R1 refuted the
hypothesis that motivated it (research.md D1). No other file under `src/` or `test/`
was touched. The three modified submodule pointers (`external/...`,
`papers`, `tutorials`) were already dirty before this feature began and are not staged.

### What changed in the function

1. **Signature** `[Zpos, Z]` -> `[Zpos, Z, status]`. Additive: two-output callers are
   unaffected (asserted by test).
2. **Acceptance** now judged against a per-call accuracy target instead of an absolute
   `1e-6`. `param.feasTol` may tighten it, never loosen it (FR-015a).
3. **Verification on the returned object** (FR-003) — residual in both absolute and
   scaled form, plus a hard non-negativity assertion that errors rather than warns.
4. **Drop-and-continue** for a candidate failing the target, with the rejection count
   reported (FR-003a).
5. **Restart on a dead end** — added on the user's instruction, see Unresolved issues.
6. **Timeout defect fixed** — budgets moved to the top of the search loop.
7. **`maxTime`/`maxNewBasisTime` guard fixed** — required by (5).
8. **Help header** rewritten: corrected USAGE, documents the third output, and carries
   the Principle II migration statement for the approved breaking change.

### US2, added after Gate 3

9. **Five terminal outcomes** (`complete`, `incomplete`, `emptyNullspace`,
   `badlyScaled`, `missingField`), mutually exclusive, on every return path.
   `missingField` is documented but NOT yet produced — that is US4/FR-013.
10. **Regime classification** against the R4 boundary, applied to the OPERATIVE matrix
    (post consistency-restriction, post transposition), with the size recorded.
11. **Regime-B withholding**: both bases returned empty, a graceful return with a
    warning raised *as well as*, never instead of, the status.
12. **Regime-B diagnosis**: what is badly scaled, its value, the boundary, what the
    boundary is derived from, and the indicated repair.
13. **Correction to a US1 decision.** The exact spectrum-derived target is now the
    DEFAULT and `param.exactAccuracyTarget` was removed. It had been made opt-in during
    US1 because a full `svd` appeared to cost minutes; that timing was an artefact of a
    wedged MATLAB session. Re-measured headless: **0.15 s** (iDopaNeuroC operative
    matrix) and 0.35 s (iAF1260). This also removes US1's stated limitation that the
    conservative surrogate was too loose for a badly scaled matrix.
14. **`scalingValue` / `scalingBoundary` on every call**, not only in Regime B, so a
    caller sees its margin. `data-model.md` updated to match.

### US3, added after the second Gate 3

15. **The basis is trimmed to the rays actually accepted.** It is still preallocated to
    the expected height for speed, but the unfilled trailing rows are removed before
    return, so `size(Zpos, 1)` can no longer overstate what was found.
16. **An all-zero row now raises** `greedyExtremeRayBasis:zeroBasisRow` instead of being
    returned, so the property is asserted on the returned object rather than assumed.
17. **The US2-era header warning was reverted**: with the basis trimmed, `.raysFound`
    equals `size(Zpos, 1)` again, and the header says so.

## Tests

`test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m`, run headless
(`matlab -batch`, the CI path) because the interactive MATLAB session was wedged:

```text
PASSED=1 FAILED=0 INCOMPLETE=0
```

Covers: four exactly-known fixtures including `m != n` and an empty left nullspace;
fixture self-verification before use; non-negativity on every return; augmented-matrix
rank agreement across a 3-order tolerance span **at the structural rank**; the
augmented nullspace residual; the accuracy-rejection path forced against its failure;
time-budget bounding of a reject-everything run; and both call arities.

Measured acceptance (gurobi, seed 20260914, 1 replicate per fixture):

| Fixture | target | residual abs | rays | non-neg | runtime |
|---|---|---|---|---|---|
| F1 square 3x3 | 3.846e-16 | 5.551e-17 | 1/1 | yes | 0.03 s |
| F2 chain 3x2 (m != n) | 2.220e-16 | 5.551e-17 | 1/1 | yes | 0.03 s |
| F2b two pools | 3.140e-16 | 0 | 2/2 | yes | 0.20 s |
| F3 empty nullspace | 3.846e-16 | 0 | 0/0 | yes | 0.00 s |
| ecoli_core | 3.010e-14 | 0 | 5/5 | yes | 0.15 s |

Full campaign figures with replicate counts: `measurements/results.md`.

**US2 measured** (gurobi, `g` = the near-dependence parameter of the badly scaled fixture):

| g | sigma_min+ | boundary | outcome | Zpos | Z |
|---|---|---|---|---|---|
| 1 | 6.180e-01 | 8.829e-02 | `complete` | returned | returned |
| 1e-4 | 7.071e-05 | 1.010e-01 | `badlyScaled` | **empty** | **empty** |
| 1e-12 | 7.071e-13 | 1.010e-01 | `badlyScaled` | **empty** | **empty** |

**SC-005 regression, iDopaNeuroC**: regime `wellScaled` (margin 5372x), residual
**1.185e-16** against a 1.193e-12 target, outcome `incomplete`/`timeBudget` at 101 of
105 rays. An accurate basis, with its incompleteness reported rather than concealed.

**Not run**: `test/testAll.m` in full (not required by this slice, and the interactive
MATLAB session was unavailable); the `iDopaNeuroC` reproducibility check as a committed
artifact (T043, outside the approved slice).

## Unresolved issues

1. **Three additions beyond the approved task list**, each recorded in `tasks.md` as
   T016a/T016b/T016c rather than folded in silently:
   - **T016a, restart on a dead end** — implemented on the user's explicit mid-run
     instruction. Outside T001-T021. **Measured, and it does not help on the instance
     that motivated it**: gurobi on iDopaNeuroC reaches 101 of 105 rays both with and
     without restart, taking 9 restarts to arrive at the same place. The stall is
     structural, not a stochastic dead end. The mechanism is retained (it costs nothing
     when the search progresses, and is reported via `status.nRestarts`), but it did not
     deliver the improvement it was reasonably expected to. A candidate explanation —
     that the non-negative extreme rays span fewer than `nVar - rankS` dimensions, so
     105 was never reachable — is recorded in `measurements/results.md` as the next
     question to measure, not as a finding.
   - **T016b, timeout defect** — the `continue` on a rejected candidate skipped the
     budget checks, so a reject-everything run spun indefinitely. Latent before this
     feature (rejection was rare at `1e-6`), made reachable by tightening acceptance.
     Fixing it was not optional: the change would otherwise have shipped a hang.
   - **T016c, `maxTime` guard** — pulled forward from T035 (US4) because T016a needs a
     genuine total budget. Defaults preserve historical behaviour.
2. **The accuracy target's default is the conservative surrogate, not the derivation.**
   The exact target needs `sigma_min+` of the operative matrix; a full `svd` costs
   minutes at genome scale and `svds(...,'smallestnz')` is no faster (abandoned after
   7 minutes on iDopaNeuroC). Default is `eps*normest(Sop)`, 84x stricter on
   iDopaNeuroC; the exact form is available via `param.exactAccuracyTarget`. For a
   **badly scaled** matrix the default becomes too loose — that is the Regime-B
   condition, which US2 (not approved) handles. Stated in the function's comments.
3. **US1's slice boundary required a minimal `status`.** T022 (the full five-outcome
   status) is US2 and unapproved, but US1's own requirements (FR-003, FR-003a, FR-016)
   have nowhere to report without a third output. A US1-scoped `status` was implemented;
   the five terminal outcomes, the Regime-B diagnosis block and `raysExpectedIsEstimate`
   remain US2 work.
4. **Defects demonstrated but NOT fixed** (their tasks remain unapproved):
   - **FR-010 / US3 is now FIXED** (approved at the second Gate 3). Confirmed on
     iDopaNeuroC: 101 rows for 101 rays found against 105 expected, **0 all-zero rows**,
     reported `incomplete`. Before the fix the same run returned 105 rows of which 4
     were padding, which is exactly what the `varkin` guards test.
   - **FR-013 / US4 remains**: the unconditional `SConsistentRxnBool` read, which the
     in-repo caller `optimalExtremePoolDriver.m:121` still hits. `'missingField'` exists
     in the status vocabulary but is never produced. This is the last known defect from
     the original set, and the only user story left unimplemented.
5. **The interactive MATLAB session is wedged** and needs a manual interrupt. Caused by
   an earlier probe of mine that ran the tightened acceptance before the T016b timeout
   fix existed, and so span forever. All verification was completed headless instead.

## Other information

**The feature's central finding contradicts both prior diagnoses.** The seed named the
`1e-6` acceptance test as the operative cause; this feature's plan hypothesised the
`epsilon` truncation in `findExtremePool`. Measurement refuted both. On the same model,
same code path, same tolerances, the assembled residual is **1.185e-16 under gurobi and
9.342e-09 under mosek** — seven orders of magnitude apart. Accuracy is dominated by
which LP solver is installed, and the seed's 1.418e-07 is consistent with a mosek-class
solve. This is why FR-003 (verify on the returned object) is the load-bearing
requirement: it is the only one that catches a defect whose cause lives outside the
function entirely.

## Final response

**US1 implemented and verified — but the measurement phase refuted both standing
diagnoses, including my own.**

### What Phase 0 found

The seed named the absolute `1e-6` acceptance test as the operative cause. My plan
hypothesised the post-solve truncation at `findExtremePool.m:66`, and I told you its
fingerprint was "not a coincidence". **Both are wrong.** On the same model, same code
path, same tolerances:

| iDopaNeuroC (1244 x 1710) | gurobi | mosek |
|---|---|---|
| entries destroyed by the truncation | **0** | 1186/ray, all dust |
| assembled residual, absolute | **1.185e-16** | 9.342e-09 |
| ...scaled | 1.707e-19 | 1.302e-11 |

Seven orders of magnitude apart. **Accuracy is dominated by which LP solver is
installed.** The seed's 1.418e-07 is consistent with a mosek-class solve. The smallest
basis entries do sit at ~1.6e-05, matching the seed's 1.252e-05 — but gurobi truncates
nothing while producing entries of that size, so the proximity to `epsilon = 1e-5` is
coincidence of scale. This is why FR-003 — verify on the *returned object*, never infer
accuracy from the path that produced it — is the load-bearing requirement: it is the
only one that catches a defect whose cause lives outside this function entirely.

The accuracy target is derived, not chosen: `tauMin * sigma_1(M) * sigma_min+(Sop)` from
Weyl's inequality, validated against both known outcomes (the seed's basis fails, an
exact basis passes) and by controlled perturbation. The regime boundary is measured at
`sigma_min+ < 2.379e-06`; iDopaNeuroC sits 11,929x above it.

### Your restart suggestion: implemented, measured, and it does not help here

| | rays | restarts | time |
|---|---|---|---|
| no restart | 101/105 | 0 | 240 s |
| with restart | **101/105** | 9 | 240 s |

Nine restarts from fresh randomness reach exactly the same 101. The stall is
**structural, not a stochastic dead end**. One candidate explanation — that the
non-negative extreme rays span fewer than `nVar - rankS` dimensions, so 105 was never
reachable — is recorded as the next thing to measure, not as a finding. I kept the
mechanism: it costs nothing when the search progresses and is reported via
`status.nRestarts`.

### Two things I did beyond the approved scope

- **A hang I had to fix.** The `continue` on a rejected candidate skipped the timeout
  checks entirely. Latent before (rejection was rare at 1e-6), but tightening acceptance
  made it reachable — a reject-everything run spun forever. It wedged your interactive
  MATLAB session, which still needs a manual Ctrl+C; all verification ran headless via
  `matlab -batch`, the CI path.
- **The `maxTime` guard**, pulled forward from T035 because restart needs a real total
  budget. Defaults preserve historical behaviour.

Both are recorded in `tasks.md` as T016b/T016c rather than folded in silently.

### Scope

`findExtremePool.m` is **unchanged** — you approved the extension, R1 made it
unnecessary. Not done, because unapproved: Regime-B detection (US2), the zero-padded
incomplete basis (US3 — demonstrated: gurobi returns 4 all-zero rows), the
`SConsistentRxnBool` crash that `optimalExtremePoolDriver.m:121` still hits (US2).

The default accuracy target is a conservative surrogate, not the derivation: the exact
form needs `sigma_min+`, and both a full `svd` and `svds(...,'smallestnz')` cost minutes
at genome scale. `eps*normest(Sop)` is 84x stricter on iDopaNeuroC, so it is safe for a
well-scaled matrix — but too loose for a badly scaled one, which is precisely the
Regime-B case US2 handles. That limitation is in the function's comments, not hidden.

Test passes on two consecutive runs; test file has zero code issues.
