function [ax, rowOrder, columnOrder] = cobraClustergram(data, varargin)
% Clustered heat map (hierarchical clustering of rows and columns with
% dendrograms), without the Bioinformatics and Statistics Toolboxes
%
% USAGE:
%
%    [ax, rowOrder, columnOrder] = cobraClustergram(data)
%    [ax, rowOrder, columnOrder] = cobraClustergram(data, 'RowLabels', rowLabels, ...
%        'ColumnLabels', columnLabels, 'ColumnLabelsRotate', angle, 'Cluster', 'all', ...
%        'ShowDendrogram', show, 'Symmetric', symmetric, 'Colormap', colormapSpec, ...
%        'DisplayRange', range, 'Standardize', 'none')
%
% INPUT:
%    data:         m x n numeric matrix without NaN
%
% OPTIONAL INPUTS (name-value pairs, names case-insensitive; logical values may be given as
% 'true'/'false', 'on'/'off'):
%    'RowLabels', 'ColumnLabels':  cell or string arrays of labels
%    'ColumnLabelsRotate':         rotation of the column labels in degrees (default 90)
%    'Cluster':                    'all' (default), 'column' (cluster along the columns, which
%                                  orders the rows, as clustergram documents it) or 'row'
%                                  (along the rows: orders the columns)
%    'ShowDendrogram':             draw the dendrograms (default true)
%    'Symmetric':                  color limits symmetric about 0 (default true)
%    'Colormap':                   colormap name (for example 'turbo', 'jet') or matrix
%                                  (default: green-black-red, as redgreencmap)
%    'DisplayRange':               the color limits are at most this far from 0 (default 3)
%    'Standardize':                'none' (the only value supported)
%
% OUTPUTS:
%    ax:           handle of the heat-map axes (an ordinary axes with an image, so
%                  set(ax, 'TickLabelInterpreter', ...) and colorbar(ax) work)
%    rowOrder:     row order of the heat map (indices into the rows of data)
%    columnOrder:  column order of the heat map
%
% EXAMPLE:
%
%    ax = cobraClustergram(magic(5), 'RowLabels', {'a','b','c','d','e'}, 'Symmetric', false);
%    colorbar(ax)
%
% NOTE:
%    Plain-MATLAB replacement for clustergram(...) followed by plot(cgo) (Bioinformatics
%    Toolbox) with the options used by correlateFluxWithTaxonAbundance and
%    summarizeFeaturesOnTaxonLevels; other options raise an error naming them; semantics:
%    specs/20261111-152503-toolbox-free-remaining/mathworks-semantics.md, G4 section A4. As
%    clustergram's defaults: Euclidean distances (cobraPdist), average linkage
%    (computeEcosystemLinkage), optimal leaf order (cobraOptimalLeafOrder) unless the dimension
%    has more than 1500 elements (then the dendrogram order), no standardization; missing
%    values raise an error (clustergram needs ImputeFun for them). Color limits: with
%    Symmetric, +-min(DisplayRange, max|data|); otherwise [max(min(data), -DisplayRange),
%    min(max(data), DisplayRange)] (the MathWorks rule for Symmetric = false is UNCONFIRMED).
%    The heat map is drawn with imagesc in a new figure; dendrogram lines are tagged
%    'RowDendrogram' and 'ColumnDendrogram'.
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

settings = struct('rowlabels', [], 'columnlabels', [], 'columnlabelsrotate', 90, 'cluster', 'all', ...
    'showdendrogram', true, 'symmetric', true, 'colormap', [], 'displayrange', 3, 'standardize', 'none');
if mod(numel(varargin), 2) ~= 0
    error('COBRA:cobraClustergram:unsupportedOption', 'cobraClustergram: unsupported option ''%s'' (options are name-value pairs).', describeValue(varargin{end}));
end
for k = 1:2:numel(varargin)
    name = lower(describeValue(varargin{k}));
    if ~isfield(settings, name)
        error('COBRA:cobraClustergram:unsupportedOption', 'cobraClustergram: unsupported option ''%s''.', describeValue(varargin{k}));
    end
    settings.(name) = varargin{k + 1};
end
if ~strcmpi(describeValue(settings.standardize), 'none')
    error('COBRA:cobraClustergram:unsupportedOption', 'cobraClustergram: unsupported option ''Standardize'' value ''%s'' (only ''none'').', describeValue(settings.standardize));
end
clusterSetting = lower(describeValue(settings.cluster));
if ~any(strcmp(clusterSetting, {'all', 'column', 'row'}))
    error('COBRA:cobraClustergram:unsupportedOption', 'cobraClustergram: unsupported option ''Cluster'' value ''%s''.', clusterSetting);
end
if ~isnumeric(data) || ~ismatrix(data) || isempty(data)
    error('COBRA:cobraClustergram:invalidInput', 'cobraClustergram: data must be a non-empty numeric matrix.');
end
data = double(data);
if any(isnan(data(:)))
    error('COBRA:cobraClustergram:invalidInput', 'cobraClustergram: data contain NaN (clustergram needs ''ImputeFun'' for missing values, which is not supported).');
end
isSymmetric = asLogical(settings.symmetric);
isShowingDendrogram = asLogical(settings.showdendrogram);

