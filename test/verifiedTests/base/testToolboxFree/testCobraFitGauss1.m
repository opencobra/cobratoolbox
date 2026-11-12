% The COBRAToolbox: testCobraFitGauss1.m
%
% Purpose:
%     - cobraFitGauss1 is the plain-MATLAB replacement for prepareCurveData + fittype('gauss1') +
%       fitoptions('Method','NonlinearLeastSquares') + fit (Curve Fitting Toolbox) as used by
%       createFitL and createFitR (rFASTCORMICS). This test checks exact data, a noisy peak and
%       the two rFASTCORMICS-shaped curves (right hybrid curve and left residual curve, with the
%       start points of createFitR and createFitL) against SciPy curve_fit (trust-region
%       reflective, bound c1 >= 0), the goodness-of-fit fields, the bound on c1 from a negative
%       start, an all-zero curve (a1 -> 0, no warning or error), row/column inputs, NaN removal
%       with a warning, the stopping limits and display levels, the errors for unsupported
%       options, and (only where the toolbox is installed) parity with fit.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraFitGauss1.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Safeguard branches of the trust-region reflective algorithm (the code paths of SciPy's
%     least_squares 'trf') that neither the realistic curves nor the 150 seeded random starts below
%     reach: lines 207-208 (non-finite residuals at a trial point: the Gaussian model stays finite
%     for finite coefficients), 214-217 (zero or negative predicted reduction), 289 (initial
%     damping for a rank-deficient scaled Jacobian), 340, 345-346, 354, 364 (reflection stride
%     limited by a second bound, or no admissible reflection: only c1 has a bound).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCobraFitGauss1'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

relativeError = @(value, reference) abs(value - reference) ./ abs(reference);
coefficients = @(fitresult) [fitresult.a1 fitresult.b1 fitresult.c1];
startR = [0.215494818454649 5.36184523579772 1.10452062242243];   % createFitR
startL = [0.0442312785349232 -0.515420615759673 2.77989514663167]; % createFitL
bounds = [-Inf -Inf 0];

%% exact data: the coefficients are recovered

x = linspace(-5, 10, 100);
y = 0.3 * exp(-((x - 2) / 1.5) .^ 2);
[fitresult, gof, output] = cobraFitGauss1(x, y, 'StartPoint', [0.2 1 1], 'Lower', bounds, 'Display', 'off');
assert(max(relativeError(coefficients(fitresult), [0.3 2 1.5])) < 1e-6);
assert(gof.sse < 1e-12 && abs(gof.rsquare - 1) < 1e-10 && gof.dfe == 97 && output.exitflag > 0);
assert(output.numobs == 100 && output.numparam == 3 && isequal(size(output.Jacobian), [100 3]));
% the function handle evaluates the fitted curve
assert(max(abs(fitresult.f(x) - y)) < 1e-6 && strcmp(fitresult.formula, 'a1*exp(-((x-b1)/c1)^2)'));

%% noisy peak against SciPy (tight tolerances: the optimum itself)

% references/g2_fit_optim.py (section gauss1), SciPy 1.16.3 curve_fit(method='trf', bounds c1 >= 0,
% ftol = xtol = gtol = 1e-14): p = [0.2999999999924558 2.000000000012507 1.5000000000862466],
% sse = 0.004964571701325228, rsquare = 0.9941268342753887, adjrsquare = 0.9940057380748814,
% rmse = 0.007154100331981226
yNoisy = y + 0.01 * sin(7 * x);
tight = {'TolFun', 1e-14, 'TolX', 1e-14, 'MaxIter', 1000, 'MaxFunEvals', 2000};
[fitresult, gof] = cobraFitGauss1(x, yNoisy, 'StartPoint', [0.25 1.5 1.2], 'Lower', bounds, 'Display', 'off', tight{:});
assert(max(relativeError(coefficients(fitresult), [0.2999999999924558 2.000000000012507 1.5000000000862466])) < 1e-8);
assert(relativeError(gof.sse, 0.004964571701325228) < 1e-8 && relativeError(gof.rsquare, 0.9941268342753887) < 1e-10);
assert(relativeError(gof.adjrsquare, 0.9940057380748814) < 1e-10 && relativeError(gof.rmse, 0.007154100331981226) < 1e-8);
% default tolerances (1e-6, as MathWorks) stop within about 1e-6 of the optimum
fitDefault = cobraFitGauss1(x', yNoisy', 'StartPoint', [0.25 1.5 1.2], 'Lower', bounds, 'Display', 'off');
assert(max(relativeError(coefficients(fitDefault), coefficients(fitresult))) < 1e-5);

%% rFASTCORMICS-shaped curves with the start points of createFitR and createFitL

