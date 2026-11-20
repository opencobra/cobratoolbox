# Research: lrsSpecifyRows without sed

## R1. Replace sed by base MATLAB (Principle XI, option 1)

- **Decision**: open the file once with `fopen(name, 'r+')`, which checks that it can be read and
  rewritten, as the current code does. Read all bytes with `fread(fid, Inf, '*char')'` and close it.
  Count the rows by the current rule on the lines split at `newline`. Replace with `regexprep(text,
  '\*\*\*\*\*', int2str(nRows))`. Write the bytes back with `fopen(name, 'w')` and `fwrite`, then
  close.
- **Rationale**:
  - `regexprep` replaces leftmost, non-overlapping matches, as `sed s/.../g` does. `strrep` replaces
    overlapping matches, so `******` would differ.
  - `fread` as bytes and `fwrite` as `uint8` keep every byte (final newline, `\r`, non-ASCII), as
    sed did.
  - Splitting at `\n` gives the lines that fgetl returned. The piece after a final newline is never
    reached unless `end` is missing, which is an error in both versions.
- **Alternatives considered**:
  - `sed -i ''` for BSD and `sed -i` for GNU, chosen by platform: still an external program, and
    Windows has none. Rejected by Principle XI.
  - `perl -pi -e`: another external program. Rejected.
  - `strrep`: wrong on overlapping stars.

## R2. Defects fixed on the way

- Line 22 `disp(fileNameOut)`, an undefined variable, is removed, so the documented error 'Could not
  open lrs output file.' is raised. This is a cosmetic entry of the registry.
- The identifier is closed right after reading, so no path leaves it open. This is the limitation
  entry of the registry.
- Both entries leave testLrsSpecifyRows's header, the test covers the formerly exempt lines, and the
  registry is regenerated (Constitution III-Defects).

## R3. Outputs `[status, result]`

- **Decision**: kept, `0` and `''` on success. The only caller, lrsRun, assigns and ignores them.
  The error 'sed failed on file ...' disappears with sed. A write failure after a successful `r+`
  open is not reachable in practice; if it happens, `fwrite` raises MATLAB's invalid-identifier error.

## R4. Configuration audit (Principle IV)

- N/A: no solver or external program is invoked any more.
