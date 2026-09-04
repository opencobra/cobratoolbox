# Phase 0 Research: Fix Empty-Selection Crashes in Reacting-Moieties Pipeline

All items below were resolved by direct source inspection (no `[NEEDS
CLARIFICATION]` markers remained after `/speckit-specify`); this document
records the concrete decisions the plan is built on, plus one scope-affecting
finding surfaced during this planning phase.

## R1: Reaching the zero-MILP-selection branch in a test

**Decision**: Extend the existing
`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
rather than create a new test file (III-Naming). The exact mechanism to drive
`solveCobraMILP`'s `selectedReactions` output to empty is left to the
implementation phase, to be confirmed empirically in a live MATLAB session
against one of two candidate approaches:

1. **Minimal harness** (FR-007's explicitly sanctioned alternative): construct
   a degenerate covering problem directly — `activeBonds` all-false (i.e. a
   `CRB2R` with zero rows having any nonzero entry) makes STEP 4's MILP
   `min sum(x) s.t. []*x <= []` trivially solve to `x = 0`, i.e.
   `selectedReactions = []`, by construction, without needing a real
   VMH/Rhea reaction pair. This can be reached either by feeding
   `identifyConservedReactingMoieties` a tiny hand-built `model`/`BG`/`dATM`
   triple with no reacting bonds (a pure isomerization with no bond-order or
   connectivity change), or by isolating just STEP 4 behind a thin call that
   exercises the same `MILPproblem` construction the production code uses.
2. **Real degenerate fixture**: the existing r0317/ACONTm/r0426 submodel
   already used by the test currently selects 2 reactions (non-zero); a
   different small Recon3D subset, or a trimmed version of the existing one,
   may already land on zero reacting bonds. This avoids constructing any new
   graph objects by hand but requires empirical trial against real data.

**Rationale**: FR-007 explicitly permits a minimal harness "around its MILP
set-cover step" specifically because forcing this branch via only real
biological data is not guaranteed to be reachable with fixtures already in
the repository, and constructing a new one is non-trivial. Whichever
approach is used, the test MUST call the actual `identifyConservedReactingMoieties`
production code path (not a duplicate/reimplemented STEP 4-6), so the
characterization test proves the real fix, not a parallel implementation.

**Alternatives considered**: Sourcing the real MACACI/RPE/UDPG4E/UAG4E RXN
files from reconXmoieties' `experiments/notebooks/exp_positive_control_broad.mlx`
staging area — rejected as the primary test mechanism because those fixtures
live in a separate repository (`~/repos/reconXmoieties`) and are not
guaranteed available in cobratoolbox's own CI checkout; they remain the
recommended follow-up **manual** reproduction per spec Assumptions (SC-001),
run once outside CI, not as the CI-gated characterization test itself.

## R2: Reaching the both-empty-subtable branch in a test

**Decision**: No new fixture is needed. The existing test already computes
`formedBondsTable`/`brokenBondsTable` (via `identifyConservedReactingSubgraphs`)
and `reacting.selectedReactionNames` from the r0317/ACONTm/r0426 submodel.
Appending one phantom reaction name (a string not present in either table's
`rxns` column, e.g. `'PHANTOM_NO_REACTING_BONDS'`) to
`reacting.selectedReactionNames` immediately before calling
`buildReactingMoietyTables` deterministically drives that reaction's `F` and
`B` slices to zero rows each — reaching the both-empty branch through the
real production function, using only data the test already has in memory.

**Rationale**: Reuses the existing fixture and existing `prepareTest`
requirement declaration; no new `.mat`/RXN fixture file to maintain; exercises
the actual `buildReactingMoietyTables` code, not a reimplementation.

**Alternatives considered**: Finding a *real* reaction in the existing
fixture whose formed/broken bond counts are naturally both zero — rejected
because the existing r0317/ACONTm/r0426 set's bond counts (7 broken, 7
formed across 3 reactions, all selected) are not independently known to
contain such a case, and searching for one would be less deterministic than
the phantom-reaction technique, which guarantees the branch by construction.

## R3: Reaching the one-empty-subtable branch (FR-009) in a test

**Decision**: Same phantom-reaction technique as R2, but construct the
phantom reaction's presence asymmetrically — one row manually appended to
only one of `formedBondsTable`/`brokenBondsTable` (matching that table's
existing column schema, since both are literal row-slices of `dBTM.Edges`
and therefore share a schema before either gets `BondChange` added), zero
rows in the other. This exercises the exact `[F; B]` concatenation path that
FR-009 identifies as a latent crash before the fix (mismatched `BondChange`
presence) and confirms it succeeds after.

**Rationale**: Same as R2 — reuses existing fixture and schema, deterministic,
tests real code.

## R4 (scope-affecting finding): `constructCanonicalMoietySignature.m`'s empty-`T` branch

**Finding**: While grounding Technical Context against source (not from the
spec, which named only `identifyConservedReactingMoieties.m` and
`buildReactingMoietyTables.m`), inspection of reconXmoieties'
`moietySignature/functions/constructCanonicalMoietySignature.m:278-283` found:

```matlab
T = reacting.reactMoietyTables{k};
if isempty(T)
    sig.reactingPattern = table();
    signatures(end+1) = sig;
    continue
