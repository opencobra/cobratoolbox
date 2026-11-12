"""Reference values for group G1 (statistical tests, distributions, utilities).

Feature 20261111-152503-toolbox-free-remaining. Run with the reference virtual environment
(SciPy 1.16.3, NumPy, statsmodels 0.15.0, scikit-learn 1.9.1):

    python -I g1_stats.py [section]

Each section prints MATLAB-pastable values with full precision. The values are pasted into
test/verifiedTests/base/testToolboxFree/testCobra<Name>.m with a comment naming this script.
"""
import sys

import numpy as np
import scipy
from scipy import stats

np.set_printoptions(precision=17)


def m(values):
    """Format a number or array as a MATLAB literal (row vector for 1-D, rows for 2-D)."""
    a = np.asarray(values, dtype=float)
    fmt = lambda v: 'NaN' if np.isnan(v) else ('Inf' if v == np.inf else ('-Inf' if v == -np.inf else repr(float(v))))
    if a.ndim == 0:
        return fmt(a)
    if a.ndim == 1:
        return '[' + ' '.join(fmt(v) for v in a) + ']'
    return '[' + '; '.join(' '.join(fmt(v) for v in row) for row in a) + ']'


def header(name):
    print(f'\n%% {name} -- SciPy {scipy.__version__}, NumPy {np.__version__}')


# beam-strength data of the MathWorks anova1/kruskalwallis documentation examples
STRENGTH = np.array([82, 86, 79, 83, 84, 85, 86, 87, 74, 82, 78, 75, 76, 77, 79, 79, 77, 78, 82, 79], float)
ALLOY = ['st'] * 8 + ['al1'] * 6 + ['al2'] * 6


def oneway_tables(y, labels):
    """Sums of squares of a one-way layout (groups in first-appearance order)."""
    names = list(dict.fromkeys(labels))
    groups = [y[[l == n for l in labels]] for n in names]
    grand = y.mean()
    ssg = sum(len(g) * (g.mean() - grand) ** 2 for g in groups)
    sst = ((y - grand) ** 2).sum()
    return names, groups, ssg, sst - ssg, sst


def section_tiedrank():
    header('tiedrank')
    x = np.array([[3, np.nan, 1, 1, 2, 3, 3], [0.5, 0.5, np.nan, np.nan, -1, np.inf, np.inf]]).T
    r = stats.rankdata(x, method='average', axis=0, nan_policy='omit')
    print('xMatrix =', m(x))
    print('refRanks =', m(r))
    for column in range(x.shape[1]):
        v = x[:, column][~np.isnan(x[:, column])]
        _, t = np.unique(v, return_counts=True)
        print(f'refTieadj column {column + 1} =', m((t ** 3 - t).sum() / 2))


def section_anova1():
    header('anova1')
    names, groups, ssg, sse, sst = oneway_tables(STRENGTH, ALLOY)
    f, p = stats.f_oneway(*groups)
    k, n = len(groups), len(STRENGTH)
    print('beam: SSg, SSe, SSt =', m([ssg, sse, sst]), ' F, p =', m([f, p]),
          ' dfs =', m([k - 1, n - k, n - 1]), ' s =', m(np.sqrt(sse / (n - k))))
    print('beam means (st, al1, al2) =', m([g.mean() for g in groups]))
    # unbalanced data with NaN and a missing group label
    y = np.array([1.5, 2.25, np.nan, 3.0, 4.75, 0.5, 2.0, 6.0, 5.5, 1.0])
    lab = ['b', 'a', 'a', 'c', 'b', 'a', '', 'c', 'c', 'a']
    keep = ~np.isnan(y) & np.array([l != '' for l in lab])
    y2, lab2 = y[keep], [l for l, k2 in zip(lab, keep) if k2]
    names, groups, ssg, sse, sst = oneway_tables(y2, lab2)
    f, p = stats.f_oneway(*groups)
    print('unbalanced: names =', names, ' SSg, SSe, SSt =', m([ssg, sse, sst]), ' F, p =', m([f, p]))


