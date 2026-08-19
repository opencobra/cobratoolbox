# Data Model: Canonicalize Bond-Node Keys for Symmetric/Resonance-Equivalent Atom Groups

**Feature**: 020-canonicalize-symmetric-atom-bonds

Like feature 019, this feature does not introduce a new persistent data model or COBRA model
field (Constitution Principle I/II are not implicated). It adds one new per-metabolite derived
structure (the equivalence-class canonical-rank map) consumed immediately before feature 019's
existing `canonicalBondKey.m` call, plus one new per-bond cache (first-seen bond type), both
computed and discarded within a single call to `buildAtomAndBondTransitionMultigraph.m`. The
entities below extend feature 019's data-model.md (`specs/019-canonicalize-bond-node-keys/data-model.md`)
rather than restating it; only what changes or is newly added is documented here.

## Entity: `atoms`/`bonds` tables (input, unchanged)

Produced by `readABRXNFile.m`, per feature 019's data-model.md — unchanged by this feature. This
feature's new equivalence-class computation reads `atoms.mets`/`.elements`/`.metNrs` and
`bonds.mets`/`.headAtoms`/`.tailAtoms`/`.bTypes` for one metabolite's first-seen molblock, but
does not alter their production.

## Entity: Symmetry-Equivalence Class (spec Key Entities)

A set of two or more raw atom numbers (`metNrs`, within one metabolite's own molblock row
numbering) that are interchangeable under the metabolite's own adjacency-graph automorphism
group — i.e., swapping them produces an isomorphic labeled graph (element and bond-type
preserving). Computed once per metabolite, from the first RXN file it is seen in (mirroring
`metBondCountGroundTruth`'s existing "read once, cache" pattern,
`buildAtomAndBondTransitionMultigraph.m:581-588`), via iterative color refinement (research R6):

| Step | Description |
|---|---|
| Build | Construct an undirected atom-adjacency graph for the metabolite from its own `atoms`/`bonds` tables — one node per `metNrs` value, one edge per bond row, node attribute = element, edge attribute = bond type. |
| Initialize | Each atom's invariant = its element symbol. |
| Refine | Repeatedly replace each atom's invariant with the sorted multiset of `(edge bond type, neighbor invariant)` pairs over its current neighbors, until the partition of atoms by invariant stops changing (standard color-refinement / 1-WL fixed point). |
| Classify | Atoms sharing a final invariant, and whose class survives an `isisomorphic`-based collision check (research R6), form one Symmetry-Equivalence Class. Atoms whose invariant is unique to them are singleton classes (i.e., not symmetric — the common case). |

**Validation rules** (from spec FR-001, FR-004):
- Two atoms in the same class MUST be truly interchangeable (collision-free — FR-004); the
  `isisomorphic` cross-check exists specifically to catch a color-refinement false-positive (two
  atoms with the same iterative invariant that are nonetheless not genuinely symmetric — a known,
  if rare, limitation of color refinement alone on graphs with certain regular substructures).
- A metabolite with no symmetric atoms yields only singleton classes, so the canonical-rank map
  (below) is the identity map and every downstream value is unchanged (spec FR-006).

## Entity: Canonical Atom Rank / `atomNumber -> canonicalAtomNumber` map (spec Key Entities)

A `containers.Map('KeyType','double','ValueType','double')`, one per metabolite, cached alongside
(and populated in the same loop pass as) `metBondCountGroundTruth`. For each Symmetry-Equivalence
Class, every member's raw atom number maps to the same canonical value — a deterministic
tie-break, the lowest raw atom number among the class's members (mirrors `canonicalBondKey.m`'s
own existing tie-break philosophy: a stable, arbitrary-but-consistent minimum). Singleton classes
map each atom number to itself.

| Field | Type | Meaning |
|---|---|---|
| key | `double` | raw `atomNumber` (`metNrs`), stable row position within the metabolite's molblock (research R6 — this is what makes a single per-metabolite map valid for every RXN file of that metabolite, not just the one it was built from) |
| value | `double` | canonical representative atom number for that atom's equivalence class |

