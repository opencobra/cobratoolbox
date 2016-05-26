function A = fastcore(C, model, epsilon, printLevel) 
% A = fastcore( C, model, epsilon )
% The FASTCORE algorithm for context-specific metabolic network reconstruction
% Input C is the core set, and output A is the reconstruction
%
% INPUT
% C             indices of reactions in cobra model that are part of the
%               core set of reactions
% model         cobra model structure containing the fields
%   S           m x n stoichiometric matrix    
%   lb          n x 1 flux lower bound
%   ub          n x 1 flux uppper bound
%   rxns        n x 1 cell array of reaction abbreviations
% 
% epsilon       {1e-4} smallest flux that is considered nonzero 
%
% printLevel    0 = silent, 1 = summary, 2 = debug
%
% OUTPUT
% A             indices of reactions in the new model 
%
%
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg

tic

N = 1:numel(model.rxns);
%reactions assumed to be irreversible in forward direction
I = find(model.lb>=0);

A = [];
flipped = false;
singleton = false;  

% start with I
J = intersect( C, I ); fprintf('|J|=%d  ', length(J));
P = setdiff( N, C);
[Supp, basis] = findSparseMode( J, P, singleton, model, epsilon);
if ~isempty( setdiff( J, Supp ) ) 
  fprintf ('fastcore.m Error: Inconsistent irreversible core reactions.\n');
  return;
end
A = Supp;  fprintf('|A|=%d\n', length(A));
% J is the set of irreversible reactions
J = setdiff( C, A ); fprintf('|J|=%d  ', length(J));

% main loop     
while ~isempty( J )
    P = setdiff( P, A);
    %reuse the basis from the previous solve if it exists
    [Supp, basis] = findSparseMode( J, P, singleton, model, epsilon, basis);
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
                fprintf('\n fastcore.m Error: Global network is not consistent.\n');
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

