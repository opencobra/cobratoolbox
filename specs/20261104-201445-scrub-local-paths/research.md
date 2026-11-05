# Research: Remove local machine details from older feature records

All findings were checked against `upstream/develop` at `56dcc3064`.

## R1 Finding every form of the path

- **Decision**: Search for the home path with either separator, so that the form embedded in a
  scratch-folder name is caught as well as the ordinary form.
- **Rationale**: A search for the ordinary form alone found 13 files and missed 2 more.
- **Alternatives considered**: Listing only known files; rejected because it would repeat that miss.

## R2 Paths the scripts use at runtime

| Script | Use today | Replacement |
|---|---|---|
| `diffDup.m`, `diffRFE.m`, `runTest.m` | toolbox root | three `fileparts` calls from the script's folder |
| `profRun.m` | toolbox `src` | the same root plus `src` |
| `ownCode.m` | toolbox `src` | the same, four `fileparts` calls from `mfilename('fullpath')` |
| `diffDup.m`, `diffRFE.m` | scratch copy of the reference functions | `bench/ref`, which holds both `...Ref` functions |
| `stageRun.m` | private code | `COBRA_BENCH_EXTRA_CODE` |
| `ownCode.m` | private model file | `COBRA_BENCH_MODEL` |

- **Decision**: Keep each change to the line that held the path, plus a guard where an input can be
  missing.
- **Rationale**: Only `checkFeasibilityConditions`, in the `feasibility` stage, lives outside `src`.
  Every other function `stageRun.m` calls is in the toolbox, so the other stages run without the
  variable. `stageRun.m` stops early only for that stage. `runChain.sh` passes the variable through,
  because a systemd scope inherits the caller's environment.
- **Alternatives considered**: Extra function arguments; rejected because `runChain.sh` and
  `profRun.m` would need changing too, and the calling convention recorded in the README would move.

## R3 Hardware statements

- **Decision**: Remove the core count and memory size from the two research records and one receipt.
  Keep MATLAB and Gurobi versions, commit ids, the imposed memory caps, and the existing "same machine"
  statement.
- **Rationale**: The versions and caps define the benchmark conditions. Timing comparisons rest on the
  runs sharing a machine, not on its size. The maintainer asked that no system information be kept,
  so the hardware goes; software versions are kept because removing them would make the recorded
  numbers uninterpretable.
- **Alternatives considered**: Removing software versions too; left to the maintainer's call at review.

## R4 Receipts

- **Decision**: Replace absolute links with relative links to the same file, use `#L<n>` for the line
  reference so the link works on GitHub, replace other paths with a placeholder, and add one dated
  note to `Other information`, creating that section where it is missing.
- **Rationale**: The ledger allows minimal redaction of personal data when marked.
- **Alternatives considered**: Leaving receipts alone because they are historical; rejected, since the
  ledger's own exception covers exactly this case.

## R5 Remaining text

- **Decision**: `tasks.md` entries that named a scratch helper keep its file name and say it was not
  kept. The `deprecated` data file keeps a repository-relative input path, which is the provenance the
  comment records; nothing reads that line. The older quickstart uses a placeholder for the clone.
- **Rationale**: Each keeps the information a reader needs while dropping only the personal prefix.

## R6 Left alone on purpose

- The CI runner's name: the project's shared runner, documented in a live workflow file.
- The word ReconXKG, and the reproducibility scripts that use it: other contributors' records rely on
  it, and those scripts need their fixture locations.
- `/home/<other user>` paths and machine notes in other contributors' records.
- The model file name in the 2026-10-21 research record: repository-relative and needed to identify
  the benchmark input.