**Consumption point**: `buildAtomAndBondTransitionMultigraph.m:604-609`, immediately before the
existing `canonicalBondKey(...)` calls. `bondMappings.headAtoms(...)`/`.tailAtoms(...)` for the
current bond are looked up in the current metabolite's map and replaced with their canonical
value before being passed to `canonicalBondKey`; the atom-index lookups that follow (lines
612-619, into `dATME.Nodes`) must resolve against the same canonical value so
`EdgeTable.HeadBondHeadAtom`/etc. stay self-consistent with the canonicalized identity string
(mirrors feature 019's FR-005 internal-consistency requirement, one level up).

**`canonicalBondKey.m` itself is unchanged** (research R6) — its existing `(met, atomNumber,
element)` ordering contract already produces a deterministic, order-independent key once its
`atomNumber` inputs are class-canonicalized upstream.

## Entity: Canonical Bond-Type Cache (new, for FR-003)

A `containers.Map('KeyType','char','ValueType','double')`, keyed by the canonicalized bond-node
identity string (the same key `dBTM.Nodes.Name`/`.Bond` will resolve to), recording each key's
`bTypes` value the first time that key is encountered in the per-reaction loop (`if
~isKey(...)`, the same idiom as `metBondCountGroundTruth`). Populated during the same pass that
builds `EdgeTable`. After `dBTM = digraph(EdgeTable)` (line 642) and node-level `BondType` is
computed (line 655), this cache overrides `dBTM.Nodes.BondType` for every row so the final value
is deterministically the first-RXN-file-encountered bond type (research R7), independent of
`mapAontoBOld`'s incidental Head-before-Tail resolution order.

| Field | Type | Meaning |
|---|---|---|
| key | `char` | canonicalized bond-node identity string (`canonicalBondKey`'s `key` output) |
| value | `double` | bond type (1/2/3) recorded the first time this bond-node was encountered across all processed reactions |

**Validation rule** (spec FR-003): for a bond whose two RXN-file representations disagree on
formal bond type, the cache's value MUST equal whichever RXN file's molblock was processed first
in `model.rxns` order (matching `metBondCountGroundTruth`'s own "first time it is seen"
semantics) and MUST NOT vary based on later files' values.

## Entity: `dBTM.Nodes`/`dBTM.Edges` rows (extends feature 019's data-model.md)

Same structures feature 019 documents, with two additional value-level effects (no new columns,
no shape change):

| Field | Change beyond feature 019 |
|---|---|
| `Bond` / `.Name` (node identity) | For a metabolite with a Symmetry-Equivalence Class, the identity string now collapses across class members via the canonical-rank remap (above), in addition to feature 019's within-bond ordering — so previously-inflated node counts (`coa[m]` 86→82, `crn[m]` 29→25) drop to the metabolite's true bond count. |
| `BondType` | Deterministically the first-RXN-file-encountered value (Canonical Bond-Type Cache, above) rather than `mapAontoBOld`'s incidental resolution, for any node where source files disagreed (FR-003). |
| All other fields (`BondIndex`, `BondElmts`, `BondHeadAtom`/`BondTailAtom`/`*Index`, `mets`) | Unaffected in kind — values are internally consistent with the (now class-canonicalized) `Bond`/`Name`, exactly as feature 019 established for its own canonicalization. |

**For a metabolite with no Symmetry-Equivalence Class** (the common case, and every metabolite
feature 019's existing regression fixtures cover): the canonical-rank map is the identity map, so
every field above is byte-for-byte identical to feature 019's already-fixed behavior (spec FR-006).

## Entity: Detection-Inconclusive Fallback State (new, for FR-011)

Not a persisted structure — a per-metabolite branch taken when the color-refinement/`isisomorphic`
computation cannot produce a validated partition for a metabolite (e.g. non-termination guard
exceeded, or a molblock structurally malformed enough that the adjacency graph cannot be built).
On this path: a `warning(...)` names the metabolite (Constitution VII-B), the metabolite's
canonical-rank map defaults to the identity map (i.e., feature 019's plain atom-number behavior,
unchanged), and the per-reaction loop continues to the next metabolite/reaction without halting.
This guarantees FR-011's "continue processing every other metabolite" requirement structurally:
the fallback is a *local* substitution for one metabolite's canonical-rank map, not a control-flow
change to the surrounding loop.

## State / lifecycle

Both new caches (`atomNumber -> canonicalAtomNumber` map, and the bond-type first-seen map) are
built fresh on every call to `buildAtomAndBondTransitionMultigraph.m`, scoped to that call, and
discarded on return — identical lifecycle to the existing `metBondCountGroundTruth` map they sit
beside. No COBRA model field is read or written beyond the existing `model.S`/`model.mets`/`model.rxns`
inputs already consumed today.
