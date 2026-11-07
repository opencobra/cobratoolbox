function p = cobraTcdf(x, nu, varargin)
% Student's t cumulative distribution function without the Statistics and
% Machine Learning Toolbox
%
% USAGE:
%
%    p = cobraTcdf(x, nu)
%    p = cobraTcdf(x, nu, 'upper')
%
% INPUTS:
%    x:        real numeric array of values at which the cdf is evaluated
%    nu:       degrees of freedom, real positive numeric array or scalar
%              (non-integer values and `Inf` are allowed)
%
% OPTIONAL INPUT:
%    'upper':  return the upper tail `P(T > x)`, computed directly so that
%              extreme upper-tail probabilities keep full relative accuracy
%
% OUTPUT:
%    p:        cdf values, the common size of `x` and `nu` after scalar
%              expansion (single if any input is single, else double)
%
% NOTE:
%    Plain-MATLAB replacement for tcdf (Statistics and Machine Learning
%    Toolbox); supported syntaxes are those listed under USAGE; any other
%    option raises an error naming it; semantics: mathworks-semantics.md §3
%    (feature 20261103-120403-toolbox-free-replacements).
%    Algorithm (the R14 MathWorks rule; whether current releases still use
%    it is UNCONFIRMED): the smaller tail `P(T < -|x|)` is computed directly
%    and the other tail as its complement.
%
%    * `nu <= 1e7`: `betainc(nu./(nu + x.^2), nu/2, 1/2)/2` when
%      `x.^2 >= nu`, and `betainc(x.^2./(nu + x.^2), 1/2, nu/2, 'upper')/2`
%      when `x.^2 < nu` (the form whose argument is below 1/2, which avoids
%      cancellation in `1 - argument`).
%    * `nu > 1e7` (including `Inf`): the standard normal cdf
%      `erfc(|x|/sqrt(2))/2`.
%
%    Known differences from the exact values (measured against 60-digit
%    mpmath values): they come from MATLAB's `betainc`, whose relative error
%    grows with `nu`: below 1e-13 for nu <= 100, up to about 1e-12 at
%    nu = 1e3, 1e-11 at nu = 1e4 (3.4e-11 measured at x = 1.147,
%    nu = 9997.4), 1e-10 at nu = 1e5, 2e-9 at nu = 1e6 and 2e-8 at nu = 1e7. Above 1e7 the normal
%    cdf differs from the t cdf by about `(x^3 + x)/(4*nu)` relative to the
%    tail (1e-4 at x = -8 just above 1e7). Where `x.^2` overflows
%    (`|x| > 1e154`) the tail is 0 even if the exact value (`nu < 2`) is
%    representable. `nu <= 0` and NaN inputs give NaN.
%    Non-scalar inputs must have the same size (scalars are expanded);
%    implicit expansion of compatible sizes (for example a row and a
%    column) is not supported and raises an error, as no call site uses it.
%
% EXAMPLE:
%
%    p = cobraTcdf(1.8125, 10)            % 0.9500
%    q = cobraTcdf(40, 10, 'upper')       % 1.1404e-12
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
        error('cobraTcdf:unsupportedOption', 'cobraTcdf: unsupported option ''%s'' (only ''upper'' is supported).', optionName);
    end
    isUpper = true;
end

[x, nu, isSingle] = expandInputs('cobraTcdf', x, nu);

if isUpper
    % P(T > x) = P(T < -x) by symmetry
    x = -x;
end

% smaller tail P(T < -|x|)
tail = NaN(size(x));
isValid = ~isnan(x) & nu > 0;

isBeta = isValid & nu <= 1e7;
xsq = x .^ 2;
isFar = isBeta & xsq >= nu;
tail(isFar) = 0.5 * betainc(nu(isFar) ./ (nu(isFar) + xsq(isFar)), nu(isFar) / 2, 0.5);
isNear = isBeta & xsq < nu;
tail(isNear) = 0.5 * betainc(xsq(isNear) ./ (nu(isNear) + xsq(isNear)), 0.5, nu(isNear) / 2, 'upper');

isNormal = isValid & nu > 1e7;
tail(isNormal) = 0.5 * erfc(abs(x(isNormal)) / sqrt(2));

p = tail;
isPositive = x > 0;
p(isPositive) = 1 - tail(isPositive);

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
