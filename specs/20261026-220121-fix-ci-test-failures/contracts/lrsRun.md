# Contract: lrsRun

`fileNameOut = lrsRun(modelName, param)` — signature, inputs, defaults and the success
return value are unchanged.

| Situation | Today | After |
|---|---|---|
| lrs/redund exits 0 | continue | continue (unchanged) |
| lrs/redund exits 1 | `error('lsr failed on file …')` (no identifier) | `error('lrsRun:commandFailed', …)` |
| lrs/redund exits any other non-zero (e.g. 127 cannot execute) | continues; a later read fails with "Could not read lrs output file." | `error('lrsRun:commandFailed', …)` |
| shell-script mode, script exits 0 | `error('Failure to run Bash script …')` (inverted) | returns `fileNameOut` (`<model>.ext` for vertex, `<model>.ine` for facet enumeration) |
| shell-script mode, script exits non-zero | continues, then "Output argument not assigned" | `error('lrsRun:commandFailed', …)` |
| `which lrs` empty, or non-Unix | prints a message, returns without assigning output | unchanged (out of scope) |

**Error message content** (`lrsRun:commandFailed`): the command run, its exit status, and
the captured output text (may be empty), e.g.

```text
lrsRun: command "lrs /path/test.ine > /path/test.ext" failed with exit status 127.
Output: sh: 1: lrs: cannot execute ...
```
