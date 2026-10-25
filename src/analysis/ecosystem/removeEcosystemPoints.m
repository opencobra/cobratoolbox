function eco = removeEcosystemPoints(eco, pointIndex)
% Removes a set of grid points from the analysis of an ecosystem: the points
% are labeled as unfeasible and their qualitative vectors and FVA results
% are deleted. Previous clustering results are reset.
%
% USAGE:
%
%    eco = removeEcosystemPoints(eco, pointIndex)
%
% INPUTS:
%    eco:          (structure) ecosystem structure with feasible points and,
%                  optionally, qualitative vectors (see `ecosystemQualitativeFVA`)
%    pointIndex:   (double or logical) indices of the grid points to remove
%
% OUTPUT:
%    eco:          (structure) updated ecosystem structure
%
% EXAMPLE:
%
%    % remove points with null community growth or a single member
%    toRemove = eco.points(:, 2) == 0 | eco.pfractions(:, 1) == 1 | eco.pfractions(:, 1) == 0;
%    eco = removeEcosystemPoints(eco, toRemove);
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

if nargin < 2
    error('eco and pointIndex must be provided.');
end
if ~isstruct(eco) || ~isfield(eco, 'points') || ~isfield(eco, 'feasiblePoints')
    error('eco must be an ecosystem structure with a grid.');
end
if isempty(eco.feasiblePoints)
    error('Feasible points have not been computed.');
end
nPoints = size(eco.points, 1);
if islogical(pointIndex)
    if numel(pointIndex) ~= nPoints
        error('A logical pointIndex must have one element per grid point.');
    end
    pointIndex = find(pointIndex);
end
if ~isnumeric(pointIndex) || any(pointIndex < 1) || any(pointIndex > nPoints)
    error('pointIndex contains invalid indices.');
end

eco.feasiblePoints(pointIndex) = false;
if isfield(eco, 'qualPointIndex') && ~isempty(eco.qualPointIndex)
    keep = ~ismember(eco.qualPointIndex, pointIndex);
    eco.qualPointIndex = eco.qualPointIndex(keep);
    if ~isempty(eco.qualVectors)
        eco.qualVectors = eco.qualVectors(keep, :);
    end
    if isfield(eco, 'fvaResults') && ~isempty(eco.fvaResults)
        eco.fvaResults = eco.fvaResults(keep, :, :);
    end
end
eco.clusters = [];
eco.k = [];
end
