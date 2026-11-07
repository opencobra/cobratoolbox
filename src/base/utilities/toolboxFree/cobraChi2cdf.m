function p = cobraChi2cdf(x, v, varargin)
% Chi-square cumulative distribution function without the Statistics and
% Machine Learning Toolbox
%
% USAGE:
%
%    p = cobraChi2cdf(x, v)
%    p = cobraChi2cdf(x, v, 'upper')
%
% INPUTS:
%    x:        real numeric array of values at which the cdf is evaluated
%    v:        degrees of freedom, real positive numeric array or scalar
%              (non-integer values are allowed)
%
% OPTIONAL INPUT:
%    'upper':  return the upper tail `P(X > x)`, computed directly with
%              `gammainc(..., 'upper')` so that small upper-tail
%              probabilities keep full relative accuracy
%
% OUTPUT:
%    p:        cdf values, the common size of `x` and `v` after scalar
%              expansion (single if any input is single, else double)
%
% NOTE:
%    Plain-MATLAB replacement for chi2cdf (Statistics and Machine Learning
%    Toolbox); supported syntaxes are those listed under USAGE; any other
%    option raises an error naming it; semantics: mathworks-semantics.md §4
%    (feature 20261103-120403-toolbox-free-replacements).
%    Algorithm: `p = gammainc(x/2, v/2)` (lower) or
%    `gammainc(x/2, v/2, 'upper')` (upper), the regularized incomplete gamma
%    function, for `x >= 0`. `x < 0` gives 0 (upper: 1) and `x = Inf` gives
%    1 (upper: 0). `v = 0` (a point mass at 0) follows gammainc: `p = 1`
%    (upper: 0) for every `x >= 0`. This is UNCONFIRMED: it is adopted
%    because current chi2cdf (through gamcdf) is believed to return NaN only
%    for `v < 0`, while R14 returned NaN for `v <= 0`; compareTwoSamplesStat
%    can pass `nBin - 1 = 0`. `v < 0` and NaN inputs give NaN. Non-scalar
%    inputs must have the same size (scalars are expanded); implicit
%    expansion of compatible sizes (for example a row and a column) is not
%    supported and raises an error, as no call site uses it.
%
% EXAMPLE:
%
%    p = cobraChi2cdf(3.84, 1)            % 0.9500
%
% .. Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

isUpper = false;
if ~isempty(varargin)
    option = varargin{1};
    if numel(varargin) > 1 || ~(ischar(option) || isstring(option)) || ~strcmpi(char(option), 'upper')
        if ischar(option) || isstring(option)
            optionName = char(option);
        else
            optionName = class(option);
        end
        error('cobraChi2cdf:unsupportedOption', 'cobraChi2cdf: unsupported option ''%s'' (only ''upper'' is supported).', optionName);
    end
    isUpper = true;
end

[x, v, isSingle] = expandInputs('cobraChi2cdf', x, v);

p = NaN(size(x));
isValid = ~isnan(x) & v >= 0;
isNonNegative = isValid & x >= 0;
if isUpper
    p(isNonNegative) = gammainc(x(isNonNegative) / 2, v(isNonNegative) / 2, 'upper');
    p(isValid & x < 0) = 1;
    p(isValid & x == Inf) = 0;
else
    p(isNonNegative) = gammainc(x(isNonNegative) / 2, v(isNonNegative) / 2);
    p(isValid & x < 0) = 0;
    p(isValid & x == Inf) = 1;
end

if isSingle
    p = single(p);
end
end

function [varargout] = expandInputs(functionName, varargin)
% Checks that inputs are real numeric, that non-scalar inputs agree in size,
% and expands scalars to the common size; computation is in double
commonSize = [];
isSingle = false;
for k = 1:numel(varargin)
    arg = varargin{k};
    if ~(isnumeric(arg) || islogical(arg)) || ~isreal(arg)
        error([functionName ':invalidInput'], '%s: inputs must be real numeric arrays.', functionName);
    end
    isSingle = isSingle || isa(arg, 'single');
    if ~isscalar(arg)
        if isempty(commonSize)
            commonSize = size(arg);
        elseif ~isequal(size(arg), commonSize)
            error([functionName ':sizeMismatch'], '%s: non-scalar inputs must have the same size.', functionName);
        end
    end
end
if isempty(commonSize)
    commonSize = [1 1];
end
varargout = cell(1, numel(varargin) + 1);
for k = 1:numel(varargin)
    arg = double(varargin{k});
    if isscalar(arg)
        arg = repmat(arg, commonSize);
    end
    varargout{k} = arg;
end
varargout{end} = isSingle;
end
