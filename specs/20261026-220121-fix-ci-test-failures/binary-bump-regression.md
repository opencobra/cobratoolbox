# Binary bump regression record (FR-012)

`binary` submodule: `43f41b0b7` (committed on develop) → `10697a987`. Runs use
`matlab -batch` (R2026a Update 3), each test through `test/runScriptFile.m` as `testAll`
does it, on 2026-10-26.

| Test | `43f41b0b7` (before) | `10697a987` (after) |
|---|---|---|
| testSolveCobraLP | passed (12.2 s) | passed (10.3 s) |
| testSolveCobraQP | passed | passed |
| testQuadLP | skipped: quadMinos and dqqMinos missing | skipped: quadMinos and dqqMinos missing |
| testDuals | passed | passed |
| testMapSolverStatus | passed | passed |
| testExtremePathways | failed: Could not read lrs output file. | passed |
| testExtremePools | failed: Could not read lrs output file. | passed |
| testLrsInterface | failed: Could not read lrs output file. | passed (with the new FR-002/FR-003 checks) |

The three "before" lrs failures reproduce the CI failures exactly.

**Reading.** The only change in outcome is that the three lrs tests now pass, as intended.
testQuadLP is skipped at both pointers because quad/DQQ MINOS is not usable on this
machine. The changed `quadPrecision`, `minos` and `DQQ` executables are therefore **not
exercised** by this record; CI, where they may be usable, is the first place they run.
