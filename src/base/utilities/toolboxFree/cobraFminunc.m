function [x, fval, exitflag, output, grad, hessian] = cobraFminunc(fun, x0, options)
% Unconstrained minimization by a trust-region Newton method with the caller's
% gradient and Hessian, without the Optimization Toolbox
%
% USAGE:
%
%    [x, fval, exitflag, output, grad, hessian] = cobraFminunc(fun, x0, options)
%
% INPUTS:
%    fun:        function handle; [f, g, H] = fun(x) returns the objective value, its gradient
%                (vector with numel(x) entries) and its symmetric Hessian (numel(x) x numel(x))
%    x0:         starting point (numeric array; x keeps its shape)
%    options:    structure of options (names case-insensitive; current and legacy fminunc
%                names); a plain structure replaces optimoptions('fminunc', ...):
%
%                  * Algorithm - 'trust-region' (the only algorithm supported)
%                  * SpecifyObjectiveGradient (or GradObj = 'on') - must be true
%                  * HessianFcn = 'objective' (or Hessian = 'on') - required: fun returns H
%                  * OptimalityTolerance - first-order optimality tolerance (default 1e-6)
%                  * FunctionTolerance - relative change of f (default 1e-6)
%                  * TolFun - sets OptimalityTolerance and FunctionTolerance (legacy)
%                  * StepTolerance (or TolX) - relative step size (default 1e-6)
%                  * MaxIterations (or MaxIter) - default 400
%                  * MaxFunctionEvaluations (or MaxFunEvals) - default 100*numel(x0)
%                  * Display - 'off', 'final' (default), 'notify' or 'iter'
%
% OUTPUTS:
%    x:          the minimizer found, the shape of x0
%    fval:       fun(x)
%    exitflag:   1 first-order optimality below OptimalityTolerance, 2 step below
%                StepTolerance, 3 change of f below FunctionTolerance, 0 iteration or
%                evaluation limit
%    output:     structure with `iterations`, `funcCount`, `firstorderopt` (infinity norm of
%                the gradient), `cgiterations`, `algorithm`, `stepsize` and `message`
%    grad:       gradient at x
%    hessian:    Hessian at x
%
% EXAMPLE:
%
%    rosenbrock = @(x) deal(100*(x(2) - x(1)^2)^2 + (1 - x(1))^2, ...
%        [-400*x(1)*(x(2) - x(1)^2) - 2*(1 - x(1)); 200*(x(2) - x(1)^2)], ...
%        [1200*x(1)^2 - 400*x(2) + 2, -400*x(1); -400*x(1), 200]);
%    x = cobraFminunc(rosenbrock, [-1.2; 1], struct('HessianFcn', 'objective', ...
%        'SpecifyObjectiveGradient', true, 'Display', 'off'))   % [1; 1]
%
% NOTE:
%    Plain-MATLAB replacement for fminunc with Algorithm 'trust-region' and a user-supplied
%    gradient and Hessian (Optimization Toolbox), as used by BDCA and DCA (varKin); the
%    quasi-newton algorithm and any other option raise an error naming it; semantics:
%    specs/20261111-152503-toolbox-free-remaining/mathworks-semantics.md, G2 section 2.
%    Algorithm (Nocedal and Wright 2006, Algorithm 4.1 with the Steihaug-Toint conjugate
%    gradient subproblem solver, Algorithm 7.2): the quadratic model built from the caller's
%    gradient and Hessian is minimized approximately inside the trust region, the conjugate
%    gradient iteration stopping at a direction of negative curvature, at the region's boundary
%    or when the residual falls below min(0.1, sqrt(||g||))*||g|| (inexact Newton forcing
%    term). A step is accepted when f decreases. The radius starts at max(1, ||x0||), shrinks
%    to a quarter of the step when the model predicts poorly (ratio < 1/4) and doubles when it
%    predicts well (ratio > 3/4) at the boundary. Stopping tests: ||g||_inf <=
%    OptimalityTolerance*max(1, ||g(x0)||_inf); ||step|| < StepTolerance*(1 + ||x||);
%    |f_k - f_k+1| < FunctionTolerance*(1 + |f_k|). MathWorks solves the trust-region
%    subproblem in a two-dimensional subspace with a preconditioned conjugate gradient
%    direction; the iterates differ, the minimizer of a problem with a unique minimizer does not
%    (maintainer decision 2026-11-11: same algorithm class, same optimum).
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

