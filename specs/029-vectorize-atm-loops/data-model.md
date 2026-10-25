# Phase 1 Data Model: Vectorize the stage02 reorientation loop and createBIGraph's edge-expansion loop

This feature introduces **no new entity and changes no existing one**. Every table below keeps
its current shape, column set, column types, and row order — that invariance is the feature's
acceptance bar (`isequal`), not merely a side effect. The entities are documented here to make
explicit which columns the rewrite writes, which it must leave untouched, and what the
reproducibility check stores.

## `ATM.Edges` (existing, unchanged in shape)

The undirected atom transition multigraph's edge table, inside
`identifyConservedReactingMoieties.m`. `nTransInstances` rows.

| Column | Type | Written by stage02? | Notes |
|---|---|---|---|
| `Trans` | cell of char | **Yes** | Forward rows: everything after the first `#` (may become `''`). Reverse rows: rebuilt as `[newHeadAtom '#' newTailAtom]` (research.md R2, R3) |
| `HeadAtomIndex` | numeric | **Yes**, reverse rows only | Set to `EndNodes(:,2)` |
| `TailAtomIndex` | numeric | **Yes**, reverse rows only | Set to `EndNodes(:,1)` |
| `HeadAtom` | cell of char | **Yes**, reverse rows only | Swapped with `TailAtom` |
| `TailAtom` | cell of char | **Yes**, reverse rows only | Swapped with `HeadAtom` |
| `EndNodes` | numeric N×2 | No | Read-only source for the index swap |
| `TransInstIndex` | numeric | No | Used by the surrounding `sanityChecks` blocks |
| `orientationATM2dATM` | numeric (−1/0/1) | No | Assigned at line 317, *before* the loop; the rewrite reads it and must not modify it (FR-002) |
| any other column | — | No | FR-002: untouched |

**Row partition** (research.md R1): `fwdBool = (orientationATM2dATM == 1)`; the reverse branch
applies to `~fwdBool`, which includes any `0`-orientation rows when `sanityChecks` is off.
These two sets are complementary and cover all rows — there is no third case.

## `BIG` — bond instance graph (existing, unchanged in shape)

The `digraph` returned by `createBIGraph(BG)`, built from `graphNoE` (the input `BG` with the
energy node, `Element == 'E'`, removed).

- **`BIG.Nodes`**: copied wholesale from `graphNoE.Nodes` via `addnode`. Not touched by this
  feature; the existing `if ~isequal(BIG.Nodes, dATM.Nodes)` guard after the call must keep
  passing (FR-006).
- **`BIG.Edges`**: one row per bond *instance*. Row count is `sum(graphNoE.Edges.Weight)`.

| Column | Type | Value after expansion |
|---|---|---|
| `EndNodes` | numeric N×2 | From the source edge; row order is edge-major, instance-minor (research.md R4) |
| `Weight` | numeric | Always `1` per expanded row, regardless of the source edge's weight |
| `EdgeIndex` | numeric | `(1:numEdges(BIG))'`, assigned after `addedge` |
| every other `BG.Edges` column | numeric or cell | Copied unchanged from the source edge, once per instance |

**Construction invariant** (research.md R5): properties are assigned positionally after
`addedge`, which sorts by (source, target). This is correct only because `graphNoE.Edges`
arrives sorted, making the expanded order sorted too. The rewrite preserves the construction
sequence; it does not rely on a new invariant and does not repair the latent one.

## Reproducibility-check records (new, outside `src/`)

Stored under `specs/029-vectorize-atm-loops/`, not in the toolbox source tree.

### Per-fixture golden snapshot

One file per fixture, `snapshots/<fixture>-golden-snapshot.mat` (research.md R7 governs which
are committed):

| Field | Purpose |
|---|---|
| `fixtureName` | One of the 8 fixture names |
| `nReactions`, `nMetabolites` | Observed at capture time, not hardcoded (research.md R8) |
| `atmEdges` | `ATM.Edges` immediately after stage02 — the User Story 1 baseline. Sourced from the temporary capture hook (`CBT029_CAPTURE_FILE`, research.md R10), since `ATM` is internal and never returned |
| `bigNodes`, `bigEdges` | `BIG.Nodes`/`BIG.Edges` — the User Story 2 baseline. Sourced by the harness calling `createBIGraph` directly on the build output `BG`, which is identical to the in-function input (R10) |
| `corpusProvenance` | Corpus path, top-level `.rxn` count, and sorted contents of `flagged_for_review/` at capture time (research.md R11) |
| `stage02Seconds`, `createBIGraphSeconds` | Pre-change timings from the temporary instrumentation (research.md R10) |
| `capturedAt`, `gitCommit` | Provenance |

### Results record (append-only)

`vectorization-reproducibility-results.md`, one entry per fixture per run: fixture name,
`isequal` outcome per compared table, before/after seconds and the derived speedup for both
hotspots, the corpus provenance observed for this run (and whether it matches the snapshot's —
a mismatch is reported as "corpus changed since capture", never as a code regression, per
research.md R11), and — for uncommitted large snapshots — the external snapshot path and hash.

## State transitions

The harness has exactly two modes per fixture, selected by whether that fixture's snapshot
exists: **capture** (pre-change, writes the snapshot) and **compare** (post-change, asserts
`isequal` and appends results). Per-fixture selection is what makes the run resumable (FR-011):
`pufa` may still be capturing while the small fixtures are already comparing.
