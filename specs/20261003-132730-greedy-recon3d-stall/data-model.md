# Data Model

- **Operative matrix `Sop`** — `model.S`, restricted to `SConsistentRxnBool` when requested, transposed for `'right'`. Nullity `size(Sop,1) - rank(Sop)`.
- **Candidate ray** — raw solver vector `sol.full` (length = rows of `Sop`) → returned form: negatives clipped to 0. Validation: length matches; `max|x'*Sop| <= acceptanceTarget`; `min(x) >= 0`; linearly independent of accepted rays. No other transformation.
- **Accuracy target record** (`nullspaceAccuracyTarget`) — fields per contracts/nullspaceAccuracyTarget.md; derived once per call.
- **Search state** — `nfail` (consecutive failures: empty solve, accuracy, dependence), `nfailMax = 5`, `nStallEscalations`; transitions: random objective → (nfail >= nfailMax) coverage-zeroing relaxed and targeted objective → on acceptance nfail = 0.
- **Status** — parent-feature fields + `nStallEscalations`, `spectrumTime` (contracts/greedyExtremeRayBasis.md).
- **Attainable dimension** — support of the maximal-support LP solution `z` (0/1 at optimum, threshold 0.5) → `|support| - rank(Sop(support,:))`; `shortfallKind = 'sampling'` iff attainable > raysFound, else `'structural'`; `'notAssessed'` if the LP fails.
- **Basis report** (`checkNullspaceBasis`) — contracts/checkNullspaceBasis.md.