if ~exist('options', 'var') || isempty(options)
    options = struct();
end
if ~isstruct(options)
    error('COBRA:cobraFminunc:unsupportedOption', ...
        'cobraFminunc: options must be a structure (optimoptions objects are not available without the Optimization Toolbox).');
end
nVariables = numel(x0);
settings = struct('algorithm', 'trust-region', 'gradient', false, 'hessian', false, ...
    'optimalityTolerance', 1e-6, 'functionTolerance', 1e-6, 'stepTolerance', 1e-6, ...
    'maxIterations', 400, 'maxFunctionEvaluations', 100 * nVariables, 'display', 'final');
names = fieldnames(options);
for k = 1:numel(names)
    value = options.(names{k});
    switch lower(names{k})
        case 'algorithm'
            settings.algorithm = lower(char(value));
        case 'specifyobjectivegradient'
            settings.gradient = isequal(value, true);
        case 'gradobj'
            settings.gradient = strcmpi(char(value), 'on');
        case 'hessianfcn'
            settings.hessian = (ischar(value) || isstring(value)) && strcmpi(char(value), 'objective');
        case 'hessian'
            settings.hessian = (ischar(value) || isstring(value)) && strcmpi(char(value), 'on');
        case 'optimalitytolerance'
            settings.optimalityTolerance = value;
        case 'functiontolerance'
            settings.functionTolerance = value;
        case 'tolfun'
            settings.optimalityTolerance = value;
            settings.functionTolerance = value;
        case {'steptolerance', 'tolx'}
            settings.stepTolerance = value;
        case {'maxiterations', 'maxiter'}
            settings.maxIterations = value;
        case {'maxfunctionevaluations', 'maxfunevals'}
            settings.maxFunctionEvaluations = value;
        case 'display'
            settings.display = lower(char(value));
        otherwise
            error('COBRA:cobraFminunc:unsupportedOption', 'cobraFminunc: unsupported option ''%s''.', names{k});
    end
end
if ~strcmp(settings.algorithm, 'trust-region') || ~settings.gradient || ~settings.hessian
    error('COBRA:cobraFminunc:unsupportedOption', ...
        ['cobraFminunc: unsupported option ''Algorithm'' (only ''trust-region'' with ' ...
        'SpecifyObjectiveGradient = true and HessianFcn = ''objective'' is supported).']);
end
if ~any(strcmp(settings.display, {'off', 'final', 'notify', 'iter'}))
    error('COBRA:cobraFminunc:unsupportedOption', 'cobraFminunc: unsupported option ''Display'' value ''%s''.', settings.display);
end

shape = size(x0);
x = double(x0(:));
[fval, grad, hessian] = evaluate(fun, x, shape);
funcCount = 1;
gradientScale = max(1, norm(grad, Inf));
radius = max(1, norm(x));
iterations = 0;
cgIterations = 0;
stepSize = 0;
exitflag = 0;
message = 'Solver stopped prematurely: the maximum number of iterations was exceeded.';
if norm(grad, Inf) <= settings.optimalityTolerance * gradientScale
    exitflag = 1;
    message = 'Optimization completed: the first-order optimality measure is below the tolerance at the initial point.';
