function [Supp, basis] = findSparseMode( J, P, singleton, model, epsilon, basis)
%
% A = findSparseMode( J, P, singleton, model, epsilon, orig )
%
% The findsparseMode function of the FASTCORE algorithm for context-specific
% metabolic network reconstruction to detect a minimal supporting set of reactions
% 
% J         indicies of the reactions for which card(v) is maximized
% P         indicies of penalized reactions
% singleton Indicator whether the algorithm is in a singleton step
% model     cobra model structure containing the fields
%   S         m x n stoichiometric matrix    
%   lb        n x 1 flux lower bound
%   ub        n x 1 flux upper bound
%   rxns      n x 1 cell array of reaction abbreviations
% epsilon   flux threshold
% 
%OPTIONAL INPUT
% orig 	    Indicator whether the original code or COBRA adjusted code 
%           should be used. If original code is requested, CPLEX needs 
%           to be installed (default 0)
%
%OUTPUT
% Supp      Support of the set to be maximized. I.e. the indices of the set of reactions 
%           determined to be needed to activate as many reactions of J as possible
%
% Finds a mode that contains as many reactions from J and as few from P
% Returns its support, or [] if no reaction from J can get flux above epsilon

% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg
%
% Maria Pires Pacheco  27/01/15 Added a switch to select between COBRA code and the original code

if nargin < 6
   orig = 0;
end

Supp = [];
if isempty( J ) 
  return;
end

if ~exist('basis','var')
    basis=[];
end

if singleton
  [V, basis] = LP7( J(1), model, epsilon, basis);
else
  [V, basis] = LP7( J, model, epsilon, basis);
end

K = intersect( J, find(V >= 0.99*epsilon) );   

if isempty( K ) 
  return;
end

V = LP9( K, P, model, epsilon, orig );

Supp = find( abs(V) >= 0.99*epsilon );
