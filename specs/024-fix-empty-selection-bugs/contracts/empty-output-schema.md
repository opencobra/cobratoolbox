# Contract: Empty-Result Schema Across the Reacting-Moieties Pipeline

This is not a network/API contract — `identifyConservedReactingMoieties.m`
and `buildReactingMoietyTables.m` are MATLAB library functions consumed
in-process by reconXmoieties (a downstream, separate-repository consumer).
The "contract" this feature establishes is the **output shape guarantee**
for the previously-undefined/crashing empty cases, since reconXmoieties code
(both today's and the amended `constructCanonicalMoietySignature.m`) is
written against it.

## Contract 1 — `identifyConservedReactingMoieties` zero-selection output

**Signature**: unchanged — `[arm, moietyFormulae, reacting] =
identifyConservedReactingMoieties(model, BG, dATM, options)` (FR-006).

**Guarantee**: for any input where the STEP-4 MILP set-cover selects zero
reactions (`selectedReactions` is `[]`), the function returns normally
(no error) with:

- `reacting.ReactMoietySets` == `{}` (0x0 cell array)
- `reacting.ReactMoietyGraphs` == `{}` (0x0 cell array)
- `reacting.selectedReactionNames` == `{}` (empty cell, unaffected by this
  fix — already correctly empty today via `model.rxns(selectedReactions)`
  with an empty index)

**Non-goal**: this contract does not change what counts as a "zero
selection" (the MILP formulation, STEP 4, is untouched) — only that the
result is representable without crashing.

## Contract 2 — `buildReactingMoietyTables` empty-subtable output

**Signature**: unchanged — `reacting = buildReactingMoietyTables(reacting,
formedBondsTable, brokenBondsTable)` (FR-006).

**Guarantee**: for every `k`, `reacting.reactMoietyTables{k}` is a table
whose **column set is identical** whether the reaction has 0, 1, or many
reacting bonds — specifically always including a `BondChange` column
(`string`, `"formed"`/`"broken"`) — never a bare, columnless `table()`
(FR-003, FR-004, FR-009). Consumers MUST be able to read
`reacting.reactMoietyTables{k}.BondChange` (and the other documented
columns — see data-model.md) unconditionally, without an `isempty`/column-
existence guard.

## Contract 3 — reconXmoieties `constructCanonicalMoietySignature` empty-pattern output (amended)

**File**: `~/repos/reconXmoieties/moietySignature/functions/constructCanonicalMoietySignature.m`
(outside this repository; amendment scoped per spec FR-005).

**Guarantee**: for every signature entry `sig`, `sig.reactingPattern` is a
table whose column set is always `{BondChange, CanonicalBondElmts,
IntraInterMoiety}` — never a bare, columnless `table()` — regardless of row
count. This is what makes Contract 4 possible without touching
`compareMoietySignatures.m`.

## Contract 4 — `reactingPatternSetEqual` on two empty patterns (read-only, unchanged)

**File**: `~/repos/reconXmoieties/moietySignature/functions/compareMoietySignatures.m`
(explicitly out of scope — untouched by this feature, both by the original
scope decision and its FR-005 amendment).

**Guarantee** (a consequence of Contracts 2 and 3, not a code change here):
given two typed-but-empty `reactingPattern` tables (same schema, 0 rows),
`reactingPatternSetEqual(reactA, reactB, flipB)` returns `true` — the
row-count guard passes (`0 == 0`), `reactA.BondChange`/`reactB.BondChange`
resolve to 0x1 string arrays, `sort(strcat(...))` on two empty string arrays
yields two equal 0x1 arrays, and `isequal` of those is `true`.
