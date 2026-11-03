# MathWorks semantics reference for toolbox-free replacements

Compiled 2026-11-03. Read-only research. Every claim cites its source.

## Source key

- **[DOC-x]**: the current MathWorks documentation page, fetched 2026-11-03. URLs are listed under each function.
- **[R14:x.m]**: MathWorks' own source code for the Statistics Toolbox, R14SP2 (2004/2005), from a public third-party mirror at
  `https://globec.whoi.edu/data/matlabr14sp2/toolbox/stats/<x>.m`. They were read for semantics only (never executed, never copied into the repository).
  (not committed).
  This is authoritative for the 2005 algorithm only. Current releases may differ. Anything that relies only on R14 is marked **(R14; current UNCONFIRMED)**.
- **[BIO-REF]**: the Bioinformatics Toolbox 2 Reference PDF (2006–2007 edition), `http://cda.psych.uiuc.edu/matlab_class_material/bioinfo_ref.pdf`, pages 2-242 to 2-247.
- **UNCONFIRMED** means no source could confirm the claim. Where a value is given, it is my best recollection or an inference.
- **Local check:** `/usr/local/MATLAB/R2025a` has no Statistics or Curve Fitting toolbox. The `mcr/toolbox/stats` and `mcr/toolbox/curvefit` `.m` files are encrypted MCR stubs (header `V2MCC8000MEC2000MCR2000`) and cannot be read. Nothing could be checked empirically on this machine.

---

## 1. normcdf

Doc: https://www.mathworks.com/help/stats/normcdf.html

- **Syntax:**
  - `p = normcdf(x)`, `normcdf(x,mu)`, `normcdf(x,mu,sigma)`
  - `[p,pLo,pUp] = normcdf(x,mu,sigma,pCov)`, `normcdf(x,mu,sigma,pCov,alpha)`
  - `___ = normcdf(___,'upper')`

  Defaults are mu=0, sigma=1, alpha=0.05 [DOC-normcdf].
- **Size:** "p is the same size as x, mu, and sigma after any necessary scalar expansion." Non-scalar inputs must have the same size. pLo and pUp have the same size as p [DOC-normcdf].
- **Formula:** `p = 0.5*erfc(-z/sqrt(2))` with `z = (x-mu)./sigma` [DOC-normcdf: "uses the complementary error function erfc"; R14:normcdf.m identical].
- **'upper':** returns the complement and uses "an algorithm that more accurately computes the extreme upper-tail probabilities". For example, `normcdf(10,'upper') = 7.6199e-24`, while `1-normcdf(10)` is 0 [DOC-normcdf]. The natural implementation, `0.5*erfc(z/sqrt(2))`, is UNCONFIRMED as the exact code but is mathematically equal.
- **sigma = 0:** "If sigma is zero, then the output p is either 0 or 1": "p is 0 if x is smaller than mu, or 1 otherwise". So x == mu gives **1** [DOC-normcdf]. R14 instead set every `sigma<=0` to NaN [R14:normcdf.m], so this changed in a later release.
- **sigma < 0:** the doc only says sigma is "nonnegative". R14 returned NaN. Current behaviour is NaN (R14; current UNCONFIRMED).
- **NaN inputs:** not documented. They propagate through the arithmetic to NaN [R14:normcdf.m].
- **pCov:** requires scalar x, mu, sigma and a 2x2 pCov. Bounds use the delta method [DOC-normcdf]. R14 formula: `zvar = (pcov(1,1)+2*pcov(1,2)*z+pcov(2,2)*z.^2)./sigma.^2`, `halfwidth = -norminv(alpha/2)*sqrt(zvar)`, `pLo = Phi(z-halfwidth)`, `pUp = Phi(z+halfwidth)`. It errors if `zvar<0` [R14:normcdf.m]. With one output, pCov is not used.

## 2. norminv

Doc: https://www.mathworks.com/help/stats/norminv.html

- **Formula:** `x = mu + sigma.*(-sqrt(2)*erfcinv(2*p))` [DOC-norminv: "uses the inverse complementary error function"; R14:norminv.m].
- **Size:** scalar expansion, the same as normcdf [DOC-norminv].
- **p = 0 and p = 1:** give `-Inf` and `+Inf`. The doc example `p=0:0.25:1` starts with -Inf and ends with Inf [DOC-norminv]. erfcinv(2)=-Inf and erfcinv(0)=Inf.
- **p outside [0,1]:** NaN, via `p(p<0 | 1<p) = NaN` [R14:norminv.m]. The current doc only says p must be in [0,1] (R14; current UNCONFIRMED).
- **sigma <= 0:** NaN in R14 [R14:norminv.m]. The current doc says sigma must be "positive". Current behaviour for sigma=0 is UNCONFIRMED: it may return mu, as normcdf does now.

