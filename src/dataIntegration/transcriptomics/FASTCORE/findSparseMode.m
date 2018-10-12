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
%    epsilon:     Parameter (default: 1e-4; see `Vlassis et al` for more details)
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

    if singleton
      [V, basis] = LP7(J(1), model, LPproblem, epsilon, basis);
    else
      [V, basis] = LP7(J, model, LPproblem, epsilon, basis);
    end

    K = intersect(J, find(V >= 0.99*epsilon));

    if isempty(K)
      return;
    end

    V = LP9( K, P, model, LPproblem, epsilon );
    Supp = find(abs(V) >= 0.99*epsilon);
