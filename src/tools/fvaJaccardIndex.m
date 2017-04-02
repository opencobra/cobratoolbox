function J = fvaJaccardIndex(minFlux, maxFlux)
% Compare flux ranges by computing the Jaccard index
%
% USAGE:
%
%     J = fvaJaccardIndex(minFlux, maxFlux);
%
% INPUTS:
%     minFlux:    An n x k matrix of minimum fluxes through n reactions in k
%                 different constraint-based models (k > 1).
%     maxFlux:    An n x k matrix of maximum fluxes through n reactions in k
%                 different constraint-based models (k > 1).
%
% OUTPUT:
%    J:           An n x 1 vector of Jaccard indices, defined as the
%                 intersection divided by the union of all k flux ranges
%
% .. Authors: 
%       - Hulda S. Haraldsdottir, 2016/08/22
%       - Laurent Heirendt, 2017/02/01

tol = 1e-6; % set the tolerance

if size(minFlux, 2) ~= size(maxFlux, 2)
    error('The size the minFlux and maxFlux matrices is different.');

elseif size(minFlux, 2) <= 1
    error('In order to calculate a Jaccard index, please input flux vectors of more than only one model (k > 1).');

else
    % Compute intersection
    fvaIntersect = min(maxFlux, [], 2) - max(minFlux, [], 2);

    % Compute union
    fvaUnion = max(maxFlux, [], 2) - min(minFlux, [], 2);

    % Gap between flux ranges
    fvaIntersect(fvaIntersect < 0) = 0;

    % Fix flux value
    fvaIntersect(fvaUnion < tol) = 1;

    % Fix flux value
    fvaUnion(fvaUnion < tol) = 1;

    % Calculate Jaccard indices
    J = fvaIntersect ./ fvaUnion;
end

end
