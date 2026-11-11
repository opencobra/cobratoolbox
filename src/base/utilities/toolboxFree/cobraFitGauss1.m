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
%    mathworks-semantics.md, G2 section 1. Algorithm: Levenberg-Marquardt in trust-region form
%    (More 1978; Nielsen's damping update) with the analytic Jacobian
%    d/da1 = e, d/db1 = 2*a1*e.*(x - b1)/c1^2, d/dc1 = 2*a1*e.*(x - b1).^2/c1^3 with
%    e = exp(-((x - b1)/c1).^2). The model depends on c1 only through c1^2, so the bound c1 >= 0
%    is met exactly by reporting |c1| (same sum of squares); MathWorks uses a reflective trust
%    region (Coleman and Li) for bounded fits, which can stop at a slightly different point
%    within the tolerances. Stopping: relative coefficient step <= TolX, relative change of the
%    sum of squares <= TolFun, or the iteration and evaluation limits (exitflag 0, with a
%    warning-free message; Display 'notify' prints it). The fitresult is a structure, not a cfit
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
J = jacobian(p, x);
lambda = 1e-3 * max(diag(J' * J));
nu = 2;
exitflag = 0;
message = 'Fit computation did not converge: maximum number of iterations exceeded.';
iteration = 0;
while iteration < options.maxiter
    iteration = iteration + 1;
    A = J' * J;
    g = J' * residual;
    % damped normal equations solved through the eigen-decomposition of the symmetric matrix,
    % dropping directions without curvature (a1 = 0 makes b1 and c1 unidentifiable), so that a
    % singular system gives the minimum-norm step instead of a singular-matrix warning
    damped = A + lambda * diag(max(diag(A), eps));
    [V, E] = eig((damped + damped') / 2);
    curvature = diag(E);
    isUsed = curvature > 3 * eps * max(abs(curvature));
    step = V(:, isUsed) * ((V(:, isUsed)' * g) ./ curvature(isUsed));
    stepNorm = norm(step);
    trial = p + step;
    trialResidual = y - model(trial);
    trialSse = trialResidual' * trialResidual;
    funcCount = funcCount + 1;
    predicted = step' * (lambda * max(diag(A), eps) .* step + g);
    rho = (sse - trialSse) / predicted;
    if rho > 0
        sseChange = sse - trialSse;
        p = trial;
        residual = trialResidual;
        sse = trialSse;
        J = jacobian(p, x);
        lambda = lambda * max(1 / 3, 1 - (2 * rho - 1) ^ 3);
        nu = 2;
        if strcmp(displayLevel, 'iter')
            fprintf('cobraFitGauss1: iteration %d, sum of squares %.10g\n', iteration, sse);
        end
        if stepNorm <= options.tolx * (norm(p) + options.tolx)
            exitflag = 2;
            message = 'Success, but fitting stopped because change in coefficients less than tolerance (TolX).';
            break
        end
        if sseChange <= options.tolfun * sse
            exitflag = 3;
            message = 'Success, but fitting stopped because change in residuals less than tolerance (TolFun).';
            break
        end
    else
        lambda = lambda * nu;
        nu = 2 * nu;
        if stepNorm <= options.tolx * (norm(p) + options.tolx)
            % even the damped step is below the tolerance: no further progress is possible
            exitflag = 2;
            message = 'Success, but fitting stopped because change in coefficients less than tolerance (TolX).';
            break
        end
    end
    if funcCount >= options.maxfunevals
        message = 'Fit computation did not converge: maximum number of function evaluations exceeded.';
        break
    end
end
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
    'algorithm', 'Levenberg-Marquardt (trust-region form)', 'message', message);
if strcmp(displayLevel, 'final') || (strcmp(displayLevel, 'notify') && exitflag == 0) || strcmp(displayLevel, 'iter')
    fprintf('cobraFitGauss1: %s\n', message);
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