% the same formulas as references/g2_fit_optim.py; SciPy 1.16.3 optimum:
% right: p = [0.2099588439452126 5.4007562870642385 1.1998077534741014], sse = 1.346391592863489e-07
% left:  p = [0.059993216217928184 -0.7998070286671146 2.6006908348598485], sse = 3.0932605346591117e-07
xi = linspace(-6, 12, 100);
density = 0.06 * exp(-((xi + 0.8) / 2.6) .^ 2) + 0.21 * exp(-((xi - 5.4) / 1.2) .^ 2);
[~, peakIndex] = min(abs(xi - 5.4));
hybrid = (xi >= 5.4) .* density + (xi < 5.4) .* density(peakIndex) .* exp(-((xi - 5.4) / 1.2) .^ 2);
rest = density - hybrid;
rest(rest < 1e-4) = 0;
[fitRight, gofRight] = cobraFitGauss1(xi', hybrid', 'StartPoint', startR, 'Lower', bounds, 'Display', 'off', tight{:});
assert(max(relativeError(coefficients(fitRight), [0.2099588439452126 5.4007562870642385 1.1998077534741014])) < 1e-7);
assert(relativeError(gofRight.sse, 1.346391592863489e-07) < 1e-6);
[fitLeft, gofLeft] = cobraFitGauss1(xi, rest, 'StartPoint', startL, 'Lower', bounds, 'Display', 'off', tight{:});
assert(max(relativeError(coefficients(fitLeft), [0.059993216217928184 -0.7998070286671146 2.6006908348598485])) < 1e-7);
assert(relativeError(gofLeft.sse, 3.0932605346591117e-07) < 1e-6);
% with the default tolerances of the call sites, b1 and c1 (the values discretizeFPKM reads)
% agree with the optimum to 1e-4 relative
fitLeftDefault = cobraFitGauss1(xi, rest, 'StartPoint', startL, 'Lower', bounds, 'Display', 'off');
assert(max(relativeError([fitLeftDefault.b1 fitLeftDefault.c1], [fitLeft.b1 fitLeft.c1])) < 1e-4);

%% seeded random starts on peaked data: steps that reach the bound c1 >= 0 are reflected

% (the reflective step selection of the trust-region reflective method); every fit ends with
% c1 >= 0 and a sum of squares no larger than at its start
rng(20261111);
for trial = 1:150
    truth = [0.1 + rand, -3 + 9 * rand, 0.05 + 3 * rand];
    yTrial = truth(1) * exp(-((x - truth(2)) / truth(3)) .^ 2) + 0.01 * randn(size(x));
    start = [2 * rand - 0.5, -5 + 15 * rand, 0.01 + 4 * rand];
    [fitTrial, gofTrial] = cobraFitGauss1(x, yTrial, 'StartPoint', start, 'Lower', bounds, 'Display', 'off');
    startSse = sum((yTrial - start(1) * exp(-((x - start(2)) / start(3)) .^ 2)) .^ 2);
    assert(fitTrial.c1 >= 0 && gofTrial.sse <= startSse * (1 + 1e-12), sprintf('trial %d', trial));
end

%% bound c1 >= 0 from a negative start, and no bounds at all

fitNegative = cobraFitGauss1(x, y, 'StartPoint', [0.2 1 -1], 'Lower', bounds, 'Display', 'off');
assert(fitNegative.c1 > 0 && abs(fitNegative.c1 - 1.5) < 1e-5);
fitFree = cobraFitGauss1(x, y, 'StartPoint', [0.2 1 1], 'Upper', [Inf Inf Inf], 'Display', 'off');
assert(abs(fitFree.c1 - 1.5) < 1e-5);
% a start with c1 = 0 (the model is undefined there) is moved to c1 = eps; no error
fitDegenerate = cobraFitGauss1(x, y, 'StartPoint', [0.2 1 0], 'Display', 'off');
assert(isfinite(fitDegenerate.c1));

%% all-zero curve: a1 goes to 0, b1 and c1 are not identifiable; no warning, no error

lastwarn('');
[fitZero, gofZero] = cobraFitGauss1(xi, zeros(1, 100), 'StartPoint', startL, 'Lower', bounds, 'Display', 'off');
[warningMessage, ~] = lastwarn;
assert(isempty(warningMessage) && abs(fitZero.a1) < 1e-6 && gofZero.sse < 1e-12);

%% data preparation: NaN removed with a warning; numeric checks

yWithNaN = y;
yWithNaN(5) = NaN;
% the warning is expected and printed (warnings are never switched off, Constitution VII-B)
[~, ~, outputNaN] = cobraFitGauss1(x, yWithNaN, 'StartPoint', [0.2 1 1], 'Display', 'off');
[warningMessage, warningId] = lastwarn;
assert(outputNaN.numobs == 99 && strcmp(warningId, 'COBRA:cobraFitGauss1:nonFiniteData'));
assert(contains(warningMessage, '1 data points with NaN or Inf are removed'));
cobraFitGauss1(x, complex(y, 0), 'StartPoint', [0.2 1 1], 'Display', 'off');
[~, warningId] = lastwarn;
assert(strcmp(warningId, 'COBRA:cobraFitGauss1:complexData'));

%% stopping limits and display levels

