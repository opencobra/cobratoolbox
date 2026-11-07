# Research: Tier-2 test pilot

## R1 — Model

- **Decision**: `ecoli_core_model.mat` via `getDistributedModel` for all ten tests.
- **Rationale**: probe (2026-11-02, MATLAB R2025a) on this model: 95 reactions, 72 metabolites,
  137 genes, compartments `c` and `e`, `subSystems` as a cell of char, fields `S, mets, b, csense,
  rxns, lb, ub, c, osenseStr, genes, rules, metFormulas, metNames, grRules, rxnGeneMat, rxnNames,
  subSystems, description, modelID`. Every function ran without a solver:
  `extractSubSysModel` (2 subsystems → 7 reactions), `extractCompModel('c')` → 50 reactions,
  `keepCompartment({'c'})` → 59 reactions, `orderModelFields` → 19 fields,
  `updateFieldOrderForType('rxns', reversed)` → 95 reactions, `removeCompartments({'e'})` → 54
  metabolites, `createEmptyFields` (2 fields) → 21 fields, `convertOldCouplingFormat` → 19 fields,
  `findRxnFromCompartment('[e]')` → 45 rows, `findMetFromCompartment('[e]')` → 20 rows.
- **Alternatives considered**: Recon3D (rejected: no branch needs it; III-Coverage smallest
  model rule); toy models (rejected: the user asked for distributed models, Tier 4).

## R2 — Assertion pattern

- **Decision**: per test, (a) a shared helper-free block of size checks: `size(S) ==
  [numel(mets) numel(rxns)]`, every rxns-sized field has `numel(rxns)` rows, the same for mets and
  genes, `rxnGeneMat` is `numel(rxns) x numel(genes)`, every gene index used in `rules` exists;
  (b) content checks against the input model (`ismember` of identifiers, stoichiometry and bounds
  of kept reactions equal to the original columns); (c) first-run counts as Tier-5 reference
  constants with date and model in the header.
- **Rationale**: III-Coverage Tier 2 names exactly these checks; content checks prevent a result
  that is consistent but wrong.

## R3 — Inputs not present in the model

- **Decision**: derive them from the loaded model (e.g. build the old coupling format `A`/`b`
  rows for `convertOldCouplingFormat`; add an empty field for `createEmptyFields` checks).
