# Quickstart: Validating the Empty-Selection Fixes

This guide runs the narrowest checks that prove the feature works, per
spec FR-007/SC-001–SC-005. It assumes a working `initCobraToolbox` MATLAB
environment with a MILP-capable solver configured (`prepareTest('needsMILP', true)`
skips gracefully otherwise).

## Prerequisites

- MATLAB R2024b+, repo initialized via `initCobraToolbox`.
- A MILP solver available to `changeCobraSolver` (Gurobi, or any solver
  `solveCobraMILP` supports).
- For the reconXmoieties-side check only: a checkout of
  `~/repos/reconXmoieties` (separate repository) with its own test
  environment set up per that repo's conventions.

## 1. cobratoolbox characterization tests (this repo)

Run the extended existing test file (no new file is created — III-Naming):

```matlab
cd(fullfile(getenv('HOME'), 'cobratoolbox'))
initCobraToolbox(false)
result = runtests('test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m');
assert(all([result.Passed]))
```

Expected: all assertions pass, including the new ones covering —

- **US1**: the MILP zero-selection branch (`RM_sets`/`RM_graph`
  initialization) — uses the real MACACI/rh:14817 pair (one of the four
  known-affected pairs), hand-built into a minimal combined model from its
  own staged RXN files (vendored at `data/rxnFiles/MACACI.rxn`,
  `data/rxnFiles/rh:14817.rxn`) — asserting
  `identifyConservedReactingMoieties` completes without error and
  `reacting.ReactMoietySets`/`reacting.ReactMoietyGraphs` are `{}`. This
  sub-check requires the gurobi MILP solver specifically (glpk's MEX
  wrapper errors on the fully-unconstrained/zero-row MILP this case
  produces — an unrelated, out-of-scope limitation; the check skips
  gracefully, with a warning, if gurobi is unavailable).
- **US2**: the both-empty-subtable branch (phantom-reaction technique,
  research.md R2) — asserting `reacting.reactMoietyTables{end}` has zero
  rows and a `BondChange` variable.
- **FR-009 edge case**: the one-empty-subtable branch (research.md R3) —
  asserting `[F; B]` concatenates without error and the result has a
  uniform `BondChange` column regardless of which side was empty.
- **Non-regression**: the pre-existing assertions on the r0317/ACONTm/r0426
  non-empty path continue to pass unchanged (US1 acceptance scenario 3 /
  US2 acceptance scenario 3).

## 2. reconXmoieties characterization test (separate repository)

```matlab
addpath(genpath('~/repos/reconXmoieties/moietySignature'))
run('~/repos/reconXmoieties/moietySignature/tests/scripts/stage5_pilot_empty_reacting_pattern_schema.m')
```

This script (added by this feature, following that repository's own
`stage5_pilot_*.m` convention) asserts, using the real RETI3/rh:55352 pair
(spec.md's own named US2 reproduction case, run through the actual Stage 4
pipeline, not a synthetic input):

- `constructCanonicalMoietySignature`'s empty-`T` branch produces a
  `sig.reactingPattern` with columns
  `{BondChange, CanonicalBondElmts, IntraInterMoiety}` at 0 rows (not a
  bare `table()`) — Contract 3.
- Feeding the two typed-but-empty `reactingPattern` tables into
  `compareMoietySignatures` (which internally calls
  `reactingPatternSetEqual`, `compareMoietySignatures.m` itself unmodified)
  reaches a real verdict (`combinedVerdict = "MATCH"`,
  `forward.reactMatch = true`) instead of throwing — Contract 4.

## 3. Live 9-pair reproduction (performed during implementation, reproducible)

Per spec Assumptions and SC-001/SC-002, all 9 known-affected VMH/Rhea pairs
are available via reconXmoieties'
`experiments/notebooks/data/exp_positive_control_broad/<PAIR>/rxnfiles/`
staged RXN files, and were live-verified end-to-end during this feature's
implementation (not merely recommended as a follow-up):

- **User Story 1 pairs** (previously `Unrecognized function or variable
  'RM_sets'`): MACACI/rh:14817, RPE/rh:13677, UDPG4E/rh:22168,
  UAG4E/rh:20517 — each selects 0 reactions, `{}` outputs, no error.
- **User Story 2 pairs** (previously `Unrecognized table variable name
  'BondChange'`): RETI3/rh:55352, RETI2/rh:55348, RETI1/rh:19141,
  MMEm/rh:20553, RE2624M/rh:40455 — each selects 2 reactions with both
  `reactMoietyTables` typed-but-empty, reaching `combinedVerdict = "MATCH"`.

All 9/9 pairs pass. A full 300-pair `exp_positive_control_broad` re-run
(SC-003) was **not** performed (out of scope — requires reconXmoieties'
full experiment harness) and remains a recommended, not required,
follow-up — expected error count after the fix is 1 (the unrelated,
out-of-scope "sparse inputs" issue on ACACT1rm), down from 10.

## 4. Non-regression check

No previously-passing pair should change verdict (SC-004) — this is a
property of the fix touching only previously-*erroring* code paths (the
`isempty`/undefined-variable branches), not the non-empty processing logic;
the existing assertions in `testConservedReactingMoieties.m` on the
non-empty r0317/ACONTm/r0426 case (bond counts, `L*N=0` invariant, moiety
counts) already cover this at the unit level.
