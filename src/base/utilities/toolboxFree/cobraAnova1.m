function [p, tbl, stats] = cobraAnova1(y, group, displayopt)
% One-way analysis of variance without the Statistics and Machine Learning
% Toolbox
%
% USAGE:
%
%    [p, tbl, stats] = cobraAnova1(y, group)
%    [p, tbl, stats] = cobraAnova1(y, group, displayopt)
%
% INPUTS:
%    y:            real numeric vector of observations
%    group:        grouping variable with one entry per observation: numeric,
%                  logical or categorical vector, cell array of character
%                  vectors, string array or char matrix (one row per entry)
%
% OPTIONAL INPUT:
%    displayopt:   'on' or 'off' (default 'on'); accepted for compatibility,
%                  no figure is drawn either way (see NOTE)
%
% OUTPUTS:
%    p:            p-value of the F test that all group means are equal
%    tbl:          4 x 6 cell array, the ANOVA table: header
%                  {'Source','SS','df','MS','F','Prob>F'} and the rows
%                  'Groups', 'Error' and 'Total'; the F and Prob>F cells of
%                  'Error' and the MS, F and Prob>F cells of 'Total' are empty
%    stats:        structure with fields `gnames` (group names, cell column),
%                  `n` (group sizes, row), `source` ('anova1'), `means` (group
%                  means, row), `df` (error degrees of freedom) and `s`
%                  (pooled standard deviation, sqrt of the error mean square)
%
% EXAMPLE:
%
%    strength = [82 86 79 83 84 85 86 87 74 82 78 75 76 77 79 79 77 78 82 79];
%    alloy = [repmat({'st'}, 1, 8), repmat({'al1'}, 1, 6), repmat({'al2'}, 1, 6)];
%    p = cobraAnova1(strength, alloy, 'off')   % 1.5264e-04
%
% NOTE:
%    Plain-MATLAB replacement for anova1 (Statistics and Machine Learning
%    Toolbox); supported syntaxes are those listed under USAGE (vector `y`
%    with a grouping variable); a matrix `y` or a missing `group` raises an
%    error; semantics: specs/20261111-152503-toolbox-free-remaining/
%    mathworks-semantics.md, G1 section 1. NaN values of `y` and missing
%    group entries (NaN, '', "", <missing>, <undefined>) are removed with
%    their observation. Groups are ordered as `cobraGrp2idx` orders them
%    (first appearance for text, sorted for numeric, category order for
%    categorical); groups without observations (for example unused
%    categories) are dropped. SSg = sum(n_i*(mean_i - mean)^2),
%    SSt = sum((y - mean)^2), SSe = SSt - SSg, F = MSg/MSe and
%    p = P(F(k-1, N-k) > F). When SSe is 0, F is 0 and p is 1 if SSg is also
%    0, otherwise F is Inf and p is 0; with N = k the error mean square is
%    NaN, so F and p are NaN. MathWorks draws a table figure and a box plot
%    when displayopt is 'on'; this replacement draws nothing, which leaves
%    the outputs unchanged (the call sites that use 'on' close or replace
%    those figures at once).
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

if ~exist('group', 'var') || isempty(group)
    error('COBRA:cobraAnova1:unsupportedOption', ...
        'cobraAnova1: a grouping variable is required (matrix input without group is not supported).');
end
if ~exist('displayopt', 'var') || isempty(displayopt)
    displayopt = 'on';
end
if ~(ischar(displayopt) || isstring(displayopt)) || ~any(strcmpi(char(displayopt), {'on', 'off'}))
    error('COBRA:cobraAnova1:unsupportedOption', ...
        'cobraAnova1: unsupported option ''%s'' (displayopt must be ''on'' or ''off'').', describeValue(displayopt));
end
if ~(isnumeric(y) || islogical(y)) || ~isreal(y) || ~isvector(y)
    error('COBRA:cobraAnova1:unsupportedOption', ...
        'cobraAnova1: unsupported option ''matrix y'' (y must be a real numeric vector).');
end

[groupIndex, groupNames] = cobraGrp2idx(group);
y = double(y(:));
if numel(groupIndex) ~= numel(y)
    error('COBRA:cobraAnova1:sizeMismatch', 'cobraAnova1: group must have one entry per observation of y.');
end
isKept = ~isnan(y) & ~isnan(groupIndex);
y = y(isKept);
groupIndex = groupIndex(isKept);

% drop groups without observations and renumber 1..k in the original order
[usedGroups, ~, groupIndex] = unique(groupIndex);
groupNames = groupNames(usedGroups);
k = numel(usedGroups);
total = numel(y);

groupSize = accumarray(groupIndex, 1)';
groupMean = accumarray(groupIndex, y)' ./ groupSize;
grandMean = mean(y);
ssGroups = sum(groupSize .* (groupMean - grandMean) .^ 2);
ssTotal = sum((y - grandMean) .^ 2);
ssError = ssTotal - ssGroups;
dfGroups = k - 1;
dfError = total - k;
dfTotal = total - 1;
msGroups = ssGroups / dfGroups;
msError = ssError / dfError;
if dfError > 0 && ssError == 0
    if ssGroups == 0
        F = 0;
        p = 1;
    else
        F = Inf;
        p = 0;
    end
elseif dfError > 0
    F = msGroups / msError;
    p = cobraFcdf(F, dfGroups, dfError, 'upper');
else
    msError = NaN;
    F = NaN;
    p = NaN;
end

tbl = {'Source', 'SS', 'df', 'MS', 'F', 'Prob>F'; ...
    'Groups', ssGroups, dfGroups, msGroups, F, p; ...
    'Error', ssError, dfError, msError, [], []; ...
    'Total', ssTotal, dfTotal, [], [], []};
stats = struct('gnames', {groupNames(:)}, 'n', groupSize, 'source', 'anova1', ...
    'means', groupMean, 'df', dfError, 's', sqrt(msError));
end

function text = describeValue(value)
% Text naming an option value in an error message
if ischar(value) || isstring(value)
    text = char(value);
else
    text = class(value);
end
end
