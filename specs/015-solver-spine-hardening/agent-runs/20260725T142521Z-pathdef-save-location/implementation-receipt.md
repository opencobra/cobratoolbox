# Implementation receipt — pathdef save location

- **UTC timestamp:** 2026-07-25T14:25:21Z
- **File changed:** `initCobraToolbox.m`
- **Spec Kit workflow:** **bypassed** under Principle VI direct-implementation override.
- **Override token supplied by user:** `SPECKIT OVERRIDE`.
  Note: that is the variationalKinetics token. This repository's constitution
  (`.specify/memory/constitution.md:404`) specifies
  `DIRECT IMPLEMENTATION OVERRIDE: bypass Spec Kit for this change.`
  The mismatch was raised with the user before proceeding.

## Reason

`initCobraToolbox.m:101` set `defaultSavePathLocation = '~/pathdef.m'`. On Linux,
when the installation's own `pathdef.m` is not user-writable, the toolbox calls
`savepath` against that location, creating `~/pathdef.m`.

MATLAB reads `pathdef` from the startup folder in preference to
`matlabroot/toolbox/local/pathdef.m`. Any MATLAB launched with the working
directory set to the home directory therefore builds its entire initial search
path from that file. Because the file records one release's toolbox folder
layout, it silently breaks other releases installed on the same machine.

Observed failure: R2026a moved `mustBeNumericOrLogical`, `mustBeInteger` and
`mustBeNonnegative` into `toolbox/matlab/mathvalidator`, a folder absent from a
`~/pathdef.m` written under an earlier release. `isMATLABReleaseOlderThan`
validates its `update` argument default of `0` with `mustBeNumericOrLogical`, so
every call failed with:

```
Undefined function 'mustBeNumericOrLogical' for input arguments of type 'double'.
```

This disabled the MATLAB MCP server's `evaluate_matlab_code`, `check_matlab_code`
and `run_matlab_file` tools, which call `isMATLABReleaseOlderThan` before running
any user code.

## Change

1. `defaultSavePathLocation` is now `fullfile(prefdir, 'pathdef.m')`. `prefdir` is
   release specific (`~/.matlab/R2026a`) and is not on the search path, so a path
   saved by one release can neither be read by another nor override `pathdef`.
2. The Linux save branch now targets `matlabroot/toolbox/local/pathdef.m`
   explicitly instead of `which('pathdef.m')`, which resolves to a stray copy in
   the startup folder when one exists and caused `savepath` to overwrite that copy.
3. The confirmation message reports the location actually written, not always
   `defaultSavePathLocation`.

`fileattrib` is retained rather than the Code Analyzer's suggested
`filePermissions`, which requires R2025b or newer and would break backward
compatibility.

## Validation

| Check | Result |
| --- | --- |
| Install `pathdef.m` writability branch | `attribOK=1 UserWrite=0` → falls through to `prefdir` |
| `savepath` to new target | returned `0` (success), file created |
| Full non-agent `initCobraToolbox(false)` | `prefdir/pathdef.m` checksum changed → written by the toolbox |
| `~/pathdef.m` recreated? | No |
| Saved file is release-correct | contains `mathvalidator` (228693 bytes) |
| MATLAB launched from `/home/rfleming` | `mathvalidator_on_path=1`, `isMATLABReleaseOlderThan=OK` |
| Code Analyzer | 52 issues, unchanged from before the edit |

The pre-existing poisoned `~/pathdef.m` was moved to `~/pathdef.m.bak` by the user
out of band; this change stops it being recreated.

## Backfill recommendation

More than a trivial local correction. Recommend backfilling a Spec Kit artifact
covering the path-persistence behaviour, and reporting the `~/pathdef.m` default
upstream to opencobra/cobratoolbox, since it affects any multi-release Linux
installation, not just this fork.

## Related change in the same working tree

The redundant `addpath(originalUserPath)` following `path(originalUserPath)` was
removed in an earlier run (proven a no-op producing a byte-identical path string).
The surviving `path(originalUserPath)` is deliberate: solver probing re-adds
folders already on the path, hoisting them to the front, and a targeted
`rmpath` of the set difference would leave that reordering in place and change
which of the MOSEK / Optimization Toolbox copies of `linprog`, `quadprog`,
`intlinprog` and `lsqlin` wins.
