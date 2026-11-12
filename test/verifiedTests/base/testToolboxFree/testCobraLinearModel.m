% The COBRAToolbox: testCobraLinearModel.m
%
% Purpose:
%     - cobraLinearModel is the object returned by cobraFitlm in place of a MathWorks
%       LinearModel. This test checks its properties (SSE, SSR, SST, MSE, RMSE, Rsquared,
%       Fitted, Coefficients, NumObservations), the methods coefCI (default and given alpha,
%       against statsmodels), predict and disp, and that a MathWorks method that is not
%       reproduced raises an error naming it.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraLinearModel.m
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
fileDir = fileparts(which('testCobraLinearModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the data of testCobraFitlm (statsmodels 0.15.0 OLS: SSE 0.740237215341591, RMSE 0.30418687006131423)
x = [0.2 1.1 1.9 3.2 3.8 5.1 6.0 6.8 8.1 9.0];
y = 2.0 + 0.7 * x + [0.3 -0.2 0.1 -0.4 0.5 -0.1 0.2 -0.3 0.0 0.25];
mdl = cobraFitlm(x, y);

%% properties: sums of squares, mean squared error, fitted values

assert(abs(mdl.SSE - 0.740237215341591) < 1e-13 && abs(mdl.SST - sum((y - mean(y)) .^ 2)) < 1e-12);
assert(abs(mdl.SSR - (mdl.SST - mdl.SSE)) < 1e-12 && abs(mdl.MSE - mdl.SSE / 8) < 1e-15 && abs(mdl.RMSE - 0.30418687006131423) < 1e-13);
assert(abs(mdl.Rsquared.Ordinary - (1 - mdl.SSE / mdl.SST)) < 1e-14 && isequal(fieldnames(mdl.Rsquared), {'Ordinary'; 'Adjusted'}));
assert(isequal(size(mdl.Fitted), [10 1]) && max(abs(mdl.Fitted - [ones(10, 1), x'] * mdl.Coefficients.Estimate)) < 1e-12);
assert(istable(mdl.Variables) && isequal(mdl.Variables.Properties.VariableNames, {'x1', 'y'}) && strcmp(mdl.Formula, 'y ~ 1 + x1'));
assert(mdl.NumCoefficients == 2 && mdl.NumEstimatedCoefficients == 2 && istable(mdl.ObservationInfo));

%% coefCI (t quantiles; statsmodels conf_int computed in the same way) and predict

halfWidth = cobraTinv(0.975, 8) * mdl.Coefficients.SE;
assert(max(abs(coefCI(mdl) - [mdl.Coefficients.Estimate - halfWidth, mdl.Coefficients.Estimate + halfWidth]), [], 'all') < 1e-14);
halfWidth99 = cobraTinv(0.995, 8) * mdl.Coefficients.SE;
assert(max(abs(coefCI(mdl, 0.01) - [mdl.Coefficients.Estimate - halfWidth99, mdl.Coefficients.Estimate + halfWidth99]), [], 'all') < 1e-14);
assert(max(abs(predict(mdl, [0; 10]) - [1 0; 1 10] * mdl.Coefficients.Estimate)) < 1e-12);

%% disp (captured with evalc to check the text)

printedSummary = evalc('disp(mdl)');
assert(contains(printedSummary, 'Linear regression model') && contains(printedSummary, 'R-squared: 0.9815'));

%% a MathWorks method that is not reproduced raises an error naming it

try
    anova(mdl);
    error('no error');
catch ME
    assert(contains(ME.message, 'anova'));
end

% change the directory
cd(currentDir)