## 3. tcdf and tinv

Docs: https://www.mathworks.com/help/stats/tcdf.html and https://www.mathworks.com/help/stats/tinv.html

**What the docs say**

- `p = tcdf(x,nu)` and `tcdf(x,nu,'upper')`. 'upper' returns the complement and is more accurate in the extreme upper tail [DOC-tcdf].
- nu must be "positive". Non-integer nu and Inf are not mentioned in either doc.
- Both use scalar expansion [DOC-tcdf, DOC-tinv].
- No algorithm is documented for either function.

**tcdf algorithm (R14; current UNCONFIRMED)** [R14:tcdf.m]

- NaN when x is NaN or `~(nu>0)`.
- nu == 1 (Cauchy): `p = 0.5 + atan(x)/pi`.
- nu > 1e7: `p = normcdf(x)`. This covers **nu = Inf**.
- Otherwise: `p = betainc(nu./(nu+x.^2), nu/2, 0.5)/2`, reflected to `1-p` when x > 0.
- `p(x==0) = 0.5`.
- Non-integer nu works because betainc accepts real parameters.
- **tcdf 'upper':** the formula is UNCONFIRMED. It equals `tcdf(-x,nu)` by symmetry. Computing it as `betainc(...)/2` for x > 0 keeps tail accuracy.

**tinv algorithm (R14; current UNCONFIRMED)** [R14:tinv.m]

- `nu<=0` gives NaN.
- nu == 1: `tan(pi*(p-0.5))`.
- p == 0 gives -Inf. p == 1 gives +Inf.
- For 0 < p < 1 and nu < 1000: `x = ±sqrt(nu./betainv(2*min(p,1-p),nu/2,0.5) - nu)`.
- For nu >= 1000 (including Inf): a 4-term Cornish-Fisher expansion around `xn = norminv(p)`. With nu = Inf this reduces to exactly `norminv(p)`.
- **p outside [0,1]:** R14 has no explicit guard. Out-of-range values reach betainv, which returns NaN.

## 4. chi2cdf

Doc: https://www.mathworks.com/help/stats/chi2cdf.html

- `p = chi2cdf(x,nu)` and `chi2cdf(x,nu,'upper')` [DOC-chi2cdf].
- The doc says x is "nonnegative" and nu is "positive". It uses scalar expansion and the output has the same size [DOC-chi2cdf].
- Formula: the integral of the chi-square density from 0 to x [DOC-chi2cdf]. In R14, `chi2cdf(x,v) = gamcdf(x,v/2,2)` [R14:chi2cdf.m], and `gamcdf` does the following [R14:gamcdf.m]:
  - sets `a<=0` to NaN;
  - clamps **x<0 to 0, so p = 0**;
  - computes `p = gammainc(x/2, v/2)`;
  - sets `p(x==Inf)=1`.
- Lower tail is therefore `gammainc(max(x,0)/2, nu/2)`.
- NaN x or NaN nu gives NaN (gammainc propagates it).
- Vector inputs are element-wise after scalar expansion.

## 5. fcdf

Doc: https://www.mathworks.com/help/stats/fcdf.html

- `p = fcdf(x,nu1,nu2)` and `fcdf(...,"upper")`. x is nonnegative, nu1 and nu2 are positive, and inputs use scalar expansion [DOC-fcdf].

R14 algorithm [R14:fcdf.m]:

- p starts at 0, so **x <= 0 gives 0**.
- NaN if `nu1<=0`, `nu2<=0`, or any input is NaN.
- `x==Inf` gives 1.
- For x > 0 with finite dfs: `p = betainc(x./(x+nu2./nu1), nu1/2, nu2/2)`.
- Infinite-df cases:
  - nu2 = Inf: `chi2cdf(nu1*x,nu1)`
  - nu1 = Inf: `1-chi2cdf(nu2./x,nu2)`
  - both Inf: `x>=1`
- The 'upper' algorithm is UNCONFIRMED. `betainc(nu2./(nu2+nu1.*x), nu2/2, nu1/2)` is the accurate complement.

## 6. tabulate

Doc: https://www.mathworks.com/help/stats/tabulate.html

**Syntax and output type**

