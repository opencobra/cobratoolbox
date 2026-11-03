# Contract: getRankLUSOL

`[rankA, p, q] = getRankLUSOL(A, printLevel)` — signature, default `printLevel = 0`, and
all outputs are unchanged, bit-for-bit, for every input and print level.

| Situation | printLevel 0 (after) | printLevel ≥ 1 (after) |
|---|---|---|
| LUSOL inform 0 / 1 | silent (unchanged) | same text as today |
| LUSOL inform 3, 4, 7, 8, 9 (+ `Check norm(b-b2)`) | silent (today: printed) | same text as today |
| LUSOL call errors (catch) | first time in session: warning `getRankLUSOL:lusolFallback`; later: silent | warning on first time; the "Caught error using lusol interface…" line every time |
| `lusol_obj` not on the path | first time in session: warning `getRankLUSOL:lusolFallback`; later: silent | warning on first time; the "Cannot find lusol_obj.m…" line every time |

**Warning text** (`getRankLUSOL:lusolFallback`), one line, prefix fixed so tests can
match it:

```text
getRankLUSOL: LUSOL unavailable, using MATLAB LU instead (shown once per session). Cause: <ME.message> (<ME.stack(1).file> line <ME.stack(1).line>)
```

For the "not on path" branch the cause reads `lusol_obj.m not found on the MATLAB path`.
If `ME.stack` is empty, `(no stack)` replaces the file and line. MATLAB appends its own
backtrace to the warning in the usual way.

**Session**: see data-model.md (reset by `clear getRankLUSOL`, `clear functions`,
`clear all`, new process).
