# Data Model: Canonicalize Bond-Node Keys

**Feature**: 019-canonicalize-bond-node-keys

This feature does not introduce a new persistent data model or COBRA model field (Constitution
Principle I/II are not implicated). It changes the **construction rule** for one identity string
and its dependent attributes inside an in-memory MATLAB `digraph` structure
(`dBTM`, returned by `buildAtomAndBondTransitionMultigraph.m`). The entities below are the
existing structures this feature reads and mutates, documented so the canonicalization's
required internal consistency (spec FR-005) is traceable to concrete fields.

## Entity: `bondMappings` (input to node-key construction)

Produced by `addBondMappingsRXNFile.m`; per-reaction table with one row per (bond,
substrate-or-product-side) instance. Relevant fields (unchanged by this feature — the fix reads
these, does not alter their production):

| Field | Type | Meaning |
|---|---|---|
| `mets` | cellstr | Metabolite ID for this bond-instance's atom pair |
| `headAtoms` | numeric | Atom number (within its metabolite) of the "head" atom, in raw MOL-file row order |
| `tailAtoms` | numeric | Atom number of the "tail" atom, in raw MOL-file row order |
| `headAtomElements` / `tailAtomElements` | cellstr | Element symbol of the head/tail atom |
| `bondTransitionNrs` | numeric | Groups substrate- and product-side rows into one bond transition |
| `isSubstrate` | logical | True for a reaction's substrate-side row, false for product-side |
| `bTypes` | numeric | Bond order (1/2/3 = single/double/triple) |

**Invariant preserved**: `headAtoms`/`tailAtoms` order remains exactly as parsed from the RXN
file — this feature does not alter `bondMappings` production (research R2). Canonicalization
happens only where these fields are consumed to build identity strings.

## Entity: Bond-Node Identity (Bond Key)

The string used as a `dBTM.Nodes` row identity (`dBTM.Nodes.Name`, auto-assigned by
`digraph(EdgeTable)` from `EdgeTable.EndNodes`). Currently constructed per bond-instance as
(`buildAtomAndBondTransitionMultigraph.m:593–598`):

```text
<met>#<headAtomNumber>#<headElement>#<met>#<tailAtomNumber>#<tailElement>
```

**Change**: The two (metabolite, atomNumber, element) triples MUST be ordered deterministically
before concatenation — by metabolite identity first (handles the energy-node case, where the
two ends carry different `mets` values, `AtomNumber` hardcoded to `1` at line 579), then by
atom number within one metabolite — so the same physical bond produces the same string
regardless of which RXN file supplied it and which atom that file happened to list first.

**Validation rules** (from spec FR-001/FR-002):
- Deterministic: same physical bond → same string, always.
- Collision-free: two distinct bonds of one metabolite (e.g. C1–C7 vs. C1–N10) must not collapse
  to the same string.
- `atomNumA == atomNumB` cannot occur for two distinct real atoms within one metabolite instance;
  for a bond to the reaction's energy node (`AtomNumber` hardcoded to `1`), the primary
  metabolite-identity sort resolves ordering before atom number is compared, since `metA ≠ metB`
  in that case.

## Entity: `EdgeTable` row (per bond-transition instance)

One row per `(bondTransitionNrs, reaction)` — i.e., one row per directed use of a bond in one
reaction. Fields whose *values* change for previously mis-keyed bonds (types/shapes unchanged —
spec FR-002/FR-006):

| Field | Current source (lines) | Change |
|---|---|---|
| `EndNodes` (`HeadBond`/`TailBond` at node-collapse time) | 607–608, from `bondSubstrateID`/`bondProductID` (593–604) | Sourced from canonicalized key |
| `HeadBondElmts`/`TailBondElmts` | 605–606, 625–626 | Reordered consistently with the same canonical ordering, so element-pair label (`'C-O'` vs `'O-C'`) matches the canonicalized head/tail assignment |
| `HeadBondHeadAtom`/`HeadBondTailAtom`/`TailBondHeadAtom`/`TailBondTailAtom` + `*Index` | 612–619 | Derived from the canonicalized (head, tail) assignment, not the raw substrate/product atom order |
| `HeadBond`/`TailBond` | 623–624 | Equal to the canonicalized `bondSubstrateID`/`bondProductID` |

**Fields explicitly NOT changed** (spec FR-004 — reaction-direction semantics are a separate
concept from within-bond atom order):

| Field | Meaning | Why unaffected |
|---|---|---|
| `HeadMet`/`TailMet` | Which molecule instance is the reaction's substrate vs. product side | Driven by `bondMappings.isSubstrate`, not by within-bond atom order |
| `HeadMetBondTypes`/`TailMetBondTypes` | Bond order (single/double/triple) of the substrate-/product-side bond | Read from `bondMappings.bTypes`, independent of head/tail atom ordering |
| `HeadBondIndex`/`TailBondIndex` | Resolved post-hoc from `dBTM.Nodes.BondIndex` (line 677–678) | Numeric, assigned after node collapse; unaffected in kind, only in the specific index value assigned |

## Entity: `dBTM.Nodes` row (one per distinct bond, post-collapse)

One row per canonicalized Bond-Node Identity. Fields (`addvars`'d at line 668):

| Field | Current source | Change |
|---|---|---|
| `Bond` | `mapAontoBOld` over `HeadBond`/`TailBond` (line 641) | Value changes to the canonicalized key string for previously mis-keyed bonds; unaffected for already-consistent bonds |
| `BondIndex` | `(1:size(dBTM.Nodes,1))'` (line 646) | Numeric row index — value shifts because the corrected row *count* is smaller for affected metabolites (fewer duplicate rows); type/shape unchanged |
| `BondElmts` | Recomputed per node from the node's own `BondHeadAtomIndex`/`BondTailAtomIndex` (lines 670–674) | Value reflects the canonicalized head/tail; already self-consistent per node both before and after (research R1) |
| `BondHeadAtom`/`BondTailAtom`/`BondHeadAtomIndex`/`BondTailAtomIndex` | `mapAontoBOld` over the edge-level fields (651–667) | Values sourced from the now-canonicalized edge fields, so they stay mutually consistent with `Bond` (spec FR-005) |
| `mets` (aliased `Met`) | `mapAontoBOld` (line 648) | Unaffected — metabolite identity is independent of within-bond atom order |
| `BondType` | `mapAontoBOld` (line 650) | Unaffected — bond order is independent of within-bond atom order |

**New field/behavior this feature adds**: none — no new column is added to `dBTM.Nodes` or
`dBTM.Edges`. The per-metabolite bond-count sanity check (spec FR-008) is a **post-construction
validation pass**, not a new persistent field: it counts `dBTM.Nodes` rows per metabolite
(`nnz(ismember(dBTM.Nodes.mets, model.mets(i)))`, matching the existing `M2BiE` row-sum pattern
at lines 728–731) and compares against a ground-truth bond count read once from that
metabolite's own canonical RXN-file molblock.

## Entity: Metabolite Bond-Count Ground Truth

Not a stored field — a value computed once per metabolite, independently of `dBTM` construction,
from that metabolite's own MOL block (the `atom bond` counts line at the top of a `$MOL` block,
e.g. `26 25` for `crn[c]` = 26 atoms, 25 bonds). Used only by the new sanity check (FR-008) as
the independent reference; not persisted or returned by the function.

## State / lifecycle

`dBTM` is rebuilt fresh on every call to `buildAtomAndBondTransitionMultigraph.m`; there is no
cross-call persistence or migration concern. No COBRA model field is read or written beyond the
existing `model.S`/`model.mets`/`model.rxns` inputs already consumed today.