- `tabulate(x)` prints a table. `tbl = tabulate(x)` returns it [DOC-tabulate].
- tbl is a **numeric matrix when x is numeric and a cell array otherwise**. The cell case includes logical, categorical, char, string and cellstr. Columns are Value, Count, Percent [DOC-tabulate].

**Numeric x**

- **Positive integers:** "If the elements of x are positive integers, then the frequency table includes 0 counts for the integers between 1 and max(x) that do not appear in x." For example, `tabulate(Height)` returns rows 1..72 [DOC-tabulate].
- The positive-integer test applies only after NaNs are removed [R14:tabulate.m]: `y = x(~isnan(x))`, then `all(y==round(y)) && all(y>=1)`. A single 0, negative, or non-integer value switches to unique-value mode.
- **Unique-value mode:** only values that occur, in **ascending numeric order** (grp2idx sorts numeric input). There are no zero-count rows [R14:tabulate.m + DOC-grp2idx].
- R14 rebuilt the values from `str2num(char(gn))`, which loses precision. Current releases presumably use exact values (UNCONFIRMED).

**Non-numeric x**

- Rows follow grp2idx order: **first appearance** for char, cellstr and string; **categories order** for categorical.
- The DOC example `carsmall Origin` lists USA, France, Japan, Germany, Sweden, Italy, which is first-appearance order, not alphabetical [DOC-tabulate, DOC-grp2idx].
- **Logical:** the doc says cell output. The row order (false first) is UNCONFIRMED; grp2idx sorts logical.

**NaN and missing values**

- NaN is excluded. Percent uses only the non-missing count: the MPG example's counts sum to 94 of 100 and `1/94*100 = 1.0638` [DOC-tabulate].
- Missing strings and `''` are excluded through grp2idx (inference from DOC-grp2idx; UNCONFIRMED for tabulate itself).

**Percent**

- `100*count/sum(count)`, on a 0–100 scale [R14:tabulate.m; DOC examples 47.00%].

**No output argument (prints)**

- Header line `'  %5s    %5s   %6s\n'` with Value, Count, Percent.
- Positive-integer rows: `'  %5d    %5d    %6.2f%%\n'`.
- Cell (string) rows use a value width of `max(5,min(50,maxlen))` [R14:tabulate.m].
- The current DOC printout looks the same, for example `    Male       47     47.00%`. Current column widths are UNCONFIRMED.
- The doc's integer example prints zero-count rows too (the doc says "displays").

## 7. grp2idx

Doc: https://www.mathworks.com/help/stats/grp2idx.html

**Syntax and outputs**

- `[g,gN] = grp2idx(s)` and `[g,gN,gL] = grp2idx(s)`.
- g is a "positive integer vector with values from 1 up to the number K of distinct groups" [DOC-grp2idx]. It is a column vector; R14 transposes row input [R14:grp2idx.m]. The current orientation is UNCONFIRMED but presumably a column.
- gN is a **cell array of character vectors**, and `gN(g)` reproduces s.
- gL is a "column vector ... with the same data type as s". A char matrix stays char (`gL(g,:)` reproduces s). **String input gives cellstr** in gL [DOC-grp2idx].

**Group order** [DOC-grp2idx]

| Input type | Order |
|---|---|
| numeric, logical | **sorted** |
| categorical | order of `categories(s)` |
| char, cellstr, string, datetime, duration | **first appearance** |

Whether unused categorical categories appear in gN is UNCONFIRMED.

**Missing values** [DOC-grp2idx]

- These are treated as missing and get **NaN in g**, with no entry in gN or gL: NaN, `''`, `""`, `<missing>`, `<undefined>`, NaT.
- Because g holds NaN, it is double.
- R14 also mapped the string `'NaN'` to missing for cell input [R14:grp2idx.m]. Current behaviour is UNCONFIRMED.

**Numeric gN text**

- R14: `cellstr(strjust(num2str(b),'left'))` [R14:grp2idx.m]. num2str uses about 4 significant digits after the point for non-integers, so `0.123456` becomes `'0.12346'`.
- Current format is UNCONFIRMED. The DOC crosstab example shows logical or 0/1 values labeled `{'0'}`, `{'1'}` [DOC-crosstab].

## 8. crosstab

Doc: https://www.mathworks.com/help/stats/crosstab.html

**Syntax and outputs**

