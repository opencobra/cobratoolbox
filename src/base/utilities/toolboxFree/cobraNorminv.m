function [x, varargout] = cobraNorminv(p, varargin)
% Inverse of the normal cumulative distribution function without the
% Statistics and Machine Learning Toolbox
%
% USAGE:
%
%    x = cobraNorminv(p)
%    x = cobraNorminv(p, mu)
%    x = cobraNorminv(p, mu, sigma)
%
% INPUT:
%    p:        real numeric array of probabilities
%
% OPTIONAL INPUTS:
%    mu:       mean, real numeric array or scalar (default: 0)
%    sigma:    standard deviation, real numeric array or scalar (default: 1)
%
% OUTPUT:
%    x:        quantiles, the common size of `p`, `mu` and `sigma` after
%              scalar expansion (single if any input is single, else double)
%
% NOTE:
%    Plain-MATLAB replacement for norminv (Statistics and Machine Learning
%    Toolbox); supported syntaxes are those listed under USAGE with one
%    output; the confidence-bound syntax (pCov, alpha, outputs xLo, xUp) and
%    any other further input or output raise the error
%    `cobraNorminv:unsupportedSyntax`; semantics: mathworks-semantics.md §2
%    (feature 20261103-120403-toolbox-free-replacements).
%    Algorithm: `x = mu + sigma.*(-sqrt(2)*erfcinv(2*p))`. `p = 0` gives
%    `-Inf` and `p = 1` gives `Inf`; `p` outside [0, 1], `sigma <= 0` (the
%    documentation requires a positive sigma; R14 returned NaN for
%    `sigma <= 0`, current behaviour for `sigma = 0` UNCONFIRMED) and NaN
%    inputs give NaN. Non-scalar inputs must have the same size (scalars are
%    expanded); implicit expansion of compatible sizes (for example a row
%    and a column) is not supported and raises an error, as no call site
%    uses it.
%
% EXAMPLE:
%
%    x = cobraNorminv(0.975)       % 1.9600
%
% .. Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

if nargout > 1 || numel(varargin) > 2
    error('cobraNorminv:unsupportedSyntax', ...
        'cobraNorminv: the confidence-bound syntax (pCov, alpha, xLo, xUp) is not supported; use x = cobraNorminv(p, mu, sigma).');
end
varargout = {};
mu = 0;
sigma = 1;
if numel(varargin) >= 1
    mu = varargin{1};
end
if numel(varargin) >= 2
    sigma = varargin{2};
end

[p, mu, sigma, isSingle] = expandInputs('cobraNorminv', p, mu, sigma);

p(p < 0 | p > 1) = NaN;
sigma(sigma <= 0) = NaN;
x = mu + sigma .* (-sqrt(2) * erfcinv(2 * p));

if isSingle
    x = single(x);
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
