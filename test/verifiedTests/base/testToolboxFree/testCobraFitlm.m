% The COBRAToolbox: testCobraFitlm.m
%
% Purpose:
%     - cobraFitlm is the plain-MATLAB replacement for fitlm(x, y) (Statistics and Machine
%       Learning Toolbox), as used by CreateClusterAndRAtables and
%       dimensionalityReductionAndMultivariateAnalysis. This test checks a simple regression
%       against statsmodels OLS (estimates, SE, p-values, R^2, SSE, RMSE), the properties the
%       call sites read (Rsquared.Ordinary, NumObservations, Coefficients row 2), matrix and
%       categorical predictors, NaN rows, the rank-deficiency warning that the call sites use to
%       drop a result, and the errors for unsupported input.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraFitlm.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCobraFitlm'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

relativeError = @(value, reference) abs(value - reference) ./ abs(reference);

%% simple regression against statsmodels OLS

% references/g3_regression.py (section fitlm), statsmodels 0.15.0 OLS
x = [0.2 1.1 1.9 3.2 3.8 5.1 6.0 6.8 8.1 9.0];
y = 2.0 + 0.7 * x + [0.3 -0.2 0.1 -0.4 0.5 -0.1 0.2 -0.3 0.0 0.25];
mdl = cobraFitlm(x, y);
assert(isa(mdl, 'cobraLinearModel') && isequal(mdl.CoefficientNames, {'(Intercept)', 'x1'}));
assert(max(relativeError(mdl.Coefficients.Estimate', [2.0368058330003973 0.6996004794246904])) < 1e-12);
assert(max(relativeError(mdl.Coefficients.SE', [0.1812591112695857 0.033988738837002465])) < 1e-12);
assert(max(relativeError(mdl.Coefficients.pValue', [3.531233212733592e-06 3.249722452866397e-08])) < 1e-8);
assert(relativeError(mdl.Rsquared.Ordinary, 0.9814674244058998) < 1e-12 && relativeError(mdl.Rsquared.Adjusted, 0.9791508524566374) < 1e-12);
assert(relativeError(mdl.SSE, 0.740237215341591) < 1e-12 && relativeError(mdl.RMSE, 0.30418687006131423) < 1e-12);
% the values the call sites read
assert(mdl.NumObservations == 10 && mdl.DFE == 8 && mdl.Coefficients.Estimate(2) == mdl.Coefficients{2, 1});

%% matrix and categorical predictors, NaN rows

X = [x', cos(x')];
mdlMatrix = cobraFitlm(X, y');
assert(isequal(mdlMatrix.CoefficientNames, {'(Intercept)', 'x1', 'x2'}) && mdlMatrix.NumObservations == 10);
group = categorical({'a'; 'b'; 'a'; 'c'; 'b'; 'c'; 'a'; 'b'; 'c'; 'a'});
mdlCategorical = cobraFitlm(group, y');
assert(isequal(mdlCategorical.CoefficientNames, {'(Intercept)', 'x1_b', 'x1_c'}));
% the intercept is the mean of level a, the slopes the differences of the level means
assert(abs(mdlCategorical.Coefficients.Estimate(1) - mean(y(group == 'a'))) < 1e-12);
assert(abs(mdlCategorical.Coefficients.Estimate(2) - (mean(y(group == 'b')) - mean(y(group == 'a')))) < 1e-12);
yWithNaN = y;
yWithNaN(4) = NaN;
assert(cobraFitlm(x, yWithNaN).NumObservations == 9);

%% rank deficiency: a constant predictor raises the warning the call sites check with lastwarn

lastwarn('');
cobraFitlm([x', ones(10, 1)], y');
[~, warningId] = lastwarn;
assert(strcmp(warningId, 'COBRA:cobraFitglm:RankDeficient'));

%% errors: options, table input, size mismatch

assert(verifyCobraFunctionError('cobraFitlm', 'inputs', {x, y, 'Intercept', false}, ...
    'testMessage', 'cobraFitlm: unsupported option ''Intercept'' (only the syntax cobraFitlm(x, y) is supported).'));
assert(verifyCobraFunctionError('cobraFitlm', 'inputs', {x, y, 2}, ...
    'testMessage', 'cobraFitlm: unsupported option ''double'' (only the syntax cobraFitlm(x, y) is supported).'));
assert(verifyCobraFunctionError('cobraFitlm', 'inputs', {table(x', y'), 'Var2 ~ Var1'}, ...
    'testMessage', 'cobraFitlm: unsupported option ''table input'' (use cobraFitglm with a formula).'));
assert(verifyCobraFunctionError('cobraFitlm', 'inputs', {x, y(1:5)}, ...
    'testMessage', 'cobraFitlm: y must have one value per row of x.'));

%% parity with fitlm (only where the Statistics and Machine Learning Toolbox is installed)

if exist('fitlm', 'file') == 2 && license('test', 'Statistics_Toolbox')
    mdlToolbox = fitlm(x, y);
    assert(max(abs(mdl.Coefficients{:, :} - mdlToolbox.Coefficients{:, :}) ./ abs(mdlToolbox.Coefficients{:, :}), [], 'all') < 1e-10);
    assert(abs(mdl.Rsquared.Ordinary - mdlToolbox.Rsquared.Ordinary) < 1e-12);
    fprintf('parity with fitlm: passed\n');
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)
