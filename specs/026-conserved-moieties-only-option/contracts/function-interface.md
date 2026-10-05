# Public Interface Contract: identifyConservedReactingMoieties

This is the library's public contract surface for this feature (Constitution Principle II).

## Signature (unchanged)

```matlab
[arm, moietyFormulae, reacting] = identifyConservedReactingMoieties(model, BG, dATM, options)
```

No change to function name, argument order, arity, or the meaning of `model`, `BG`, `dATM`.

## `options` struct contract

| Field | Type | Default | Status |
|---|---|---|---|
| `options.sanityChecks` | logical | `1` (true) | unchanged |
| `options.useOpenSourceMoietyTools` | logical | `true` | unchanged |
| `options.conservedMoietiesOnly` | logical | `false` | **new** |

## Output contract

| Output | `conservedMoietiesOnly = false` (default) | `conservedMoietiesOnly = true` |
|---|---|---|
| `arm` | unchanged (full struct, as documented in the function header) | identical fields/values to the default-mode call on the same inputs |
| `moietyFormulae` | unchanged | identical to the default-mode call on the same inputs |
| `reacting` | unchanged (populated struct, as documented in the function header) | `struct('computed', false)` — see data-model.md |

## Backward compatibility statement

Every existing call site that does not set `options.conservedMoietiesOnly` observes no
change in behavior, performance characteristics, or output values. This is a strictly
additive change to the public contract (Constitution Principle II): no existing field,
argument, or default is altered or removed.
