function [G, h] = plotOptStoicPathway(database, pathway, varargin)
% Plots a pathway found by `findOptStoicPathways` (minFlux/minRxn) as a
% directed bipartite graph of metabolites (circles) and reactions (squares).
% Edges follow the direction of the flux. Currency metabolites (water,
% protons, ATP, NAD(P)H, ...) are hidden by default.
%
% USAGE:
%
%    [G, h] = plotOptStoicPathway(database, pathway, varargin)
%
% INPUTS:
%    database:          (structure) database loaded with `loadOptStoicDatabase`
%    pathway:           (structure) one element of the output of
%                       `findOptStoicPathways`
%
% OPTIONAL INPUTS:
%    currencyMets:      (cell array) metabolites that are not drawn
%                       (Default = water, H+, ATP, ADP, AMP, phosphate,
%                       pyrophosphate, NAD+, NADH, NADP+, NADPH, CoA, FAD,
%                       FADH2, ammonia, oxygen and ferredoxins: C00001, C00080, C00002,
%                       C00008, C00020, C00009, C00013, C00003, C00004,
%                       C00006, C00005, C00010, C00016, C01352, C00014, C00007,
%                       C00138, C00139)
%    useAbbreviations:  (logical) label reactions with their abbreviations
%                       when available (Default = true)
%    showFlux:          (logical) add the flux to the reaction labels
%                       (Default = true)
%    title:             (string) figure title (Default = '')
%    axes:              axes handle (Default = new figure)
%
% OUTPUTS:
%    G:                 digraph object of the pathway
%    h:                 GraphPlot handle
%
% EXAMPLE:
%
%    pathways = optStoicMinFlux(database, {'C00267', 'C00033'}, [-1 3], 'flexibleMets', {'C00080'});
%    plotOptStoicPathway(database, pathways(1));
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026

parser = inputParser();
parser.addRequired('database', @(x) isstruct(x) && all(isfield(x, {'S', 'mets', 'rxns'})));
parser.addRequired('pathway', @(x) isstruct(x) && all(isfield(x, {'rxns', 'fluxes'})));
parser.addParameter('currencyMets', {'C00001', 'C00080', 'C00002', 'C00008', 'C00020', 'C00009', 'C00013', ...
    'C00003', 'C00004', 'C00006', 'C00005', 'C00010', 'C00016', 'C01352', 'C00014', 'C00007', 'C00138', 'C00139'}, @iscellstr);
parser.addParameter('useAbbreviations', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('showFlux', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('title', '', @ischar);
parser.addParameter('axes', [], @(x) isempty(x) || isgraphics(x, 'axes'));
parser.parse(database, pathway, varargin{:});
database = parser.Results.database;
pathway = parser.Results.pathway;
currencyMets = parser.Results.currencyMets;
useAbbreviations = parser.Results.useAbbreviations;
showFlux = parser.Results.showFlux;
titleText = parser.Results.title;
ax = parser.Results.axes;

[~, rxnIdx] = ismember(pathway.rxns, database.rxns);
if any(rxnIdx == 0)
    error('Reactions of the pathway not found in the database.');
end
S = database.S(:, rxnIdx) .* pathway.fluxes(:)';
metRows = find(any(S ~= 0, 2) & ~ismember(database.mets, currencyMets));
metLabels = database.mets(metRows);
if isfield(database, 'metNames')
    metLabels = database.metNames(metRows);
end
rxnLabels = pathway.rxns(:);
if useAbbreviations && isfield(database, 'rxnAbbreviations')
    abbr = database.rxnAbbreviations(rxnIdx);
    hasAbbr = ~cellfun(@isempty, abbr);
    rxnLabels(hasAbbr) = abbr(hasAbbr);
end
if showFlux
    rxnLabels = strcat(rxnLabels, ' (', arrayfun(@(v) num2str(v, 4), abs(pathway.fluxes(:)), 'UniformOutput', false), ')');
end

nMets = numel(metRows);
nRxns = numel(rxnIdx);
% node names must be unique
nodeNames = [strcat('m:', database.mets(metRows)); strcat('r:', pathway.rxns(:))];
[src, dst] = deal({});
for j = 1:nRxns
    for k = 1:nMets
        value = S(metRows(k), j);
        if value < 0
            src{end + 1} = nodeNames{k}; %#ok<AGROW>
            dst{end + 1} = nodeNames{nMets + j}; %#ok<AGROW>
        elseif value > 0
            src{end + 1} = nodeNames{nMets + j}; %#ok<AGROW>
            dst{end + 1} = nodeNames{k}; %#ok<AGROW>
        end
    end
end
G = digraph(src, dst, [], nodeNames);
[~, order] = ismember(G.Nodes.Name, nodeNames);
labels = [metLabels; rxnLabels];
labels = labels(order);
isRxnNode = order > nMets;

if isempty(ax)
    figure('Position', [100, 100, 900, 700]);
    ax = gca;
end
h = plot(ax, G, 'Layout', 'layered', 'NodeLabel', labels, 'Interpreter', 'none', ...
    'ArrowSize', 8, 'EdgeColor', [0.5 0.5 0.5]);
highlight(h, find(~isRxnNode), 'Marker', 'o', 'MarkerSize', 6, 'NodeColor', [0 0.45 0.74]);
highlight(h, find(isRxnNode), 'Marker', 's', 'MarkerSize', 8, 'NodeColor', [0.85 0.33 0.1]);
% substrates and products of the overall conversion
if isfield(pathway, 'exchangeMets') && isfield(pathway, 'exchangeFluxes')
    exNodes = find(ismember(G.Nodes.Name, strcat('m:', pathway.exchangeMets(pathway.exchangeFluxes ~= 0))));
    highlight(h, exNodes, 'NodeColor', [0.47 0.67 0.19], 'MarkerSize', 9);
end
set(ax, 'XTick', [], 'YTick', []);
if ~isempty(titleText)
    title(ax, titleText, 'Interpreter', 'none');
end
end
