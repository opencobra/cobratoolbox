function fig = plotQuantitativeFluxCoupling(qfca, varargin)
% Plots the results of a quantitative flux coupling analysis (see
% `quantitativeFluxCoupling`). One panel is drawn per grid point, showing the
% feasible region (between the minimum and maximum values) of the second
% reaction as a function of the first reaction.
%
% USAGE:
%
%    fig = plotQuantitativeFluxCoupling(qfca, varargin)
%
% INPUT:
%    qfca:          (table) output of `quantitativeFluxCoupling`
%
% OPTIONAL INPUTS:
%    colWrap:       (double) number of panels per row (Default = 4)
%    faceColor:     (double) RGB color of the feasible region
%                   (Default = [0.55 0.71 0.86])
%    figureSize:    (double) [width, height] of the figure in pixels
%                   (Default = [300 * colWrap, 260 * nRows])
%
% OUTPUT:
%    fig:           figure handle
%
% EXAMPLE:
%
%    qfca = quantitativeFluxCoupling(eco, [0.2 0.4], [40 20], {'org1_EX_A', 'org2_EX_A'});
%    plotQuantitativeFluxCoupling(qfca, 'colWrap', 2);
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

parser = inputParser();
parser.addRequired('qfca', @(x) istable(x) && all(ismember({'rxn1', 'rxn2', 'FVA', 'point'}, x.Properties.VariableNames)));
parser.addParameter('colWrap', 4, @(x) isnumeric(x) && isscalar(x) && x >= 1);
parser.addParameter('faceColor', [0.55 0.71 0.86], @(x) isnumeric(x) && numel(x) == 3);
parser.addParameter('figureSize', [], @(x) isempty(x) || (isnumeric(x) && numel(x) == 2));
parser.parse(qfca, varargin{:});
qfca = parser.Results.qfca;
colWrap = parser.Results.colWrap;
faceColor = parser.Results.faceColor;
figureSize = parser.Results.figureSize;

rxnPair = {'rxn1', 'rxn2'};
if isfield(qfca.Properties.UserData, 'rxnPair')
    rxnPair = qfca.Properties.UserData.rxnPair;
end
points = unique(qfca.point, 'stable');
points = points(:);
nPanels = numel(points);
nCols = min(colWrap, nPanels);
nRows = ceil(nPanels / nCols);
if isempty(figureSize)
    figureSize = [300 * nCols, 260 * nRows];
end
fig = figure('Position', [100, 100, figureSize]);
for i = 1:nPanels
    ax = subplot(nRows, nCols, i);
    hold(ax, 'on');
    isPoint = strcmp(qfca.point, points{i});
    isMax = isPoint & strcmp(qfca.FVA, 'maximum');
    isMin = isPoint & strcmp(qfca.FVA, 'minimum');
    x = qfca.rxn1(isMax);
    yMax = qfca.rxn2(isMax);
    yMin = qfca.rxn2(isMin);
    valid = ~isnan(x) & ~isnan(yMax) & ~isnan(yMin);
    x = x(valid);
    yMax = yMax(valid);
    yMin = yMin(valid);
    if ~isempty(x)
        fill(ax, [x; flipud(x)], [yMax; flipud(yMin)], faceColor, 'EdgeColor', 'none', 'FaceAlpha', 0.6);
        plot(ax, x, yMax, '-', 'Color', [0.8 0.33 0.1], 'LineWidth', 1.2);
        plot(ax, x, yMin, '-', 'Color', [0 0.45 0.74], 'LineWidth', 1.2);
    end
    title(ax, ['point = ' points{i}], 'Interpreter', 'none');
    xlabel(ax, rxnPair{1}, 'Interpreter', 'none');
    ylabel(ax, rxnPair{2}, 'Interpreter', 'none');
    set(ax, 'XGrid', 'on', 'YGrid', 'on');
    set(ax, 'Box', 'on');
    if i == 1
        legend(ax, {'feasible region', 'maximum', 'minimum'}, 'Location', 'best');
    end
end
end
