"""Reference values for cobraTabulate, cobraGrp2idx, cobraCrosstab, cobraSkewness,
cobraKurtosis and cobraSmooth (task T006 of feature 20261103-120403-toolbox-free-replacements).

Run:  python3 tables.py
Environment used for the values pasted into the tests: Python 3, SciPy 1.16.0, NumPy 1.26.4.

Sources:
- skewness / kurtosis: scipy.stats.skew(bias=True|False) and
  scipy.stats.kurtosis(fisher=False, bias=True|False), nan_policy='omit'.
- crosstab chi2 / p: scipy.stats.chi2_contingency(correction=False) (Pearson, no Yates).
- tabulate / grp2idx / smooth: hand computation in plain Python from the documented rules in
  mathworks-semantics.md sections 6, 7 and 15 (no SciPy equivalent).

The 24 numbers in RANDN24 are MATLAB's rng('default'); randn(1,24) printed with %.17g on
MATLAB R2025a; the MathWorks skewness/kurtosis documentation examples use exactly these
numbers (displayed there to 4 decimals).
"""
from collections import Counter
import math

import numpy as np
import scipy
from scipy import stats

RANDN24 = [0.53766713954610001, 1.8338850145950865, -2.2588468610036481, 0.86217332036812055,
           0.31876523985898081, -1.3076882963052734, -0.43359202230568356, 0.34262446653864992,
           3.5783969397257605, 2.7694370298848772, -1.3498869401565212, 3.0349234663318545,
           0.72540422494610557, -0.063054873189656191, 0.71474290382609584, -0.20496605829977463,
           -0.12414434821631191, 1.4896976077854649, 1.4090344898004792, 1.4171924134296139,
           0.6714971336080805, -1.2074869226850378, 0.71723865132883846, 1.6302352891647292]


def fmt(values):
    """Print a flat list at full precision in MATLAB literal syntax."""
    arr = np.atleast_1d(np.asarray(values, dtype=float)).ravel(order='F')
    return '[' + ' '.join('%.17g' % v for v in arr) + ']'


def moments():
    print('== skewness / kurtosis ==')
    a = np.array(RANDN24[:20]).reshape((5, 4), order='F')  # MATLAB randn(5,4)
    print('A5x4 skew bias=True  ', fmt(stats.skew(a, axis=0, bias=True)))
    print('A5x4 skew bias=False ', fmt(stats.skew(a, axis=0, bias=False)))
    print('A5x4 kurt bias=True  ', fmt(stats.kurtosis(a, axis=0, fisher=False, bias=True)))
    print('A5x4 kurt bias=False ', fmt(stats.kurtosis(a, axis=0, fisher=False, bias=False)))
    print('A5x4 dim2 skew       ', fmt(stats.skew(a, axis=1, bias=True)))
    print('A5x4 dim2 kurt       ', fmt(stats.kurtosis(a, axis=1, fisher=False, bias=True)))
    x10 = np.array(RANDN24[:10])
    print('x10 skew 1/0 ', fmt([stats.skew(x10, bias=True), stats.skew(x10, bias=False)]))
    print('x10 kurt 1/0 ', fmt([stats.kurtosis(x10, fisher=False, bias=True),
                               stats.kurtosis(x10, fisher=False, bias=False)]))
    c = np.array(RANDN24).reshape((4, 3, 2), order='F')  # MATLAB randn([4 3 2])
    print('C dim1 skew ', fmt(stats.skew(c, axis=0, bias=True)))
    print('C dim1 kurt ', fmt(stats.kurtosis(c, axis=0, fisher=False, bias=True)))
    print('C dim2 skew ', fmt(stats.skew(c, axis=1, bias=True)))
    print('C all skew/kurt ', fmt([stats.skew(c.ravel(), bias=True),
                                   stats.kurtosis(c.ravel(), fisher=False, bias=True)]))
    pages = c.reshape((12, 2), order='F')
    print('C vecdim[1 2] skew ', fmt(stats.skew(pages, axis=0, bias=True)))
    print('C vecdim[1 2] kurt ', fmt(stats.kurtosis(pages, axis=0, fisher=False, bias=True)))
    # NaN is ignored per column
    d = np.array([[1.0, 2.0], [2.0, np.nan], [4.0, 3.0], [np.nan, 7.0], [10.0, 5.0], [3.0, 11.0]])
    print('D nan skew 1 ', fmt(stats.skew(d, axis=0, bias=True, nan_policy='omit')))
    print('D nan skew 0 ', fmt(stats.skew(d, axis=0, bias=False, nan_policy='omit')))
    print('D nan kurt 1 ', fmt(stats.kurtosis(d, axis=0, fisher=False, bias=True, nan_policy='omit')))
    print('D nan kurt 0 ', fmt(stats.kurtosis(d, axis=0, fisher=False, bias=False, nan_policy='omit')))


