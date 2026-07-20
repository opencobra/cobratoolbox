# Implementation Receipt

**Feature**: 010-gecko-entropic-fba
**Run (UTC)**: 20260715T212225Z (Part 1 of implementation — characterization net; GECKO fold-in paused at checkpoint)
**Scope**: PARTIAL — the non-GECKO characterization net (US2, T001/T003/T004/T005) is complete and green.
The GECKO fold-in (US1: T002, T006–T011) and polish (T012–T015) are NOT done — paused at the pre-fold-in
checkpoint per the honesty commitment made at Gate 2 (the fold-in is the highest-risk work).

## Prompt

Human-loop run for feature 010. User invoked `/speckit-implement` after approving all tasks at Gate 2.
Implementation ordered: characterization net first (hard gate T005), then GECKO fold-in.

## Final response

010 characterization net implemented and green; GECKO fold-in paused at the checkpoint.

Delivered and verified (MATLAB MCP, R2026a):
- testCharacterizeEntropicFBA (new) pins the CURRENT non-GECKO `fluxes` behaviour of
  entropicFluxBalanceAnalysis on the consistent ecoli_core model under BOTH backends (mosek + pdco):
  `.stat == 1` exact, steady-state mass balance `||S*v - b|| < 1e-4`, and `||v||` within 1% of the
  captured per-backend reference (mosek 13.4347, pdco 13.4256); skips cleanly if a backend is absent.
  PASS (1/1). This pins entropic-FBA behaviour that had NO direct test before (independently valuable).
- NO src/solver code was modified for this increment — the net is test-only, so it cannot itself
  regress the default path. It IS the regression baseline the GECKO fold-in will be checked against.

Paused (checkpoint): the GECKO fold-in is genuinely the highest-risk work of the session — an additive
edit to the 1795-line core `entropicFluxBalanceAnalysis` in two backends, a NEW entropy-on-enzyme
formulation (the fork does linear-only), and cone-dual reindexing verified only by feasibility+KKT on a
fixture with no independent golden reference. Per the Gate-2 commitment to surface honestly at the
risky part, this is checkpointed for dedicated focus rather than rushed at the tail of a long session.

## Diff summary

- A `test/verifiedTests/analysis/testCharacterizeEntropicFBA/testCharacterizeEntropicFBA.m` (new).
- A `specs/010-gecko-entropic-fba/**` (spec + clarify + plan + research + data-model + quickstart +
  tasks + checklists + implementation-review + human-loop + this receipt).
- M `.specify/feature.json` (010 pointer).
- UNCHANGED: `entropicFluxBalanceAnalysis.m`, `solveCobraEP.m`, all solver source.

## Tests

- testCharacterizeEntropicFBA — PASS (mosek + pdco), 1/1 via MATLAB MCP.
- Reference capture: current entropicFluxBalanceAnalysis on ecoli_core, mosek stat=1 ||v||=13.4347,
  pdco stat=1 ||v||=13.4256 (both fast; the current mosek dual-optimality warning is preserved behaviour).

## Unresolved issues

- GECKO fold-in (T006–T011) + polish (T012–T015) not done — paused checkpoint. Resume from T002/T006.
- F1 (entropy-on-enzymes cone-dual reindexing) and F2 (no golden GECKO reference → assert KKT) remain
  the key risks for the fold-in.
- Not pushed.
