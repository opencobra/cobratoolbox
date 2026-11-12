function p = cobraHygecdf(x, M, K, N, varargin)
% Hypergeometric cumulative distribution function without the Statistics and
% Machine Learning Toolbox
%
% USAGE:
%
%    p = cobraHygecdf(x, M, K, N)
%    p = cobraHygecdf(x, M, K, N, 'upper')
%
% INPUTS:
%    x:        values at which the cdf is evaluated (non-integer values are
%              rounded down)
%    M:        population size (non-negative integer)
%    K:        number of items with the desired characteristic in the
%              population (integer, 0 <= K <= M)
%    N:        number of draws without replacement (integer, 0 <= N <= M)
%
% OPTIONAL INPUT:
%    'upper':  return P(X > x), summed directly over the upper tail so that
%              small upper-tail probabilities keep their relative accuracy
%
% OUTPUT:
%    p:        cdf values, the common size of the inputs after scalar
%              expansion
%
% EXAMPLE:
%
%    p = cobraHygecdf(0:2, 100, 20, 10)   % 0.0951 0.3630 0.6812
%
% NOTE:
%    Plain-MATLAB replacement for hygecdf (Statistics and Machine Learning
%    Toolbox); supported syntaxes are those listed under USAGE; any other
%    option raises an error naming it; semantics:
%    specs/20261111-152503-toolbox-free-remaining/mathworks-semantics.md,
%    G1 section 6. P(X <= x) = sum_{i <= floor(x)} C(K,i)*C(M-K,N-i)/C(M,N),
%    each term evaluated as exp of a sum of gammaln terms; only the requested
%    tail is summed. Invalid parameters (negative, non-integer, K > M,
%    N > M) and NaN give NaN. Values outside the support
%    max(0, N - (M - K)) <= X <= min(K, N), including x < 0, follow the
%    mathematical definition (cdf 0 below, 1 above; the upper tail is the
%    complement); R14 returned NaN for x < 0 or x > min(K, N), the current
%    MathWorks behaviour there is UNCONFIRMED (no call site reads such a
%    value: FEA discards its x = -1 entries).
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

isUpper = false;
if ~isempty(varargin)
    option = varargin{1};
    if numel(varargin) > 1 || ~(ischar(option) || isstring(option)) || ~strcmpi(char(option), 'upper')
        if ischar(option) || isstring(option)
            optionName = char(option);
        else
            optionName = class(option);
        end
        error('COBRA:cobraHygecdf:unsupportedOption', ...
            'cobraHygecdf: unsupported option ''%s'' (only ''upper'' is supported).', optionName);
    end
    isUpper = true;
end

inputs = {x, M, K, N};
commonSize = [1 1];
for k = 1:4
    if ~(isnumeric(inputs{k}) || islogical(inputs{k})) || ~isreal(inputs{k})
        error('COBRA:cobraHygecdf:invalidInput', 'cobraHygecdf: inputs must be real numeric arrays.');
    end
    if ~isscalar(inputs{k})
        if ~isequal(commonSize, [1 1]) && ~isequal(size(inputs{k}), commonSize)
            error('COBRA:cobraHygecdf:sizeMismatch', 'cobraHygecdf: non-scalar inputs must have the same size.');
        end
        commonSize = size(inputs{k});
    end
end
for k = 1:4
    if isscalar(inputs{k})
        inputs{k} = repmat(double(inputs{k}), commonSize);
    else
        inputs{k} = double(inputs{k});
    end
end
[x, M, K, N] = inputs{:};

logChoose = @(a, b) gammaln(a + 1) - gammaln(b + 1) - gammaln(a - b + 1);
p = NaN(commonSize);
isValid = ~isnan(x) & M >= 0 & K >= 0 & N >= 0 & M == round(M) & K == round(K) & N == round(N) & K <= M & N <= M;
for k = find(isValid(:))'
    lowest = max(0, N(k) - (M(k) - K(k)));
    highest = min(K(k), N(k));
    xFloor = floor(x(k));
    if xFloor < lowest
        lowerTail = 0;
    elseif xFloor >= highest
        lowerTail = 1;
    else
        lowerTail = [];
    end
    if ~isempty(lowerTail)
        if isUpper
            p(k) = 1 - lowerTail;
        else
            p(k) = lowerTail;
        end
        continue
    end
    if isUpper
        terms = (xFloor + 1):highest;
    else
        terms = lowest:xFloor;
    end
    logTerms = logChoose(K(k), terms) + logChoose(M(k) - K(k), N(k) - terms) - logChoose(M(k), N(k));
    p(k) = min(sum(exp(logTerms)), 1);
end
end
