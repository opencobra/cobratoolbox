function [reconstruction, LP] = swiftcore(S, rev, coreInd, weights, reduction, varargin)
% swifcore is an even faster version of fastcore
%
% USAGE:
%
%    [reconstruction, LP] = swiftcore(S, rev, coreInd, weights, reduction [, solver])
%
% INPUTS:
%    S:            the associated sparse stoichiometric matrix
%    rev:          the 0-1 vector with 1's corresponding to the reversible reactions
%    coreInd:      the set of indices corresponding to the core reactions
%    weights:      weight vector for the penalties associated with each reaction
%    reduction:    boolean enabling the metabolic network reduction preprocess 
% 
% OPTIONAL INPUT:
%    solver:    the LP solver to be used; the currently available options are
%               'gurobi', 'linprog', and 'cplex' with the default value of 
%               'linprog'. It fallbacks to the COBRA LP solver interface if 
%               another supported solver is called.
%
% OUTPUTS:
%    reconstruction:    the 0-1 indicator vector of the reactions constituting 
%                       the consistent metabolic network reconstructed from the 
%                       core reactions
%    LP:                the number of solved LPs
%
% NOTE:
%
%    For the choice of the weight vector, use c*ones(n, 1) where c is an
%    arbitrary constant c > 1 if you have no preference over reactions.
%
% .. Authors:
%       - Mojtaba Tefagh, Stephen P. Boyd, 2019, Stanford University

    [m, n] = size(S);
    reacNum = (1:n).';
    fullCouplings = (1:n).';
    
    %% setting up the LP solver
    if ~isempty(varargin)
        solver = varargin{1};
    else
        solver = 'linprog';
    end
    
    %% finding the trivial full coupling relations if the reduction flag is true
    while reduction
        reduction = false;
        for i = m:-1:1
            if i <= size(S, 1)
                nzcols = find(S(i, :));
                % check to see if the i-th row of S has only two nonzero elements
                if length(nzcols) == 2
                    % deleting the reaction from the rev vector
                    if rev(nzcols(2)) ~= 1
                        if S(i, nzcols(1))/S(i, nzcols(2)) < 0
                            rev(nzcols(1)) = rev(nzcols(2));
                        else
                            rev(nzcols(1)) = -1 - rev(nzcols(2));
                        end
                    end
                    rev(nzcols(2)) = [];
                    % merging the fully coupled pair of reactions
                    S(:, nzcols(1)) = S(:, nzcols(1)) - S(i, nzcols(1))/S(i, nzcols(2))*S(:, nzcols(2));
                    S(:, nzcols(2)) = [];
                    % deleting the zero rows from the stoichiometric matrix
                    S = S(any(S, 2), :);
                    fullCouplings(fullCouplings == reacNum(nzcols(2))) = reacNum(nzcols(1));
                    coreInd(coreInd == reacNum(nzcols(2))) = reacNum(nzcols(1));
                    weights(nzcols(1)) = weights(nzcols(1)) + weights(nzcols(2));
                    weights(nzcols(2)) = [];
                    reacNum(nzcols(2)) = [];
                    reduction = true;
                end
            end
        end
    end
    S(:, rev == -1) = -S(:, rev == -1);
    rev(rev == -1) = 0;
    
    %% the main algorithm
    weights(ismember(reacNum, coreInd)) = 0;
    % the zero-tolerance parameter is the smallest flux value that is considered nonzero
    tol = norm(S, 'fro')*eps(class(S));
    % phase one of unblocking the irreversible reactions
    n_ = length(weights);
    blocked = zeros(n_, 1);
    LP = 1;
    flux = core(S, rev, blocked, weights, solver);
    weights(abs(flux) > tol) = 0;
    % identifying the blocked reversible reactions
    if n == n_
        blocked = ismember(reacNum, coreInd);
    else
        [Q, R, ~] = qr(transpose(S(:, weights == 0)));
        Z = Q(:, sum(abs(diag(R)) > tol)+1:end);
        blocked(weights == 0) = vecnorm(Z, 2, 2) < tol;
    end
    % phase two of unblocking the reversible reactions
    while any(blocked)
        % incrementing the core set until no reversible blocked reaction remains
        blockedSize = sum(blocked);
        LP = LP + 1;
        flux = core(S, rev, blocked, weights, solver);
        weights(abs(flux) > tol) = 0;
        blocked(abs(flux) > tol) = 0;
        % adjust the weights if the number of the blocked reactions is no longer reduced by more than half
        if 2*sum(blocked) > blockedSize
            weights = weights/2;
        end
    end
    reconstruction = ismember(fullCouplings, reacNum(weights == 0));
end