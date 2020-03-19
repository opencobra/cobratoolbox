function [N, resInfo] = fastSNP(model, varargin)
% Generate a minimal feasible basis for all internal cycles using the method
% Fast-SNP introduced in Saa and Nielson, Bioinformatics, 2016.
%
% USAGE:
%    N = fastSNP(model, 'name', 'value', ...)
%
% INPUTS
%    model:             COBRA model
%
% OPTIONAL INPUTS:
%    parameters:        solver-specific parameter structure or name-value pair argument for solverCobraLP
%
% OUTPUT:
%    N:                 a minimal feasible basis generating all internal cycles
%    resInfo:           structure containing the following used parameters/information:
%                       *.iter:      number of iterations
%                       *.iterTime:  time for each iteration
%                       *.weight:    the random weight vector used for finding new basis vector
%                       *.M:         the bound for minimum/maximum flux 
%                       *.feasTol:   feasibility tolerance for checking solution feasibility
%                       *.tol0:      tolerance for zeros in the basis vector
%                       *.epsilon:   tolerance for a new basis vector not
%                                    lying in the projection of the current null-space,
%                                    i.e. w'(I - P)v >= epsilon or w'(I - P)v <= -epsilon
%
% Siu Hung Joshua Chan 2017 Nov

% feasibility tolerance
feasTol = getCobraSolverParams('LP', 'feasTol');
% parameters required. Not set as input. Should always work well.
M = 1e3;
tol0 = 1e-9;
epsilon = 1e-3;

% exchange reactions
rxnEx = sum(model.S ~= 0, 1) <= 1;

% #metabolites
m = size(model.S, 1);
% #internal reactions
n = size(model.S, 2) - sum(rxnEx);

% LP for finding sparse basis vector
LP = struct();
LP.A = [model.S(:, ~rxnEx),  sparse(m, n); ...  Sv        = 0
        speye(n),           -speye(n); ...       v - |v| <= 0
       -speye(n),           -speye(n); ...      -v - |v| <= 0
        sparse(1, n * 2)];  %           w'(I - P)v       >= eps or   w'(I - P)v <= -eps        
LP.b = [zeros(m + n * 2, 1); 0];
LP.c = [zeros(n, 1); ones(n, 1)];  % minimize sum of absolute fluxes
LP.lb = [-M * (model.lb(~rxnEx) < 0); zeros(n, 1)];
LP.ub = [M .* (model.ub(~rxnEx) > 0); M * (model.ub(~rxnEx) > 0 | model.lb(~rxnEx) < 0)];
LP.osense = 1;  % minimize
LP.csense = [char(['E' * ones(m, 1); 'L' * ones(n * 2, 1)]); 'G'];

% initialize variables for the main loop
weight = rand(1, n);  % weight vector
wP = weight;  % projection vector
N = [];  % null space
iter = 0;  % iteration
iterTime = [];  % time taken
Ntemp = zeros(n, 2);  % basis vectors from the current iteration

while true
    t = tic;
    iter = iter + 1;
    
    % projection
    LP.A(end, 1:n) = wP;
    
    % find v such that w'(I - P)v > 0
    LP.b(end) = epsilon;
    LP.csense(end) = 'G';
    sol = solveCobraLP(LP, varargin{:});
    
    if checkSolFeas(LP, sol) <= feasTol
        % feasible solution found. Save it
        x = sol.full(1:n);
        x(abs(x) < tol0) = 0;
        Ntemp(:, 1) = x / min(abs(x(x ~= 0)));
    end
    
    % find v such that w'(I - P)v < 0
    LP.b(end) = -epsilon;
    LP.csense(end) = 'L';
    sol = solveCobraLP(LP, varargin{:});
    
    if checkSolFeas(LP, sol) <= feasTol
        % feasible solution found. Save it
        x = sol.fulledit(1:n);
        x(abs(x) < tol0) = 0;
        Ntemp(:, 2) = x / min(abs(x(x ~= 0)));
    end
    
    iterTime(iter) = toc(t);
    
    if nnz(Ntemp) == 0
        % no more feasible solution is found. Terminate.
        %fprintf('Basis found. %d reactions in internal cycles.\n', sum(any(N, 2)));
        break;
    end
    
    s = sum(Ntemp ~= 0, 1);
    if s(1) == 0  % if no feasible solution is found in the 1st case
        ix = 2;  % use the 2nd solution
    elseif s(2) == 0  % if no feasible solution is found in the 2nd case
        ix = 1;  % use the 1st solution
    else
        % otherwise use the sparsest solution
        [~, ix] = min(s);
    end
    
    % add the new basis vector into null space
    N(:, end + 1) = Ntemp(:, ix);
    % orthonormal basis
    P_N = orth(N)';
    % I - P (projective matrix)
    wP = weight - (weight * P_N') * P_N;
    % clear Ntemp
    Ntemp(:) = 0;
end

resInfo = struct();
resInfo.iter = iter;
resInfo.iterTime = iterTime;
resInfo.weights = weight;
resInfo.M = M;
resInfo.feasTol = feasTol;
resInfo.tol0 = tol0;
resInfo.epsilon = epsilon;
Nout = zeros(size(model.S, 2), size(N, 2));
Nout(~rxnEx, :) = N;
N = Nout;
end