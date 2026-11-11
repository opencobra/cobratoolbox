function mdl = cobraFitlm(x, y, varargin)
% Fits a linear regression model y ~ 1 + x1 + ... by least squares, without
% the Statistics and Machine Learning Toolbox
%
% USAGE:
%
%    mdl = cobraFitlm(x, y)
%
% INPUTS:
%    x:      n x k predictor matrix (numeric or logical; one column per predictor) or a
%            categorical vector; do not include a column of ones
%    y:      n x 1 numeric response
%
% OUTPUT:
%    mdl:    cobraLinearModel object with the properties of a MathWorks LinearModel used by
%            the toolbox (Coefficients, Rsquared.Ordinary, NumObservations, DFE, ...) and the
%            methods coefCI, predict and disp
%
% EXAMPLE:
%
%    mdl = cobraFitlm([1; 2; 3; 4], [2.1; 3.9; 6.2; 7.8]);
%    slope = mdl.Coefficients.Estimate(2);   % 1.92
%
% NOTE:
%    Plain-MATLAB replacement for fitlm(X, y) (Statistics and Machine Learning Toolbox)
%    with an intercept and no options; any further argument raises an error naming it;
%    semantics: specs/20261111-152503-toolbox-free-remaining/mathworks-semantics.md, G3
%    section 5. The predictors are named x1, ..., xk and the response y, as MathWorks names
%    them for matrix input; a categorical x gives reference-coded columns x1_<level>. The fit
%    is the normal-distribution fit of cobraFitglm (least squares through the QR
%    decomposition): coefficient p-values from t(DFE), rows with NaN excluded, and the
%    warning COBRA:cobraFitglm:RankDeficient for a rank-deficient design.
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

if ~isempty(varargin)
    option = varargin{1};
    if ischar(option) || isstring(option)
        optionName = char(option);
    else
        optionName = class(option);
    end
    error('COBRA:cobraFitlm:unsupportedOption', 'cobraFitlm: unsupported option ''%s'' (only the syntax cobraFitlm(x, y) is supported).', optionName);
end
if istable(x)
    error('COBRA:cobraFitlm:unsupportedOption', 'cobraFitlm: unsupported option ''table input'' (use cobraFitglm with a formula).');
end
if isvector(x)
    x = x(:);
end
if numel(y) ~= size(x, 1)
    error('COBRA:cobraFitlm:invalidInput', 'cobraFitlm: y must have one value per row of x.');
end
names = arrayfun(@(k) sprintf('x%d', k), 1:size(x, 2), 'UniformOutput', false);
if iscategorical(x)
    tbl = table(x, double(y(:)), 'VariableNames', {'x1', 'y'});
else
    tbl = [array2table(double(x), 'VariableNames', names), table(double(y(:)), 'VariableNames', {'y'})];
end
formula = ['y ~ ' strjoin(names, ' + ')];
mdl = cobraLinearModel(cobraFitglm(tbl, formula, 'Distribution', 'normal'));
end
