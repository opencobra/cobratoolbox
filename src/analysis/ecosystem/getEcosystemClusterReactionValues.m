function [repTable, repValues, rxnIds] = getEcosystemClusterReactionValues(eco, varargin)
% Computes the representative qualitative state of each reaction in each
% cluster of grid points. The representative state of a reaction in a
% cluster is the qualitative state exhibited by at least a fraction `thr` of
% the points of the cluster (the smallest state code if more than one
% satisfies this condition). If no state reaches the threshold, the
% representative value is NaN.
%
% USAGE:
%
%    [repTable, repValues, rxnIds] = getEcosystemClusterReactionValues(eco, varargin)
%
% INPUT:
%    eco:          (structure) ecosystem structure with qualitative vectors
%                  and clusters (see `clusterEcosystemPoints`)
%
% OPTIONAL INPUTS:
%    thr:          (double) minimum fraction of the points of a cluster with
%                  the same qualitative state for it to be representative
%                  (Default = 0.75)
%    changing:     (logical) report only reactions whose representative
%                  values differ in at least two clusters. NaN is considered
%                  as a different value (Default = true)
%    rxnList:      (cell array) reactions (columns of `eco.qualVectors`)
%                  to consider (Default = `eco.rxn2cluster`)
%
% OUTPUTS:
%    repTable:     (table) table with reactions as rows (RowNames) and
%                  clusters as columns ('c1', 'c2', ...) containing the
%                  labels of the representative states ('NaN' if none)
%    repValues:    (double) nRxns x k matrix with representative state codes
%    rxnIds:       (cell array) reaction IDs of the rows
%
% EXAMPLE:
%
%    repTable = getEcosystemClusterReactionValues(eco, 'thr', 0.8, 'changing', true);
%
% NOTE:
%
%    Equivalent to `Ecosystem.get_cluster_reaction_values` of the Python
%    implementation.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

parser = inputParser();
parser.addRequired('eco', @(x) isstruct(x) && isfield(x, 'qualVectors') && isfield(x, 'clusters'));
parser.addParameter('thr', 0.75, @(x) isnumeric(x) && isscalar(x) && x > 0 && x <= 1);
parser.addParameter('changing', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('rxnList', {}, @(x) iscellstr(x) || isstring(x));
parser.parse(eco, varargin{:});
eco = parser.Results.eco;
thr = parser.Results.thr;
changing = parser.Results.changing;
rxnList = cellstr(parser.Results.rxnList);

if isempty(eco.clusters)
    error('Missing clustering/qualitative FVA results!');
end
if numel(eco.clusters) ~= size(eco.qualVectors, 1)
    error('The number of clustered points differs from the number of qualitative vectors.');
end
rxnIds = eco.rxn2cluster(:);
qualVectors = eco.qualVectors;
if ~isempty(rxnList)
    [found, cols] = ismember(rxnList(:), rxnIds);
    if ~all(found)
        error('Reactions not found in eco.rxn2cluster: %s', strjoin(rxnList(~found), ', '));
    end
    rxnIds = rxnIds(cols);
    qualVectors = qualVectors(:, cols);
end
qualVectors = round(qualVectors);
k = eco.k;
if isempty(k)
    k = max(eco.clusters);
end
nRxns = numel(rxnIds);
repValues = NaN(nRxns, k);
for c = 1:k
    members = eco.clusters == c;
    total = sum(members);
    if total == 0
        continue
    end
    values = qualVectors(members, :);
    for r = 1:nRxns
        [states, ~, idx] = unique(values(:, r));
        counts = accumarray(idx, 1);
        rep = states(counts / total >= thr);
        if ~isempty(rep)
            repValues(r, c) = rep(1);
        end
    end
end

if changing
    isChanging = false(nRxns, 1);
    for r = 1:nRxns
        row = repValues(r, :);
        nUnique = numel(unique(row(~isnan(row)))) + any(isnan(row));
        isChanging(r) = nUnique > 1;
    end
    repValues = repValues(isChanging, :);
    rxnIds = rxnIds(isChanging);
end

clusterNames = strcat('c', arrayfun(@num2str, 1:k, 'UniformOutput', false));
labels = qualitativeStateLabels(repValues);
repTable = cell2table(labels, 'VariableNames', clusterNames, 'RowNames', rxnIds);
end