end
while exitflag == 0 && iterations < settings.maxIterations
    iterations = iterations + 1;
    [step, nCg] = steihaug(grad, hessian, radius);
    cgIterations = cgIterations + nCg;
    predictedDecrease = -(grad' * step + 0.5 * step' * (hessian * step));
    [trialValue, trialGradient, trialHessian] = evaluate(fun, x + step, shape);
    funcCount = funcCount + 1;
    ratio = (fval - trialValue) / predictedDecrease;
    stepSize = norm(step);
    if trialValue < fval
        valueChange = fval - trialValue;
        previousValue = fval;
        x = x + step;
        fval = trialValue;
        grad = trialGradient;
        hessian = trialHessian;
        if strcmp(settings.display, 'iter')
            fprintf('cobraFminunc: iteration %d, f = %.10g, first-order optimality %.3g\n', iterations, fval, norm(grad, Inf));
        end
        if norm(grad, Inf) <= settings.optimalityTolerance * gradientScale
            exitflag = 1;
            message = 'Optimization completed: the first-order optimality measure is below the tolerance.';
        elseif stepSize < settings.stepTolerance * (1 + norm(x))
            exitflag = 2;
            message = 'Optimization completed: the size of the step is below the step tolerance.';
        elseif valueChange < settings.functionTolerance * (1 + abs(previousValue))
            exitflag = 3;
            message = 'Optimization completed: the change of the objective value is below the function tolerance.';
        end
    end
    if ratio < 0.25
        radius = 0.25 * stepSize;
        if exitflag == 0 && radius < settings.stepTolerance * (1 + norm(x))
            exitflag = 2;
            message = 'Optimization completed: the trust region shrank below the step tolerance.';
        end
    elseif ratio > 0.75 && stepSize >= 0.99 * radius
        radius = 2 * radius;
    end
    if exitflag == 0 && funcCount >= settings.maxFunctionEvaluations
        message = 'Solver stopped prematurely: the maximum number of function evaluations was exceeded.';
        break
    end
end
x = reshape(x, shape);
output = struct('iterations', iterations, 'funcCount', funcCount, 'firstorderopt', norm(grad, Inf), ...
    'cgiterations', cgIterations, 'algorithm', 'trust-region', 'stepsize', stepSize, 'message', message);
if strcmp(settings.display, 'final') || strcmp(settings.display, 'iter') || (strcmp(settings.display, 'notify') && exitflag == 0)
    fprintf('cobraFminunc: %s\n', message);
end
end

function [f, g, H] = evaluate(fun, x, shape)
% Calls the objective with x in the caller's shape; returns a column gradient and a symmetric Hessian
[f, g, H] = fun(reshape(x, shape));
g = double(g(:));
H = full(double(H));
H = (H + H') / 2;
end

function [step, iterations] = steihaug(g, B, radius)
% Steihaug-Toint conjugate gradient for min g'p + p'Bp/2 subject to ||p|| <= radius
% (Nocedal and Wright 2006, Algorithm 7.2)
step = zeros(size(g));
residual = g;
direction = -residual;
tolerance = min(0.1, sqrt(norm(g))) * norm(g);
iterations = 0;
for iteration = 1:numel(g)
    iterations = iteration;
    curvature = direction' * (B * direction);
    if curvature <= 0
        step = step + toBoundary(step, direction, radius) * direction;
        return
    end
    alpha = (residual' * residual) / curvature;
    nextStep = step + alpha * direction;
    if norm(nextStep) >= radius
        step = step + toBoundary(step, direction, radius) * direction;
        return
    end
    nextResidual = residual + alpha * (B * direction);
    step = nextStep;
    if norm(nextResidual) <= tolerance
        return
    end
    beta = (nextResidual' * nextResidual) / (residual' * residual);
    direction = -nextResidual + beta * direction;
    residual = nextResidual;
end
end

function tau = toBoundary(step, direction, radius)
% The positive tau with ||step + tau*direction|| = radius
a = direction' * direction;
b = 2 * (step' * direction);
c = step' * step - radius ^ 2;
tau = (-b + sqrt(b ^ 2 - 4 * a * c)) / (2 * a);
end
