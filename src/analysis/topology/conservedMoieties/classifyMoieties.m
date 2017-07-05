function types = classifyMoieties(L, S)
% Classifies conserved moieties for a metabolic network
%
% USAGE:
%
%    types = classifyMoieties(L, S)
%
% INPUTS:
%    L:        The `m x r` moiety matrix with moiety vectors as columns.
%    S:        The `m x n` total stoichiometric matrix.
%
% OUTPUT:
%    types:    an `r x 1` cell array of moiety classifications
%
% .. Author: - Hulda S. Haraldsdóttir, June 2015

types = cell(size(L,2),1);

isInternal = ~any(S'*L,1); % Internal moieties are conserved in the open network
isSecondary = any(L(:,isInternal),2); % Secondary metabolites contain internal moieties
isTransitive = ~any(L(isSecondary,:),1); % Transitive moieties are only found in primary metabolites
isIntegrative = ~(isTransitive | isInternal); % All other moieties are Integrative

types(isTransitive) = {'Transitive'};
types(isIntegrative) = {'Integrative'};
types(isInternal) = {'Internal'};