end
```

`isempty(T)` is true for a 0-row table regardless of its column count (MATLAB
`isempty` is a `numel`/product-of-dimensions check). This branch therefore
fires identically whether `T` is today's bare `table()` or the fix's
typed-but-empty table, and in both cases replaces it with a bare,
columnless `table()`. `compareMoietySignatures.m`'s `reactingPatternSetEqual`
receives that bare table and still throws on `reactA.BondChange` — the same
crash, moved one hop upstream. **The originally-scoped cobratoolbox-only fix
cannot satisfy FR-005/SC-002 as written.**

**Decision**: Per explicit user choice (AskUserQuestion during this planning
session, 2026-09-04 — see `checklists/requirements.md`, "Amendment during
`/speckit-plan`"), scope is widened by exactly this one branch. The fix
removes the special case (mirroring the `buildReactingMoietyTables.m`
approach in R-nil above): once `T` is properly typed (guaranteed by the
cobratoolbox fix), the *existing* non-empty-case code path already handles
`n = height(T) = 0` correctly —

```matlab
n = height(T);
canonElmts = strings(n, 1);
intraInter = strings(n, 1);
for r = 1:n           % does not execute when n == 0
    ...
end
reactingPattern = table(T.BondChange, canonElmts, intraInter, ...
    'VariableNames', {'BondChange', 'CanonicalBondElmts', 'IntraInterMoiety'});
sig.reactingPattern = sortrows(reactingPattern);   % no-op on 0 rows
```

— producing a properly typed, 0-row, 3-column `reactingPattern` table
without any special-casing, exactly mirroring how the cobratoolbox-side fix
works. `compareMoietySignatures.m` is untouched, preserving the original
scope decision for that specific file.

**Note on the AskUserQuestion preview**: the option's preview text shown to
the user illustrated an `if istable(T) && ~isempty(VariableNames) ... else
table() ... end`-style guard to communicate the *category* of change (schema
preserved, not discarded) at decision time. The simpler "remove the special
case entirely" approach above achieves the same approved outcome
(non-bare, schema-preserving output) with less code and no hand-maintained
guard condition; it is the recommended concrete patch for the implementation
phase.

**Rationale**: The removed-special-case pattern requires zero new
conditionals, is symmetric with the `buildReactingMoietyTables.m` fix
(consistent "let 0-row inputs flow through the general path" style across
both fixes), and cannot diverge from the non-empty case's column set since
it *is* the non-empty case's code path.

**Alternatives considered**: A hand-listed
`table(zeros(0,1), strings(0,1), strings(0,1), 'VariableNames', {...})`
reconstruction (mirroring the `EndNodes`/`Weight` precedent's literal style,
cited in spec FR-004) — rejected as strictly more code with a real
maintenance risk (the three column names/types would need to be kept in
sync by hand with the `table(T.BondChange, canonElmts, intraInter, ...)`
line a few lines below, whereas removing the branch makes that drift
structurally impossible).
