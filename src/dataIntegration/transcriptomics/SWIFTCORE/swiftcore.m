function [reconstruction, reconInd, LP] = swiftcore(model, coreInd, weights, tol, reduction, varargin)
% swifcore is an even faster version of fastcore
%
% USAGE:
%
%    [reconstruction, reconInd, LP] = swiftcore(model, coreInd, weights, tol, reduction [, solver])
%
% INPUTS:
%    model:        the metabolic network with fields:
%                    * .S - the associated sparse stoichiometric matrix
%                    * .lb - lower bounds on reaction rates
%                    * .ub - lower bounds on reaction rates
%                    * .rxns - the cell array of reaction abbreviations
%                    * .mets - the cell array of metabolite abbreviations
%    coreInd:      the set of indices corresponding to the core reactions
%    weights:      weight vector for the penalties associated with each reaction
%    tol:          zero-tolerance, i.e., the smallest flux value considered nonzero
%    reduction:    boolean enabling the metabolic network reduction preprocess 
% 
% OPTIONAL INPUT:
%    solver:    the LP solver to be used; the currently available options are
%               'gurobi', 'linprog', and 'cplex' with the default value of 
%               'linprog'. It fallbacks to the COBRA LP solver interface if 
%               another supported solver is called.
%
% OUTPUTS:
%    reconstruction:    the consistent metabolic network reconstructed from the 
%                       core reactions
%    reconInd:          the 0-1 indicator vector of the reactions constituting
%                       the reconstruction
%    LP:                the number of solved LPs
%
% NOTE:
%
%    For the choice of the weight vector, use c*ones(n, 1) where c is an
%    arbitrary constant c > 1 if you have no preference over reactions.
%
% .. Authors:
%       - Mojtaba Tefagh, Stephen P. Boyd, 2019, Stanford University

    S = model.S;
    [m, n] = size(S);
    rev = ones(n, 1);
    rev(model.lb == 0) = 0;
    rev(model.ub == 0) = -1;
    model.ub(rev == -1) = -model.lb(rev == -1);
    model.lb(rev == -1) = 0;
    model.ub = model.ub/norm(model.ub, Inf);
    model.lb = model.lb/norm(model.lb, Inf);
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
                    c = S(i, nzcols(1))/S(i, nzcols(2));
                    % deleting the reaction from the rev, lb, and ub vectors
                    if c < 0
                        if rev(nzcols(2)) ~= 1
                            rev(nzcols(1)) = rev(nzcols(2));
                        end
                        model.lb(nzcols(1)) = max([model.lb(nzcols(1)), -model.lb(nzcols(2))/c]);
                        model.ub(nzcols(1)) = min([model.ub(nzcols(1)), -model.ub(nzcols(2))/c]);
                    else
                        if rev(nzcols(2)) ~= 1
                            rev(nzcols(1)) = -1 - rev(nzcols(2));
                        end
                        model.lb(nzcols(1)) = max([model.lb(nzcols(1)), -model.ub(nzcols(2))/c]);
                        model.ub(nzcols(1)) = min([model.ub(nzcols(1)), -model.lb(nzcols(2))/c]);
                    end
                    rev(nzcols(2)) = [];
                    model.lb(nzcols(2)) = [];
                    model.ub(nzcols(2)) = [];
                    % merging the fully coupled pair of reactions
                    S(:, nzcols(1)) = S(:, nzcols(1)) - c*S(:, nzcols(2));
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
    model.S = S;
    model.rev = rev;
    
    %% the main algorithm
    weights(ismember(reacNum, coreInd)) = 0;
    n_ = length(weights);
    % phase one of unblocking the irreversible reactions
    blocked = zeros(n_, 1);
    LP = 1;
    flux = core(model, blocked, weights, solver);
    weights(abs(flux) > tol) = 0;
    if n == n_
        blocked = ismember(reacNum, coreInd);
        blocked(abs(flux) > tol) = false;
    else
        % identifying the blocked reversible reactions
        [~, D, V] = svds(S(:, weights == 0), 10, 'smallest');
        blocked(weights == 0) = vecnorm(V(:, diag(D) < ...
            norm(S(:, weights == 0), 'fro')*eps(class(S))), Inf, 2) < tol;
    end
    % phase two of unblocking the reversible reactions
    while any(blocked)
        % incrementing the core set until no reversible blocked reaction remains
        blockedSize = sum(blocked);
        LP = LP + 1;
        flux = core(model, blocked, weights, solver);
        weights(abs(flux) > tol) = 0;
        blocked(abs(flux) > tol) = 0;
        % adjust the weights if the number of the blocked reactions is no longer reduced by more than half
        if 2*sum(blocked) > blockedSize
            weights = weights/2;
        end
    end
    reconInd = ismember(fullCouplings, reacNum(weights == 0));
    reconstruction = removeRxns(model, model.rxns(~reconInd));
    reconstruction = removeUnusedGenes(reconstruction);
end