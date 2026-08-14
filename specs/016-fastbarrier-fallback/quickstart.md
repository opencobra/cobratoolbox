# Quickstart: FastBarrier Fallback Validation

## Prerequisites

- MATLAB available on the system path.
- COBRA Toolbox repository initialized.
- Gurobi available to MATLAB and recognized by `initCobraToolbox(false)`.
- Current branch: `016-fastbarrier-fallback`.

## 1. Initialize the toolbox and run the full FVA regression

From the repository root:

```bash
matlab -batch "diary('/tmp/testFVA_fastbarrier_fallback.log'); try, initCobraToolbox(false); testFVA; catch ME, fprintf(2,'\\nCAUGHT ERROR:\\n%s\\n', getReport(ME,'extended','hyperlinks','off')); exit(1); end; diary off; exit(0);"
```

Expected outcome:

- MATLAB exits with status `0`.
- `testFVA` reaches and passes the fastBarrier section.
- The log contains `fastBarrier mode test passed.`
- No `A Solution could not be found!` error is thrown from the fastBarrier `PFK` or `PPS`
  subproblems.

## 2. Optional focused reproduction probe

Use this probe during implementation to confirm the fallback-triggering reactions complete
without running the entire test:

```bash
matlab -batch "initCobraToolbox(false); cd('test/verifiedTests/analysis/testFVA'); model=readCbModel('Ec_iJR904.mat'); changeCobraSolver('gurobi','LP',0); rxnNames={'PFK','PPS'}; for i=1:numel(rxnNames), [mn,mx]=fluxVariability(model,90,'max',rxnNames(i),'fastBarrier',1,'threads',1); fprintf('%s %.12g %.12g\\n',rxnNames{i},mn,mx); end; exit(0);"
```

Expected outcome:

- MATLAB exits with status `0`.
- Both `PFK` and `PPS` print finite min/max flux values.
- No temporary `.mat` or diary artifact is committed.

## 3. Solver-state preservation check

After implementation, verify that a fastBarrier call restores the pre-call LP solver:

```bash
matlab -batch "initCobraToolbox(false); cd('test/verifiedTests/analysis/testFVA'); model=readCbModel('Ec_iJR904.mat'); changeCobraSolver('glpk','LP',0); before=CobraSolverState.getSolver('LP'); try, fluxVariability(model,90,'max',{'PFK'},'fastBarrier',1,'threads',1); catch ME, after=CobraSolverState.getSolver('LP'); assert(strcmp(before,after)); rethrow(ME); end; after=CobraSolverState.getSolver('LP'); assert(strcmp(before,after)); fprintf('LP solver restored: %s\\n', after); exit(0);"
```

Expected outcome:

- MATLAB exits with status `0` when Gurobi is available.
- Output confirms the active LP solver after the call matches the solver before the call.

## 4. Final acceptance

The feature is ready for implementation receipt only when:

- The full `testFVA` command passes.
- Any focused probes used during debugging are reported as supporting evidence.
- No source-controlled generated logs, diaries, or temporary LP `.mat` files are left behind.
