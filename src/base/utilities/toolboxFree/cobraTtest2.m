function [h, p, ci, stats] = cobraTtest2(x, y, varargin)
% Two-sample t-test (equal variances) without the Statistics and Machine
% Learning Toolbox
%
% USAGE:
%
%    [h, p, ci, stats] = cobraTtest2(x, y)
%
% INPUTS:
%    x, y:     real numeric vectors (row or column, lengths may differ); NaN
%              values are removed
%
% OUTPUTS:
%    h:        1 if the null hypothesis of equal means is rejected at the 5%
%              level, 0 otherwise, NaN when p is NaN (double, as MathWorks)
%    p:        two-sided p-value
%    ci:       95% confidence interval of mean(x) - mean(y), a 1 x 2 row for
%              row-vector `x` and a 2 x 1 column otherwise
%    stats:    structure with fields `tstat`, `df` (nx + ny - 2) and `sd`
%              (pooled standard deviation)
%
% EXAMPLE:
%
%    [h, p] = cobraTtest2([1 2 3 4], [3 4 5 6])   % h = 0, p = 0.0742
%
% NOTE:
%    Plain-MATLAB replacement for ttest2 (Statistics and Machine Learning
%    Toolbox) with its defaults (Vartype 'equal', Tail 'both', Alpha 0.05);
%    supported syntax: [h, p, ci, stats] = cobraTtest2(x, y) with vectors;
%    any further argument raises an error naming it; semantics:
%    specs/20261111-152503-toolbox-free-remaining/mathworks-semantics.md,
%    G1 section 4. df = nx + ny - 2,
%    sd = sqrt(((nx - 1)*var(x) + (ny - 1)*var(y))/df),
%    t = (mean(x) - mean(y))/(sd*sqrt(1/nx + 1/ny)), p = 2*P(T(df) < -|t|),
%    ci = mean(x) - mean(y) +- tinv(0.975, df)*sd*sqrt(1/nx + 1/ny). A zero
%    pooled standard deviation gives t = +-Inf and p = 0, or t = NaN and
%    p = NaN when the means are also equal (IEEE arithmetic, as in R14).
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
    error('COBRA:cobraTtest2:unsupportedOption', ...
        'cobraTtest2: unsupported option ''%s'' (only the syntax cobraTtest2(x, y) is supported).', optionName);
end
if ~(isnumeric(x) || islogical(x)) || ~(isnumeric(y) || islogical(y)) || ~isvector(x) || ~isvector(y)
    error('COBRA:cobraTtest2:invalidInput', 'cobraTtest2: x and y must be numeric vectors.');
end

isRowInput = isrow(x) && ~isscalar(x);
x = double(x(:));
y = double(y(:));
x = x(~isnan(x));
y = y(~isnan(y));
nx = numel(x);
ny = numel(y);
df = nx + ny - 2;
difference = mean(x) - mean(y);
pooledSd = sqrt(((nx - 1) * var(x) + (ny - 1) * var(y)) / df);
standardError = pooledSd * sqrt(1 / nx + 1 / ny);
tstat = difference / standardError;
p = 2 * cobraTcdf(-abs(tstat), df);
halfWidth = cobraTinv(0.975, df) * standardError;
ci = [difference - halfWidth; difference + halfWidth];
if isRowInput
    ci = ci';
end
if isnan(p)
    h = NaN;
else
    h = double(p <= 0.05);
end
stats = struct('tstat', tstat, 'df', df, 'sd', pooledSd);
end
