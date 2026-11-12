function [fitresult, gof, output] = cobraFitGauss1(x, y, varargin)
% Fits the one-term Gaussian model a1*exp(-((x-b1)/c1)^2) by nonlinear least
% squares, without the Curve Fitting Toolbox
%
% USAGE:
%
%    [fitresult, gof, output] = cobraFitGauss1(x, y, 'StartPoint', startPoint)
%    [fitresult, gof, output] = cobraFitGauss1(x, y, 'StartPoint', startPoint, 'Lower', lower, ...
%                                              'Upper', upper, 'Display', display, 'TolFun', tolFun, ...
%                                              'TolX', tolX, 'MaxIter', maxIter, 'MaxFunEvals', maxFunEvals)
%
% INPUTS:
%    x, y:           real numeric vectors with the same number of elements (rows or columns);
%                    pairs with a NaN or Inf are removed (with a warning), as prepareCurveData does
%
% OPTIONAL INPUTS (name-value pairs, names case-insensitive):
%    'StartPoint':   [a1 b1 c1] start point (required: no start-point heuristic is reproduced)
%    'Lower':        lower bounds [a1 b1 c1]; supported: no bound on a1 and b1, and c1 >= 0 or
%                    no bound on c1 (default [-Inf -Inf -Inf])
%    'Upper':        upper bounds; supported: none ([] or Inf)
%    'Display':      'off', 'notify', 'final' or 'iter' (default 'notify'); 'final' and 'iter'
%                    print a one-line summary, 'notify' prints only when the fit does not converge
%    'TolFun':       tolerance on the relative change of the sum of squares (default 1e-6)
%    'TolX':         tolerance on the relative change of the coefficients (default 1e-6)
%    'MaxIter':      maximum number of iterations (default 400)
%    'MaxFunEvals':  maximum number of model evaluations (default 600)
%
% OUTPUTS:
%    fitresult:      structure with the coefficients `a1`, `b1`, `c1` (c1 >= 0), the formula text
%                    `formula` and the function handle `f`, so that fitresult.f(x) evaluates the
%                    fitted curve
%    gof:            structure with `sse`, `rsquare` (1 - sse/sst), `dfe` (n - 3), `adjrsquare`
%                    (1 - (sse/dfe)/(sst/(n - 1))) and `rmse` (sqrt(sse/dfe))
%    output:         structure with `numobs`, `numparam`, `residuals`, `Jacobian`, `exitflag`
%                    (> 0 converged, 0 iteration or evaluation limit), `iterations`, `funcCount`,
%                    `firstorderopt`, `algorithm` and `message`
%
% EXAMPLE:
%
%    x = linspace(-5, 10, 100);
%    y = 0.3 * exp(-((x - 2) / 1.5) .^ 2);
%    fitresult = cobraFitGauss1(x, y, 'StartPoint', [0.2 1 1], 'Lower', [-Inf -Inf 0]);
%    % fitresult.a1 = 0.3, fitresult.b1 = 2, fitresult.c1 = 1.5
%
% NOTE:
%    Plain-MATLAB replacement for prepareCurveData + fittype('gauss1') + fitoptions('Method',
%    'NonlinearLeastSquares') + fit (Curve Fitting Toolbox) as used by createFitL and createFitR;
%    supported options are those listed above, any other option or bound pattern raises an
%    error naming it; semantics: specs/20261111-152503-toolbox-free-remaining/
%    mathworks-semantics.md, G2 section 1. Algorithm: trust-region reflective nonlinear least
%    squares for bounds (Branch, Coleman and Li 1999; the class of the MathWorks default
%    'Trust-Region', which Curve Fitting uses for bounded fits), written after SciPy's
%    least_squares(method='trf', x_scale=1) with the exact subproblem solver (More-Hebden
%    iteration on the singular value decomposition of the scaled, augmented Jacobian), with the
%    analytic Jacobian
%    d/da1 = e, d/db1 = 2*a1*e.*(x - b1)/c1^2, d/dc1 = 2*a1*e.*(x - b1).^2/c1^3 with
%    e = exp(-((x - b1)/c1).^2). The model depends on c1 only through c1^2, so the bound c1 >= 0
%    with the bound c1 >= 0 handled by the reflective method (c1 is reported as |c1|; the sum of
%    squares depends on c1^2). The result can differ from MathWorks within the tolerances.
%    Stopping (SciPy rules): scaled gradient below 1e-8 (exitflag 1), relative coefficient step
%    below TolX (2), relative reduction of the sum of squares below TolFun on a well-predicted
%    step (3), or the iteration and evaluation limits (exitflag 0, with a warning-free message;
%    Display 'notify' prints it). The fitresult is a structure, not a cfit
%    object: dot access to the coefficients works as before; use fitresult.f to evaluate or plot.
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

