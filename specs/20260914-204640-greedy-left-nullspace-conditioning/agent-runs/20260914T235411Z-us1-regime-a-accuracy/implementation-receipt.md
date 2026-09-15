# Implementation Receipt

**Feature**: `specs/20260914-204640-greedy-left-nullspace-conditioning`
**Run**: US1 slice (Regime-A accuracy), tasks T001-T021
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

One further instruction arrived mid-run, from the user, in their own words:

> Generation of greedy left nullspace vectors is stochastic. If it times out an
> alternative is to randomly start again rather than persist in a dead end.

## Final response

*(see the Final response section at the end of this receipt)*

## Diff summary

| File | Change | Lines |
|---|---|---|
| `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m` | modified | +220 / -19 |
| `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m` | **created** | +231 |
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
4. **Defects demonstrated but NOT fixed** (their tasks are unapproved): the zero-padded
   incomplete basis (FR-010/US3) — observed under gurobi on iDopaNeuroC, which returns
   105 rows of which 4 are all-zero padding; the unconditional `SConsistentRxnBool` read
   (FR-013/US2), which the in-repo caller `optimalExtremePoolDriver.m:121` still hits.
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
