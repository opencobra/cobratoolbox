## Summary

The test back-fill campaign quarantines a function with a confirmed defect, and blocks every untested function that calls it. Seven widely used functions blocked between 239 and 430 functions each. This PR fixes them; each fix was reviewed and approved on its own. Every fix comes with a full test that fails on the old code and passes on the new one, and with an impact check: the callers' tests, plus old and new outputs compared on the shipped test models where results could change.

As a result, 215 functions are unblocked and can now be tested, and the known-defects registry goes from 830 to 821 entries.

## The fixes

| Function | Defect | Fix |
|---|---|---|
| `getCobraSolverParams` | The two-input form ignored the global settings made with `changeCobraSolverParams`. `'default'` returned the global settings, and the help described the structure output the wrong way round. | The global settings are read unless `'default'` is given. Help corrected. |
| `optimizeCbModel` (companion) | Revealed by the fix above: a global `minNorm` of 0 started a norm minimisation, and failed on models without an objective. | A global `minNorm` of 0 means no norm, as for the `minNorm` input. |
| `getModelFieldsForType` | Custom fields were missed in small models: it compared the whole type name, including the plural `s`. A field whose size matched in several dimensions got dimension -1 and crashed callers. | Prefix comparison without the plural `s`. An ambiguous field now gives a guiding error (`getModelFieldsForType:ambiguousField`) that points to the standard COBRA field names. |
| `setGurobiParam` | `printLevel`, `feasTol` and `optTol` were required although documented as optional. `timelimit` overrode `TimeLimit`. The `lpmethod` warning named `qpmethod`. | Every field is optional, `TimeLimit` wins, and the warning names the right field. |
| `findSExRxnInd` | Only `DM_atp_c_` of the three ATP demand names became internal. A missing `c` was created with one entry per metabolite. The prefix `Ex_` never matched (5 characters compared). A biomass message was printed at `printLevel` 0. | One boolean for `ATPM`, `DM_atp(c)` and `DM_atp_c_`. `c` has n entries. 3 characters are compared. The message is gated by `printLevel`. |
| `getFilesInDir` | An empty git listing returned the folder itself. Outside git, subfolders were skipped by default, against the documented `checkSubFolders = true`, and folders were listed as files. | Empty names are dropped, the default is `true`, and only files are listed. |
| `checkBalance` | With exactly one metabolite without a formula, `any()` of a 1 × n row gave a scalar. So reaction 1 became `NaN`, and the reactions using that metabolite kept a number. | `any(..., 1)`. The help now gives the code's default `printLevel` (1). |
| `setCplexParametersForProblem` | For MIQP, an algorithm named in `problemTypeParams.method` was always replaced by barrier. | The barrier default applies only when no algorithm was named. |

Each changed function has a dated NOTE in its help describing the change.

## Results that change

- **`checkBalance` / `checkMassChargeBalance` on Recon3D.** `protein[c]` has no formula. `10FTHF5GLUtl` goes from `NaN` to 0. `PROTEIN_BS` (before: −32.57 C, among others) and `DM_PROTEIN` (before: 0) become `NaN`. The list of imbalanced reactions is unchanged.
- **`findSExRxnInd`.** Of the 37 shipped test models, only `cardiac_mit_glcuptake_atpmax` changes: `DM_atp(c)` becomes internal, and atp, adp, h, h2o and pi become "internal only". It also affects models with reactions named `Ex_…` (none shipped), or with `ATPM`/`DM_atp(c)` in an HMR exchange subsystem.
- **`getCobraSolverParams`.** Values set with `changeCobraSolverParams` now reach the 63 callers that use the two-input form, mostly `feasTol`. Without global settings, nothing changes.
- **`getFilesInDir`.** Nothing changes inside a git checkout, apart from the stray folder entry. In a copy not under git (for example a zip download), `initCobraToolbox`'s cleanup now deletes only files that are genuinely new. Before, every subfolder file matching a COBRA `.gitignore` pattern looked new and was deleted.
- **`setCplexParametersForProblem`.** Only `solveCobraMIQP` with `ibm_cplex` and a named `method` changes. CPLEX was not available to run this.
- **`setGurobiParam` and `getModelFieldsForType`.** Toolbox callers get the same results. Calls that used to fail now work, or now get the guiding error.

## Tests

Full tests, written new or completed, each seen to fail on the old code:

| Test | Lines covered |
|---|---|
| `testGetCobraSolverParams` | 73/73 |
| `testGetModelFieldsForType` | 94/94 |
| `testSetGurobiParam` | 243/244 |
| `testFindSExRxnInd` | 116/118 |
| `testGetFilesInDir` | 72/72 (needs git) |
| `testCheckBalance` | 37/37 |
| `testSetCplexParametersForProblem` | 120/129 |

The lines not covered are unreachable or dead code, and are documented in each test header.

- **New section** in `testOptimizeCbModel` for a global `minNorm` of 0.
- **Callers' tests** after each fix: all pass. Some are skipped where a solver, toolbox or program is missing: CPLEX, MOSEK, Image Processing Toolbox or `cxcalc`.

## Known, not changed

- `setGurobiParam` doesn't translate COBRA's camel-case `timeLimit`, so a COBRA time limit has no effect with Gurobi.
- `findSExRxnInd` stops on models whose `subSystems` entries aren't text (`AntCore`, `ME_matrix_GlcAer_WT`). The old code did too.
- For MIQP in `setCplexParametersForProblem`, method names set `lpmethod` while numeric codes set `qpmethod`, and a mapping warning is issued on every MIQP solve.

## Records

`specs/20261120-161825-core-blocker-fixes/` holds:

- the spec, with one approved decision per function;
- `review.md`, the impact report for each fix;
- the implementation receipt.

The back-fill ledger and `test/known-defects.md` are updated to match.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
