# Feature: optional skip of the bond-level stage in conserved-only mode

**Branch:** `20261002-conserved-only-skip-moiety-graphs`
**Created:** 2026-10-02
**Status:** Implemented and verified 2026-10-02 (SC-001, SC-002, SC-003 pass; see Evidence)
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
- **SC-003** (added during verification) On a real model where the default
  conserved-only run completes (`pufa` n=494), every output except `arm.MG` is identical
  with `computeMoietyGraphs = false` and `true`.

## Out of scope

Fixing hydrogen-pairing over-splitting of moieties (KI-001 consequence 2). Results
produced with `computeMoietyGraphs = false` are provisional until KI-001 is resolved.

## Implementation notes

Two `if computeMoietyGraphs ... end` blocks in `identifyConservedReactingMoieties.m`,
wrapped around existing code without reindenting it, so the diff stays reviewable.
Checked that no variable defined inside either block is read outside it before the
conserved-only return (only `BIG`, created before the first block, and `arm.MG`, set
in both branches).

## Evidence (2026-10-02)

Run on Jack's workstation, cobratoolbox branch `20261002-conserved-only-skip-moiety-graphs`
(commit `296425b94`), corpus `/media/JACK/repos/ctf/rxns/moiety_rxns/atomMapped_std`.
Exact commit, MATLAB version and timestamps are recorded in the provenance lines of the
run log below.

**SC-001: PASS.** `testConservedReactingMoieties.m` completed with no assertion error:
all existing golden cases plus the new KI-001 block (FR-003 output equivalence, FR-004
error on the invalid combination).

**SC-002: PASS.** `pufa` prefix n=495 (reaction 495 confirmed as `DKPGD2COAB3FAOXCOA`,
same model order as the bisection), conserved-only, `computeMoietyGraphs = false`:

| Run | Build (s) | Identify (s) | Conserved moieties | max abs(L*N) |
|---|---|---|---|---|
| n=495, first rerun | 168.4 | 33.4 | 332 | 0 |
| n=495, evidence run | 193.9 | 28.3 | 332 | 0 |

Before this change the same model never returned from `identifyConservedReactingMoieties`.

**SC-003: PASS.** `pufa` prefix n=494, conserved-only:

| Mode | Build (s) | Identify (s) | Conserved moieties | arm.MG | max abs(L*N) |
|---|---|---|---|---|---|
| `computeMoietyGraphs = true` (default) | 168.7 | 81.9 | 333 | 4700 graphs | 0 |
| `computeMoietyGraphs = false` | 171.9 | 27.9 | 333 | 0 (empty) | 0 |

`EQUIV PASS`: all 20 other `arm` fields identical (`A2C, A2I, A2R, A2Ti, ATG, C2A, I2A,
I2C, I2M, L, M2A, M2Ai, M2I, M2M, M2R, MRH, MTG, Ti2I, Ti2R, dATM`) and `moietyFormulae`
identical. Skipping the bond-level stage also made the identify step 2.9x faster.

The 332 vs 333 difference between n=495 and n=494 is expected: adding a reaction can
only remove or keep conservation relations.

**Artefacts** (reconXmoieties repository):
- Script: `experiments/2026-10-01-conserved-only-cliff/rerunPufaSkipMoietyGraphs.m`
- Log: `results/moietySizing/outputs/ki001/rerunPufa_n495_equiv_20261002_103910.log`
- Results (L, M2M, M2R, formulae, timings, provenance for all three runs):
  `results/moietySizing/outputs/ki001/rerunPufa_n495_equiv_20261002_103910.mat`

**Not addressed:** KI-001 consequence 2 (hydrogen-pairing over-splitting). The 332/333
moiety counts above are expected to include over-split moieties.