def section_kruskalwallis():
    header('kruskalwallis')
    h, p = stats.kruskal(*[STRENGTH[[a == n for a in ALLOY]] for n in ['st', 'al1', 'al2']])
    r = stats.rankdata(STRENGTH)
    names, groups, ssg, sse, sst = oneway_tables(r, ALLOY)
    _, t = np.unique(STRENGTH, return_counts=True)
    print('beam: H, p =', m([h, p]), ' SSg, SSe, SSt (ranks) =', m([ssg, sse, sst]),
          ' sumt =', m((t ** 3 - t).sum()), ' meanranks =', m([g.mean() for g in groups]))
    y = np.array([0.3, np.nan, 1.2, 0.3, 2.2, 5.0, 0.3, 4.1, 3.3, 2.2, 1.0])
    grp = np.array([0, 1, 1, 2, 0, 2, 1, 2, 0, 1, 0])
    keep = ~np.isnan(y)
    h, p = stats.kruskal(*[y[keep & (grp == g)] for g in range(3)])
    print('numeric groups with NaN: H, p =', m([h, p]))


def ranksum_by_hand(x, y):
    """W (rank sum of x), z with continuity and tie correction, approximate p (MathWorks rule)."""
    pooled = np.concatenate([x, y])
    r = stats.rankdata(pooled)
    nx, ny = len(x), len(y)
    n = nx + ny
    w = r[:nx].sum()
    _, t = np.unique(pooled, return_counts=True)
    tiescor = (t ** 3 - t).sum() / (n * (n - 1))
    sigma = np.sqrt(nx * ny * ((n + 1) - tiescor) / 12)
    e = nx * (n + 1) / 2
    z = (w - e - 0.5 * np.sign(w - e)) / sigma
    return w, z, 2 * stats.norm.cdf(-abs(z))


def ranksum_exact(x, y):
    """Exact two-sided p over mid-ranks by full enumeration (permutation_test)."""
    pooled = np.concatenate([x, y])
    r = stats.rankdata(pooled)
    nx = len(x)
    res = stats.permutation_test((r[:nx], r[nx:]), lambda a, b: a.sum(), permutation_type='independent',
                                 n_resamples=np.inf, alternative='two-sided')
    return r[:nx].sum(), min(res.pvalue, 1.0)


def section_ranksum():
    header('ranksum')
    mileage_x = np.array([33.3, 33.4, 32.9, 32.6, 32.5, 33.0])
    mileage_y = np.array([34.5, 34.8, 33.8, 33.4, 33.7, 33.9])
    print('mileage exact: W, p =', m(ranksum_exact(mileage_x, mileage_y)))
    # unequal sizes with ties, exact (x larger than y)
    x = np.array([1.0, 2.0, 2.0, 5.0, 7.0, 7.0, 8.0])
    y = np.array([2.0, 3.0, 9.0, 10.0])
    print('ties exact x(7) y(4): W, p =', m(ranksum_exact(x, y)))
    # approximate, unequal sizes, ties and zeros (performStatisticalAnalysis-like data)
    rng = np.random.default_rng(20261111)
    xa = np.round(rng.normal(1.0, 1.0, 25), 1)
    xa[:6] = 0.0
    ya = np.round(rng.normal(1.6, 1.0, 14), 1)
    ya[:3] = 0.0
    print('xa =', m(xa))
    print('ya =', m(ya))
    w, z, p = ranksum_by_hand(xa, ya)
    mw = stats.mannwhitneyu(xa, ya, alternative='two-sided', use_continuity=True, method='asymptotic')
    print('approximate: W, z, p =', m([w, z, p]), ' scipy mannwhitneyu p =', m(mw.pvalue))
    # exact without ties, larger sample (default rule picks approximate at N >= 20)
    xs = np.array([0.8, 1.9, 2.4, 3.1, 4.6, 5.2, 6.7, 7.3, 8.8])
    ys = np.array([2.2, 4.1, 5.9, 9.4, 10.6, 11.1, 12.5])
    print('no ties: exact p (scipy mannwhitneyu exact) =', m(stats.mannwhitneyu(xs, ys, method='exact').pvalue),
          ' W =', m(stats.rankdata(np.concatenate([xs, ys]))[:len(xs)].sum()))


