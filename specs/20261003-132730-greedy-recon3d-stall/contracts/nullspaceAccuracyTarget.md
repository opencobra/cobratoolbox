# Contract: nullspaceAccuracyTarget (new, extracted)

`target = nullspaceAccuracyTarget(Sop, param)`

- `Sop`: operative matrix (already restricted/transposed by the caller); its LEFT nullspace is the one certified.
- `param.maxElementsForSpectrum` (default 1e8; spectrum computed iff `numel(Sop) <= maxElementsForSpectrum`, the existing `<=` semantics).
- Returns struct: `accuracyTarget`, `accuracyTargetDerived`, `regime` (`'wellScaled'|'badlyScaled'|'notAssessed'`), `sigmaOne`, `sigmaMinPlus`, `regimeBoundary`, `tauMin`, `spectrumTime`.
- Mathematics identical to the derivation in greedyExtremeRayBasis as of develop @ a2069f7ed (parent research.md R3/R2): `tauMin = eps*max(nRow+nCol, nRow)`, `accuracyTarget = tauMin*sigma_1*sigma_min+`, `regimeBoundary = eps/(tauMin*sigma_1)`, fallback `eps*normest(Sop)`.
- Invariant: on every existing test fixture, greedyExtremeRayBasis reports the same `accuracyTarget` before and after extraction (bitwise).
