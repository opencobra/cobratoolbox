# Research: plain-MATLAB toolbox replacements

## R1 — Semantics source
MathWorks behaviour for every replaced function is collected in
[mathworks-semantics.md](mathworks-semantics.md), with a source URL per claim (current MathWorks
documentation; MathWorks' own R14SP2 Statistics Toolbox source from a public mirror where the
documentation is silent, marked "(R14; current UNCONFIRMED)"). The R14 source is copyrighted: it
informs the semantics only, and no code from it is copied (all implementations are written
from the documented formulas).

## R2 — Independent references
- **Decision**: SciPy 1.16 (this machine) as the independent numerical reference; reference
  values are computed by scripts kept in the feature folder (`references/*.py`, one per group)
  and pasted into the tests with the SciPy version; MathWorks documentation examples are used
  where they publish numbers; a parity section compares with the MathWorks function when its
  toolbox is installed.
- SciPy equivalents: `norm.cdf/ppf`, `t.cdf/ppf`, `chi2.cdf`, `f.cdf`, `skew(bias=True)`,
  `kurtosis(fisher=False, bias=True)`, `pearsonr`, `spearmanr` (t approximation),
  `kendalltau(variant='b', method='exact'|'asymptotic')`, `spatial.distance.pdist`
  ('euclidean', 'jaccard'), `linalg.svd`, `linalg.lstsq`. For exact Spearman p-values (n<10)
  the reference enumerates all permutations in Python; for AS 89 the reference implements the
  published formula (Best & Roberts 1975).

## R3 — Design decisions
- Names: `cobra` + MathWorks name (e.g. `cobraNormcdf`), in `src/base/utilities/toolboxFree/`
  (new subfolder, Principle IX); no shadowing (FR-002).
- Parallel helpers: `isParallelToolboxAvailable` (license and installation check),
  `getParallelPool` (≡ `gcp('nocreate')` or `[]`), `openParallelPool(varargin)` (≡ `parpool`
  arguments, opens only if none is open, returns the pool or `[]`), `closeParallelPool`
  (≡ `delete(gcp('nocreate'))`).
- `cobraSmooth`: only the default `'moving'` method with span 5 on uniformly spaced or absent x;
  non-uniform x or NaN (where MATLAB switches to 'lowess') raises an error naming 'lowess'.
- `cobraPca`: SVD-based; supports `'Centered'` true/false and accepts `'Algorithm','als'` for
  complete data (no NaN), documented as matching ALS within tolerance; MATLAB sign convention.
- `cobraCorr`: Pearson, Spearman, Kendall; 'rows' 'all'; p-value rules of
  mathworks-semantics.md §10 (exact/Edgeworth/t/normal approximations).
- `cobraRegress`: QR with rank detection; stats per §13.
- `cobraTdfread`: base-MATLAB parsing of tab-delimited text; numeric only if every row parses
  as a number (no `eval`); char matrix columns padded with blanks.
- `nansum` → `sum(..., 'omitnan')` at its single call site.
- `old/` and `deprecated/` call sites are not changed.

## R4 — Review
Codex CLI 0.164 in read-only sandbox (`codex exec -s read-only`), one review per group, prompt
includes the semantics note; findings recorded in `review.md`.
