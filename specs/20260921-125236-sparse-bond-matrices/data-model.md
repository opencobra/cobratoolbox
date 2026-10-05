# Data Model: sparse bond matrices

**Feature**: `20260921-125236-sparse-bond-matrices` | **Date**: 2026-09-21

`m = length(model.mets)`, `b = height(dBTM.Nodes)` (bond nodes, including one energy
pseudo-node per bond-mapped reaction), `s = height(dBTM.Edges)` (directed bond
transitions), `n = nMappedRxns` (the atom-mapped reaction count; see E3).

## E1: `M2BiE` — metabolite-to-bond incidence

| Property | Value |
|---|---|
| Size | `m x b` (unchanged) |
| Rows | `model.mets` order |
| Columns | `dBTM.Nodes` order (unchanged, must not be permuted) |
| Entry `(i,j)` | `1` if `dBTM.Nodes.mets{j}` equals `model.mets{i}`, else `0` |
| Non-zeros | at most one per column; energy pseudo-node columns empty; bond-less metabolite rows empty |
| Class (default) | sparse `double` **(changed: was full `double`)** |
| Class (`denseBondMatrices = 1`) | full `double` (historical) |

## E2: `M2BiW` — metabolite-to-bond weighted incidence

As E1, but entry `(i,j)` is `double(full(dBTM.Nodes.BondType(j)))` where E1 is 1.
Values reproduced exactly, including 0 (stored implicitly when sparse, `isequal` after
`full`) and `NaN` (stored explicitly). Same class rule as E1.

## E3: `BTi2R` — bond-transition-to-reaction map

| Property | Value |
|---|---|
| Size | `s x nMappedRxns` (unchanged; column count taken from the **atom**-mapped `N`, line 414, deliberately not "corrected") |
| Entry `(k,r)` | `1` where `r` is the index of `dBTM.Edges.rxns{k}` in `model.rxns(rxnBondMappedBool)` |
| Non-zeros | exactly one per row |
| Class (default) | sparse `double` **(changed: was `full(sparse(...))`)** |
| Class (`denseBondMatrices = 1`) | full `double` (historical) |

## E4: `options.denseBondMatrices`

| Property | Value |
|---|---|
| Type | scalar, interpreted by truthiness (as `sanityChecks`, `bondTransitionMultigraph`) |
| Default | `0` (set when the field is absent) |
| `0` | E1-E3 returned sparse |
| `1` | E1-E3 converted with `full` immediately after construction, before the bond residual check (research R3), so all downstream code runs on today's classes |
| Interaction | ignored when `options.bondTransitionMultigraph = 0` (E1-E3 not built) |

## E5: Golden snapshot (`specs/<feature>/golden-snapshot.mat`)

One struct per fixture, keyed by fixture name:

| Field | Content |
|---|---|
| `outputs` | 1x12 cell of the original function's outputs, in signature order; E1-E3 stored `sparse` |
| `originalClasses` | 1x12 cellstr of `class` and `issparse` of each original output (proves E1-E3 were full `double`) |
| `residuals` | atom and bond residual maxima of the original outputs |
| `warningsSeen` | which of the two inconsistency warnings appeared in the original call's diary text |
| `provenance` | corpus path, `.rxn` count, SHA-256 change indicator, model path, `develop` commit hash |
| `fillMedianSecondsBefore` | tyrosine only: median of 5 runs of the verbatim original fill loops (research R8) |

Lifecycle: written once in capture mode against the unmodified source; read-only
thereafter; the compare mode refuses to run if provenance changed.

## E6: Results log (`specs/<feature>/reproducibility-results.md`)

Append-only; one `## Run <timestamp>` section per compare-mode run, with per-fixture,
per-mode PASS/FAIL for SC-001, SC-003, SC-004 (storage figures), SC-005 (both medians),
plus provenance and the list of fixtures not covered and why.
