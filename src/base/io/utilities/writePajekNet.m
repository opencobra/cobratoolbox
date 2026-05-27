function writePajekNet(model, fluxTol, fileName)
% Builds a metabolite centric directed graph from a COBRA model
% and outputs a graph in Pajek `.net` format ready to use for most graph
% analysis software (e.g. Pajek). One FBA is solved to set the arc width
% equal to the reaction flux.
%
% USAGE:
%
%    writePajekNet(model, fluxTol, fileName)
%
% INPUT:
%    model:       a COBRA structured model
%
% OPTIONAL INPUTS:
%    fluxTol:     absolute flux threshold below which a reaction is
%                 considered inactive and excluded from the graph
%                 (default: solver `feasTol` from `getCobraSolverParams`)
%    fileName:    name of the output `.net` file (default: 'COBRAmodel.net')
%
% OUTPUT:
%    .net:        directed Pajek file (uses `*Arcs`) containing the graph
%
% Ex: `A + B -> C` (hypergraph) with `|v| < fluxTol` => no output,
% if `v > 0` then it becomes `A -> C`; `B -> C` (graph),
% if `v < 0` then the order is reversed.
%
% .. Author: - Marouen BEN GUEBILA 20/01/2016

if nargin < 2 || isempty(fluxTol)
    try
        fluxTol = getCobraSolverParams('LP', 'feasTol');
    catch
        fluxTol = 1e-6;
    end
end
if nargin < 3 || isempty(fileName)
    fileName = 'COBRAmodel.net';
end

m = length(model.mets);  % number of metabolites (vertices)
n = length(model.rxns);  % number of reactions

% performs one FBA
FBA = solveCobraLP(model);
if ~isfield(FBA, 'stat') || FBA.stat ~= 1 || ~isfield(FBA, 'full') || isempty(FBA.full)
    error('writePajekNet:lpFailed', ...
          'FBA did not return an optimal solution (stat = %s); cannot build graph.', ...
          mat2str(getfield_safe(FBA, 'stat')));
end
v = FBA.full(1:n);

% identify biomass / objective reactions to exclude (case-insensitive),
% plus anything currently set as the linear objective
rxnIds = lower(model.rxns);
isBiomass = ~cellfun('isempty', strfind(rxnIds, 'biomass')) | ...
            ~cellfun('isempty', strfind(rxnIds, 'objective'));
if isfield(model, 'c')
    isBiomass = isBiomass | (model.c(:) ~= 0);
end

% pre-compute which reactions actually contribute edges
isActive = false(n, 1);
edgesPerRxn = zeros(n, 1);
for i = 1:n
    if isBiomass(i) || abs(v(i)) < fluxTol
        continue
    end
    metPos = find(model.S(:, i) > 0);
    metNeg = find(model.S(:, i) < 0);
    % skip demand / sink reactions
    if isempty(metPos) || isempty(metNeg)
        continue
    end
    isActive(i) = true;
    edgesPerRxn(i) = numel(metPos) * numel(metNeg);
end
totalEdges = sum(edgesPerRxn);

% write the .net file (directed: *Arcs)
fileID = fopen(fileName, 'w');
if fileID < 0
    error('writePajekNet:openFailed', 'Could not open %s for writing.', fileName);
end
cleanup = onCleanup(@() fclose(fileID));

fprintf(fileID, '*Vertices %d\n', m);
for i = 1:m
    fprintf(fileID, '%d "%s"\n', i, model.mets{i});
end

fprintf(fileID, '*Arcs %d\n', totalEdges);
for i = 1:n
    if ~isActive(i)
        continue
    end
    metPos = find(model.S(:, i) > 0);
    metNeg = find(model.S(:, i) < 0);
    weight = abs(v(i));
    if v(i) > 0
        % forward: substrates (metNeg) -> products (metPos)
        src = metNeg;
        dst = metPos;
    else
        % reverse direction
        src = metPos;
        dst = metNeg;
    end
    for j = 1:length(src)
        for k = 1:length(dst)
            fprintf(fileID, '%d %d %g\n', src(j), dst(k), weight);
        end
    end
end

end

function val = getfield_safe(s, f)
if isstruct(s) && isfield(s, f)
    val = s.(f);
else
    val = NaN;
end
end