options = struct('startpoint', [], 'lower', [], 'upper', [], 'display', 'notify', ...
    'tolfun', 1e-6, 'tolx', 1e-6, 'maxiter', 400, 'maxfunevals', 600);
if mod(numel(varargin), 2) ~= 0
    error('COBRA:cobraFitGauss1:unsupportedOption', ...
        'cobraFitGauss1: unsupported option ''%s'' (options are name-value pairs).', describeValue(varargin{end}));
end
for k = 1:2:numel(varargin)
    name = lower(describeValue(varargin{k}));
    if ~isfield(options, name)
        error('COBRA:cobraFitGauss1:unsupportedOption', 'cobraFitGauss1: unsupported option ''%s''.', describeValue(varargin{k}));
    end
    options.(name) = varargin{k + 1};
end
if isempty(options.startpoint) || numel(options.startpoint) ~= 3
    error('COBRA:cobraFitGauss1:unsupportedOption', ...
        'cobraFitGauss1: option ''StartPoint'' with the three coefficients [a1 b1 c1] is required.');
end
lowerBound = options.lower;
if isempty(lowerBound)
    lowerBound = -Inf(1, 3);
end
if numel(lowerBound) ~= 3 || any(lowerBound(1:2) ~= -Inf) || lowerBound(3) > 0
    error('COBRA:cobraFitGauss1:unsupportedOption', ...
        'cobraFitGauss1: unsupported option ''Lower'' value (supported: [-Inf -Inf 0] or no bounds).');
end
if ~isempty(options.upper) && any(options.upper(:) ~= Inf)
    error('COBRA:cobraFitGauss1:unsupportedOption', ...
        'cobraFitGauss1: unsupported option ''Upper'' value (only no upper bounds are supported).');
end
displayLevel = lower(describeValue(options.display));
if ~any(strcmp(displayLevel, {'off', 'notify', 'final', 'iter'}))
    error('COBRA:cobraFitGauss1:unsupportedOption', ...
        'cobraFitGauss1: unsupported option ''Display'' value ''%s''.', describeValue(options.display));
end

[x, y] = prepareData(x, y);
n = numel(x);

model = @(p) p(1) * exp(-((x - p(2)) / p(3)) .^ 2);
p = double(options.startpoint(:));
if p(3) == 0
    p(3) = eps;
end
residual = y - model(p);
sse = residual' * residual;
funcCount = 1;
% the only bound supported is c1 >= 0 (a negative lower bound on c1 is no bound: the model
% depends on c1^2)
if lowerBound(3) == 0
    lowerBound = [-Inf; -Inf; 0];
else
    lowerBound = -Inf(3, 1);
end
upperBound = Inf(3, 1);
if lowerBound(3) == 0 && p(3) <= 0
    p(3) = abs(p(3)) + eps; % strictly feasible start (the model depends on c1^2)
    residual = y - model(p);
    sse = residual' * residual;
end
[p, iteration, funcCount, exitflag, message] = trustRegionReflective(@(q) model(q) - y, @(q) jacobian(q, x), ...
    p, lowerBound, upperBound, options.tolfun, options.tolx, options.maxiter, options.maxfunevals, displayLevel);
residual = y - model(p);
sse = residual' * residual;
p(3) = abs(p(3));

a1 = p(1);
b1 = p(2);
c1 = p(3);
fitresult = struct('a1', a1, 'b1', b1, 'c1', c1, 'formula', 'a1*exp(-((x-b1)/c1)^2)', ...
    'f', @(t) a1 * exp(-((t - b1) / c1) .^ 2));
sst = sum((y - mean(y)) .^ 2);
dfe = n - 3;
gof = struct('sse', sse, 'rsquare', 1 - sse / sst, 'dfe', dfe, ...
    'adjrsquare', 1 - (sse / dfe) / (sst / (n - 1)), 'rmse', sqrt(sse / dfe));