[nRows, nColumns] = size(data);
rowOrder = 1:nRows;
columnOrder = 1:nColumns;
rowLinkage = [];
columnLinkage = [];
% clustergram: 'column' clusters along the columns (the rows are ordered), 'row' along the rows
if any(strcmp(clusterSetting, {'all', 'row'}))
    [columnOrder, columnLinkage] = clusterOrder(data');
end
if any(strcmp(clusterSetting, {'all', 'column'}))
    [rowOrder, rowLinkage] = clusterOrder(data);
end

if isempty(settings.colormap)
    green = [linspace(0, 0, 32)', linspace(1, 0, 32)', zeros(32, 1)];
    red = [linspace(0, 1, 32)', zeros(32, 1), zeros(32, 1)];
    colormapMatrix = [green; red];
elseif ischar(settings.colormap) || isstring(settings.colormap)
    colormapMatrix = feval(char(settings.colormap), 256);
else
    colormapMatrix = settings.colormap;
end
if isSymmetric
    limit = min(settings.displayrange, max(abs(data(:))));
    colorLimits = [-limit, limit];
else
    colorLimits = [max(min(data(:)), -settings.displayrange), min(max(data(:)), settings.displayrange)];
end
if colorLimits(1) == colorLimits(2)
    colorLimits = colorLimits + [-1 1] * max(eps(colorLimits(1)), eps);
end

figure;
ax = axes('Position', [0.25 0.12 0.6 0.62]);
imagesc(ax, data(rowOrder, columnOrder));
colormap(ax, colormapMatrix);
set(ax, 'CLim', colorLimits, 'YDir', 'normal', 'XTick', 1:nColumns, 'YTick', 1:nRows, 'YAxisLocation', 'right');
% labels follow the clustered order; without labels, the original row and column numbers
if isempty(settings.rowlabels)
    rowLabels = cellstr(string(1:nRows))';
else
    rowLabels = cellstr(string(settings.rowlabels(:)));
end
if isempty(settings.columnlabels)
    columnLabels = cellstr(string(1:nColumns))';
else
    columnLabels = cellstr(string(settings.columnlabels(:)));
end
set(ax, 'YTickLabel', rowLabels(rowOrder), 'XTickLabel', columnLabels(columnOrder));
set(ax, 'XTickLabelRotation', settings.columnlabelsrotate);
if isShowingDendrogram
    if ~isempty(columnLinkage)
        columnAxes = axes('Position', [0.25 0.76 0.6 0.18]);
        drawDendrogram(columnAxes, columnLinkage, columnOrder, 'ColumnDendrogram', false);
    end
    if ~isempty(rowLinkage)
        rowAxes = axes('Position', [0.05 0.12 0.18 0.62]);
        drawDendrogram(rowAxes, rowLinkage, rowOrder, 'RowDendrogram', true);
    end
    axes(ax); % the heat map is the current axes, as after plot(cgo)
end
end

function [order, Z] = clusterOrder(observations)
% Average-linkage tree of the rows of observations and its (optimal) leaf order
n = size(observations, 1);
if n < 2
    order = 1:n;
    Z = [];
    return
end
distances = cobraPdist(observations, 'euclidean');
D = zeros(n);
D(tril(true(n), -1)) = distances;
D = D + D';
Z = computeEcosystemLinkage(D, 'average');
if n <= 1500
    order = cobraOptimalLeafOrder(Z, D);
else
    order = treeOrder(Z);
end
end

function order = treeOrder(Z)
% Leaf order of the dendrogram (left subtree first), without recursion
n = size(Z, 1) + 1;
order = zeros(1, n);
filled = 0;
stack = 2 * n - 1;
while ~isempty(stack)
    node = stack(end);
    stack(end) = [];
    if node <= n
        filled = filled + 1;
        order(filled) = node;
    else
        stack = [stack, Z(node - n, 2), Z(node - n, 1)]; %#ok<AGROW>
    end
end
end

function drawDendrogram(dendrogramAxes, Z, order, tag, isRow)
% U-shaped links of the tree at the leaf positions of order, heights Z(:, 3)
n = size(Z, 1) + 1;
position = zeros(1, 2 * n - 1);
position(order) = 1:n;
height = zeros(1, 2 * n - 1);
hold(dendrogramAxes, 'on');
for row = 1:n - 1
    a = Z(row, 1);
    b = Z(row, 2);
    position(n + row) = (position(a) + position(b)) / 2;
    height(n + row) = Z(row, 3);
    along = [position(a), position(a), position(b), position(b)];
    across = [height(a), Z(row, 3), Z(row, 3), height(b)];
    if isRow
        line(dendrogramAxes, -across, along, 'Color', 'k', 'Tag', tag);
    else
        line(dendrogramAxes, along, across, 'Color', 'k', 'Tag', tag);
    end
end
axis(dendrogramAxes, 'off');
if isRow
    ylim(dendrogramAxes, [0.5, n + 0.5]);
else
    xlim(dendrogramAxes, [0.5, n + 0.5]);
end
end

function value = asLogical(value)
% Logical value from true/false, 1/0, 'true'/'false', 'on'/'off'
if ischar(value) || isstring(value)
    value = any(strcmpi(char(value), {'true', 'on'}));
else
    value = logical(value);
end
end

function text = describeValue(value)
% Text naming an option or value in an error message
if ischar(value) || isstring(value)
    text = char(value);
else
    text = class(value);
end
end
