function [Supp, basis] = findSparseMode(J, P, singleton, model, LPproblem, epsilon, basis)
% Finds a mode that contains as many reactions from J and as few from P.
% Returns its support, or [] if no reaction from J can get flux above epsilon
%
% USAGE:
%
%    Supp = findSparseMode(J, P, singleton, model, LPproblem, epsilon)
%
% INPUTS:
%    J:           Indicies of irreversible reactions
%    P:           Reactions
%    singleton:   Takes only first instance from `J`, else takes whole `J`
%    model:       Model structure (for reference)
%    LPproblem:   LPproblem structure
%    epsilon:     Parameter (default: getCobraSolverParams('LP', 'feasTol')*100; see `Vlassis et al` for more details)
%
% OPTIONAL INPUT:
%    basis:       Basis
%
% OUTPUTS:
%    Supp:        Support or [] if no reaction from `J` can get flux above epsilon
%    basis:       Basis
%
% .. Authors: - Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013 LCSB / LSRU, University of Luxembourg

Supp = [];
if isempty(J)
    return;
end

if ~exist('basis','var')
    basis=[];
end

if ~exist('epsilon','var')
    epsilon = getCobraSolverParams('LP', 'feasTol')*100;
end

%find a flux vector of maximum cardinality
if singleton
    [v, basis] = LP7(J(1), model, LPproblem, epsilon, basis);
else
    [v, basis] = LP7(J, model, LPproblem, epsilon, basis);
end

%K is the subset of active reactions that are in the irreversible core reaction set (J)
K = intersect(J, find(v >= 0.99*epsilon));

if isempty(K)
    return;
end

%find a flux vector that maintains the activity of any active irreversible core reaction
%(K) yet minimises the activity of any non-core reaction(P).
v = LP10( K, P, v, LPproblem, epsilon );
Supp = find(abs(v) >= 0.99*epsilon);