[~, ~, outputLimit] = cobraFitGauss1(x, yNoisy, 'StartPoint', [0.25 1.5 1.2], 'MaxIter', 1, 'Display', 'notify');
assert(outputLimit.exitflag == 0 && outputLimit.iterations == 1);
[~, ~, outputEvaluations] = cobraFitGauss1(x, yNoisy, 'StartPoint', [0.25 1.5 1.2], 'MaxFunEvals', 2, 'Display', 'off');
assert(outputEvaluations.exitflag == 0 && contains(outputEvaluations.message, 'function evaluations'));
printed = evalc('cobraFitGauss1(x, y, ''StartPoint'', [0.2 1 1], ''Display'', ''iter'');');
assert(contains(printed, 'iteration 1') && contains(printed, 'Success'));
printed = evalc('cobraFitGauss1(x, y, ''StartPoint'', [0.2 1 1], ''Display'', ''final'');');
assert(contains(printed, 'Success') && ~contains(printed, 'iteration'));
% a start at the optimum: the first step is already below TolX, accepted or rejected
[~, ~, outputAtOptimum] = cobraFitGauss1(x, y, 'StartPoint', [0.3 2 1.5], 'Display', 'off');
assert(outputAtOptimum.exitflag > 0);

%% errors: unsupported options and bound patterns, missing start point, invalid data

assert(verifyCobraFunctionError('cobraFitGauss1', 'inputs', {x, y, 'StartPoint', [0.2 1 1], 'Robust', 'LAR'}, ...
    'testMessage', 'cobraFitGauss1: unsupported option ''Robust''.'));
assert(verifyCobraFunctionError('cobraFitGauss1', 'inputs', {x, y, 'StartPoint', [0.2 1 1], 5, 1}, ...
    'testMessage', 'cobraFitGauss1: unsupported option ''double''.'));
assert(verifyCobraFunctionError('cobraFitGauss1', 'inputs', {x, y, 'StartPoint'}, ...
    'testMessage', 'cobraFitGauss1: unsupported option ''StartPoint'' (options are name-value pairs).'));
assert(verifyCobraFunctionError('cobraFitGauss1', 'inputs', {x, y}, ...
    'testMessage', 'cobraFitGauss1: option ''StartPoint'' with the three coefficients [a1 b1 c1] is required.'));
assert(verifyCobraFunctionError('cobraFitGauss1', 'inputs', {x, y, 'StartPoint', [0.2 1 1], 'Lower', [0 -Inf 0]}, ...
    'testMessage', 'cobraFitGauss1: unsupported option ''Lower'' value (supported: [-Inf -Inf 0] or no bounds).'));
assert(verifyCobraFunctionError('cobraFitGauss1', 'inputs', {x, y, 'StartPoint', [0.2 1 1], 'Upper', [1 1 1]}, ...
    'testMessage', 'cobraFitGauss1: unsupported option ''Upper'' value (only no upper bounds are supported).'));
assert(verifyCobraFunctionError('cobraFitGauss1', 'inputs', {x, y, 'StartPoint', [0.2 1 1], 'Display', 'loud'}, ...
    'testMessage', 'cobraFitGauss1: unsupported option ''Display'' value ''loud''.'));
assert(verifyCobraFunctionError('cobraFitGauss1', 'inputs', {x, y(1:50), 'StartPoint', [0.2 1 1]}, ...
    'testMessage', 'cobraFitGauss1: x and y must have the same number of elements.'));
assert(verifyCobraFunctionError('cobraFitGauss1', 'inputs', {{1}, y, 'StartPoint', [0.2 1 1]}, ...
    'testMessage', 'cobraFitGauss1: x and y must be numeric.'));
assert(verifyCobraFunctionError('cobraFitGauss1', 'inputs', {[1 2], [1 2], 'StartPoint', [0.2 1 1]}, ...
    'testMessage', 'cobraFitGauss1: at least three finite data points are needed.'));

%% parity with fit (only where the Curve Fitting Toolbox is installed)

if exist('fit', 'file') == 2 && license('test', 'Curve_Fitting_Toolbox')
    for curve = 1:2
        if curve == 1
            [xData, yData] = prepareCurveData(xi', hybrid');
            startPoint = startR;
        else
            [xData, yData] = prepareCurveData(xi, rest);
            startPoint = startL;
        end
        options = fitoptions('Method', 'NonlinearLeastSquares');
        options.Display = 'Off';
        options.Lower = bounds;
        options.StartPoint = startPoint;
        [fitToolbox, gofToolbox] = fit(xData, yData, fittype('gauss1'), options);
        fitReplacement = cobraFitGauss1(xData, yData, 'StartPoint', startPoint, 'Lower', bounds, 'Display', 'off');
        % both stop within their 1e-6 tolerances of the same optimum
        assert(max(relativeError(coefficients(fitReplacement), [fitToolbox.a1 fitToolbox.b1 fitToolbox.c1])) < 1e-4);
        assert(gofToolbox.sse >= 0);
    end
    fprintf('parity with fit: passed\n');
else
    fprintf('skipped: Curve Fitting Toolbox not installed\n');
end

% change the directory
cd(currentDir)
