# Data Model: Fix Empty-Selection Crashes in Reacting-Moieties Pipeline

No new persisted entities, database schema, or COBRA model fields are
introduced. This document captures the shape of the existing in-memory
MATLAB structures whose *empty-case* representation this feature fixes, so
the characterization tests and the reconXmoieties amendment have a concrete,
grounded schema to assert against.

## Entity: `RM_sets` / `RM_graph` (local variables in `identifyConservedReactingMoieties.m`)

| Field | Type (non-empty case) | Type (fixed empty case) | Notes |
|-------|------------------------|--------------------------|-------|
| `RM_sets{k}` | numeric column vector — indices into `Condensed_RBG.Edges` for reacting bonds of selected reaction `k` | N/A — `RM_sets` itself is `{}` (0x0 cell) when `selectedReactions` is empty | Assigned at `identifyConservedReactingMoieties.m:1674-1676` |
| `RM_graph{k}` | `graph` object — induced subgraph over `RM_sets{k}`'s bonds | N/A — `RM_graph` itself is `{}` (0x0 cell) | Assigned at `identifyConservedReactingMoieties.m:1679-1683` |

Consumed as `reacting.ReactMoietySets` / `reacting.ReactMoietyGraphs`
(`identifyConservedReactingMoieties.m:1703-1704`) — field names and types
(`cell`) are unchanged by this fix (FR-006); only the pre-loop-empty case
becomes well-defined (`{}` instead of an undefined-variable error).

## Entity: `reacting.reactMoietyTables{k}` (`buildReactingMoietyTables.m` output)

Non-empty case column schema (post-processing, `buildReactingMoietyTables.m:43-89`):

| Column | Type | Origin |
|--------|------|--------|
| `BondChange` | `string`, values `"formed"`/`"broken"` | Added at lines 30/33 (fixed: unconditionally) |
| `BondEndNodes` | `double` (n×2) | Computed lines 53-78 |
| `BondElmts` | `string` | Computed lines 53-78 |
| `Bond` | `string` | Computed lines 53-78 |
| *(remaining `dBTM.Edges` columns not in either `dropCols` list)* | as in `dBTM.Edges` | Row-sliced from `identifyConservedReactingSubgraphs.m:58-59`'s `formedBondsTable`/`brokenBondsTable`, which are both row-slices of the same `dBTM.Edges` table (`buildAtomAndBondTransitionMultigraph.m:571`'s edge-table schema) |

**Fixed empty-case contract**: when a selected reaction's formed- and
broken-bond subtables (`F`, `B`) are *both* zero rows, `reactMoietyTables{k}`
is a table with **zero rows and this exact same column set** (not a bare,
columnless `table()`). When exactly *one* of `F`/`B` is zero rows (FR-009),
the concatenation `[F; B]` succeeds and produces the same uniform column set
regardless of which side was empty — both sides carry `BondChange` before
concatenation.

This satisfies spec FR-003/FR-004/FR-009 by construction: because `F` and
`B` always originate from the same `dBTM.Edges` schema, unconditionally
assigning `BondChange` to both (regardless of `height`) and running the
*existing* non-empty-case processing pipeline (which is itself agnostic to
row count — `for i=1:n` with `n=0` is a no-op) produces a schema-identical,
typed-but-empty table without any separate empty-case code path.

## Entity: `sig.reactingPattern` (reconXmoieties `constructCanonicalMoietySignature.m` output)

Non-empty case column schema (`constructCanonicalMoietySignature.m:297-298`):

| Column | Type | Origin |
|--------|------|--------|
| `BondChange` | `string` | Copied verbatim from `T.BondChange` |
| `CanonicalBondElmts` | `string` | Derived from `T.BondElmts` (sorted, joined) |
| `IntraInterMoiety` | `string`, values `"intra"`/`"inter"`/`"unknown"` | Derived via `classifyIntraInter` |

**Fixed empty-case contract** (FR-005 amendment): when `T =
reacting.reactMoietyTables{k}` is empty (0 rows — true for both today's
bare `table()` and the fix's typed-but-empty table), `sig.reactingPattern`
is a table with **zero rows and this exact same 3-column set**, produced by
letting `T`'s now-guaranteed `BondChange` column and the existing
`n = height(T)` loop (a no-op at `n = 0`) flow through the general
(non-empty) code path — no special-cased `sig.reactingPattern = table()`
branch remains.

## Entity: comparison input to `reactingPatternSetEqual` (`compareMoietySignatures.m`, read-only)

No change to this function. Its existing row-count guard
(`height(reactA) ~= height(reactB)`) already passes for two 0-row inputs;
its subsequent `reactA.BondChange`/`reactB.BondChange` access now succeeds
because `reactA`/`reactB` (each a `sig.reactingPattern`) are guaranteed, by
the two upstream fixes, to carry that column even at 0 rows.