- `[tbl,chi2,p,labels] = crosstab(x1,x2,...)` [DOC-crosstab].
- **Order:** "The numerical order of grp2idx(x1) and grp2idx(x2) order rows and columns of tbl." So numeric levels are sorted and text levels are in first-appearance order [DOC-crosstab + DOC-grp2idx].
- The DOC example `x=[1 1 2 3 1]`, `y=[1 2 5 3 1]` gives `[2 1 0 0; 0 0 0 1; 0 0 1 0]`, with columns 1, 2, 3, 5 sorted [DOC-crosstab].
- **labels:** a cell array with column j holding the gN of variable j. Shorter columns are padded with `[]` (shown as `{0×0 double}`). Numeric levels appear as char, for example `'0'`, `'1'` [DOC-crosstab; R14:crosstab.m `labels(1:ng,j) = g2`].

**Missing values**

- `IncludeMissingGroups` defaults to false, so **rows with a missing value in any input are dropped** [DOC-crosstab].
- R14 dropped rows where any grp2idx index is NaN [R14:crosstab.m].

**chi2 statistic**

- This is Pearson's chi-square test of independence [DOC-crosstab example text]. R14 computes [R14:crosstab.m]:
  - expected counts as the product of the marginal proportions times n, so `E = rowsum*colsum'/n` in 2D;
  - `chi2 = sum((T-E).^2./E)`;
  - `df = prod(sz) - (1 + sum(sz-1))`, which is `(r-1)(c-1)` in 2D;
  - `p = 1 - chi2cdf(chi2,df)`.
- Current p may use the 'upper' option (UNCONFIRMED). The doc says p is asymptotic.
- Singleton dimensions (a variable with only 1 level) are removed first. If fewer than 2 non-singleton dimensions remain, **chi2 = NaN and p = NaN** [R14:crosstab.m].
- No continuity correction.
- DOC check values: `hospital.Sex x Smoker` gives `[40 13; 26 21]`, `chi2 = 4.5083`, `p = 0.0337` [DOC-crosstab]. Pearson without Yates reproduces 4.5083.

## 9. pdist

Doc: https://www.mathworks.com/help/stats/pdist.html

