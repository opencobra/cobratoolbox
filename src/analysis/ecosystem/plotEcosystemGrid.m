function [ax, plottedPoints, plottedColors] = plotEcosystemGrid(eco, varargin)
% Plots the points of the abundance-growth grid of a two-member ecosystem.
% The x axis is the fraction of the first member and the y axis is the
% community growth rate. Points can be colored according to their
% feasibility, cluster, community growth, member fraction, the qualitative
% state of a reaction or any user-provided value.
%
% USAGE:
%
%    [ax, plottedPoints, plottedColors] = plotEcosystemGrid(eco, varargin)
%
% INPUT:
%    eco:            (structure) ecosystem structure with a grid
%                    (see `buildEcosystemGrid`)
%
% OPTIONAL INPUTS:
%    toPlot:         (string) how points are colored:
%
%                      * 'none' - all grid points without coloring (Default)
%                      * 'feasible' - all grid points, colored as feasible
%                        or unfeasible
%                      * 'cluster' - analyzed points colored by cluster
%                      * 'communityGrowth' - analyzed points colored by `mu`
%                      * 'memberFraction' - analyzed points colored by the
%                        fraction of member `fracPrefix`
%                      * 'qualState' - analyzed points colored by the
%                        qualitative state of reaction `rxn`
%                      * 'values' - analyzed points colored by `values`
%    rxn:            (string) reaction ID for 'qualState' (Default = '')
%    values:         (double) one value per analyzed point for 'values'
%                    (Default = [])
%    clusters:       (double) cluster labels used instead of `eco.clusters`
%                    (Default = [])
%    fracPrefix:     (string) member prefix for 'memberFraction'
%                    (Default = first member)
%    colormap:       (string or double) 'tab20', 'tab20c', any MATLAB
%                    colormap name, or a n x 3 RGB matrix (Default = 'tab20')
%    markerSize:     (double) marker area in points^2 (Default = 60)
%    xlabel:         (string) x axis label (Default = ['f_{' prefix1 '}'])
%    ylabel:         (string) y axis label (Default = '\mu_{com} [h^{-1}]')
%    title:          (string) axes title (Default = '')
%    showColorbar:   (logical) draw a colorbar (Default = true)
%    axes:           axes handle where the points are drawn (Default = new figure)
%    saveFile:       (string) file name (without extension) to save the
%                    figure as png (Default = '', not saved)
%
% OUTPUTS:
%    ax:             axes handle
%    plottedPoints:  (double) n x 2 matrix with the plotted points
%    plottedColors:  (double) n x 1 vector with the plotted color values
%
% EXAMPLE:
%
%    plotEcosystemGrid(eco, 'toPlot', 'cluster', 'colormap', 'tab20c', 'markerSize', 70);
%
% NOTE:
%
%    Equivalent to `Ecosystem.plot_2D_slice` of the Python implementation for
%    two-member communities. Analyzed points are those listed in
%    `eco.qualPointIndex` or, if empty, the feasible points.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

parser = inputParser();
parser.addRequired('eco', @(x) isstruct(x) && isfield(x, 'points'));
parser.addParameter('toPlot', 'none', @(x) any(strcmpi(x, {'none', 'feasible', 'cluster', 'communityGrowth', ...
    'memberFraction', 'qualState', 'values'})));
