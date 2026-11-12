function [p, h, stats] = cobraRanksum(x, y, varargin)
% Wilcoxon rank sum test without the Statistics and Machine Learning Toolbox
%
% USAGE:
%
%    [p, h, stats] = cobraRanksum(x, y)
%    [p, h, stats] = cobraRanksum(x, y, 'method', method, 'alpha', alpha)
%
% INPUTS:
%    x, y:     real numeric vectors (row or column, lengths may differ); NaN
%              values are removed
%
% OPTIONAL INPUTS (name-value pairs, names case-insensitive):
%    'method': 'exact' or 'approximate'; default 'exact' when
%              min(nx, ny) < 10 and nx + ny < 20, otherwise 'approximate'
%    'alpha':  significance level for `h` (default 0.05)
%
% OUTPUTS:
%    p:        two-sided p-value
%    h:        logical, true when p <= alpha
%    stats:    structure; exact method: field `ranksum` (W, the rank sum of
%              the smaller sample, `x` when the sizes are equal); approximate
%              method: fields `zval` (of that sample) and `ranksum`
%
% EXAMPLE:
%
%    x = [33.3 33.4 32.9 32.6 32.5 33.0];
%    y = [34.5 34.8 33.8 33.4 33.7 33.9];
%    [p, h, stats] = cobraRanksum(x, y)   % p = 0.0043, h = 1, ranksum = 21.5
%
% NOTE:
%    Plain-MATLAB replacement for ranksum (Statistics and Machine Learning
%    Toolbox); supported syntaxes are those listed under USAGE; the 'tail'
%    option and any other argument raise an error naming it; semantics:
%    specs/20261111-152503-toolbox-free-remaining/mathworks-semantics.md,
%    G1 section 3. The pooled sample is ranked with `cobraTiedrank`
%    (average ranks for ties) and W is the rank sum of the smaller sample
%    (x when nx <= ny), as MathWorks' R14 source computes it (the current
%    documentation calls it the rank sum of the first sample; for nx > ny
%    the current behaviour is UNCONFIRMED and settled by the parity section
%    of the test; two-sided p-values do not depend on it). Exact method: the
%    null distribution of W over all choices of ns = min(nx, ny) of the pooled
%    mid-ranks (ties included) is
%    counted on doubled ranks, which are integers, and
%    p = min(2*min(P(W <= w), P(W >= w)), 1); it needs memory proportional
%    to ns*ns*N, and larger exact problems raise an error. Approximate method:
%    z = (W - ns*(N + 1)/2 - 0.5*sign(W - ns*(N + 1)/2))/sigma with
%    sigma^2 = nx*ny*((N + 1) - 2*tieadj/(N*(N - 1)))/12 and
%    p = 2*Phi(-|z|); when all values are tied sigma is 0 and z and p are
%    NaN, as in MathWorks. The fields of `stats` follow the R14 and
%    documented display (`ranksum` only for the exact method).
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

method = '';
alpha = 0.05;
if mod(numel(varargin), 2) ~= 0
    error('COBRA:cobraRanksum:unsupportedOption', ...
        'cobraRanksum: unsupported option ''%s'' (options are name-value pairs ''method'' and ''alpha'').', ...
        describeValue(varargin{end}));
end
for k = 1:2:numel(varargin)
    name = varargin{k};
    value = varargin{k + 1};
    switch lower(describeValue(name))
        case 'method'
            if ~(ischar(value) || isstring(value)) || ~any(strcmpi(char(value), {'exact', 'approximate'}))
                error('COBRA:cobraRanksum:unsupportedOption', ...
                    'cobraRanksum: unsupported option ''method'' value ''%s'' (use ''exact'' or ''approximate'').', describeValue(value));
            end
            method = lower(char(value));
        case 'alpha'
            alpha = value;
        otherwise
            error('COBRA:cobraRanksum:unsupportedOption', ...
                'cobraRanksum: unsupported option ''%s'' (options are name-value pairs ''method'' and ''alpha'').', describeValue(name));
    end
end
if ~(isnumeric(x) || islogical(x)) || ~(isnumeric(y) || islogical(y)) || ~isvector(x) || ~isvector(y)
    error('COBRA:cobraRanksum:invalidInput', 'cobraRanksum: x and y must be numeric vectors.');
end

x = double(x(:));
y = double(y(:));
x = x(~isnan(x));
y = y(~isnan(y));
nx = numel(x);
ny = numel(y);
total = nx + ny;
if isempty(method)
    if min(nx, ny) < 10 && total < 20
        method = 'exact';
    else
        method = 'approximate';
    end
end

[ranks, tieadj] = cobraTiedrank([x; y]);
% rank sum of the smaller sample (x when the sizes are equal)
if nx <= ny
    sampleRanks = ranks(1:nx);
else
    sampleRanks = ranks(nx + 1:end);
end
ns = numel(sampleRanks);
W = sum(sampleRanks);

if strcmp(method, 'exact')
    % counts of the sums of nx doubled mid-ranks (integers) over all subsets
    doubledRanks = round(2 * ranks);
    maxSum = sum(maxk(doubledRanks, ns));
    if (ns + 1) * (maxSum + 1) > 5e7
        error('COBRA:cobraRanksum:tooLarge', 'cobraRanksum: the exact method is too large for these samples; use ''method'', ''approximate''.');
    end
    counts = zeros(ns + 1, maxSum + 1);
    counts(1, 1) = 1;
    for item = 1:total
        shift = doubledRanks(item);
        for chosen = min(item, ns):-1:1
            counts(chosen + 1, shift + 1:end) = counts(chosen + 1, shift + 1:end) + counts(chosen, 1:end - shift);
        end
    end
    distribution = counts(ns + 1, :);
    sums = 0:maxSum;
    observed = round(2 * W);
    pLower = sum(distribution(sums <= observed)) / sum(distribution);
    pUpper = sum(distribution(sums >= observed)) / sum(distribution);
    p = min(2 * min(pLower, pUpper), 1);
    stats = struct('ranksum', W);
else
    expectedW = ns * (total + 1) / 2;
    tieCorrection = 2 * tieadj / (total * (total - 1));
    sigma = sqrt(nx * ny * ((total + 1) - tieCorrection) / 12);
    z = (W - expectedW - 0.5 * sign(W - expectedW)) / sigma;
    p = 2 * cobraNormcdf(-abs(z));
    stats = struct('zval', z, 'ranksum', W);
end
h = p <= alpha;
end

function text = describeValue(value)
% Text naming an option or value in an error message
if ischar(value) || isstring(value)
    text = char(value);
else
    text = class(value);
end
end
