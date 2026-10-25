# Data Model: Tier-1 test coverage pilot

No persistent data. Test inputs are hand-built literals created inside each test:

- **Model stub** (`getIDPositions`): struct with `rxns`, `mets`, optional `evars`, `ctrs`,
  a cellstr field `foo` and a numeric field `bar`. Two to three entries per field.
- **Rule strings** (`verifyRuleSyntax`): empty, valid, invalid, large-index.
- **Metabolite IDs** (`getMetAbbr`): `abbr[c]` strings, one repeated abbreviation.
- **Arrays** (`getDefaultValue`, `extendIndicesInDimenion`): small numeric, logical, cell,
  string, table literals.

Test file shape (every file): header (purpose, tier, function under test, coverage
exemptions, authors/date) -> `currentDir`/`cd` boilerplate as in sibling tests -> `%%`
sections, one per branch, each assertion group commented -> `cd(currentDir)`.