def section_ttest2():
    header('ttest2')
    x = np.array([5.1, 4.9, 6.2, 5.8, 6.0, 5.5, 5.3, np.nan])
    y = np.array([6.4, 6.8, 5.9, 7.1, 6.6, 7.0])
    res = stats.ttest_ind(x, y, equal_var=True, nan_policy='omit')
    ci = res.confidence_interval(0.95)
    xc = x[~np.isnan(x)]
    nx, ny = len(xc), len(y)
    sd = np.sqrt(((nx - 1) * xc.var(ddof=1) + (ny - 1) * y.var(ddof=1)) / (nx + ny - 2))
    print('t, p, df, sd =', m([res.statistic, res.pvalue, res.df, sd]), ' ci =', m([ci.low, ci.high]))


def stephens_p(d, n1, n2, two_sided):
    n = n1 * n2 / (n1 + n2)
    lam = max((np.sqrt(n) + 0.12 + 0.11 / np.sqrt(n)) * d, 0)
    if two_sided:
        j = np.arange(1, 102)
        return min(max(2 * np.sum((-1.0) ** (j - 1) * np.exp(-2 * lam ** 2 * j ** 2)), 0), 1)
    return np.exp(-2 * lam ** 2)


def section_kstest2():
    header('kstest2')
    x, y = np.arange(50.0), np.arange(14.0, 64.0)
    print('doc-equivalent D = 0.28: one-sided p =', m(stephens_p(0.28, 50, 50, False)),
          ' two-sided p =', m(stephens_p(0.28, 50, 50, True)),
          ' kstwobign.sf =', m(stats.kstwobign.sf((np.sqrt(25) + 0.12 + 0.11 / 5) * 0.28)))
    rng = np.random.default_rng(7)
    a = np.round(rng.normal(0, 1, 23), 2)
    b = np.round(rng.normal(0.4, 1.3, 31), 2)
    print('a =', m(a))
    print('b =', m(b))
    for alt, name in [('two-sided', 'unequal'), ('greater', 'larger'), ('less', 'smaller')]:
        d = stats.ks_2samp(a, b, alternative=alt).statistic
        print(f'{name}: D, p =', m([d, stephens_p(d, 23, 31, name == 'unequal')]))


def section_hygecdf():
    header('hygecdf')
    print('doc lower 0:8 (100,20,10) =', m(stats.hypergeom.cdf(np.arange(9), 100, 20, 10)))
    print('doc upper [7 8] =', m(stats.hypergeom.sf([7, 8], 100, 20, 10)))
    # FEA-like column: M = 95 reactions, K per subsystem, N = 12 drawn
    xk = np.array([2, 0, 5, 1, 3])
    kk = np.array([10, 3, 7, 40, 25])
    print('FEA-like upper P(X >= x) for x =', m(xk), ' K =', m(kk), ':', m(stats.hypergeom.sf(xk - 1, 95, kk, 12)))
    print('large M upper (x=30, M=5000, K=200, N=300) =', m(stats.hypergeom.sf(30, 5000, 200, 300)),
          ' lower =', m(stats.hypergeom.cdf(30, 5000, 200, 300)))


def section_ksdensity():
    header('ksdensity')
    x = np.array([2.1, 3.4, 3.4, 5.0, 1.2, 7.7, 4.4, 3.9, 2.8, 6.1, np.nan, 4.0, 3.3])
    x = x[~np.isnan(x)]
    n = len(x)
    sigma = stats.median_abs_deviation(x, scale=1.0) / 0.6745
    h = sigma * (4 / (3 * n)) ** 0.2
    xi = np.linspace(x.min() - 3 * h, x.max() + 3 * h, 100)
    kde = stats.gaussian_kde(x, bw_method=h / np.std(x, ddof=1))
    f = kde(xi)
    print('bw =', m(h), ' xi(1), xi(end) =', m([xi[0], xi[-1]]))
    print('f at indices 1, 25, 50, 75, 100 =', m(f[[0, 24, 49, 74, 99]]))
    print('sum(f)*dx =', m(f.sum() * (xi[1] - xi[0])))


