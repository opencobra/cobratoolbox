# Contract: lrsRun (unchanged interface)

`fileNameOut = lrsRun(modelName, param)`; inputs, defaults, returned names, the
`lrsRun:commandFailed` error and the messages for a missing lrs and for non-Unix machines stay as
documented (Principle II).

Changed behaviour, `param.redund = 0` with facet enumeration only:

| | Before | After |
|---|---|---|
| Programs run | `lrs`, then `redund` | `lrs`, then `lrs` again with the `redund 0 0` option |
| Printed command | `redund <m>.ine > <m>_noR.ine` | `lrs <m>.ine (with option redund 0 0) > <m>_noR.ine` |
| Requirement | `redund` on the PATH | none beyond `lrs` (lrslib 7 or later) |
| Files left | `<m>.ine`, `<m>_noR.ine` | the same; the temporary input is removed |
| Failure | `lrsRun:commandFailed` naming the redund command | `lrsRun:commandFailed` naming the lrs command |
