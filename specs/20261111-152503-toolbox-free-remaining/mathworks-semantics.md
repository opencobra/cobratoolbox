# MathWorks semantics reference: remaining toolbox-free replacements

Compiled 2026-11-11 by four read-only research passes (one per function group), for
[spec.md](spec.md) and [research.md](research.md). Every claim cites its source; anything that
could not be confirmed is marked **UNCONFIRMED**. MathWorks source code was never copied.
Decisions taken on these notes are in research.md; where this note proposes something that
research.md decides differently (for example functions left toolbox-gated), research.md governs.

Groups:

- [G1 — statistical tests, distributions, small utilities](#g1)
- [G2 — curve fitting and optimizers](#g2)
- [G3 — regression and machine learning](#g3)
- [G4 — figures, parallel leftovers, test requirements](#g4)

<a id="g1"></a>

# MathWorks semantics, group G1: statistical tests, distributions and small utilities

Compiled 2026-11-11 for feature `20261111-152503-toolbox-free-remaining`. This is read-only research: no repository file was edited and MATLAB was not run. Every claim cites its source.

## Source key

- **[DOC-x]**: the current MathWorks documentation page, fetched 2026-11-11.
  - Statistics pages: `https://www.mathworks.com/help/stats/<x>.html`
  - mafdr: `https://www.mathworks.com/help/bioinfo/ref/mafdr.html`
  - dataset export: `https://www.mathworks.com/help/stats/dataset.export.html`
- **[R14:x.m]**: the R14SP2 Statistics Toolbox source, from the public mirror `https://globec.whoi.edu/data/matlabr14sp2/toolbox/stats/<x>.m`. It was read through a summarising fetch for semantics only and never copied. This is the same source class the first slice used. It is authoritative for the 2005 algorithm only. Anything resting on it alone is marked **(R14; current UNCONFIRMED)**.
  - Fetched files: anova1, kruskalwallis, ranksum, kstest2, ttest2, ksdensity, cmdscale, hygecdf, tiedrank, randsample, geomean.
- **[STOREY02]**: J. D. Storey (2002), "A direct approach to false discovery rates", JRSS-B 64:479-498. Read from https://www.stat.cmu.edu/~ryantibs/journalclub/storey_2002.pdf (text extracted locally in the scratchpad).
- **[PY]**: numerical checks run locally with SciPy 1.16.3 in the reference virtual environment outside the repository (statsmodels 0.15.0 and scikit-learn 1.9.1 are also installed there). Each check is stated where it is used.
- **UNCONFIRMED** means no source could confirm the claim.

---

## 0. Cross-cutting findings (read first)

1. **mafdr default (Storey) is used.** `performStatisticalAnalysis` has `BHFDR` defaulting to **false** (line 42). It then calls `[fdr,q] = mafdr(pAverages,'BHFDR',false)` (line 191) and stores **q**. This default path is the one reached from `analyzeMgPipeResults` (lines 111 and 132), which never passes BHFDR. `fdrBHadjustment` therefore does **not** cover it. mafdr's default `'Method','bootstrap'` is very probably random (§7), so seeded parity with MathWorks is not achievable without the unpublished algorithm.
2. **Toolbox guards hide call sites.** Replacing the function is not enough at these three places, because the call site is also gated by a licence check:
   - `analyseWBMsol.m:205` (`if license('test','Statistics_Toolbox')`, around tiedrank);
   - `mgSimResCollect.m:115` (forces `noPcoa = 1` without Statistics, around cmdscale);
   - `initPersephone.m:69` sets `statToolboxInstalled`, which gates the whole statistics stage in `runPersephone.m:315`. That stage also needs fitlm/fitglm from another group.

   The plan must decide whether these guards are removed in this feature.
3. **ranksum statistic for unequal sizes.** The current doc says stats.ranksum is "the rank sum of the first sample" [DOC-ranksum]. R14 reported the rank sum (and z) of the **smaller** sample [R14:ranksum.m]. Five call sites read `stats.ranksum` or `stats.zval`, and the groups are generally unequal. This is UNCONFIRMED for current releases and must be settled by a parity section. Two-sided p is unaffected.
4. **kstest2 positional syntax.** `compareTwoSamplesStat` calls `kstest2(x1,x2,0.01,'larger')`. The current doc lists only name-value options [DOC-kstest2]. R14 used exactly this positional form [R14:kstest2.m]. Whether current MATLAB still accepts it is UNCONFIRMED. The replacement must accept it either way.
5. **Pre-existing defects seen while tracing (record under III-Defects; do not fix here):**
   - `createContextSpecificModel.m` calls `findTranscriptionValue` (lines 62, 64, 83, 97, 119). No such function exists anywhere in the repository (`grep` over the whole repo). The geomean branches are unreachable in practice.
   - `testFitC13Data.m:20` uses `solverPkgs.LP{1}`, but the variable is `solvers`.
   - `testFitC13Data` declares no toolbox requirement, yet reaches `dataset` through `generateIsotopomerSolver`.
   - `partition.m:34` (SWIFTCORE) still asserts a Bioinformatics licence. This is relevant to `testSWIFTCORE`/`testPartition` (spec US6 #4).
6. **Display 'on' at two kruskalwallis sites.** `retrieveModelStats.m:174` and `dimensionalityReductionAndMultivariateAnalysis.m:189` call kruskalwallis **without** `'off'`, so MathWorks draws a table figure and a box plot.
   - `retrieveModelStats` closes them at once (`close all`, line 175).
   - In `dimRed...`, the next statement opens a new `figure` and `saveas(gcf,...)`, so gcf is the violin plot, not the KW figures.

   The replacement can therefore draw nothing for 'on' without changing any saved output. Alternatively, the call sites can pass `'off'`.

---

## 1. anova1

Doc: https://www.mathworks.com/help/stats/anova1.html

### 1.1 Call sites

- `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/performStatisticalAnalysis.m:164`: `[p,tbl,stats] = anova1(dataAll,group,'off');`
  - **Inputs:**
    - `dataAll` is a **1×nSamples double row** (`cell2mat(sampleData(i,2:end))` or `str2double(...)`, lines 119-123). Values with |x| < 1e-10 are set to 0.
    - `group` is an **n×1 cell column of char** (labels from `sampleInformation`, built at line 112).
    - Caveat: `group{j-1}` is only assigned when the sample is found. Missing samples leave `[]` cells, and a trailing missing sample makes `group` shorter than `dataAll`. This is an edge case and probably cannot happen because of the earlier `setdiff` cleanup.
    - The branch is reached only when `length(groups) > 2` and `groupTest = 'ANOVA'` (not the default).
  - **Outputs read:**
    - `p` goes to `Statistics{i,3}` and drives `Statistics{i,5}`, which is later overwritten by FDR.
    - `tbl{2,3}` (Groups df) goes to `Statistics{i,6}`.
    - `tbl{2,2}` (Groups SS) goes to `Statistics{i,7}`.
    - `stats` is not used.
  - The results are written to the Statistics table returned to the caller (and saved by `analyzeMgPipeResults`).

### 1.2 Semantics

- **Syntax:** `anova1(y,group,displayopt)`. For vector y, group is required. 'off' suppresses the table and box plot [DOC-anova1].
- **Table:** `tbl` is a **4×6 cell** [DOC-anova1].
  - Header: `Source | SS | df | MS | F | Prob>F`.
  - Rows: `Groups`, `Error`, `Total`.
  - Empty `[]` cells: F and Prob>F for Error; MS, F and Prob>F for Total.
  - Row label: the doc's grouped example shows `Groups`. R14 used `Columns` for matrix input and `Groups` when a grouping variable is given [R14:anova1.m].
- **Degrees of freedom:** Groups df = k−1, Error df = N−k, Total df = N−1. MS = SS/df [DOC-anova1].
- **F and p:** F = MSgroups/MSE and p = 1 − fcdf(F,k−1,N−k) [R14:anova1.m].
- **Special cases when SSE = 0** [R14:anova1.m]:
  - SSgroups also 0: F = 0 and p = 1.
  - Otherwise: F = Inf and p = 0.
  - Error df = 0: MSE is NaN [R14].
- **NaN:** NaN in y is ignored. Empty or NaN group entries drop the observation [DOC-anova1].
- **Grouping:** via grp2idx [R14:anova1.m], so groups are in first-appearance order for cellstr.
- **stats fields:** gnames, n (row), source = 'anova1', means (row), df, s [DOC-anova1; R14].
- **DOC test value (beam strength):** `anova1(strength,alloy,'off')` gives
  - Groups: SS 184.8, df 2, MS 92.4, F 15.4, p 1.5264e-04
  - Error: SS 102.0, df 17, MS 6.0
  - Total: SS 286.8, df 19

  Data from [DOC-kruskalwallis]:
  - `strength = [82 86 79 83 84 85 86 87 74 82 78 75 76 77 79 79 77 78 82 79]`
  - `alloy` = 8×'st', 6×'al1', 6×'al2'

  [PY] `scipy.stats.f_oneway` on these data gives F = 15.4000, p = 1.52644e-04, which matches.

### 1.3 Base alternative

None. Base MATLAB has no one-way ANOVA.

### 1.4 Proposal

`cobraAnova1(y, group, displayopt)`. Combine it with cobraKruskalwallis in one private engine, the way R14 does: kruskalwallis is anova1 on ranks.

- **Minimal syntax:** `p = cobraAnova1(y,group,'off')`, `[p,tbl,stats] = ...`, with y a vector and group a cellstr, string, numeric or categorical vector.
- Use `cobraGrp2idx` for grouping and `cobraFcdf(F,df1,df2,'upper')` for p.
- Accept `'on'`, but draw nothing or error. Recommendation: accept it, draw nothing, and state this.
- Matrix y is not needed by any call site. Raise an error naming it.

### 1.5 Independent reference

- `scipy.stats.f_oneway(*groups)` for F and p.
- SS, df and MS by hand in numpy: SSg = Σ n_i(ȳ_i − ȳ)², SST = Σ (y − ȳ)².
- DOC beam values above.

### 1.6 UNCONFIRMED

- The current table row label ('Groups' is shown in the doc example, so it is effectively confirmed for grouped input).
- Behaviour with a single group or empty groups (R14: NaN by arithmetic, no error).
- Whether unused categorical categories create empty groups.

---

## 2. kruskalwallis

Doc: https://www.mathworks.com/help/stats/kruskalwallis.html

### 2.1 Call sites

| Site | Call | Inputs | Outputs read |
|---|---|---|---|
| `performStatisticalAnalysis.m:154` | `[p,ANOVATAB] = kruskalwallis(dataAll,group,'off')` | 1×n double row; n×1 cellstr (as §1) | p → Statistics{i,3}; `ANOVATAB{2,6}` (p) compared `==0` → '0'/'1'; `ANOVATAB{2,3}` (df) → col 6; `ANOVATAB{2,5}` (Chi-sq) → col 7 |
| `mgPipe/retrieveModelStats.m:174` | `[p,ANOVATAB] = kruskalwallis(dataAll,group)` (**display on**, then `close all`) | `dataAll = data(:,i)` (column double); `group` is a cellstr column built by `group{j,1}=...` over `modelList`. It can be shorter than dataAll, or contain `[]`, if a model is missing from infoFile. | p; `ANOVATAB{2,6}`, `{2,3}`, `{2,5}`, as above |
| `persephone/runNonparametricTests.m:184` | `[p, tbl, stats] = kruskalwallis(normalizedData, dataGroup.Response, 'off')` | column double, **may contain NaN**; numeric group codes 0..k−1 (from `cobraGrp2idx(...)-1`, line 67) | p; `sum(stats.n)`; `tbl{2,5}` (Chi-sq, also used for η² = (H−k+1)/(n−k)) |
| `persephone/additionalFunctions/dimensionalityReductionAndMultivariateAnalysis.m:189` | `[p_kruskal, tbl_kruskal, ~] = kruskalwallis(PCofInterestScore, ic_namedByCategories)` (**display on**) | column double (PC scores); `categories(ic)` from `unique(metadataTable.(var))`, so cellstr, string **or categorical** | p printed in a figure title (`%.4g`); **the whole `tbl` cell is written to xlsx with `writecell`** (line 205), so labels, empties and header text all matter |

### 2.2 Semantics

- **Syntax:** `kruskalwallis(x,group,displayopt)`. displayopt defaults to `'on'` (table and box plot of the raw data) [DOC-kruskalwallis].
- **group types:** numeric, logical, char, string, cellstr [DOC-kruskalwallis]. Categorical is not listed on the KW page but is listed for anova1. Because KW runs on the anova1 engine [R14:kruskalwallis.m], categorical should work (UNCONFIRMED).
- **Missing values:** NaN in x or group is ignored, and empty group rows are dropped with their x [DOC-kruskalwallis].
- **Table:** a cell with columns `Source | SS | df | MS | Chi-sq | Prob>Chi-sq` and rows for between-groups, `Error`, `Total` [DOC-kruskalwallis].
  - Empty cells: Chi-sq and Prob for Error; MS, Chi-sq and Prob for Total [DOC-kruskalwallis].
  - Row label: `Groups` when a grouping variable is given, `Columns` for matrix input [R14:anova1.m]. The doc's matrix example shows `Columns`.
- **Algorithm** [R14:anova1.m kruskalwallis mode]:
  - Rank all observations with tiedrank (average ranks).
  - Run one-way ANOVA on the ranks: SSg = Σ n_i (r̄_i − r̄)², SST = Σ (r − r̄)², SSE = SST − SSg.
  - H = 12·SSg/(N(N+1)) / (1 − Σ(t³−t)/(N³−N)). This is algebraically equal to **SSg / (SST/(N−1))**.
  - p = 1 − chi2cdf(H, k−1).
- **stats fields:** gnames, n, source = 'kruskalwallis', meanranks, sumt [DOC-kruskalwallis].
  - n and meanranks are row vectors [R14].
  - `sumt` = Σ(t³ − t) (twice tiedrank's tieadj) [R14:anova1.m]. The doc example shows sumt = 0 with no ties.
- **All values tied:** SST = 0, so H = 0/0 = **NaN** and p = NaN (R14 arithmetic). This matters because fluxes that are all zero are common in mgPipe. `ANOVATAB{2,6}==0` is false for NaN, giving '1'. The replacement must return NaN, not 0 or 1.
- **DOC test values:**
  1. Beam data (§1.2): `kruskalwallis(strength,alloy,'off')` gives **p = 0.0018** [DOC-kruskalwallis]. [PY] `scipy.stats.kruskal` gives H = 12.630188, p = 0.0018088 (tie-corrected). This equals SSg/(SST/(N−1)) = 436.40625/(656.5/19), so tie correction is confirmed. The uncorrected H would be 12.46875.
  2. Simulated-data table: Columns SS 7631.1, df 2, MS 3815.5, Chi-sq 25.02, p 3.6896e-06; Error SS 10364, df 57, MS 181.82; Total SS 17995, df 59 [DOC-kruskalwallis]. SST = N(N²−1)/12 = 17995 confirms no ties. The data come from `random(pd,…)` after `rng('default')` and can be regenerated only inside MATLAB.

### 2.3 Base alternative

None.

### 2.4 Proposal

`cobraKruskalwallis(x, group, displayopt)` sharing the engine with cobraAnova1.

- Use a new `cobraTiedrank` (§8) for the ranks and `cobraChi2cdf(H,k−1,'upper')` for p.
- Support vector x with a group given as cellstr, string, numeric or categorical (via `cobraGrp2idx`, which already treats `''`, `""`, `<missing>` and `<undefined>` as missing).
- Accept display `'on'`/`'off'` and draw nothing. Recommendation: document that `'on'` produces no figure. Optionally print the table with disp when 'on'. This is safe for the two 'on' sites (see §0.6).
- tbl must match the full cell layout, because dimRed writes it to xlsx.

### 2.5 Independent reference

- `scipy.stats.kruskal(*groups)` gives H and p (tie-corrected, chi2 sf).
- SS, MS and sumt by hand on `scipy.stats.rankdata` ranks.
- NaN removal: drop NaN before grouping.

### 2.6 UNCONFIRMED

- Current row label 'Groups' vs 'Columns' for grouped input.
- Categorical group acceptance.
- Whether current releases still return NaN when all values are tied.
- Behaviour when `group` is shorter than `x` (MathWorks very likely errors; the retrieveModelStats edge).

---

## 3. ranksum

Doc: https://www.mathworks.com/help/stats/ranksum.html

### 3.1 Call sites

| Site | Call | Inputs | Outputs read |
|---|---|---|---|
| `performStatisticalAnalysis.m:142` | `[p,h,stats] = ranksum(dataGrouped{1},dataGrouped{2},'method','approximate')` | column doubles, unequal lengths in general, many zeros (ties) | p (NaN→1), h (overwritten later), `stats.ranksum` (col 6), `stats.zval` (col 7) |
| `mgPipe/retrieveModelStats.m:156` | same call | column doubles (counts of reactions, metabolites, microbes) | p (NaN→1), h, `stats.ranksum`, `stats.zval` |
| `persephone/runNonparametricTests.m:157` | `[p, ~, stats] = ranksum(group1Data, group2Data)` (**default method**, so exact for small n) | columns, **may contain NaN** (allowed when the NaN fraction is < 0.3) | p; `stats.ranksum`; p is then converted to an effect size via `cobraNorminv(p/2)` |
| `sampling/compareTwoSamplesStat.m:62` | `[p, ~, stat] = ranksum(sample1(j,:), sample2(j,:), 'method','approximate')` | **row** vectors, equal lengths (nSample columns) | p; `-stat.zval` |

### 3.2 Semantics

- **Statistic:** W = rank sum of the **first sample** "for a two-sided test of medians with unequal sample sizes" [DOC-ranksum Algorithms]. In contrast, R14 swapped so that W and z belong to the **smaller** sample [R14:ranksum.m]. This is unresolved; see §0.3.
- **Default method:** `'exact'` if min(nx,ny) < 10 **and** nx+ny < 20, otherwise `'approximate'` [DOC-ranksum; R14 identical].
- **Approximate method** [DOC-ranksum; R14:ranksum.m]:
  - E(W) = nx(N+1)/2, where nx is the size of the sample whose W is reported and N = nx+ny.
  - tiescor = 2·tieadj/(N(N−1)), with tieadj = Σ(t³−t)/2 from tiedrank.
  - Var = nx·ny·((N+1) − tiescor)/12.
  - z = (W − E − 0.5·sign(W−E))/√Var, so the continuity correction moves toward 0, and sign(0) = 0.
  - Two-sided p = 2·Φ(−|z|).
  - `stats.zval` is set only for 'approximate' and is `[]` for 'exact' [DOC-ranksum].
- **All values tied:** W = E exactly, so z = 0/0 = NaN and p = NaN (arithmetic). performStatisticalAnalysis relies on this ("if isnan(p) p=1").
- **Exact method:**
  - The distribution of W is computed over all C(N,nx) subsets of the **midranks** (ties included).
  - Two-sided p = min(2·min(P(W≤w), P(W≥w)), 1) [R14:ranksum.m].
  - R14 enumerated subsets when N ≤ 10 and used a network algorithm (statctexact) otherwise. Both give the same exact distribution.
  - DOC check: `load mileage`, `ranksum(mileage(:,1),mileage(:,2))` gives p = 0.0043, h = 1, ranksum = 21.5, zval = [] [DOC-ranksum]. The data (classic `mileage` set, recalled from memory; confirmed only by reproducing W = 21.5 with one tie at 33.4) are:
    - x = [33.3 33.4 32.9 32.6 32.5 33.0]
    - y = [34.5 34.8 33.8 33.4 33.7 33.9]

    [PY] Full enumeration over midranks gives p = 2·2/924 = **0.0043290**, and `scipy.stats.permutation_test(..., permutation_type='independent', n_resamples=np.inf)` gives the same. The plain normal approximation would give 0.0064. **This confirms exact-with-ties over midranks and the doubling.**
  - Other DOC values: weather `'tail','left','alpha',0.01`: approximate p = 0.1271, zval = −1.1403, ranksum = 837.5; exact p = 0.1273 [DOC-ranksum]. The `weather.mat` data are not available offline.
- **NaN:** "treats NaNs in x and y as missing values and ignores them" [DOC-ranksum]. R14 did **not** remove NaN [R14:ranksum.m], so this changed later. Whether the default method rule uses the counts after NaN removal is UNCONFIRMED (presumably yes).
- **h:** p ≤ alpha (default 0.05) [R14]. It is logical [DOC-ranksum].
- **Inputs:** vectors, row or column, of different lengths. Orientation is irrelevant.

### 3.3 Base alternative

None.

### 3.4 Proposal

`cobraRanksum(x, y, 'method', m)` returning `[p, h, stats]`.

- Support 'method' 'exact' or 'approximate' (plus the default rule), and 'alpha'.
- Raise an error naming 'tail' (no call site uses it).
- Exact method: DP/convolution count of subset sums over **doubled midranks**, which are integers. Counts can be held in double; use log-space or ratios when C(N,nx) is huge, although exact is only chosen by default for N < 20.
- Approximate method: the formula above, with `cobraNormcdf`.
- **Decide W orientation** (first sample per the doc). Make it a single switch so that the parity section can confirm it.

### 3.5 Independent reference

- **Approximate:** `scipy.stats.mannwhitneyu(x, y, alternative='two-sided', use_continuity=True, method='asymptotic')`.
  - Same tie correction, Σ(t³−t)/(N(N−1)).
  - Same continuity correction; scipy uses |U−μ|−0.5. When W = E, scipy gives z < 0 and p clipped to 1, while MATLAB gives z = 0 and p = 1, so p is equal.
  - W_x = U1 + nx(nx+1)/2.
  - z: compute by hand, z_x = (W_x − E − 0.5·sign)/σ.
- **Exact without ties:** `mannwhitneyu(..., method='exact')`.
- **Exact with ties:** scipy's exact ignores ties, so use `scipy.stats.permutation_test((x,y), stat=sum of pooled ranks of x, permutation_type='independent', n_resamples=np.inf, alternative='two-sided')`. Its two-sided value is 2·min(one-sided), capped at 1; verified equal on the mileage case.
- **DOC value:** mileage (above).

### 3.6 UNCONFIRMED

- **Which sample's W and z is returned when nx > ny (current release).** This matters for 3 of the 4 sites.
- NaN removal before the method rule.
- Whether the current exact two-sided value is capped at 1.

---

## 4. ttest2

Doc: https://www.mathworks.com/help/stats/ttest2.html

### 4.1 Call sites

- `compareTwoSamplesStat.m:78`: `[~, pVals.ttest(j,1), tmp, tmpstats] = ttest2(sample1(j,:), sample2(j,:));`
  - Inputs are **row** vectors, so Dim defaults to 2.
  - Reads p and `tmpstats.tstat`. ci (`tmp`) is unused.
- `reconstruction/comparison/modelBorgifier/optimalScores.m:128`: `[~, qual(it,it2)] = ttest2(trunk(trainlabel,it,it2), trunk(~trainlabel,it,it2));`
  - Inputs are **column** vectors (logical-row index on a 3-D array).
  - Reads p only. Downstream: NaN becomes 1, p > 0.1 becomes 1, weight = −log10(p), Inf becomes 0.
  - The call is inside `try/catch`. Without the toolbox it currently falls back silently to default weights, so with a replacement the 'RF' optimizer starts working (a behaviour change worth noting).

### 4.2 Semantics

- **Defaults:** Alpha 0.05, Tail 'both', **Vartype 'equal'**, Dim = first non-singleton [DOC-ttest2].
- **Equal variances** [DOC-ttest2; R14:ttest2.m]:
  - df = nx+ny−2
  - sp = √(((nx−1)sx² + (ny−1)sy²)/df)
  - t = (x̄−ȳ)/(sp·√(1/nx+1/ny))
  - p = 2·tcdf(−|t|, df)
  - stats = struct(tstat, df, sd = sp)
  - ci = (x̄−ȳ) ± tinv(1−α/2,df)·se
- **NaN:** NaN is ignored [DOC-ttest2]. R14 used nanmean/nanvar and per-column counts [R14].
- **Zero pooled sd:** t = ±Inf gives p = 0; if the means are also equal, t = NaN and p = NaN. h is NaN when p is NaN [R14]. optimalScores handles both cases.
- **Vector orientation:** when Dim is not given and both are vectors, y is reoriented to match x [R14].
- **DOC values:** exam grades: p = 0.9867, ci = [−1.9438, 1.9771], tstat = 0.0167, df = 238, sd = 7.7084 [DOC-ttest2]. `examgrades.mat` is not available offline. MATLAB tests can `load examgrades` only if the dataset ships with base MATLAB (UNCONFIRMED; it probably ships with Statistics only).

### 4.3 Base alternative

None as a function. The formula is a few lines using the existing `cobraTcdf`.

### 4.4 Proposal

`cobraTtest2(x, y)` returning `[h, p, ci, stats]`.

- Vectors only, equal-variance, two-sided, alpha 0.05.
- Raise an error naming any name-value option.
- Use `cobraTcdf` and `cobraTinv`.

### 4.5 Independent reference

- `scipy.stats.ttest_ind(x, y, equal_var=True, nan_policy='omit')` for statistic, pvalue and df.
- ci from `res.confidence_interval(0.95)`.
- sd: hand-computed pooled sd.

### 4.6 UNCONFIRMED

Current zero-variance behaviour (assume the IEEE arithmetic, as in R14).

---

## 5. kstest2

Doc: https://www.mathworks.com/help/stats/kstest2.html

### 5.1 Call sites

- `compareTwoSamplesStat.m:48-51`:
  - `[~, pLarger, statLarger] = kstest2(sample1(j,:), sample2(j,:), 0.01, 'larger');`
  - `[~, pSmaller, statSmaller] = kstest2(sample1(j,:), sample2(j,:), 0.01, 'smaller');`
  - These use the **positional alpha and tail** syntax with row vectors. h is unused, so alpha is irrelevant to the outputs read.
  - It keeps the larger statistic: stats.ks = statLarger or −statSmaller, and pVals.ks is the matching p.
- `dataIntegration/fluxomics/score_KS.m:31`: `[h, p] = kstest2(loset(i,:), hiset(i,:));`
  - Default two-sided test, row vectors, inside a `parfor`.
  - `scores(i) = max(log(p), -708)`, so tiny p matter only down to e^-708.

### 5.2 Semantics

- **Statistics** [DOC-kstest2; R14 identical]. F̂ is the fraction of the sample ≤ x, evaluated over the pooled sorted values:
  - 'unequal': max|F̂1−F̂2|
  - **'larger': max(F̂1−F̂2)**
  - **'smaller': max(F̂2−F̂1)**

  One-sided statistics are ≥ 0, because both CDFs are 0 at −∞.
- **p-value (asymptotic only)** [R14:kstest2.m]:
  - n = n1·n2/(n1+n2)
  - λ = max((√n + 0.12 + 0.11/√n)·D, 0)
  - One-sided: p = exp(−2λ²)
  - Two-sided: p = 2·Σ_{j=1}^{101} (−1)^{j−1} exp(−2λ²j²), clipped to [0,1]

  The current doc says the p-value is asymptotic and "reasonably accurate" for n1·n2/(n1+n2) ≥ 4, with no exact method [DOC-kstest2].
- **[PY] verification against the DOC example** (`rng(1)`, `x1 = wblrnd(1,1,1,50)`, `x2 = wblrnd(1.2,2,1,50)`):
  - The doc reports `'Tail','larger'`: p = 0.0158, k = 0.2800, and two-sided `'Alpha',0.01`: p = 0.0317 [DOC-kstest2].
  - With D = 0.28 and n = 25, the Stephens λ = 1.43976 gives one-sided 0.015830 and two-sided 0.031661. **Both match the doc.**
  - SciPy differs: `ks_2samp` exact gives 0.019597/0.039195, and asymp gives 0.014996/0.031677. So the R14 Stephens-modified asymptotic formula is confirmed as current behaviour, and SciPy p-values must **not** be used as the reference.
- **NaN:** removed from each sample. An empty sample after removal is an error [R14]. The current doc is silent.
- **h** = (alpha ≥ p) [R14].
- **Tail values:** 'unequal', 'larger', 'smaller' (case-insensitive), or 0/1/−1 [R14].

### 5.3 Base alternative

None.

### 5.4 Proposal

`cobraKstest2(x1, x2)`, `cobraKstest2(x1, x2, alpha, tail)` (positional, as the call site uses), plus `'Alpha'`/`'Tail'` name-value pairs. Outputs `[h, p, ks2stat]`.

- Compute the empirical CDFs at the pooled sorted values with base `histcounts` or by sorting.
- Use the R14 p formulas exactly, including the 101-term series and the clip.

### 5.5 Independent reference

- Statistic: `scipy.stats.ks_2samp(x1, x2, alternative=...)`.statistic.
  - 'unequal' maps to `'two-sided'`; 'larger' (max F1−F2) maps to `'greater'`; 'smaller' maps to `'less'`. The mapping was verified with x = 0:49, y = x + 14: 'greater' gives 0.28 and 'less' gives 0.
- p: computed by hand in numpy with the Stephens λ. Two-sided: `scipy.stats.kstwobign.sf(λ)`, which equals the 101-term series to ≤1e-12 for λ ≥ 0.05. One-sided: `exp(-2λ²)`.
- DOC numbers above (D = 0.28, n1 = n2 = 50) are usable as fixed inputs: construct x = 0:49, y = 14:63 to obtain D = 0.28. Expected p = 0.015830485828 (one-sided) and 0.031660846052 (two-sided).

### 5.6 UNCONFIRMED

- Whether the current release still accepts `kstest2(x1,x2,alpha,tail)` positional input.
- Current NaN handling.
- For λ < ~0.044 the truncated series is inaccurate before clipping. Reproduce R14 exactly (two-sided D = 0 gives p = 1 through the clip).

---

## 6. hygecdf

Doc: https://www.mathworks.com/help/stats/hygecdf.html

### 6.1 Call sites

- `src/analysis/fluxEnrichmentAnalysis/FEA.m:96`: `gopvalues = hygecdf(allSubsystems' - 1, length(model.rxns), nRxns, length(rxnSet), 'upper');`
  - x is an **m×1 column** (counts − 1; **−1** for subsystems not hit).
  - M is a scalar (number of reactions).
  - K is an **m×1 column** (`histcounts(...)'`).
  - N is a scalar (number of draws).
  - Result: a column of P(X ≥ count).
  - Entries with x = −1 are removed later (`nonZerInd`). `sort` is stable, so their values (NaN or 1) do not change the order of the kept entries.
- `test/verifiedTests/analysis/testFEA/testFEA.m:76`: `expectedPval = hygecdf(X - 1, M, Kpop, N, 'upper');` (scalars).
  - Recommendation: compute the expected value independently, e.g. `sum` of `nchoosek` terms or `exp(gammaln…)`, rather than with the replacement it is testing.
  - Also drop `requiredToolboxes` there; the test currently declares bioinformatics and statistics.

### 6.2 Semantics

- **Arguments:** `hygecdf(x,m,k,n)` and `hygecdf(x,m,k,n,"upper")`. m is the population size, k the number of successes in the population, n the number of draws [DOC-hygecdf].
- **CDF:** F(x) = Σ_{i=0}^{floor(x)} C(K,i)C(M−K,N−i)/C(M,N), so non-integer x is floored [DOC-hygecdf].
- **'upper':** the complement P(X > x), computed "more accurately" in the extreme tail [DOC-hygecdf].
- **Size:** scalar expansion; output size is the common size [DOC-hygecdf].
- **DOC values:**
  - `hygecdf(0:8,100,20,10)` = 0.0951 0.3630 0.6812 0.8904 0.9745 0.9961 0.9996 1.0000 1.0000
  - `hygecdf([7 8],100,20,10,"upper")` = 2.378e-05, 7.9e-07

  [PY] `scipy.stats.hypergeom.cdf/sf` reproduce these: 2.37827e-05 and 7.86904e-07.
- **Invalid input** [R14:hygecdf.m]: NaN for any of these: negative M, K or N; **negative x**; non-integer M, K or N; K > M; N > M; **x > K or x > N** (bounds checked on the unfloored x). R14 has no 'upper' option.
  - The current doc says only that inputs are nonnegative, with x ≤ n, m, k.
  - The current value for x < 0 under 'upper' is UNCONFIRMED: R14 logic would give NaN, the mathematical value is 1. FEA's output is unaffected either way.

### 6.3 Base alternative

None.

### 6.4 Proposal

`cobraHygecdf(x, M, K, N)` and `cobraHygecdf(..., 'upper')`.

- Use scalar expansion.
- PMF via `exp(gammaln …)` (log-binomials). Sum the lower terms 0..floor(x) for the cdf, or the upper terms floor(x)+1..min(K,N) directly for 'upper' (this keeps tail accuracy).
- Invalid parameters give NaN.
- x outside the support: choose and document one of the following.
  - Option A, R14: NaN for x < 0 or x > min(K,N).
  - Option B, mathematical: cdf 0/1 and upper 1/0.

  Recommendation: follow the mathematical definition for x < 0 (it is FEA's case) and state it as UNCONFIRMED. The parity section settles it.

### 6.5 Independent reference

`scipy.stats.hypergeom.cdf(x, M, K, N)` and `.sf(x, M, K, N)` (SciPy argument order: M = total, n = successes, N = draws). Plus the DOC values above.

### 6.6 UNCONFIRMED

Current out-of-support behaviour (x < 0, x > K or N), and the exact 'upper' algorithm.

---

## 7. mafdr (Bioinformatics)

Doc: https://www.mathworks.com/help/bioinfo/ref/mafdr.html

### 7.1 Call sites

| Site | Call | Input | Outputs |
|---|---|---|---|
| `FEA.m:117` | `mafdr(cell2mat(resultCell(2:end,1)), 'BHFDR', true)` | column of p-values, possibly **empty** (0×1) | FDR column → cell column |
| `dimensionalityReductionAndMultivariateAnalysis.m:274` | `FDR = mafdr(pValues, 'BHFDR', true)` | table column `generalTable.pValue`, which **contains NaN** for regressions that warned (line 255) | stored in the table and written to csv |
| `performStatisticalAnalysis.m:188` | `fdr = mafdr(pAverages,'BHFDR', BHFDR)` when BHFDR is true | column (cell2mat of column 3; NaN p was already replaced by 1 for ranksum; KW/ANOVA p may still be NaN) | fdr → column 4 |
| `performStatisticalAnalysis.m:191` | **`[fdr,q] = mafdr(pAverages,'BHFDR', false)`**: Storey default, `'Method','bootstrap'`, default Lambda. This is **the default path** (BHFDR defaults to false; analyzeMgPipeResults never sets it). | column | **q** → column 4 → significance decision (< 0.05) → `significantFeatures` |

- `runNonparametricTests.m:202` already calls `fdrBHadjustment` in place of `mafdr(...,'BHFDR',true)`, as do `performRegressions.m:233` and `findPvalCategories.m:24`.

### 7.2 Semantics

- **Syntaxes:** `FDR = mafdr(P)`, `[FDR,Q] = mafdr(P,...)`, `[FDR,Q,aPrioriProb] = ...`, `[...,R_squared]` (only with 'polynomial') [DOC-mafdr].
- **'BHFDR',true:** Benjamini-Hochberg (1995) linear step-up. 'Method' and 'Lambda' are ignored, and **only one output is allowed** [DOC-mafdr]. The formula is not printed on the page. The standard BH adjusted value is min_{j≥i} min(1, m·p_(j)/j), which is what `fdrBHadjustment` implements: sort, multiply by m/i, cumulative minimum from the top, cap at 1, unsort.
- **Default (Storey)** [DOC-mafdr]:
  - FDR = the positive FDR (pFDR) for each p-value (Storey 2002); Q = q-values.
  - Lambda default `[0.01:0.01:0.95]`. A scalar Lambda is used directly and Method is ignored.
  - Method default **'bootstrap'**, alternative 'polynomial' (cubic polynomial fit of π̂0(λ), with R²).
  - The doc gives **no formulas**.
- **Input:** a column vector or DataMatrix, double. FDR is a column for column input; Q is a column [DOC-mafdr]. NaN handling is not documented.
- **Storey estimators** [STOREY02 §3, Algorithms 1-3]:
  - π̂0(λ) = W(λ)/((1−λ)m), with W = #{p > λ}.
  - Pr(P ≤ γ) is estimated as max(R(γ),1)/m, with R = #{p ≤ γ}.
  - pFDR_λ(γ) = π̂0(λ)·γ / (Pr(P≤γ)·{1−(1−γ)^m}).
  - q̂(p_(m)) = pFDR(p_(m)), and q̂(p_(i)) = min(pFDR(p_(i)), q̂(p_(i+1))).
  - λ is chosen by bootstrap: B resamples of the p-values with replacement, MSE(λ) = (1/B)Σ_b [pFDR*_b,λ − min_λ' pFDR_λ'], λ̂ = argmin. The paper's simulations use B = 500.
  - Storey, Taylor & Siegmund (2004), also cited by the doc, apply the same idea to π̂0 directly.
- **What mafdr does exactly is UNCONFIRMED:**
  - Whether the 1−(1−γ)^m factor is included.
  - Bootstrap on pFDR or on π̂0.
  - Value of B, and how pFDR above 1 or π̂0 above 1 is clipped. A MathWorks Answers thread confirms that a helper `bootstrapchooser` called from `storeyFDR` warns "estimated PI0 is greater than 1" and sets PI0 = 1. Staff called it a bug fixed in R2012b: https://se.mathworks.com/matlabcentral/answers/44824
  - Run-to-run variation (evidence that the bootstrap uses random numbers): a user reports mafdr giving different pFDR values on re-runs (https://in.mathworks.com/matlabcentral/answers/53038, unanswered). The randomness is therefore likely but UNCONFIRMED.
- **fdrBHadjustment vs mafdr BH:**
  - Exact for finite p in [0,1] (same formula; [PY] `scipy.stats.false_discovery_control([0.01,0.04,0.03,0.005])` = [0.02 0.04 0.04 0.02]).
  - Differences: it **always returns a column** (mafdr returns a column for column input, which is what all call sites pass, so no difference there).
  - NaN: it counts NaN in m and returns NaN at NaN positions, because the NaNs sort last and `min(q,NaN)` ignores them. mafdr's NaN behaviour is UNDOCUMENTED, which matters for the dimRed site.
  - Empty input gives `zeros(0,1)`, which is fine for FEA.
  - **Every BHFDR call site passes `'BHFDR', true`, except performStatisticalAnalysis, whose default uses Storey.**

### 7.3 Base alternative

- `fdrBHadjustment(p)` is exact for the BHFDR = true sites (FEA:117, dimRed:274, performStatisticalAnalysis:188). It lives in `src/analysis/persephone/`. Moving or copying it is a plan decision; it is already on the path.
- There is **no** base or existing equivalent for the Storey default (performStatisticalAnalysis:191).

### 7.4 Proposal

- **(a)** Substitute `fdrBHadjustment` at the BH sites (FR-002). Record the NaN-counting choice as UNCONFIRMED vs mafdr.
- **(b)** Add a new `cobraMafdr(p, 'BHFDR', tf)` returning `[FDR, Q]` (and optionally 'Lambda', 'Method'). For BH it delegates to the same formula. For Storey it implements [STOREY02] eq. (9), Algorithm 2 for q, and bootstrap λ selection (Algorithm 3) with a stated B, drawing through `rand`/`randi` so that `rng` seeds make it reproducible.
- Parity with MathWorks can only be distributional or within tolerance, and the plan must say so (spec Acceptance 3 allows "otherwise the same distribution"; FR-006).
- **Maintainer decision required:** accept a documented Storey re-implementation (with a deterministic scalar-λ path testable exactly), or another approach. Changing performStatisticalAnalysis's default to BH would break Principle II.

### 7.5 Independent reference

- BH: `scipy.stats.false_discovery_control(p, method='bh')` or `statsmodels.stats.multitest.multipletests(p, method='fdr_bh')[1]`.
- Storey: no SciPy or statsmodels implementation. statsmodels' `fdr_tsbh` is a different two-stage BH. A hand numpy reference must compute π̂0(λ) for a **fixed scalar λ**, pFDR by eq. (9) and q by Algorithm 2. That is the only exactly testable Storey path.
- Bootstrap: test the properties instead (λ̂ ∈ grid, π̂0 ≤ 1, q monotone in p, reproducible for a fixed seed).

### 7.6 UNCONFIRMED

The whole mafdr Storey algorithm:
- whether 1−(1−γ)^m is used;
- bootstrap target and B;
- random source;
- clipping;
- NaN handling;
- the BH result when NaN are present.

---

## 8. tiedrank

Doc: https://www.mathworks.com/help/stats/tiedrank.html

### 8.1 Call sites

- `src/analysis/persephone/analyseWBMsol.m:237`: `convToRank = @(x) array2table(tiedrank(table2array(x)), 'RowNames',..., 'VariableNames',...)`, applied with `cellfun` to two tables (fluxes and relative abundances).
  - Input: **samples×variables double matrix with NaN** (later correlated with `corrcoef(...,'Rows','pairwise')`).
  - Output: the rank matrix, same size. Only the first output is used.
  - The block sits **inside `if license('test','Statistics_Toolbox')`** (line 205). See §0.2.

### 8.2 Semantics

- **Shape:** for a matrix, ranks each column; R is the same size as X [DOC-tiedrank].
- **Ties:** average ranks. Example: `tiedrank([-2 1 3 1 4])` = [1 2.5 4 2.5 5], with tieadj = 3 [DOC-tiedrank]. [PY] `scipy.stats.rankdata` gives the same.
- **NaN:** "treated as missing and ignored"; the rank of each NaN is NaN [DOC-tiedrank]. The non-NaN values get ranks 1..n_nonNaN within their column [R14:tiedrank.m].
- **tieadj** [R14]:
  - default: Σ(t³−t)/2 per column (1×ncol);
  - tieflag = 1: [Σt(t−1)/2; Σt(t−1)(t−2); Σt(t−1)(2t+5)]. DOC example: [1;0;18].
  - bidir (`tiedrank(X,0,1)`) exists in current releases [DOC-tiedrank], not in R14.

### 8.3 Base alternative

- None in base MATLAB.
- `cobraCorr`'s local `columnTies` (src/base/utilities/toolboxFree/cobraCorr.m:363) computes average ranks but gives **NaN for the whole column if any NaN is present**, so it is **not** reusable for this call site.

### 8.4 Proposal

`cobraTiedrank(X)` returning `[R, tieadj]`.

- Vector or matrix, column-wise, NaN ranked as NaN, default tieadj only.
- Raise an error naming tieflag/bidir if passed.
- cobraRanksum and cobraKruskalwallis can use it. cobraCorr could optionally be refactored to use it, but that is not required.

### 8.5 Independent reference

- `scipy.stats.rankdata(X, method='average', axis=0, nan_policy='omit')`, which returns NaN at NaN positions (SciPy ≥ 1.10).
- tieadj by hand.
- DOC example above.

### 8.6 UNCONFIRMED

None material.

---

## 9. geomean

Doc: https://www.mathworks.com/help/stats/geomean.html

### 9.1 Call sites

- `thermo/vonBertalanffy/estimateDfGt0.m:196`: `log(geomean([model.concMin, model.concMax], 2))`. Input is nMet×2, positive concentrations; output nMet×1.
- `thermo/vonBertalanffy/estimateDrGt0.m:151`: same expression.
- `igemRNA/modelCreation/createContextSpecificModel.m:91` and `:127`: `round(geomean(andsToCompare))` and `round(geomean(numbersToCompare))`.
  - Input is a row vector of transcript values (possibly empty).
  - **These branches call the undefined `findTranscriptionValue`** (§0.5), so they cannot run today.

### 9.2 Semantics

- **Definition:** (Πx)^(1/n). X is documented as "nonnegative". Supports dim, 'all', vecdim, nanflag (default 'includenan') [DOC-geomean].
- **Algorithm** [R14:geomean.m]:
  - exp(sum(log(x),dim)/n), with the log-of-zero warning suppressed, so 0 gives 0;
  - **negative input → error `stats:geomean:BadData`**;
  - empty dim → NaN;
  - NaN → NaN;
  - Inf → Inf.

  Current error behaviour is UNCONFIRMED (doc silent).
- **DOC values:**
  - `geomean(reshape(1:40,[2 5 4]),'all')` = 15.7685
  - `x = 1:10; x(3) = NaN; geomean(x,'omitnan')` = 4.7408

  [PY] `scipy.stats.gmean` gives 15.768527 and 4.740772.

### 9.3 Base alternative

`exp(mean(log(x), dim))`:
- exact for nonnegative input at these sites (n = 2, or a short row);
- for empty input it gives NaN, matching R14.

Differences:
- negative input gives a complex number instead of an error;
- `mean` vs `sum/n` can differ in the last bit only for long or multithreaded reductions, which is irrelevant at n = 2.

Concentrations are positive (log of concMin and concMax is already taken on lines 192-193 of estimateDfGt0), so the substitution is exact there.

### 9.4 Proposal

- **Base substitution**, `exp(mean(log(x), dim))`, at the thermo sites.
- For createContextSpecificModel, use the same substitution (dead code). Optionally add a guard that errors on negative values to keep MathWorks' error. If the plan prefers a function, a tiny `cobraGeomean(x, dim)` that errors on negatives is the alternative.

### 9.5 Independent reference

`scipy.stats.gmean(x, axis=…)` plus the DOC values.

### 9.6 UNCONFIRMED

Current negative-input behaviour.

---

## 10. normrnd

Doc: https://www.mathworks.com/help/stats/normrnd.html

### 10.1 Call sites

- `transcriptomics/eFlux/eFlux.m:50`: `normFun = @(mean,std) normrnd(mean,std);`. This is the **default of the public `'noiseFun'` parameter**.
  - It is called at line 105 as `arrayfun(@(x) noiseFun(0,x), columnVector(noiseStd))`, one scalar draw per element.
  - sigma = `std(controlData.values')` or a user `noiseStd`, which can be 0.
- `transcriptomics/SWIFTCORE/core.m:33`: `dense(blocked == 1) = normrnd(0, 1, [sum(blocked), 1]);` produces a k×1 column used as LP objective coefficients for blocked reactions.

### 10.2 Semantics

- **Syntax and size:** `normrnd(mu,sigma)`, `normrnd(mu,sigma,sz)` with scalar expansion.
- **sigma = 0:** "If sigma is zero, then the output r is always equal to mu" [DOC-normrnd].
- **Algorithm (confirmed numerically from the doc):** `normrnd = mu + sigma .* randn(sz)`, in column-major order.
  - After `rng('default')`, `normrnd(0,1)` = 0.5377, and `normrnd(0,1,size([3 2;-2 1]))` = [0.5377 −2.2588; 1.8339 0.8622]. These are the first values of `randn` after `rng('default')` (0.5377, 1.8339, −2.2588, 0.8622, 0.3188).
  - `normrnd(3,10,[1,5])` from the default state = 8.3767 21.3389 −19.5885 11.6217 6.1877 = 3 + 10·(0.5377, 1.8339, −2.2588, 0.8622, 0.3188) [DOC-normrnd].
  - R14 code used `randn(sz).*sigma + mu`, with sigma < 0 giving NaN (R14; current UNCONFIRMED). Multiplication and addition are commutative in IEEE arithmetic, so `mu + sigma.*randn` is bitwise identical.
- **sigma < 0:** not documented (R14: NaN).

### 10.3 Base alternative

`randn`, which is exact for the same seed:
- `core.m`: `randn(sum(blocked), 1)`, exactly equal to `normrnd(0,1,[k,1])`.
- `eFlux.m`: `@(mean,std) mean + std .* randn()`, exactly equal for std ≥ 0. Note that sigma = 0 still consumes one randn draw in both, as R14 always called randn for the full size.

### 10.4 Proposal

- **Direct base substitution** (FR-002).
- In eFlux the default handle changes text but not behaviour. For std < 0 it gives mean − |std|·z instead of NaN; that input is impossible because std() is ≥ 0. If NaN fidelity for sigma < 0 is wanted, write `@(m,s) m + s.*randn() ./ (s >= 0)`, but this is not recommended (it is clutter).

### 10.5 Independent reference

- Python cannot reproduce MATLAB's randn stream (Ziggurat on mt19937ar).
- Use the DOC numbers above in a MATLAB test: `rng('default'); r = <replacement>` and compare with 0.5377 and 8.3767 … to 4 decimals. Also check equality with `mu + sigma*randn` under the same seed.

### 10.6 UNCONFIRMED

sigma < 0 in current releases.

---

## 11. randsample (tests only)

Doc: https://www.mathworks.com/help/stats/randsample.html

### 11.1 Call sites

All are in tests; none are in src.

- `test/verifiedTests/dataIntegration/testSWIFTCORE/testSWIFTCORE.m:36`: `core = randsample(n, round(n/2));`. The result is used as an index set (`coreInd(core)`, `swiftcore(model, core, …)`). No seed is set, and no assertion depends on which indices are drawn.
- `test/verifiedTests/visualization/testSammi/testSammi.m:151, 156, 186`: `rxntbl(randsample(N, k)) = NaN` with k = N/10 or 0.5·nMets. It runs after `rng(734)` (line 31). The test only asserts that the output file exists.
- Also `test/tutorialDerived/visualization/SAMMIM/tutorial_Sammi.m:127, 132` (tutorial-derived; not in the scan list).
- Requirements: testSWIFTCORE declares `'requiredToolboxes', {'statistics_toolbox'}` (line 13); testSammi does the same (line 19).

### 11.2 Semantics

- `randsample(n,k)`: k values without replacement from 1:n. Output is a **k×1 column** (scalar for k = 1) [DOC-randsample].
- The algorithm is **not documented** [DOC-randsample]. R14 [R14:randsample.m]:
  - if 4k > n: `randperm(n)`, then the first k values;
  - otherwise: rejection sampling with `ceil(n*rand(...))`, followed by `randperm(k)` shuffling.

  Whether the current release uses `randperm(n,k)` is UNCONFIRMED. So same-seed equality is unattainable as documented behaviour.

### 11.3 Base alternative

`randperm(n, k)'`. It has the same distribution (uniform k-subset in random order) and a column orientation after transposing.

### 11.4 Proposal

Direct base substitution in the three test files (and optionally the tutorial copy), then remove the Statistics requirement. No new function: FR-006 only asks for same draws "where the MathWorks algorithm is documented", and it is not documented.

### 11.5 Independent reference

None needed. If a check is wanted: uniqueness, range 1..n, size k×1.

### 11.6 UNCONFIRMED

The current randsample algorithm.

---

## 12. ksdensity

Doc: https://www.mathworks.com/help/stats/ksdensity.html

### 12.1 Call sites

- `src/analysis/KLdistance/KLdistance.m:34, 35, 47, 48`: `[fWT, ~] = ksdensity(col)`.
  - Input: column vector (one parameter's values for one group).
  - Only f (100 values) is used, passed to `KLDis(fMUT, fWT)`. Each f is on its **own** grid.
- `src/dataIntegration/transcriptomics/rFASTCORMICS/discretizeFPKM.m`:
  - `:88` `[probability_estimate, xi] = ksdensity(signal_sample)` (column of log2 FPKM).
    - Results drive the thresholds: `find(f == max(f(50:100)))` **requires exactly 100 points**.
    - `[max_l_side(1:end-1), max_r_side]` **requires row orientation**.
    - `probability_estimate - hybrid_curve_r'` produces a row.
    - The values are fed to `createFitR`/`createFitL` (Curve Fitting, another group).
    - **This site determines the discretisation output, so bandwidth and grid must match MathWorks to rounding.**
  - `:193` `[yFPKM, xFPKM] = ksdensity(zFPKM)` (plot only, under figflag; it is computed unconditionally).
  - `:260`, `:287` (plots only, under figflag).

### 12.2 Semantics

- **Defaults:** normal kernel, Support 'unbounded', 100 points that "cover the range of the data", Bandwidth "normal-approx" (Silverman's rule of thumb, "optimal for estimating normal densities", citing Bowman & Azzalini). The MAD basis is implied by the tall-array note "standard deviation (instead of median absolute deviation)" [DOC-ksdensity].
- **Exact formulas (R14; current UNCONFIRMED but consistent with the doc wording)** [R14:ksdensity.m]:
  - NaN removed; n = count of the rest.
  - σ = median(|x − median(x)|)/**0.6745** (the literal constant, not norminv(0.75)).
  - If σ ≤ 0: σ = max − min.
  - If σ > 0: **h = σ·(4/(3n))^(1/5)**, otherwise h = 1.
  - Grid: **xi = linspace(min(x) − 3h, max(x) + 3h, 100)**. The cut-off is 3 for the normal kernel (k = min(cutoff 4, 3)).
  - f(xi) = (1/n)·Σ φ((xi − x_i)/h)/h.
  - xi and f are **row vectors** for the default call.
- **DOC check value:** `rng('default'); x = [randn(30,1); 5+randn(30,1)]; [f,xi,bw] = ksdensity(x)` gives **bw = 1.5141** [DOC-ksdensity]. This can be reproduced in a base-MATLAB test because rng and randn are base functions. It verifies the bandwidth formula, but not the grid.

### 12.3 Base alternative

None.

### 12.4 Proposal

`cobraKsdensity(x)` returning `[f, xi, bw]`.

- Default call only: unbounded support, normal kernel, 100 points, row outputs.
- Raise an error naming any option, or the pts argument.
- Evaluate with an n×100 broadcast (memory note: n can be ~20k genes, giving 2M doubles, which is fine) or in blocks.

### 12.5 Independent reference

- `scipy.stats.gaussian_kde(x, bw_method=h/np.std(x, ddof=1))` evaluated at `np.linspace(x.min()-3h, x.max()+3h, 100)`. gaussian_kde's kernel sd = factor·std(ddof=1), so this choice makes the kernel sd exactly h. Its default (Scott, n^(−1/5)·std) is **different** and must not be used.
- h by hand: `scipy.stats.median_abs_deviation(x, scale=1.0)/0.6745*(4/(3*n))**0.2`.
- DOC bw = 1.5141 (MATLAB-side only).

### 12.6 UNCONFIRMED

- The current grid rule (±3h) and the 0.6745 literal. The bw example confirms h only.
- Behaviour when MAD = 0 (σ fallback).

---

## 13. cmdscale

Doc: https://www.mathworks.com/help/stats/cmdscale.html

### 13.1 Call sites

- `mgPipe/plotMappingInfo.m:102` and `:170`: `[Y, eigvals] = cmdscale(D)`.
  - D = `cobraPdist(reactionPresence, 'jaccard')`, a **1×m pdist row vector**. It may contain NaN when two rows are all zero (§9 of the first-slice note).
  - Uses: `Y(:,1)`, `Y(:,2)`, `size(Y,2)`, `isempty(Y)`, `P = [eigvals eigvals/max(abs(eigvals))]` (unused), and `expr = eigvals/sum(eigvals)` (axis labels, rounded to 2 dp of a percentage).
  - Figures are printed to files.
- `mgPipe/mgSimResCollect.m:123`: `[Y, eigvals] = cmdscale(JD)` with JD = `cobraPdist(fSpOld','euclidean')`.
  - Same uses, plus `text(Y(:,1),Y(:,2),…)`.
  - **Guarded by `if ~license('test','Statistics_Toolbox') noPcoa = 1`** (line 115).
- `persephone/.../dimensionalityReductionAndMultivariateAnalysis.m:96`: `[PCscores, eigvals] = cmdscale(measuresMatrix)`.
  - Input: a **full square** beta-diversity matrix from `table2array`, possibly non-Euclidean, so negative eigenvalues are possible.
  - `explVar = eigvals/sum(eigvals)*100` is plotted. `PCscores(:,1:2)` is plotted.
  - `PCscores(:,PCofInterest)` feeds kruskalwallis (sign-invariant p) and `fitlm`. **The slope estimate's sign depends on the eigenvector sign** and is written to csv.

### 13.2 Semantics

- **D forms:** full n×n, or a row vector of length n(n−1)/2 (upper triangle; pdist output), converted by squareform. Similarity matrices (ones on the diagonal) are converted with sqrt(1−S) [DOC-cmdscale; R14].
- **Columns of Y:** "the number of positive eigenvalues of Y*Y'" [DOC-cmdscale].
- **e:** the column of **all n** eigenvalues, displayed in descending order, including negatives [DOC-cmdscale example: 624.6469 … −5.6586].
- **Algorithm** [R14:cmdscale.m]:
  - Input checks: must be nonnegative and symmetric within ~10·eps·max; a vector must have an integer n.
  - B = P(−½ D∘D)P, with P = I − 11ᵀ/n.
  - `eig` of (B+Bᵀ)/2.
  - Sort descending.
  - Keep eigenvalues with e > max|e|·eps^(3/4).
  - Y = V_keep·diag(√e_keep).
  - **If none are kept, Y = zeros(n,1)** (never empty).
  - No sign normalisation (whatever eig returns).
- **NaN in D:** R14 does not reject NaN through the nonnegativity check, but `eig` errors on NaN (inference).
- **DOC test values (US cities, 10×10 D listed on the page)** [DOC-cmdscale]:
  - **e/1e6** = 9.5821 1.6868 0.0082 0.0014 0.0005 0.0000 0.0000 −0.0009 −0.0055 −0.0355
  - Y is 10×6, displayed ×1e3. First row: −0.7188 0.1430 0.0351 −0.0012 −0.0074 0.0015.
  - MaxRelDiff of the 2-D reconstruction = 0.0075.
- **Second DOC case:** `rng(0,"twister"); A = [normrnd(0,1,10,3), normrnd(0,0.1,10,1)]; B = randn(4,4); X = A*B; D = pdist(X,"cityblock")` gives e = 624.6469 8.0643 6.7448 1.3965 1.0377 0.6631 −0.0000 −0.0685 −0.6633 −5.6586. This is reproducible in base MATLAB with randn (normrnd = mu + sigma·randn, §10) and a hand cityblock distance (cobraPdist has no 'cityblock').

### 13.3 Base alternative

None as a function. It is ~15 lines with `eig`.

### 13.4 Proposal

`cobraCmdscale(D)` returning `[Y, e]`.

- Accept a pdist row vector or a full matrix, single or double.
- Similarity handling as in R14.
- Raise an error naming the `p` argument (unused).
- Same `eig` call on (B+Bᵀ)/2 so that signs match MATLAB on the same platform, but **tests must compare Y up to column sign**.

### 13.5 Independent reference

- numpy hand computation: B as above, `np.linalg.eigh`, sort descending, same keep rule, Y = V·sqrt(e). Compare |Y| or Y·sign.
- scikit-learn's `MDS` is SMACOF, not classical, so it is **not** a reference. scikit-bio `pcoa` is not installed.
- DOC US-cities values.

### 13.6 UNCONFIRMED

- Whether current cmdscale still uses full `eig` (sign parity) and the eps^(3/4) threshold.
- Behaviour for a 0-length vector (one sample).
- NaN input.

---

## 14. confusionmat

Doc: https://www.mathworks.com/help/stats/confusionmat.html

### 14.1 Call sites

| Site | Call | group / grouphat | Use |
|---|---|---|---|
| `dataIntegration/modelPredictiveCapacity.m:603, 627, 654` | `confusionmat(fullReport.target(rows), fullReport.predict(rows), 'ORDER', [1, 0, -1])` | numeric columns. target ∈ {−1,0,1} (NaN rows removed via `~isnan(target)`); predict = sign(v), can be NaN if v is NaN | `sum(diag(C))/sum(C(:))` → qualAccuracy |
| `XomicsToModel/analysis/quanQualAcc.m:128` | `confusionmat(fullReport.target, fullReport.predict, 'ORDER', [2,1,0,-1])` | numeric; NaN target **not** filtered here, so missing rows are excluded | accuracy |
| `XomicsToModel/thermoKernel/plotThermoKernelExtractStats.m:65` | `confusionmat(T,P,'order',{'Active';'Inactive';'Unspecified'})` | cellstr. **Dead code**: the branch is inside `if 0` (line 50) | plotConfMat |
| `plotThermoKernelExtractStats.m:108, 154` | `confusionmat(P,T,'order',labels)`, labels = `{'Active';'Inactive'}` | cellstr columns. P (prediction) is passed as `group` and T (input weights) as `grouphat`, so **rows are the model output**. T may contain `''` cells (e.g. NaN weights), which are treated as missing | `plotConfMat(C,labels)`; accuracy in the title |
| `plotThermoKernelStats.m:55, 80, 103, 127` | `confusionmat(P,T,'order',labels)`, labels = `{'Active';'Inactive'}` | cellstr | plotConfMat; accuracy |

- The option name is given as `'ORDER'` and as `'order'`, so matching must be case-insensitive.

### 14.2 Semantics

- **C(i,j):** the count known to be in group i and predicted in j, so rows = group (1st argument) and columns = grouphat [DOC-confusionmat].
- **Default order:** numeric is sorted ascending over [group; grouphat]; logical is false then true; categorical follows categories; char, string and cellstr follow **first appearance** [DOC-confusionmat].
- **Missing:** NaN, empty and 'undefined' in either input are treated as missing and excluded. The observation is dropped [DOC-confusionmat].
- **'Order':** "containing all the distinct elements in group and grouphat". Elements not present give zero rows and columns [DOC-confusionmat]. Whether omitting a present value is an error is **not documented** (likely an error; UNCONFIRMED).
- **group and grouphat** must have the same type and length [DOC-confusionmat].
- **Outputs:** the class of C is not stated (double assumed). `order` is a column; cellstr for text input [DOC-confusionmat].
- **DOC values** [DOC-confusionmat]:
  - `g1 = [3 2 2 3 1 1]'`, `g2 = [4 2 3 NaN 1 1]'` gives `[2 0 0 0; 0 1 1 0; 0 0 0 1; 0 0 0 0]`, order 1:4.
  - The same with `'Order',[4 3 2 1]` gives `[0 0 0 0; 1 0 0 0; 0 1 1 0; 0 0 0 2]`.

### 14.3 Base alternative

None exact as a function. It reduces to `accumarray` on indices from `ismember(...)`. The call sites read only the full C, so a small function is cleanest.

### 14.4 Proposal

`cobraConfusionmat(g, ghat, 'Order', order)` returning `[C, order]`.

- Types: numeric, logical, cellstr, string, categorical.
- Remove missing values: NaN, `''`, `<missing>`, `<undefined>`. `cobraGrp2idx` already defines these.
- Error naming any present level absent from 'Order', or match MathWorks once confirmed.

### 14.5 Independent reference

- `sklearn.metrics.confusion_matrix(y_true, y_pred, labels=order)` (rows true, columns predicted).
- **Differences:** sklearn silently ignores values not in `labels`, and does not treat NaN or `''` as missing. The reference script must drop missing pairs first.
- DOC numeric examples above.

### 14.6 UNCONFIRMED

The error for incomplete 'Order', and the class of C.

---

## 15. dataset (+ export)

Docs: https://www.mathworks.com/help/stats/dataset.html and https://www.mathworks.com/help/stats/dataset.export.html

### 15.1 Call site

`src/dataIntegration/fluxomics/c13solver/generateIsotopomerSolver.m:86` and `:91`:

```matlab
isotopomer = dataset(Isotopomer_Info);
export(isotopomer,'file',strcat(xdir,'IsotopomerModel.txt'),'WriteVarNames',false);
```

- `Isotopomer_Info` is an **N×1 cell column of char rows**: the input metabolite, then the isotopomer lines (split on '!'), then '!!Measured Metabolites!!' and the fragment lines.
- The text file is read line by line by the Perl scripts in `external/dataIntegration/fluxomics/c13solver/`. `generatorEMU.pl` reads the first line with `chomp` as the known carbon source and compares it exactly, then splits each line on `\s+`.
- A trailing delimiter, quoting or a header line would corrupt the parse.
- Reached from `testFitC13Data` (no toolbox requirement declared; see §0.5).

### 15.2 Semantics

- `dataset` is "not recommended"; "use the MATLAB table data type instead" [DOC-dataset].
- **export defaults** [DOC-dataset.export]:
  - tab-delimited;
  - `WriteVarNames` true by default, set to false here;
  - `WriteObsNames` true by default, but this dataset has no ObsNames, so nothing is written;
  - character variables written "as unquoted text";
  - a cell is written only when it contains a single row (otherwise a single empty field);
  - existing files are overwritten.
- One variable gives one field per line, so each line is exactly the string. Line endings and any trailing delimiter are UNCONFIRMED (no trailing delimiter is expected with one variable).

### 15.3 Base alternative

```matlab
fid = fopen(file,'w'); fprintf(fid, '%s\n', Isotopomer_Info{:}); fclose(fid);
```

- Writes each string unquoted, one per line. An empty cell gives an empty line, consistent with export's "single empty field".
- The `table` route the spec mentions (FR-002) works only with `writetable(T, file, 'WriteVariableNames', false, 'Delimiter', '\t', 'QuoteStrings', false, 'FileType', 'text')`. **writecell or writetable defaults quote strings that contain the delimiter** (comma by default for .txt), which risks altering lines. fprintf is simpler and exact.

### 15.4 Proposal

Direct base substitution with fopen/fprintf. Mention `table` in the justification as the documented successor, but not needed.

### 15.5 Independent reference

- Compare the file content with the expected lines (byte-exact) in a MATLAB test on a tiny model, or compare the old export output when Statistics is installed (parity section).
- No Python reference is needed.

### 15.6 UNCONFIRMED

export's line terminator (`\n` assumed; Perl `chomp` would leave a `\r` on CRLF).

---

## 16. Summary table

| Function | Approach | Reuses | Python reference |
|---|---|---|---|
| anova1 | new `cobraAnova1` (shared engine) | cobraGrp2idx, cobraFcdf | scipy.stats.f_oneway + hand SS |
| kruskalwallis | new `cobraKruskalwallis` | cobraTiedrank, cobraGrp2idx, cobraChi2cdf | scipy.stats.kruskal + hand SS |
| ranksum | new `cobraRanksum` | cobraTiedrank, cobraNormcdf | mannwhitneyu(asymptotic, continuity); permutation_test exact for ties |
| ttest2 | new `cobraTtest2` | cobraTcdf, cobraTinv | scipy.stats.ttest_ind(equal_var=True) |
| kstest2 | new `cobraKstest2` (positional + name-value) | — | ks_2samp statistic only; hand Stephens p (kstwobign.sf for two-sided) |
| hygecdf | new `cobraHygecdf` | — | scipy.stats.hypergeom.cdf/sf |
| mafdr | **BH sites → existing `fdrBHadjustment`**; Storey default → new `cobraMafdr` (maintainer decision on parity) | fdrBHadjustment | false_discovery_control / multipletests fdr_bh; Storey by hand (fixed λ) |
| tiedrank | new `cobraTiedrank` | — | scipy.stats.rankdata(nan_policy='omit') |
| geomean | **base** `exp(mean(log(x),dim))` | — | scipy.stats.gmean |
| normrnd | **base** `mu + sigma.*randn(...)` (bit-exact for the seed) | — | DOC numbers in MATLAB |
| randsample | **base** `randperm(n,k)'` (tests only) | — | — |
| ksdensity | new `cobraKsdensity` (default call only) | — | gaussian_kde(bw_method=h/std(ddof=1)) on the MATLAB grid |
| cmdscale | new `cobraCmdscale` | — | numpy eigh by hand (up to sign) |
| confusionmat | new `cobraConfusionmat` | cobraGrp2idx | sklearn confusion_matrix(labels=) after dropping missing values |
| dataset | **base** fopen/fprintf (table is the documented successor) | — | byte comparison |


---

<a id="g2"></a>

# MathWorks semantics, group G2: curve fitting and optimizers

Compiled 2026-11-11 for `specs/20261111-152503-toolbox-free-remaining`. Read-only research:
nothing in the repository was edited and MATLAB was not run. Every claim about MathWorks
behaviour cites the documentation page it comes from. **UNCONFIRMED** marks anything that no
fetched page states.

## Source key

- **[DOC-fit]** https://www.mathworks.com/help/curvefit/fit.html
- **[DOC-libmodels]** https://www.mathworks.com/help/curvefit/list-of-library-models-for-curve-and-surface-fitting.html
- **[DOC-fitoptions]** https://www.mathworks.com/help/curvefit/cfit.fitoptions.html
  (`https://www.mathworks.com/help/curvefit/fitoptions.html` returned 404 on 2026-11-11)
- **[DOC-prepare]** https://www.mathworks.com/help/curvefit/preparecurvedata.html
- **[DOC-gof]** https://www.mathworks.com/help/curvefit/evaluating-goodness-of-fit.html
- **[DOC-lsfit]** https://www.mathworks.com/help/curvefit/least-squares-fitting.html
- **[DOC-cfitplot]** https://www.mathworks.com/help/curvefit/cfit.plot.html
- **[DOC-fminunc]** https://www.mathworks.com/help/optim/ug/fminunc.html
- **[DOC-uncalg]** https://www.mathworks.com/help/optim/ug/unconstrained-nonlinear-optimization-algorithms.html
- **[DOC-tol]** https://www.mathworks.com/help/optim/ug/tolerances-and-stopping-criteria.html
- **[DOC-fom]** https://www.mathworks.com/help/optim/ug/first-order-optimality-measure.html
- **[DOC-legacy]** https://www.mathworks.com/help/optim/ug/current-and-legacy-option-name-tables.html
- **[DOC-fmincon]** https://www.mathworks.com/help/optim/ug/fmincon.html
- **[DOC-ga]** https://www.mathworks.com/help/gads/ga.html
- **[DOC-gaopt]** https://www.mathworks.com/help/gads/gaoptimset.html
- **[DOC-gaoptions]** https://www.mathworks.com/help/gads/genetic-algorithm-options.html
- **[DOC-gahow]** https://www.mathworks.com/help/gads/how-the-genetic-algorithm-works.html
- **[DOC-gascale]** https://www.mathworks.com/help/gads/fitness-scaling.html
- **[NW]** J. Nocedal and S. J. Wright, *Numerical Optimization*, 2nd ed., Springer 2006.
  Alg. 3.5/3.6 (strong-Wolfe line search with zoom), Alg. 4.1 (trust region), Alg. 4.3
  (exact subproblem, Moré–Sorensen), Alg. 6.1 (BFGS), Alg. 7.2 (CG–Steihaug), §8.1 (finite
  differences), Ch. 10 (least squares, Levenberg–Marquardt as a trust-region method).
- **[CL96]** T. F. Coleman and Y. Li, "An interior trust region approach for nonlinear
  minimization subject to bounds", *SIAM J. Optim.* 6(2):418–445, 1996 (the reflective
  trust-region family that Curve Fitting's "Trust-Region" and `lsqnonlin` belong to).
- **[More78]** J. J. Moré, "The Levenberg–Marquardt algorithm: implementation and theory",
  *Lecture Notes in Mathematics* 630, 1978 (LM as a trust-region method; MINPACK).
- **[BLNZ95]** R. H. Byrd, P. Lu, J. Nocedal and C. Zhu, "A limited memory algorithm for bound
  constrained optimization", *SIAM J. Sci. Comput.* 16(5):1190–1208, 1995 (L-BFGS-B).
- **[Kelley99]** C. T. Kelley, *Iterative Methods for Optimization*, SIAM 1999, §5.5
  (projected BFGS for bound constraints).
- **[Baker87]** J. E. Baker, "Reducing bias and inefficiency in the selection algorithm", Proc.
  2nd ICGA, 1987 (stochastic universal sampling = MathWorks `selectionstochunif`).
- **Local check:** no Curve Fitting, Optimization or Global Optimization Toolbox on this
  machine, so nothing was checked empirically.

---

## 1. fit / fittype('gauss1') / fitoptions / prepareCurveData

### 1.1 Call sites

| File:line | Call text | Inputs |
|---|---|---|
| `src/dataIntegration/transcriptomics/rFASTCORMICS/createFitL.m:22` | `[xData, yData] = prepareCurveData( xi, rest );` | `xi` 1x100 row (ksdensity grid); `rest` 1x100 row |
| `createFitL.m:25-29` | `ft = fittype( 'gauss1' ); opts = fitoptions( 'Method', 'NonlinearLeastSquares' ); opts.Display = 'Off'; opts.Lower = [-Inf -Inf 0]; opts.StartPoint = [0.0442312785349232 -0.515420615759673 2.77989514663167];` | |
| `createFitL.m:32` | `[fitresult, gof] = fit( xData, yData, ft, opts );` | 100x1 columns |
| `createFitR.m:22` | `[xData, yData] = prepareCurveData(x', hybrid_curve);` | `x'` 100x1 (transposed row); `hybrid_curve` 100x1 |
| `createFitR.m:25-29` | same as L but `opts.StartPoint = [0.215494818454649 5.36184523579772 1.10452062242243];` | |
| `createFitR.m:34` | `[fitresult, gof] = fit(xData, yData, ft, opts);` | |

Options set: only `Method='NonlinearLeastSquares'`, `Display='Off'`, `Lower=[-Inf -Inf 0]`,
`StartPoint` (fixed numbers). `Upper` is left at its default `[]`, and `Algorithm`, `TolFun`,
`TolX`, `MaxIter`, `MaxFunEvals`, `Robust`, `Normalize`, `Weights` and `Exclude` stay at their defaults.
Because `StartPoint` is given, the heuristic start point of the library model is never used.

**Callers** (only `discretizeFPKM.m`):

- `discretizeFPKM.m:132-133` `[fit_r_r, ~] = createFitR(xi, hybrid_curve_r); [fit_l_r, ~] = createFitL(xi, rest_curve_r);`
- `discretizeFPKM.m:171-172` the same with `_g`.
- `xi`, `probability_estimate` come from `[probability_estimate, xi] = ksdensity(signal_sample)`
  (line 88), so both are 1x100 rows. `hybrid_curve_*` is 100x1 (`zeros(numel(...),1)`),
  `rest_curve_* = probability_estimate - hybrid_curve_*'` is 1x100 with values `< 1e-4` set to 0
  (lines 116-117, 168-169).

**Downstream use of the outputs:**

- `gof` is discarded at every call (`[fit, ~] = ...`).
- `fitresult.c1` and `fitresult.b1` are read by dot access (lines 148-150, 174-176): `sigma1 = fit_r.c1/sqrt(2)`,
  `mu1 = fit_r.b1`, `mu2 = fit_l.b1`, `ue = max(-3,(mu2-mu1)/sigma1)`. `a1` is never read.
- `plot(fit_r_r, 'b'); plot(fit_l_r, 'g');` (lines 136-137) is the only method call on the
  cfit object, and only when `figflag` is true, on held axes after the density plot. There is no `feval`, `fitresult(x)`,
  `confint`, `predint` or `coeffvalues` anywhere in `src/`.
- **Tests:** `test/verifiedTests/dataIntegration/testRFASTCORMICS/testRFASTCORMICS.m` never calls
  `discretizeFPKM`. It does hard-`assert(~isempty(ver('curvefit')))` (line 13), which fails rather than
  skips on base MATLAB, and it declares `statistics_toolbox` (line 10). No test covers
  `createFitL/R` or `discretizeFPKM`.

### 1.2 MathWorks semantics

- **Model:** gauss1 is `Y = a1*exp(-((x-b1)/c1)^2)`, with coefficients `a1, b1, c1` [DOC-libmodels].
  The coefficient order in `StartPoint`, `Lower` and `Upper` is `[a1 b1 c1]`. This is consistent
  with `fitoptions('gauss2')` showing `Lower: [-Inf -Inf 0 -Inf -Inf 0]` [DOC-fitoptions]. An explicit
  statement of the order for gauss1 is UNCONFIRMED.
- **Width bound:** [DOC-fitoptions] shows that the library gauss options carry `Lower` 0 on the widths:
  "To help the algorithm, specify lower bounds for the nonnegative amplitudes a1 and a2 and
  widths c1, c2." The call sites set it explicitly, so the library default does not matter here. They
  build opts from the generic `fitoptions('Method','NonlinearLeastSquares')`, whose
  `Lower`/`Upper`/`StartPoint` default to `[]` [DOC-fitoptions].
- **NonlinearLeastSquares defaults** [DOC-fitoptions]:

  | Option | Default |
  |---|---|
  | Algorithm | "Trust-Region" |
  | Display | 'notify' |
  | DiffMaxChange | 0.1 |
  | DiffMinChange | 1e-8 |
  | MaxFunEvals | 600 |
  | MaxIter | 400 |
  | TolFun | 1e-6 |
  | TolX | 1e-6 |
  | Robust | 'off' |
  | Normalize | 'off' |

  Trust-Region "is the default" and "You must use the trust-region algorithm if you specify
  coefficient constraints" [DOC-lsfit]. Whether TolFun and TolX are relative or absolute in Curve
  Fitting is UNCONFIRMED.
- **Start points:** "starting points for some library models are determined heuristically" [DOC-fit].
  The gauss heuristic is UNCONFIRMED and not needed, because StartPoint is given.
- **Algorithm internals:** [DOC-lsfit] says only that the algorithm iterates using "the Jacobian of
  f(X,β)", and does not say whether that Jacobian is analytic or finite-difference (UNCONFIRMED). The "Trust-Region" algorithm is
  the Coleman–Li reflective trust region [CL96] shared with `lsqnonlin` (inference from naming;
  UNCONFIRMED for Curve Fitting). Whether library gauss models are fitted by separable
  least squares (solving a1 linearly) is UNCONFIRMED.
- **gof fields** [DOC-fit]: `sse`, `rsquare`, `dfe`, `adjrsquare`, `rmse`. Their definitions
  [DOC-gof], unweighted here:
  - `sse = sum((y - yhat).^2)`
  - `sst = sum((y - mean(y)).^2)`
  - `rsquare = 1 - sse/sst`. This "is possible to get a negative R-square for equations that do not contain a
    constant term", which applies to gauss1.
  - `dfe = v = n - m`, with m = 3 coefficients
  - `adjrsquare = 1 - (sse/(n-1))/(sst/v)` as printed on the page. Read literally this is
    `1 - sse*v/(sst*(n-1))`. The usual definition `1 - (sse/v)/(sst/(n-1))` swaps v and n−1. The
    page rendering was garbled ("reconstructed"), so the exact formula is **UNCONFIRMED**. Settle
    it with a parity check or the documented examples. No call site reads it.
  - `rmse = sqrt(sse/v)`
- **Third output** `output` [DOC-fit]: numobs, numparam, residuals, Jacobian, exitflag, iterations,
  funcCount, firstorderopt, algorithm, message. Not requested by the call sites.
- **NaN/Inf:** `fit` documents that x and y "Cannot contain Inf or NaN" [DOC-fit].
- **prepareCurveData** [DOC-prepare]:
  - "Return data as columns regardless of the input shapes."
  - "Error if the number of elements do not match."
  - "Warn if the number of elements match, but the sizes differ."
  - "Remove NaN or Inf from data and warn of this removal."
  - "Convert complex to real (remove imaginary parts) and warn of this conversion."
  - "Convert nondouble to double and warn of this conversion."

  Whether the NaN removal is pairwise (a row is dropped if x or y is non-finite) is UNCONFIRMED.
  It is pairwise by necessity, since x and y must stay aligned. The warning identifiers and texts are UNCONFIRMED.
  At the call sites, the shapes match (row/row in L, column/column in R), the data are finite
  double (ksdensity output), so no warning fires.
- **plot(cfit, spec)** "plots the curve given in the cfit object cfit over the range of the
  current axes (gca)". With no current axes, it plots "over the range of the data used to create cfit"
  [DOC-cfitplot]. The number of sample points is UNCONFIRMED.

### 1.3 Proposed replacement: `cobraFitGauss1`

`fit` is generic, so the narrowest function that serves the call sites is a gauss1-only fitter. The
name `cobraFit` would promise the generic syntax.

```
[fitresult, gof, output] = cobraFitGauss1(x, y, 'StartPoint', sp, 'Lower', lb, 'Upper', ub, ...
                                          'Display', 'off', 'TolFun', 1e-6, 'TolX', 1e-6, ...
                                          'MaxIter', 400, 'MaxFunEvals', 600)
```

- **prepareCurveData step (built in):**
  - `x(:)`, `y(:)`; error if `numel` differs; warning if the sizes differ.
  - Drop rows where x or y is NaN/Inf, with a warning.
  - Take `real()` with a warning if complex; cast to double with a warning.

  A separate `cobraPrepareCurveData` is only needed if another call site appears. The fit
  function can accept the call sites' raw row/column inputs, so `createFitL/R` call
  `cobraFitGauss1(xi, rest, ...)` directly.
- **Supported options:** `StartPoint` (required; error if missing, since no heuristic is
  reproduced), `Lower`, `Upper`, `Display` ('off'/'notify'/'final'/'iter'), `TolFun`,
  `TolX`, `MaxIter`, `MaxFunEvals`. Any other name gives an error naming it (FR-003).
- **Algorithm:** bounded nonlinear least squares in the trust-region family, with the analytic Jacobian
  (`e = exp(-((x-b1)/c1).^2)`):
  - `d/da1 = e`
  - `d/db1 = 2*a1*e.*(x-b1)/c1^2`
  - `d/dc1 = 2*a1*e.*(x-b1).^2/c1^3`

  Two options:
  - (a) **Recommended:** Levenberg–Marquardt in Moré's trust-region form [More78; NW Ch. 10]. It
    handles bounds by the exact symmetry of gauss1 in c1: the model depends on `c1^2`, so for
    `Lower = [-Inf -Inf 0]`, `Upper = []` the bounded problem has the same SSE landscape as the
    unconstrained one, and `c1 := abs(c1)` maps any unconstrained minimizer to a feasible one
    with identical SSE. c1 = 0 itself is a removable singularity (the model is undefined), so guard it.
    Other bound patterns raise an error naming `Lower`/`Upper` (FR-003), or use (b).
  - (b) A Coleman–Li reflective trust region [CL96] for general bounds, the same class as MathWorks
    and SciPy `least_squares(method='trf')`.

  Stopping:
  - relative step `||dp|| <= TolX*(1+||p||)`;
  - relative SSE change `<= TolFun*(1+sse)`;
  - MaxIter;
  - MaxFunEvals.

  This mirrors [DOC-tol]'s generic relative tests. The Curve Fitting form is UNCONFIRMED.
- **Outputs:**
  - `fitresult`: a struct with `a1`, `b1`, `c1` (dot access works unchanged in
    `discretizeFPKM`), plus `fitresult.f = @(x) a1*exp(-((x-b1)/c1).^2)` for evaluation, and
    `fitresult.formula = 'a1*exp(-((x-b1)/c1)^2)'`. With a struct, `feval(fitresult,x)`,
    `fitresult(x)` and `plot(fitresult)` do not work, but no call site uses the first two.
  - `gof`: a struct with `sse`, `rsquare`, `dfe`, `adjrsquare`, `rmse`. Use the conventional
    adjrsquare and record the doc ambiguity.
  - `output`: a struct with `numobs`, `numparam`, `residuals`, `Jacobian`, `exitflag`, `iterations`,
    `funcCount`, `firstorderopt`, `algorithm`, `message`.
- **Call-site change in `discretizeFPKM.m:136-137`** (inside `if figflag`): replace `plot(fit_r_r,'b')` with
  `xl = xlim; xx = linspace(xl(1), xl(2), 1001); plot(xx, fit_r_r.f(xx), 'b')`. This reproduces
  "range of the current axes" [DOC-cfitplot]. The point count is a free choice and is UNCONFIRMED vs MathWorks.
- **Principle II note:** the documented output of `createFitL/R` changes from "a `cfit`
  object" to a struct with the same coefficient fields. The only caller is `discretizeFPKM`, which uses dot
  access and the plot. Record this in the help header. An alternative that keeps `fitresult(x)`,
  `feval` and `plot` working is a small value class (for example `cobraCfitGauss1` with
  `subsref`/`feval`/`plot`). It is heavier and not needed by any call site.

### 1.4 Test problems and references

1. **Exact data:** `x = linspace(-5,10,100)'`, `y = 0.3*exp(-((x-2)/1.5).^2)` from the
   createFitR start point. Expect `[0.3 2 1.5]` to 1e-8, `sse` ≈ 0, `rsquare` = 1.
2. **Noisy data** (seeded `rng`): compare `a1, b1, c1, sse` with SciPy 1.16
   `scipy.optimize.curve_fit(gauss1, x, y, p0=sp, bounds=([-inf,-inf,0],[inf,inf,inf]),
   method='trf', ftol=1e-10, xtol=1e-10)`, to a relative 1e-6. Tight tolerances are used on both sides so
   that the comparison measures the optimum, not the stopping point.
3. **Start from negative c1 / bound-active direction:** check that c1 is returned ≥ 0 and
   the SSE equals the reference.
4. **Real pipeline shape:** seeded log-normal FPKM data run through `ksdensity` (the
   replacement from another agent). Build `hybrid_curve`/`rest_curve` exactly as in discretizeFPKM,
   export `xi`, `y` to CSV, and compare with curve_fit (trf) from the same start points.
5. **prepareCurveData behaviour:** row inputs, NaN/Inf rows removed with a warning, size mismatch with
   equal numel gives a warning, numel mismatch gives an error, complex gives a warning.
6. **gof formulas:** check against direct computation, with `dfe = n-3`.
7. **Error tests:** an unsupported option name; missing StartPoint.
8. **Parity section** (only if `license('test','Curve_Fitting_Toolbox')` and `ver('curvefit')`):
   `fit(x,y,fittype('gauss1'),opts)` on cases 2 and 4, comparing `a1,b1,c1` and `gof.sse`.

### 1.5 UNCONFIRMED and risks

- **Local minima:** the left fit runs on `rest_curve`, a residual density with zero-clipped
  values that may be near-zero or multimodal. From the same start point, MathWorks' reflective trust region
  and an LM path can end in different local minima. `b1` of the left fit sets the threshold
  `ue`, which is clamped at −3. Mitigate with a parity run on a machine with Curve Fitting and
  with SciPy trf on realistic data. Record any divergence.
- **All-zero rest_curve:** `a1 → 0` makes `b1` and `c1` unidentifiable. MathWorks' returned `b1` is then
  the path-dependent result of its own iterations (UNCONFIRMED), and the replacement's will differ. Document this as a known
  limitation and test that no error is raised.
- **Unconfirmed details:** the TolFun/TolX semantics (absolute vs relative), separable least squares
  for gauss, the adjrsquare formula rendering, and the prepareCurveData warning texts.
- **Also needed in planning:** `discretizeFPKM` needs a `ksdensity` replacement from another agent.
  testRFASTCORMICS needs its `ver('curvefit')` assert and `statistics_toolbox` requirement removed (it
  never reaches either toolbox).

---

## 2. fminunc, trust-region with user gradient and Hessian (varKin BDCA, DCA)

### 2.1 Call sites

| File:line | Text |
|---|---|
| `src/base/solvers/varKin/BDCAmethods/BDCA.m:114-116` | `eps = 1e-8; options_fmin = optimoptions('fminunc','Algorithm', 'trust-region', 'GradObj', 'on','Hessian','on','Display','off','TolFun',eps,'TolX',eps);` |
| `BDCA.m:139` | `yk = fminunc(@(x)FuncGradHessSub(x,xk,F,R,kin,rho),xk,options_fmin);` |
| `DCA.m:110-112` | identical options |
| `DCA.m:134` | `xk = fminunc(@(x)FuncGradHessSub(x,xk,F,R,kin,rho),xk,options_fmin);` |

- **Outputs used:** only `x` (first output). `fval`, `exitflag` and `output` are never requested.
- **Objective:** `[func, grad, Hess] = FuncGradHessSub(x, y, F, R, kin, rho)`
  (`BDCAmethods/FuncGradHessSub.m`).
  - It always computes all three outputs, regardless of nargout.
  - `x` is an m x 1 column, with m the number of metabolites = `size(F,1)`.
  - `FR = [F,R]` is m x 2n and `kin` is 2n x 1.
  - `func = g(x) - dh(y)'*x`, a strongly convex DC subproblem:
    - `g(x) = 2(||FR e||^2 + ||RF e||^2) + rho/2 ||x||^2`, with `e = exp(kin + FR'x) > 0`;
    - `Hess = 4*H + rho*I`, where `H = dux*dux' + dwx*dwx' + Σ_j ux(j)*FR*diag(e.*FR(j,:)')*FR' + Σ_j wx(j)*FR*diag(e.*RF(j,:)')*FR'`;
    - every term is PSD because F, R ≥ 0 and e > 0, so **Hess is symmetric positive definite** (≥ rho).
  - `rho` defaults to 100 (`InitialBDCA.m:106`). DCA sets `options.rho = 100` in `optimizeVKmodel0.m:536`.
  - The Hessian is a dense m x m matrix.
- **Problem size:** caller `src/base/solvers/varKin/optimizeVKmodel0.m:532-543`, used with
  `testOptimizeVKmodel0` (ecoli_core without biomass: m = 72 metabolites, n = 94 reactions; kin = 0;
  x0 = 0.1*cos(1:m)). That test currently exempts lines 533-537 and 540-543 because fminunc is missing.
- **Other observations:**
  - BDCA's `'quadratic_interpolation'` branch (lines 149-159) and `df` (line 112) reference the
    undefined `p`, `f`, `lambda` and `nfyk`. This is a pre-existing defect and is unaffected by the change.
  - BDCA and DCA print `Status`, and DCA prints `Niter` (no semicolon).

### 2.2 MathWorks semantics

- **Algorithm choice:** the default is `quasi-newton`. "The trust-region algorithm requires you to provide the
  gradient ... or else fminunc uses the quasi-newton algorithm" [DOC-fminunc].
- **Objective outputs:** with SpecifyObjectiveGradient, `fun` returns `g(x)` as its second output. With
  `HessianFcn = 'objective'`, it returns "H(x), a symmetric matrix, in a third output argument" [DOC-fminunc].
- **Legacy names** [DOC-fminunc, DOC-legacy]:
  - `GradObj` maps to `SpecifyObjectiveGradient` ('on' = true);
  - `TolX` maps to `StepTolerance`;
  - `TolFun` maps to `OptimalityTolerance` (usage 1) and `FunctionTolerance` (usage 2). fminunc lists TolFun
    under both, so both become 1e-8 here.
  - Legacy **`Hessian`** maps to `HessianApproximation` and is "Ignored when HessianFcn or
    HessianMultiplyFcn is nonempty" [DOC-legacy]. That `optimoptions('fminunc',...,'Hessian','on')`
    sets `HessianFcn='objective'` for trust-region (that is, uses the third output) is
    **UNCONFIRMED**. It is the evident intent, since FuncGradHessSub returns `Hess`, and it is the R2015-era
    meaning of `Hessian='on'`. If it is instead treated as an approximation setting, MathWorks would form a
    finite-difference Hessian from the gradient (`HessianFcn = []` means "finite-difference Hessian"
    [DOC-fminunc]). Either way, the minimizer of the strongly convex subproblem is the same.
- **Trust-region method** [DOC-uncalg]:
  - It minimizes `½sᵀHs + sᵀg` subject to `||Ds|| ≤ Δ`, restricted to a 2-D subspace spanned by
    the gradient and either an approximate Newton direction (from preconditioned CG) or a direction of
    negative curvature. "PCG exits when it encounters a direction of negative (or zero) curvature."
  - Δ "is adjusted according to standard rules", and is "decreased if the trial step is not accepted, i.e.,
    f(x + s) ≥ f(x)". So a step is accepted on simple decrease (inference).
  - Options [DOC-fminunc]: `MaxPCGIter = max(1,floor(n/2))`, `PrecondBandWidth = 0` (diagonal
    preconditioner), `SubproblemAlgorithm = 'cg'`, `TolPCG = 0.1`.
  - The trust-region algorithm does not use FiniteDifferenceStepSize.
- **Defaults** [DOC-fminunc]: OptimalityTolerance 1e-6, StepTolerance 1e-6, FunctionTolerance
  1e-6, MaxIterations 400, MaxFunctionEvaluations 100*nvars, Display 'final', ObjectiveLimit −1e20.
- **Stopping tests:**
  - [DOC-tol] says iterations end when `|x_i − x_{i+1}| < StepTolerance*(1+|x_i|)` "or a similar relative
    measure", and when `|f_i − f_{i+1}| < FunctionTolerance*(1+|f_i|)`.
  - First-order optimality is `||∇f||∞` for unconstrained problems [DOC-fom]. [DOC-fom] says solvers may scale it
    relative to `||∇f(x0)||∞`.
  - The exact scaling fminunc uses is **UNCONFIRMED**.
- **exitflag** [DOC-fminunc]:

  | Flag | Meaning |
  |---|---|
  | 1 | gradient magnitude below OptimalityTolerance |
  | 2 | change in x below StepTolerance |
  | 3 | change in f below FunctionTolerance |
  | 5 | predicted decrease below FunctionTolerance (the algorithm that emits it is UNCONFIRMED) |
  | 0 | iteration or function-evaluation limit reached |
  | -1 | stopped by an output function |
  | -3 | objective below ObjectiveLimit |
- **output fields:** iterations, funcCount, firstorderopt, algorithm, cgiterations
  (trust-region), lssteplength (quasi-newton), stepsize, message [DOC-fminunc].
- **Shape:** x keeps the shape of x0 [DOC-fminunc].

### 2.3 Proposed replacement: `cobraFminunc` (one function, two algorithms; see also §3)

```
[x, fval, exitflag, output, grad, hessian] = cobraFminunc(fun, x0, options)
```

- **options:** a plain struct, because `optimoptions` is Optimization Toolbox. Whether base
  `optimset` accepts `GradObj`/`Hessian` without the toolbox is UNCONFIRMED, so do not rely on it.
  - Accept current names: `Algorithm` ('trust-region' | 'quasi-newton'), `SpecifyObjectiveGradient`, `HessianFcn`
    ('objective' | []), `Display`, `OptimalityTolerance`, `FunctionTolerance`, `StepTolerance`,
    `MaxIterations`, `MaxFunctionEvaluations`.
  - Accept legacy aliases: `GradObj` ('on'/'off'), `Hessian` ('on' means `HessianFcn='objective'`, as used by the call sites), `TolFun`
    (sets both OptimalityTolerance and FunctionTolerance), `TolX`, `MaxIter`, `MaxFunEvals`.
  - Any other field gives an error naming it.
  - `Algorithm='trust-region'` without a gradient falls back to quasi-newton, as documented.
- **Call-site change** (BDCA.m:115, DCA.m:111):

  ```
  options_fmin = struct('Algorithm','trust-region','SpecifyObjectiveGradient',true,
      'HessianFcn','objective','Display','off','OptimalityTolerance',1e-8,
      'FunctionTolerance',1e-8,'StepTolerance',1e-8)
  ```

  then `cobraFminunc(@(x)FuncGradHessSub(...), xk, options_fmin)`. Alternatively, cobraFminunc accepts
  the legacy names and the struct keeps the exact legacy spelling.
- **Trust-region Newton** (the same class as MathWorks: trust region on the exact quadratic model
  built from the caller's g and H). [NW Alg. 4.1] with:
  - **Subproblem:** CG–Steihaug [NW Alg. 7.2], with a Jacobi (diagonal) preconditioner (the
    analogue of `PrecondBandWidth = 0`) and the relative residual tolerance `TolPCG = 0.1`. MaxPCGIter is
    `max(1,floor(n/2))`, raised to n when the subproblem is small (a documented deviation). An
    alternative is the exact Moré–Sorensen solve [NW Alg. 4.3]: for m ≈ 72, a Cholesky of a dense SPD
    Hessian costs almost nothing, and for these SPD subproblems it gives the Newton step whenever it lies inside Δ.
    **Recommendation:** Steihaug as the default (closest to MathWorks' PCG), plus an optional exact
    solve, and test both.
  - **Acceptance:** `ρ = (f(x) − f(x+s)) / (−m(s))`. Accept if `ρ > 0` (simple decrease, matching
    [DOC-uncalg]). `ρ < 1/4` gives `Δ = ||s||/4`; `ρ > 3/4` with `||s|| = Δ` gives `Δ = min(2Δ, Δmax)`. Initial `Δ0 = max(1, ||x0||)`
    (UNCONFIRMED vs MathWorks).
  - **Stops:**
    - `||g||∞ ≤ OptimalityTolerance*max(1, ||g0||∞)` gives exitflag 1. The relative form is a choice;
      make it a documented constant.
    - `||s|| < StepTolerance*(1+||x||)` gives 2.
    - `|Δf| < FunctionTolerance*(1+|f|)` gives 3.
    - Iteration or evaluation limit gives 0.
    - `f < ObjectiveLimit` gives −3.
  - **output:** iterations, funcCount, firstorderopt, cgiterations, algorithm ('trust-region'),
    stepsize, message. `grad` and `hessian` are the last evaluated.
  - x is reshaped to `size(x0)` before every call to `fun` and on return.

### 2.4 Test problems and references

- **Rosenbrock** n=2 with analytic g and H, x0 = [−1.2; 1]: optimum [1;1], f = 0, within 1e-6. Reference:
  SciPy `minimize(method='trust-exact')` and `'trust-ncg'` with `rosen`, `rosen_der`, `rosen_hess`.
- **Extended Rosenbrock** n = 10, x0 = −ones.
- **SPD quadratic** `½xᵀAx − bᵀx`: A seeded, n = 50, condition number 1e4, optimum `A\b` within 1e-8
  relative. Converges in one or a few iterations.
- **Negative curvature at the start:** for example `f = x1^4 + x1*x2 + (1+x2)^2` from [0.75; −1.25]
  (NW-style example). The optimum comes from SciPy trust-exact (known stationary point, check that the Hessian is PD there).
- **Already optimal start:** exitflag 1, `output.iterations = 0`.
- **MaxIterations = 1:** exitflag 0.
- **Real subproblem:** FuncGradHessSub on ecoli_core F, R, kin = 0, rho = 100, y = 0.1*cos(1:m)'.
  Check `||g(x*)||∞ ≤ 1e-8*scale`, and compare x* with SciPy trust-exact fed the same exported F, R
  (the Python version of FuncGradHessSub is ~15 lines).
- **DCA/BDCA end to end:** `optimizeVKmodel0` with 'DCA'/'BDCA' on the testOptimizeVKmodel0
  model. Expect convergence to a steady state with `||h(x_best)|| ≤ epsilon`, which removes that test's exemption.
- **Parity** (with Optimization Toolbox): `fminunc` with the same options on Rosenbrock and the real
  subproblem, comparing x within 1e-6.

### 2.5 UNCONFIRMED and risks

- The `'Hessian','on'` mapping under optimoptions; the exact relative form of the optimality and stopping
  tests; Δ0 and the update constants; which algorithm emits exitflag 5.
- **Low risk:** the subproblem is strongly convex with a PD Hessian, so any convergent TR-Newton
  reaches the same unique minimizer. BDCA/DCA results can differ from MathWorks only through
  stopping differences of about 1e-8.
- **Performance:** FuncGradHessSub builds a dense m x m Hessian with an m-loop of dense products.
  The cost is the caller's, not the replacement's.

---

## 3. fminunc (quasi-newton default) and fmincon in modelBorgifier `optimalScores`

### 3.1 Call sites (`src/reconstruction/comparison/modelBorgifier/optimalScores.m`)

**Data:**
- `hitVec` (k x nHit) and `missVec` (k x (nHit+nMiss)) are double. k = `size(SCORE,3)` = 38
  score components: there are 38 fields of `ScoreVal` in `compareCbModels.m:72-93`, and SCORE is int8.
- The training data come from `rxnList`.
- Callers: `reactionCompareGUI.m:316-380` (GUI only). No automated test calls `optimalScores`.
  `testOptWeightLin.m` and `testOptWeightExp.m` test only the objectives.

**'linear' branch, lines 146-155:**

```
weights = fminunc(@(weight)optWeightLin(weight, hitVec, missVec), ones(size(hitVec, 1), 1)) ;
```

- There are no options, so the defaults apply: quasi-newton, finite-difference gradient, Display 'final' (prints a message).
- Only `x` is used.
- The call is wrapped in `try/catch`. On error it prints "optWeightLin training failed, using default
  weights.", sets `weights = ones` and `optimizer = 'none'`. Without the toolbox this catch path runs
  today (`fminunc` is undefined), so **the GUI silently falls back today**.
- Downstream: `weights(weights<0) = 0` and `scoreWeighted = Σ SCORE(:,:,i)*weights(i)` (lines 200-209).
- **Objective** `optWeightLin(w,H,L) = 1/(|mean(H'w) − mean(L'w)| + 1)`, which equals `1/(|cᵀw|+1)` with
  `c = mean(H,2) − mean(L,2)`.
  - **It has no minimizer:** the infimum 0 is approached as `|cᵀw| → ∞`.
  - It is non-smooth where `cᵀw = 0`.
  - The gradient is `−sign(cᵀw)·c/(|cᵀw|+1)²`.
  - BFGS moves w along ±c until the gradient falls below tolerance (`||g||∞ ~ ||c||∞/(cᵀw)²`).
    The returned w is `ones + t·c` for a t set entirely by the stopping rule, so **the weights are
    stopping-rule dependent**, and so is `Stats.bestMatch`.
  - Gradients are not supplied, so the gradient is a finite difference.

**'exp' branch, lines 157-174:**

```
[wnum, hitnum] = size(hitVec); missnum = size(missVec, 2);
signs = sign(mean([hitVec missVec], 2));
weights = fmincon(@(weight)optWeightExp(weight, hitVec, missVec, wnum, hitnum, missnum), ...
          ones(size(hitVec, 1), 2), [], [], [], [], ...
          [zeros(wnum, 1) repmat(0.3, wnum, 1)], [repmat(1000, wnum, 1) repmat(3, wnum, 1)] );
weights(:, 1) = weights(:, 1) .* signs;
```

- x0 is a k x 2 matrix (coefficients, exponents). There are bounds only: col1 ∈ [0, 1000], col2 ∈ [0.3, 3]. x0 = 1 is
  interior.
- No options, so the defaults apply: interior-point, BFGS, finite differences, Display 'final'.
- Only `x` is used. Downstream: `Σ |SCORE_i|.^w(i,2) * w(i,1)` (lines 183-189).
- Also wrapped in try/catch with the same fallback to `ones`/'none'.
- **Pre-existing defect:** `optWeightExp` is declared with **5 inputs**
  (`weight, highscoreVectors, lowscoreVectors, hitnum, missnum`; see
  `optWeightExp.m:1` and `testOptWeightExp.m`, which call it with 5 arguments). The anonymous function passes
  **6** (`..., wnum, hitnum, missnum`), so the first objective evaluation raises "Too many input
  arguments". Even with the Optimization Toolbox, fmincon stops on that error (whether fmincon
  wraps the error message is UNCONFIRMED), the catch fires, and **the 'exp' branch always falls back to
  default weights**. It has been like this since the file was added; git history shows a single
  version. Per FR-013 this is documented, not fixed.
- **Other branches:**
  - 'svm' uses `fitcsvm(combinedVec, labelVec).Beta` directly as `weights`. No optimizer is
    involved (another agent covers fitcsvm).
  - 'RF' uses `ttest2` p-values to build `weight2`. No optimizer is involved (another agent covers it).

### 3.2 MathWorks semantics

- **fminunc quasi-newton:**
  - It is the default algorithm. The legacy option `HessianApproximation` defaults to "bfgs" [DOC-fminunc].
  - BFGS update `H+ = H + qqᵀ/(qᵀs) − Hs sᵀH/(sᵀHs)`; "H0 can be set to any symmetric positive definite matrix,
    for example, the identity" [DOC-uncalg].
  - Line search: a bracketing phase and sectioning by polynomial interpolation; "The resulting step length α
    satisfies the Wolfe conditions" [DOC-uncalg]. Whether the interpolation is cubic or quadratic is
    UNCONFIRMED.
  - Gradient by forward differences, with `delta = sqrt(eps)·sign′(x)·max(|x|, TypicalX)`,
    TypicalX = ones, and `sign′(0) = 1` [DOC-fminunc].
  - Defaults are as in §2.2: MaxFunctionEvaluations = 100·k = 3800 for k = 38.
- **fmincon:**
  - Default algorithm "interior-point" [DOC-fmincon].
  - `x`, `lb`, `ub` may be matrices, and x has the size of x0 [DOC-fmincon].
  - Interior-point "resets x0 components that are on or outside bounds" to strictly inside (HonorBounds) [DOC-fmincon].
  - Defaults [DOC-fmincon]: OptimalityTolerance 1e-6, StepTolerance 1e-10 (interior-point), ConstraintTolerance 1e-6,
    MaxIterations 1000, MaxFunctionEvaluations 3000, HessianApproximation 'bfgs', forward finite differences,
    Display 'final'.
  - exitflag [DOC-fmincon]:

    | Flag | Meaning |
    |---|---|
    | 1 | first-order optimality below tolerance, with constraints satisfied |
    | 2 | step below StepTolerance |
    | 0 | iteration, evaluation or time limit |
    | -1 | output or plot function |
    | -2 | no feasible point |
    | -3 | below ObjectiveLimit |
  - Inconsistent bounds give an error [DOC-fmincon].
  - The bound-constrained optimality measure is `max_i |v_i g_i|` (scaled, Coleman–Li) [DOC-fom].

### 3.3 Proposed replacements

**`cobraFminunc`, quasi-newton path** (same function as §2):

- BFGS [NW Alg. 6.1] with H0 = I, then rescaled after the first step by `yᵀs/yᵀy` (NW eq. 6.20).
- Strong-Wolfe line search with zoom and cubic interpolation [NW Alg. 3.5/3.6], c1 = 1e-4, c2 = 0.9.
- Skip the update if `yᵀs ≤ 1e-10·||s||·||y||`.
- Forward finite-difference gradient with the documented MathWorks step formula.
- Stops: as §2.3. `exitflag 5` is not emitted.
- `output.lssteplength` is provided.
- `Display='final'` prints one exit line, which reproduces that the call site prints a message. Its text is not
  MathWorks'.
- **Call-site change:** `cobraFminunc(@(weight)optWeightLin(...), ones(k,1))`. The try/catch stays.
  This **changes behaviour on base MATLAB**: the branch now produces optimized weights instead of
  the silent fallback. That is the intended effect of the feature, and it should be stated in the receipt.

**`cobraFmincon`** (narrow: bound constraints only):

```
[x, fval, exitflag, output] = cobraFmincon(fun, x0, A, b, Aeq, beq, lb, ub)   % A, b, Aeq, beq must be []
[x, fval, exitflag, output] = cobraFmincon(fun, x0, [], [], [], [], lb, ub, [], options)
```

- Non-empty linear or nonlinear constraints give an error naming them (FR-003). This is the narrowest support that
  serves the only call site.
- **Algorithm:** projected BFGS for bound constraints [Kelley99 §5.5], or the more robust L-BFGS-B
  [BLNZ95].
  - **Recommendation:** projected BFGS with an active-set reduction (BFGS on the free variables,
    projected Armijo backtracking).
  - This belongs to the "bound-constrained quasi-Newton" class allowed by FR-005. MathWorks uses an
    interior-point barrier, but identical iterates are not required.
  - x0 is projected onto [lb, ub]. An interior shift is not needed for a projection method; document this.
  - Stop when the projected-gradient measure `||x − P(x − g)||∞ ≤ OptimalityTolerance` (exitflag 1).
    Other stops: step `< StepTolerance (1e-10)` gives 2; limits (MaxIterations 1000, MaxFunctionEvaluations 3000)
    give 0.
  - `lb > ub` gives an error, as documented.
  - Variables with lb == ub are fixed.
- x is reshaped to `size(x0)` for every `fun` call, and lb/ub are reshaped with x0's shape.
- **Errors in `fun` must propagate** (rethrow, or wrap with the cause attached) so that
  optimalScores' catch path is still reached. With the 6-vs-5 argument defect, the call-site behaviour is
  then identical to MathWorks: always the fallback.

### 3.4 Test problems and references

**cobraFminunc quasi-newton:**
- Rosenbrock without gradient: [1, 1] within 1e-4. Reference: SciPy `minimize(method='BFGS')`.
- SPD quadratic n = 20: within 1e-6.
- Matrix x0, 3x2 quadratic: the shape is kept.
- `optWeightLin` on a small synthetic H, L: check that the objective decreases from x0, that `w − 1` is parallel to c
  (cosine > 0.999), and that the run stops with exitflag 1 or 0. It is not compared with an "optimum", because none exists.

**cobraFmincon:**
- `min Σ(x − t)²` with t partly outside [lb, ub]: `x* = min(max(t,lb),ub)` exactly (bound-active).
- Rosenbrock with `x1 ≤ 0.5` (`ub = [0.5; Inf]`): x* = (0.5, 0.25). Reference: SciPy `minimize(method='L-BFGS-B')` and
  `'trust-constr'` with `Bounds`.
- Matrix x0 (k x 2) with matrix lb/ub: shape kept, bounds honoured.
- x0 outside the bounds.
- lb == ub.
- lb > ub gives an error.
- A fixed 5-argument wrapper of `optWeightExp` on synthetic data: the objective is not larger than at x0, every
  iterate is within bounds, and the KKT measure ≤ 1e-6 or the run stops at bounds.
- An objective that throws: the error propagates.
- Non-empty A: the error names A.

**Parity sections:** fminunc on Rosenbrock (quasi-newton) and fmincon on the bound-active problems, when the
Optimization Toolbox is installed.

### 3.5 UNCONFIRMED and risks

- **'linear' weights are not reproducible across algorithms:** the problem is ill-posed (no minimizer), so the
  returned weights depend on the stopping rule. Parity with MathWorks can only be qualitative (the same direction).
  State this in the test and the semantics note.
- **'exp' branch:** dead because of the argument-count defect. Implementing cobraFmincon changes nothing
  observable at this call site. Fixing the defect would be a separate feature (FR-013).
- Whether fmincon wraps the objective's error text is UNCONFIRMED; it is irrelevant here because of the bare `catch`.

---

## 4. ga and gaoptimset (`src/design/optGene.m`)

### 4.1 Call site

- **Options, `optGene.m:152-170`:**

  ```
  options = gaoptimset('PopulationType','bitstring', 'CreationFcn',@lowmutationcreation,
    'MutationFcn',{@mutationUniformEqual, mutationRate}, 'PopulationSize',PopulationSize,
    'StallTimeLimit',StallTimeLimit, 'TimeLimit',TimeLimit, 'PlotFcns',PlotFcns,
    'InitialPopulation',InitialPopulation, 'CrossoverFraction',CrossoverFraction,
    'CrossoverFcn',crossfun, 'StallGenLimit',StallGenLimit, 'Generations',Generations,
    'TolFun',1e-10, 'Vectorize','on', 'MigrationFraction',MigrationFraction,
    'MigrationInterval',MigrationInterval);
  ```

  `SelectionFcn` is commented out, so it is the default.

- **Option values:**

  | Option | Value |
  |---|---|
  | PopulationSize | `[P P P P]` with P = 125, so **4 subpopulations of 125 = 500 individuals** (line 117) |
  | Generations | 10000 |
  | TimeLimit | 172800 s |
  | StallTimeLimit | 86400 s |
  | StallGenLimit | 10000 |
  | MigrationFraction | 0.1 |
  | MigrationInterval | 100 |
  | CrossoverFraction | 0.8 |
  | mutationRate | `1/ngenes` |
  | crossovermutationRate | `0.2/ngenes` |
  | MaxKOs | 10 (stored in global `MaxKnockOuts`) |
  | InitialPopulation | `double(population)`, `[]` by default |
- **PlotFcns** = `{@gaplotscores, @gaplotbestf, @gaplotscorediversity, @gaplotstopping,
  @gaplotmutationdiversity}`. The first four are **Global Optimization Toolbox functions**. The
  last one is local (lines 293-343), uses base `hist`/`title`, and its header carries a MathWorks
  copyright line from 2007.
- **Problem, lines 177-183:**

  ```
  gap.fitnessfcn = @(x) optGeneFitnessTilt(x,model,targetRxn,generxnList,geneok);
  gap.nvars = ngenes;
  gap.options = options;
  [x,FVAL,REASON,OUTPUT,population,scores] = ga(gap);
  ```

  `gap.solver` is not set.
- **Outputs:**
  - `x` goes to `GetOptGeneSol` (`sum(x)==0` gives an error "No genes or reactions found"; otherwise
    `generxnList(logical(x))`).
  - `population` and `scores` are returned to the user and stored in `optGeneSol.population` / `.scores`.
  - `optGeneSol.obj = min(scores)`.
  - `FVAL`, `REASON` and `OUTPUT` are **unused**.
- **Custom functions** (local to optGene.m):
  - `lowmutationcreation(GenomeLength, FitnessFcn, options)`:
    - reads `options.PopulationSize` (`sum` = 500) and `options.InitialPopulation`;
    - returns a **logical** 500 x n matrix: the provided rows, then rows with bits set with probability 1/n.
  - `mutationUniformEqual(parents, options, GenomeLength, FitnessFcn, state, thisScore, thisPopulation, mutationRate)`:
    - takes `length(parents)` children from `thisPopulation(parents(i),:)`;
    - flips bits with probability `mutationRate`;
    - trims to MaxKnockOuts;
    - with probability 0.5, when kos > 1, removes knock-outs until the count is below the parent's;
    - returns **double** 0/1;
    - uses `rand` and `randi`.
  - `crossoverCustom(parents, options, GenomeLength, FitnessFcn, unused, thisPopulation, mutationRate)`:
    - makes `nKids = length(parents)/2` children, gene-wise uniform from parent pairs (consecutive entries
      of `parents`);
    - trims to MaxKnockOuts;
    - then applies `mutationUniformEqual` with `crossovermutationRate`.
- **Fitness** `optGeneFitnessTilt(rxn_vector_matrix, ...)`:
  - **vectorized**: takes popsize x n and returns a **row** `1 x popsize`;
  - memoized in the global Java `HTABLE`;
  - value = −(target flux at the max-growth solution of the tilted KO model), or 0 if infeasible, growth < 0.1, too
    many KOs, or the value is > −1e-3;
  - each evaluation calls `optimizeCbModel`, so the LP solver is required.
- **Test `test/verifiedTests/design/testOptGene.m`:**
  - It declares `requiredToolboxes = {'gads_toolbox'}` (prepareTest maps it to 'Global Optimization
    Toolbox', `prepareTest.m:84`), `needsLP`, `needsMILP`.
  - It runs `rng(0)`, then `optGene(model, rxns{39} (succinate), rxns{26}, rxns(setdiff(1:95,[11 13 26 39])), 'StallTimeLimit',15,'TimeLimit',30)`
    on ecoli_core.
  - It takes `optSols = population(optGeneSol.scores == min(optGeneSol.scores), :)` and
    `optReacs = optSols(1,:)`, sets those reactions' bounds to 0, and asserts that the succinate flux of the KO model
    exceeds wild type.
  - It deletes `MILPProblem.mat` and calls `close all`.
  - **Note:** `generxnList(optReacs)` (line 53) indexes with `optReacs`. If the population is double
    0/1, as [DOC-gaoptions] states for bitstring ("vectors of type double"), indexing with 0 is an
    error. The test would then only pass if the returned population is logical. The type
    MathWorks returns after mixing logical creation output with double mutation and crossover output is **UNCONFIRMED**.
    **The replacement must decide.** Recommendation: return the population as double (doc) and treat line 53 as
    a pre-existing test defect (III-Defects). Alternatively, the test change under FR-012 uses `logical(optReacs)`.
    This must be settled in planning.
  - Tutorials `tutorial_optGene.m:119,166` use `'MaxKOs',2` with `'TimeLimit',120` and `'Generations',20`.

### 4.2 MathWorks semantics for that subset

**Calling and outputs:**
- `ga(problem)` requires the fields `fitnessfcn`, `nvars`, `options`; `solver` is optional [DOC-ga].
- Outputs `[x,fval,exitflag,output,population,scores]` [DOC-ga]:
  - `population` is the "Final population, returned as a PopulationSize-by-nvars matrix";
  - `scores` are the "Final scores, returned as a column vector";
  - `output` has the fields problemtype, rngstate ("state just before the algorithm started"),
    generations, funccount, message, maxconstraint, hybridflag.
- `exitflag` [DOC-ga]:

  | Flag | Meaning |
  |---|---|
  | 1 | average relative change in best fitness over MaxStallGenerations ≤ FunctionTolerance |
  | 3 | no change over MaxStallGenerations |
  | 4 | step below eps |
  | 5 | FitnessLimit reached |
  | 0 | MaxGenerations exceeded |
  | -1 | stopped by an output or plot function |
  | -2 | no feasible point |
  | -4 | MaxStallTime exceeded |
  | -5 | MaxTime exceeded |

**gaoptimset:**
- "gaoptimset is not recommended. Use optimoptions instead." There are "no plans to remove"
  it [DOC-gaopt].
- Defaults [DOC-gaopt]:

  | Option | Default |
  |---|---|
  | CrossoverFraction | 0.8 |
  | EliteCount | '0.05*PopulationSize' |
  | FitnessLimit | −Inf |
  | FitnessScalingFcn | @fitscalingrank |
  | Generations | '100*numberOfVariables' |
  | MigrationDirection | 'forward' |
  | MigrationFraction | 0.2 |
  | MigrationInterval | 20 |
  | StallGenLimit | 50 |
  | StallTimeLimit | Inf |
  | TimeLimit | Inf |
  | TolFun | 1e-6 |
  | Vectorized | 'off' |
  | Display | 'final' |
  | PopulationType | 'doubleVector' |

  [DOC-gaoptions] gives EliteCount as `ceil(0.05*PopulationSize)`.
- `'Vectorize'` is not an option name. It is accepted as a unique leading abbreviation of
  `Vectorized` [DOC-gaopt].

**Population:**
- **Bitstring:** "The individuals in a Bit string population are vectors of type double", with components 0/1
  [DOC-gaoptions]. "ga ignores all constraints when PopulationType is set to bitString" [DOC-ga].
- **PopulationSize vector:** "creates multiple subpopulations, the number of which is the length of the
  vector". The page also says "Note that this option is not useful" [DOC-gaoptions].
- **Migration:** "the best individuals from one subpopulation replace the worst individuals in another
  subpopulation". Migrants "are copied". 'forward' migrates toward the last subpopulation and "wraps at the
  ends". MigrationFraction is "the fraction of the smaller of the two subpopulations that moves", for example
  0.1*50 = 5. MigrationInterval is "how many generation pass between migrations" [DOC-gaoptions].
  - The rounding of 0.1*125 = 12.5 is UNCONFIRMED (optGene's comment says "~12").
  - Whether EliteCount, selection and operators act per subpopulation is UNCONFIRMED. They presumably do.
- **InitialPopulation:** with fewer rows than PopulationSize, "calls CreationFcn to generate the
  remaining individuals" [DOC-gaoptions].

**Generation step:**
- One generation [DOC-gahow]: score, scale, select parents, elite children, crossover children,
  mutation children.
  - Elite children "automatically survive to the next generation" and are not re-evaluated.
  - Worked example: population 20, EliteCount 2, CrossoverFraction 0.8 gives `round(0.8*18) = 14` crossover
    children and 4 mutation children.
  - The number of parents (2·nXover + nMutate) is UNCONFIRMED. It is implied by the custom-crossover
    contract, since optGene uses `length(parents)/2` kids.
- **Scaling** `fitscalingrank` [DOC-gascale]: "The scaled value of an individual with rank n is
  proportional to 1/n", and "The sum of the scaled values ... equals the number of parents".
  - Discrepancy: a MathWorks staff answer on MATLAB Answers says rank scaling is proportional to the square
    root. The exact exponent is **UNCONFIRMED**, and the doc is taken as authority.
  - Tie handling is UNCONFIRMED.
- **Selection** default `selectionstochunif` [DOC-gaoptions]: the line is laid out by expectation, and the
  algorithm "moves along the line in steps of equal size"; "The first step is a uniform random number less than
  the step size" (stochastic universal sampling [Baker87]).

**Custom functions and vectorization:**
- Current doc signatures use `problem` in place of the legacy `FitnessFcn` argument:
  - creation `myfun(GenomeLength, problem, options)`;
  - crossover `myfun(parents, options, nvars, problem, thisScore, thisPopulation)`;
  - mutation `myfun(parents, options, nvars, problem, state, thisScore, thisPopulation)`
  [DOC-gaoptions].
  - optGene's functions ignore arguments 2 and 4 except `options.PopulationSize` and
    `options.InitialPopulation` in the creation function, so passing a struct with those fields is sufficient.
  - Extra cell entries (`{@f, rate}`) are appended after the standard arguments. This is the standard gaoptimset
    convention; an explicit statement in the current docs is UNCONFIRMED.
- **Vectorized:** "ga calls the fitness function on the entire population at once, in a single call"
  [DOC-gaoptions]. Whether a row result (optGene returns `1 x popsize`) is accepted is UNCONFIRMED. The
  replacement takes `(:)`.

**Stopping** [DOC-gaoptions, DOC-gahow]:
- MaxGenerations default `100*nvars`.
- Stall generations: "average relative change in the best fitness function value over
  MaxStallGenerations" ≤ FunctionTolerance. [DOC-gahow] says "less than". The exact relative formula and
  weighting are UNCONFIRMED (a `StallTest` option exists).
- MaxStallTime: "no improvement in the best fitness value for an interval of time".
- MaxTime is "measured by tic and toc" and "enforced after each iteration".
- FitnessLimit: stop if the best ≤ FitnessLimit.
- The order of the checks is UNCONFIRMED.

### 4.3 Proposed replacement: `cobraGa`

```
[x, fval, exitflag, output, population, scores] = cobraGa(problem)
% problem.fitnessfcn, problem.nvars, problem.options (plain struct with gaoptimset names)
```

- **No `gaoptimset` replacement.** optGene builds the options with `struct(...)`, wrapping the cell
  values `MutationFcn` and `PlotFcns` in `{{...}}`.
- **Supported option names** (legacy gaoptimset spelling, plus `Vectorized`):
  PopulationType ('bitstring' only; 'doubleVector' gives an error naming it), CreationFcn,
  MutationFcn (handle or `{handle, extra...}`), CrossoverFcn, CrossoverFraction, EliteCount,
  PopulationSize (scalar or vector), InitialPopulation, Generations, StallGenLimit,
  StallTimeLimit, TimeLimit, FitnessLimit, TolFun, Vectorized ('on'/'off'), MigrationFraction,
  MigrationInterval, MigrationDirection ('forward'), PlotFcns, Display.
  - `Vectorize` is accepted as an abbreviation only if cobraGa implements unique-prefix matching.
    Simpler: optGene passes `Vectorized`.
  - SelectionFcn and FitnessScalingFcn: only their defaults are implemented. Passing them gives an error naming them.
- **Algorithm (per generation, per subpopulation s):**
  1. Rank-scale the scores (expectation ∝ 1/rank per the doc, ties by sort order; normalized to sum to
     nParents).
  2. Stochastic universal sampling of `nParents = 2*nXover + nMutate` parents, shuffled.
  3. `nElite = EliteCount` (default `ceil(0.05*Ps)`) best individuals are copied with their scores.
  4. `nXover = round(CrossoverFraction*(Ps − nElite))` and `nMutate = Ps − nElite − nXover`.
  5. Children: `CrossoverFcn(parents(1:2*nXover), opts, nvars, fitnessfcn, [], thisPopulation, extra...)` and
     `MutationFcn(parents(2*nXover+1:end), opts, nvars, fitnessfcn, state, thisScore, thisPopulation, extra...)`.
  6. Default operators for bitstring when none are given: scattered crossover and bit-flip mutation at rate 0.01.
  7. The new children of all subpopulations are evaluated in **one vectorized call** (or a row loop if
     Vectorized is 'off'). The result is reshaped to a column.
  8. Every MigrationInterval generations, `floor(MigrationFraction*min(Ps))` best individuals of subpopulation s replace the
     worst of s+1 (wrapping), for 'forward'.
  9. Creation: if CreationFcn is given, call it once with `(nvars, fitnessfcn, opts)` for the total
     population; otherwise use InitialPopulation plus uniform random bits. The result is split into subpopulations by
     consecutive rows.
- **Randomness:** only `rand`/`randi`/`randperm` on the global stream, so `rng(seed)` makes the
  run reproducible **provided the stop is not time-based**. `output.rngstate = rng` is captured at the start.
- **Stopping:** checked after each generation, in this order:
  1. FitnessLimit (5)
  2. Generations (0)
  3. TimeLimit (−5)
  4. StallTimeLimit (−4)
  5. stall generations: the relative change of the best fitness over the last StallGenLimit generations,
     `|best(g−L) − best(g)| / max(1,|best(g)|) / L ≤ TolFun`, gives 1. The formula is UNCONFIRMED and documented as a choice.
- **Outputs:**
  - `x` is the best individual (1 x nvars double); `fval` is its score.
  - `population` is (Σ Ps) x nvars **double** (doc: bitstring individuals are double), with subpopulations
    stacked in order. `scores` is the matching column.
  - `output` has problemtype 'unconstrained', rngstate, generations, funccount, message, maxconstraint = [].
- **PlotFcns:** call each `f(options, state, flag)` with 'init', 'iter' and 'done', where state has the fields
  `Generation`, `Population`, `Score`, `Best`, `StartTime`, `StopFlag`. Skip them when there is no display.
  - **Call-site change:** optGene drops the four GADS plot functions, because cobraGa cannot call
    them on base MATLAB. It either keeps only its local `gaplotmutationdiversity` or adds small local
    best-score plots.
  - This changes figures only; the outputs are unaffected (Principle II).
- **Display:** 'final' prints the stop message; 'off' prints nothing.

### 4.4 Test problems and references

1. **OneMax:** nvars = 30, fitness `-sum(x,2)` vectorized, rng(0), Generations = 300, default operators.
   Expect fval = −30 and x all ones.
2. **0/1 knapsack:** 15 items with seeded weights and values; fitness = −value with a large penalty if over capacity. The
   reference optimum comes from **exhaustive enumeration** of 2^15 subsets (an independent, exact
   reference; SciPy has no GA). Assert fval equals it within 0, with rng fixed and Generations = 500.
3. **Reproducibility:** two runs with rng(1) and Generations = 50 give identical x, fval, population,
   scores and output.generations.
4. **optGene's operator signatures:** run cobraGa with local copies (in the test) of
   lowmutationcreation, mutationUniformEqual and crossoverCustom, a PopulationSize vector `[20 20 20 20]`,
   MigrationInterval = 5 and MigrationFraction = 0.1, on OneMax with MaxKOs. The best can only reach
   MaxKOs ones.
5. **Exit flags:**

   | Setting | Expected exitflag |
   |---|---|
   | Generations = 3 | 0 |
   | FitnessLimit = −10 on OneMax | 5 |
   | StallGenLimit = 5 on a constant fitness | 1 |
   | TimeLimit = 0 | −5 |
   | StallTimeLimit = 0 | −4 |
6. **Elitism:** the best score never worsens across generations (monotone `best`).
7. **Migration:** a deterministic check that after a migration the worst rows of s+1 equal the best rows of s.
8. **Errors:** PopulationType 'doubleVector'; an unknown option.
9. **testOptGene** (LP + MILP solver): drop `gads_toolbox`. Note that the test is time-limited (StallTimeLimit 15,
   TimeLimit 30), so it is not reproducible run to run. Its assertion (improvement over wild type) is
   robust. Settle the double-vs-logical `optReacs` issue (§4.1).
10. **Parity** (with Global Optimization Toolbox): `ga` on OneMax and the knapsack reaches the same
    optimum value.

### 4.5 UNCONFIRMED and risks

- **Scaling and ties:** the rank-scaling exponent (doc 1/n vs the staff answer's √) and tie handling.
- **Subpopulations:** the per-subpopulation EliteCount and operators; the migration count rounding; the order of
  the stopping checks; the exact stall formula.
- **Fitness shape:** whether ga accepts a row fitness vector.
- **Population type:** the class of the returned population (double vs logical). It affects testOptGene line 53.
- **Time-based stops** (testOptGene and the tutorials) make results machine- and speed-dependent, with or
  without the toolbox. The spec's "same result with a fixed seed" (US2-AS2) can only be tested with
  generation-based stops.
- **Cost:** each fitness evaluation is an LP, and a 4x125 population over many generations is costly. Memoization
  (HTABLE) is kept because cobraGa does not change the fitness function.
- **MathWorks code:** `gaplotmutationdiversity` in optGene carries a MathWorks copyright header (2007). It is
  outside this feature's scope, but flag it for review (licensing).

---

## 5. Summary of new functions

| New function | Replaces | Minimal syntax | Algorithm |
|---|---|---|---|
| `cobraFitGauss1` | `prepareCurveData` + `fittype('gauss1')` + `fitoptions` + `fit` | `[f,gof,out] = cobraFitGauss1(x,y,'StartPoint',sp,'Lower',lb,'Display','off')` | LM trust region with analytic Jacobian; c1 bound via the c1² symmetry (or Coleman–Li TRR for general bounds) |
| `cobraFminunc` | `fminunc` + `optimoptions` | `x = cobraFminunc(fun,x0,opts)` with opts a struct (current or legacy names) | trust-region Newton (CG–Steihaug or Moré–Sorensen) with the user's g and H; BFGS with strong-Wolfe line search and FD gradient otherwise |
| `cobraFmincon` | `fmincon` (bounds only) | `x = cobraFmincon(fun,x0,[],[],[],[],lb,ub)` | projected BFGS / L-BFGS-B-style; errors from `fun` propagate |
| `cobraGa` | `ga` + `gaoptimset` | `[x,fval,flag,out,pop,scores] = cobraGa(problem)` with problem.options a struct | generational GA: rank scaling, stochastic universal sampling, elitism, custom creation/crossover/mutation, subpopulations with forward migration, legacy stopping options |


---

<a id="g3"></a>

# G3 semantics note: regression and machine learning (fitglm, fitglme, coefCI, fitlm, fitcsvm, tsne)

Compiled 2026-11-11. This is read-only planning research. No repository file was changed and MATLAB was not run.
Every claim cites its source. MathWorks source code was not copied.

## Source key

- **[DOC-fitglm]** https://www.mathworks.com/help/stats/fitglm.html
- **[DOC-GLM]** https://www.mathworks.com/help/stats/generalizedlinearmodel.html (GeneralizedLinearModel class)
- **[DOC-GLM-coefCI]** https://www.mathworks.com/help/stats/generalizedlinearmodel.coefci.html
- **[DOC-LM-coefCI]** https://www.mathworks.com/help/stats/linearmodel.coefci.html
- **[DOC-fitglme]** https://www.mathworks.com/help/stats/fitglme.html
- **[DOC-GLME]** https://www.mathworks.com/help/stats/generalizedlinearmixedmodel-class.html. The URL `generalizedlinearmixedmodel.html` returns 404.
- **[DOC-GLME-coefCI]** https://www.mathworks.com/help/stats/generalizedlinearmixedmodel.coefci.html
- **[DOC-GLME-models]** https://www.mathworks.com/help/stats/generalized-linear-mixed-effects-models.html
- **[DOC-LME-est]** https://www.mathworks.com/help/stats/estimating-parameters-in-linear-mixed-effects-models.html
- **[DOC-wilk]** https://www.mathworks.com/help/stats/wilkinson-notation.html
- **[DOC-fitlm]** https://www.mathworks.com/help/stats/fitlm.html
- **[DOC-LM]** https://www.mathworks.com/help/stats/linearmodel.html
- **[DOC-glmfit]** https://www.mathworks.com/help/stats/glmfit.html
- **[DOC-fitcsvm]** https://www.mathworks.com/help/stats/fitcsvm.html
- **[DOC-tsne]** https://www.mathworks.com/help/stats/tsne.html
- **[DOC-tsne-alg]** https://www.mathworks.com/help/stats/t-sne.html
- **[ANS-jeffreys]** https://www.mathworks.com/matlabcentral/answers/2149979-understanding-the-jeffrey-prior-penalty-term-in-the-glmfit-function-in-matlab-r2024a. This is a MATLAB Answers thread, not official documentation.
- **[R14:glmfit.m]** https://globec.whoi.edu/data/matlabr14sp2/toolbox/stats/glmfit.m. It is the 2005 source, read for semantics only (the same mirror and policy as the first slice). It does not prove how the current release behaves.
- **[NUM]** A numeric check made here with SciPy 1.16.0 / NumPy 1.26.4 against published MathWorks example output. The scripts were inline and nothing is kept in the repository.
- **[CODE]** The repository at branch `20261111-152503-toolbox-free-remaining`.
- **UNCONFIRMED**: no source confirms the claim. A parity section has to settle it wherever the toolbox is installed.

**Local fact [CODE/filesystem]:** `patients.mat` ships with **base MATLAB** at `toolbox/matlab/demos/patients.mat`. `carsmall.mat`, `hospital.mat`, `fisheriris.mat` and `ionosphere.mat` are only in `mcr/toolbox/stats/statsdata` (Statistics Toolbox). The `fitglm` documentation example built on `patients` therefore runs on base MATLAB, and it has published numbers (§2.6).

---

## 1. Call sites and how they are reached

### 1.1 `performRegressions` (src/analysis/persephone/performRegressions.m, 248 lines)

**Signature:** `[results, regressions] = performRegressions(data, metadata, formula, exponentiateLogOdds)` [CODE].

**How `data` is built** (lines 57-68, 115-116) [CODE]:
1. The input `data` is a wide table: `ID` plus one column per reaction or taxon. It is `stack`ed into long form, with the value column named `Flux` or `relative_abundance` and the index column named `Reaction` or `Taxa`. A `stack` index variable is categorical (MATLAB behaviour; not checked here).
2. `HM_` is stripped from `ID`, and the table is `innerjoin`ed with `metadata` on `ID`.
3. The formula is tokenised with `strsplit(formula,'[+\|*]', 'DelimiterType','RegularExpression')`, so `+`, `|` and `*` all separate tokens. The response is the left side of `~`. Tokens that contain `:` are dropped from the predictor list.
4. Random effects: `regexp(formula,'(?<=\|).*?(?=\))','match')` returns the text between `|` and `)` of every term. Tokens containing `(1` or `)` are removed, and the grouping variables are appended.
5. `data = data(:, [name response predictors])`. Column order is therefore **name, response, then predictors in formula order, then the random-effect grouping variables**. This matters for coefficient order (§6.4).

**Response and distribution** (lines 92-112) [CODE]:
- If the response has exactly two unique values, it is recoded as `cobraGrp2idx(categorical(.)) - 1`, so the first sorted category becomes 0, and `responseDistribution = 'binomial'`.
- The `isa(response,'double')` test is always false because `response` is a cell, so the branch is harmless.
- Otherwise `responseDistribution = 'normal'`.
- **Only 'normal' and 'binomial' occur.** Text responses with more than two values error before any fit.

**Which fit runs** (lines 127-153) [CODE]:
- `firthRegression = (ver(1).Version >= 24.2)`, i.e. R2024b or newer. On the maintainer's R2025a, **every non-mixed fit, normal or binomial, uses `'LikelihoodPenalty','jeffreys-prior'`.** [DOC-fitglm] says the option was "Introduced in R2024a", so R2024a users get the unpenalised path although the option exists. Results differ by MATLAB version.
- Mixed-effects formula: `mdl = fitglme(data(groups==i,:), formula, 'Distribution', responseDistribution)` runs inside `try`. `catch ME` sets `mdl = {}`.
- Otherwise: `fitglm(data(groups==i,:), formula, 'Distribution', responseDistribution [, 'LikelihoodPenalty','jeffreys-prior'])`. This call is **not** inside `try`, so an error from `fitglm` aborts `performRegressions`.
- **Warning gate:** `lastwarn('')` runs before each fit. If **any** warning was issued during the fit, the model is discarded (`regressions.(field) = {}`). A replacement must (a) issue a warning in the situations where MathWorks does (iteration limit, rank deficiency, perfect separation; see §2.5), and (b) issue **no** spurious warnings, including from helpers it calls. Otherwise results silently appear or disappear.

**Every model property and method read downstream** (lines 177-228) [CODE]:

| Read | GLM path | GLME path |
|---|---|---|
| `isempty(mdl)` via `structfun(@isempty, regressions)` | model must be non-empty | same |
| `mdl.CoefficientNames(2:end)`, `mdl.CoefficientNames(j)` | cell row; `(Intercept)` first | same |
| `mdl.Variables.(name)(1)` | full input table, including the `Reaction`/`Taxa` column and rows excluded as missing | same ([DOC-GLME]: "Variables is identical to tbl") |
| `mdl.NumObservations` | rows used | same |
| `mdl.Coefficients{j,:}` | **all columns** of a 4-column table: Estimate, SE, tStat, pValue | — |
| `double(mdl.Coefficients(j,{'Estimate','SE','tStat','pValue'}))` | — | **dataset array** indexing. `double()` of a MATLAB `table` errors, so this line **must change** (to `mdl.Coefficients{j,{'Estimate','SE','tStat','pValue'}}`) |
| `ci = coefCI(mdl)`, then `ci(j,:)` | default alpha 0.05 | fixed-effects CI, default alpha and DFMethod |
| `mdl.Rsquared.Adjusted` | GLM definition (§2.4) | GLME definition (§3.5) |

- With binomial and `exponentiateLogOdds`, estimate, low and high are passed through `exp`. SE, tStat and pValue are not.
- `fdrBHadjustment` is already used instead of `mafdr`.

**Second output:** `regressions` is a struct of `GeneralizedLinearModel` / `GeneralizedLinearMixedModel` objects, documented as "fitted regression model object". No in-repo caller uses it: `performStatsPersephone` takes only `regRes`, and `runStatisticsOnModerationAnalysisResults` takes only `results`. External users might call methods on it (`predict`, `plotResiduals`, …). **Returning structs instead is a Principle II interface change and needs a maintainer decision** (§9).

### 1.2 Callers of `performRegressions` and the formulas they build [CODE]

- `performStatsPersephone.m:485,503,521,539,557,577` (subfunction `runStatistics`). `predictor` is `'Flux'` or `'relative_abundance'` and `response` is a metadata column.
  - `response~Flux` (simple linear; the simple-logistic flag is never set true)
  - `response~Flux+Sex`
  - `response~Flux+Sex+conf1+conf2…` (via `strjoin(confounders,'+')`)
  - None of these contain spaces. `metadata.Sex = string(metadata.Sex)`, so **Sex is a string array** and becomes a categorical predictor. Confounders are any metadata columns, numeric or text.
- `runStatisticsOnModerationAnalysisResults.m:126` has **no caller in the repository**; the moderation option is commented out in `performStatsPersephone`. It strips the moderator and the `Flux:moderator` term, so it passes `response~Flux+Sex…`.
- **Mixed-effects formulas (`(1|g)`) are never built by repository code.** The path exists for users calling `performRegressions` directly. It was added in commit cf3babb1f ("support for unnested mixed effect regressions"), and an external contributor fixed a bug in it in commit f2ca8337d, which shows real users run it.
- What the tokeniser actually supports:
  - **Random intercepts `(1|g)` only, one or several, unnested (crossed).** A random slope `(x|g)` leaves the token `(x` as a "predictor", and `data(:,includedVars)` then errors.
  - A nested `(1|g1:g2)` yields the "variable" `g1:g2`, which also errors at `data(:, …)`.
  - `*` is a delimiter, so `a*b` is anticipated. `:` terms are tolerated in the formula, but their variables must also appear as main effects or they are filtered out of `data`.
- **Data scale:** cohorts have at least about 50 samples (`performStatsPersephone` header; it warns when there are fewer than 40). Each call runs one regression per reaction or taxon, so hundreds to thousands of fits.
  - Per fit, n ≈ cohort size, minus rows with NaN. Microbiome `relative_abundance` is NaN where a taxon is absent, so **NumObservations varies per taxon**.
  - p is about 2-10 fixed effects.
  - The number of random-effect levels is unknown and user-chosen: from a few batches or sites up to about n/2 subjects.
- No test covers `performRegressions`, `performStatsPersephone`, `CreateClusterAndRAtables`, `dimensionalityReductionAndMultivariateAnalysis`, `optimalScores` or `producetSNEPlots`. `testPersephone` only tests helpers.

### 1.3 `fitlm` call sites [CODE]

- **`CreateClusterAndRAtables.m:90`**: `fit_microbe = fitlm(flux, singleClusterAbn);`
  - This file is a **script**, not a function, with hard-coded file names, and nothing calls it.
  - `flux` is a numeric column vector of fluxes for one reaction (NaN possible). `singleClusterAbn` is a numeric vector of summed abundances with NaN set to 0.
  - **Reads only `fit_microbe.Rsquared.Ordinary`.**
- **`dimensionalityReductionAndMultivariateAnalysis.m:248`** (subfunction `exploreMetadataCorrelations`): `mdl = fitlm(currentVar, PCofInterestScore);`
  - `currentVar` is a metadata-table column of any type: numeric, logical, categorical, or possibly string/cellstr. `PCofInterestScore` is a numeric PC score vector.
  - Wrapped in a `lastwarn('')` gate: any warning means the result is NaN.
  - Reads `mdl.NumObservations`, `mdl.Coefficients.Estimate(2)`, `.SE(2)`, `.tStat(2)`, `.pValue(2)` and `mdl.Rsquared.Ordinary`. The model is stored in a local struct only.
  - The same function calls `mafdr`, which belongs to another group.

### 1.4 `fitcsvm` call site [CODE]

- **`optimalScores.m:107`**: `SVMModel = fitcsvm(combinedVec, labelVec); weights = SVMModel.Beta;`
  - **Only `Beta` is read**; `Bias`, `predict` and the rest are unused. Negative weights are then set to 0, the weights multiply the `SCORE` layers, and the argmax over `scoreTotal` picks `bestMatchIndex`.
  - `combinedVec` is `[hitVec'; missVec']`. Shape: (h + (h+m)) × size(SCORE,3), where h = training hits and m = declared-new reactions.
  - `SCORE` is `int8`, preallocated with 38 layers (`length(fieldnames(ScoreVal))`), but `ScoreVal` indices run up to 40, so in practice there are 40 layers and layers 9-10 are never written (all-zero columns). Values are small integers.
  - Typical n is the size of the training list: hundreds to a few thousand. p ≈ 40.
  - `labelVec` is a double 0/1 vector.
  - Reached from the `reactionCompareGUI` "svm" button, line 334; the call is interactive. `tutorial_modelBorgifier` exists.

### 1.5 `tsne` call sites [CODE]

- **`producetSNEPlots.m:188`**: `Y = tsne(data,'Distance','euclidean','Algorithm','barneshut','Perplexity',perpl,'NumDimensions',2);`
  - `perpl` is 50 if n>150, 30 if n≥50, 10 if n≥20, else 5. The call is reached only when n>10.
  - `data` is strains × features: reaction or metabolite presence (0/1), or flux values. All-zero and NaN columns are removed first.
  - n can be several thousand (AGORA2 has about 7,000 strains; the phylum level keeps nearly all). There are thousands of features.
- **`producetSNEPlots.m:260`**: the same call with `NumDimensions` 3, for custom features.
- How `Y` is used:
  - Written as text into `Summary` and exported with `cell2csv` as "x-axis value / y-axis value".
  - Plotted with `gscatter(Y(:,1),Y(:,2),taxa,cols,cmarkers)` (2-D) or `gscatter3` (3-D; `external/visualization/gscatter3b`).
  - The guard `size(data,1)==size(Y,1)` relies on NaN-free rows.
  - **No seed is set**, so the output is random today.
- **Pre-existing defects found (record under III-Defects; do not fix here):**
  - (a) Line 263 assigns the n×3 `cellstr(string(Y))` into `(:,3:4)`, which raises a size-mismatch error whenever the 3-D custom-feature branch runs.
  - (b) Lines 246-248 filter `taxa` and not `feats`, and `perpl` is reused from the previous loop.

---

## 2. fitglm (incl. Firth) — replacement `cobraFitglm`

### 2.1 Syntax subset needed
- `mdl = cobraFitglm(tbl, formula, 'Distribution', dist)`, where `dist ∈ {'normal','binomial'}`.
- Optional `'LikelihoodPenalty'`, `'none'|'jeffreys-prior'`.
- Anything else raises an error naming the option (FR-003).

### 2.2 MathWorks semantics
- **Formula / table:**
  - Predictors are table variables named in Wilkinson notation, and names must be valid identifiers [DOC-fitglm].
  - Default `Intercept` is true, and the canonical link is used: identity for normal, logit for binomial [DOC-fitglm].
  - **Categorical detection for table input:** "categorical values, logical values, character arrays, string arrays" and cellstr are treated as categorical [DOC-fitglm; DOC-fitlm same sentence].
- **Dummy coding:** reference coding with the **first category** as reference [DOC-fitlm: "The model uses the first category as a reference level"; DOC-fitglme: `DummyVarCoding` default `'reference'`].
  - **"First" depends on type:**
    - `categorical`: category order (sorted unless set).
    - **cellstr: order of first appearance.** Proof [NUM]: in the [DOC-fitglm] `patients` example the first row is `'Male'`, and the output shows a coefficient `Gender_Female`, i.e. reference = Male, although `'Female'` sorts first.
    - **string array: presumably first appearance as well (UNCONFIRMED).** This matters because `Sex` is a string array in `performStatsPersephone`: the coefficient is named `Sex_male` or `Sex_female` depending on which sex appears first in each per-reaction subset. That subset order is the order of the `innerjoin` output (sorted by key, MATLAB default; UNCONFIRMED).
  - `cobraGrp2idx` already implements "first appearance for char/cell/string, category order for categorical" (its header cites semantics note §7). **Reuse it to order levels.**
  - Coefficient names have the form `Var_level` [DOC-fitglm example `Gender_Female`; DOC-LM `Model_Year_76`]. Interaction names: `Age:Gender_Female` [DOC-fitglm].
- **Missing values:** `NaN`, `''`, `""`, `<missing>` and `<undefined>` in any formula variable exclude the row ("does not use observations with missing values in the fit") [DOC-fitglm].
  - `NumObservations` = rows − excluded − missing [DOC-GLM].
  - `Variables` keeps **all** rows and all table variables [DOC-GLM].
- **Estimation:** IRLS, with `Options` defaulting to `statset('fitglm')`: `MaxIter` 100, `TolX` 1e-6 [DOC-fitglm].
  - Starting values (R14; current UNCONFIRMED) [R14:glmfit.m]: binomial μ₀ = (y+0.5)/2, which is (N·y+0.5)/(N+1) with N=1; normal μ₀ = y.
  - Convergence (R14; current UNCONFIRMED) [R14:glmfit.m]: every |Δb| ≤ 1e-6·max(√eps, |b_old|).
  - On the 100-iteration limit, warning `stats:glmfit:IterationLimit` "Iteration limit reached." (R14). Whether `fitglm` re-issues it under the same ID is UNCONFIRMED.
- **Dispersion:**
  - Binomial: `DispersionFlag` false, so dispersion is 1 and `DispersionEstimated` = false.
  - Normal: always estimated [DOC-fitglm, DOC-GLM], = SSE/DFE.
  - `DFE = n − p` [DOC-GLM], with p = number of estimated coefficients. Under rank deficiency, p is presumably the rank (UNCONFIRMED).
- **Coefficients table:** columns `Estimate`, `SE`, `tStat` (= Estimate/SE, kept as "tStat" for binomial) and `pValue` [DOC-GLM]. RowNames = CoefficientNames.
  - SE = sqrt(diag(s²·(XᵀWX)⁻¹)), with W the IRLS weights at convergence [R14:glmfit.m]. Binomial checked [NUM] below.
  - **pValue: normal distribution when dispersion is not estimated (binomial), t(DFE) when it is estimated (normal).** [R14:glmfit.m] states it, and [NUM] confirms it on current documentation output:
    - Binomial `patients` example: pValue 0.77394 for tStat −0.28722 equals 2Φ(−|t|) = 0.773944; t(93) would give 0.774583.
    - Poisson example: x3 has t = 3.3932 and p = 0.00069087; normal gives 0.000691, t(92) gives 0.00102.
- **Rsquared** [DOC-GLM]:
  - `Ordinary = 1 − SSE/SST`.
  - `Adjusted = 1 − (SSE/SST)(N−1)/DFE`.
  - SSE = sum of squared errors (weighted when weights are given). SST = Σ(y − ȳ)².
  - The page does not say which residual type enters SSE, and the doc example output does not print R², so this cannot be checked against published numbers. **Using raw response residuals `y − μ̂` for SSE is UNCONFIRMED** for binomial. Under it, the `patients` model gives Ordinary 0.050111 and Adjusted −0.011172 [NUM].
  - `performRegressions` stores `Rsquared.Adjusted` in its tables, so this needs parity.
- **Deviance / LogLikelihood:** not read by the call sites. The replacement can still return them (cheap) for tests: binomial deviance = −2·loglik; chi² vs the constant model = 5.07 for `patients` (reproduced [NUM]: 5.0657, p = 0.5354).

### 2.3 Firth (`'LikelihoodPenalty','jeffreys-prior'`)
- [DOC-fitglm]/[DOC-glmfit]: values are `"none"` (default) and `"jeffreys-prior"`. "For logistic models, setting LikelihoodPenalty to "jeffreys-prior" is called Firth's regression." It is recommended for small samples and separable data. No formula, SE rule or distribution restriction is documented. Only tall arrays are excluded.
- [ANS-jeffreys]:
  - The unpenalised `glmfit` on separable data gives "Iteration limit reached" and a message recommending `'LikelihoodPenalty','jeffreys-prior'`. **So separation produces a warning, which `performRegressions` turns into a dropped result on the non-Firth path.**
  - The poster also reports that MATLAB's Jeffreys estimate did not match his own grid maximisation of loglik + ½log det I, but that thread is unresolved and non-authoritative.
- Standard Firth theory (Firth 1993, Biometrika 80:27-38; Heinze & Schemper 2002, Stat Med 21:2409-2419):
  - Maximise ℓ(β) + ½ log det I(β), with I = XᵀWX.
  - For logit, the modified score is U*(β) = Xᵀ(y − μ + h∘(½ − μ)), where h = diag(W^{½}X(XᵀWX)⁻¹XᵀW^{½}).
  - Solve by Newton with I(β) and step-halving on the penalised likelihood.
- **UNCONFIRMED for MATLAB:**
  - (a) Whether SE comes from I(β̂)⁻¹, the logistf/firthlogist convention, or from the penalised Hessian.
  - (b) Whether pValue stays Wald-normal (expected, same column semantics) or is a penalised-LR test (logistf's default).
  - (c) Whether Deviance and LogLikelihood are penalised.
  - (d) Starting values, convergence rule and step-halving.
  - (e) **What `'normal'` + `jeffreys-prior` does.** For an identity link with dispersion profiled separately, I(β) = XᵀX/σ² does not depend on β, so the penalty is constant in β and the estimate equals OLS. The expectation is identical output to the unpenalised normal fit, but this is UNCONFIRMED. It matters because `performRegressions` on R2024b+ uses Firth for **all** continuous responses.
  - (f) Whether `fitglm` with Firth warns on non-convergence.
  - Parity sections must settle (a)-(f). Until then, document the conventions chosen: SE from I(β̂)⁻¹, Wald normal p, unpenalised deviance.

### 2.4 coefCI for GLM
- See §4. Note the inconsistency inside MathWorks: **coefCI uses t(DFE) even when the pValue uses the normal distribution.**

### 2.5 Failure and warning behaviour the call site depends on
- **Iteration limit:** a warning, ID `stats:glmfit:IterationLimit` in R14. The current ID inside `fitglm` is UNCONFIRMED; the call site only checks `lastwarn` is non-empty, so the message and ID need not match exactly. Use a `cobra`-prefixed ID or mirror the MathWorks ID? Constitution VII-B requires visible warnings. Recommend `stats`-free IDs such as `COBRA:cobraFitglm:IterationLimit`.
- **Perfect / quasi separation (no penalty):**
  - Current MATLAB warns. The message recommends jeffreys-prior [ANS-jeffreys]. The exact ID is UNCONFIRMED; it is something like `stats:glmfit:PerfectSeparation`, from memory.
  - The replacement must detect separation (fitted μ within eps of 0/1 for all observations of one side, or the iteration limit with diverging |b|) and warn.
- **Rank-deficient design** (e.g. a confounder constant within a subset, or a categorical with an empty level):
  - MathWorks `LinearModel` warns "Regression design matrix is rank deficient to within machine precision." The ID is believed to be `stats:LinearModel:RankDefDesignMat`, UNCONFIRMED. For GLM it is UNCONFIRMED whether there is a warning or an error.
  - [R14:glmfit.m] has no pivoting and no rank check.
  - Recommended replacement behaviour: detect rank via pivoted QR, warn, and set dropped coefficients to 0 with SE 0 (regress convention). Settle by parity.
- **A categorical predictor with a single level in a subset** (e.g. all one sex): there is no dummy column, so `CoefficientNames` is shorter. `performRegressions` indexes coefficients by position j taken from the first non-empty model, which is a pre-existing fragility. Mirror MathWorks: drop unused levels? Whether MathWorks keeps unused categorical levels as zero columns (which would make the design rank deficient) is UNCONFIRMED. Text predictors have no unused levels.
- **No usable rows** (e.g. a taxon all NaN): MathWorks errors (UNCONFIRMED message). The fitglm call is not in `try`, so the whole call aborts today. The replacement should also error.

### 2.6 Published numbers usable as test values (base-MATLAB data)
- **[DOC-fitglm] logistic example on `patients`** (base MATLAB `toolbox/matlab/demos/patients.mat`). Model: `fitglm(tbl, "Smoker ~ Age*Weight*Gender - Age:Weight:Gender", Distribution="binomial")`.

| Term | Estimate | SE | tStat | pValue |
|---|---|---|---|---|
| (Intercept) | −8.3351 | 29.02 | −0.28722 | 0.77394 |
| Age | 0.13764 | 0.70593 | 0.19498 | 0.84541 |
| Weight | 0.043269 | 0.15966 | 0.27101 | 0.78638 |
| Gender_Female | 2.2859 | 12.424 | 0.18399 | 0.85402 |
| Age:Weight | −0.00071959 | 0.0038964 | −0.18468 | 0.85348 |
| Age:Gender_Female | −0.020734 | 0.20681 | −0.10025 | 0.92014 |
| Weight:Gender_Female | −0.01216 | 0.053168 | −0.22871 | 0.8191 |

  - 100 observations, 93 error df, Dispersion 1, chi² vs constant 5.07, p = 0.535.
  - **Reproduced exactly [NUM]** by plain IRLS (SE from (XᵀWX)⁻¹, normal p) on the `.mat` data. This one example exercises `*` expansion, `-` term removal, cellstr reference = first appearance, interaction naming, and normal p-values.
  - If the parser scope excludes `*`/`-`, the test can instead pass the expanded formula `Smoker ~ Age + Weight + Gender + Age:Weight + Age:Gender + Weight:Gender`. Same numbers expected; the term order then follows the formula, UNCONFIRMED.
- **[DOC-GLM-coefCI] Poisson** has published estimates and SEs: Intercept 1.0405 / 0.022122, x1 0.9968 / 0.003362, x2 1.987 / 0.0063433, with n=100 and DFE=97.
  - Published CIs: 95% `[0.9966 1.0844; 0.9901 1.0035; 1.9744 1.9996]` and 99% `[0.9824 1.0986; 0.9880 1.0056; 1.9703 2.0036]`.
  - The data come from `poissrnd` (Statistics), so they cannot be regenerated. **The test can still check `cobraCoefCI` given Estimate/SE/DFE**: [NUM] t(97) gives 1.08441 vs normal 1.08386, which reproduces the published 1.0844 and proves t(DFE).

### 2.7 Independent references
- **statsmodels `GLM(y, X, family=Binomial())`** for the unpenalised logit.
  - Use `.fit()` with default IRLS and `use_t=False`, so p-values are normal, like MATLAB binomial.
  - CIs: compute `params ± t.ppf(0.975, df_resid)*bse` in the script; statsmodels' own `conf_int()` is normal.
- **statsmodels `OLS`** or `GLM(family=Gaussian())` with `use_t=True` for the normal case. Rsquared adjusted is `rsquared_adj` on OLS.
- **Firth:** not in statsmodels.
  - (1) PyPI `firthlogist` (`FirthLogisticRegression(fit_intercept=False, skip_pvals=False, wald=True)` on [1 X]). It is independent code, Heinze-Schemper algorithm, with `bse_` from (XᵀWX)⁻¹.
  - (2) A short NumPy implementation of the modified score in the reference script, as a second check.
  - (3) Optional, published: R `logistf` documentation examples (`sex2` data), only if the data can be re-entered. Not needed.
  - All three share the SE and p conventions that are UNCONFIRMED for MATLAB, so state in the test that they settle the *algorithm*, and that parity settles MATLAB's conventions.
- Data for tests: hand-built tables with a string `Sex` column (first-appearance reference), NaN rows, a separable binary set (Firth finite, non-Firth warns), and a constant-column subset (rank warning).

### 2.8 Proposed replacement
- `cobraFitglm(tbl, formula, 'Distribution', d, 'LikelihoodPenalty', lp)` returns a **struct** with these fields:
  - `Coefficients`: a table with variables `Estimate, SE, tStat, pValue` and RowNames = names. This keeps `mdl.Coefficients{j,:}` and `.Estimate(2)` working.
  - `CoefficientNames` (1×p cell), `NumObservations`, `DFE`.
  - `Rsquared` struct with `Ordinary` and `Adjusted` (optionally `LLR`, `Deviance`).
  - `Deviance`, `LogLikelihood`, `Dispersion`, `DispersionEstimated`.
  - `Variables` (input table), `ObservationInfo.Missing`/`Subset` (logical), `Formula` (char), `Distribution`, `LikelihoodPenalty`.
  - `CoefficientCovariance` (needed by `cobraCoefCI`; free to keep).
- **Call-site edits in `performRegressions`:**
  - `fitglm` → `cobraFitglm`, `fitglme` → `cobraFitglme`, `coefCI(mdl)` → `cobraCoefCI(mdl)`.
  - Line 206: `double(mdl.Coefficients(j,{…}))` → `mdl.Coefficients{j,{'Estimate','SE','tStat','pValue'}}`.
  - All other lines are unchanged.
- **Formula parser scope** (shared private helper; see §6).
- **Size:** about 220 lines for the IRLS, Firth, statistics and warnings, plus the shared parser and design builder (about 180 lines, §6).

---

## 3. fitglme — replacement `cobraFitglme`

### 3.1 Syntax subset needed
- `cobraFitglme(tbl, formula, 'Distribution', d)` with `d ∈ {'normal','binomial'}`.
- The formula contains fixed main effects (and `:`/`*` if supported) plus **one or more `(1|g)` random-intercept terms on different grouping variables**.
- Any other random-effects form errors by name: `(x|g)`, `(1|g1:g2)` and `(-1+x|g)`. `performRegressions` cannot pass them anyway (§1.2).

### 3.2 MathWorks semantics (defaults) [DOC-fitglme]

| Setting | Default | Notes |
|---|---|---|
| `FitMethod` | `'MPL'` | maximum pseudo-likelihood; alternatives REMPL / Laplace / ApproximateLaplace |
| `CovariancePattern` | `'Isotropic'` for scalar random-effects terms | — |
| `DispersionFlag` | `false` for binomial and Poisson | dispersion fixed at 1.0; "applies only with MPL or REMPL". Normal: "always estimates the dispersion". |
| `DummyVarCoding` | `'reference'` | — |
| `Optimizer` | `'quasinewton'` | options `TolFun` 1e-6, `TolX` 1e-12, `MaxIter` 10000 |
| `PLIterations` | 100 | — |
| `PLTolerance` | 1e-8 | — |
| `InitPLIterations` | 10 | for Laplace only |
| `StartMethod` | `'default'` | — |
| `EBMethod` | `'Auto'` | — |
| `CheckHessian` | false | — |
| `Exclude` | all rows without NaN | — |

- **Model** [DOC-GLME-models]: y_i|b ~ Distr(μ_i, σ²w_i); g(μ) = Xβ + Zb + δ; b ~ N(0, σ²D(θ)); observations conditionally independent given b. NaN rows are excluded.
  - The **MPL algorithm itself is not documented** [DOC-GLME-models; MATLAB Answers 2173100 says the docs lack it].
  - Standard reference: Wolfinger & O'Connell (1993), J. Stat. Comput. Simul. 48:233-243 (PQL/MPL). Breslow & Clayton (1993), JASA 88:9-25 (PQL).
  - Inferred algorithm, UNCONFIRMED in detail:
    1. Working response z = η + (y−μ)g′(μ) and working weights w = 1/(g′(μ)²V(μ)).
    2. Fit a weighted LME to z by **ML** (MPL; REML for REMPL) with residual variance σ²/w. **σ² is fixed at 1 for binomial with DispersionFlag false**; that it is fixed inside the pseudo-LME is UNCONFIRMED.
    3. Update η = Xβ̂ + Zb̂ (BLUPs).
    4. Repeat until the change is below PLTolerance (criterion UNCONFIRMED, e.g. relative change of η or of β, θ), up to PLIterations.
- **Normal + identity link:** the pseudo-data equal y and the weights equal 1, so MPL reduces to an **ML linear mixed model** (= `fitlme(…,'FitMethod','ML')`). This is inferred and UNCONFIRMED, but follows from the algorithm.
  - [DOC-LME-est] gives the profiled ML objective (β and σ² profiled out, optimised over θ; Cholesky parameterisation Λ(θ) of D).
- **LogLikelihood under MPL** = the maximised log-likelihood of the pseudo-data at the final PL iteration [DOC-GLME]. It is not the binomial likelihood. Not read by the call site.

### 3.3 Coefficients and inference
- `Coefficients` is a **dataset array** with columns `Name, Estimate, SE, tStat, DF, pValue, Lower, Upper` [DOC-GLME]. **DF uses `DFMethod="Residual"`, so DF = n − p** (p = fixed-effects coefficients) [DOC-GLME; DOC-GLME-coefCI].
- **pValue and Lower/Upper use t(n−p) even for binomial/Poisson with fixed dispersion.** [NUM] on the [DOC-GLME-models] `mfr` Poisson Laplace example:
  - Intercept: tStat 9.1875 with DF 94 gives p 9.8194e-15. t(94) gives 9.8202e-15; normal would give 4.0e-20.
  - Lower 1.1515 = 1.4689 − t₀.₉₇₅(94)·0.15988.
  - This is **unlike fitglm**, whose p-values are normal.
- SE for MPL fits: covariance of β̂ "based on the fitted linear mixed-effects model from the final pseudo likelihood iteration" (search-result summary of [DOC-GLME]; the class page fetched here did not show this sentence, so treat the exact wording as UNCONFIRMED). Presumably Cov(β̂) = σ²(XᵀV⁻¹X)⁻¹ with V = W⁻¹ + ZDZᵀ, conditional on θ̂ (UNCONFIRMED).
- `CoefficientNames`: the intercept is labelled `(Intercept)` [DOC-GLME].

### 3.4 coefCI for GLME [DOC-GLME-coefCI]
- `feCI = coefCI(glme)`: default `Alpha` 0.05.
- `DFMethod` default `'residual'`, meaning a constant n − p. `'none'` means infinite DF. **`'satterthwaite'` is not listed** for GLME, unlike LME.
- Output: p×2 matrix with rows in `fixedEffects` order. A second output `reCI` exists and is not used by the call site.
- Published: `mfr` Intercept CI [1.1515, 1.7864] and time_dev [−1.7395, 1.5505]. These come from `mfr.mat`, a Statistics dataset, and a Poisson Laplace fit, outside our scope. Usable only to check `cobraCoefCI` arithmetic from Estimate, SE and DF.

### 3.5 Rsquared for GLME [DOC-GLME]
- Effective weights w_i^eff = w_i / v(f_i), with f_i = g⁻¹(x_iᵀβ̂ + z_iᵀb̂ + δ_i), i.e. **conditional** fitted values including BLUPs.
- SSE = Σ w^eff (y − f)².
- SSR = Σ w^eff (f − ȳ)², with ȳ the "weighted average of the response" (weighted by w^eff: UNCONFIRMED).
- With an intercept, **SST = SSE + SSR**, not the centred total.
- `Ordinary = 1 − SSE/SST`; `Adjusted = 1 − (SSE/SST)(n−1)/(n−p)`.
- For binomial, v(μ) = μ(1−μ), so w^eff = 1/(μ(1−μ)): an unusual R². For normal, w^eff = 1, so this is the ordinary conditional R² with SST = SSE + SSR.
- **This differs from fitglm's R²** and must be implemented separately.

### 3.6 Failure behaviour
- The call site wraps `fitglme` in `try`, so any error gives a dropped result.
- MathWorks warnings (PL non-convergence, a non-positive-definite Hessian only with CheckHessian, etc.) also drop the result through `lastwarn`. Their exact identities and triggers are UNCONFIRMED.
- Replacement: warn on PL non-convergence and on inner optimiser non-convergence. Error on an unsupported formula. Do **not** warn on a boundary fit (σ_b → 0); whether MathWorks does is UNCONFIRMED.
- A grouping variable with one level: θ is not identifiable from the data, and the fit converges to the boundary or something arbitrary. MathWorks behaviour is UNCONFIRMED.

### 3.7 Proposed implementation
- **LME core:**
  - Random intercepts only. Z = [Z₁ … Z_K], with one indicator block per term. Use `cobraGrp2idx` for the level order (any type; the grouping variable is always treated as categorical).
  - D = blkdiag(θ_k² I).
  - Profiled ML deviance via the Cholesky of (ΛᵀZᵀWZΛ + I) (Bates et al. 2015, J. Stat. Softw. 67(1) lme4 formulation): β̂(θ) by GLS, σ̂²(θ) profiled (normal) or fixed at 1 (binomial).
  - Optimise over log θ_k (K = 1-3) with **`fminsearch`** (base MATLAB) or a small quasi-Newton.
  - BLUPs b̂ = ΛΛ… solved from the same factorisation.
  - Cov(β̂) = σ²(XᵀV⁻¹X)⁻¹ via the factorisation.
  - q = total number of levels (≤ n), so dense q×q is fine for n ≤ a few thousand.
- **PL loop** (binomial):
  - Start from a GLM fit (μ₀ as fitglm). Iterate the pseudo-data, call the LME core, and stop when ‖Δη‖∞/(1+‖η‖∞) < 1e-8 (document the choice) or after 100 iterations, with a warning.
- **Output struct:**
  - `Coefficients`: a **table** with `Name, Estimate, SE, tStat, DF, pValue, Lower, Upper`.
  - `CoefficientNames`, `NumObservations`, `DFE`.
  - `Rsquared.Ordinary`/`Adjusted` (conditional, §3.5).
  - `LogLikelihood` (pseudo-data ML, MPL semantics), `Dispersion`, `Variables`, `Formula`, `Distribution`, `FitMethod` (`'MPL'`), `CoefficientCovariance`.
  - Random-effects standard deviations (for tests) and `randomEffects` (b̂) as fields.
- **Size:** about 300-350 lines plus tests of about 220. It is the riskiest item in G3.

### 3.8 Independent references and their feasibility
- **Normal:** `statsmodels.regression.mixed_linear_model.MixedLM`.
  - Use `.fit(reml=False)` with `groups=` for a single `(1|g)`. Two crossed terms need `vc_formula` with a single dummy group, or use **Julia MixedModels.jl** (`fit(MixedModel, @formula(y ~ x + (1|g1) + (1|g2)), df; REML=false)`). Julia is installed, the package is not.
  - Compare β̂, σ̂², σ̂_b² and the log-likelihood.
  - **Compute the SE reference as σ̂²(XᵀV̂⁻¹X)⁻¹ in the script** from the fitted variance components. statsmodels `bse_fe` comes from the observed joint Hessian, which differs slightly in the ML case (UNCONFIRMED magnitude). MixedModels.jl `stderror` is the GLS form.
- **Binomial MPL: no maintained Python/Julia reference implements MPL/PQL with the scale fixed at 1.**
  - statsmodels `BinomialBayesMixedGLM` is variational Bayes: **not the same estimator; unusable for value checks.**
  - R `MASS::glmmPQL` estimates the scale and R is not installed.
  - lme4 `glmer` and MixedModels.jl GLMM are Laplace/AGQ, a different estimator: usable only as a loose sanity bound when random-effect variance is small and clusters are large.
  - Feasible plan:
    - (1) A **NumPy/SciPy reference implementation of Wolfinger-O'Connell MPL** in the feature folder, written independently of the MATLAB code from the paper, with σ²=1 and ML on pseudo-data. Ideally a different agent writes it, to reduce shared-author risk.
    - (2) Structural checks: σ_b → 0 reproduces fitglm binomial (unpenalised) estimates; the normal case equals MixedLM.
    - (3) A **parity section against `fitglme`** where the Statistics Toolbox exists.
  - State honestly in the test header that the binomial GLME numbers have no third-party reference.
- No base-MATLAB dataset has published fitglme numbers: the `mfr` example needs Statistics `mfr.mat` and uses Laplace/Poisson. `patients.mat` (`Location` has 3 levels) can serve as base-MATLAB data for normal and binomial GLME tests, with reference values from the scripts.

---

## 4. coefCI — replacement `cobraCoefCI(mdl, alpha)`

- **LinearModel and GeneralizedLinearModel** [DOC-LM-coefCI, DOC-GLM-coefCI]:
  - `ci = coefCI(mdl)` gives 95%. `coefCI(mdl, alpha)` gives 100(1−α)%.
  - "Wald method": b_i ± t(1−α/2, n−p)·SE(b_i).
  - k×2 output, rows in CoefficientNames order.
  - **The t quantile is used even for GLMs with fixed dispersion.** [NUM] Poisson doc example: 1.0405 ± t₀.₉₇₅(97)·0.022122 = [0.99659, 1.08441], published [0.9966, 1.0844]. Normal would give 1.08386. 99%: t₀.₉₉₅(97) gives 1.09862, published 1.0986, normal 1.09748.
- **GLME** [DOC-GLME-coefCI]: the same form with DF = n − p (`DFMethod='residual'`).
- Since all three model kinds use b ± t₁₋α/2(DFE)·SE, a **single 20-30-line function** reading `mdl.Coefficients.Estimate`, `.SE` and `mdl.DFE` serves all call sites. It reuses `cobraTinv`.
  - Under rank deficiency, MathWorks DFE uses the rank (UNCONFIRMED).
  - Firth CI: whether MATLAB uses Wald-t or profile-penalised CIs is UNCONFIRMED. The doc formula suggests Wald.
- Test: the published Poisson numbers above (inputs re-entered), the `mfr` intercept CI from Estimate, SE and DF=94, and alpha = 0.01.

---

## 5. fitlm — replacement `cobraFitlm`

### 5.1 Syntax subset
- `mdl = cobraFitlm(x, y)`: x is a numeric or logical vector or matrix (continuous), **or a categorical vector**; y is a numeric vector. The call sites pass no options.
- **Types of X:** [DOC-fitlm] lists "Data Types: single | double" for X, but its own example fits `fitlm(Year_reordered, MPG)` with a categorical vector after `reordercats`, so a **categorical vector X is accepted** and treated as categorical (first category = reference).
  - Logical X: presumably converted to double (UNCONFIRMED).
  - String/cellstr X: UNCONFIRMED; MathWorks may error. If it does, the original `exploreMetadataCorrelations` already fails on text metadata columns.
  - Recommendation: support numeric, logical and categorical. **Error naming the type for others unless parity shows MathWorks accepts them.**

### 5.2 Semantics
- Intercept by default; "do not include a column of 1s" [DOC-fitlm]. The fit uses QR [DOC-fitlm]. Rows with NaN in x or y are excluded [DOC-fitlm]. Names: `(Intercept)`, `x1`, `x2`, … for matrix input [DOC-LM].
- Categorical vector: coefficients `x1_<level>`; naming for an unnamed vector is UNCONFIRMED. The call site only reads row 2 by position, and for a categorical X row 2 is the first non-reference level.
- Coefficients: Estimate, SE, tStat = Estimate/SE, pValue from t(DFE) [DOC-LM; standard OLS; the [DOC-fitlm] carsmall output is consistent].
- `Rsquared.Ordinary = SSR/SST` with SST = Σ(y−ȳ)² [DOC-LM]. With an intercept this equals 1 − SSE/SST. `Adjusted = 1 − (SSE/SST)(n−1)/DFE` (same form as [DOC-GLM]).
- **Rank deficiency** (e.g. a constant metadata column): MathWorks warns. The message "Regression design matrix is rank deficient to within machine precision." and ID `stats:LinearModel:RankDefDesignMat` are UNCONFIRMED. The `lastwarn` gate in `exploreMetadataCorrelations` relies on *some* warning being issued, so the replacement must warn and use regress-like basic-solution handling.
  - The first slice's `cobraRegress` already implements pivoted-QR rank detection and the `RankDefDesignMat` warning (semantics note §13). **Reuse its core**, but return per-coefficient SE, t and p, which `cobraRegress` does not give directly (it gives `bint`; SE can be recovered as (bint(:,2)−b)/tinv).
  - Simpler: `cobraFitlm` = `cobraFitglm` normal path with an auto-generated table and formula `y ~ x1 + … `.
- Published numbers on base-MATLAB data: none. `carsmall` is Statistics-only, so its published `fitlm(X,MPG)` table (Intercept 47.977/3.8785/12.37/4.8957e-21, R² 0.752, adj 0.744, n=93) could only be used by **re-entering the 100-row carsmall data in the test**. The spec allows this, but it is 100×4 numbers.
  - Better: `patients.mat` (base) with statsmodels OLS reference values, and the carsmall categorical example (`Model_Year` 70/76/82, Intercept 17.69, `Model_Year_76` 3.8839, `Model_Year_82` 14.02, R² 0.531, adj 0.521, n=94) only if the data are re-entered.
- References: statsmodels `OLS` (`params, bse, tvalues, pvalues, rsquared, rsquared_adj, nobs`).
- **Size:** about 80 lines on top of the shared core.

---

## 6. Shared formula and design-matrix helper (private to `toolboxFree/`)

### 6.1 Grammar to support (only forms that occur or are trivially implied)
- `resp ~ t1 + t2 + …`, whitespace-insensitive.
- Each fixed term is either a variable name (main effect) or `a:b` (two-way interaction).
- Optional: `a*b` → `a + b + a:b` [DOC-wilk]. This is cheap, and lets the base-MATLAB `patients` doc example run as published; supporting `- a:b:c` term removal is then also needed for that example, about 10 extra lines. If removal is out of scope, use the expanded formula in the test.
- Random terms (GLME only): `(1|g)`, possibly several.
- Implicit intercept. Explicit `1`/`-1` and `^`, `/` and nested forms are **unsupported and raise an error naming the term**.

### 6.2 Variable classification (table input)
- Numeric (non-logical): continuous.
- Logical, categorical, string, cellstr, char: categorical [DOC-fitglm].
- Level order: `cobraGrp2idx` (category order for categorical; first appearance for text). **Logical level order is UNCONFIRMED**: false, true sorted? The resulting name `x_true` is UNCONFIRMED as well.
- Interaction of continuous × categorical: product columns named `a:b_level` [DOC-fitglm example]. Categorical × categorical: `a_l1:b_l2` (UNCONFIRMED naming; not used by call sites).

### 6.3 Missing values
Exclude a row if any variable in the formula (response, fixed and grouping variables) is NaN, `<missing>`, `<undefined>`, `""` or `''` [DOC-fitglm]. Keep `Variables` = the full table.

### 6.4 Coefficient order
- Main effects first, then interactions [DOC-fitglm example output; DOC-wilk is silent].
- Within an order, follow **table variable order or formula order? UNCONFIRMED.** In `performRegressions` both orders coincide, because the table is subset as `[name response predictors]` in formula order. Implement formula order and test with matching orders. Parity settles the general case.

### 6.5 Size
About 150-180 lines plus about 80 lines of tests. It could be exercised through `testCobraFitglm`. Per III-Naming a private helper is tested through its public callers.

---

## 7. fitcsvm — replacement `cobraFitcsvm`

### 7.1 Syntax subset
- `Mdl = cobraFitcsvm(X, Y)` with no options, numeric X (n×p) and Y with exactly 2 classes.
- Returns a struct with `Beta` (p×1), `Bias`, `Alpha`, `SupportVectors`/`IsSupportVector`, `ClassNames`, `KernelParameters` and `ConvergenceInfo`.
- One-class Y and any option raise errors naming them.

### 7.2 MathWorks defaults for this call [DOC-fitcsvm]

| Setting | Default |
|---|---|
| `KernelFunction` | `'linear'` (two-class) |
| `Standardize` | false |
| `BoxConstraint` | 1 |
| `KernelScale` | 1 |
| `KernelOffset` | 0 for SMO |
| `Solver` | **`'SMO'`** (ISDA only if OutlierFraction > 0; L1QP needs Optimization Toolbox) |
| `DeltaGradientTolerance` | 1e-3 |
| `GapTolerance` | 0 |
| `KKTTolerance` | 0 |
| `IterationLimit` | 1e6 |
| `CacheSize` | 1000 MB |
| `ShrinkagePeriod` | 0 |
| Initial `Alpha` | zeros |
| `Prior` | `'empirical'` |
| `Cost` | [0 1; 1 0] |
| `Weights` | ones, normalised to the class prior |

- **Box constraint per observation:** C_j = n·C₀·w_j* [DOC-fitcsvm]. With unit weights and empirical prior, w_j* = 1/n, **so C_j = 1 for all j** (inferred from the stated normalisation).
- **Classes:** `ClassNames` is the distinct labels in sorted order (0, 1), and "the second class is the positive class" [DOC-fitcsvm example text]. So label 1 maps to y = +1 and label 0 to −1. Whether numeric 0/1 maps exactly this way is inferred from the order rule; UNCONFIRMED by an explicit sentence.
- **Score / primal:** f(x) = xᵀβ + b. Primal: min ½‖β‖² + CΣξ_j subject to y_j f(x_j) ≥ 1 − ξ_j, ξ ≥ 0. Dual: min ½ΣΣα_jα_k y_j y_k G(x_j,x_k) − Σα_j subject to Σα_j y_j = 0 and 0 ≤ α_j ≤ C [DOC-fitcsvm].
  - For the linear kernel with KernelScale 1 and no standardisation, **β = Σα_j y_j x_j**. This is standard and follows from the dual; the doc does not print it, so it is UNCONFIRMED as text.
- SMO reference: Fan, Chen & Lin (2005), JMLR 6:1889-1918, working-set selection using second-order information [DOC-fitcsvm reference 2]. The convergence criterion `DeltaGradientTolerance` is the gap between the maximal violating pair's gradients (UNCONFIRMED exact definition). It is the same quantity as libsvm's `eps`.
- Missing response rows are removed [DOC-fitcsvm]. The call site has no NaN.
- **Uniqueness:** the primal objective is strictly convex in β, so **β is unique**. b and α need not be unique (Burges & Crisp 1999, NIPS "Uniqueness of the SVM solution"). The call site reads only β. MathWorks' β is only accurate to about the SMO tolerance (1e-3 gradient gap), so tests compare with a tolerance, not exactly.

### 7.3 Implementation options and the Principle IV trade-off
- **(A) Plain-MATLAB SMO with WSS2** (Fan-Chen-Lin), the **same algorithm class as MathWorks' default**:
  - For the linear kernel, kernel columns are computed on the fly as y∘(X(x_iᵀ)) without a Gram matrix.
  - Memory O(np), cost O(np) per iteration. For n ≈ 4000 and p = 40 that is about 3e5 flops per iteration, and typically O(n)-O(10n) iterations, so seconds.
  - No solver needed, so the test can be **Tier 1 with no requirement (FR-010)** and the function runs without any QP solver.
  - About 150-200 lines.
- **(B) Primal QP through `solveCobraQP`:**
  - Variables [β; b; ξ], (p+1+n). Q = blkdiag(I_p, 0, 0), c = [0; 0; C·1], A = [y∘X, y, I] ≥ 1, ξ ≥ 0.
  - It honours Principle IV ("solver-facing changes go through solveCobra*"), and gives an essentially exact β with Gurobi.
  - But it needs a configured QP solver: the test would declare a QP requirement and is no longer Tier 1, contradicting FR-010's "declaring no requirement". QP solvers on dense n×(p+1+n) constraints are fine for Gurobi but less robust with pdco/qpng. The result also differs from MathWorks by the SMO tolerance.
- **Recommendation: (A) as the implementation.**
  - SVM training is not a COBRA model optimisation problem, so Principle IV's solver-abstraction clause is not engaged; state this in research.md.
  - Use (B) only as an **optional cross-check section** in the test that runs when `solveCobraQP` has a QP solver and otherwise prints a skip message.
  - Expose `'DeltaGradientTolerance'`/`'IterationLimit'` (MathWorks names) only if a test needs tighter tolerance. Otherwise keep the narrow no-option syntax.
- **Bias:** libsvm convention, the mean of y_i − x_iᵀβ over free SVs (0 < α < C), else the midpoint of the bounds. MathWorks' rule is UNCONFIRMED. It is not read by the call site.

### 7.4 References and tests
- **scikit-learn `SVC(kernel='linear', C=1.0, tol=1e-3 / 1e-8)`** (libsvm, the same WSS2 SMO family):
  - Compare `coef_` with β and `intercept_` with b (b loosely).
  - `classes_` is sorted, and `coef_` refers to `classes_[1]` as positive, matching MathWorks' second class.
  - Do **not** use `LinearSVC` (liblinear): it regularises the bias and uses squared hinge by default, which is a different problem.
- Test data: deterministic overlapping 2-D/5-D clouds, plus a SCORE-like int8 matrix with two all-zero columns and duplicate rows with conflicting labels.
  - Check β within about 1e-2 relative of SVC(tol=1e-8) at the default tolerance, and within 1e-6 if a tight tolerance is used.
  - Check that zero columns give β = 0 exactly.
  - Check that the KKT conditions hold.
- There are no MathWorks doc numbers on base data: `fisheriris`/`ionosphere` are Statistics-only.

### 7.5 Size
About 180 lines plus about 150 lines of tests.

---

## 8. tsne — replacement `cobraTsne`

### 8.1 Syntax subset
- `Y = cobraTsne(X, 'Distance','euclidean', 'Algorithm','barneshut'|'exact', 'Perplexity',p, 'NumDimensions',2|3)`.
- Optional second output `loss` (KL divergence).
- Other options raise an error naming them. Optionally accept `'Exaggeration'`, `'LearnRate'` and `'Options'` (`MaxIter`) so tests can run short.

### 8.2 MathWorks semantics [DOC-tsne, DOC-tsne-alg]

| Setting | Default |
|---|---|
| `Algorithm` | `'barneshut'` |
| `Distance` | `'euclidean'` |
| `NumDimensions` | 2 |
| `NumPCAComponents` | 0 |
| `Perplexity` | 30 |
| `Exaggeration` | 4 |
| `LearnRate` | 500 |
| `Standardize` | false |
| `Theta` | 0.5 (BH only) |
| `Options` | `MaxIter` 1000; `TolFun` 1e-10, exit when **‖gradient of KL‖ < TolFun** |
| `InitialY` | **`1e-4*randn(N,NumDimensions)`**, from the global stream, so `rng(seed)` reproduces MathWorks' initial Y |

- **NaN rows are removed** and Y has n = number of NaN-free rows [DOC-tsne].
- Algorithm [DOC-tsne-alg]:
  - **Squared** distance in the Gaussian.
  - p_{j|i} with σ_i found by binary search to perplexity 2^H (log₂ entropy). Bounds and tolerance are UNCONFIRMED.
  - p_ij = (p_{j|i} + p_{i|j})/(2N).
  - Student-t q_ij; KL(P‖Q); gradient 4ΣZ(p_ij − q_ij)q_ij(y_i − y_j).
  - **Exaggeration in the first 99 iterations.**
  - "adaptive learning" citing Jacobs (1988), which implies delta-bar-delta gains. Each step combines the previous step and the current gradient, i.e. momentum.
- BH: "min(3*Perplexity, N−1)" nearest neighbours via `knnsearch` [DOC-tsne]; the van der Maaten (2014) JMLR 15:3221 / arXiv:1301.3342 approximation.
- **UNCONFIRMED:**
  - The momentum schedule (van der Maaten 2008 uses 0.5 for t < 250 and 0.8 after).
  - The gain rule (vdM: +0.2 / ×0.8, min 0.01).
  - The binary-search tolerance.
  - Whether the BH P is renormalised after symmetrisation.
  - The tree type.
  - Whether Y is centred each iteration.
  - The error message when Perplexity ≥ N.
- The algorithm is randomly initialised and non-convex, so **coordinates cannot be compared with MathWorks** even for the same seed, unless every UNCONFIRMED detail matched.

### 8.3 Scale problem and proposal
- n can reach about 7,000, with D in the thousands. Exact t-SNE needs N×N P and Q: about 392 MB each at N = 7000, several such arrays, and 1000 iterations of O(N²). That conflicts with the memory-safety note (oomd kills).
- **Proposal:**
  - **P:** as MathWorks BH, from k = min(3·perp, N−1) nearest neighbours.
    - Distances are computed in row blocks: ‖a‖² + ‖b‖² − 2abᵀ, then a partial sort. Memory is O(N·block).
    - Binary search per point on the k distances; a sparse symmetric P.
  - **Repulsive forces:**
    - **Exact**, computed in row blocks: O(N²) time, O(N·block) memory. This is equivalent to Barnes-Hut with θ = 0, i.e. more accurate than MathWorks' θ = 0.5.
    - About 0.1-0.5 s per iteration at N = 7000, so a few minutes per embedding. The DEMETER loop runs up to 24 embeddings, so runtime goes up notably but stays feasible.
    - Option for later: FFT-interpolation repulsion (Linderman et al. 2019, Nat Methods 16:243, "FIt-SNE"), which is vectorisable in MATLAB. Do not attempt a quadtree in interpreted MATLAB.
  - `'exact'`: dense P from all pairs, for N ≤ about 2000, with a guard.
- **Optimiser:** vdM 2008 (gradient descent with momentum 0.5→0.8 at iteration 250 and Jacobs gains, min 0.01), exaggeration 4 for iterations 1-99, learning rate 500, stop at MaxIter or when ‖grad‖ < 1e-10.
- **Size:** about 250-300 lines.

### 8.4 Test measures (no coordinate comparison; spec US3-AS3)
1. **P matrix** (deterministic): compare with scikit-learn's private `sklearn.manifold._t_sne._joint_probabilities` (exact, from squared distances) and `_joint_probabilities_nn` (kNN/BH) at the same perplexity. The tolerance follows sklearn's binary-search tolerance (1e-5 entropy), e.g. abs 1e-6. Private API: pin the sklearn version in the header.
2. **Reproducibility:** `rng(1); Y1 = cobraTsne(...); rng(1); Y2 = ...` gives `isequal(Y1,Y2)`.
3. **Neighbourhood preservation:**
   - Trustworthiness T(k) (Venna & Kaski 2001; `sklearn.manifold.trustworthiness`), k = 5-10, on a deterministic dataset with known clusters (e.g. 3 Gaussian blobs, n = 150, D = 20, stored in the test or generated with fixed `rng`).
   - Require T_cobra ≥ T_sklearn − 0.02, where T_sklearn is from `TSNE(perplexity=…, init='random', early_exaggeration=4, learning_rate=500, method='exact'|'barnes_hut', random_state=…)`. Note sklearn's exaggeration phase is fixed at 250 iterations, not 99.
   - Also require leave-one-out 1-NN cluster-label accuracy in Y ≥ 0.95.
   - Implement trustworthiness in the MATLAB test (about 15 lines). Cross-check it once against sklearn on the same Y.
4. **KL loss:** cobra `loss` within about 10% of sklearn's `kl_divergence_` (exact method, same P).
5. **Edge cases:** NaN rows removed; N = 11 with perplexity 5 (smallest call-site case); NumDimensions 3.

---

## 9. Cross-cutting decisions for the plan

1. **Model objects become structs** (`cobraFitglm`/`cobraFitglme`/`cobraFitlm`).
   - The `regressions` output of `performRegressions` changes class: a Principle II public-interface change. Methods such as `predict` are lost for external users.
   - Options: (a) accept and document in the header and the PR; (b) a lightweight `classdef` with the same property names and a `coefCI` method (methods dispatch on the class and do not shadow the path function, though this is arguably against the spirit of FR-001); (c) keep the MathWorks functions when the toolbox is present, which contradicts FR-009.
   - Recommend (a) plus `cobraCoefCI`. Maintainer decision.
2. **Firth version gate:** keep the `ver >= 24.2` gate so each MATLAB version's results stay as they are now (Principle II), even though the replacement makes Firth available everywhere. Maintainer decision.
3. **Warnings drive results** in `performRegressions` and `exploreMetadataCorrelations` (`lastwarn`).
   - Each replacement must document exactly when it warns.
   - Its helpers (`cobraTinv`, `cobraTcdf`, `cobraGrp2idx`, `fminsearch`) must not warn in normal use. `fminsearch` warns only through its own options/display; call it with `Display` 'off' and check `exitflag` instead.
4. **p-value distribution differs by model kind:**
   - fitglm binomial: normal.
   - fitglm normal and fitlm: t(DFE).
   - fitglme (all): t(n−p).
   - coefCI: t(DFE) for all.
   - All are confirmed by [NUM] on published output. This is easy to get wrong.
5. **Reference environment:** statsmodels, scikit-learn and firthlogist are **not installed** anywhere on this machine (at the time of this pass; since installed in a scratch virtual environment outside the repository). Julia is installed but MixedModels.jl is not. Create a scratch venv outside the repository (FR-016) and pin versions in the test headers.

## 10. UNCONFIRMED items that matter (summary)

| # | Item | Affects | Settle by |
|---|---|---|---|
| U1 | fitglm Firth: SE (I(β̂)⁻¹ vs penalised Hessian), p (Wald-normal vs PLR), penalised deviance, convergence | every R2024b+ PERSEPHONE logistic result | parity |
| U2 | fitglm normal + jeffreys-prior = OLS? | every R2024b+ continuous PERSEPHONE result | parity (expected yes) |
| U3 | fitglm binomial SSE in Rsquared = raw Σ(y−μ̂)² | `R2` column | parity |
| U4 | String-array predictor reference level = first appearance (proven for cellstr) | `Sex_male` vs `Sex_female` naming and sign | parity; a small doc check could also do |
| U5 | Warning IDs/conditions: separation, rank deficiency (GLM, LM), GLME non-convergence | which results are dropped | parity |
| U6 | fitglme MPL internals: σ² fixed in the pseudo-LME for binomial, convergence criterion, SE conditional on θ̂, ȳ weighting in the GLME R² | all GLME numbers | parity; no third-party reference |
| U7 | Coefficient order when formula order ≠ table order | naming only (not at current call sites) | parity |
| U8 | fitlm(X,y) with string/cellstr/logical X | `exploreMetadataCorrelations` | parity |
| U9 | fitcsvm numeric 0/1 → positive class 1; β = Σα y x; bias rule | sign of weights (critical), bias (unused) | parity; sklearn convention agrees |
| U10 | tsne momentum, gains, binary-search tolerance, BH details | none measurable (coordinates not compared) | — |

## 11. Size estimate (honest)

| Item | Source lines | Test lines | Notes |
|---|---|---|---|
| shared formula/design helper (private) | 150-180 | via callers | |
| `cobraFitglm` (IRLS, Firth, warnings, stats) | 200-250 | 200 | `patients` doc example gives exact published numbers on base data |
| `cobraFitlm` | 60-100 | 120 | reuses core; no base-data doc numbers |
| `cobraCoefCI` | 25-40 | 60 | published Poisson CI numbers usable |
| `cobraFitglme` (LME core and MPL loop) | 300-350 | 220 | highest risk; binomial has no third-party reference |
| `cobraFitcsvm` (SMO WSS2) | 150-200 | 150 | sklearn SVC reference |
| `cobraTsne` (kNN-P, blockwise exact repulsion, vdM optimiser) | 250-300 | 150 | measured by trustworthiness / P / KL |
| Python and Julia reference scripts (feature folder) | about 400-500 | — | incl. NumPy MPL and NumPy Firth |
| Call-site edits | about 15 lines in 5 files | — | `performRegressions` (4 lines), 2× `fitlm` lines, `optimalScores` (1), `producetSNEPlots` (2) |

Total is about 1,150-1,400 source lines plus about 900 test lines plus about 450 reference-script lines. `cobraFitglme` with its reference is about 40% of the effort.


---

<a id="g4"></a>

# G4 research notes: figures, parallel leftovers, test requirements

Feature `20261111-152503-toolbox-free-remaining`, read-only planning research, 2026-11-11.
No repository file was edited, MATLAB was not run, no MathWorks source was read or copied.
"UNCONFIRMED" = not stated by the cited MathWorks page; to be settled by a parity run on an
installation with the toolbox, or by a run on base MATLAB.

Line numbers refer to the working tree at 62812e7a4.

---

## Summary of new facts that change the spec

1. **`HeatMap` (Bioinformatics, capital H) is missing from the inventory.** `plotEssentialRxns.m`
   lines 70, 74, 78, 82 call `HeatMap(...)`; `redbluecmap` is only its constructor argument and
   the colour map is immediately replaced by `colormap(hm, mymap)` (lines 71, 75, 79, 83). The
   replacement target is the heat map, not `redbluecmap`.
2. **biograph was removed from MATLAB in R2022b** (MathWorks Answers, staff:
   https://www.mathworks.com/matlabcentral/answers/1867118 and the graphconncomp thread
   https://www.mathworks.com/matlabcentral/answers/2139451 — "removed in release R2022b
   according to the Bioinformatics Toolbox Release Notes"; release-notes page itself not opened,
   UNCONFIRMED at source). On R2024b+ `bio_draw_by_rxn(..., drawMap='true')` fails even with
   the Bioinformatics Toolbox. Its tests self-skip with `if ~exist('biograph','file')`.
3. **`testConnectedComponents` is not stale.** `connectedComponents.m:253/255` calls
   `graph_analysis` (`external/analysis/graph_analysis/graph_analysis.m`), which calls
   `bwlabel(group_mat,4)` at line 237 unconditionally. `bwlabel` is Image Processing Toolbox
   (https://www.mathworks.com/help/images/ref/bwlabel.html). Under the external/ read-only rule
   the test keeps `image_toolbox` (KEEP) — SC-003 would then count 3 toolbox skips, not 2 —
   unless the maintainer decides to change `connectedComponents` (src) to stop calling
   `graph_analysis` (algorithm change; needs a decision).
4. **`testPartition` is not stale either.** `partition.m:34` asserts
   `license('test','bioinformatics_toolbox') == 1` (hard error), and lines 73 and 97 call
   `range(...)` — a Statistics function (https://www.mathworks.com/help/stats/range.html, no
   "moved to MATLAB" note). Neither is in the inventory. Fix in src: drop the assert (graph code
   now uses base `graph`/`conncomp`) and use `max(C) - min(C)`. Then REMOVE. (Whether `range`
   resolves on base MATLAB through some other class method: UNCONFIRMED; check with
   `which range -all` on base MATLAB.)
5. **External `violinplot` reaches `ksdensity`.** `external/base/utilities/violinPlots/Violin.m:117`
   calls `ksdensity`. Default `plotType` of `makeViolinPlots`/`analyzeMgPipeResults` is
   `'ViolinPlot'`, so the default path of the boxplot call site needs Statistics through
   external/ code. The external `violinplot.m` also shadows base MATLAB `violinplot` (base since
   R2024b, https://www.mathworks.com/help/matlab/ref/violinplot.html). Other src callers:
   retrieveModelStats (lines 111/114 unreachable — see defects; 190/194/200 reachable with
   infoFile), plotATPTestResults/plotBiomassTestResults (inside `try` without `catch`, so the
   error is swallowed), computeReconstructionFeatures 214–232, dimensionalityReduction... 194,
   plotTestSuiteResults 95. Plan must decide: leave (external), or a src `cobraViolinplot`.
6. **Dead or broken code around three inventory items**: `plotconfusion` is inside `if 0`
   (plotThermoKernelExtractStats.m:38–47); `checkFullRowRankFRK.m` is a script whose line 6
   calls `makeLoopToyModel`, which exists nowhere in the repository (only
   `deprecated/_testTopology/lrsLPdriver.m` mentions it), so `syms`/`pretty` (lines 52/55) are
   never reached; `spmd` and `getCurrentTask` are reachable only when a pool exists.
7. **An existing src linkage implementation**: `src/analysis/ecosystem/computeEcosystemLinkage.m`
   implements `'single'|'complete'|'average'|'weighted'|'ward'` on a square distance matrix, in
   MATLAB `linkage` format, matching SciPy tie-breaking. A `cobraLinkage` is not needed; reuse it
   (with `squareform`-free conversion from `cobraPdist` vector output).
8. **testSteadyCom fails on base MATLAB once its requirement is removed**: `parWorks` is set
   by `try getParallelPool()` (line 25–30), which no longer throws, so line 440
   `parcluster(parallel.defaultClusterProfile)` runs without the toolbox. Use
   `parWorks = isParallelToolboxAvailable();`.
9. **testCreatePanModels' key is malformed**: `'Statistics Toolbox'` lower-cases to
   `'statistics toolbox'`, not a `toolboxInfo` field in `prepareTest.m:78–84`, so the check falls
   back to `license('test','statistics toolbox')` (feature names are `Statistics_Toolbox`) —
   probably always false, i.e. the test skips everywhere (UNCONFIRMED; check on a machine with
   Statistics).

---

## PART A — figures and miscellaneous

### A1. `boxplot` — makeViolinPlots.m

File: `src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/makeViolinPlots.m`
Callers: `analyzeMgPipeResults.m:127, 139, 157` (passes `plotType`; default `'ViolinPlot'`,
`makeViolinPlots.m:34`, `analyzeMgPipeResults.m:40`).

Call sites:
- line 102 (no stratification): `boxplot(plotdata)` — `plotdata` column vector; preceded by
  `figure; hold on`; followed by `set(gca,'FontSize',16)`, `ylim([min max])`, `ylabel(unit)`,
  `title(varname)`, `set(gca,'TickLabelInterpreter','none')`, `print(...,'-dpng','-r300')`,
  `close all`.
- line 199–203 (stratified):
  ```
  boxplot(plotdata,sampleStratification)
  h = findobj(gca,'Tag','Box');
  for j=1:length(h)
      patch(get(h(j),'XData'),get(h(j),'YData'),cols(j,:),'FaceAlpha',.5);
  end
  ```
  `sampleStratification` is a cell array of char (group per sample); `cols` from lines 149–162
  (2 groups `[1 0 0; 0 0 1]`, 3 groups `[0 1 0; 1 0 0; 0 0 1]`, else `rand`). Then
  `xtickangle(45)` if > 6 groups, ylim, ylabel, title, `print`.
- No return value is used; output = PNG files.

Doc (https://www.mathworks.com/help/stats/boxplot.html, Statistics and Machine Learning
Toolbox):
- grouping: "sorts character and string grouping variables in the order they initially appear
  in the data" (first appearance);
- Whisker default 1.5; outliers beyond q3 + w(q3 − q1) / below q1 − w(q3 − q1);
- "The bottom and top of each box are the 25th and 75th percentiles of the sample" — quantile
  method not stated (UNCONFIRMED; parity needed);
- Tags: `'Box'`, `'Outliers'`, traditional: `'Median'`, `'Upper Whisker'`, `'Lower Whisker'`,
  `'Upper Adjacent Value'`, `'Lower Adjacent Value'`;
- positions default `1:NumGroups`.

Hidden semantic of the call site: `findobj` returns children newest-first, so `h(1)` is the
LAST group's box; `cols(1,:)` colours the last group (UNCONFIRMED that boxplot creates boxes in
group order; parity check). A replacement must keep this mapping or the colours swap.

Base alternative `boxchart` (https://www.mathworks.com/help/matlab/ref/boxchart.html, MATLAB,
since R2020a): one `BoxChart` object per call (one per `cgroupdata` value), quartiles via the
`quantile` function, outliers "more than 1.5·IQR away", categorical x ordered by categories
(alphabetical unless created with an explicit order). No `'Box'`-tagged lines, so the
`findobj`/`patch` code cannot stay; quartile method may differ from boxplot (UNCONFIRMED).

**Proposal: `cobraBoxplot(x, g)`** in toolboxFree drawing the traditional style with `line`
objects carrying the MathWorks tags (`'Box'` closed polygon XData/YData, `'Median'`, whiskers,
adjacent values, `'Outliers'` markers), groups in first-appearance order (reuse
`cobraGrp2idx`), positions 1..k, x tick labels = group names (or `'1'` for a single vector),
quartiles with base `prctile` (base since R2022a,
https://www.mathworks.com/help/matlab/ref/prctile.html) — exact percentile rule UNCONFIRMED.
The call site then changes only the function name. Alternative (FR-002): `boxchart` +
per-group `BoxFaceColor`, dropping `findobj/patch`; justified only if the maintainer accepts
possibly different quartiles and changed colour mapping.

Headless test assertions: count of `findobj(ax,'Tag','Box')` = number of groups; each box
`YData` = [q1 q3 q3 q1 q1] (order of vertices to be fixed by the implementation), `XData`
centred on 1..k with documented width; `'Median'` YData = [m m]; whisker ends = most extreme
non-outlier points; `'Outliers'` XData/YData; `ax.XTick` = 1..k, `ax.XTickLabel` = group names
in first-appearance order; ties/NaN handling (NaN dropped). Reference values: numpy
`percentile` with the chosen method, plus a hand example.

Also: the `'ViolinPlot'` default path calls external `violinplot` → `ksdensity` (see summary 5).

### A2. `gscatter` — producetSNEPlots.m

File: `src/reconstruction/demeter/src/properties/producetSNEPlots.m`, line 204:
```
cols=hsv(length(unique(taxa)));                 % 196
cmarkers = repeated '+o*xsdp' cut to #groups     % 198–202
h=gscatter(Y(:,1),Y(:,2),taxa,cols,cmarkers);   % 204
set(h,'MarkerSize',4)                            % 205
hold on; title(...); h=legend('Location','northeastoutside'); set FontSize, Interpreter none
grid off; f.Renderer='painters'; print(...,'-dpng','-r300')
```
`taxa` = cell array of char, already sorted alphabetically (lines 170–174), so first appearance
= alphabetical. Return value `h` used only for `MarkerSize`. Line 267 uses `gscatter3`
(external `gscatter3b`, plain MATLAB `scatter3`; not a toolbox call). `Y` comes from `tsne`
(line 188/260; covered by the tsne slice).

Doc (https://www.mathworks.com/help/stats/gscatter.html, Statistics): output `h` = array of
`Line` objects, "Each Line object corresponds to one of the groups in g"; `doleg` default
`'on'`; colours/symbols/sizes cycle when fewer than groups; default `sym` `'.'`; default size
depends on number of observations; axes labelled with input variable names when named
(here `Y(:,1)` has no name → no labels, UNCONFIRMED); group order not stated explicitly
(UNCONFIRMED; grp2idx semantics assumed = first appearance).

**Proposal: `cobraGscatter(x, y, g, clr, sym)`** returning one `Line` per group
(`plot(x(gi), y(gi), 'LineStyle','none', 'Marker', sym(k), 'Color', clr(k,:), 'DisplayName',
groupName)`, `hold` state restored), group order via `cobraGrp2idx`, cycling `clr`/`sym`,
legend on. No base function gives one line per group with legend entries, so a cobra function
is justified (FR-002).

Headless test: `numel(h)` = number of groups; `h(k).XData/YData` = points of group k;
`h(k).DisplayName` = group name in order; `h(k).Color` = `clr(mod(k-1,size(clr,1))+1,:)`;
`h(k).Marker` per `sym`; `LineStyle` `'none'`; legend `String` equals group names.

### A3. `gname` — rBioNet model_stats.m:393

```
389 set(handles.text_esc,'string','Press Esc or Enter to stop marking metabolites.');
390 axes(handles.axes2);
391 met_data = sortrows(handles.met_data,-2);
392 plot(cell2mat(met_data(:,2)),'+');
393 gname(met_data(:,1));
394 ylabel('Connectivity'); xlabel('Metabolites');
396 set(handles.text_esc,'string','');
```
GUIDE callback `act_plot_Callback` (GUI opened from `ReconstructionCreator.m:1196`). Return
value unused.

Doc (https://www.mathworks.com/help/stats/gname.html, Statistics): "opens a figure window and
waits for input"; click near a point to show its label, drag a rectangle to label several,
right-click to remove, Enter/Escape to stop; `h = gname(...)` returns text handles. It blocks.

**Proposal (base, non-blocking):** keep the line handle `p = plot(...,'+')` and attach the name
to data tips: `p.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Metabolite', names)`
(https://www.mathworks.com/help/matlab/ref/matlab.graphics.datatip.datatiptextrow.html, MATLAB
since R2019a; "The number of source values must match the number of data points"; whether a
cell array of char is accepted as `value` is not stated — UNCONFIRMED, pass `string(names)` to
be safe). Clicking a point shows its name; nothing waits, so headless runs do not block.
Optional, closer to gname's persistent labels: a small `ButtonDownFcn` on the line that adds a
`text` at the nearest point (right-click deletes) — still non-blocking. The status text on
line 389 should then read e.g. "Click a point to show its name." Possibly a local helper, no
new toolboxFree function needed (FR-002: base mechanism).

Headless test: create the plot in an invisible figure, apply the same code (factor into a
local/shared helper to make it callable), assert `p.DataTipTemplate.DataTipRows(end).Label`
and `.Value` equal the names; optionally `datatip(p, x, y)` creates a tip programmatically
(R2019b) and its row text can be read; if ButtonDownFcn is used, call the callback with a stub
event carrying `IntersectionPoint` and assert the created `text` String/Position.

### A4. `clustergram` — correlateFluxWithTaxonAbundance.m, summarizeFeaturesOnTaxonLevels.m

Call sites (all options):

| file:line | data | options |
|---|---|---|
| correlateFluxWithTaxonAbundance.m:294 (cols < 20) | `str2double(string(FluxCorrelations.(lvl)(2:end,2:end)))` (correlations) | `'RowLabels', ...(2:end,1)`, `'ColumnLabels', ...(1,2:end)`, `'ColumnLabelsRotate', 45`, `'Cluster','all'`, `'ShowDendrogram','True'`, `'symmetric','False'`, `'colormap','turbo'` |
| correlateFluxWithTaxonAbundance.m:304 (cols ≥ 20) | same | `'RowLabels'`, `'Cluster','all'`, `'ShowDendrogram','True'`, `'symmetric','False'`, `'colormap','turbo'` (no column labels) |
| summarizeFeaturesOnTaxonLevels.m:80 | `cell2mat(dataByTaxon(2:end,2:end))` (row-max normalised, NaN→0) | `'RowLabels'`, `'Cluster','all'`, `'symmetric','False'`, `'colormap','jet'` |
| summarizeFeaturesOnTaxonLevels.m:140 | `cell2mat(dataByFeature(2:end,2:end))` | same as line 80 |

Not passed anywhere: Standardize, Linkage, RowPDist/ColumnPDist, DisplayRange, OptimalLeafOrder,
ImputeFun, LogTrans, Dendrogram. Note `'True'`/`'False'` are passed as char.

What is done with `cgo` afterwards (both files): `h = plot(cgo); set(h,'TickLabelInterpreter',
'none'); colorbar(h)`; then `print([...],'-dpng','-r300')` (correlate…:315) or `title(...)`
(summarize…:89, 149) and `writetable` of the data; `close all force` at correlate…:319. So
`plot(cgo)` must return an **axes** handle (the heat-map axes) — return type not stated on the
doc page (UNCONFIRMED).

Doc defaults (https://www.mathworks.com/help/bioinfo/ref/clustergram.html, Bioinformatics,
R2026b page): Standardize `'none'` (current page; older releases reportedly defaulted to
`'column'` — UNCONFIRMED, parity needed), Cluster `'all'`, RowPDist/ColumnPDist `'euclidean'`,
Linkage `'average'`, OptimalLeafOrder `true` unless rows or columns > 1500, LogTrans `false`,
DisplayRange 3 ("color variation for values between -3 and 3"; values beyond take the limit
colour), Symmetric `true`, Colormap `redgreencmap`, ShowDendrogram `'on'`, ColumnLabelsRotate
90; missing data: "use this property [ImputeFun] to impute the missing values. Otherwise, the
clustergram function errors." What Symmetric=false does to the colour limits is not described
(UNCONFIRMED; plausible: limits = data min/max clipped to ±DisplayRange). Whether clustering is
on standardised data is not stated (irrelevant here: no standardisation).

Clustering building blocks (all Statistics): linkage
(https://www.mathworks.com/help/stats/linkage.html; `'average'` = UPGMA, Z is (m−1)×3, new
cluster index m+I; tie rule not stated), optimalleaforder
(https://www.mathworks.com/help/stats/optimalleaforder.html; Criteria default `'adjacent'`
"maximize the sum of similarities between adjacent leaves", Transformation `'linear'`;
Bar-Joseph, Gifford, Jaakkola 2001, Bioinformatics 17 Suppl 1:S22–9), dendrogram, pdist.

Reproducing the order:
- distance: `cobraPdist(X,'euclidean')` (rows; columns via `X'`) — exists.
- linkage: reuse `src/analysis/ecosystem/computeEcosystemLinkage.m` (`'average'` supported;
  needs the square matrix — build it from the cobraPdist vector inside the new function). No
  `cobraLinkage` needed.
- leaf order: new `cobraOptimalLeafOrder(Z, D)` (Bar-Joseph DP, 'adjacent' criterion, linear
  similarity = max(D) − D or equivalently minimise sum of adjacent distances — check the
  MathWorks "linear" transformation definition, UNCONFIRMED) plus the plain dendrogram leaf
  order for the >1500 case. The optimal order is not unique (at least the reversal; ties), so
  tests should assert (a) the order is consistent with the tree, (b) its adjacent-distance sum
  equals the brute-force optimum on small inputs, and only in the parity section compare with
  `clustergram`'s `RowLabels`/`ColumnLabels` order.
- `'Cluster','all'` clusters both rows and columns (doc naming of 'row'/'column' dims is
  confusing — UNCONFIRMED which numeric code is which; irrelevant here).

**Proposal: `[ax, rowOrder, colOrder] = cobraClustergram(data, Name, Value)`** supporting exactly
RowLabels, ColumnLabels, ColumnLabelsRotate, Cluster ('all'), ShowDendrogram, Symmetric,
Colormap (name or matrix), (DisplayRange default 3, Standardize 'none'); errors naming any other
option and on NaN (as clustergram does without ImputeFun). Draw with `imagesc` in a normal
**axes** (not the `heatmap` chart: it "cannot be combined with other graphics elements", has no
`TickLabelInterpreter`, and the call sites call `colorbar(h)`/`set(h,'TickLabelInterpreter',...)`
on it — https://www.mathworks.com/help/matlab/ref/heatmap.html). Dendrograms as `line` objects in
two extra axes. Call sites become `h = cobraClustergram(...)` and keep their following lines.

Headless test: `ax.Children` image `CData` = data(rowOrder, colOrder); `ax.YTickLabel` =
RowLabels(rowOrder); `ax.XTickLabel` = ColumnLabels(colOrder) and `XTickLabelRotation` 45;
`ax.Colormap` = `turbo`/`jet` matrix; `ax.CLim` per Symmetric/DisplayRange rule; dendrogram
line count = 2(m−1) segments-ish (or tagged lines) and their heights = Z(:,3); order checks as
above; SciPy `linkage(method='average')`, `optimal_leaf_ordering` (SciPy 1.16) as references.

Pre-existing defects found:
- `summarizeFeaturesOnTaxonLevels.m:126` uses `ddataByFeature` (undefined) → error whenever
  `customFeatures` is given (the line-140 clustergram is unreachable).
- correlateFluxWithTaxonAbundance: correlations can be NaN (constant columns) → clustergram
  errors without ImputeFun; replacement must error the same way (or the plan records it).
- `test/tutorialDerived/visualization/EFMviz/tutorial_Efmviz_recon.m:237` also calls
  `clustergram` (tutorial test, not src).

### A5. `redbluecmap` (and the missed `HeatMap`) — plotEssentialRxns.m

```
70 hm = HeatMap(rxnsOfInterest, 'ColumnLabels', modelNames, 'RowLabels', rxnInterestNames, ...
       'Colormap', redbluecmap, 'Symmetric', false, 'DisplayRange', 100);
71 colormap(hm, mymap);
```
repeated at 74/75, 78/79, 82/83 with different `mymap` (10–12 rows of red/orange/yellow/black,
white first in the 2nd case). Return value `rxnInterest4Models` does not depend on the figure.
Callers: only `test/tutorialDerived/analysis/essentialRxns4MultipleModels/tutorial_essentialRxns4MultipleModels.m`
(lines 136–220); no verifiedTest.

redbluecmap doc (https://www.mathworks.com/help/bioinfo/ref/redbluecmap.html, Bioinformatics):
`redbluecmap(length)`, length "must be a positive integer between 3 and 11", default 11;
"Low values are dark blue, values in the center of the map are white, and high values are dark
red." The page gives **no RGB values** (only `Colormap: [11×3 double]` in an example).
Exact values: UNCONFIRMED (widely reported to be the ColorBrewer RdBu 11-class palette in
reverse order; not verifiable from MathWorks docs and must not be copied from MathWorks source).
Because the colour map is overwritten by `mymap` on the next line, **no cobraRedbluecmap is
needed**: pass `mymap` directly.

HeatMap doc (https://www.mathworks.com/help/bioinfo/ref/heatmap.html, Bioinformatics HeatMap
object): Standardize default `'none'`, Symmetric `true`, DisplayRange default "the maximum
absolute value in the input data", Colormap `redgreencmap`; object functions only `view`,
`plot`, `addTitle`, `addXLabel`, `addYLabel`; Colormap is a property. Whether
`colormap(hm, mymap)` works on a HeatMap object is not documented — UNCONFIRMED (it may error;
then the function already fails after drawing; tutorial run with the toolbox settles it).
Symmetric=false colour limits: UNCONFIRMED.

**Proposal:** replace `HeatMap(...)` + `colormap(hm, mymap)` with a base drawing: `figure;
imagesc(rxnsOfInterest); colormap(gca, mymap); clim/caxis([lo hi])` with tick labels
`modelNames`/`rxnInterestNames`, or base `heatmap(modelNames, rxnInterestNames, rxnsOfInterest,
'Colormap', mymap, 'CellLabelColor','none', 'ColorLimits', [lo hi])` (labels: if x/y values must
be unique — UNCONFIRMED on the doc page — use indices and `XDisplayLabels`). `[lo hi]` for
Symmetric=false, DisplayRange=100: proposed `[max(min(data),-100) min(max(data),100)]`
(UNCONFIRMED). Spec inventory should add `HeatMap`.

Headless test: CData = rxnsOfInterest; labels; Colormap = mymap of the branch taken; CLim; the
returned `rxnInterest4Models` unchanged (it is the substantive output).

### A6. `biograph`, `getedgesbynodeid`, `view`, `set` — bio_paint4Net

Files: `src/visualization/paint4net/bio_paint4Net/bio_draw_by_rxn/bio_draw_by_rxn.m` (642 lines);
`bio_draw_by_met/bio_draw_by_met.m` calls it at line 168; `bio_draw_by_met/bio_findNearRxns.m`
(file name ≠ function name `findNearRxns`, pre-existing oddity; no biograph). Sample data in
`Paint4Net sample pack/`.

Biograph API used (only inside `if strcmp(drawMap,'true')`, line 448):
- 471 `map = biograph(matrix, ids, 'ShowTextInNodes','ID', 'LayoutType','hierarchical')`
  (no semicolon → prints object). `matrix` is the (mets+rxns) square connection matrix built at
  328–365 (`matrix(i,j)=1` = edge i→j); `ids` = involvedMets then `'<rxn> (<flux>)'` strings.
- 480/485 `set(map.nodes(m),'Label', ['Name: ' metName])`, `'Description', 'Charged formula: …'`
  (in try/catch); 502/508 same for reaction nodes (`Reaction: <formula> lb= ub=`).
- 523/524, 529/530 `getedgesbynodeid(map, ids(p), [])` (edges out of node p) and
  `getedgesbynodeid(map, [], ids(p))` (edges into node p); 526/527, 532/533
  `set(tot_edges,'LineColor',[0 1 0] | [0 0 1])`, `'LineWidth', abs(7*flux/max_flux)`
  (green positive, blue negative flux).
- 538 `h = view(map)`; 539 reaction nodes `Color` [241 176 102]/255; 540 met nodes `Shape`
  `'ellipse'`; 566 dead-end mets red; 586 exchange reactions [173 255 47]/255; 590 initial met
  green; 594 dead reactions red; 598 exchange reactions `Shape` `'diamond'`.
- 602–604 save: `f = get(h.hgAxes,'Parent'); print(f,'-djpeg', <timestamp>.jpg)`.
- 607–611 close: find figures named 'Biograph Viewer' and close them.

Outputs `[involvedMets, deadEnds, deadRxns]` are computed before line 448 and do not depend on
drawing (deadEnds may be the string `'No dead ends'`, involvedMets `'No involved mets'`).

biograph semantics: current docs return 404 (removed). digraph doc
(https://www.mathworks.com/help/matlab/ref/digraph.html, MATLAB since R2015b): "if A(2,1) = 10,
then G contains an edge from node 2 to node 1" → same i→j convention as the code assumes for
biograph (biograph's own convention UNCONFIRMED from a live MathWorks page); node names "must
… contain a nonempty, unique name for each node". getedgesbynodeid semantics (source/sink
`[]` = any) UNCONFIRMED from docs; inferred from the inline comments.

Comparison with `src/visualization/paint4Net/Draw_by_rxn/draw_by_rxn.m` (CRLF, already on
digraph): lines 1–448 are NOT identical — draw_by_rxn initialises outputs as `{}`, uses default
flux zeros instead of `'x'`, adds `abs(flux)<=1e-9` conditions to the connection-matrix rules
(354–363), and returns `{}` instead of `'No dead ends'`. So **bio_draw_by_rxn cannot delegate to
draw_by_rxn** without changing its outputs (Principle II, US4.3). Its drawing block (draw_by_rxn
479–608: `digraph(matrix)`, `plot(G,'Layout','layered')`, `outedges`/`inedges`, `highlight`) is
the template.

**Proposal:** keep lines 1–447 of bio_draw_by_rxn unchanged; replace 448–612 by a digraph
rendering: `G = digraph(matrix, ids)` (or numeric nodes + `NodeLabel` if ids can collide);
`hp = plot(G,'Layout','layered','NodeLabel',ids)`; per reaction node p:
`eid = [outedges(G,p); inedges(G,p)]` → `highlight(hp,'Edges',eid,'EdgeColor',[0 1 0]/[0 0 1],
'LineWidth', abs(7*flux/max_flux))` (guard `max_flux==0` → LineWidth must be > 0); node colours
and markers via `highlight(hp, ids, 'NodeColor', …, 'Marker', 's'|'o'|'d')` with the same
colours and precedence order as lines 539–598; Label/Description into data-tip rows
(`dataTipTextRow`) or `G.Nodes` variables; save via `print(gcf,'-djpeg',…)`; close via
`close(figureHandle)` instead of searching 'Biograph Viewer'. Possibly a shared private helper
used by both draw_by_rxn and bio_draw_by_rxn — but changing draw_by_rxn is out of scope.

Headless test assertions: outputs equal the stored expectations (unchanged); in the figure,
`hp.NodeLabel`/node names = ids; edge set `G.Edges.EndNodes` = nonzeros of `matrix`; edges with
`hp.EdgeColor` rows / `LineWidth` per flux sign (read `hp.EdgeColor` when it becomes an n×3
matrix after highlight); `hp.NodeColor` rows for reaction/dead/exchange/initial nodes; markers.

Existing tests (test/verifiedTests/visualization/testPaint4Net/):
- `testPaint4Net_bio_draw_by_rxn.m`: skips with `if ~exist('biograph','file')` (line 21) —
  always skips on R2022b+; calls `bio_draw_by_rxn(model, model.rxns, 'true', 'struc', {''},
  {''}, FBAsolution.x)` and compares `Involved_mets`, `Dead_ends` with `*_rxn_bio` in
  `testPaint4Net_workspace_expected_results.mat`.
- `testPaint4Net_bio_draw_by_met.m`: same skip at line 37 (after `cd`/`load`); line ~59 compares
  against `Involved_mets_met` (not `_met_bio`) — likely a typo (UNCONFIRMED until run).
- Both locate their folder with `fileparts(which('testPaint4Net.m'))`, but `testPaint4Net.m`
  exists only in `deprecated/_testPaint4Net/` — if deprecated/ is not on the path, `cd('')`
  (UNCONFIRMED behaviour); if it is, the relative `load('Paint4Net sample pack/…')` would not find
  the folder there. The non-bio tests use the same pattern — run them to see.
- `testPaint4Net_draw_by_rxn.m`, `testPaint4Net_draw_by_met.m` (digraph versions).
- Tutorial: `test/tutorialDerived/visualization/paint4Net/tutorial_bio_paint4net.m`.
Other src callers of paint4Net functions: `drawSecPot.m`, `runFindSparsePathway.m` (check which
variant they call during planning).

### A7. `plotconfusion` — plotThermoKernelExtractStats.m

File `src/dataIntegration/XomicsToModel/thermoKernel/plotThermoKernelExtractStats.m` (function
name inside is `plotThermoModelExtractStats` — file/function name mismatch, pre-existing).
Line 47 `plotconfusion(T,P,'Reaction activity')` is inside `if 0` (lines 38–48) → never
executed; T/P are 3×nRxn one-hot logical matrices (and T's rows 2/3 are wrong — moot).
The live branches use `confusionmat` (Statistics; covered by the stats slice) and
`plotConfMat` (`external/analysis/plotConfMat/plotConfMat.m`, plain MATLAB: imagesc, text,
colormap). Callers: `tutorial_thermoKernel.m` (154–204).

Doc (https://www.mathworks.com/help/deeplearning/ref/plotconfusion.html, Deep Learning
Toolbox): `plotconfusion(targets,outputs,name)`; targets/outputs categorical or N-by-M one-hot;
rows = Output Class, columns = Target Class; "Both the number of observations and the
percentage of the total number of observations are shown in each cell"; right column
precision/FDR, bottom row recall/FNR, bottom-right overall accuracy; "plotconfusion is not
recommended for categorical labels. Use confusionchart instead" and "will be removed in a
future release".

confusionchart (https://www.mathworks.com/help/stats/confusionchart.html): **Statistics and
Machine Learning Toolbox**, introduced R2018b — not base MATLAB (the /help/matlab/ URL is 404),
so it is not a toolbox-free replacement.

**Proposal:** remove the dead `if 0` branch (behaviour unchanged) — or, if the maintainer wants
to keep the code path, replace it with `C = accumarray([predIdx truthIdx], 1, [3 3])` from the
one-hot rows + `plotConfMat(C, labels)`. No cobraPlotconfusion. Test: none needed for dead code
beyond the SC-001 scan; for the live branch, assert the confusion matrix C and the title text.

### A8. `syms` / `pretty` — checkFullRowRankFRK.m

Script (not a function). Lines: 6 `makeLoopToyModel;` (missing everywhere → script errors here,
pre-existing defect); 10–31 choose `If`, `Ir`; 33–34 `A = [-F + R; -If + Ir]`; 38 `disp(A)`; 41
`checkStoichiometricConsistency(model,1)`; 44–48 `B=[F R; If Ir]`, `disp(B)`, prints
"Row rank deficiency = <size(B,1)-rank(B)>"; 52 `syms a b c c1 c2 c3 c4 real`; 53 `x=[a,b,c,c1,
c2,c3,c4]'`; 55 `pretty(A*A'*x(1:nMet,1))`.

Purpose: show, symbolically, each component of A·Aᵀ·x as a linear combination of named
unknowns so the user can see which combinations vanish (left-nullspace inspection, header
line 4: "inspect A*A' symbolically for a left-nullspace vector"). The rank number itself is
printed numerically (line 48) and does not need Symbolic Math.

**Proposal (base MATLAB):** `M = A*A'; names = {'a','b','c','c1','c2','c3','c4'}`; for each row
i print `row i: ` followed by the nonzero terms `sprintf('%+g*%s', M(i,j), names{j})` (omit
`1*`, show `-` signs), e.g. via a local function at the end of the script (allowed in scripts
since R2016b) or a small helper. Equivalent information to `pretty` (which formats a column
vector of expressions); exact layout is not reproducible and not required (spec US4.4 asks for
the same rank information). Note `nMet = size(A,1)` must equal 7 (true for case 3).

Test: the script cannot run (missing `makeLoopToyModel`) → document under III-Defects; test the
printing helper directly (factored out, or run the script with a test-only fixture
`makeLoopToyModel.m` defining `F`, `R` in a temp folder) and assert evalc output lines for a
known A.

---

## PART B — Parallel Computing leftovers

### B1. `getCurrentTask` — fastFVA.m:529

Doc (https://www.mathworks.com/help/parallel-computing/getcurrenttask.html, Parallel Computing
Toolbox): `t = getCurrentTask` "returns the parallel.Task object that the current worker is
associated with"; output type `parallel.Task | []`; "When you use getCurrentTask on the client,
t is an empty double." Behaviour without the toolbox: the function does not exist →
"Unrecognized function or variable 'getCurrentTask'" (standard MATLAB error; UNCONFIRMED wording).
The page does not document the `ID` property (UNCONFIRMED from this page; it is a Task property).

Use: `t = getCurrentTask();` inside `parfor i = 1:nworkers` (518–600); `t.ID` is printed (536,
541) and passed as the 10th argument (worker/log ID) to the CPLEX MEX `FVAc` (556, 562, 572). The
serial branch (`nworkers <= 1`, line 344) passes the literal `1` in that position.

Reachability: `nworkers` comes from `getParallelPool()` (325–330): `[]` → 1 → serial branch.
Without the toolbox `getParallelPool` returns `[]`, so the parfor branch and `getCurrentTask` are
**unreachable** without the toolbox. With the toolbox but if the parfor ever runs on the client
(e.g. pool busy, `parfor (…, 0)`), `t` is `[]` and `t.ID` errors — a latent defect.

Proposal (FR-008, and to make the SC-001 scan clean or explainable):
```
taskId = 1;                                   % serial value, as in the nworkers<=1 branch
if isParallelToolboxAvailable()
    t = getCurrentTask();
    if ~isempty(t), taskId = t.ID; end
end
```
then use `taskId` in place of `t.ID` (parfor-transparent: a temporary). Results unchanged
(the ID only names log files / CPLEX clone). Test: testFastFVA needs ibm_cplex → verify
statically on this machine; on base MATLAB the branch cannot be entered.

### B2. `spmd` — SteadyComPOAgr.m:586

Doc (https://www.mathworks.com/help/parallel-computing/spmd.html, Parallel Computing Toolbox):
- "The `spmd` statement can be used only if you have Parallel Computing Toolbox™." (No
  sentence of the form "If you do not have Parallel Computing Toolbox … runs on the client";
  base-MATLAB behaviour is therefore UNCONFIRMED — `spmd` is a MATLAB keyword so the file
  parses; executing the block without the toolbox presumably errors.)
- "If there is no parallel pool and `spmd` cannot start one, the code runs serially in the
  client session." (Tips); "If your settings do not allow automatic pool creation, MATLAB
  executes the block body locally and creates Composite objects as necessary."
- "If `n` is `0`, MATLAB executes the `spmd` statements locally and creates Composite objects,
  the same as if there is no pool available."
- "Values returning from the body of an `spmd` statement are converted to `Composite` objects
  on the MATLAB client" … "retrieved using cell-array indexing".
- spmdIndex/spmdSize values on the client: not stated (UNCONFIRMED; presumably 1/1).
- parfor (https://www.mathworks.com/help/matlab/ref/parfor.html): "if only one core is available
  or M is 0), MATLAB executes the loop in a serial manner"; the page does not contain a
  sentence about running without the toolbox (the first slice relied on that behaviour).

Code (539–747): branch `else %% parallel` is taken only when `threads ~= 1`. Lines 132–147 set
`threads = 1` when `getParallelPool()` is empty after trying `openParallelPool` ("no Parallel
Computing Toolbox: compute serially") → without the toolbox the spmd branch is **unreachable**.
Inside the branch:
- 565–566 `numPool = openParallelPool(); numPool = numPool.NumWorkers;`
- 573 `undoneCur = Composite();` (PCT function, client side), 574–585 `nRange{kP}`,
  `undoneCur{kP} = undone(nRange{kP})` (one cell per worker).
- 586–739 `spmd`: builds a local LP (Cplex clone or LP copy), loops
  `for jP = 1:numel(nRange{labindex})`, solves POA pairs, saves results to files (`iSave`), sets
  `undoneCur(jP) = false` (inside spmd the Composite is the worker's local array), polls
  `labProbe('any',0)` (718, 735), `labSend(true, setdiff(1:numlabs, labindex), 0)` (728),
  `labReceive('any',0)` (737) for work redistribution.
- 741–743 after the block: `undone(nRange{kP}) = undoneCur{kP}` (Composite read by cell index).
Variables that are Composite after the block: `undoneCur` (explicit), and every variable assigned
in the body (`LPp`, `addConstraint`, `first`, loop temporaries) but only `undoneCur` is read.
Results reach the caller through the saved files, then loaded in the common tail.

Proposal: keep the spmd branch (it is the parallel implementation and runs only with a pool);
make the guard explicit so the requirement is visible to the SC-001 scan:
`if threads ~= 1 && ~isParallelToolboxAvailable(), threads = 1; end` (already implied by
132–147). Record `spmd`, `Composite`, `labindex`, `numlabs`, `labSend`, `labReceive`,
`labProbe` (lines 573–737) as **guarded, toolbox-only code** — the SC-001 scan needs an
"allowed when guarded by isParallelToolboxAvailable/getParallelPool" exception (like the optional
`matlab` solver), or the parallel body moves into a separate file named in the exception list.
Rewriting the serial path is unnecessary: the existing `threads == 1` branch (438–554) is the
serial equivalent, and testSteadyCom compares both against the same reference data.
(labindex/numlabs/labSend/labReceive/labProbe are the pre-R2022b names of spmdIndex/spmdSize/
spmdSend/spmdReceive/spmdProbe — renaming is optional and not required here.)

### B3. Other Parallel Computing functions in src/ (outside old/, deprecated/)

grep for labindex, numlabs, spmdIndex, spmdSize, labSend, labReceive, labProbe, labBarrier,
spmdSend/Receive/Barrier, gop, gplus, gcat, Composite, parfeval(OnAll), afterEach, afterAll,
DataQueue, PollableDataQueue, parallel.pool.*, parcluster, batch(, createJob, createTask,
gpuArray, gather, distributed, codistributed, drange, matlabpool, getCurrentWorker/Job/Cluster,
parforOptions, ticBytes:
- Only `SteadyComPOAgr.m` (Composite 573, labindex 600/601/728, numlabs 728, labSend 728,
  labReceive 737, labProbe 718/735), all inside the guarded parallel branch above.
- `solveCobraLP.m:1369` assigns a variable named `labindex = 1` (not a call).
- `gcp`/`parpool` only inside toolboxFree helpers. `findOptExchRxns.m:27` sets a variable
  `matlabpool = 0`.
- `gpSampler.m:205` calls `ACHRSamplerDistributedGeneral` (threads < 0), which **does not exist**
  in the repository (pre-existing defect; not a PCT call).
- Tests: `parcluster(parallel.defaultClusterProfile)` in `testSampleCbModel.m:24` (inside
  try/catch, fine) and `testSteadyCom.m:440` (not in try; reached on base MATLAB — see C).
- Licence-based guards in src (graceful, not errors): mgSimResCollect.m:115 (Statistics →
  skips PCoA; must be removed when `cmdscale` is replaced, or Y stays `[]`), analyseWBMsol.m:205,
  initPersephone.m:58/69, fluxVariability.m:333, metabolicCartography visualize*.m. Hard error:
  `partition.m:34` (Bioinformatics assert).

---

## PART C — test requirement table

Method: grep of every `prepareTest(... 'toolboxes'|'requiredToolboxes' ...)` (including through
variables), `license('test',…)`, `ver('…')`, `exist('<toolbox fn>','file')` in
test/verifiedTests (and test/ as a whole: no other toolbox keys outside verifiedTests); for each
test, a static call-graph walk over src/ and external/ (scratch script, over-approximating; hits
in `solveCobraLP` `linprog/optimoptions` = optional backend, and `fastFVA` `getCurrentTask` via
fluxVariability = guarded, were discarded) plus manual reading.

| Test | Declared toolbox | Other requirements | Toolbox functions actually reached (after/before this feature) | Verdict |
|---|---|---|---|---|
| analysis/testBiomassPrecursorCheck | statistics_toolbox | none else (default LP solver) | none | STALE → REMOVE; pre-existing assertion failure at line 91 (spec US6.3) to document under III-Defects |
| analysis/testMultiSpeciesModelling/testCreatePanModels | `'Statistics Toolbox'` (malformed key, see summary 9) | numWorkers=4 (pools optional) | external `Violin.m:117` ksdensity via plotBiomassTestResults/plotATPTestResults violinplot, inside `try` without `catch` (error swallowed, figure incomplete) | STALE → REMOVE (note the swallowed violin error) |
| analysis/testSampling/testSampleCbModel | statistics_toolbox | needsUnix, needsLP, excludeSolvers {mosek, dqqMinos, quadMinos, matlab, pdco}; parcluster in try | external `Volume-and-Sampling/rand_exponential_range_coord.m:35` exprnd (CHRR_EXP); prctile (base since R2022a) | KEEP (external/), reason into header |
| analysis/testSampling/testSampleCbModelRHMC | statistics_toolbox | — | external `PolytopeSamplerMatlab/code/diagnostics/distribution_test.m` exprnd, adtest, kstest, norminv | KEEP (external/) |
| analysis/testFEA | bioinformatics_toolbox, statistics_toolbox | — | FEA.m:96 hygecdf(…,'upper'), FEA.m:117 mafdr(p,'BHFDR',true); test line 76 hygecdf directly | REMOVE after cobraHygecdf + fdrBHadjustment; switch test line 76 |
| analysis/testConnectedComponents | image_toolbox | — | external `graph_analysis.m:237` bwlabel (Image Processing), unconditional | KEEP (external/) — contradicts spec US6.4; maintainer decision |
| analysis/testTopology/testMoieties | bioinformatics_toolbox only inside `if 0` (lines 16–21) | requireOneSolverOf {gurobi, ibm_cplex} | none | STALE (already inactive); optionally delete the dead branch |
| analysis/testSteadyCom | statistics_toolbox | needsQP, requireOneSolverOf {gurobi, glpk, tomlab_cplex, cplex_direct, mosek} | none (regress already cobraRegress); test line 440 `parcluster` reached on base MATLAB because `parWorks` is always true | REMOVE + set `parWorks = isParallelToolboxAvailable()`; parallel-cleanup issue (first slice) documented |
| analysis/testMultiSpeciesModelling/testMgPipe | statistics_toolbox | requiredSolvers ibm_cplex | mgSimResCollect.m:123 cmdscale (behind licence guard line 115, so today Y=[] silently); retrieveModelStats ranksum/kruskalwallis/violin only with infoFile (not passed) | REMOVE after cobraCmdscale and removal of the licence guard; verify statically (CPLEX) |
| analysis/testFVA/testFastFVA | `{}` (cleared in slice 1) | ibm_cplex | getCurrentTask only with a pool | N/A (nothing to remove); B1 guard |
| analysis/testuFBA | `{}` | gurobi | none | N/A |
| analysis/testMultiSpeciesModelling/testJoinModelsPairwiseFromList | `ver('parallel')` gates one section (stand-ins) | — | none | N/A (section gate is intentional) |
| dataIntegration/testRFASTCORMICS | statistics_toolbox + `assert(~isempty(ver('curvefit')))` (line 13: hard failure, not a skip) | needsLP, requireOneSolverOf {gurobi, ibm_cplex} | none — calls only `rFastcormics` with a pre-discretized vector; `discretizeFPKM` (ksdensity, createFitL/R fit) is not called | STALE → REMOVE both; add a section calling `discretizeFPKM` to cover the new fit/ksdensity code (US2) |
| dataIntegration/testSWIFTCORE/testSWIFTCORE | statistics_toolbox | needsLP, requireOneSolverOf {gurobi, ibm_cplex}, excludeSolvers {matlab, lp_solve, pdco} | core.m:33 normrnd(0,1,[k,1]); test line 36 randsample(n, round(n/2)) | REMOVE after cobraNormrnd; test → cobraRandsample or base `randperm(n,k)` |
| dataIntegration/testSWIFTCORE/testPartition | bioinformatics_toolbox | needsLP, useSolversIfAvailable gurobi | partition.m:34 licence assert (Bioinformatics); partition.m:73, 97 `range` (Statistics) — both missing from the inventory | REMOVE after src fix (drop assert, `max-min`) |
| dataIntegration/testEFlux | bioinformatics_toolbox | needsLP, needsWebAddress GEO, excludeSolvers {matlab, pdco} | test lines 26–27 geosoftread(urlread(…)); eFlux.m:50 normrnd(mean,std) | REMOVE after cobraNormrnd + geosoft parsing (see below); keep needsWebAddress |
| design/testOptGene | gads_toolbox | needsLP, needsMILP | optGene.m ga, gaoptimset | REMOVE after cobraGa |
| visualization/testSammi | statistics_toolbox | — | test lines 151, 156, 186 randsample(N, k) | REMOVE after switching test calls |
| visualization/testUpsetPlot | `{}` | — | none | N/A |
| visualization/testPaint4Net/testPaint4Net_bio_draw_by_rxn | `exist('biograph','file')` self-skip (line 21) | none | biograph, getedgesbynodeid, view (removed in R2022b) | REMOVE skip after A6; check the `which('testPaint4Net.m')`/cd fragility |
| visualization/testPaint4Net/testPaint4Net_bio_draw_by_met | same self-skip (line 37) | none | same (via bio_draw_by_met:168) | REMOVE skip after A6; check `Involved_mets_met` vs `_met_bio` comparison |
| base/testToolboxFree/* (17 files) | licence checks only gate parity sections | — | — | N/A (by design) |
| base/testToolboxFree/testIsParallelToolboxAvailable | ver('parallel'), license | — | — | N/A |

Counts (rows with a declared toolbox requirement or toolbox self-skip, excluding N/A):
REMOVE 13 (of which STALE today: testBiomassPrecursorCheck, testCreatePanModels,
testRFASTCORMICS; already inactive: testMoieties counted separately), KEEP 3 (testSampleCbModel,
testSampleCbModelRHMC, testConnectedComponents), STALE-inactive 1 (testMoieties).
Breakdown of REMOVE: testBiomassPrecursorCheck, testCreatePanModels, testRFASTCORMICS (stale),
testFEA, testSteadyCom, testMgPipe, testSWIFTCORE, testPartition, testEFlux, testOptGene,
testSammi, testPaint4Net_bio_draw_by_rxn, testPaint4Net_bio_draw_by_met.

Tests calling toolbox functions directly in test code:
- testFEA.m:76 `hygecdf(X - 1, M, Kpop, N, 'upper')`
- testSWIFTCORE.m:36 `randsample(n, round(n/2))`
- testSammi.m:151, 156, 186 `randsample(length(model.rxns)*n, floor(...))` etc.
- testEFlux.m:26–27 `geosoftread(urlread(...))` (urlread is base but "not recommended"; webread
  is the modern call)
- testSampleCbModel.m:24 and testSteadyCom.m:440 `parcluster(parallel.defaultClusterProfile)`
  (Parallel Computing; the first is in try/catch, the second is not)
- Tutorial tests: tutorial_Efmviz_recon.m:237 clustergram (outside verifiedTests).
No test calls exprnd directly (exprnd is only in external/).

testEFlux and geosoftread: doc (https://www.mathworks.com/help/bioinfo/ref/geosoftread.html,
Bioinformatics) — `File` may be the text of a SOFT file; output fields Scope, Accession, Header,
ColumnDescriptions, ColumnNames, Data ("Array containing microarray data"; GSM Data type not
stated, the test's `cell2mat(Data(:,2))` implies a cell with numeric VALUE). The test uses only
`Data(:,1)` (ID_REF, first five characters as gene target) and `Data(:,2)` (VALUE). GSM SOFT text
has the table between `!sample_table_begin` and `!sample_table_end`, header row `ID_REF\tVALUE…`.
Recommendation: **parse in the test** (a local function: split lines, take the block between the
two markers, `textscan`/`strsplit` on tabs, column 1 as cellstr, column 2 `str2double`), not a
`cobraGeosoftread` in src — no src function uses geosoftread, and a faithful replacement would
have to cover GDS/GSE/GPL records and the full output struct (FR-003 scope creep). Optionally
store a trimmed fixture of the two GSM tables (core-model genes only) to remove the web
dependency — a separate decision (web requirements are out of scope).

---

## Pre-existing defects noted (III-Defects candidates; not to be fixed in this feature)

- summarizeFeaturesOnTaxonLevels.m:126 `ddataByFeature` undefined.
- retrieveModelStats.m:108 `if ~numel(unique(...))==1 && …` precedence → always false; violin
  plots of model sizes never drawn.
- checkFullRowRankFRK.m:6 `makeLoopToyModel` missing.
- plotThermoKernelExtractStats.m: function name ≠ file name; dead `if 0` branches.
- bio_findNearRxns.m: function name `findNearRxns` ≠ file name.
- gpSampler.m:205 `ACHRSamplerDistributedGeneral` missing.
- fastFVA.m:529–572 `t.ID` errors if a parfor iteration runs on the client (t = []).
- testPaint4Net_bio_draw_by_met: compares with `Involved_mets_met` (UNCONFIRMED).
- plotEssentialRxns: `colormap(hm, mymap)` on a HeatMap object (UNCONFIRMED whether valid).
- correlateFluxWithTaxonAbundance: NaN correlations → clustergram error without ImputeFun.

## Sources (MathWorks documentation, fetched 2026-11-11)

- boxplot https://www.mathworks.com/help/stats/boxplot.html
- boxchart https://www.mathworks.com/help/matlab/ref/boxchart.html
- gscatter https://www.mathworks.com/help/stats/gscatter.html
- gname https://www.mathworks.com/help/stats/gname.html
- dataTipTextRow https://www.mathworks.com/help/matlab/ref/matlab.graphics.datatip.datatiptextrow.html
- clustergram https://www.mathworks.com/help/bioinfo/ref/clustergram.html
- redbluecmap https://www.mathworks.com/help/bioinfo/ref/redbluecmap.html
- HeatMap (Bioinformatics) https://www.mathworks.com/help/bioinfo/ref/heatmap.html
- heatmap (MATLAB) https://www.mathworks.com/help/matlab/ref/heatmap.html
- linkage https://www.mathworks.com/help/stats/linkage.html
- optimalleaforder https://www.mathworks.com/help/stats/optimalleaforder.html
- digraph https://www.mathworks.com/help/matlab/ref/digraph.html
- biograph removal (MathWorks Answers, staff) https://www.mathworks.com/matlabcentral/answers/1867118-replacing-old-version-graphshortestpath-with-new-shortestpath-function ,
  https://www.mathworks.com/matlabcentral/answers/2139451-unrecognized-function-or-variable-graphconncomp
  (biograph/getedgesbynodeid reference pages: 404 for current and R2021a archive)
- plotconfusion https://www.mathworks.com/help/deeplearning/ref/plotconfusion.html
- confusionchart https://www.mathworks.com/help/stats/confusionchart.html
- getCurrentTask https://www.mathworks.com/help/parallel-computing/getcurrenttask.html
- spmd https://www.mathworks.com/help/parallel-computing/spmd.html
- parfor https://www.mathworks.com/help/matlab/ref/parfor.html
- violinplot (MATLAB, since R2024b) https://www.mathworks.com/help/matlab/ref/violinplot.html
- quantile (moved to MATLAB R2022a) https://www.mathworks.com/help/matlab/ref/quantile.html
- prctile (moved to MATLAB R2022a) https://www.mathworks.com/help/matlab/ref/prctile.html
- range (Statistics) https://www.mathworks.com/help/stats/range.html
- bwlabel (Image Processing) https://www.mathworks.com/help/images/ref/bwlabel.html
- geosoftread https://www.mathworks.com/help/bioinfo/ref/geosoftread.html
