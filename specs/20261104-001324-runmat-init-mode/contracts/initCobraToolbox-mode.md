# Contract: `initCobraToolbox` `'runmat'` mode

**Signature**: `initCobraToolbox(updateToolbox, mode)`. Unchanged; the documented values of `mode` grow by one.

| Call | Behaviour |
|---|---|
| `initCobraToolbox`, `initCobraToolbox(u)`, `initCobraToolbox(u, 'default')` | as before this feature |
| `initCobraToolbox(false, 'agent')` | as before this feature |
| `initCobraToolbox(false, 'runmat')` | agent-mode flow (silent apart from the summary line; skips git, network, solver probing, path saving and updates), plus the registered RunMat workarounds |
| `initCobraToolbox(true, 'runmat')` | error `initCobraToolbox:invalidMode`; the message names the combination `updateToolbox = true` with `'runmat'` |
| `initCobraToolbox(false, 'nope')` | error `initCobraToolbox:invalidMode`; the message lists `'default'`, `'agent'` and `'runmat'` |

## Postconditions of `'runmat'` mode

**In MATLAB** (SC-004):
- `CBTDIR` is the same as after `'agent'` mode.
- The set of COBRA path entries is the same as after `'agent'` mode.
- `SOLVERS`, `OPT_PROB_TYPES` and `CBT_INITIALIZED` are set as in `'agent'` mode.

**In RunMat v0.6.2** (SC-001):
- Every statement before the first toolbox-function call runs.
- The run stops at that call with an error that `debtRegister.md` lists under *Blocking defects*.

**Idempotency**: the existing `CBT_INITIALIZED` guard applies unchanged.
