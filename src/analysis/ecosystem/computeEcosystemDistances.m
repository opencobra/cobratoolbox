function D = computeEcosystemDistances(Z, distanceMetric)
% Computes the matrix of pairwise distances between the rows of a matrix
% (e.g. the qualitative flux vectors of the points of an ecosystem grid),
% without requiring the Statistics and Machine Learning Toolbox. The
% Jaccard and Hamming distances are identical to those of
% `scipy.spatial.distance.pdist` (used by the Python implementation of
% Jiménez et al., 2023).
%
% USAGE:
%
%    D = computeEcosystemDistances(Z, distanceMetric)
%
% INPUT:
%    Z:                (double) n x m matrix (one vector per row)
%
% OPTIONAL INPUT:
%    distanceMetric:   (string) 'jaccard', 'hamming', 'euclidean' or
%                      'cityblock' (Default = 'jaccard')
%
% OUTPUT:
%    D:                (double) n x n symmetric matrix of distances
%
% EXAMPLE:
%
%    D = computeEcosystemDistances(eco.qualVectors, 'jaccard');
%
% NOTE:
%
%    Jaccard: fraction of coordinates that differ among the coordinates
%    where at least one of the two vectors is non-zero (0 for two null
%    vectors). Hamming: fraction of coordinates that differ. For matrices
%    with few distinct values (e.g. qualitative states), the Jaccard and
%    Hamming distances are computed with matrix products of indicator
%    matrices, which count coordinates exactly.
%
% .. Author: - Sebastián N. Mendoza, 21/10/2026

if nargin < 1 || ~(isnumeric(Z) || islogical(Z)) || ~ismatrix(Z)
    error('Z must be a numeric matrix.');
end
if nargin < 2 || isempty(distanceMetric)
    distanceMetric = 'jaccard';
end
if ~ischar(distanceMetric) || ~any(strcmpi(distanceMetric, {'jaccard', 'hamming', 'euclidean', 'cityblock'}))
    error('distanceMetric must be ''jaccard'', ''hamming'', ''euclidean'' or ''cityblock''.');
end
distanceMetric = lower(distanceMetric);
Z = double(Z);
if any(isnan(Z(:)))
    error('Z must not contain NaN values.');
end
[n, m] = size(Z);
values = unique(Z(:));
maxValuesForProducts = 50;

switch distanceMetric
    case {'jaccard', 'hamming'}
        if numel(values) <= maxValuesForProducts
            % number of coordinates with the same value in both vectors
            % (non-zero values only for jaccard)
            equalCount = zeros(n);
            for v = values(:)'
                if v == 0 && strcmp(distanceMetric, 'jaccard')
                    continue
                end
                indicator = double(Z == v);
                equalCount = equalCount + indicator * indicator';
            end
            if strcmp(distanceMetric, 'jaccard')
                % coordinates where at least one vector is non-zero
                nonZero = double(Z ~= 0);
                nonZeroCount = sum(nonZero, 2);
                unionCount = nonZeroCount + nonZeroCount' - nonZero * nonZero';
                D = (unionCount - equalCount) ./ unionCount;
                D(unionCount == 0) = 0;
            else
                D = (m - equalCount) / m;
            end
        else
            D = zeros(n);
            for i = 1:n
                unequal = Z ~= Z(i, :);
                if strcmp(distanceMetric, 'jaccard')
                    nonZero = Z ~= 0 | Z(i, :) ~= 0;
                    unionCount = sum(nonZero, 2);
                    D(:, i) = sum(unequal & nonZero, 2) ./ unionCount;
                    D(unionCount == 0, i) = 0;
                else
                    D(:, i) = sum(unequal, 2) / m;
                end
            end
        end
    case 'euclidean'
        D = zeros(n);
        for i = 1:n
            D(:, i) = sqrt(sum((Z - Z(i, :)) .^ 2, 2));
        end
    case 'cityblock'
        D = zeros(n);
        for i = 1:n
            D(:, i) = sum(abs(Z - Z(i, :)), 2);
        end
end
% exact symmetry and zero diagonal
D = triu(D, 1);
D = D + D';
end
