# Contract: known-defect entry format in test headers

This is the single definition of the entry grammar required by Constitution III-Defects. The
generator ([plan.md](../plan.md)) implements exactly this contract; the constitution does not
restate it (Principle X).

## Where entries live

In the leading comment block of a `test*.m` file under `test/verifiedTests/` (the lines that
start with `%` before the first code line).

## The function under test

```matlab
% Function under test:
%     src/<domain>/.../<functionName>.m
```

The path on the line after `Function under test:` is repository-relative and MUST exist.

## The defects section

```matlab
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: short title, unique for this function
%       SEVERITY: wrong-result
%       TRIGGER: the input or call that causes it
%       OBSERVED: what happens
%       EXPECTED: what should happen
%       LINES: 40, 62-64
%     - DEFECT: a second defect of the same function
%       SEVERITY: error
%       ...
```

or, when the test found none:

```matlab
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
```

## Rules

1. The heading line is exactly `Known defects documented (NOT tested, NOT fixed here):` after
   the `%` and optional spaces. The section ends at the first empty comment line (`%`) or the
   end of the header block.
2. Each entry starts with a line whose text is `- DEFECT: <title>`.
3. A field line starts with one of the keywords `DEFECT`, `SEVERITY`, `TRIGGER`, `OBSERVED`,
   `EXPECTED`, `LINES` followed by `:`. Every entry MUST have all six fields, once each.
4. A field value may continue on following comment lines. A continuation line MUST NOT start
   with one of the six keywords followed by `:`; continuation lines are joined to the value
   with single spaces.
5. `SEVERITY` is exactly one of `wrong-result`, `error`, `unusable-option`, `cosmetic`,
   `limitation`.
6. `LINES` is a comma-separated list of positive integers or ranges `a-b` (with `a <= b`),
   each within the number of lines of the function's source file.
7. `DEFECT` titles are unique for one function across all test files.
8. `None found.` (optionally followed by an explanation in the same comment text) means there
   is no entry. Any other content that is not an entry is an error, so free-form prose cannot
   hide a defect from the registry.
9. A test file that has a `Function under test:` line MUST have the defects section. A test
   file with neither is ignored (existing tests written before this convention).
10. Text is plain ASCII where possible; the characters `|` in a value are escaped by the
    generator in the table.

## Severity meaning

| Severity | Meaning |
|---|---|
| wrong-result | the function returns a result that is incorrect for valid input |
| error | the function raises an error (or cannot be called) for valid input |
| unusable-option | an option or argument can never take effect |
| cosmetic | harmless but unexpected output (formatting, console text) |
| limitation | works only for a restricted kind of input and silently misbehaves otherwise |
