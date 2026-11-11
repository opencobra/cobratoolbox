% The COBRAToolbox: testCobraGeneralizedLinearModel.m
%
% Purpose:
%     - cobraGeneralizedLinearModel is the object returned by cobraFitglm in place of a
%       MathWorks GeneralizedLinearModel (maintainer decision 2026-11-11: scripts that read the
%       fitted models of performRegressions keep working). This test checks the properties that
%       performRegressions and user scripts read (Coefficients table and its brace indexing,
%       CoefficientNames, NumObservations, Variables, Rsquared, ObservationInfo, Fitted), the
%       methods coefCI (t(DFE) quantiles, default and given alpha, against statsmodels and the
%       published MathWorks Poisson example), predict (table and matrix input, binomial and
%       normal, unknown levels), disp, the error for invalid predict input, and that a MathWorks
%       method that is not reproduced raises an error naming it.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraGeneralizedLinearModel.m
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
fileDir = fileparts(which('testCobraGeneralizedLinearModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

relativeError = @(value, reference) abs(value - reference) ./ abs(reference);

% the PERSEPHONE-like table of testCobraFitglm (deterministic data)
i = (1:40)';
flux = sin(0.7 * i) * 3 + i / 10;
age = 20 + mod(7 * i, 31);
isFemale = mod(5 * i, 3) == 0;
sex = repmat("male", 40, 1);
sex(isFemale) = "female";
yNormal = 1.5 + 0.8 * flux - 0.03 * age + 0.6 * isFemale + 0.5 * cos(1.3 * i);
yBinary = double((0.9 * flux - 0.05 * (age - 35) + 0.4 * isFemale + 1.2 * sin(2.1 * i)) > 0.5);
tbl = table(flux, sex, age, yNormal, yBinary, 'VariableNames', {'Flux', 'Sex', 'Age', 'yNormal', 'yBinary'});

%% properties read by performRegressions

mdl = cobraFitglm(tbl, 'yBinary ~ Flux + Sex + Age', 'Distribution', 'binomial');
assert(isa(mdl, 'cobraGeneralizedLinearModel') && iscell(mdl.CoefficientNames) && isrow(mdl.CoefficientNames));
% brace indexing of one row of the 4-column coefficient table (performRegressions line 208)
row = mdl.Coefficients{2, :};
assert(isequal(size(row), [1 4]) && row(1) == mdl.Coefficients.Estimate(2));
assert(isequal(mdl.Coefficients.Properties.VariableNames, {'Estimate', 'SE', 'tStat', 'pValue'}));
assert(isequal(mdl.Coefficients.Properties.RowNames', mdl.CoefficientNames));
% Variables is the whole input table; the first value of a variable can be read
assert(isequal(mdl.Variables, tbl) && mdl.Variables.Sex(1) == "male" && mdl.NumObservations == 40);
assert(isfield(mdl.Rsquared, 'Adjusted') && isfield(mdl.Rsquared, 'Ordinary') && isfield(mdl.Rsquared, 'AdjGeneralized'));
assert(istable(mdl.ObservationInfo) && all(mdl.ObservationInfo.Subset) && istable(mdl.Fitted));
assert(isequal(size(mdl.CoefficientCovariance), [4 4]) && mdl.NumCoefficients == 4 && mdl.NumEstimatedCoefficients == 4);

%% coefCI: t(DFE) quantiles for every distribution

% statsmodels 0.15.0 (references/g3_regression.py, section glm) with t(36) quantiles: the binomial
% intervals [-10.45090034597921 4.030859422827761; 0.441950910266685 4.758758937724419; ...]; the
% IRLS stopping rule leaves about 1e-5 relative between the two fits
ci = coefCI(mdl);
refCi = [-10.45090034597921 4.030859422827761; 0.441950910266685 4.758758937724419; ...
    -1.3414516476147376 7.234374479707542; -0.16347456206255062 0.1630307560097351];
assert(max(relativeError(ci, refCi), [], 'all') < 1e-4);
% normal distribution: statsmodels OLS conf_int (t quantiles), essentially exact
mdlNormal = cobraFitglm(tbl, 'yNormal ~ Flux + Sex + Age');
refCiNormal = [1.1986143673492502 2.201731696044472; 0.7537694851714835 0.8503570676867379; ...
    0.3288869606703347 0.8302384358395625; -0.048809265733310056 -0.022516688233433103];
assert(max(relativeError(coefCI(mdlNormal), refCiNormal), [], 'all') < 1e-10);
% the published MathWorks Poisson example of coefCI: estimates and SE with DFE = 97 give the
% published 95% and 99% intervals (to their 4 decimals)
poissonModel = mdlNormal;
poissonModel = setCoefficients(poissonModel, [1.0405; 0.9968; 1.987], [0.022122; 0.003362; 0.0063433], 97);
assert(max(abs(coefCI(poissonModel) - [0.9966 1.0844; 0.9901 1.0035; 1.9744 1.9996]), [], 'all') < 1e-4);
assert(max(abs(coefCI(poissonModel, 0.01) - [0.9824 1.0986; 0.9880 1.0056; 1.9703 2.0036]), [], 'all') < 1e-4);

%% predict: table input, matrix input, unknown levels

newData = table([1; 2], ["female"; "male"], [30; 40], 'VariableNames', {'Flux', 'Sex', 'Age'});
probability = predict(mdl, newData);
eta = [1 1 1 30; 1 2 0 40] * mdl.Coefficients.Estimate;
assert(max(abs(probability - 1 ./ (1 + exp(-eta)))) < 1e-14);
assert(max(abs(predict(mdlNormal, newData) - [1 1 1 30; 1 2 0 40] * mdlNormal.Coefficients.Estimate)) < 1e-12);
% fitted values on the data equal the predictions there
assert(max(abs(predict(mdlNormal, tbl) - mdlNormal.Fitted.Response)) < 1e-12);
% an unknown level gives NaN
assert(isnan(predict(mdlNormal, table(1, "other", 30, 'VariableNames', {'Flux', 'Sex', 'Age'}))));
% matrix input for a model with continuous predictors only
continuousModel = cobraFitglm(tbl, 'yNormal ~ Flux + Age');
assert(max(abs(predict(continuousModel, [1 30; 2 40]) - [1 1 30; 1 2 40] * continuousModel.Coefficients.Estimate)) < 1e-12);
assert(verifyCobraFunctionError('predict', 'inputs', {mdl, [1 2 3]}, ...
    'testMessage', 'cobraGeneralizedLinearModel.predict: give a table, or a matrix with one column per (continuous) predictor.'));

%% disp: the summary of both distributions (captured with evalc to check the text)

printedBinomial = evalc('disp(mdl)');
assert(contains(printedBinomial, 'logit(yBinary)') && contains(printedBinomial, 'Dispersion: 1') && contains(printedBinomial, 'Chi^2-statistic'));
printedNormal = evalc('disp(mdlNormal)');
assert(contains(printedNormal, 'identity(yNormal)') && contains(printedNormal, 'Estimated Dispersion'));
printedConstant = evalc('disp(cobraFitglm(tbl, ''yNormal ~ Flux - Flux''))');
assert(~contains(printedConstant, 'Chi^2'));

%% a MathWorks method that is not reproduced raises an error naming it

try
    plotResiduals(mdl);
    error('no error');
catch ME
    assert(contains(ME.message, 'plotResiduals'));
end

% change the directory
cd(currentDir)

function mdl = setCoefficients(mdl, estimate, se, dfe)
% A copy of mdl with given estimates, standard errors and error degrees of freedom (for the
% published coefCI example, whose data are not available without the toolbox)
values = struct();
names = [properties(mdl); {'ResponseName'; 'PredictorNames'; 'VariableInfo'; 'Terms'; 'SSE'; 'SST'; 'Deviance0'}];
for k = 1:numel(names)
    values.(names{k}) = mdl.(names{k});
end
values.Coefficients = table(estimate, se, estimate ./ se, zeros(size(se)), 'VariableNames', {'Estimate', 'SE', 'tStat', 'pValue'});
values.DFE = dfe;
mdl = cobraGeneralizedLinearModel(values);
end
