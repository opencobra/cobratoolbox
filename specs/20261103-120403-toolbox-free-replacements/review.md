# Independent review (FR-007)

**Reviewer.** The Codex CLI (0.164) was invoked read-only on 2026-11-03, but the ChatGPT account
of this machine rejects every model ("model is not supported when using Codex with a ChatGPT
account": gpt-5.5, gpt-5, gpt-5.1, gpt-5.2, gpt-5-codex, gpt-5.1-codex, gpt-5.3-codex, gpt-5-mini,
o4-mini, gpt-4.1, codex-mini-latest). Per FR-007 the review was done by independent reviewer
agents that received only the code, the tests and `mathworks-semantics.md` (not the
implementers' reports), with the same prompt prepared for Codex. The Codex review is to be
repeated when the account works.

## Group P — parallel pool helpers and the 41 call sites

| # | Severity | Finding | Resolution |
|---|---|---|---|
| 1 | BUG | `cycleFreeFlux.m` detected the toolbox with `try gcp ... catch`; `getParallelPool` never errors, so on base MATLAB `hasPCT` became true and `param.parallelize=true, k>12` reached an error instead of running serially | Fixed: `hasPCT = isParallelToolboxAvailable();` |
| 2 | MISMATCH | `GPR2models.m`: with a pool open and `numWorkers > 1`, the old `parpool(numWorkers)` errored; `openParallelPool` returned the open pool and the user's worker limit was ignored | Fixed: `poolsize = min(numWorkers, p.NumWorkers)` (the `parfor` limit), no pool call |
| 3 | STYLE | `openParallelPool(n)` without a semicolon (33 callers) printed `ans = []` on base MATLAB | Fixed in the helper: the output is assigned only when requested; display with the toolbox unchanged |
| 4 | STYLE | `setWorkerCount.m` printed "Parallel computation initialized" without the toolbox | Fixed: printed only when a pool was opened |
| 5 | TEST-GAP | the no-semicolon call was not tested | Fixed: `testOpenParallelPool` asserts `evalc('openParallelPool(1)')` prints nothing under the stand-in |
| 6 | TEST-GAP | no test of caller behaviour without the toolbox on a machine that has it (SteadyCom fallbacks, `cycleFreeFlux`) | Answered: the callers need an LP solver (Tier 3); `testSteadyCom` (threads = 2) exercises the fallback on CI machines without the toolbox. Recorded as a follow-up for the Tier-3 tests of these functions |
| 7 | TEST-GAP | `testCloseParallelPool` closed and recreated a pool the user had open | Fixed: the section is skipped when a pool was open before the test |
| 8 | TEST-GAP | the test pool and the working directory were not restored on failure | Fixed for the pool (`onCleanup`); the `cd(currentDir)` ending follows the COBRA test template used by every test |
| 9 | TEST-GAP | `testIsParallelToolboxAvailable` compares with the same expression | Accepted: the stand-in tests in the other three files exercise the false branch |

Reviewer verified without findings: `isParallelToolboxAvailable`, `getParallelPool`,
`closeParallelPool`; the SteadyCom fallbacks; all callers that read `.NumWorkers`; the four tests
restore path, temp directory and pool state.

Re-run after the fixes: the four tests pass, 100% line coverage each.

## Group T — tabulate, grp2idx, crosstab, skewness, kurtosis, smooth

Items marked (recall) come from the reviewer's recollection of MathWorks source; they were
adopted to move closer to MathWorks and are marked "(recall of MathWorks source; UNCONFIRMED)"
in the headers, to be settled by the parity sections on an installation with the toolbox.

| # | Severity | Finding | Resolution |
|---|---|---|---|
| 1 | MISMATCH | `cobraTabulate` printed non-integer values with `%5d` | Fixed: grp2idx names, width max(5,min(50,longest)) |
| 2 | STYLE | sparse input and Inf failed inside accumarray | Fixed: `full()`; Inf raises a clear error |
| 3 | MISMATCH | `cobraGrp2idx` formatted numeric names per element | Fixed: `strtrim(cellstr(num2str(gL)))` of the whole column |
| 5 | TEST-GAP | zero marginals in `cobraCrosstab` | Documented and tested (chi2, p NaN) |
| 7 | STYLE | "NaN for a constant slice" overstated | Fixed: only for an exactly constant slice |
| 8 | MISMATCH | `[]` special case with dim, and class | Fixed: only without dim, `NaN('like',X)` |
| 9 | STYLE | duplicated dim, integer X | Fixed: clear errors |
| 11 | MISMATCH (recall) | uniform-x test ran on sorted x | Fixed: on x as given |
| 12 | MISMATCH (recall) | lowess on uniform x kept an even span | Fixed: span = min(span,n), made odd; uniform-x end rule |
| 13 | MISMATCH (recall) | 'moving' ignored tied x | Fixed: tie-group averaging |
| 14 | BUG | empty span misread | Fixed: empty span = 5 in both positions |
| 15 | MISMATCH | scalar second argument read as y | Fixed: scalar second argument is the span |
| 16 | MISMATCH | output always double | Fixed: class of y |
| 17 | MISMATCH | lowess span 1 | Fixed: returns y unchanged |
| 18 | doc | NaN with explicit 'moving' | Header states MathWorks computes there; ours errors (unsupported) |
| 19 | performance | lowess O(n²) | Fixed: sliding window O(n·span); 1e5 points < 0.6 s. The implementer's brute-force cross-check (4085 random cases) found and fixed a stall on repeated x in the first version |
| 20 | TEST-GAP | missing cases | Added: even span, repeated x, empty span, scalar y, single |
| 21 | BUG (call site) | `sampleScatterMatrix` still guarded with `exist('smooth')` | Fixed: guard removed |
| 22 | BUG (call site) | moiety functions gated `cobraTabulate` on a Statistics licence | Fixed: licence branch and warning removed; option documentation updated |

Re-run after the fixes: six tests pass, 100% line coverage each; lowess matches the independent
Python reference within 9.2e-16 relative.

## Group D — normcdf, norminv, tcdf, tinv, chi2cdf, fcdf

Decision: the maintainer's goal is consistency with the MathWorks functions, so where the first
implementation improved on the MathWorks algorithms (more accurate t distribution for large
degrees of freedom, Newton-refined quantiles), it was changed to reproduce them; every remaining
known difference is written in the function's NOTE and has its own test tolerance.

| # | Severity | Finding | Resolution |
|---|---|---|---|
| 1 | BUG | `cobraTinv` returned huge wrong values for nu > ~1e200 (extreme-tail branch) | Fixed (branch removed); test `cobraTinv(0.025,[1e199 1e250 1e300]) = cobraNorminv(0.025)` |
| 2 | MISMATCH (deliberate) | `cobraTcdf` used Hill's expansion from nu = 1e4 | Changed to MathWorks' rule: betainc for nu ≤ 1e7, normal cdf above (R14; current UNCONFIRMED) |
| 3 | MISMATCH (deliberate) | `cobraTinv` Newton refinement and tail branch | Changed to MathWorks' rule: betaincinv for nu < 1000, Cornish-Fisher for nu ≥ 1000, ±Inf where the formula overflows |
| 4 | STYLE | wrong accuracy claim in the `cobraTcdf` NOTE | Corrected with measured values per nu |
| 5 | TEST-GAP | no nu between 1e3 and 1e4 | nu = 9000 column added; per-column tolerances ≈ 3× measured maximum |
| 6 | TEST-GAP | betaincinv accuracy claim; parity tolerance too loose | Claim corrected; tinv parity 1e-12 incl. extreme-tail points |
| 7 | TEST-GAP | nu > 1e200 untested | Test added (item 1) |
| 8 | performance | tinv 10× slower than tcdf (Newton) | Resolved by item 3 |
| 9 | performance | fcdf computed both tails | Fixed: only the requested tail |
| 10 | MISMATCH (unconfirmed) | `cobraChi2cdf(x,0)` was NaN; call site `compareTwoSamplesStat` can pass 0 | Changed to gammainc semantics (1 for x ≥ 0), marked UNCONFIRMED, parity check added |
| 11 | doc | implicit expansion of compatible sizes unsupported | Stated in every NOTE |
| 12 | STYLE | generic "too many arguments" errors | Named `unsupportedSyntax` errors in `cobraNorminv`, `cobraTinv` |
| 13 | STYLE | duplicated `expandInputs` helper | Accepted (each file self-contained, no private folder) |
| 14 | scope | `old/` call sites still call `normcdf` | By design: `old/` and `deprecated/` are excluded (spec) |

Re-run after the fixes: six tests pass, 100% line coverage each. Largest differences: normcdf
6.2e-14, norminv 1.5e-16, tcdf 6.1e-14 (nu ≤ 10) to 1.6e-9 (nu = 1e6, betainc), tinv 1.3e-14 vs
mpmath, chi2cdf 5.0e-14, fcdf 2.35e-13.

## Group M — pdist, corr, pca, regress, tdfread

The reviewer found MathWorks sources newer than the R14 baseline: corr.m (1984-2010, third-party
mirror), a regress.m (1993-2014) excerpt, and evidence that tdfread (~R2012) calls genvarname.
Decision: follow the newest known behaviour; `mathworks-semantics.md` §10, §13, §14 updated.

| # | Severity | Finding | Resolution |
|---|---|---|---|
| 1 | MISMATCH | Spearman ties decided per column pair (R14) | Fixed: ties over all columns decide the method for every pair (2010) |
| 2 | MISMATCH | diagonal p-values of `corr(X)` (0, 2/n!, …) | Fixed: `sign(diag(rho))` (1, NaN for a NaN column) for all types |
| 3 | — | Pearson, AS 89, exact and normal-approximation rules | Verified against the 2010 source; no change |
| 4 | TEST-GAP | tests asserted the R14 rules | Updated to the 2010 rules |
| 5 | call sites | `correlateFluxWithTaxonAbundance` corrMethod values supported | No change. Pre-existing, unchanged: `quanQualAcc.m:136` filters its two vectors with different `isfinite` masks (lengths can differ) — follow-up |
| 6 | BUG | `cobraRegress` rint divided by zero for nu == 1 | Fixed: nu > 1 / nu == 1 / nu == 0 branches |
| 7 | MISMATCH | rint used nu degrees of freedom | Fixed: `cobraTinv(1-alpha/2, nu-1)` (2014) |
| 8 | MISMATCH | error when no row is complete (`SteadyComPOAgr` can reach it) | Fixed: regress outputs for n = 0 with the rank warning |
| 9 | STYLE | constant-term check | Fixed: regress form |
| 10 | TEST-GAP | rint reference used the same formula; no nu == 1 case | Fixed: independent leave-one-out reference; nu == 1 and leverage-1 cases |
| 11 | MISMATCH (recall) | pca tsquared for DOF ≤ 1 and rank warning | Fixed: q = 0 for DOF ≤ 1; `cobraPca:ColRankDefX` warning (UNCONFIRMED) |
| 12 | call site | pca call site (NaN replaced by 0 beforehand; ALS tolerance) | No change |
| 13 | — | pdist | No findings |
| 14 | MISMATCH | tdfread field names via makeValidName | Fixed: `genvarname(strtrim(header))` as in ~R2012 (hex-encodes punctuation, e.g. 'a-b' → 'a0x2Db') |
| 15 | pre-existing | `readInputTableForPipeline` turns field names into table headers, so DEMETER loses original headers of .tsv inputs (e.g. bile-acid spreadsheet headers 7aHSDH… become x7aHSDH… and do not match InReactions.txt) | Not caused by this feature (MathWorks tdfread does the same); recorded as a DEMETER follow-up: read the raw header line instead |
| 16 | MISMATCH (UNCONFIRMED) | lines made only of delimiters were dropped | Fixed: only truly empty lines are skipped |
| 17 | — | real VMH and DEMETER files | Verified: VMH files 19 313 / 8 585 rows, fields char as annotateModel needs; 38 DEMETER spreadsheets read in 4.7 s |
| 18 | TEST-GAP | tests asserted makeValidName names; no empty-row test | Updated; added |

Re-run after the fixes: five tests pass, 100% line coverage each; corr p-values within 1.1e-13,
regress within 3.9e-13 (scaled) of independent references.
