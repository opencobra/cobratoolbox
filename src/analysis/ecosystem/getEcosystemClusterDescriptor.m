function descriptorTable = getEcosystemClusterDescriptor(repValues, rxnIds, clusterId)
% Describes what makes a cluster of grid points different from the other
% clusters. For each reaction whose representative state in the selected
% cluster is defined (not NaN), it counts the number of clusters in which the
% reaction has a different representative state (NaN included). Reactions
% are sorted by this count in descending order.
%
% USAGE:
%
%    descriptorTable = getEcosystemClusterDescriptor(repValues, rxnIds, clusterId)
%
% INPUTS:
%    repValues:         (double) nRxns x k matrix of representative state
%                       codes (see `getEcosystemClusterReactionValues`)
%    rxnIds:            (cell array) reaction IDs of the rows of repValues
%    clusterId:         (double or string) cluster to describe, e.g. 14 or 'c14'
%
% OUTPUT:
%    descriptorTable:   (table) table with reactions as rows and variables
%                       `status` (label of the representative state in the
%                       cluster) and `diff` (number of clusters with a
%                       different representative state; NaN when the state
%                       in the cluster is not defined)
%
% EXAMPLE:
%
%    [~, repValues, rxnIds] = getEcosystemClusterReactionValues(eco, 'thr', 0.8);
%    descriptorTable = getEcosystemClusterDescriptor(repValues, rxnIds, 'c14');
%
% NOTE:
%
%    Equivalent to the function `get_cluster_descriptor` defined in the
%    notebook `sup_mat_multiple_bioleaching.ipynb`.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

if nargin < 3
    error('repValues, rxnIds and clusterId must be provided.');
end
if ~isnumeric(repValues)
    error('repValues must be a numeric matrix.');
end
if ~iscellstr(rxnIds) || numel(rxnIds) ~= size(repValues, 1)
    error('rxnIds must be a cell array with one ID per row of repValues.');
end
if ischar(clusterId) || isstring(clusterId)
    clusterId = str2double(regexprep(char(clusterId), '^c', ''));
end
if ~isnumeric(clusterId) || isnan(clusterId) || clusterId < 1 || clusterId > size(repValues, 2)
    error('Invalid cluster ID.');
end

nRxns = size(repValues, 1);
diffCount = NaN(nRxns, 1);
for r = 1:nRxns
    value = repValues(r, clusterId);
    if ~isnan(value)
        row = repValues(r, :);
        diffCount(r) = sum(isnan(row) | row ~= value);
    end
end
status = qualitativeStateLabels(repValues(:, clusterId));
% sort by diff in descending order (NaN at the end)
sortKey = diffCount;
sortKey(isnan(sortKey)) = -Inf;
[~, order] = sort(sortKey, 'descend');
statusName = sprintf('status_c%d', clusterId);
descriptorTable = table(status(order), diffCount(order), 'VariableNames', {statusName, 'diff'}, ...
    'RowNames', rxnIds(order));
end