output = struct('numobs', n, 'numparam', 3, 'residuals', residual, 'Jacobian', jacobian(p, x), ...
    'exitflag', exitflag, 'iterations', iteration, 'funcCount', funcCount, ...
    'firstorderopt', norm(jacobian(p, x)' * residual, Inf), ...
    'algorithm', 'trust-region-reflective', 'message', message);
if strcmp(displayLevel, 'final') || (strcmp(displayLevel, 'notify') && exitflag == 0) || strcmp(displayLevel, 'iter')
    fprintf('cobraFitGauss1: %s\n', message);
end
end

function [x, iteration, funcCount, exitflag, message] = trustRegionReflective(fun, jac, x, lb, ub, ftol, xtol, maxIter, maxFunEvals, displayLevel)
% Trust-region reflective least squares for bounds (Branch, Coleman and Li 1999), as implemented
% in SciPy's least_squares(method='trf') with x_scale = 1 and the exact subproblem solver: Coleman-
% Li scaling of the variables by their distance to the bound the gradient points to, the
% subproblem on the augmented Jacobian [J*d; sqrt(diag(g.*dv))] solved through the singular value
% decomposition (More-Hebden iteration), and the choice between the trust-region step, its
% reflection at the bound and the scaled anti-gradient
f = fun(x);
funcCount = 1;
J = jac(x);
cost = 0.5 * (f' * f);
g = J' * f;
[v, ~] = scalingVector(x, g, lb, ub);
radius = norm(x ./ sqrt(v)); % > 0: c1 is never 0 at the start
alpha = 0;
iteration = 0;
exitflag = 0;
message = 'Fit computation did not converge: maximum number of iterations exceeded.';
n = numel(x);
m = numel(f);
while true
    [v, dv] = scalingVector(x, g, lb, ub);
    gradientNorm = norm(g .* v, Inf);
    if gradientNorm < 1e-8
        exitflag = 1;
        message = 'Success. Fitting converged to a solution.';
        break
    end
    if iteration >= maxIter
        break
    end
    if funcCount >= maxFunEvals
        message = 'Fit computation did not converge: maximum number of function evaluations exceeded.';
        break
    end
    d = sqrt(v);
    diagH = g .* dv;
    gH = d .* g;
    JH = J .* d';
    [U, S, V] = svd([JH; diag(sqrt(diagH))], 0);
    singular = diag(S);
    uf = U' * [f; zeros(n, 1)];
    theta = max(0.995, 1 - gradientNorm);
    actualReduction = -1;
    status = 0;
    while actualReduction <= 0 && funcCount < maxFunEvals
        [pH, alpha] = solveTrustRegion(n, m, uf, singular, V, radius, alpha);
        p = d .* pH;
        [step, stepH, predictedReduction] = selectStep(x, JH, diagH, gH, p, pH, d, radius, lb, ub, theta);
        xNew = x + step;
        xNew(xNew <= lb) = lb(xNew <= lb) + eps(lb(xNew <= lb)); % strictly feasible (next number above the bound)
        fNew = fun(xNew);
        funcCount = funcCount + 1;
        stepHNorm = norm(stepH);
        if ~all(isfinite(fNew))
            radius = 0.25 * stepHNorm;
            continue
        end
        costNew = 0.5 * (fNew' * fNew);
        actualReduction = cost - costNew;
        if predictedReduction > 0
            ratio = actualReduction / predictedReduction;
        elseif predictedReduction == 0 && actualReduction == 0
            ratio = 1;
        else
            ratio = 0;
        end
        newRadius = radius;
        if ratio < 0.25
            newRadius = 0.25 * stepHNorm;
        elseif ratio > 0.75 && stepHNorm > 0.95 * radius
            newRadius = 2 * radius;
        end
        stepNorm = norm(step);
        isFtol = actualReduction < ftol * cost && ratio > 0.25;
        isXtol = stepNorm < xtol * (xtol + norm(x));
        if isFtol || isXtol
            status = 2 + double(isXtol && ~isFtol);
            break
        end
        alpha = alpha * radius / newRadius;
        radius = newRadius;
    end
    if actualReduction > 0
        x = xNew;
        f = fNew;
        cost = costNew;
        J = jac(x);
        g = J' * f;
    end
    iteration = iteration + 1;
    if strcmp(displayLevel, 'iter')
        fprintf('cobraFitGauss1: iteration %d, sum of squares %.10g\n', iteration, 2 * cost);
    end
    if status == 2
        exitflag = 3;
        message = 'Success, but fitting stopped because change in residuals less than tolerance (TolFun).';
        break
    elseif status == 3
        exitflag = 2;
        message = 'Success, but fitting stopped because change in coefficients less than tolerance (TolX).';
        break
    end
end
end

function [v, dv] = scalingVector(x, g, lb, ub)
% Coleman-Li scaling: distance to the bound that the negative gradient points to
v = ones(size(x));
dv = zeros(size(x));
mask = g < 0 & isfinite(ub);
v(mask) = ub(mask) - x(mask);
dv(mask) = -1;
mask = g > 0 & isfinite(lb);
v(mask) = x(mask) - lb(mask);
dv(mask) = 1;
end

function [p, alpha] = solveTrustRegion(n, m, uf, s, V, radius, alpha)
% min ||J*p + f|| subject to ||p|| <= radius, J = U*diag(s)*V' (More-Hebden iteration on alpha)
suf = s .* uf;
isFullRank = m >= n && s(end) > eps * m * s(1);
if isFullRank
    p = -V * (uf ./ s);
    if norm(p) <= radius
        alpha = 0;
        return
    end
end
alphaUpper = norm(suf) / radius;
if isFullRank
    [phi, phiPrime] = phiAndDerivative(0, suf, s, radius);
    alphaLower = -phi / phiPrime;
else
    alphaLower = 0;
end
if ~isFullRank && alpha == 0
    alpha = max(0.001 * alphaUpper, sqrt(alphaLower * alphaUpper));
end
for iterationCount = 1:10
    if alpha < alphaLower || alpha > alphaUpper
        alpha = max(0.001 * alphaUpper, sqrt(alphaLower * alphaUpper));
    end
    [phi, phiPrime] = phiAndDerivative(alpha, suf, s, radius);
    if phi < 0
        alphaUpper = alpha;
    end
    ratio = phi / phiPrime;
    alphaLower = max(alphaLower, alpha - ratio);
    alpha = alpha - (phi + radius) * ratio / radius;
    if abs(phi) < 0.01 * radius
        break
    end
end
p = -V * (suf ./ (s .^ 2 + alpha));
p = p * radius / norm(p);
end

function [phi, phiPrime] = phiAndDerivative(alpha, suf, s, radius)
% ||p(alpha)|| - radius and its derivative
denominator = s .^ 2 + alpha;
pNorm = norm(suf ./ denominator);
phi = pNorm - radius;
phiPrime = -sum(suf .^ 2 ./ denominator .^ 3) / pNorm;
end

function [step, stepH, predicted] = selectStep(x, JH, diagH, gH, p, pH, d, radius, lb, ub, theta)
% Trust-region step if it stays feasible; otherwise the best of its reflection at the bound, the
% step to the bound shortened by theta, and the scaled anti-gradient (Branch, Coleman, Li 1999)
if all(x + p >= lb) && all(x + p <= ub)
    step = p;
    stepH = pH;
    predicted = -quadraticValue(JH, gH, pH, diagH);
    return
end
[pStride, hits] = stepToBound(x, p, lb, ub);
rH = pH;
rH(hits ~= 0) = -rH(hits ~= 0);
r = d .* rH;
p = p * pStride;
pH = pH * pStride;
xOnBound = x + p;
[~, toRegion] = intersectRegion(pH, rH, radius);
toBound = stepToBound(xOnBound, r, lb, ub);
rStride = min(toBound, toRegion);
if rStride > 0
    rStrideLower = (1 - theta) * pStride / rStride;
    if rStride == toBound
        rStrideUpper = theta * toBound;
    else
        rStrideUpper = toRegion;
    end
else
    rStrideLower = 0;
    rStrideUpper = -1;
end
if rStrideLower <= rStrideUpper
    [a, b, c] = quadratic1d(JH, gH, rH, pH, diagH);
    [rStride, rValue] = minimizeQuadratic1d(a, b, rStrideLower, rStrideUpper, c);
    rH = rH * rStride + pH;
    r = rH .* d;
else
    rValue = Inf;
end
p = p * theta;
pH = pH * theta;
pValue = quadraticValue(JH, gH, pH, diagH);
agH = -gH;
ag = d .* agH;
toRegion = radius / norm(agH);
toBound = stepToBound(x, ag, lb, ub);
if toBound < toRegion
    agStride = theta * toBound;
else
    agStride = toRegion;
end
[a, b] = quadratic1d(JH, gH, agH, [], diagH);
[agStride, agValue] = minimizeQuadratic1d(a, b, 0, agStride, 0);
agH = agH * agStride;
ag = ag * agStride;
if pValue < rValue && pValue < agValue
    step = p;
    stepH = pH;
    predicted = -pValue;
elseif rValue < pValue && rValue < agValue
    step = r;
    stepH = rH;
    predicted = -rValue;
else
    step = ag;
    stepH = agH;
    predicted = -agValue;
end
end

function value = quadraticValue(J, g, s, diagH)
% 0.5*s'*(J'*J + diag(diagH))*s + g'*s
q = J * s;
value = 0.5 * (q' * q + sum(diagH .* s .^ 2)) + g' * s;
end

function [a, b, c] = quadratic1d(J, g, s, s0, diagH)
% Coefficients of the quadratic model along s0 + t*s: a*t^2 + b*t + c
v = J * s;
a = 0.5 * (v' * v + sum(diagH .* s .^ 2));
b = g' * s;
c = 0;
if ~isempty(s0)
    u = J * s0;
    b = b + u' * v + sum(diagH .* s0 .* s);
    c = 0.5 * (u' * u + sum(diagH .* s0 .^ 2)) + g' * s0;
end
end

function [t, value] = minimizeQuadratic1d(a, b, lower, upper, c)
% Minimum of a*t^2 + b*t + c over [lower, upper]
candidates = [lower, upper];
if a ~= 0
    extremum = -0.5 * b / a;
    if lower < extremum && extremum < upper
        candidates(end + 1) = extremum;
    end
end
values = candidates .* (a * candidates + b) + c;
[value, index] = min(values);
t = candidates(index);
end

function [minStep, hits] = stepToBound(x, s, lb, ub)
% Largest step along s inside the bounds and the variables whose bound is hit (with the sign of s)
steps = Inf(size(x));
isMoving = s ~= 0;
steps(isMoving) = max((lb(isMoving) - x(isMoving)) ./ s(isMoving), (ub(isMoving) - x(isMoving)) ./ s(isMoving));
minStep = min(steps);
hits = (steps == minStep) .* sign(s);
end

function [t1, t2] = intersectRegion(x, s, radius)
% The two values of t with ||x + t*s|| = radius (t1 <= t2)
a = s' * s;
b = x' * s;
c = x' * x - radius ^ 2;
discriminant = sqrt(b ^ 2 - a * c);
q = -(b + sign(b + (b == 0)) * discriminant);
t1 = q / a;
t2 = c / q;
if t1 > t2
    [t1, t2] = deal(t2, t1);
end
end

function J = jacobian(p, x)
% Jacobian of the model a1*exp(-((x - b1)/c1)^2) with respect to [a1 b1 c1]
e = exp(-((x - p(2)) / p(3)) .^ 2);
J = [e, 2 * p(1) * e .* (x - p(2)) / p(3) ^ 2, 2 * p(1) * e .* (x - p(2)) .^ 2 / p(3) ^ 3];
end

function [x, y] = prepareData(x, y)
% Columns of finite double data, as prepareCurveData returns them
if ~(isnumeric(x) || islogical(x)) || ~(isnumeric(y) || islogical(y))
    error('COBRA:cobraFitGauss1:invalidInput', 'cobraFitGauss1: x and y must be numeric.');
end
if numel(x) ~= numel(y)
    error('COBRA:cobraFitGauss1:invalidInput', 'cobraFitGauss1: x and y must have the same number of elements.');
end
if ~isreal(x) || ~isreal(y)
    warning('COBRA:cobraFitGauss1:complexData', 'cobraFitGauss1: imaginary parts of the data are ignored.');
end
x = double(real(x(:)));
y = double(real(y(:)));
isFinitePair = isfinite(x) & isfinite(y);
if ~all(isfinite(x) & isfinite(y))
    warning('COBRA:cobraFitGauss1:nonFiniteData', 'cobraFitGauss1: %d data points with NaN or Inf are removed.', sum(~isFinitePair));
    x = x(isFinitePair);
    y = y(isFinitePair);
end
if numel(x) < 3
    error('COBRA:cobraFitGauss1:invalidInput', 'cobraFitGauss1: at least three finite data points are needed.');
end
end

function text = describeValue(value)
% Text naming an option or value in an error message
if ischar(value) || isstring(value)
    text = char(value);
else
    text = class(value);
end
end