def classical_mds(d):
    n = d.shape[0]
    p = np.eye(n) - np.ones((n, n)) / n
    b = -p @ (d ** 2) @ p / 2
    b = (b + b.T) / 2
    e, v = np.linalg.eigh(b)
    idx = np.argsort(e)[::-1]
    e, v = e[idx], v[:, idx]
    keep = e > np.abs(e).max() * np.finfo(float).eps ** 0.75
    return v[:, keep] * np.sqrt(e[keep]), e


def section_cmdscale():
    header('cmdscale')
    # US cities distances of the MathWorks cmdscale documentation example (miles)
    cities = np.array([
        [0, 587, 1212, 701, 1936, 604, 748, 2139, 2182, 543],
        [587, 0, 920, 940, 1745, 1188, 713, 1858, 1737, 597],
        [1212, 920, 0, 879, 831, 1726, 1631, 949, 1021, 1494],
        [701, 940, 879, 0, 1374, 968, 1420, 1645, 1891, 1220],
        [1936, 1745, 831, 1374, 0, 2339, 2451, 347, 959, 2300],
        [604, 1188, 1726, 968, 2339, 0, 1092, 2594, 2734, 923],
        [748, 713, 1631, 1420, 2451, 1092, 0, 2571, 2408, 205],
        [2139, 1858, 949, 1645, 347, 2594, 2571, 0, 678, 2442],
        [2182, 1737, 1021, 1891, 959, 2734, 2408, 678, 0, 2329],
        [543, 597, 1494, 1220, 2300, 923, 205, 2442, 2329, 0]], float)
    y, e = classical_mds(cities)
    print('cities e/1e6 =', m(e / 1e6))
    print('cities |Y(1,:)|/1e3 =', m(np.abs(y[0]) / 1e3), ' size(Y) =', y.shape)
    # small Euclidean configuration (pdist vector input)
    pts = np.array([[0, 0], [3, 0], [0, 4], [1, 1], [2, 5]], float)
    d = np.sqrt(((pts[:, None, :] - pts[None, :, :]) ** 2).sum(-1))
    y, e = classical_mds(d)
    print('points e =', m(e), ' |Y| =', m(np.abs(y)))


def section_confusionmat():
    header('confusionmat')
    from sklearn import __version__ as skv
    from sklearn.metrics import confusion_matrix
    print('scikit-learn', skv)
    g = np.array([3, 2, 2, 3, 1, 1.0])
    gh = np.array([4, 2, 3, np.nan, 1, 1.0])
    keep = ~np.isnan(g) & ~np.isnan(gh)
    print('doc default =', m(confusion_matrix(g[keep], gh[keep], labels=[1, 2, 3, 4])))
    print('doc order 4:-1:1 =', m(confusion_matrix(g[keep], gh[keep], labels=[4, 3, 2, 1])))
    t = np.array([1, 0, -1, 1, 1, 0, -1, np.nan, 0])
    p = np.array([1, 0, 1, -1, 1, np.nan, -1, 1, 0])
    keep = ~np.isnan(t) & ~np.isnan(p)
    print('modelPredictiveCapacity order [1 0 -1] =', m(confusion_matrix(t[keep], p[keep], labels=[1, 0, -1])))
    P = ['Active', 'Inactive', 'Active', 'Active', 'Inactive', 'Inactive']
    T = ['Active', 'Active', '', 'Active', 'Inactive', 'Active']
    pairs = [(a, b) for a, b in zip(P, T) if a and b]
    print('text order {Active, Inactive} =', m(confusion_matrix([a for a, _ in pairs], [b for _, b in pairs], labels=['Active', 'Inactive'])))


SECTIONS = {name[len('section_'):]: f for name, f in globals().items() if name.startswith('section_')}

if __name__ == '__main__':
    for name in (sys.argv[1:] or SECTIONS):
        SECTIONS[name]()