def crosstab():
    print('== crosstab (scipy chi2_contingency, correction=False) ==')
    tables = {
        'doc example 1 x=[1 1 2 3 1] y=[1 2 5 3 1]': [[2, 1, 0, 0], [0, 0, 0, 1], [0, 0, 1, 0]],
        'doc example 2 (unidrnd table)': [[1, 6, 7], [5, 5, 2], [11, 7, 6]],
        'doc hospital Sex x Smoker': [[40, 13], [26, 21]],
    }
    for name, t in tables.items():
        chi2, p, dof, _ = stats.chi2_contingency(np.array(t), correction=False)
        print(name, 'chi2 %.17g p %.17g dof %d' % (chi2, p, dof))
    # text variables, first-appearance order, '' missing (row dropped)
    resp = ['case', 'control', 'case', '', 'control', 'case', 'control', 'case', 'control', 'case']
    sex = ['M', 'F', 'F', 'M', 'M', 'M', 'F', 'F', 'F', 'M']
    rlev = list(dict.fromkeys(r for r in resp if r != ''))
    slev = list(dict.fromkeys(s for r, s in zip(resp, sex) if r != '' and s != ''))
    t = np.zeros((len(rlev), len(slev)))
    for r, s in zip(resp, sex):
        if r != '' and s != '':
            t[rlev.index(r), slev.index(s)] += 1
    chi2, p, dof, _ = stats.chi2_contingency(t, correction=False)
    print('text levels', rlev, slev, 'table', t.tolist(), 'chi2 %.17g p %.17g dof %d' % (chi2, p, dof))
    # three variables
    x1 = [1, 1, 2, 2, 1, 2, 1, 2, 1, 1, 2, 2]
    x2 = [1, 2, 1, 2, 2, 2, 1, 1, 1, 2, 2, 1]
    x3 = [1, 1, 1, 2, 2, 2, 2, 1, 1, 2, 2, 1]
    t3 = np.zeros((2, 2, 2))
    for a, b, c in zip(x1, x2, x3):
        t3[a - 1, b - 1, c - 1] += 1
    chi2, p, dof, _ = stats.chi2_contingency(t3, correction=False)
    print('3-way table (column-major)', fmt(t3), 'chi2 %.17g p %.17g dof %d' % (chi2, p, dof))


def tabulate_rule(x):
    """Documented tabulate rule for numeric input (mathworks-semantics.md section 6)."""
    y = [v for v in x if not math.isnan(v)]
    cnt = Counter(y)
    if y and all(v == round(v) and v >= 1 for v in y):
        values = list(range(1, int(max(y)) + 1))
    else:
        values = sorted(cnt)
    counts = [cnt.get(v, 0) for v in values]
    total = sum(counts)
    return values, counts, [100.0 * c / total for c in counts]


