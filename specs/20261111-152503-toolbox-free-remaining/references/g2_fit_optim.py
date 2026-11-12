"""Reference values for group G2 (curve fit and optimizers).

Feature 20261111-152503-toolbox-free-remaining. Run with the reference virtual environment
(SciPy 1.16.3, NumPy):

    python -I g2_fit_optim.py [section]
"""
import sys

import numpy as np
import scipy
from scipy import optimize


def m(values):
    a = np.asarray(values, dtype=float)
    fmt = lambda v: 'NaN' if np.isnan(v) else repr(float(v))
    if a.ndim == 0:
        return fmt(a)
    if a.ndim == 1:
        return '[' + ' '.join(fmt(v) for v in a) + ']'
    return '[' + '; '.join(' '.join(fmt(v) for v in row) for row in a) + ']'


def header(name):
    print(f'\n%% {name} -- SciPy {scipy.__version__}, NumPy {np.__version__}')


def gauss1(x, a1, b1, c1):
    return a1 * np.exp(-((x - b1) / c1) ** 2)


def fit(x, y, p0):
    """Bounded fit with c1 >= 0, trust-region reflective, tight tolerances (the optimum)."""
    p, _ = optimize.curve_fit(gauss1, x, y, p0=p0, bounds=([-np.inf, -np.inf, 0], [np.inf, np.inf, np.inf]),
                              method='trf', ftol=1e-14, xtol=1e-14, gtol=1e-14, max_nfev=100000)
    r = y - gauss1(x, *p)
    sse = r @ r
    sst = ((y - y.mean()) ** 2).sum()
    n = len(x)
    return p, sse, 1 - sse / sst, 1 - (sse / (n - 3)) / (sst / (n - 1)), np.sqrt(sse / (n - 3))


START_R = [0.215494818454649, 5.36184523579772, 1.10452062242243]
START_L = [0.0442312785349232, -0.515420615759673, 2.77989514663167]


def section_gauss1():
    header('gauss1')
    # noisy single peak: deterministic perturbation (no random generator needed in MATLAB)
    x = np.linspace(-5, 10, 100)
    y = 0.3 * np.exp(-((x - 2) / 1.5) ** 2) + 0.01 * np.sin(7 * x)
    p, sse, r2, adj, rmse = fit(x, y, [0.25, 1.5, 1.2])
    print('noisy peak (start [0.25 1.5 1.2]): p =', m(p), ' sse, rsquare, adjrsquare, rmse =', m([sse, r2, adj, rmse]))
    # rFASTCORMICS-like curves on a 100-point grid: a right peak (hybrid curve) and a left
    # residual curve with values below 1e-4 set to 0
    xi = np.linspace(-6, 12, 100)
    density = 0.06 * np.exp(-((xi + 0.8) / 2.6) ** 2) + 0.21 * np.exp(-((xi - 5.4) / 1.2) ** 2)
    hybrid = np.where(xi >= 5.4, density, 0.0)
    hybrid = hybrid + np.where(xi < 5.4, density[np.argmin(np.abs(xi - 5.4))] * np.exp(-((xi - 5.4) / 1.2) ** 2), 0.0)
    rest = density - hybrid
    rest[rest < 1e-4] = 0.0
    print('xi = linspace(-6, 12, 100); density, hybrid and rest built in the test with the same formulas')
    p, sse, *_ = fit(xi, hybrid, START_R)
    print('right fit (createFitR start): p =', m(p), ' sse =', m(sse))
    p, sse, *_ = fit(xi, rest, START_L)
    print('left fit (createFitL start): p =', m(p), ' sse =', m(sse))


def section_fminunc():
    header('fminunc')
    f = lambda x: x[0] ** 4 + x[0] * x[1] + (1 + x[1]) ** 2
    g = lambda x: np.array([4 * x[0] ** 3 + x[1], x[0] + 2 * (1 + x[1])])
    h = lambda x: np.array([[12 * x[0] ** 2, 1.0], [1.0, 2.0]])
    res = optimize.minimize(f, [0.75, -1.25], jac=g, hess=h, method='trust-exact', options={'gtol': 1e-14})
    print('negative curvature start [0.75 -1.25]: x =', m(res.x), ' f =', m(res.fun),
          ' eig(H(x)) =', m(np.linalg.eigvalsh(h(res.x))), ' Hessian at start eig =', m(np.linalg.eigvalsh(h([0.75, -1.25]))))
    res = optimize.minimize(f, [0.0, 0.0], jac=g, hess=h, method='trust-exact', options={'gtol': 1e-14})
    print('start [0 0] (indefinite Hessian there): x =', m(res.x), ' f =', m(res.fun))


SECTIONS = {name[len('section_'):]: f for name, f in globals().items() if name.startswith('section_')}

if __name__ == '__main__':
    for name in (sys.argv[1:] or SECTIONS):
        SECTIONS[name]()
