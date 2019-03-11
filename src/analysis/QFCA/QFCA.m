function [reduced_net, fctable, blocked] = QFCA(model, reduction, varargin)
% QFCA computes the table of flux coupling relations and the list of blocked 
% reactions for a metabolic network specified by its stoichiometric matrix 
% and irreversible reactions and also returns the reduced metabolic network.
%
% USAGE:
%
%    [reduced_net, fctable, blocked] = QFCA(model, reduction [, solver])
%
% INPUTS:
%    model:        the metabolic network with fields:
%                    * .S - the associated sparse stoichiometric matrix
%                    * .rev - the 0-1 indicator vector of the reversible reactions
%                    * .rxns - the cell array of reaction abbreviations
%                    * .mets - the cell array of metabolite abbreviations
%    reduction:    logical indicating whether DCE-induced reductions should be
%                  carried out or not
% 
% OPTIONAL INPUT:
%    solver:    the LP solver to be used; the currently available options are
%               either 'gurobi' or 'linprog' with the default value of 'linprog'
%
% OUTPUTS:
%    reduced_net:    the reduced metabolic network with fields:
%                      * .S - the associated sparse stoichiometric matrix
%                      * .rev - the 0-1 indicator vector of the reversible reactions
%                      * .rxns - cell array of reaction abbreviations
%                      * .mets - cell array of metabolite abbreviations
%    fctable:        the resulting flux coupling matrix; for the choice of entries, 
%                    we use the F2C2 convention for the sake of compatibility. 
%                    The meaning of the entry (i, j) is:
%                      * 0 - uncoupled reactions
%                      * 1 - fully coupled reactions
%                      * 2 - partially coupled reactions
%                      * 3 - reaction i is directionally coupled to reaction j
%                      * 4 - reaction j is directionally coupled to reaction i
%    blocked:        the 0-1 vector with 1's corresponding to the blocked reactions
%
% EXAMPLE:
%
%    % The following code uses QFCA to compute the table of flux coupling relations 
%    % and the list of blocked reactions for the E. coli core model and also returns
%    % the reduced metabolic network.
%    load('ecoli_core_model.mat');
%    [reduced_net, fctable, blocked] = QFCA(model, true, 'linprog');
%
% NOTE:
%
%    The directionallyCoupled function can be utilized as a stand-alone function 
%    to find fictitious metabolite certificates.
%
% .. Authors:
%       - Mojtaba Tefagh, Stephen P. Boyd, 2019, Stanford University

    S = sparse(model.S);
    [m, n] = size(S);
    rev = double(model.rev);
    rxns = model.rxns;
    fprintf('Original number of:\n\tmetabolites = %d;\treactions = %d;\tnonzero elements = %d\n', ...
        m, n, nnz(S));
    fprintf('Original number of:\n\treversible reactions = %d;\tirreversible reactions = %d\n', ...
        sum(rev), n-sum(rev));
    numLP = 0;
    numLE = 0;
    
    %% setting up the LP solver
    if ~isempty(varargin)
        solver = varargin{1};
    else
        solver = 'linprog';
    end
    
    %% identifying the blocked reactions and removing them from the network
    tic;
    [S, metNum, ~] = unique(S, 'rows', 'stable');
    mets = model.mets(metNum);
    numLP = numLP + 1;
    numLE = numLE + 1;
    [S, rev, rxns, blocked] = blockedReac(S, rev, rxns, solver);
    % aggregating all the isozymes
    [~, reacNum, duplicates] = unique([S.', rev], 'rows', 'stable');
    duplicates = duplicates.';
    S = S(:, reacNum);
    rev = rev(reacNum);
    for i = 1:length(reacNum)
        rxns(reacNum(i)) = {strjoin(rxns(duplicates == i), ', ')};
    end
    rxns = rxns(reacNum);
    fullCouplings = reacNum(duplicates);
    % removing the newly blocked reactions
    numLP = numLP + 1;
    numLE = numLE + 1;
    [S, rev, rxns, newlyBlocked] = blockedReac(S, rev, rxns, solver);
    reacNum(newlyBlocked == 1) = [];
    t = toc;
    fprintf('Identifying the blocked reactions and removing them from the network: %.3f\n', t);
    tic;
    [m, n] = size(S);
    fprintf('Reduced number of:\n\tmetabolites = %d;\treactions = %d;\tnonzero elements = %d\n', ...
        m, n, nnz(S));
    
    %% identifying the fully coupled pairs of reactions
    % finding the trivial full coupling relations
    flag = true;
    while flag
        flag = false;
        for i = m:-1:1
            nzcols = find(S(i, :));
            % check to see if the i-th row of S has only 2 nonzero elements
            if length(nzcols) == 2
                n = n-1;
                [S, rev, rxns] = mergeFullyCoupled(S, rev, rxns, nzcols(1), nzcols(2), ...
                    -S(i, nzcols(1))/S(i, nzcols(2)));
                fullCouplings(fullCouplings == reacNum(nzcols(2))) = reacNum(nzcols(1));
                reacNum(nzcols(2)) = [];
                flag = true;
            end
        end
    end
    % finding the rest of full coupling relations
    numLE = numLE + 1;
    [Q, R, P] = qr(S.');
    tol = norm(S, 'fro')*eps(class(S));
    % Z is the kernel of the stoichiometric matrix
    rankS  = sum(abs(diag(R)) > tol);
    Z = Q(:, rankS+1:n);
    X = tril(Z*Z.');
    Y = diag(diag(X).^(-1/2));
    X = Y*X*Y;
    for i = n:-1:2
        % j is the candidate reaction to be fully coupled to reaction i
        [M, j] = max(abs(X(i, 1:i-1)));
        % this is in fact cauchy-schwarz inequality
        if M > 1 - tol
            [S, rev, rxns] = mergeFullyCoupled(S, rev, rxns, j, i, sign(X(i, j))*Y(j, j)/Y(i, i));
            fullCouplings(fullCouplings == reacNum(i)) = reacNum(j);
            reacNum(i) = [];
        end
    end
    S(:, rev == -1) = -S(:, rev == -1);
    rev(rev == -1) = 0;
    [p, ~, ~] = find(P);
    S = S(p(1:rankS), :);
    mets = mets(p(1:rankS));
    t = toc;
    fprintf('Finding the full coupling relations: %.3f\n', t);
    tic;
    [m, n] = size(S);
    fprintf('Reduced number of:\n\tmetabolites = %d;\treactions = %d;\tnonzero elements = %d\n', ...
        m, n, nnz(S));
    
    %% computing the set of fully reversible reactions
    numLP = numLP + 1;
    numLE = numLE + 1;
    [~, ~, ~, prev] = blockedReac(S(:, rev == 1), rev(rev == 1), rxns(rev == 1), solver);
    % marking the Frev set by 2 in the rev vector
    rev(rev == 1) = 2 - prev;
    t = toc;
    fprintf('Correcting the reversibility types: %.3f\n', t);
    tic;
    
    %% QFCA finds the flux coupling coefficients
    k = n;
    reacs = 1:n;
    reactions = false(n, 1);
    A = zeros(n);
    for i = k:-1:1
        if rev(i) ~= 2
            numLP = numLP +1;
            [certificate, result] = directionallyCoupled(S, rev, i, solver);
            dcouplings = result < -0.5;
            dcouplings(i) = false;
            if any(dcouplings)
                %% Irev ---> Irev flux coupling relations
                A(reacs, i) = 3*dcouplings;
                A(i, reacs) = 4*dcouplings.';
                dcouplings(i) = true;
                % correcting the reversibility conditions
                rev(i) = 0;
                % inferring by the transitivity of directional coupling relations
                A(reacs(rev == 1), i) = max(A(reacs(rev == 1), ...
                    reacs(dcouplings)), [], 2);
                A(i, reacs(rev == 1)) = max(A(reacs(dcouplings), ...
                    reacs(rev == 1)), [], 1);
                
                %% Prev ---> Irev flux coupling relations
                if any(A(reacs(rev == 1), i) == 0)
                    numLE = numLE + 1;
                    coupled = false(n, 1);
                    [Q, R, ~] = qr(transpose(S(:, ~dcouplings)));
                    tol = norm(S(:, ~dcouplings), 'fro')*eps(class(S));
                    Z = Q(rev(~dcouplings) == 1 & A(reacs(~dcouplings), i) == 0, ...
                        sum(abs(diag(R)) > tol)+1:end);
                    coupled(~dcouplings & rev == 1 & A(reacs, i) == 0) = diag(Z*Z.') < tol^2;
                    A(reacs(coupled), i) = 3;
                    A(i, reacs(coupled)) = 4;
                    % -1 indicates an uncoupled pair for remembering to skip 
                    % it without any need for further double check later
                    A(reacs(~coupled & rev == 1 & A(reacs, i) == 0), ...
                        reacs(dcouplings)) = -1;
                end
                
                %% metabolic network reductions induced by DCE
                if reduction
                    c = S.'*certificate;
                    S = S + repmat(S(:, i), 1, n)*spdiags(-c/c(i), 0, n, n);
                    S(:, i) = [];
                    rev(i) = [];
                    for j = 1:n
                        if dcouplings(j)
                            rxns(j) = {strjoin([rxns(j), rxns(i)], ', ')};
                        end
                    end
                    rxns(i) = [];
                    reacs(i) = [];
                    % deleting the redundant rows from the stoichiometric matrix
                    numLE = numLE + 1;
                    [~, R, P] = qr(S.');
                    [p, ~, ~] = find(P);
                    rankS  = sum(abs(diag(R)) > tol);
                    S = S(p(1:rankS), :);
                    mets = mets(p(1:rankS));
                    [m, n] = size(S);
                elseif result(i) < 0
                    S(:, i) = -S(:, i);
                end
                reactions(i) = true;
                for j = i+1:k
                    if reactions(j)
                        if all(A(i, reacs(rev == 0 & ~reactions(reacs))) == ...
                                A(j, reacs(rev == 0 & ~reactions(reacs))))
                            A(i, j) = 2;
                            A(j, i) = 2;
                        elseif all(A(i, reacs(rev == 0 & ~reactions(reacs))) ...
                                <= A(j, reacs(rev == 0 & ~reactions(reacs))))
                            A(i, j) = 3;
                            A(j, i) = 4;
                        elseif all(A(i, reacs(rev == 0 & ~reactions(reacs))) ...
                                >= A(j, reacs(rev == 0 & ~reactions(reacs))))
                            A(i, j) = 4;
                            A(j, i) = 3;
                        end
                    end
                end
            end
        end
    end
    % the usage of -1 was temporary and we return to our earlier convention
    A(A == -1) = 0;
    A(logical(eye(k))) = 1;
    t = toc;
    fprintf('Finding the directional and partial coupling relations: %.3f\n', t);
    tic;
    
    %% postprocessing to fill in the flux coupling table for the original 
    % metabolic network from the flux coupling relations for the reduced one
    map = repmat(fullCouplings.', k, 1) == repmat(reacNum, 1, length(duplicates));
    fctable = map.'*A*map;
    t = toc;
    fprintf('Inferring by the transitivity of full coupling relations: %.3f\n', t);
    tic;
    
    %% reaction pairs that become blocked after merging isozymes are fully coupled
    for i = 1:duplicates(end)
        blockedAfterMerging = find(duplicates == i);
        if (length(blockedAfterMerging) > 2 || ...
                (length(blockedAfterMerging) == 2 && newlyBlocked(i) == 0))
            fctable(duplicates == i, :) = 0;
            fctable(:, duplicates == i) = 0;
        elseif length(blockedAfterMerging) == 2 && newlyBlocked(i) == 1
            fctable(blockedAfterMerging(1), blockedAfterMerging(2)) = 1;
            fctable(blockedAfterMerging(2), blockedAfterMerging(1)) = 1;
        end
    end
    fctable(logical(eye(size(fctable)))) = 1;
    t = toc;
    fprintf('Metabolic network reductions postprocessing: %.3f\n', t);
    fprintf('Reduced number of:\n\tmetabolites = %d;\treactions = %d;\tnonzero elements = %d\n', ...
        m, n, nnz(S));
    fprintf('The number of solved:\n\tlinear programs = %d;\tsystems of linear equations = %d\n', ...
        numLP, numLE);
    reduced_net.S = S;
    reduced_net.rev = rev;
    reduced_net.rxns = rxns;
    reduced_net.mets = mets;
end