def tabulate_and_grp2idx():
    print('== tabulate (hand computation of the documented rules) ==')
    for x in ([3, 1, 3, 5, float('nan'), 3], [2.5, -1, 2.5, 0, float('nan')], [0, 2, 2, 3]):
        values, counts, pct = tabulate_rule(x)
        print(x, 'values', fmt(values), 'counts', fmt(counts), 'pct', fmt(pct))
    elems = ['C', 'H', 'C', 'O', 'H', 'C']
    lev = list(dict.fromkeys(elems))
    counts = [elems.count(v) for v in lev]
    print(elems, 'levels', lev, 'counts', counts, 'pct', fmt([100.0 * c / len(elems) for c in counts]))
    print('== grp2idx (hand computation) ==')
    num = [3, 1, float('nan'), 3, 2]
    lev = sorted(set(v for v in num if not math.isnan(v)))
    print(num, 'g', [lev.index(v) + 1 if not math.isnan(v) else 'NaN' for v in num], 'levels', lev)
    txt = ['b', 'a', '', 'b', 'c']
    lev = list(dict.fromkeys(v for v in txt if v != ''))
    print(txt, 'g', [lev.index(v) + 1 if v != '' else 'NaN' for v in txt], 'levels', lev)


def smooth_rule(y, span):
    """Documented moving-average rule (mathworks-semantics.md section 15)."""
    n = len(y)
    out = []
    for i in range(n):
        half = min((span - 1) // 2, i, n - 1 - i)
        window = y[i - half:i + half + 1]
        out.append(math.fsum(window) / len(window))
    return out


def smooth():
    print('== smooth moving (hand computation, exact fsum) ==')
    y = [2.0, 7.0, 1.0, 8.0, 2.0, 8.0, 1.0, 8.0, 2.0, 8.0, 4.5]
    print('y', fmt(y))
    print('span5', fmt(smooth_rule(y, 5)))
    print('span3', fmt(smooth_rule(y, 3)))
    print('span7', fmt(smooth_rule(y, 7)))
    print('span11', fmt(smooth_rule(y, 11)))
    # unsorted uniform x: sort by x, smooth, return in the original order
    x = [6, 2, 10, 4, 8, 12, 14, 18, 16, 20, 22]
    order = sorted(range(len(x)), key=lambda k: x[k])
    ys = smooth_rule([y[k] for k in order], 5)
    back = [0.0] * len(x)
    for pos, k in enumerate(order):
        back[k] = ys[pos]
    print('x', x, 'span5 original order', fmt(back))


def lowess_rule(x, y, span):
    """Documented lowess (smoothing-data page): at each x[i] a degree-1 weighted least-squares
    fit over the `span` nearest points (ties at the span-th distance included, points with
    NaN in y not used), tricube weights (1 - (|x - x_i| / d)^3)^3 with d the largest distance
    in the window, every weight < eps -> weights 1 (UNCONFIRMED choice). Solved with
    numpy.linalg.lstsq (minimum-norm solution when the line is not determined), i.e. a
    different linear-algebra path from the closed form used in cobraSmooth."""
    x = np.asarray(x, dtype=float)
    y = np.asarray(y, dtype=float)
    keep = ~np.isnan(y)
    xd, yd = x[keep], y[keep]
    out = np.empty(len(x))
    for i, xi in enumerate(x):
        d = np.abs(xd - xi)
        if len(d) > span:
            win = d <= np.sort(d)[span - 1]
        else:
            win = np.ones(len(d), dtype=bool)
        off = xd[win] - xi
        scaled = np.abs(off)
        if scaled.max() > 0:
            scaled = scaled / scaled.max()
        w = (1 - scaled ** 3) ** 3
        out[i] = solve_line(off, yd[win], w)
    return out


def solve_line(off, yw, w):
    """Weighted least-squares line evaluated at offset 0, by numpy.linalg.lstsq."""
    off = np.asarray(off, dtype=float)
    w = np.asarray(w, dtype=float)
    yw = np.asarray(yw, dtype=float)
    if np.all(w < np.finfo(float).eps):
        w = np.ones_like(w)
    if len(np.unique(off[w > 0])) < 2:
        # line not determined: weighted mean (cobraSmooth's documented choice, UNCONFIRMED)
        return float(np.sum(w * yw) / np.sum(w))
    root = np.sqrt(w)
    design = np.column_stack([np.ones_like(off), off]) * root[:, None]
    return np.linalg.lstsq(design, np.asarray(yw, dtype=float) * root, rcond=None)[0][0]


def uniform_lowess_rule(y, span):
    """lowess on uniformly spaced data as recalled from MathWorks' smooth.m (UNCONFIRMED):
    span = min(span, n), made odd with 2*floor(span/2)+1; interior point: centred window,
    d = (span-1)/2; j-th point from an end: the span-1 points at that end, d = span - j."""
    y = np.asarray(y, dtype=float)
    n = len(y)
    span = 2 * (min(span, n) // 2) + 1
    if span == 1:
        return y.copy()
    h = (span - 1) // 2
    out = np.empty(n)
    for i in range(1, n + 1):            # 1-based as in the description
        if i > h and i + h <= n:
            idx, dmax = range(i - h, i + h + 1), h
        elif i <= h:
            idx, dmax = range(1, span), span - i
        else:
            idx, dmax = range(n - span + 2, n + 1), i - (n - span + 1)
        off = np.array([k - i for k in idx], dtype=float)
        w = (1 - (np.abs(off) / dmax) ** 3) ** 3
        out[i - 1] = solve_line(off, [y[k - 1] for k in idx], w)
    return out


def moving_ties_rule(x, y, span):
    """'moving' with tied x as recalled from MathWorks' smooth.m (UNCONFIRMED): sort by x,
    span = min(span, n), odd width; each group of equal x is widened on both sides by
    ceil((width - groupSize)/2) points (limited at the ends), then to whole tie groups; all
    points of the group get the mean of the window. Returned in the original order."""
    order = sorted(range(len(x)), key=lambda k: x[k])
    xs = [x[k] for k in order]
    ys = [y[k] for k in order]
    n = len(xs)
    span = min(span, n)
    width = span if span % 2 == 1 else span - 1
    sm = [0.0] * n
    a = 0
    while a < n:
        b = a
        while b + 1 < n and xs[b + 1] == xs[a]:
            b += 1
        h = math.ceil(max(0, (width - (b - a + 1)) / 2))
        h = min(h, a, n - 1 - b)
        lo, hi = a - h, b + h
        while lo > 0 and xs[lo - 1] == xs[lo]:
            lo -= 1
        while hi < n - 1 and xs[hi + 1] == xs[hi]:
            hi += 1
        value = math.fsum(ys[lo:hi + 1]) / (hi - lo + 1)
        for k in range(a, b + 1):
            sm[k] = value
        a = b + 1
    back = [0.0] * n
    for pos, k in enumerate(order):
        back[k] = sm[pos]
    return back


def smooth_lowess():
    print('== smooth lowess (independent numpy lstsq implementation) ==')
    # call-site input: MATLAB rng(1, 'twister'); [n, bins] = hist(randn(1, 1000), 30),
    # bins printed with %.17g on MATLAB R2025a
    bins = [-2.9586328767017265, -2.7455272181571959, -2.5324215596126654, -2.3193159010681343,
            -2.1062102425236038, -1.893104583979073, -1.6799989254345424, -1.4668932668900119,
            -1.2537876083454811, -1.0406819498009503, -0.82757629125641952, -0.61447063271188895,
            -0.40136497416735839, -0.18825931562282783, 0.024846342921702735, 0.23795200146623374,
            0.45105766001076431, 0.66416331855529531, 0.87726897709982588, 1.0903746356443569,
            1.3034802941888874, 1.516585952733418, 1.7296916112779486, 1.9427972698224791,
            2.1559029283670097, 2.3690085869115403, 2.5821142454560708, 2.7952199040006023,
            3.0083255625451319, 3.2214312210896634]
    counts = [2, 3, 4, 7, 9, 21, 22, 30, 24, 46, 52, 82, 77, 83, 99, 83, 78, 80, 48, 42, 33, 25,
              21, 9, 6, 5, 2, 2, 2, 3]
    print('hist bins/n span5', fmt(lowess_rule(bins, counts, 5)))
    y = [2.0, 7.0, 1.0, 8.0, 2.0, 8.0, 1.0, 8.0, 2.0, 8.0, 4.5]
    xg = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]
    print('geometric x span5', fmt(lowess_rule(xg, y, 5)))
    print('geometric x span4', fmt(lowess_rule(xg, y, 4)))
    print('uniform x span5', fmt(lowess_rule(range(1, 12), y, 5)))
    print('uniform x span7', fmt(lowess_rule(range(1, 12), y, 7)))
    # unsorted x with ties (the rule is order-free, so no sorting is needed here)
    xt = [3, 1, 2, 2, 5, 4, 4, 4, 7, 6, 8]
    print('ties x span5', fmt(lowess_rule(xt, y, 5)))
    yn = [2.0, 7.0, np.nan, 8.0, 2.0, 8.0, 1.0, np.nan, 2.0, 8.0, 4.5]
    print('NaN y span5', fmt(lowess_rule(range(1, 12), yn, 5)))
    print('[1 NaN 5 7] span2', fmt(lowess_rule([1, 2, 3, 4], [1, np.nan, 5, 7], 2)))
    print('x [1 1 1 1 2] span3', fmt(lowess_rule([1, 1, 1, 1, 2], [1, 2, 3, 4, 10], 3)))
    # repeated x followed by further points (a sliding window must not stall on ties) and a
    # NaN point whose window has one point of nonzero weight at a nonzero distance
    print('repeated x span2', fmt(lowess_rule([1, 1, 1, 2, 5, 6, 9], [1, 3, 2, 5, 4, 8, 7], 2)))
    print('one weighted point span2', fmt(lowess_rule([2, 2, 2.5, 5.5], [0.05, 0.65, 1.37, np.nan], 2)))
    # unsorted x is not uniform (judged in the given order), so smooth(x, y) uses lowess
    xu = [6, 2, 10, 4, 8, 12, 14, 18, 16, 20, 22]
    print('unsorted x span5 lowess', fmt(lowess_rule(xu, y, 5)))
    print('== smooth lowess, uniform x (recalled unifloess rule) ==')
    for s in (5, 4, 7):
        u = uniform_lowess_rule(y, s)
        print('uniform span%d' % s, fmt(u))
    print('max |unifloess - nearest-neighbour rule| span5/7: %.3g %.3g' % (
        np.max(np.abs(uniform_lowess_rule(y, 5) - lowess_rule(range(1, 12), y, 5))),
        np.max(np.abs(uniform_lowess_rule(y, 7) - lowess_rule(range(1, 12), y, 7)))))
    print('[3 1 4 1] span5 (-> 5 > n)', fmt(uniform_lowess_rule([3, 1, 4, 1], 5)))
    print('[3 1 4 1 5] span7 (-> 5)', fmt(uniform_lowess_rule([3, 1, 4, 1, 5], 7)))
    print('== smooth moving with tied x (recalled rule) ==')
    xr = [1, 2, 2, 3, 4, 4, 4, 5, 6, 7, 8]
    for s in (5, 3):
        print('tied x span%d' % s, fmt(moving_ties_rule(xr, y, s)))
    print('tied unsorted x span5', fmt(moving_ties_rule([4, 1, 2, 4, 3, 2, 4, 5, 6, 7, 8], y, 5)))


if __name__ == '__main__':
    print('SciPy', scipy.__version__, 'NumPy', np.__version__)
    moments()
    crosstab()
    tabulate_and_grp2idx()
    smooth()
    smooth_lowess()
