# Binary bump regression record (FR-012)

`binary` submodule: `43f41b0b7` (committed on develop) → `10697a987`. Runs use
`matlab -batch` (R2026a Update 3), each test through `test/runScriptFile.m` as `testAll`
does it, on 2026-10-26.

| Test | `43f41b0b7` (before) | `10697a987` (after) |
|---|---|---|
| testSolveCobraLP | passed (12.2 s) | |
| testSolveCobraQP | passed | |
| testQuadLP | skipped: quadMinos and dqqMinos missing | |
| testDuals | passed | |
| testMapSolverStatus | passed | |
| testExtremePathways | failed: Could not read lrs output file. | |
| testExtremePools | failed: Could not read lrs output file. | |
| testLrsInterface | failed: Could not read lrs output file. | |

The three "before" lrs failures reproduce the CI failures exactly.
