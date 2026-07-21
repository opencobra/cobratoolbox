# Contract — mode control (`getCobraTestMode`)

## Signature

```matlab
mode = getCobraTestMode()      % returns 'fast' | 'full'
tf   = getCobraTestMode('isFast')   % optional convenience → logical (fast?)
```

New file: `src/base/install/getCobraTestMode.m`.

## Behaviour

| Condition | Result |
|-----------|--------|
| `getenv('COBRA_CI') == '1'` | `'full'` (unconditional; FR-012) |
| global `CBT_TEST_MODE` set to `fast`/`full` | that value |
| `getenv('COBRA_TEST_MODE')` is `fast`/`full` | that value |
| none of the above | `'fast'` (default) |
| any set value not in {`fast`,`full`} (case-insensitive) | error `COBRA:testMode:invalid` listing accepted values |

## Guarantees

- Deterministic and side-effect free (no global writes, no solver calls).
- CI always resolves to `full`, regardless of other settings.
- Case-insensitive acceptance; returns canonical lowercase.

## Consumers

- `test/testAll.m` — prints the active mode; passes nothing else through.
- `src/base/install/prepareTest.m` — fast ⇒ minimal solvers unless overridden.
- Individual tests with hardcoded solver lists — fast ⇒ single default solver.
