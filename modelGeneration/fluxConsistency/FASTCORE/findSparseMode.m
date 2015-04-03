<<<<<<< HEAD
function Supp = findSparseMode( J, P, singleton, model, epsilon, orig )
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

if singleton
  V = LP7( J(1), model, epsilon, orig );
else
  V = LP7( J, model, epsilon, orig );
end

K = intersect( J, find(V >= 0.99*epsilon) );   

if isempty( K ) 
  return;
end

V = LP9( K, P, model, epsilon, orig );

Supp = find( abs(V) >= 0.99*epsilon );
=======
function Supp = findSparseMode( J, P, singleton, model, epsilon )
% Supp = findSparseMode( J, P, singleton, model, epsilon )
% Finds a mode that contains as many reactions from J and as few from P
% Returns its support, or [] if no reaction from J can have flux above epsilon
%
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg

Supp = [];
% J is the set of reactions for which card(v) is maximized
if isempty( J )
    return;
end
%Fastcore first tests the irreversible reactions then the reversible ones.
%If reversible reactions of set J have an absolute flux below epsilon,
%the sign of the reversible reactions in set J is flipped and
%eventually card(v) of the reamining reactions in J is maximized one by one
%in the singleton step.
if singleton
    %V is the flux vector that approximately maximizes card(v)
    %for the set of reactions in J
    V = LP7( J(1), model, epsilon ); %Maximises card(v) for the 1st
    %element in J
else
    V = LP7( J, model, epsilon ); %Maximises card(v) for all
    %elements in J
end
%K is the set of reactions having a flux above epsilon
K = intersect( J, find(V >= 0.99*epsilon) );

if isempty( K )
    return;
end

V = LP9( K, P, model, epsilon );%Minimizes the number of additional reactions
%from the set of penalized reactions P that are required for set
%K to carry a flux

Supp = find( abs(V) >= 0.99*epsilon );
>>>>>>> d5562420a822295f562c1cdf458cf5ebac0d69a0
