function [tbl, chi2, p, labels] = cobraCrosstab(varargin)
% Cross-tabulation of grouping variables with Pearson's chi-square test of
% independence, without the Statistics and Machine Learning Toolbox.
%
% USAGE:
%
%    [tbl, chi2, p, labels] = cobraCrosstab(x1, x2, ...)
%
% INPUTS:
%    x1, x2, ...:   one or more grouping variables of equal length (any type
%                   accepted by cobraGrp2idx)
%
% OUTPUTS:
%    tbl:       counts; `tbl(i, j, ...)` is the number of observations with
%               level i of x1, level j of x2, ... (levels in cobraGrp2idx order).
%               One variable gives a column vector.
%    chi2:      Pearson chi-square statistic of independence, without continuity
%               correction; NaN when fewer than two variables have more than one
%               level
%    p:         asymptotic upper-tail p-value of `chi2` on
%               prod(size(tbl)) - 1 - sum(size(tbl) - 1) degrees of freedom
%               ((r-1)(c-1) for two variables)
%    labels:    cell array; column j holds the level names of variable j, padded
%               with [] up to the longest column
%
% EXAMPLE:
%
%    tbl = cobraCrosstab([1 1 2 3 1], [1 2 5 3 1])   % [2 1 0 0; 0 0 0 1; 0 0 1 0]
%
% NOTE:
%    Plain-MATLAB replacement for crosstab (Statistics and Machine Learning
%    Toolbox); supported syntaxes: [tbl, chi2, p, labels] = cobraCrosstab(x1, x2, ...)
%    with grouping vectors; table input and name-value options
%    (IncludeMissingGroups) raise an error; semantics: mathworks-semantics.md
%    section 8. Observations with a missing value in any variable are left out.
%    The expected counts are n times the product of the marginal proportions.
%    The p-value is gammainc(chi2/2, df/2, 'upper'). Every level keeps its row
%    or column, so a level that occurs only in left-out observations, or an
%    unused category of a categorical variable, gives a zero row or column; its
%    expected counts are 0 and chi2 and p are then NaN (0/0).
%
% .. Author: generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

if isempty(varargin)
    error('cobraCrosstab:noInput', 'cobraCrosstab: at least one grouping variable is required.');
end

nVariables = numel(varargin);
groupNames = cell(1, nVariables);
nLevels = zeros(1, nVariables);
for j = 1:nVariables
    variable = varargin{j};
    if istable(variable)
        error('cobraCrosstab:unsupportedInput', 'cobraCrosstab: table input is not supported.');
    end
    if (ischar(variable) && isrow(variable)) || (isstring(variable) && isscalar(variable))
        if strcmpi(variable, 'IncludeMissingGroups')
            error('cobraCrosstab:unsupportedOption', ...
                'cobraCrosstab: the option ''IncludeMissingGroups'' is not supported.');
        end
    end
    [g, groupNames{j}] = cobraGrp2idx(variable);
    if j == 1
        groupIndex = zeros(numel(g), nVariables);
    elseif numel(g) ~= size(groupIndex, 1)
        error('cobraCrosstab:lengthMismatch', ...
            'cobraCrosstab: all grouping variables must have the same length.');
    end
    groupIndex(:, j) = g;
    nLevels(j) = numel(groupNames{j});
end

% observations with a missing value in any variable are left out
groupIndex = groupIndex(all(~isnan(groupIndex), 2), :);
tbl = accumarray(groupIndex, 1, [nLevels, ones(1, 2 - nVariables)]);

labels = cell(max(nLevels), nVariables);
for j = 1:nVariables
    labels(1:nLevels(j), j) = groupNames{j};
end

if sum(nLevels > 1) < 2
    % fewer than two variables with more than one level: no test of independence
    chi2 = NaN;
    p = NaN;
else
    nObservations = sum(tbl(:));
    expected = nObservations;
    for j = 1:nVariables
        marginal = tbl;
        for k = setdiff(1:nVariables, j)
            marginal = sum(marginal, k);
        end
        expected = expected .* (marginal / nObservations);
    end
    chi2 = sum((tbl - expected) .^ 2 ./ expected, 'all');
    df = prod(nLevels) - 1 - sum(nLevels - 1);
    p = gammainc(chi2 / 2, df / 2, 'upper');
end
end
