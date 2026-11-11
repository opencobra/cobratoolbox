function h = cobraBoxplot(x, group, varargin)
% Box plot (traditional style), without the Statistics and Machine Learning
% Toolbox
%
% USAGE:
%
%    h = cobraBoxplot(x)
%    h = cobraBoxplot(x, group)
%
% INPUTS:
%    x:        numeric vector (one box, or one box per group) or matrix (one box per
%              column); NaN values are ignored
%
% OPTIONAL INPUT:
%    group:    grouping variable with one entry per element of the vector x (numeric,
%              logical, categorical, cell array of character vectors or string array)
%
% OUTPUT:
%    h:        7 x k array of line handles, one column per box, rows tagged 'Upper Whisker',
%              'Lower Whisker', 'Upper Adjacent Value', 'Lower Adjacent Value', 'Box',
%              'Median' and 'Outliers' (as boxplot returns them)
%
% EXAMPLE:
%
%    figure; h = cobraBoxplot([1 2 3 4 10 2 3 4 5 6], {'a','a','a','a','a','b','b','b','b','b'});
%    boxes = findobj(gca, 'Tag', 'Box');   % newest first: the box of group 'b' first
%
% NOTE:
%    Plain-MATLAB replacement for boxplot(x) and boxplot(x, group) (Statistics and Machine
%    Learning Toolbox) with the default options, as used by makeViolinPlots; other options
%    raise an error naming them; semantics: specs/20261111-152503-toolbox-free-remaining/
%    mathworks-semantics.md, G4 section A1. Groups in the order of cobraGrp2idx (first
%    appearance for text, sorted for numbers, category order for categorical) at positions
%    1..k, tick labels the group names ('1'..'k' for the columns of a matrix). Box: 25th to
%    75th percentile by base-MATLAB prctile (the boxplot quartile rule is UNCONFIRMED and
%    settled by the parity section of the test), width 0.5; median line; whiskers to the most
%    extreme values within 1.5 interquartile ranges of the box (dashed), adjacent-value
%    marks; outliers beyond as red '+' (a line with NaN data when there is none). The boxes are drawn in group order, so findobj
%    returns the last group's box first, as with boxplot. Draws into the current axes (held
%    while drawing).
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

if ~isempty(varargin)
    if ischar(varargin{1}) || isstring(varargin{1})
        optionName = char(varargin{1});
    else
        optionName = class(varargin{1});
    end
    error('COBRA:cobraBoxplot:unsupportedOption', 'cobraBoxplot: unsupported option ''%s'' (only cobraBoxplot(x) and cobraBoxplot(x, group)).', optionName);
end
if ~(isnumeric(x) || islogical(x)) || ~ismatrix(x)
    error('COBRA:cobraBoxplot:invalidInput', 'cobraBoxplot: x must be a numeric vector or matrix.');
end
x = double(x);
if exist('group', 'var') && ~isempty(group)
    if ~isvector(x) || numel(group) ~= numel(x)
        error('COBRA:cobraBoxplot:invalidInput', 'cobraBoxplot: group must have one entry per element of the vector x.');
    end
    [groupIndex, groupNames] = cobraGrp2idx(group);
    x = x(:);
    samples = arrayfun(@(k) x(groupIndex == k), 1:numel(groupNames), 'UniformOutput', false);
else
    if isvector(x)
        x = x(:);
    end
    samples = arrayfun(@(k) x(:, k), 1:size(x, 2), 'UniformOutput', false);
    groupNames = arrayfun(@(k) sprintf('%d', k), 1:size(x, 2), 'UniformOutput', false);
end

ax = gca;
wasHeld = ishold(ax);
hold(ax, 'on');
nBoxes = numel(samples);
h = gobjects(7, nBoxes);
halfWidth = 0.25;
for k = 1:nBoxes
    values = samples{k};
    values = values(~isnan(values));
    if isempty(values)
        values = NaN;
    end
    quartiles = prctile(values, [25 50 75]);
    q1 = quartiles(1);
    q3 = quartiles(3);
    reach = 1.5 * (q3 - q1);
    inside = values(values >= q1 - reach & values <= q3 + reach);
    if isempty(inside)
        inside = quartiles(2);
    end
    upperAdjacent = max(inside);
    lowerAdjacent = min(inside);
    outliers = values(values > q3 + reach | values < q1 - reach);
    if isempty(outliers)
        outliers = NaN; % an outlier line with NaN data, as boxplot draws it
    end
    h(1, k) = line(ax, [k k], [q3 upperAdjacent], 'LineStyle', '--', 'Color', 'k', 'Tag', 'Upper Whisker');
    h(2, k) = line(ax, [k k], [lowerAdjacent q1], 'LineStyle', '--', 'Color', 'k', 'Tag', 'Lower Whisker');
    h(3, k) = line(ax, k + [-1 1] * halfWidth / 2, [upperAdjacent upperAdjacent], 'Color', 'k', 'Tag', 'Upper Adjacent Value');
    h(4, k) = line(ax, k + [-1 1] * halfWidth / 2, [lowerAdjacent lowerAdjacent], 'Color', 'k', 'Tag', 'Lower Adjacent Value');
    h(5, k) = line(ax, k + [-1 -1 1 1 -1] * halfWidth, [q1 q3 q3 q1 q1], 'Color', 'b', 'Tag', 'Box');
    h(6, k) = line(ax, k + [-1 1] * halfWidth, [quartiles(2) quartiles(2)], 'Color', 'r', 'Tag', 'Median');
    h(7, k) = line(ax, k * ones(size(outliers)), outliers, 'LineStyle', 'none', 'Marker', '+', ...
        'MarkerEdgeColor', 'r', 'Tag', 'Outliers');
end
set(ax, 'XTick', 1:nBoxes, 'XTickLabel', groupNames, 'XLim', [0.5, nBoxes + 0.5]);
if ~wasHeld
    hold(ax, 'off');
end
end
