function [x, varargout] = cobraTinv(p, nu, varargin)
% Inverse of Student's t cumulative distribution function without the
% Statistics and Machine Learning Toolbox
%
% USAGE:
%
%    x = cobraTinv(p, nu)
%
% INPUTS:
%    p:        real numeric array of probabilities
%    nu:       degrees of freedom, real positive numeric array or scalar
%              (non-integer values and `Inf` are allowed)
%
% OUTPUT:
%    x:        quantiles, `cobraTcdf(x, nu) = p`, the common size of `p` and
%              `nu` after scalar expansion (single if any input is single,
%              else double)
%
% NOTE:
%    Plain-MATLAB replacement for tinv (Statistics and Machine Learning
%    Toolbox); supported syntax is the one listed under USAGE; further
%    inputs or outputs raise the error `cobraTinv:unsupportedSyntax`;
%    semantics: mathworks-semantics.md §3 (feature
%    20261103-120403-toolbox-free-replacements).
%    `p = 0` gives `-Inf`, `p = 1` gives `Inf`, `p = 0.5` gives 0; `p`
%    outside [0, 1], `nu <= 0` and NaN inputs give NaN. Non-scalar inputs
%    must have the same size (scalars are expanded); implicit expansion of
%    compatible sizes (for example a row and a column) is not supported and
%    raises an error, as no call site uses it.
%    Algorithm (the R14 MathWorks rule; whether current releases still use
%    it is UNCONFIRMED): by symmetry the lower-tail quantile for
%    `min(p, 1 - p)` is computed and its sign flipped for `p > 1/2`.
%
%    * `nu < 1000`: from `betaincinv` (the inverse regularized incomplete
%      beta function) with `y = nu/(nu + x^2)`: `x^2 = nu*(1 - y)/y` when
%      `y < 1/2`, otherwise from `w = 1 - y = x^2/(nu + x^2)` computed by
%      `betaincinv(..., 'upper')` as `x^2 = nu*w/(1 - w)`. R14 used
%      `x^2 = nu/y - nu` throughout, which loses relative accuracy for small
%      `|x|` (cancellation); the two forms agree elsewhere.
%    * `nu >= 1000` (including `Inf`, where it is exactly the normal
%      quantile `-sqrt(2)*erfcinv(2*p)`): the Cornish-Fisher expansion of
%      Abramowitz and Stegun (1964), eq. 26.7.5, with four correction terms.
%
%    Known differences from the exact values (measured against 50-digit
%    mpmath values): the `betaincinv` branch agrees to about 1e-14 relative
%    in ordinary cases but only to about 4e-9 at p = 1e-300 (nu = 2.5, 10);
%    the expansion is exact to double precision while `x^2 << nu` but loses
%    accuracy in the tails at moderate nu (1e-11 at p = 1e-10 and 3e-11 at
%    p = 1 - 1e-12 for nu = 1000; 3e-4 at p = 1e-300 for nu = 1000, 6e-9 for
%    nu = 9000). Where `y` underflows or `nu*(1 - y)/y` overflows (quantiles
%    beyond about 1e154, for example p = 1e-300 with nu = 1, exact value
%    -3.18e299) the result is `-Inf` (or `Inf`), as the MathWorks formula.
%
% EXAMPLE:
%
%    x = cobraTinv(0.95, 10)       % 1.8125
%
% .. Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

if nargout > 1 || ~isempty(varargin)
    error('cobraTinv:unsupportedSyntax', ...
        'cobraTinv: only x = cobraTinv(p, nu) is supported (no further inputs or outputs).');
end
varargout = {};

[p, nu, isSingle] = expandInputs('cobraTinv', p, nu);

x = NaN(size(p));
isValid = p >= 0 & p <= 1 & nu > 0;
x(isValid & p == 0) = -Inf;
x(isValid & p == 1) = Inf;
x(isValid & p == 0.5) = 0;

% lower-tail quantile of pTail = min(p, 1 - p), sign restored at the end
isInner = isValid & p > 0 & p < 1 & p ~= 0.5;
pTail = min(p, 1 - p);

% nu < 1000: inverse incomplete beta function, in the form whose argument is below 1/2
isBeta = isInner & nu < 1000;
q = 2 * pTail(isBeta);
nuBeta = nu(isBeta);
y = betaincinv(q, nuBeta / 2, 0.5);                 % y = nu/(nu + x^2)
xBeta = -sqrt(nuBeta .* (1 - y) ./ y);
isSmallX = y >= 0.5;                                 % then use w = 1 - y = x^2/(nu + x^2)
w = betaincinv(q(isSmallX), 0.5, nuBeta(isSmallX) / 2, 'upper');
xBeta(isSmallX) = -sqrt(nuBeta(isSmallX) .* w ./ (1 - w));
x(isBeta) = xBeta;

% nu >= 1000: Cornish-Fisher expansion around the normal quantile z
isCornishFisher = isInner & nu >= 1000;
z = -sqrt(2) * erfcinv(2 * pTail(isCornishFisher));
nuCF = nu(isCornishFisher);
g1 = (z .^ 3 + z) / 4;
g2 = (5 * z .^ 5 + 16 * z .^ 3 + 3 * z) / 96;
g3 = (3 * z .^ 7 + 19 * z .^ 5 + 17 * z .^ 3 - 15 * z) / 384;
g4 = (79 * z .^ 9 + 776 * z .^ 7 + 1482 * z .^ 5 - 1920 * z .^ 3 - 945 * z) / 92160;
x(isCornishFisher) = z + g1 ./ nuCF + g2 ./ nuCF .^ 2 + g3 ./ nuCF .^ 3 + g4 ./ nuCF .^ 4;

isUpperHalf = isInner & p > 0.5;
x(isUpperHalf) = -x(isUpperHalf);

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
