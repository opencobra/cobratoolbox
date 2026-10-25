function [fig, stateCodes, stateLabels] = plotQualitativeStateOverlap(ecoList, rxns, varargin)
% Plots the overlap of the qualitative states of one or more reactions on the
% abundance-growth grid of one or more scenarios (one panel per scenario).
% For each analyzed point, the states of the reactions are encoded as
%
%    code = sum_i (state_i + 4) * base^(i - 1)
%
% and each distinct combination of states found in any scenario receives a
% color shared by all panels.
%
% USAGE:
%
%    [fig, stateCodes, stateLabels] = plotQualitativeStateOverlap(ecoList, rxns, varargin)
%
% INPUTS:
%    ecoList:       (cell array or structure) ecosystem structures with
%                   qualitative vectors (see `ecosystemQualitativeFVA` or
%                   `loadEcosystemScenario`)
%    rxns:          (cell array) reactions to analyze (must be in
%                   `eco.rxn2cluster` of all scenarios)
%
% OPTIONAL INPUTS:
%    base:          (double) base of the encoding (Default = 10)
%    titles:        (cell array) title of each panel (Default = `eco.name`)
%    colormap:      (string or double) 'tab20c', 'tab20', a MATLAB colormap
%                   name or a n x 3 RGB matrix (Default = 'tab20c')
%    markerSize:    (double) marker area (Default = 30)
%    xlabel:        (string) x axis label (Default = 'f_{<first prefix>}')
%    ylabel:        (string) y axis label (Default = '\mu_{com} [h^{-1}]')
%    showColorbar:  (logical) draw a colorbar with the state combinations
%                   (Default = true)
%    saveFile:      (string) file name (without extension) to save the figure
%                   as png (Default = '', not saved)
%
% OUTPUTS:
%    fig:           figure handle
%    stateCodes:    (double) sorted codes of the state combinations found
%    stateLabels:   (cell array) description of each state combination
%
% EXAMPLE:
%
%    plotQualitativeStateOverlap(ecoList, {'cut_EX_co2_e', 'EX_fe2_e', 'EX_tsul_e'});
%
% NOTE:
%
%    Equivalent to the functions `plot_single_overlap` and
%    `plot_multiple_overlap` defined in the notebook
%    `sup_mat_multiple_bioleaching.ipynb`.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

parser = inputParser();
parser.addRequired('ecoList', @(x) iscell(x) || isstruct(x));
parser.addRequired('rxns', @(x) iscellstr(x) || ischar(x) || isstring(x));
parser.addParameter('base', 10, @(x) isnumeric(x) && isscalar(x) && x >= 10);
parser.addParameter('titles', {}, @iscell);
parser.addParameter('colormap', 'tab20c', @(x) ischar(x) || (isnumeric(x) && size(x, 2) == 3));
parser.addParameter('markerSize', 30, @(x) isnumeric(x) && isscalar(x) && x > 0);
parser.addParameter('xlabel', '', @ischar);
parser.addParameter('ylabel', '\mu_{com} [h^{-1}]', @ischar);
parser.addParameter('showColorbar', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('saveFile', '', @ischar);
parser.parse(ecoList, rxns, varargin{:});
ecoList = parser.Results.ecoList;
rxns = cellstr(parser.Results.rxns);
base = parser.Results.base;
titles = parser.Results.titles;
cmapInput = parser.Results.colormap;
markerSize = parser.Results.markerSize;
xLabel = parser.Results.xlabel;
yLabel = parser.Results.ylabel;
showColorbar = parser.Results.showColorbar;
saveFile = parser.Results.saveFile;

if isstruct(ecoList)
    ecoList = num2cell(ecoList);
end
nScenarios = numel(ecoList);
if isempty(titles)
    titles = cellfun(@(e) e.name, ecoList, 'UniformOutput', false);
end
if isempty(xLabel)
    xLabel = ['f_{' strrep(ecoList{1}.prefixes{1}, '_', '\_') '}'];
end

% encode the states of each scenario
codes = cell(nScenarios, 1);
points = cell(nScenarios, 1);
for s = 1:nScenarios
    eco = ecoList{s};
    [found, cols] = ismember(rxns, eco.rxn2cluster);
    if ~all(found)
        error('Reactions not found in scenario %s: %s', titles{s}, strjoin(rxns(~found), ', '));
    end
    code = zeros(size(eco.qualVectors, 1), 1);
    for i = 1:numel(rxns)
        code = code + (eco.qualVectors(:, cols(i)) + 4) * base ^ (i - 1);
    end
    codes{s} = code;
    points{s} = eco.points(eco.qualPointIndex, :);
end
stateCodes = unique(vertcat(codes{:}));
nStates = numel(stateCodes);

% labels of the state combinations
stateLabels = cell(nStates, 1);
for c = 1:nStates
    parts = cell(1, numel(rxns));
    for i = numel(rxns):-1:1
        state = mod(floor(stateCodes(c) / base ^ (i - 1)), base) - 4;
        label = qualitativeStateLabels(state);
        parts{numel(rxns) - i + 1} = [rxns{i} ' ' label{1}];
    end
    stateLabels{c} = strjoin(parts, ', ');
end

% colormap resampled to the number of state combinations
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
nBase = size(baseCmap, 1);
cmap = baseCmap(min(floor(linspace(0, 1, nStates) * nBase), nBase - 1) + 1, :);

% panels on the left, colorbar labels on the right
labelWidth = 0;
if showColorbar
    labelWidth = 7 * max(cellfun(@numel, stateLabels)) + 60;
end
figWidth = 300 * nScenarios + 80 + labelWidth;
fig = figure('Position', [100, 100, figWidth, 450]);
plotsWidth = 1 - (80 + labelWidth) / figWidth;
gap = 0.04 * (nScenarios > 1);
panelWidth = (plotsWidth - gap * (nScenarios - 1)) / nScenarios;
axList = gobjects(nScenarios, 1);
for s = 1:nScenarios
    axList(s) = axes(fig, 'Position', [0.07 + (s - 1) * (panelWidth + gap), 0.13, panelWidth - 0.01, 0.78]);
    [~, colorIdx] = ismember(codes{s}, stateCodes);
    scatter(axList(s), points{s}(:, 1), points{s}(:, 2), markerSize, colorIdx, 'filled');
    colormap(axList(s), cmap);
    caxis(axList(s), [0.5, nStates + 0.5]);
    title(axList(s), titles{s}, 'Interpreter', 'none');
    xlabel(axList(s), xLabel);
    if s == 1
        ylabel(axList(s), yLabel);
    end
    set(axList(s), 'Box', 'on');
end
linkaxes(axList, 'xy');
yl = ylim(axList(1));
ylim(axList(1), [0, yl(2)]);
if showColorbar
    lastPos = get(axList(end), 'Position');
    colorbar(axList(end), 'Ticks', 1:nStates, 'TickLabels', stateLabels, 'TickLabelInterpreter', 'none', ...
        'Position', [lastPos(1) + lastPos(3) + 0.015, lastPos(2), 0.015, lastPos(4)]);
end
if ~isempty(saveFile)
    saveas(fig, [saveFile '.png']);
end
end
