function A = fastcore( C, model, epsilon, printLevel)
% A = fastcore( C, model, epsilon, printLevel)
%
% The FASTCORE algorithm for context-specific metabolic network reconstruction
% Input C is the core set, and output A is the reconstruction
%
% INPUT
% C             n x 1 vector of the indices of the model reactions that
%               must be present in the output model (core set)
% model         cobra model structure containing the fields
%   S           m x n stoichiometric matrix
%   lb          n x 1 flux lower bound
%   ub          n x 1 flux uppper bound
%   rxns        n x 1 cell array of reaction abbreviations
% epsilon       flux threshold
% printLevel    0 = silent, 1 = summary, 2 = debug
%
% OUTPUT
% A             n x 1 boolean vector indicating the flux consistent
%               reactions
%
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg
%
% Fast Reconstruction of Compact Context-Specific Metabolic Network Models
% ( Vlassis et al. 2014)   10.1371/journal.pcbi.1003424

tic

model_org = model;

% Number of reactions
N = 1:numel(model.rxns);

% Reactions annotated to be irreversible (forward direction only)
I = find(model.rev==0);

A = [];
flipped = false;
singleton = false;

% J is the set of reactions for which card(v) is maximized
J = intersect( C, I );
if printLevel>1
    fprintf('|J|=%d  ', numel(J));
end

% P is the set of reactions that is penalized
P = setdiff( N, C);

% Supp is the set of reactions in v with absolute value greater than epsilon
Supp = findSparseMode( J, P, singleton, model, epsilon );
if ~isempty( setdiff( J, Supp ) )
    fprintf ('Error: Inconsistent irreversible core reactions.\n');
    return;
end
A = Supp;
if printLevel>1
    fprintf('|J|=%d  ', numel(J));
    fprintf('|A|=%d\n', length(A));
end


% Main loop in which card(v) is maximized for the set of reversible
% reactions J,
% flipping the sign of the latter if necessary
while ~isempty( J )
    P = setdiff( P, A);
    
    % Supp is the set of reactions in v with absolute value greater than epsilon
    Supp = findSparseMode( J, P, singleton, model, epsilon );
    
    % A is the union of all sets of reactions in v
    % with absolute value greater than epsilon
    A = union( A, Supp );
    
    % Check if reactions of the set J were found among the set of reactions
    % A.
    % If yes, the reactions present in A are removed from J.
    if ~isempty( intersect( J, A ))
        J = setdiff( J, A );
        if printLevel>1
            fprintf('|J|=%d\n', numel(J));
        end
        flipped = false;
        % If no, the irreversible reactions are removed from J. The sign of
        % the reversible reactions are flipped. Card(v) of the reversible
        % is maximized.
        % If reactions of J are still not included, card (v) of each element of
        % J is maximized one by one in the singleton step.
    else
        if singleton
            % card(v) is maximized for the first reversible element of J
            JiRev = setdiff(J(1),I);
        else
            % card(v) is maximized for the reversible elements in J
            JiRev = setdiff(J,I);
        end
        % Change the sign of the reversible reaction(s) if no solution
        % could be found in forward direction.
        if flipped || isempty( JiRev )
            % In this step (flipped and singleton), the remaining reactions
            % were tested individually in both directions, if reactions were
            % still not included in A. These reactions are blocked.
            if singleton
                fprintf('\nError: Global network is not consistent.\n');
                return
            else
                % In this step the whole set of reversible J were tested in
                % both direction (not flipped and flipped). In the next
                % step, each element of J will be tested individually
                flipped = false;
                singleton = true;
            end
        else
            % Changes the sign of the reversible reactions in the S matrix
            model.S(:,JiRev) = -model.S(:,JiRev);
            tmp = model.ub(JiRev);
            model.ub(JiRev) = -model.lb(JiRev);
            model.lb(JiRev) = -tmp;
            flipped = true;
            if printLevel>0
                fprintf('(flip)  ');
            end
        end
    end
end

% Sanity check
% Extract from the input model, a smaller consistent model that includes
% the set of reactions A and check model consistency.
model=removeRxns(model,model.rxns(setdiff(1:numel(model.rxns),A)));
B = fastcc( model, epsilon,0 );% double-check consistency with fastcc
if numel(A)== numel(B);% check if the model size is decreased after the consistency check
    
else
    disp('no solution');
    A=[];
end

toc