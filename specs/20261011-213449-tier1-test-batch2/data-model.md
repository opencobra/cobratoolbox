# Data Model: Tier-1 test coverage batch 2

No persistent data. Inputs are small literals built inside each test: numbers, strings, cell
arrays, small tables, tiny structs, small matrices, `graph` objects, and for
`combineChildren` small `AndNode`/`OrNode`/`LiteralNode` objects. Metabolic-model-like
structs contain only the fields the function reads.

Test file shape (every file): header (purpose, function under test, Tier 1, coverage
exemptions, known defects pinned, authors/date) -> `currentDir`/`fileDir`/`cd(fileDir)` ->
`prepareTest()` -> shared inputs defined before the first `%%` section -> one `%%` section per
branch with commented assertion groups -> `cd(currentDir)`.