- **Output:** "numeric row vector of length m(m–1)/2" in the order "(2,1), (3,1), ..., (m,1), (3,2), ..., (m,2), ..., (m,m–1)" [DOC-pdist]. That is column-major over the lower triangle, the same as `squareform`.
- **Default distance:** 'euclidean', `d = sqrt(sum((xs-xt).^2))` [DOC-pdist].
- **Jaccard:** "One minus the Jaccard coefficient, which is the percentage of nonzero coordinates that differ".

  `d = #[(xs_j ~= xt_j) & ((xs_j ~= 0) | (xt_j ~= 0))] / #[(xs_j ~= 0) | (xt_j ~= 0)]` [DOC-pdist]

  - For **non-binary data**, coordinates count as different when their values differ, not only when their zero pattern differs. For example, [2 0] vs [3 0] gives d = 1.
  - **Two all-zero rows give 0/0 = NaN.** R14 code computes `nesum./nzsum` with no guard [R14:pdist.m]. A 2019 MathWorks Answers thread confirms the NaN in practice (https://www.mathworks.com/matlabcentral/answers/465190-pdist-gives-nan-but-there-are-no-missing-values-in-input-array). The current mex implementation is presumably the same.
- **NaN:** "If observation i or j contains NaNs, then the corresponding value in D is NaN for the built-in distance functions" [DOC-pdist].
- The output class follows X (single or double) [R14:pdist.m].

## 10. corr

Doc: https://www.mathworks.com/help/stats/corr.html

**Defaults** [DOC-corr]

- `'Type','Pearson'`, `'Rows','all'`, `'Tail','both'`.
- With Rows='all', "rho(i,j) and pval(i,j) are NaN if column i or j contains a missing value".
- pval is NaN wherever rho is NaN.

**Output sizes** [DOC-corr]

- `corr(X)` is k-by-k, `corr(X,Y)` is k1-by-k2.
- `[rho,pval]=corr(X)` is accepted by the code [R14:corr.m]. The doc lists pval only for the X,Y syntaxes.

**Pearson**

- rho is the standard formula [DOC-corr].
- R14 computes `(x0/norm(x0))'*(y0/norm(y0))`, so a zero-variance column gives NaN [R14:corr.m].
- p-value: `t = rho.*sqrt((n-2)./(1-rho.^2))`, with `t = ±Inf` when |rho| = 1. Then [R14:corr.m pvalPearson]:
  - both tails: `2*tcdf(-abs(t),n-2)`
  - right: `tcdf(-t,n-2)`
  - left: `tcdf(t,n-2)`
- The doc confirms "Student's t distribution" and that it is exact under normality [DOC-corr].
- Whether the corr(X) diagonal is forced to exactly 1 is UNCONFIRMED. In R14 the diagonal is computed from the data (it can be 1±eps), and its p-value is 0 when rho is exactly 1.

**Spearman**

- Pearson on ranks, with **average ranks for ties** (`tiedrank`) [DOC-corr; R14:tiedrank.m, R14:corr.m].
- R14 coefficient: `D = sum((rx-ry).^2)` and `rho = (meanD-D)/(sqrt(n-1)*stdD)` with tie-corrected meanD and stdD. This equals Pearson on the midranks.

**Kendall**

- **tau-b**: `K/sqrt((n0-T1)(n0-T2))`, where `n0 = n(n-1)/2`, `K = sum_{i<j} sign(dx)sign(dy)`, and T is the count of tied pairs [DOC-corr "often referred to as tau-b"; R14:corr.m].

**Two-tailed p for rank tests**

- The doc says "doubling the more significant of the two one-tailed p-values" [DOC-corr].
- R14 caps the result at 1 and does not double-count the centre bin: `min(2*p,1)` [R14:corr.m].

**Exact vs approximate p-values**

The doc says only "exact permutation distributions (for small sample sizes) or large-sample approximations" [DOC-corr]. The R14 rules [R14:corr.m] are below; whether current releases use the same thresholds is UNCONFIRMED.

| Test | Ties? | n | Method |
|---|---|---|---|
| Kendall | none | **n < 50** | exact null distribution of K by recursion (convolution of `ones(1,i)`, i = 3..n) |
| Kendall | yes | **n < 10** | exact, over all `n!` permutations of the midranks |
| Kendall | none | n ≥ 50 | **normal approximation with continuity correction** |
| Kendall | yes | n ≥ 10 | normal approximation with continuity correction and tie-adjusted stdK |
| Spearman | any | **n < 10** | exact, over all `n!` permutations (of 1:n, or of the midranks when tied) |
| Spearman | none | n ≥ 10 | **AS 89 Edgeworth series** (Best & Roberts 1975) with continuity correction |
| Spearman | yes | n ≥ 10 | **t approximation**: `t = r*sqrt((n-2)/(1-r^2))`, `p = tcdf(-|t|,n-2)`, two-sided `min(2p,1)` |

- **Kendall normal approximation details:**
  - Without ties, `stdK = sqrt(n(n-1)(2n+5)/18)`.
  - With ties, `stdK = sqrt(n0(2n+5)/9 - (x3+y3)/18 + x2*y2/(18*n0*(n-2)) + x1*y1/n0)`. The tie sums come from `tiedrank(x,1)`: `[sum t(t-1)/2; sum t(t-1)(t-2); sum t(t-1)(2t+5)]`.
  - Both: `normcdf(-(abs(K)-1)/stdK)`; right: `normcdf(-(K-1)/stdK)`; left: `normcdf((K+1)/stdK)`.
- **AS 89 (R14):** coefficients `c=[.2274 .2531 .1745 .0758 .1033 .3932 .0879 .0151 .0072 .0831 .0131 .00046]` with `x=(2*(D-1)/n3 - 1)*sqrt(n-1)`, where `n3=(n^3-n)/3`. The p-value is `u*exp(-x^2/2) + 0.5*erfc(x/sqrt(2))`, clipped to [0,1]. Two-sided: `min(2*AS89(max(D,n3-D)),1)`.
- **Ties and missing-data rule:** R14 decides "ties" **per (i,j) column pair**. Pairwise row removal also sends Spearman to the "ties" path.
- **Conflicting secondary source:** a 2018 MathWorks Answers thread (staff answer) states the reverse ("ties -> Edgeworth, no ties -> t") and reports that, in that release, **ties in any column switch the method for all columns** (https://www.mathworks.com/matlabcentral/answers/419555-problem-with-p-value-calculation-for-spearman-s-rho-correlation-analysis). This conflicts with the R14 code and remains UNRESOLVED/UNCONFIRMED for current releases. The R14 code is the primary evidence.
- **Diagonal p-values:** with exact distributions, the diagonal p-values of corr(X) are **not 0** for Spearman and Kendall (R14 help text, [R14:corr.m]).
- **n < 2:** all outputs NaN [R14:corr.m].

## 11. skewness and kurtosis

Docs: https://www.mathworks.com/help/stats/skewness.html and https://www.mathworks.com/help/stats/kurtosis.html

**Shared rules**

- Default flag = 1 (biased). Default dim is the first non-singleton dimension, so a matrix gives a row vector over columns and a row vector gives a scalar [DOC-skewness, DOC-kurtosis].
- **NaN:** "treats NaN values in X as missing values and removes them". Removal is per column [DOC]. R14 uses nanmean throughout [R14:skewness.m].
- `X = []` gives NaN [R14].
- If dim > ndims or size(X,dim) == 1, the result is NaN of size(X) [DOC]. For example, skewness of a scalar is NaN.

**skewness (flag = 1)**

- `m3/m2^1.5`, with central moments that divide by n (non-NaN count) [DOC; R14].
- A constant column gives 0/0 = NaN.
- flag = 0: `s1*sqrt(n(n-1))/(n-2)`. R14 writes it as `s.*sqrt((n-1)./n).*n./(n-2)`, which is identical. n < 3 gives NaN [R14; DOC "at least three elements"].

**kurtosis (flag = 1)**

- `m4/m2^2`. **Not excess**: "The kurtosis of the normal distribution is 3", and the function does not subtract 3 [DOC-kurtosis].
- flag = 0: `((n+1)k1 - 3(n-1))*(n-1)/((n-2)(n-3)) + 3`. n < 4 gives NaN [DOC; R14].

## 12. pca with 'Centered',false and 'Algorithm','als'

Doc: https://www.mathworks.com/help/stats/pca.html

**Outputs** [DOC-pca]

- `coeff`: p-by-k, columns in descending variance order.
- `score`: n-by-k.
- `latent`: k-by-1 column, "eigenvalues of the covariance matrix of X".
- `tsquared`: n-by-1, computed from **all** components, even when fewer are requested.
- `explained`: k-by-1, "percentage of the total variance explained by each principal component".
- `mu`: zeros(1,p) when not centered.

**Centered = 'off'** [DOC-pca]

- The data is not centered, and `X ≈ score*coeff'`.
- **Degrees of freedom:** "d is equal to i – 1 if data is centered, and i otherwise", where i is the number of rows used.
- With Economy = true (default), k = min(NumComponents, d), so **k = min(n,p)** when uncentered (versus min(n-1,p) when centered).
- **latent divisor when uncentered:** inferred to be d = n, i.e. `latent = sigma.^2/n` from the SVD of X. This is consistent with the DOF statement, but the code is UNCONFIRMED.
- **explained:** `100*latent/sum(latent)` is UNCONFIRMED but standard.

**Sign convention**

- "forcing the element with the largest magnitude in each column of coefs to be positive". score columns flip with it [DOC-pca Algorithms].

**ALS** [DOC-pca]

- Alternating least squares, "to better handle missing values". It "uses an iterative method starting with random initial values".
- Coeff0 and Score0 default to random matrices, so **results depend on rng state**.
- statset('pca') defaults: TolFun = 1e-6, TolX = 1e-6, MaxIter = 1000. Reaching MaxIter is treated as convergence.
- With no NaNs, ALS converges to the SVD subspace within tolerance. The doc example reports a subspace angle of 2.9e-16 against SVD.
- Bit-identical agreement with SVD is NOT guaranteed. Expect differences of about 1e-6 relative, and possibly different numbers of returned components. UNCONFIRMED how pca orthonormalises the ALS factors (it presumably runs an SVD of the reconstruction).
- A replacement that uses SVD plus the sign convention reproduces the "ideal" answer, not the exact ALS digits.

## 13. regress

Doc: https://www.mathworks.com/help/stats/regress.html

**Outputs** [DOC-regress]

- `[b,bint,r,rint,stats] = regress(y,X)` (optional alpha, default 0.05).
- b is p-by-1, bint is p-by-2 (95%), r is n-by-1, rint is n-by-2.
- stats is `[R2 F pF s2]` (1-by-4).
- The doc says X "must include a column of ones", and F and p "are not correct for models without a constant".

**NaN rows**

- Omitted from the fit [DOC-regress].
- r and rint get NaN put back at those rows, so they keep the original length [R14:regress.m].

**Algorithm** [R14:regress.m] (current presumably the same, UNCONFIRMED)

1. Remove rows where y or any X value is NaN.
2. Run `[Q,R,perm] = qr(X,0)`. The rank is `p = sum(abs(diag(R)) > max(n,ncolX)*eps(R(1)))`.
3. **If rank-deficient:** issue warning `stats:regress:RankDefDesignMat` ("X is rank deficient to within machine precision."), truncate to the first p pivots, and set the **b entries of dropped columns to 0** (basic solution). The doc confirms "sets the maximum number of elements of b to zero".
4. Residual df is `nu = max(0,n-p)`, where p is the **rank**, not ncolX.
5. `s2 = norm(r)^2/nu`. If nu == 0, then `s2 = NaN` and `tval = 0`.
6. `bint = b ± tinv(1-alpha/2,nu)*se`, with `se(perm) = rmse*sqrt(sum(inv(R).^2,2))`. Dropped coefficients get se = 0, so bint = [0 0].
7. Compute stats:
   - `SSE = ||r||^2`
   - `RSS = ||yhat - mean(y)||^2`
   - `TSS = ||y - mean(y)||^2`
   - **`R2 = 1 - SSE/TSS`**. Always centered, so R2 can be negative without a constant.
   - **`F = (RSS/(p-1))/s2`**. Uses RSS, not TSS-SSE; the two differ without a constant. If p == 1, F = NaN.
   - `pF = 1 - fcdf(F,p-1,nu)` in R14. The current code may use the upper tail (UNCONFIRMED); this only matters for tiny p-values.
8. If no column is all ones and no implied constant exists, issue warning `stats:regress:NoConst`. Stats are still returned.

**rint** [R14:regress.m]

- Leave-one-out studentized intervals: `sigma_i = sqrt(max(0, nu*s2/(nu-1) - r.^2./((nu-1)(1-h))))`, `ser = sqrt(1-h).*sigma_i`, `rint = r ± tval*ser`.
- Where `1-h <= sqrt(eps)`, ser = Inf.

## 14. tdfread

Doc: https://www.mathworks.com/help/stats/tdfread.html

**Syntax and delimiter** [DOC-tdfread]

- `tdfread`, `tdfread(filename)`, `tdfread(filename,delimiter)`, `s = tdfread(___)`. With an output, it "returns a structure s in which each field contains a variable".
- The **default delimiter is tab**.
- Allowed delimiters: `'\t'`/'tab', `' '`/'space', `','`/'comma', `';'`/'semi', `'|'`/'bar'.

**Field names**

- Each variable is named from its first-row value [DOC-tdfread]. How invalid names are made valid in the current release is **UNCONFIRMED**.
- R14 replaced spaces with `_`, collapsed `__` to `_`, and, if `isvarname` failed, fell back to `tdfread_<colIndex>` with a message [R14:tdfread.m].

**Numeric vs char columns**

- "If a column contains only numeric data in all rows except the first, then tdfread creates a double variable." Otherwise it creates a **char** variable [DOC-tdfread].
- char variables are padded char matrices. The DOC example shows Gender as 4x6 and Test as 4x12, i.e. padded to the longest entry [DOC-tdfread].
- R14 tested numeric with `str2num` on the whole padded char block, then `deblank`ed text columns [R14:tdfread.m]. str2num evaluates text, so `NaN`, `Inf`, `1e3`, and even `pi` or `i` parse as numbers.

**R14 whitespace munging** (current UNCONFIRMED)

- Runs of spaces collapse to one, `__` becomes `_`, spaces next to the delimiter are stripped, and trailing spaces at line ends are removed. This changes **text contents** as well as headers.
- Every line must have the same number of delimiters, otherwise error `stats:tdfread:BadFileFormat`.

**Empty numeric cells**

- **UNCONFIRMED**. In R14, an empty field becomes a blank row in the char block, so str2num can drop it and misalign the column (or the column falls back to char). The current behaviour (NaN?) could not be confirmed.
- **Recommendation:** treat this as an edge case to test against a real MATLAB with the Statistics Toolbox.

## 15. smooth (Curve Fitting Toolbox)

Docs: https://www.mathworks.com/help/curvefit/smooth.html and https://www.mathworks.com/help/curvefit/smoothing-data.html

**Defaults and span**

- **Default method is 'moving' and default span is 5** [DOC-smooth].
- Span may be an integer or a fraction in (0,1). For moving and sgolay, an even span (or a fraction giving an even count) "is automatically reduced by 1" [DOC-smooth].

**Moving-average endpoints** [DOC-smoothing-data]

- The span shrinks symmetrically at the ends and stays odd. For span 5:
  - `ys(1)=y(1)`
  - `ys(2)=(y(1)+y(2)+y(3))/3`
  - `ys(3)=mean(y(1:5))`
  - `ys(4)=mean(y(2:6))`
  - and symmetrically at the end: `ys(end)=y(end)`, `ys(end-1)=mean(y(end-2:end))`.
- "the result differs from the result returned by the filter function" [DOC-smooth].

**Use of x** [DOC-smooth, DOC-smoothing-data]

- If x is omitted, `x = 1:length(y)`.
- "If x is not uniform and you do not specify method, lowess is used." **This is a major trap: `smooth(x,y)` with non-uniform x silently becomes lowess.** The floating-point tolerance used to judge "uniform" is UNCONFIRMED.
- "ys(1), ys(2), ..., ys(end) refer to the order of the data after sorting". The data is sorted by x. Returning results in the original order is UNCONFIRMED but presumed.
- For 'moving', x supplies the ordering only. The average is over neighbouring **points**, not an x-distance window (inferred from the formula, which has no x weights). Handling of repeated x values is UNCONFIRMED.

**NaN**

- "If your data contains NaNs and you do not specify x, your data is treated as nonuniform and the smoothing method 'lowess' is used" [DOC-smooth]. This presumably applies only when method is not given (UNCONFIRMED).
- NaN-aware averaging when 'moving' is explicit is UNCONFIRMED.

**Output**

- "returned as a column vector", even for row input [DOC-smooth].

## 16. nansum vs sum(...,'omitnan')

Docs: https://www.mathworks.com/help/stats/nansum.html and https://www.mathworks.com/help/matlab/ref/double.sum.html

- nansum gives "the sum ... computed after removing all NaN values". For an **all-NaN slice the result is 0** [DOC-nansum]. sum with omitnan: "If all elements in the operating dimension are NaN, then the corresponding element in S is 0" [DOC-sum].
- Both use the same default dim (first non-singleton). The doc's migration advice is to use `sum(X,'omitnan')` [DOC-nansum].
- R14 implemented nansum as `x(isnan(x))=0; sum(x[,dim])` [R14:nansum.m], so the results are identical for double input.
- Empty `[]` gives 0 for both (sum of 0x0 is 0) [DOC-sum].

## 17. graphconncomp vs conncomp

Sources: [BIO-REF] and https://www.mathworks.com/help/matlab/ref/graph.conncomp.html

**graphconncomp** [BIO-REF]

- `[S,C] = graphconncomp(G,'Directed',false)`. S is the number of components; C is "a vector indicating to which component each node belongs". C is printed as a row vector in the example.
- `'Directed',false`: "This results in the **upper triangle of the sparse matrix being ignored**". Only the **lower triangle** defines the edges, so a matrix whose edges are only in the upper triangle loses them.
- The undirected case uses a DFS-based algorithm. The strong case uses Tarjan's algorithm. The default is Directed = true and Weak = false.
- **Label order:** for strong components the labels follow Tarjan completion order, not first appearance. The doc example gives `C = [4 4 4 1 1 2 2 4 4 3]`, so node 1 is in component 4.
- Label order for the undirected DFS case is not documented (UNCONFIRMED). A DFS from node 1 upward would give first-appearance labels, but that is not confirmed.

**conncomp** [DOC-conncomp]

- `bins = conncomp(graph(A))` returns a row vector (examples show 1xN).
- **Weak and undirected bins are numbered by smallest node index**: node 1 is in bin 1, and the next unvisited node starts a new bin. Examples: `graph([1 1 4],[2 3 5],[],6)` gives `1 1 1 2 2 3`; the weak example gives `1 1 1 1 1 1 1 2 2 2 3 ... 12`.
- **Strong bins** are topologically ordered ("any edge connecting two components points from the component of smaller bin number to larger"). Example: `4 4 4 4 4 6 5 1 3 2`.

**Migration** (https://www.mathworks.com/matlabcentral/answers/2139451-unrecognized-function-or-variable-graphconncomp)

- graphconncomp's C corresponds to conncomp's first output. S becomes `max(bins)` or `numel(binsizes)`.
- biograph and its methods were removed in R2022b.

**Construction pitfall**

- `graph(A)` requires a symmetric A, or `graph(A,'lower')` / `graph(A,'upper')`. To mimic graphconncomp's Directed=false, use `graph(A,'lower')`, which ignores the upper triangle.
- `graph(A,'lower')` on a non-symmetric adjacency matrix matches graphconncomp exactly. `graph(A|A')` differs if A has upper-only edges.
- Component numbering can differ between the two functions, so compare partitions rather than raw labels.
