# Quickstart / validation guide: generateFullRowRankFR

## Prerequisites

- MATLAB R2024b or newer, with the COBRA Toolbox initialised (`initCobraToolbox(false)`).
- No LP/QP solver is required.
- Optional: the `papers` submodule (for iDopaNeuroC) and the variationalKinetics data folder (for Recon3T).

## 1. Fixture tests (CI)

```matlab
cd(fileparts(which('testGenerateFullRowRankFR')));
testGenerateFullRowRankFR
```

Expected: all fixture cases pass (see the spec's Traceability table). The in-repo Recon3D case (SC-002b) also runs. The iDopaNeuroC and Recon3T cases print a skip notice if their files are absent.

## 2. In-repo Recon3D (SC-002b)

```matlab
model = getDistributedModel('Recon3DModel_301_xomics_input.mat');
[modelOut, report] = generateFullRowRankFR(model);
```

Expected:
- `report.mBefore = 5835`, `report.rankBefore = 5826`, `report.fullRowRank = true`, `report.mAfter = 5812`;
- `numel(report.lumpedGroups) = 6`;
- the 14 phospholipase-D reactions are in `report.removedRxns` with reason `deadEnd`.

## 3. Recon3T reproducibility check (SC-002)

```matlab
run(fullfile('specs', '20261015-173504-prepare-recon3d-fr', 'measurements', 'reproduceRecon3T.m'))
```

Expected:
- m 5824 → 5795, rank 5809 → 5795;
- 5 `zeroRow` removals: `idl_hs[e]`, `M02560[e]`, `M02561[e]`, `M02909[e]`, `protein[c]`;
- 6 lumped groups, including the five-member HC group;
- 1 null vector with support 15 and residual 0, remedy `deadEndRemoval`, removing the 14 reactions;
- `report.flaggedForReview` includes HEPDECETH/PENDECAETH and DIDECAETH/TETDECAETH.

The script writes a log beside itself.

## 4. iDopaNeuroC (SC-003)

```matlab
L = load(fullfile(fileparts(which('initCobraToolbox')), 'papers', '2023_iDopaNeuro', 'models', 'iDopaNeuroC.mat'));
[modelOut, report] = generateFullRowRankFR(L.iDopaNeuroC);
```

Expected:
- 1244/1243 before, 1243/1243 after;
- one lumped group, `{dcholcoa[x], ppcoa[x]}`, with representative `dcholcoa[x]` and rewritten reactions `r0698` and `RE1836X`.

## 5. Opt-in general removal (User Story 5)

```matlab
[modelOut, report] = generateFullRowRankFR(model, struct('irreducibleRemedy', 'removeMetabolites'));
```

Expected:
- `report.fullRowRank = true` for any input with at least one internal column;
- `report.generalRemovalUsed` is true only if some dependency was irreducible;
- every removal is listed with its reason (`generalRemoval`, `deadEnd`, `orphaned`, `zeroRow`, `emptyColumn`).

On Recon3T and the in-repo Recon3D, the report is identical to the default run (`generalRemovalUsed = false`).
