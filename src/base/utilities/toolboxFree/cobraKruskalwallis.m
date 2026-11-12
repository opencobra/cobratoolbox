function [p, tbl, stats] = cobraKruskalwallis(x, group, displayopt)
% Kruskal-Wallis test without the Statistics and Machine Learning Toolbox
%
% USAGE:
%
%    [p, tbl, stats] = cobraKruskalwallis(x, group)
%    [p, tbl, stats] = cobraKruskalwallis(x, group, displayopt)
%
% INPUTS:
%    x:            real numeric vector of observations
%    group:        grouping variable with one entry per observation: numeric,
%                  logical or categorical vector, cell array of character
%                  vectors, string array or char matrix (one row per entry)
%
% OPTIONAL INPUT:
%    displayopt:   'on' or 'off' (default 'on'); accepted for compatibility,
%                  no figure is drawn either way (see NOTE)
%
% OUTPUTS:
%    p:            p-value of the test that all groups come from the same
%                  distribution (chi-square approximation)
%    tbl:          4 x 6 cell array: header
%                  {'Source','SS','df','MS','Chi-sq','Prob>Chi-sq'} and the
%                  rows 'Groups', 'Error' and 'Total' of the one-way ANOVA of
%                  the ranks; the Chi-sq and Prob cells of 'Error' and the MS,
%                  Chi-sq and Prob cells of 'Total' are empty
%    stats:        structure with fields `gnames` (cell column), `n` (row),
%                  `source` ('kruskalwallis'), `meanranks` (row) and `sumt`
%                  (sum of t^3 - t over the groups of t tied values)
%
% EXAMPLE:
%
%    strength = [82 86 79 83 84 85 86 87 74 82 78 75 76 77 79 79 77 78 82 79];
%    alloy = [repmat({'st'}, 1, 8), repmat({'al1'}, 1, 6), repmat({'al2'}, 1, 6)];
%    p = cobraKruskalwallis(strength, alloy, 'off')   % 0.0018
%
% NOTE:
%    Plain-MATLAB replacement for kruskalwallis (Statistics and Machine
%    Learning Toolbox); supported syntaxes are those listed under USAGE
%    (vector `x` with a grouping variable); semantics:
%    specs/20261111-152503-toolbox-free-remaining/mathworks-semantics.md,
%    G1 section 2. As MathWorks documents, the test is a one-way ANOVA of the
%    ranks: NaN values and missing group entries are removed, the remaining
%    values are ranked with `cobraTiedrank` (average ranks for ties), the
%    ranks are analysed with `cobraAnova1`, and the statistic is
%    H = SSg/(SSt/(N - 1)), which includes the tie correction; p is the upper
%    tail of the chi-square distribution with k - 1 degrees of freedom. When
%    all values are tied, SSt is 0 and H and p are NaN; with a single group
%    p is NaN. MathWorks draws a
%    table figure and a box plot when displayopt is 'on'; this replacement
%    draws nothing, which leaves the outputs unchanged (the call sites that
%    use 'on' close or replace those figures at once).
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

if ~exist('group', 'var') || isempty(group)
    error('COBRA:cobraKruskalwallis:unsupportedOption', ...
        'cobraKruskalwallis: a grouping variable is required (matrix input without group is not supported).');
end
if ~exist('displayopt', 'var') || isempty(displayopt)
    displayopt = 'on';
end
if ~(ischar(displayopt) || isstring(displayopt)) || ~any(strcmpi(char(displayopt), {'on', 'off'}))
    if ischar(displayopt) || isstring(displayopt)
        optionName = char(displayopt);
    else
        optionName = class(displayopt);
    end
    error('COBRA:cobraKruskalwallis:unsupportedOption', ...
        'cobraKruskalwallis: unsupported option ''%s'' (displayopt must be ''on'' or ''off'').', optionName);
end
if ~(isnumeric(x) || islogical(x)) || ~isreal(x) || ~isvector(x)
    error('COBRA:cobraKruskalwallis:unsupportedOption', ...
        'cobraKruskalwallis: unsupported option ''matrix x'' (x must be a real numeric vector).');
end

[groupIndex, groupNames] = cobraGrp2idx(group);
x = double(x(:));
if numel(groupIndex) ~= numel(x)
    error('COBRA:cobraKruskalwallis:sizeMismatch', 'cobraKruskalwallis: group must have one entry per observation of x.');
end
isKept = ~isnan(x) & ~isnan(groupIndex);
groupIndex = groupIndex(isKept);
[ranks, tieadj] = cobraTiedrank(x(isKept));

% one-way ANOVA of the ranks; the numeric group indices keep the group order
[~, anovaTable, anovaStats] = cobraAnova1(ranks, groupIndex, 'off');
ssGroups = anovaTable{2, 2};
ssTotal = anovaTable{4, 2};
dfGroups = anovaTable{2, 3};
total = numel(ranks);
H = ssGroups / (ssTotal / (total - 1));
p = cobraChi2cdf(H, dfGroups, 'upper');
if dfGroups < 1
    p = NaN; % one group: no test (R14 arithmetic gives NaN)
end

tbl = anovaTable;
tbl(1, 5:6) = {'Chi-sq', 'Prob>Chi-sq'};
tbl(2, 5:6) = {H, p};
usedGroups = unique(groupIndex);
stats = struct('gnames', {groupNames(usedGroups)}, 'n', anovaStats.n, 'source', 'kruskalwallis', ...
    'meanranks', anovaStats.means, 'sumt', 2 * tieadj);
end
