% The COBRAToolbox: testCobraClustergram.m
%
% Purpose:
%     - cobraClustergram is the plain-MATLAB replacement for clustergram followed by plot
%       (Bioinformatics Toolbox), as used by correlateFluxWithTaxonAbundance and
%       summarizeFeaturesOnTaxonLevels. This test draws headless and checks the content that
%       carries meaning: the returned axes (TickLabelInterpreter and colorbar work on it), the
%       image data in row and column order, the orders against the average-linkage tree and the
%       optimal leaf order, the row and column labels in that order, the label rotation, the
%       colormap (name and default), the colour limits with and without Symmetric, the
%       dendrogram lines, clustering of one dimension only, the large-dimension fallback, and
%       the errors for unsupported options and missing values.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraClustergram.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs; figures are invisible and closed.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCobraClustergram'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

defaultVisibility = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');

% correlation-like data: rows 1, 3 and 5 alike, rows 2 and 4 alike; columns 1 and 3 alike
data = [0.9 0.1 0.8 -0.2; -0.5 0.7 -0.4 0.6; 0.8 0.2 0.9 -0.1; -0.6 0.8 -0.5 0.5; 0.7 0.0 0.7 -0.3];
rowLabels = {'r1'; 'r2'; 'r3'; 'r4'; 'r5'};
columnLabels = {'c1', 'c2', 'c3', 'c4'};

%% the options of correlateFluxWithTaxonAbundance

[ax, rowOrder, columnOrder] = cobraClustergram(data, 'RowLabels', rowLabels, 'ColumnLabels', columnLabels, ...
    'ColumnLabelsRotate', 45, 'Cluster', 'all', 'ShowDendrogram', 'True', 'symmetric', 'False', 'colormap', 'turbo');
% the call site sets the interpreter and adds a colour bar to the returned axes
set(ax, 'TickLabelInterpreter', 'none');
colorbarHandle = colorbar(ax);
assert(isa(ax, 'matlab.graphics.axis.Axes') && isvalid(colorbarHandle));
image = findobj(ax, 'Type', 'image');
assert(isequal(image.CData, data(rowOrder, columnOrder)));
assert(isequal(ax.YTickLabel, rowLabels(rowOrder)) && isequal(ax.XTickLabel, columnLabels(columnOrder)'));
assert(ax.XTickLabelRotation == 45 && isequal(ax.Colormap, turbo(256)));
% Symmetric = false: data range within DisplayRange 3
assert(isequal(ax.CLim, [min(data(:)), max(data(:))]));
% similar rows are adjacent: {1, 3, 5} and {2, 4} are clusters of the average-linkage tree
assert(abs(diff(find(ismember(rowOrder, [2 4])))) == 1 && all(abs(diff(sort(find(ismember(rowOrder, [1 3 5]))))) == 1));
% the orders are the optimal leaf orders of the average-linkage trees
rowDistances = squareformLocal(cobraPdist(data, 'euclidean'), 5);
assert(isequal(rowOrder, cobraOptimalLeafOrder(computeEcosystemLinkage(rowDistances, 'average'), rowDistances)));
% dendrogram lines: n - 1 links per dimension
assert(numel(findobj(ax.Parent, 'Tag', 'RowDendrogram')) == 4 && numel(findobj(ax.Parent, 'Tag', 'ColumnDendrogram')) == 3);
close all

%% the options of summarizeFeaturesOnTaxonLevels: no column labels, jet, default dendrograms

[ax, rowOrder] = cobraClustergram(data, 'RowLabels', rowLabels, 'Cluster', 'all', 'symmetric', 'False', 'colormap', 'jet');
assert(isequal(ax.Colormap, jet(256)) && isequal(ax.YTickLabel, rowLabels(rowOrder)) && gca == ax);
close all

%% defaults: symmetric colour limits clipped at DisplayRange, red-green colormap, no dendrogram

ax = cobraClustergram(10 * data, 'ShowDendrogram', false);
assert(isequal(ax.CLim, [-3 3]) && size(ax.Colormap, 1) == 64 && isempty(findobj(ax.Parent, 'Tag', 'RowDendrogram')));
ax = cobraClustergram(data, 'Symmetric', true, 'Colormap', gray(16), 'DisplayRange', 2);
assert(isequal(ax.CLim, [-0.9 0.9]) && isequal(ax.Colormap, gray(16)));
% constant data: the colour limits are widened so that they increase
ax = cobraClustergram(ones(2, 2), 'Symmetric', false);
assert(ax.CLim(2) > ax.CLim(1));
close all

%% one dimension only, a single row, and the order for more than 1500 elements

[~, rowOrder, columnOrder] = cobraClustergram(data, 'Cluster', 'column');
assert(isequal(rowOrder, 1:5) && ~isequal(columnOrder, []));
[~, rowOrder, columnOrder] = cobraClustergram(data, 'Cluster', 'row');
assert(isequal(columnOrder, 1:4) && numel(rowOrder) == 5);
[~, rowOrder] = cobraClustergram([1 2 3], 'ShowDendrogram', 'on');
assert(isequal(rowOrder, 1));
large = [(1:1501)' .^ 1.5, zeros(1501, 1)];
[~, rowOrder] = cobraClustergram(large, 'Cluster', 'row', 'ShowDendrogram', 'off');
assert(isequal(sort(rowOrder), 1:1501));
close all

%% errors: unsupported options and values, missing values, empty data

assert(verifyCobraFunctionError('cobraClustergram', 'inputs', {data, 'ImputeFun', @knnimpute}, ...
    'testMessage', 'cobraClustergram: unsupported option ''ImputeFun''.'));
assert(verifyCobraFunctionError('cobraClustergram', 'inputs', {data, 'RowLabels'}, ...
    'testMessage', 'cobraClustergram: unsupported option ''RowLabels'' (options are name-value pairs).'));
assert(verifyCobraFunctionError('cobraClustergram', 'inputs', {data, 'Standardize', 'row'}, ...
    'testMessage', 'cobraClustergram: unsupported option ''Standardize'' value ''row'' (only ''none'').'));
assert(verifyCobraFunctionError('cobraClustergram', 'inputs', {data, 'Cluster', 3}, ...
    'testMessage', 'cobraClustergram: unsupported option ''Cluster'' value ''double''.'));
assert(verifyCobraFunctionError('cobraClustergram', 'inputs', {[1 NaN; 2 3]}, ...
    'testMessage', 'cobraClustergram: data contain NaN (clustergram needs ''ImputeFun'' for missing values, which is not supported).'));
assert(verifyCobraFunctionError('cobraClustergram', 'inputs', {[]}, ...
    'testMessage', 'cobraClustergram: data must be a non-empty numeric matrix.'));

set(0, 'DefaultFigureVisible', defaultVisibility);
close all

% change the directory
cd(currentDir)

function D = squareformLocal(distances, n)
% Square distance matrix from a pdist vector (squareform is a Statistics function)
D = zeros(n);
D(tril(true(n), -1)) = distances;
D = D + D';
end
