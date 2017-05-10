function [loops, eqSets, P, P2, cyclicBool] = equivalentSets(model)
% find the stoichiometrically balanced loops and the equivalent sets
%
% INPUT
%     model.S
%     model.lb
%     model.ub
%     model.biomassAbbr


[nMet, nRxns] = size(model.S);
% nullspace of internal stoichiometric matrix
K = nullspaceOfSInternal(model, model.biomassRxnAbbr);

[nRxn, klt] = size(K);

cyclicBool = false(nRxn, 1);
for n = 1:nRxn
    % find reactions with support in internal nullspace
    if nnz(K(n, :)) > 0
        cyclicBool(n) = 1;
    end
end

% take reactions involved in cycles
A = model.S(:, cyclicBool);
% get rid of all zero rows
keepRows = false(nMet, 1);
for m = 1:nMet
    if nnz(A(m, :)) ~= 0
        keepRows(m) = 1;
    end
end
A = A(keepRows, :);

% inequalities
D = sparse(nRxns, nRxns);
irreversibleBool = false(nRxns, 1);
forwardOnlyBool = false(nRxns, 1);
reverseOnlyBool = false(nRxns, 1);
% inequalities for irreversibility
directions = cell(nRxn, 1);
for n = 1:nRxns
    % only take directions for reactions involved in cycles
    if cyclicBool(n)
        directions{n} = 'reversible';
        if model.lb(n) < 0 && model.ub(n) <= 0
            % reverse only
            D(n, n) = -1;
            irreversibleBool(n) = 1;
            reverseOnlyBool(n) = 1;
            directions{n} = 'reverse';
        end
        if model.lb(n) >= 0 && model.ub(n) > 0
            % forward only
            D(n, n) = 1;
            irreversibleBool(n) = 1;
            forwardOnlyBool(n) = 1;
            directions{n} = 'forward';
        end
%         irreversibleBool(n)=0;
    end
end
% downsize to only keep cyclic reactions with constrained direction
D = D(irreversibleBool, cyclicBool);
%
d = sparse(sum(irreversibleBool), 1);
D = []; d = [];  % allow reactions to go in both directions
a = sparse(nMet, 1);

% lrsInput(A,D,filename,positivity,inequality,a,d,sh)
% output a file for lrs to convert an H-representation (half-space) of a
% polyhedron to a V-representation (vertex/ray) via vertex enumeration

% INPUT
% A          matrix of linear equalities A*x=(a)
% D          matrix of linear inequalities D*x>=(d)
% filename   base name of output file


% OPTIONAL INPUT
% positivity {0,(1)} if positivity==1, then positive orthant base
% inequality {0,(1)} if inequality==1, then use two inequalities rather than a single equaltiy
% a          boundry values for matrix of linear equalities A*x=a
% d          boundry values for matrix of linear inequalities D*x>=d
% sh         {(0),1} if sh==1, output a shell script for submitting qsub job
lrsInput(A, D, 'eqSet', 0, 0, a, d)

if isunix
    % call lrs and wait until extreme pathways have been calculated
    [status, result] = unix(['lrs ' pwd '/eqSet_neg_eq.ine > ' pwd '/eqSet_neg_eq.ext']);
end
% reads in P0 which is an nDim by nRay matrix of extreme rays
P1 = lrsOutputReadExt([pwd '/eqSet_neg_eq.ext']);
[nDim, nRay] = size(P1);

% expand it out to size of stoichiometric matrix
P = sparse(nRxn, nRay);
P(cyclicBool, :) = P1;

% double check
if max(max(model.S(:, cyclicBool) * P(cyclicBool, :))) > eps
    error('Extreme pathway(s) not in nullspace of internal stoichiometric matrix')
end

% make a cell array with the stoichiometrically balanced loops
q = 1;
for r = 1:nRay
    for n = 1:nRxn
        if P(n, r) ~= 0
            loops{q, 1} = P(n, r);
            loops{q, 2} = model.rxns{n};
            loops{q, 3} = directions{n};
            loops{q, 4} = printRxnFormula(model, model.rxns{n}, 0);
            q = q + 1;
        end
    end
end

% find the combination of extreme rays that satisfy the inequality
% constraints on fluxes
%  P*w >=  lb
% -P*w >= -ub
% only constrain reactions that are irreversible
D2 = [P(forwardOnlyBool, :); -P(reverseOnlyBool, :)];
[sumIrreversible, nRay] = size(D2);
d2 = zeros(sumIrreversible, 1);

lrsInput([], D2, 'eqSet2', 0, 0, [], d2)
if isunix
    % call lrs and wait until extreme pathways have been calculated
    [status, result] = unix(['lrs ' pwd '/eqSet2_neg_eq.ine > ' pwd '/eqSet2_neg_eq.ext']);
end
% reads in P0 which is an nDim by nRay matrix of extreme rays
P2 = lrsOutputReadExt([pwd '/eqSet2_neg_eq.ext']);
[nRay, nEqSet] = size(P2);

% for each equivalent set, find the net set of reactions that comprise it
E = P * P2;
[nRxn, nEqSet] = size(E);

% make a cell array with the equivalent sets that satisfy the reaction
% directionalities
q = 1;
for r = 1:nEqSet
    for n = 1:nRxn
        if E(n, r) ~= 0
            eqSets{q, 1} = E(n, r);
            eqSets{q, 2} = model.rxns{n};
            eqSets{q, 3} = directions{n};
            eqSets{q, 4} = printRxnFormula(model, model.rxns{n}, 0);
            q = q + 1;
        end
    end
    q = q + 1;
end
