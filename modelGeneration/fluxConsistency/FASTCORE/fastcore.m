function A = fastcore( C, model, epsilon , orig) 
%
% A = fastcore( C, model, epsilon )
%
% The FASTCORE algorithm for context-specific metabolic network reconstruction
% Input C is the core set, and output A is the reconstruction
% 
% C         indicies of the core set of reactions
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
% A         Indices of reactions in the input model that have to be included in the 
%           target model (On a consistent COBRA compliant model the target model can 
%           be obtained by the following command:
%           FCmodel = removeRxns(model,setdiff(model.rxns,model.rxns(A)));
%
%
% Please be aware, that tests using the glpk solver have often shown issues while CPLEX 
% worked fine. So if you encounter irreversible core reactions, first try to use a different solver.
%
%
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg
%
% Fast Reconstruction of Compact Context-Specific Metabolic Network Models
% ( Vlassis et al. 2014)   10.1371/journal.pcbi.1003424
%
% Maria Pires Pacheco  27/01/15 Added a switch to select between COBRA code and the original code
tic
if nargin < 4
   orig = 0;
end

model_org = model;

N = 1:numel(model.rxns);
I = find(model.lb==0);

A = [];
flipped = false;
singleton = false;  

% start with I
J = intersect( C, I ); fprintf('|J|=%d  ', length(J));
P = setdiff( N, C);
Supp = findSparseMode( J, P, singleton, model, epsilon, orig );
if ~isempty( setdiff( J, Supp ) ) 
  fprintf ('Error: Inconsistent irreversible core reactions.\n');
  return;
end
A = Supp;  fprintf('|A|=%d\n', length(A));
J = setdiff( C, A ); fprintf('|J|=%d  ', length(J));

% main loop     
while ~isempty( J )
    P = setdiff( P, A);
    Supp = findSparseMode( J, P, singleton, model, epsilon, orig );
    A = union( A, Supp );   fprintf('|A|=%d\n', length(A)); 
    if ~isempty( intersect( J, A ))
        J = setdiff( J, A );     fprintf('|J|=%d  ', length(J));
        flipped = false;
    else
        if singleton
            JiRev = setdiff(J(1),I);
        else
            JiRev = setdiff(J,I);
        end
        if flipped || isempty( JiRev )
            if singleton
                fprintf('\nError: Global network is not consistent.\n');
                return
            else
              flipped = false;
              singleton = true;
            end
        else
            model.S(:,JiRev) = -model.S(:,JiRev);
            tmp = model.ub(JiRev);
            model.ub(JiRev) = -model.lb(JiRev);
            model.lb(JiRev) = -tmp;
            flipped = true;  fprintf('(flip)  ');
        end
    end
end
fprintf('|A|=%d\n', length(A));
toc
