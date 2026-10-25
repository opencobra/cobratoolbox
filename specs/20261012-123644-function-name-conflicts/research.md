# Research: function-name conflicts

## Probe of the current repository (MATLAB R2025a, read-only)

- 1,592 function files under `src/` (excluding `private/`, `@class/`, `+package/`).
- 23 names occur more than once inside `src/` (also 23 case-insensitively): mostly `old/` and
  `new/` copies of the thermodynamics code, plus `Rate_function` (two solvers) and `demo` (two
  sampling folders). The `new/` folders are removed from the MATLAB path by
  `initCobraToolbox`, so a path-based check alone would miss these.
- Names that also exist in MATLAB: `demo` (`toolbox/matlab/helptools/demo.m`) and `lsqr`
  (`toolbox/matlab/sparfun/lsqr.m`). `position` appears only as a method inside a class folder
  (`@mtree/position.m`) and is not a conflict.
- No toolbox function shares a name with a file in `external/`.

## Decisions

- **Detection of toolbox duplicates**: scan the file system (not the MATLAB path) for `*.m`
  under `src/` and `external/`, ignoring `private/`, `@*` and `+*` folders; group by lower-case
  name; a conflict is any name with two or more files that includes at least one `src/` file.
  Rationale: works for folders that are not on the path and catches case-only differences.
- **Detection of MATLAB conflicts**: for every `src/` name, `which(name, '-all')`; keep results
  under `matlabroot` that are not inside a class (`@`) or package (`+`) folder. This catches
  built-ins and installed MATLAB toolbox functions. Alternative considered: `exist(name)`
  (cannot tell where the other function is, so the message could not name it).
- **Known conflicts**: plain text, one line per name: `name | duplicate` or
  `name | shadows-matlab` followed by `| reason`; lines starting with `#` are comments. One
  entry covers a name. Rationale: readable and editable by hand; the failure message tells how
  to add an entry. Limitation (accepted): a further copy of an already recorded name is not
  detected.
- **Stale entries**: do not fail; print one note listing removable entries.
- **Self-check**: the test builds a temporary tree (duplicate across folders, a case-only
  twin, a file named after a MATLAB function, a clean file, and files inside `private/` and
  `@cls/` that must be ignored), runs the same detector on it, asserts the findings and that
  the message holds the five required items, then removes the tree.
- **Message**: for every conflict: the name, the conflicting paths, one sentence on why it
  matters (only the first function on the path runs, the other is silently ignored), how to
  fix (rename; or record a reviewed duplicate in `knownFunctionNameConflicts.txt` with a
  reason), and the MATLAB release used.
- **Selection in CI**: `select_tests.py` selects tests that mention a changed function. A new
  function is mentioned by no test, and the selector's own policy for that case is "run
  nothing". A small rule adds this test whenever any changed path matches `src/**/*.m`.
- **Test location**: `base/testInstall` (existing install/path checks).
