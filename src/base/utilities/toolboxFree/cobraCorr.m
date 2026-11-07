function [rho, pval] = cobraCorr(X, varargin)
% Linear or rank correlation coefficients and their p-values without the
% Statistics and Machine Learning Toolbox
%
% USAGE:
%
%    rho = cobraCorr(X)
%    rho = cobraCorr(X, Y)
%    [rho, pval] = cobraCorr(X)
%    [rho, pval] = cobraCorr(X, Y)
%    [rho, pval] = cobraCorr(..., 'Type', type)
%
% INPUT:
%    X:          `n` x `k1` real numeric or logical matrix; each column is a
%                variable, each row an observation
%
% OPTIONAL INPUTS:
%    Y:          `n` x `k2` real numeric or logical matrix (default: `X`)
%    'Type':     name-value pair (name case-insensitive, e.g. 'type'), value
%                'Pearson' (default), 'Spearman' or 'Kendall'
%                (case-insensitive)
%    'Rows':     name-value pair, only the default value 'all' is supported
%    'Tail':     name-value pair, only the default value 'both' (alias 'ne')
%                is supported
%
% OUTPUTS:
%    rho:        `k1` x `k2` matrix of correlation coefficients (`k1` x `k1`
%                for `cobraCorr(X)`); single if `X` or `Y` is single
%    pval:       p-values of the two-sided test of zero correlation, same
%                size and class as `rho`
%
% NOTE:
%    Plain-MATLAB replacement for corr (Statistics and Machine Learning
%    Toolbox); supported syntaxes are those listed under USAGE; any other
%    option or option value raises an error naming it; semantics:
%    mathworks-semantics.md §10 (feature
%    20261103-120403-toolbox-free-replacements).
%
%    * Rows 'all': `rho(i,j)` and `pval(i,j)` are NaN when column `i` or `j`
%      contains NaN; a constant column gives NaN; `n < 2` gives NaN.
%    * Pearson: the coefficient of the centred columns, clipped to [-1, 1];
%      `cobraCorr(X)` has exactly 1 on the diagonal (NaN for NaN or constant
%      columns). p-value `2*tcdf(-|t|, n-2)`,
%      `t = rho*sqrt((n-2)/(1-rho^2))` (exact under normality).
%    * Diagonal p-values of `[rho, pval] = cobraCorr(X)` are
%      `sign(diag(rho))` for every type, i.e. 1 (NaN for a NaN or constant
%      column): "Pr{rho(i,i) as or more extreme than 1} == 1".
%    * Spearman: Pearson on average ranks of ties,
%      `rho = (Sxx + Syy - D)/(2*sqrt(Sxx*Syy))` with `D = sum((rx-ry).^2)`
%      and the tie-corrected `Sxx = (n^3-n)/12 - sum(t^3-t)/12`.
%      p-value: `n < 10` exact over all `n!` permutations (of the average
%      ranks when tied); `n >= 10` without ties the AS 89 Edgeworth series
%      (Best & Roberts 1975, Appl. Statist. 24:377-379) with continuity
%      correction, clipped to [0, 1] (it can reach 0 for strong
%      correlations); `n >= 10` with ties the t approximation above.
%      "With ties" is decided over ALL columns: if any column of `X` or `Y`
%      has tied values (NaN ignored), every pair uses the tie rules.
%    * Kendall: tau-b `K/sqrt((n0-T1)*(n0-T2))`, `n0 = n(n-1)/2`,
%      `K = sum_{i<j} sign(dx)*sign(dy)`, `T` the tied pairs. p-value: exact
%      null distribution of `K` without ties for `n < 50`; exact over all
%      `n!` permutations of the average ranks with ties for `n < 10`;
%      otherwise the normal approximation with continuity correction,
%      `Phi(-(|K|-1)/sd)` with the tie-corrected standard deviation
%      `sd = sqrt(n0(2n+5)/9 - (x3+y3)/18 + x2*y2/(18*n0*(n-2)) + x1*y1/n0)`
%      (`x1 = sum t(t-1)/2`, `x2 = sum t(t-1)(t-2)`, `x3 = sum t(t-1)(2t+5)`
%      over the tie groups of each column).
%    * Rank tests: two-sided p = `min(2*min(lower tail, upper tail), 1)`
%      (MathWorks: "doubling the more significant of the two one-tailed
%      p-values").
%      For Kendall, ties are decided per (i,j) column pair.
%    * These rules follow the newest MathWorks corr.m source found (Copyright
%      1984-2010, read for semantics only); whether later releases changed
%      them is UNCONFIRMED. (A 2018 MathWorks Answers staff post states the
%      reverse Spearman rule, ties -> Edgeworth; the 2010 source does not.)
%
% EXAMPLE:
%
%    [rho, pval] = cobraCorr((1:7)', [2 1 4 3 6 5 7]', 'Type', 'Spearman')
%
% .. Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

% ---------------------------------------------------------------- inputs
isSelf = true;
if ~isempty(varargin) && (isnumeric(varargin{1}) || islogical(varargin{1}))
    Y = varargin{1};
    varargin(1) = [];
    isSelf = false;
end
corrType = parseOptions(varargin);

checkMatrix(X, 'X');
if isSelf
    Y = X;
else
    checkMatrix(Y, 'Y');
    if size(X, 1) ~= size(Y, 1)
        error('cobraCorr:sizeMismatch', 'cobraCorr: X and Y must have the same number of rows.');
    end
end
isSingle = isa(X, 'single') || isa(Y, 'single');
X = double(X);
Y = double(Y);
nObs = size(X, 1);
nX = size(X, 2);
nY = size(Y, 2);
isNaNPair = any(isnan(X), 1)' | any(isnan(Y), 1);
wantP = nargout > 1;

rho = NaN(nX, nY);
pval = NaN(nX, nY);
if nObs >= 2
    switch corrType
        case 'pearson'
            [rho, pval] = pearsonCorrelation(X, Y, isSelf, wantP);
        case 'spearman'
            [rho, pval] = spearmanCorrelation(X, Y, isSelf, isNaNPair, wantP);
        case 'kendall'
            [rho, pval] = kendallCorrelation(X, Y, isSelf, isNaNPair, wantP);
    end
    rho(isNaNPair) = NaN;
    pval(isNaNPair | isnan(rho)) = NaN;
    if isSelf && wantP
        % Pr{rho(i,i) as or more extreme than 1} = 1 (NaN stays NaN)
        pval(1:nX + 1:end) = sign(diag(rho));
    end
end

if isSingle
    rho = single(rho);
    pval = single(pval);
end
end

% ======================================================================
function corrType = parseOptions(options)
% Name-value options: 'Type' (Pearson, Spearman, Kendall), 'Rows' 'all',
% 'Tail' 'both'
corrType = 'pearson';
if mod(numel(options), 2) ~= 0
    error('cobraCorr:invalidOptions', 'cobraCorr: options must be name-value pairs.');
end
for k = 1:2:numel(options)
    name = options{k};
    value = options{k + 1};
    if ~(ischar(name) || (isstring(name) && isscalar(name)))
        error('cobraCorr:unsupportedOption', 'cobraCorr: unsupported option of class ''%s'' (supported: ''Type'', ''Rows'', ''Tail'').', class(name));
    end
    valueText = class(value);
    if ischar(value) || (isstring(value) && isscalar(value))
        valueText = char(value);
    end
    switch lower(char(name))
        case 'type'
            if ~ismember(lower(valueText), {'pearson', 'spearman', 'kendall'})
                error('cobraCorr:unsupportedType', 'cobraCorr: unsupported value ''%s'' for option ''Type'' (supported: ''Pearson'', ''Spearman'', ''Kendall'').', valueText);
            end
            corrType = lower(valueText);
        case 'rows'
            if ~strcmpi(valueText, 'all')
                error('cobraCorr:unsupportedRows', 'cobraCorr: unsupported value ''%s'' for option ''Rows'' (only ''all'' is supported).', valueText);
            end
        case 'tail'
            if ~ismember(lower(valueText), {'both', 'ne'})
                error('cobraCorr:unsupportedTail', 'cobraCorr: unsupported value ''%s'' for option ''Tail'' (only ''both'' is supported).', valueText);
            end
        otherwise
            error('cobraCorr:unsupportedOption', 'cobraCorr: unsupported option ''%s'' (supported: ''Type'', ''Rows'', ''Tail'').', char(name));
    end
end
end

function checkMatrix(A, name)
if ~(isnumeric(A) || islogical(A)) || ~isreal(A) || ~ismatrix(A)
    error('cobraCorr:invalidInput', 'cobraCorr: %s must be a real numeric or logical matrix.', name);
end
end

% Note: every clipping uses min/max with 'includenan', because min(NaN, 1)
% is 1 in MATLAB and a NaN coefficient or p-value must stay NaN.

% ======================================================================
function [rho, pval] = pearsonCorrelation(X, Y, isSelf, wantP)
nObs = size(X, 1);
centredX = X - mean(X, 1);
unitX = centredX ./ sqrt(sum(centredX .^ 2, 1));
if isSelf
    rho = unitX' * unitX;
    isFinite = isfinite(diag(rho));
    diagonal = NaN(size(rho, 1), 1);
    diagonal(isFinite) = 1;
    rho(1:size(rho, 1) + 1:end) = diagonal;
else
    centredY = Y - mean(Y, 1);
    unitY = centredY ./ sqrt(sum(centredY .^ 2, 1));
    rho = unitX' * unitY;
end
rho = max(min(rho, 1, 'includenan'), -1, 'includenan');
pval = NaN(size(rho));
if wantP
    pval = studentPValue(rho, nObs);
end
end

function p = studentPValue(rho, nObs)
% two-sided p-value of the t transformation with n - 2 degrees of freedom
t = rho .* sqrt((nObs - 2) ./ (1 - rho .^ 2));
p = min(2 * cobraTcdf(-abs(t), nObs - 2), 1, 'includenan');
end

% ======================================================================
function [rho, pval] = spearmanCorrelation(X, Y, isSelf, isNaNPair, wantP)
nObs = size(X, 1);
tiesX = columnTies(X);
if isSelf
    tiesY = tiesX;
else
    tiesY = columnTies(Y);
end
rankX = tiesX.ranks;
rankY = tiesY.ranks;
% D = sum((rx - ry).^2), exact: average ranks are multiples of 1/2
D = sum(rankX .^ 2, 1)' + sum(rankY .^ 2, 1) - 2 * (rankX' * rankY);
spreadX = (nObs ^ 3 - nObs) / 12 - tiesX.cubic / 12;
spreadY = (nObs ^ 3 - nObs) / 12 - tiesY.cubic / 12;
rho = (spreadX' + spreadY - D) ./ (2 * sqrt(spreadX' * spreadY));
rho(spreadX' == 0 | spreadY == 0) = NaN;
rho = max(min(rho, 1, 'includenan'), -1, 'includenan');
pval = NaN(size(rho));
if ~wantP
    return
end

% Spearman: ties anywhere in X or Y send every pair to the tie rules
hasTies = any(tiesX.hasTies) || any(tiesY.hasTies);
toDo = ~isNaNPair & ~isnan(rho);
if nObs < 10
    % exact permutation distribution of D
    permutations = perms(1:nObs);
    noTieD = [];
    for i = 1:size(rho, 1)
        for j = 1:size(rho, 2)
            if ~toDo(i, j)
                continue
            end
            if hasTies
                permutedY = rankY(:, j);
                permutedD = sum((permutedY(permutations) - rankX(:, i)') .^ 2, 2);
            else
                if isempty(noTieD)
                    noTieD = sum((permutations - (1:nObs)) .^ 2, 2);
                end
                permutedD = noTieD;
            end
            lowerTail = mean(permutedD >= D(i, j));   % rho' <= rho
            upperTail = mean(permutedD <= D(i, j));   % rho' >= rho
            pval(i, j) = min(2 * min(lowerTail, upperTail), 1, 'includenan');
        end
    end
else
    % no ties: AS 89 Edgeworth series for the more significant tail
    isEdgeworth = toDo & ~hasTies;
    maxD = (nObs ^ 3 - nObs) / 3;
    pval(isEdgeworth) = min(2 * edgeworthUpperTail(max(D(isEdgeworth), maxD - D(isEdgeworth)), nObs), 1, 'includenan');
    % ties: t approximation
    isStudent = toDo & hasTies;
    pval(isStudent) = studentPValue(rho(isStudent), nObs);
end
end

function p = edgeworthUpperTail(D, nObs)
% P(D' >= D) for Spearman's D without ties, algorithm AS 89 (Best & Roberts
% 1975), Edgeworth series with continuity correction
c = [0.2274 0.2531 0.1745 0.0758 0.1033 0.3932 0.0879 0.0151 0.0072 0.0831 0.0131 0.00046];
b = 1 / nObs;
x = (6 * (D - 1) * b / (nObs ^ 2 - 1) - 1) * sqrt(1 / b - 1);
y = x .^ 2;
u = x .* b .* (c(1) + b * (c(2) + c(3) * b) + y .* (-c(4) + b * (c(5) + c(6) * b) ...
    - y .* b .* (c(7) + c(8) * b - y .* (c(9) - c(10) * b + y .* b .* (c(11) - c(12) * y)))));
p = u .* exp(-y / 2) + 0.5 * erfc(x / sqrt(2));
p = min(max(p, 0, 'includenan'), 1, 'includenan');
end

% ======================================================================
function [rho, pval] = kendallCorrelation(X, Y, isSelf, isNaNPair, wantP)
nObs = size(X, 1);
nPairs = nObs * (nObs - 1) / 2;
K = zeros(size(X, 2), size(Y, 2));
untiedX = zeros(1, size(X, 2));
untiedY = zeros(1, size(Y, 2));
for i = 1:nObs - 1
    signX = sign(X(i + 1:nObs, :) - X(i, :));
    signY = sign(Y(i + 1:nObs, :) - Y(i, :));
    K = K + signX' * signY;
    untiedX = untiedX + sum(signX .^ 2, 1);
    untiedY = untiedY + sum(signY .^ 2, 1);
end
rho = K ./ sqrt(untiedX' * untiedY);
rho = max(min(rho, 1, 'includenan'), -1, 'includenan');
pval = NaN(size(rho));
if ~wantP
    return
end

tiesX = columnTies(X);
if isSelf
    tiesY = tiesX;
else
    tiesY = columnTies(Y);
end
hasTies = tiesX.hasTies' | tiesY.hasTies;
toDo = ~isNaNPair & ~isnan(rho);

% no ties and n < 50: exact distribution of the number of discordant pairs
isExact = toDo & ~hasTies & nObs < 50;
if any(isExact(:))
    probability = 1;
    for m = 2:nObs
        probability = conv(probability, ones(1, m)) / m;
    end
    % probability(I + 1) = P(I discordant pairs), K = nPairs - 2*I
    atMost = cumsum(probability);
    atLeast = fliplr(cumsum(fliplr(probability)));
    nDiscordant = round((nPairs - K(isExact)) / 2);
    upperTail = atMost(nDiscordant + 1);     % K' >= K
    lowerTail = atLeast(nDiscordant + 1);    % K' <= K
    pval(isExact) = min(2 * min(lowerTail, upperTail), 1, 'includenan');
end

% ties and n < 10: exact over all permutations of the average ranks
isPermutation = toDo & hasTies & nObs < 10;
if any(isPermutation(:))
    permutations = perms(1:nObs);
    [first, second] = find(triu(true(nObs), 1));
    for i = 1:size(rho, 1)
        for j = 1:size(rho, 2)
            if ~isPermutation(i, j)
                continue
            end
            permutedY = tiesY.ranks(:, j);
            permutedY = permutedY(permutations);
            signX = sign(tiesX.ranks(first, i) - tiesX.ranks(second, i));
            permutedK = zeros(size(permutations, 1), 1);
            for pair = 1:numel(first)
                permutedK = permutedK + sign(permutedY(:, first(pair)) - permutedY(:, second(pair))) * signX(pair);
            end
            lowerTail = mean(permutedK <= K(i, j));
            upperTail = mean(permutedK >= K(i, j));
            pval(i, j) = min(2 * min(lowerTail, upperTail), 1, 'includenan');
        end
    end
end

% otherwise: normal approximation with continuity correction
isNormal = toDo & ~isExact & ~isPermutation;
variance = nPairs * (2 * nObs + 5) / 9 - (tiesX.kendall3' + tiesY.kendall3) / 18 ...
    + (tiesX.kendall2' * tiesY.kendall2) / (18 * nPairs * (nObs - 2)) ...
    + (tiesX.kendall1' * tiesY.kendall1) / nPairs;
pval(isNormal) = min(2 * cobraNormcdf(-(abs(K(isNormal)) - 1) ./ sqrt(variance(isNormal))), 1, 'includenan');
end

% ======================================================================
function ties = columnTies(A)
% Average ranks of each column and the tie sums used by the rank tests;
% columns containing NaN get NaN ranks and their tie flag from the non-NaN
% values
[nObs, nColumns] = size(A);
ties.ranks = NaN(nObs, nColumns);
ties.hasTies = false(1, nColumns);
ties.cubic = zeros(1, nColumns);     % sum(t^3 - t)
ties.kendall1 = zeros(1, nColumns);  % sum t(t-1)/2
ties.kendall2 = zeros(1, nColumns);  % sum t(t-1)(t-2)
ties.kendall3 = zeros(1, nColumns);  % sum t(t-1)(2t+5)
for j = 1:nColumns
    column = A(:, j);
    if any(isnan(column))
        finiteValues = column(~isnan(column));
        ties.hasTies(j) = numel(unique(finiteValues)) < numel(finiteValues);
        continue
    end
    [sortedValues, order] = sort(column);
    isNewGroup = [true; sortedValues(2:end) ~= sortedValues(1:end - 1)];
    groupId = cumsum(isNewGroup);
    groupStart = find(isNewGroup);
    groupSize = accumarray(groupId, 1);
    averageRank = groupStart + (groupSize - 1) / 2;
    ties.ranks(order, j) = averageRank(groupId);
    t = groupSize;
    ties.hasTies(j) = any(t > 1);
    ties.cubic(j) = sum(t .^ 3 - t);
    ties.kendall1(j) = sum(t .* (t - 1) / 2);
    ties.kendall2(j) = sum(t .* (t - 1) .* (t - 2));
    ties.kendall3(j) = sum(t .* (t - 1) .* (2 * t + 5));
end
end
