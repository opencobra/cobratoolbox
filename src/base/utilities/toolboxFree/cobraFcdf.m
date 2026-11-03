function p = cobraFcdf(x, v1, v2, varargin)
% F cumulative distribution function without the Statistics and Machine
% Learning Toolbox
%
% USAGE:
%
%    p = cobraFcdf(x, v1, v2)
%    p = cobraFcdf(x, v1, v2, 'upper')
%
% INPUTS:
%    x:        real numeric array of values at which the cdf is evaluated
%    v1:       numerator degrees of freedom, real positive numeric array or
%              scalar (non-integer values and `Inf` are allowed)
%    v2:       denominator degrees of freedom, real positive numeric array
%              or scalar (non-integer values and `Inf` are allowed)
%
% OPTIONAL INPUT:
%    'upper':  return the upper tail `P(F > x)`, computed directly so that
%              small upper-tail probabilities keep full relative accuracy
%
% OUTPUT:
%    p:        cdf values, the common size of `x`, `v1` and `v2` after
%              scalar expansion (single if any input is single, else double)
%
% NOTE:
%    Plain-MATLAB replacement for fcdf (Statistics and Machine Learning
%    Toolbox); supported syntaxes are those listed under USAGE; any other
%    option raises an error naming it; semantics: mathworks-semantics.md §5
%    (feature 20261103-120403-toolbox-free-replacements).
%    Algorithm (only the requested tail is computed), with
%    `w = x./(x + v2./v1)` and `1 - w = (v2./v1)./(x + v2./v1)`: lower tail
%    `betainc(w, v1/2, v2/2)` when `w <= 1/2`, otherwise
%    `betainc(1 - w, v2/2, v1/2, 'upper')`; the upper tail uses the
%    complementary pair, so neither tail is formed as `1 - p` (R14 used
%    `betainc(w, v1/2, v2/2)` for the lower tail; the MathWorks 'upper'
%    algorithm is UNCONFIRMED). Infinite degrees of freedom use the limits
%    `v1*F ~ chi2(v1)` (v2 = Inf), `v2/F ~ chi2(v2)` (v1 = Inf) and the
%    step at `x = 1` when both are infinite (lower tail 1 for `x >= 1`), as
%    in R14. `x <= 0` gives 0 (upper: 1), `x = Inf` gives 1 (upper: 0);
%    `v1 <= 0`, `v2 <= 0` and NaN inputs give NaN. Known difference: MATLAB's
%    `betainc` is accurate to a few 1e-13 relative for parameters near 50
%    (2.4e-13 measured at v1 = 0.5, v2 = 100). Non-scalar inputs must have
%    the same size (scalars are expanded); implicit expansion of compatible
%    sizes (for example a row and a column) is not supported and raises an
%    error, as no call site uses it.
%
% EXAMPLE:
%
%    p = cobraFcdf(3, 2.5, 10)           % 0.9121
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
        error('cobraFcdf:unsupportedOption', 'cobraFcdf: unsupported option ''%s'' (only ''upper'' is supported).', optionName);
    end
    isUpper = true;
end

[x, v1, v2, isSingle] = expandInputs('cobraFcdf', x, v1, v2);

% only the requested tail is computed; complementary pairs give the other tail
% without forming 1 - p
if isUpper
    tailName = 'upper';
    otherTailName = 'lower';
else
    tailName = 'lower';
    otherTailName = 'upper';
end

p = NaN(size(x));
isValid = ~isnan(x) & v1 > 0 & v2 > 0;
p(isValid & x <= 0) = double(isUpper);
p(isValid & x == Inf) = double(~isUpper);
isInside = isValid & x > 0 & x < Inf;

% both degrees of freedom finite: incomplete beta function, in the argument
% form (w or 1 - w) that is at most 1/2
isBeta = isInside & isfinite(v1) & isfinite(v2);
ratio = v2(isBeta) ./ v1(isBeta);
w = x(isBeta) ./ (x(isBeta) + ratio);
wComplement = ratio ./ (x(isBeta) + ratio);
a = v1(isBeta) / 2;
b = v2(isBeta) / 2;
isLowW = w <= 0.5;
pBeta = zeros(size(w));
pBeta(isLowW) = betainc(w(isLowW), a(isLowW), b(isLowW), tailName);
pBeta(~isLowW) = betainc(wComplement(~isLowW), b(~isLowW), a(~isLowW), otherTailName);
p(isBeta) = pBeta;

% v2 = Inf: v1*F is chi-square with v1 degrees of freedom
isChiNumerator = isInside & isfinite(v1) & v2 == Inf;
p(isChiNumerator) = gammainc(v1(isChiNumerator) .* x(isChiNumerator) / 2, v1(isChiNumerator) / 2, tailName);

% v1 = Inf: v2/F is chi-square with v2 degrees of freedom
isChiDenominator = isInside & v1 == Inf & isfinite(v2);
p(isChiDenominator) = gammainc(v2(isChiDenominator) ./ x(isChiDenominator) / 2, v2(isChiDenominator) / 2, otherTailName);

% both infinite: F = 1 with probability one (lower tail 1 for x >= 1)
isStep = isInside & v1 == Inf & v2 == Inf;
p(isStep) = double(xor(x(isStep) >= 1, isUpper));

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
