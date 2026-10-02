# Feature: optional skip of the bond-level stage in conserved-only mode

**Branch:** `20261002-conserved-only-skip-moiety-graphs`
**Created:** 2026-10-02
**Status:** Implemented; MATLAB test run pending (written without MATLAB access)
**Related:** KNOWN ISSUE KI-001 (`src/analysis/topology/reactingMoieties/KNOWN_ISSUES.md`)

## Motivation

Conserved moieties must be identified for the full VMH (~30k reactions) and Rhea
networks to start the MTG-based reconciliation. In conserved-only mode,
`identifyConservedReactingMoieties` still runs the bond-level stage (bond mapping
components, unlabelled bond-component isomorphism classification, bond isomorphism
classes, atom-bond graph), whose only conserved-only output is `arm.MG`. That stage can
fail to terminate on CoA-rich networks (KI-001). None of it feeds `L`, `M2M`, `M2R`,
`MTG`, `I2M` or `moietyFormulae`.

## Requirements

- **FR-001** New option `options.computeMoietyGraphs`, default `true`.
- **FR-002** With the default, behaviour and every output are unchanged in all modes.
- **FR-003** With `conservedMoietiesOnly = true` and `computeMoietyGraphs = false`, the
  bond-mapping-component section and the moiety-graph section are skipped; `arm.MG` is
  `{}`; every other output (all other `arm` fields, `moietyFormulae`, `reacting`) is
  identical to the default conserved-only call.
- **FR-004** `computeMoietyGraphs = false` with `conservedMoietiesOnly = false` raises
  `identifyConservedReactingMoieties:computeMoietyGraphsRequiresConservedOnly`.
- **FR-005** The option and its limitation are documented in the function header and
  in KI-001.

## Success criteria

- **SC-001** `testConservedReactingMoieties.m` passes, including all existing golden
  cases (FR-002) and the new KI-001 block (FR-003, FR-004).
- **SC-002** The `pufa` n=495 model that previously never returned completes in
  conserved-only mode with `computeMoietyGraphs = false`.

## Out of scope

Fixing hydrogen-pairing over-splitting of moieties (KI-001 consequence 2). Results
produced with `computeMoietyGraphs = false` are provisional until KI-001 is resolved.

## Implementation notes

Two `if computeMoietyGraphs ... end` blocks in `identifyConservedReactingMoieties.m`,
wrapped around existing code without reindenting it, so the diff stays reviewable.
Checked that no variable defined inside either block is read outside it before the
conserved-only return (only `BIG`, created before the first block, and `arm.MG`, set
in both branches).
