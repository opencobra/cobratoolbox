# Implementation Receipt — reacting-moieties test (004)

**UTC**: 2026-07-13T23:16:45Z · **Branch**: 004-reacting-moieties-test ·
**Gate 2**: "Approve all tasks" · **Invocation**: `/speckit-implement`

## Prompt

Repurpose the verified-working conserved-and-reacting-moieties tutorial into a
verifiedTests test covering seven currently-untested moiety functions and asserting
the L*N=0 conservation invariant, with figures generated but not displayed
(approved scope T001–T006).

## Final response

Added one additive test, `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`,
that reproduces the tutorial's 3-reaction Recon3D subnetwork workflow and exercises all
seven target functions (buildAtomAndBondTransitionMultigraph, identifyConservedReactingMoieties,
identifyConservedReactingSubgraphs, buildReactingMoietyTables, displayReactingMoieties,
createMoietyGraph, getMetMoietySubgraphs). Reference values were captured from a real run
and asserted genuinely: the conservation invariant norm(full(arm.L)*full(subModel.S)) < 1e-8
(L*N=0), subnetwork S is 4x3 with rank 2 / nullity 2, arm.L is 2x4, 2 moiety formulae, the
minimum set cover selects 2 reactions (both valid subModel reactions), broken/formed bond
tables have 7 rows each, and 2 moiety subgraphs — none reduced to a smoke check. The test
requires a MILP solver via prepareTest('needsMILP', true) (the set cover uses intlinprog or
solveCobraMILP) so it skips cleanly where none is available; it sets DefaultFigureVisible off
with an onCleanup restore so the tutorial's figures are generated but never displayed, and
closes them at the end. A minimal atom-mapped rxnFiles fixture is copied beside the test so it
is submodule-independent. Verified: passes in BOTH fast (13.3s) and full (7.3s) modes with
zero figure windows leaked; checkcode clean except the by-design global-CBTDIR warning. No
src function, scientific result, or public interface changed.

## Diff summary

- **NEW** `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` — the test.
- **NEW** `test/verifiedTests/analysis/testReactingMoieties/data/rxnFiles/{ACONTm,r0317,r0426,r1109}.rxn` — atom-mapped fixture (~24 KB).
- **EDIT** `.gitignore` — anchored the `analysis/` ignore rule to `/analysis/` (deviation, see below).
- **NEW** `test/tutorialDerived/` — the tutorial static-analysis staging + `_analysis/` reports
  (coverage-analysis.csv, categorisation.md) committed as this feature's research.
- `CLAUDE.md` — SPECKIT pointer → 004 (plan phase).

## Tests

- `testConservedReactingMoieties` via runScriptFile — **fast: passed (13.3s)**, **full: passed (7.3s)**;
  FIGCHECK: 0 open figures, DefaultFigureVisible restored.
- Reference capture (T001): sizeN=4x3, rank=2, nullity=2, LNnorm=0, sizeL=2x4, sel=[r0317,r0426],
  nBroken=nFormed=7, numMoietyMG=2.
- `checkcode` — only the by-design `global CBTDIR` warning (every COBRA test has it).

## Unresolved issues

- Whole-suite coverage delta (the 7 functions newly covered) is confirmed in CI.
- Deferred tutorial-repair follow-ups (out of scope): vonBertalanffy python2+ChemAxon(cxcalc)
  dependency in src/initVonBertalanffy.m, MetaboRePort write-path, visualiseConservedMoieties
  missing tutorial_initConservedMoietyPaths helper, atomicallyResolve expectedResults data,
  metabotoolsI >5min sampling.

## Other information

**Deviation** (recorded per human-loop): `.gitignore` was edited outside the pre-listed
allowed files because its unanchored `analysis/` rule silently ignored the new test under
`test/verifiedTests/analysis/`. Anchoring to `/analysis/` was necessary to commit the approved
test; it keeps the root `analysis/` research folder ignored and unblocks any future test under
`test/verifiedTests/analysis/`.
