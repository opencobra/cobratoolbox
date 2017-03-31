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

% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg
%
% Ronan Fleming, commenting of code and inputs/outputs

if ~exist('printLevel', 'var')
    % For Compatability with the original fastcore syntax
    printLevel = 1;
end

N = 1:numel(model.rxns);

if printLevel > 1
    tic
end

% reactions irreversible in the reverse direction
Ir = find(model.ub <= 0);
% flip direction of reactions irreversible in the reverse direction
model.S(:, Ir) = -model.S(:, Ir);
tmp = model.ub(Ir);
model.ub(Ir) = -model.lb(Ir);
model.lb(Ir) = -tmp;

% all irreversible reactions should only be in the forward direction
I = find(model.lb >= 0);

A = [];
flipped = false;
singleton = false;

% start with I
J = intersect(C, I);

if printLevel > 0
    fprintf('|J|=%d  ', length(J));
end

P = setdiff(N, C);
[Supp, basis] = findSparseMode(J, P, singleton, model, epsilon);

if ~isempty(setdiff(J, Supp))
    fprintf('fastcore.m Error: Inconsistent irreversible core reactions.\n');
    return;
end

A = Supp;
if printLevel > 0
    fprintf('|A|=%d\n', length(A));
end

% J is the set of irreversible reactions
J = setdiff(C, A);
if printLevel > 0
    fprintf('|J|=%d  ', length(J));
end

% main loop
while ~isempty(J)
    P = setdiff(P, A);
    % reuse the basis from the previous solve if it exists
    [Supp, basis] = findSparseMode(J, P, singleton, model, epsilon, basis);
    A = union(A, Supp);
    if printLevel > 0
        fprintf('|A|=%d\n', length(A));
    end
    if ~isempty(intersect(J, A))
        J = setdiff(J, A);
        if printLevel > 0
            fprintf('|J|=%d  ', length(J));
        end
        flipped = false;
    else
        if singleton
            JiRev = setdiff(J(1), I);
        else
            JiRev = setdiff(J, I);
        end
        if flipped || isempty(JiRev)
            if singleton
                error('Global network is not consistent.');
            else
                flipped = false;
                singleton = true;
            end
        else
            model.S(:, JiRev) = -model.S(:, JiRev);
            tmp = model.ub(JiRev);
            model.ub(JiRev) = -model.lb(JiRev);
            model.lb(JiRev) = -tmp;
            flipped = true;
            if printLevel > 0
                fprintf('(flip)  ');
            end
        end
    end
end
if printLevel > 0
    fprintf('|A|=%d\n', length(A));
end

if printLevel > 1
    toc
end