parser.addParameter('rxn', '', @ischar);
parser.addParameter('values', [], @isnumeric);
parser.addParameter('clusters', [], @isnumeric);
parser.addParameter('fracPrefix', '', @ischar);
parser.addParameter('colormap', 'tab20', @(x) ischar(x) || (isnumeric(x) && size(x, 2) == 3));
parser.addParameter('markerSize', 60, @(x) isnumeric(x) && isscalar(x) && x > 0);
parser.addParameter('xlabel', '', @ischar);
parser.addParameter('ylabel', '\mu_{com} [h^{-1}]', @ischar);
parser.addParameter('title', '', @ischar);
parser.addParameter('showColorbar', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('axes', [], @(x) isempty(x) || isgraphics(x, 'axes'));
parser.addParameter('saveFile', '', @ischar);
parser.parse(eco, varargin{:});
eco = parser.Results.eco;
toPlot = parser.Results.toPlot;
rxn = parser.Results.rxn;
values = parser.Results.values(:);
clusters = parser.Results.clusters(:);
fracPrefix = parser.Results.fracPrefix;
cmapInput = parser.Results.colormap;
markerSize = parser.Results.markerSize;
xLabel = parser.Results.xlabel;
yLabel = parser.Results.ylabel;
titleText = parser.Results.title;
showColorbar = parser.Results.showColorbar;
ax = parser.Results.axes;
saveFile = parser.Results.saveFile;

if isempty(eco.points)
    error('Grid points are not set yet! Run buildEcosystemGrid first.');
end
if isempty(xLabel)
    xLabel = ['f_{' strrep(eco.prefixes{1}, '_', '\_') '}'];
end
% analyzed points
if isfield(eco, 'qualPointIndex') && ~isempty(eco.qualPointIndex)
    analyzedIdx = eco.qualPointIndex(:);
elseif ~isempty(eco.feasiblePoints)
    analyzedIdx = find(eco.feasiblePoints);
else
    analyzedIdx = (1:size(eco.points, 1))';
end

% colormap
tab20 = [31 119 180; 174 199 232; 255 127 14; 255 187 120; 44 160 44; 152 223 138; 214 39 40; ...
    255 152 150; 148 103 189; 197 176 213; 140 86 75; 196 156 148; 227 119 194; 247 182 210; ...
    127 127 127; 199 199 199; 188 189 34; 219 219 141; 23 190 207; 158 218 229] / 255;
tab20c = [49 130 189; 107 174 214; 158 202 225; 198 219 239; 230 85 13; 253 141 60; 253 174 107; ...
    253 208 162; 49 163 84; 116 196 118; 161 217 155; 199 233 192; 117 107 177; 158 154 200; ...
    188 189 220; 218 218 235; 99 99 99; 150 150 150; 189 189 189; 217 217 217] / 255;
if isnumeric(cmapInput)
    baseCmap = cmapInput;
elseif strcmpi(cmapInput, 'tab20')
    baseCmap = tab20;
elseif strcmpi(cmapInput, 'tab20c')
    baseCmap = tab20c;
else
    baseCmap = feval(cmapInput, 256);
end

if isempty(ax)
    figure('Position', [100, 100, 650, 600]);
    ax = gca;
end
hold(ax, 'on');
categorical = false;
switch lower(toPlot)
    case 'none'
        plottedPoints = eco.points;
        plottedColors = [];
    case 'feasible'
        if isempty(eco.feasiblePoints)
            error('Points feasibility analysis has not been run! Required for plot!');
        end
        plottedPoints = eco.points;
        plottedColors = double(eco.feasiblePoints(:)) + 1;
        categorical = true;
        k = 2;
        tickLabels = {'unfeasible', 'feasible'};
    case 'cluster'
        if isempty(clusters)
            clusters = eco.clusters(:);
        end
        if isempty(clusters)
            error('Clusters have not been computed. Run clusterEcosystemPoints first.');
        end
        if numel(clusters) ~= numel(analyzedIdx)
            error('The number of cluster labels differs from the number of analyzed points.');
        end
        plottedPoints = eco.points(analyzedIdx, :);
        plottedColors = clusters;
        categorical = true;
        k = max([eco.k; clusters]);
        tickLabels = strcat('c', arrayfun(@num2str, 1:k, 'UniformOutput', false));
    case 'communitygrowth'
        plottedPoints = eco.points(analyzedIdx, :);
        plottedColors = plottedPoints(:, 2);
        colorLabel = 'community growth';
    case 'memberfraction'
        if isempty(fracPrefix)
            fracPrefix = eco.prefixes{1};
        end
        memberIdx = find(strcmp(eco.prefixes, fracPrefix));
        if isempty(memberIdx)
            error('Missing valid member prefix: fracPrefix');
        end
        plottedPoints = eco.points(analyzedIdx, :);
        fractions = [plottedPoints(:, 1), 1 - plottedPoints(:, 1)];
        plottedColors = fractions(:, memberIdx);
        colorLabel = [fracPrefix ' fraction'];
    case 'qualstate'
        col = find(strcmp(eco.rxn2cluster, rxn));
        if isempty(col)
            error('Reaction %s is not in eco.rxn2cluster.', rxn);
        end
        plottedPoints = eco.points(analyzedIdx, :);
        plottedColors = eco.qualVectors(:, col);
    case 'values'
        if numel(values) ~= numel(analyzedIdx)
            error('values must have one element per analyzed point (%d).', numel(analyzedIdx));
        end
        plottedPoints = eco.points(analyzedIdx, :);
        plottedColors = values;
        colorLabel = '';
end

if strcmpi(toPlot, 'none')
    scatter(ax, plottedPoints(:, 1), plottedPoints(:, 2), markerSize, 'filled');
elseif strcmpi(toPlot, 'qualstate')
    codes = [-3, -2, -1, 0, 1, 2, 3, 4, 5];
    stateColors = [0.40 0.00 0.05; 0.84 0.15 0.16; 0.99 0.55 0.38; 0.75 0.75 0.75; ...
        0.62 0.79 0.88; 0.13 0.44 0.71; 0.03 0.19 0.42; 0.58 0.40 0.74; 0 0 0];
    labels = qualitativeStateLabels(codes);
    handles = [];
    names = {};
    for i = 1:numel(codes)
        sel = plottedColors == codes(i);
        if any(sel)
            handles(end + 1) = scatter(ax, plottedPoints(sel, 1), plottedPoints(sel, 2), markerSize, ...
                stateColors(i, :), 'filled'); %#ok<AGROW>
            names{end + 1} = labels{i}; %#ok<AGROW>
        end
    end
    if showColorbar
        legend(ax, handles, names, 'Location', 'eastoutside');
    end
    if isempty(titleText)
        titleText = rxn;
    end
elseif categorical
    % same resampling of a listed colormap as matplotlib get_cmap(name, k)
    nBase = size(baseCmap, 1);
    if nBase == 256
        cmap = baseCmap(round(linspace(1, nBase, k)), :);
    else
        cmap = baseCmap(min(floor(linspace(0, 1, k) * nBase), nBase - 1) + 1, :);
    end
    scatter(ax, plottedPoints(:, 1), plottedPoints(:, 2), markerSize, plottedColors, 'filled');
    colormap(ax, cmap);
    caxis(ax, [0.5, k + 0.5]);
    if showColorbar
        colorbar(ax, 'Ticks', 1:k, 'TickLabels', tickLabels);
    end
else
    scatter(ax, plottedPoints(:, 1), plottedPoints(:, 2), markerSize, plottedColors, 'filled');
    colormap(ax, baseCmap);
    if showColorbar
        cb = colorbar(ax);
        cb.Label.String = colorLabel;
    end
end
xlabel(ax, xLabel);
ylabel(ax, yLabel);
if ~isempty(titleText)
    title(ax, titleText, 'Interpreter', 'none');
end
set(ax, 'Box', 'on');
hold(ax, 'off');
if ~isempty(saveFile)
    saveas(ancestor(ax, 'figure'), [saveFile '.png']);
end
end
