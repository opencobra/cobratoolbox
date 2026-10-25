# Implementation Receipt

**Feature**: `specs/20260915-082551-extreme-ray-coverage`
**Run**: full task list, T001-T036
**Date (UTC)**: 2026-09-15
**Path**: `/speckit-implement` (core implementer, inline)
**Branch**: `20260915-082551-extreme-ray-coverage`, on top of
`20260914-204640-greedy-left-nullspace-conditioning` — **must be rebased when the parent merges**

## Prompt

`/speckit-implement`, after Gate 2 approved all 36 tasks with three decisions already
settled: (a) `findExtremePool.m` in scope via a default-preserving settings pass-through;
(b) the two-phase two-solver approach A1 dropped entirely; (c) the paired instrumentation
ships, off by default.

## Final response

*(see the Final response section at the end of this receipt)*

## Diff summary

| File | Change |
|---|---|
| `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m` | modified — paired harness, targeted objective, shortfall classification, empty-ray guard, three local functions added |
| `src/analysis/topology/extremeRays/optimalRays/findExtremePool.m` | modified — solver-settings pass-through, defaulting to today's behaviour |
| `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m` | extended (never duplicated — Principle III-Naming) |
| `specs/.../research.md` | R1-R7 results and the D1-D6 decision table |
| `specs/.../measurements/` | created — environment, campaign drivers, results |
| `specs/.../tasks.md` | task states, 3 added tasks, 4 superseded with reasons |

## Tests

`testGreedyExtremeRayBasis` passes standalone and **through `test/testAll.m`** using its
`COBRA_TESTS` filter, under gurobi: `testGreedyExtremeRayBasis passed!`. Static analysis:
0 issues in the test, 1 pre-existing info note in the source on a line not touched.

**SC-001 achieved**: iDopaNeuroC returns `outcome = 'complete'`, **105/105 rays**,
residual **6.828e-15** against a 1.193e-12 target, in **4.7 s** — against 101/105 timing
out at 180 s before. SC-002: augmented rank **1244** from SVD across 1e-9..1e-12 and from
`getRankLUSOL`, unanimous at the structural rank.

## Unresolved issues

1. **Four tasks superseded by measurement, not completed as written** (T016, T018, T019,
   T032), each marked `[~]` with its reason in `tasks.md`. T016 is the significant one:
   the tuned per-solver sets it called for were shown to be incapable of affecting the
   result, so adopting any would have been decoration.
2. **A2 and A3 were never run as tuned arms.** R3 established that no setting changes the
   returned ray, so a tuned arm would have been identical to its control by construction.
   Running them would have produced a comparison table that looked like evidence and was
   not. This is a deviation from the letter of FR-014, recorded rather than hidden.
3. **`tunedSolverSettingsApplied` / `tunedSolverName` are not implemented** (FR-023,
   SC-013): they report whether a tuned set was applied, and no tuned set exists. The
   caller-facing `param.solverSettings` pass-through is implemented and tested.
4. **The paired campaign covered k from 0 to 98, not the stall region at k near 105.**
   The targeted objective removed the stall before a paired run could reach it. The
   coverage conclusion rests on the separate 40-trial random-versus-targeted probe, which
   is direct evidence at a stalled basis, rather than on the paired campaign.
5. **One replicate per arm** for the headline figures. The effect sizes are large (0/40
   against 40/40; 180 s timeout against 4.7 s), but they are single runs.
6. **The parent feature is still unmerged**, so this branch needs a rebase.
7. **Full coverage is solver-dependent.** iDopaNeuroC reaches 105/105 under gurobi but
   99/105 under mosek: the targeted objective supplies the aim, but mosek's rays still
   sometimes miss the tighter accuracy target and are dropped. A mosek user gets an
   honest `'incomplete'` with a `'sampling'` shortfall, not a complete basis.
8. **The structural case burns its whole time budget.** G1 is classified correctly but
   takes the full 120 s, because the attainable dimension is computed only after the
   search gives up. Computing it on first stall would end the search immediately.

## Defect found AFTER the main implementation, by a full verification sweep

A sweep across every model and both solvers found `outcome = 'complete'` being reported
for mosek on iAF1260 with a residual of **3.047e-12 against a ~1e-12 target** — success
reported while the number said otherwise. Two causes, both mine: ray acceptance used a
vector inf-norm (max entry) while verification used a matrix inf-norm (max row sum), so
the two were not comparable; and the verification result was computed, reported, and then
never checked. Fixed by using one metric for both and dropping rows that fail
verification, as FR-003a already requires of candidates that fail acceptance. After the
fix all 16 model/solver combinations report a residual within target.

## Other information

**Two corrections were forced by measurement during this run**, both recorded in
`research.md`:

- The specification's stated mechanism — "the solver's pivoting and tie-breaking decide
  which optimal vertex a given objective returns" — is **false**. The LP has a unique
  optimum for a random objective, so the solver has no latitude at all.
- The shortfall test proposed in R6, looking for a strictly positive vector in `ker(N')`,
  is sound in only one direction and produced a false `'structural'` verdict on
  `ecoli_core`. It was replaced by computing the attainable dimension from the maximal
  support. The feature's own test caught this.
