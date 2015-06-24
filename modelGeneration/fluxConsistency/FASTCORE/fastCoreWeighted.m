function A = fastCoreWeighted( C, model, epsilon ) 
%
% A = fastCoreWeighted( C, model, epsilon ) 
% Based on: "The FASTCORE algorithm for context-specific metabolic network reconstruction", Vlassis et
% al., 2013, PLoS Comp Biol.
%
% INPUT 
% C        List of reaction numbers corresponding to the core set
% model    Model structure, including a weight vector (model.weight) for
%          each reaction
% epsilon  Parameter (default: 1e-4; see Vlassis et al for more details)
%
% OUTPUT
% A        A most compact model consistent with the applied constraints and
%          containing the desired core set reactions (as given in C)
% 
% Dec 2013
% Ines Thiele, http://thielelab.eu

if ~exist('epsilon','var')
    epsilon = 1e-4;
end

tic

model_org = model;

N = 1:numel(model.rxns);
I = find(model.lb==0);

A = [];
flipped = false;
singleton = false;  

% start with I
J = intersect( C, I ); fprintf('|J|=%d  ', length(J));
P = setdiff( N, C);
Supp = findSparseModeWeighted( J, P, singleton, model, epsilon );
if ~isempty( setdiff( J, Supp ) ) 
  fprintf ('Error: Inconsistent irreversible core reactions.\n');
  return;
end
A = Supp;  fprintf('|A|=%d\n', length(A));
J = setdiff( C, A ); fprintf('|J|=%d  ', length(J));

% main loop     
while ~isempty( J )
    P = setdiff( P, A);
    Supp = findSparseModeWeighted( J, P, singleton, model, epsilon );%findSparseMode
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

