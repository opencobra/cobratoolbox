function [compTable, compValues, rxnIds] = compareEcosystemClusters(repValues, rxnIds, clusterId1, clusterId2)
% Selects the reactions whose representative qualitative states differ
% between two clusters of grid points. A NaN representative value is
% considered different from any qualitative state (but equal to NaN).
%
% USAGE:
%
%    [compTable, compValues, rxnIds] = compareEcosystemClusters(repValues, rxnIds, clusterId1, clusterId2)
%
% INPUTS:
%    repValues:     (double) nRxns x k matrix of representative state codes,
%                   or a table returned by `getEcosystemClusterReactionValues`
%                   (in that case rxnIds can be empty)
%    rxnIds:        (cell array) reaction IDs of the rows of repValues
%    clusterId1:    (double or string) first cluster, e.g. 3 or 'c3'
%    clusterId2:    (double or string) second cluster, e.g. 4 or 'c4'
%
% OUTPUTS:
%    compTable:     (table) labels of the representative states of the
%                   reactions that change between the two clusters
%    compValues:    (double) nChanging x 2 matrix with the state codes
%    rxnIds:        (cell array) IDs of the reactions that change
%
% EXAMPLE:
%
%    [repTable, repValues, rxnIds] = getEcosystemClusterReactionValues(eco, 'thr', 0.8);
%    compTable = compareEcosystemClusters(repValues, rxnIds, 'c3', 'c4');
%
% NOTE:
%
%    Equivalent to `Ecosystem.compare_clusters` of the Python implementation.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

if nargin < 4
    error('repValues, rxnIds, clusterId1 and clusterId2 must be provided.');
end
if istable(repValues)
    rxnIds = repValues.Properties.RowNames;
    labels = repValues{:, :};
    codes = [-3, -2, -1, 0, 1, 2, 3, 4, 5, 100];
    names = {'-', '--', '-0', '0', '0+', '++', '+', '-+', 'err', 'var'};
    values = NaN(size(labels));
    for i = 1:numel(codes)
        values(strcmp(labels, names{i})) = codes(i);
    end
    repValues = values;
end
if ~isnumeric(repValues)
    error('repValues must be a numeric matrix or a table.');
end
if ~iscellstr(rxnIds) || numel(rxnIds) ~= size(repValues, 1)
    error('rxnIds must be a cell array with one ID per row of repValues.');
end
clusterIds = {clusterId1, clusterId2};
cols = zeros(1, 2);
for i = 1:2
    cid = clusterIds{i};
    if ischar(cid) || isstring(cid)
        cid = str2double(regexprep(char(cid), '^c', ''));
    end
    if ~isnumeric(cid) || isnan(cid) || cid < 1 || cid > size(repValues, 2)
        error('Invalid cluster ID.');
    end
    cols(i) = cid;
end
if cols(1) == cols(2)
    error('The two clusters must be different.');
end
a = repValues(:, cols(1));
b = repValues(:, cols(2));
differ = (isnan(a) ~= isnan(b)) | (~isnan(a) & ~isnan(b) & a ~= b);
compValues = [a(differ), b(differ)];
rxnIds = rxnIds(differ);
names = {sprintf('c%d', cols(1)), sprintf('c%d', cols(2))};
compTable = cell2table(qualitativeStateLabels(compValues), 'VariableNames', names, 'RowNames', rxnIds);
end
