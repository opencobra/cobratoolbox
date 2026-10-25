# Phase 1 Data Model: Conserved-Moiety Cross-Function Equivalence Test

No new persistent data entities, source-level fields, or function signatures are
introduced. This feature adds test-local variables only, comparing outputs that
already exist and are already documented on their producing functions.

## `armConservedOnly` / `moietyFormulaeConservedOnly` (existing, read-only for this feature)

- **Origin**: `identifyConservedReactingMoieties(subModel, BG, dATM,
  optionsConservedOnly)` with `optionsConservedOnly.conservedMoietiesOnly = true`,
  already computed earlier in `testConservedReactingMoieties.m` by feature 026.
- **Fields used by this feature**: `armConservedOnly.L`, `armConservedOnly.M2M`,
  `armConservedOnly.M2R`, `moietyFormulaeConservedOnly`.
- **This feature's relationship to them**: read-only comparison target; not modified.

## `armSibling` / `moietyFormulaeSibling` (new, test-local)

- **Origin**: `identifyConservedMoieties(subModel, dATM, optionsSibling)` with
  `optionsSibling.sanityChecks = 0`, newly called by this feature on the same
  `subModel`/`dATM` already in scope in the test file.
- **Type**: same documented output shape as `identifyConservedMoieties.m`'s own
  header (`arm` struct with fields including `.L`, `.M2M`, `.M2R`; `moietyFormulae`
  cell array) — unchanged by this feature.
- **Naming**: distinct local variable names (`armSibling`,
  `moietyFormulaeSibling`) are used in the test to avoid colliding with the file's
  pre-existing `arm`/`moietyFormulae` variables (the full-mode
  `identifyConservedReactingMoieties` output already present in the file from before
  feature 026) and with `armConservedOnly`/`moietyFormulaeConservedOnly`.

## Comparison assertions (new, test-local; not a data entity)

Four `assert(isequal(...))` checks, each comparing one field of
`armConservedOnly`/`moietyFormulaeConservedOnly` against the corresponding field of
`armSibling`/`moietyFormulaeSibling`:

| Field compared | Left-hand side | Right-hand side |
|---|---|---|
| Conserved-moiety basis | `armConservedOnly.L` | `armSibling.L` |
| Metabolite-to-moiety map | `armConservedOnly.M2M` | `armSibling.M2M` |
| Moiety-transition-to-reaction map | `armConservedOnly.M2R` | `armSibling.M2R` |
| Moiety chemical formulae | `moietyFormulaeConservedOnly` | `moietyFormulaeSibling` |

## State transitions

None — both calls are single, stateless function invocations on the same read-only
fixture; there is no persisted state and no transition between the two outputs
within the test.
