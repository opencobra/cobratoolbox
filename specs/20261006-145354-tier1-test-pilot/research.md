# Research: Tier-1 test coverage pilot

Method: read each function and ran a probe in MATLAB R2025a (current behaviour, no `src`
change). Results below are the independent basis for expected values.

## Observed behaviour

| Function | Observation |
|---|---|
| getDefaultValue | `int8` 2x2 -> `int8` NaN-cast block (class kept); `"a"` -> `""` (1x1; string arrays collapse to scalar); `'abc'` -> `''` (0x0); `[true false]` -> `[false false]`; nested cell recurses, stays a cell; `zeros(0,3)` -> size 0x3; struct and function handle -> error `MATLAB:unassignedOutputs` (no matching branch: existing defect, pin, do not fix). |
| getIDPositions | `rxns` searches `[rxns; evars]` when `evars` exists (`{'R2','E1','zz'}` -> `[2 3 0]`, `[1 1 0]`); `mets` searches `[mets; ctrs]` likewise; any cellstr field works; a non-cellstr or missing field -> error with empty identifier and message "Basefield has to be a  field representing a cell array of strings in the model" (note the double space). |
| verifyRuleSyntax | Empty -> true; valid `(x(1) \| x(2)) & x(3)` -> true; `x(1) &&& x(2)` -> false; `x(20000) \| x(1)` -> true through the retry that regrows `x` (initial capacity 10000); `1 & (` -> false. Needs `clear verifyRuleSyntax` between cases (persistent `x`). |
| getMetAbbr | char `'atp[c]'` -> char `atp` for both outputs; cell -> column cell of abbreviations, `unique` sorted for the second output. An ID without brackets silently returns empty output (no error). |
| extendIndicesInDimenion | dimension 1 and 2 numeric and cell extension, table extension via vertical concat, `sizeIncrease = 0` returns the input unchanged; class mismatch (`{1}` into numeric) prints `input class is:`/`ans`/`value class is:`/`ans` then errors with identifier empty and message "extendIndicesInDimenion: Input class must be the same as value class". |

## Decisions

- **Test placement**: see plan Structure Decision. Rationale: follows existing folder
  convention for the same `src` domain. Alternative (a new `testTier1` folder) rejected:
  it would separate tests from siblings.
- **Console noise** in `extendIndicesInDimenion`: accept and document; do NOT suppress,
  since VII-A forbids `evalc` suppression and the function's prints are existing behaviour.
- **Error-path checks**: use `verifyCobraFunctionError` for both the missing-field/non-cellstr
  errors and the class mismatch. For `getDefaultValue` unsupported types, assert the
  `MATLAB:unassignedOutputs` identifier (current behaviour) with a comment marking it as a
  known defect, not intended design.
- **Persistent state**: `clear verifyRuleSyntax` before every case (FR-008). Verified that
  the regrow branch is reached only after a cleared state with an index above 10000.
- **Coverage measurement**: `matlab.unittest.TestRunner` + `CodeCoveragePlugin.forFile`
  on each source file, running the script test through `TestSuite.fromFile`. This needs no
  external tool; CI's MoCov remains the authoritative number.
- **Expected values**: derived from reading the source and cross-checked by the probe, so
  none is a "first-run reference" (Tier 5 not used; no solver or numeric result involved).
- **Reachability**: every line of the five functions appears reachable. The only
  exemptions anticipated are non-line items: the console prints (noise) and, in
  `getDefaultValue`, the missing `else` (nothing to cover, defect noted).
