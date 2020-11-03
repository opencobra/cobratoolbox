function [types, isSecondary] = classifyMoieties(L, S)
% Classifies conserved moieties for a metabolic network
%
% USAGE:
%
%    types = classifyMoieties(L, S)
%
% INPUTS:
%    L:        The `r` x `m` moiety matrix with moiety vectors as columns.
%    S:        The `m` x `n` total stoichiometric matrix.
%
% OUTPUT:
%    types:    an `r` x `1` cell array of with one of the following moiety classifications
%              'Internal' moiety that is also conserved in the open network
%              'Transitive' moiety that is only found in primary metabolites
%              'Integrative' moiety that is not conserved in the open
%               network and found in both primary and secondary metabolites.
%
%
% isSecondary  `m x 1` Boolean vector indicating secondary metabolites
%                      (containing at least one internal conserved moiety')
%
% .. Author: - Hulda S. Haraldsdóttir, June 2015
%              Ronan Fleming, Oct 2020

types = cell(size(L,1),1);

isInternal = ~any(L*S,2); % Internal moieties are conserved in the open network
isSecondary = any(L(isInternal,:),1); % Secondary metabolites contain internal moieties
isTransitive = ~any(L(:,isSecondary),2); % Transitive moieties are only found in primary metabolites
isIntegrative = ~(isTransitive | isInternal); % All other moieties are Integrative

types(isTransitive) = {'Transitive'};
types(isIntegrative) = {'Integrative'};
types(isInternal) = {'Internal'};
