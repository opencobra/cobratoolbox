# Data Model: Tier-1 test coverage batch 3

No persistent data. Inputs are small literals built inside each test (numbers, text, cell
arrays, small tables, tiny structs, small matrices). Test file shape: header (purpose,
`Function under test:`, tier, coverage exemptions, `Known defects documented` entries or
`None found.`, authors/date) -> `currentDir`/`fileDir`/`cd(fileDir)` -> `prepareTest()` ->
shared inputs -> one `%%` section per branch with commented assertion groups -> `cd(currentDir)`.
