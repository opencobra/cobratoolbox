function [p, varargout] = cobraNormcdf(x, varargin)
% Normal cumulative distribution function without the Statistics and Machine
% Learning Toolbox
%
% USAGE:
%
%    p = cobraNormcdf(x)
%    p = cobraNormcdf(x, mu)
%    p = cobraNormcdf(x, mu, sigma)
%    p = cobraNormcdf(x, mu, sigma, pCov)
%    p = cobraNormcdf(x, mu, sigma, pCov, alpha)
%    p = cobraNormcdf(..., 'upper')
%
% INPUT:
%    x:        real numeric array of values at which the cdf is evaluated
%
% OPTIONAL INPUTS:
%    mu:       mean, real numeric array or scalar (default: 0)
%    sigma:    standard deviation, real numeric array or scalar (default: 1)
%    pCov:     covariance of the estimates of `mu` and `sigma`; accepted and
%              ignored, because it only affects the confidence bounds, which
%              are not supported (a single output is returned)
%    alpha:    significance level of the confidence bounds; accepted and
%              ignored for the same reason
%    'upper':  return the upper tail `P(X > x)`, computed directly so that
%              extreme upper-tail probabilities keep full relative accuracy
%
% OUTPUT:
%    p:        cdf values, the common size of `x`, `mu` and `sigma` after
%              scalar expansion (single if any input is single, else double)
%
% NOTE:
%    Plain-MATLAB replacement for normcdf (Statistics and Machine Learning
%    Toolbox); supported syntaxes are those listed under USAGE with one
%    output; requesting the confidence bounds `pLo`, `pUp` or passing any
%    option other than 'upper' raises an error naming it; semantics:
%    mathworks-semantics.md §1 (feature 20261103-120403-toolbox-free-replacements).
%    Algorithm: `p = erfc(-z/sqrt(2))/2` with `z = (x - mu)./sigma` (lower
%    tail) and `erfc(z/sqrt(2))/2` (upper tail), both accurate in their tail.
%    `sigma == 0` gives the step `p = (x >= mu)` (upper tail: `x < mu`), as in
%    the current MathWorks documentation; `sigma < 0` and NaN inputs give NaN.
%    Non-scalar inputs must have the same size (scalars are expanded);
%    implicit expansion of compatible sizes (for example a row and a
%    column) is not supported and raises an error, as no call site uses it.
%
% EXAMPLE:
%
%    p = cobraNormcdf(0, 1, 2)           % P(X <= 0) for X ~ N(1, 2^2)
%    q = cobraNormcdf(10, 'upper')       % 7.6199e-24
%
% .. Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

if nargout > 1
    error('cobraNormcdf:unsupportedOutput', ...
        'cobraNormcdf: the confidence bounds pLo and pUp are not supported (request one output).');
end
varargout = {};

[isUpper, numericArgs] = parseTail('cobraNormcdf', varargin);
if numel(numericArgs) > 4
    error('cobraNormcdf:tooManyInputs', 'cobraNormcdf: too many numeric inputs (at most x, mu, sigma, pCov, alpha).');
end
mu = 0;
sigma = 1;
if numel(numericArgs) >= 1
    mu = numericArgs{1};
end
if numel(numericArgs) >= 2
    sigma = numericArgs{2};
end
% numericArgs{3} (pCov) and numericArgs{4} (alpha) only affect the bounds

[x, mu, sigma, isSingle] = expandInputs('cobraNormcdf', x, mu, sigma);

z = (x - mu) ./ sigma;
if isUpper
    p = 0.5 * erfc(z / sqrt(2));
else
    p = 0.5 * erfc(-z / sqrt(2));
end

% degenerate distribution: a step at mu
isStep = sigma == 0 & ~isnan(x) & ~isnan(mu);
if isUpper
    p(isStep) = double(x(isStep) < mu(isStep));
else
    p(isStep) = double(x(isStep) >= mu(isStep));
end
p(sigma < 0) = NaN;

if isSingle
    p = single(p);
end
end

function [isUpper, numericArgs] = parseTail(functionName, args)
% Removes a trailing 'upper' option; any other text option is an error
isUpper = false;
if ~isempty(args) && (ischar(args{end}) || isstring(args{end}))
    option = char(args{end});
    if ~strcmpi(option, 'upper')
        error([functionName ':unsupportedOption'], '%s: unsupported option ''%s'' (only ''upper'' is supported).', functionName, option);
    end
    isUpper = true;
    args(end) = [];
end
numericArgs = args;
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
