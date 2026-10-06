# Contract delta: greedyExtremeRayBasis

Signature unchanged: `[Zpos, Z, status] = greedyExtremeRayBasis(model, param)`.

## New optional input (additive)
| Field | Default | Meaning |
|---|---|---|
| `param.maxElementsForSpectrum` | `1e8` | largest `numel(Sop)` for which the dense spectrum is computed to derive the accuracy target and assess the regime; above it the existing fallback applies (`accuracyTargetDerived = false`, `regime = 'notAssessed'`) |

## New status fields (additive, present on every return path)
| Field | Meaning |
|---|---|
| `nStallEscalations` | times the consecutive-failure counter reached its threshold (accuracy AND dependence failures now both count) |
| `spectrumTime` | seconds spent deriving the target and regime (0 if not computed) |

## Changed behaviour (documented in the help-header NOTE)
- Rays are judged and returned as the solver's own solution with negative entries clipped to zero; entries below `10*feasTol` are no longer zeroed. Every returned row still satisfies `max|row*Sop| <= status.acceptanceTarget` and `min >= 0`.
- `attainableDimension` comes from a maximal-support LP; `shortfallKind` may change from `structural` to `sampling` where the former verdict was wrong.
- The default spectrum ceiling rises from 5e7 to 1e8 elements.

## Unchanged
Five outcomes, termination reasons, trimmed basis, Regime-B diagnosis and withheld bases, target derivation mathematics, `param.feasTol` clamp, solver nomination/restoration, tuned solver settings, paired-comparison instrumentation (inert when off), two-output call.
