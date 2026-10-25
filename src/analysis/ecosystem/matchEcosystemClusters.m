function [newClusters, refValues, clusterMap] = matchEcosystemClusters(refValues, refRxnIds, repValues, rxnIds, clusters)
% Relabels the clusters of a scenario so that they match the clusters of a
% reference scenario. A cluster of the scenario receives the label of the
% first reference cluster whose representative qualitative states are equal
% for all the shared reactions with defined (non-NaN) states in both
% clusters. Clusters without a match receive new labels, and their
% representative states are appended to the reference, so that the
% reference can be used to sequentially match several scenarios.
%
% USAGE:
%
%    [newClusters, refValues, clusterMap] = matchEcosystemClusters(refValues, refRxnIds, repValues, rxnIds, clusters)
%
% INPUTS:
%    refValues:     (double) nRef x kRef matrix of representative states of
%                   the reference clusters (see `getEcosystemClusterReactionValues`)
%    refRxnIds:     (cell array) reaction IDs of the rows of refValues
%    repValues:     (double) n x k matrix of representative states of the
%                   clusters of the scenario to relabel
%    rxnIds:        (cell array) reaction IDs of the rows of repValues
%    clusters:      (double) cluster label of each point of the scenario
%
% OUTPUTS:
%    newClusters:   (double) new cluster label of each point
%    refValues:     (double) reference matrix including the new clusters
%    clusterMap:    (double) k x 1 vector with the new label of each original
%                   cluster (NaN for clusters without points)
%
% EXAMPLE:
%
%    [~, refValues, refRxnIds] = getEcosystemClusterReactionValues(ecoRef, 'thr', 0.8);
%    [~, values2, rxnIds2] = getEcosystemClusterReactionValues(eco2, 'thr', 0.8);
%    eco2.clusters = matchEcosystemClusters(refValues, refRxnIds, values2, rxnIds2, eco2.clusters);
%
% NOTE:
%
%    Equivalent to the function `paint_same_cluster` defined in the notebook
%    `sup_mat_multiple_bioleaching.ipynb`.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

if nargin < 5
    error('refValues, refRxnIds, repValues, rxnIds and clusters must be provided.');
end
if ~isnumeric(refValues) || ~iscellstr(refRxnIds) || numel(refRxnIds) ~= size(refValues, 1)
    error('refValues must be a numeric matrix with one row per reaction in refRxnIds.');
end
if ~isnumeric(repValues) || ~iscellstr(rxnIds) || numel(rxnIds) ~= size(repValues, 1)
    error('repValues must be a numeric matrix with one row per reaction in rxnIds.');
end
if ~isnumeric(clusters)
    error('clusters must be a numeric vector.');
end

[common, iRef, iRep] = intersect(refRxnIds, rxnIds, 'stable');
k = size(repValues, 2);
clusterMap = NaN(k, 1);
for cm = 1:size(refValues, 2)
    a = refValues(iRef, cm);
    for c = 1:k
        b = repValues(iRep, c);
        valid = ~isnan(a) & ~isnan(b);
        if all(a(valid) == b(valid)) && isnan(clusterMap(c))
            clusterMap(c) = cm;
        end
    end
end
% clusters without match are appended to the reference
[~, posRep] = ismember(refRxnIds, rxnIds);
for c = unique(clusters(:))'
    if isnan(clusterMap(c))
        newColumn = NaN(numel(refRxnIds), 1);
        newColumn(posRep > 0) = repValues(posRep(posRep > 0), c);
        refValues(:, end + 1) = newColumn; %#ok<AGROW>
        clusterMap(c) = size(refValues, 2);
    end
end
newClusters = clusterMap(clusters);
if numel(common) == 0
    warning('No reactions in common between the reference and the scenario.');
end
end
