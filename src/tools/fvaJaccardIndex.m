function J = fvaJaccardIndex(minFlux,maxFlux)
% Compare flux ranges by computing the Jaccard index
% 
% J = fvaJaccardIndex(minFlux,maxFlux);
% 
% INPUTS
% minFlux ... An n x k matrix of minimum fluxes through n reactions in k
%             different constraint-based models.
% maxFlux ... An n x k matrix of maximum fluxes through n reactions in k
%             different constraint-based models.
% 
% OUTPUTS
% J       ... An n x 1 vector of Jaccard indices, defined as the
%             intersection divided by the union of all k flux ranges
% 
% Hulda S. Haraldsdottir, 2016/08/22
fvaIntersect = min(maxFlux,[],2) - max(minFlux,[],2); % Compute intersection
fvaUnion = max(maxFlux,[],2) - min(minFlux,[],2); % Compute union
fvaIntersect(fvaIntersect < 0) = 0; % Gap between flux ranges
fvaIntersect(fvaUnion < 1e-6) = 1; % Fixed flux value
fvaUnion(fvaUnion < 1e-6) = 1; % Fixed flux value
J = fvaIntersect./fvaUnion; % Jaccard indices
end