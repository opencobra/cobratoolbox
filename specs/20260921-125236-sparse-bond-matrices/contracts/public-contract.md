# Contract: `buildAtomAndBondTransitionMultigraph` after feature 20260921-125236-sparse-bond-matrices

## Signature (unchanged)

```matlab
[dATM, metAtomMappedBool, rxnAtomMappedBool, M2Ai, Ti2R, dATME, BG, dBTM, ...
    M2BiE, M2BiW, BTi2R, BTiE] = buildAtomAndBondTransitionMultigraph(model, RXNFileDir, options)
```

Output names, order and count, input names and order: unchanged.

## Options

| Field | Default | Status |
|---|---|---|
| `sanityChecks` | `1` | unchanged |
| `bondTransitionMultigraph` | `1` | unchanged |
| `denseBondMatrices` | `0` | **new** — `1` returns `M2BiE`, `M2BiW`, `BTi2R` as full `double` (historical output, bit-identical) |

## Output guarantees

| Output | Default (`denseBondMatrices = 0`) | `denseBondMatrices = 1` |
|---|---|---|
| `dATM`, `metAtomMappedBool`, `rxnAtomMappedBool`, `M2Ai`, `Ti2R`, `dATME`, `BG`, `dBTM`, `BTiE` | identical to pre-change | identical to pre-change |
| `M2BiE`, `M2BiW`, `BTi2R` | **sparse `double`**; same size; `isequal(full(x), pre-change)` | full `double`; `isequal` to pre-change |

**Breaking change (approved, spec FR-010)**: the storage class of `M2BiE`, `M2BiW` and
`BTi2R` changes from full to sparse by default. Values, sizes and element class
(`double`) are unchanged. Migration: set `options.denseBondMatrices = 1`.

## Behavioural guarantees (unchanged)

- Every `error`, `warning` and `fprintf` fires under the same conditions with the same
  text, in both modes.
- Both decompositions (`M2Ai*M2Ai'*N = M2Ai*Ti*Ti2R`;
  `M2BiW*M2BiE'*N = M2BiE*BTiE*BTi2R` over bond-mapped metabolites) hold with the same
  residual in both modes.
- With `options.bondTransitionMultigraph = 0`, behaviour is identical to today and the
  new option has no effect.
- In dense mode the bond residual check and its mismatch report run on full matrices
  exactly as today; in default mode they run on sparse matrices and print the same
  content (verified by the CI test, FR-015 (e)).

## Known in-repository consumers (no edits required)

`testConservedReactingMoieties.m`, `tutorial_conservedAndReactingMoieties.m` and the
reconXmoieties pilot scripts destructure the outputs but never read
`M2BiE`/`M2BiW`/`BTi2R` afterwards (spec Assumptions: consumer inventory).
