# Data Model: Fix four CI test failures

No persistent data. Three pieces of state matter:

## binary submodule pointer

- **Value**: `43f41b0b7` (now) → `10697a987` (target, on the binary repository's `master`).
- **Effect**: 42 changed files under `glnxa64/bin/{lrs,quadPrecision,minos,DQQ}` (research R5).

## getRankLUSOL fallback-warned flag

- **Kind**: `persistent` logical inside `getRankLUSOL`, initially empty (= not warned).
- **Transitions**: empty/false → true on the first fallback (LUSOL error or interface
  missing) after raising `getRankLUSOL:lusolFallback`. Never set back by the function.
- **Reset**: a new MATLAB process, `clear functions`, `clear all`, `clear getRankLUSOL`.
- **Validation**: the warning is raised exactly when the flag is not yet true; the
  explanatory `fprintf` lines are printed whenever `printLevel > 0`, whatever the flag.

## lrsRun command outcome

- **Fields used**: `status` (shell exit status), `result` (captured stdout/stderr text),
  the command text.
- **Rule**: `status ~= 0` → `error('lrsRun:commandFailed', ...)` naming the command,
  status and `result`, before any output file is read. Applies to lrs (vertex and facet
  enumeration), redund, and the shell-script call.
