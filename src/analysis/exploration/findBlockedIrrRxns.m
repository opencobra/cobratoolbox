function [blockedIrrRxns, sol, tol] = findBlockedIrrRxns(model, tol, varargin)
% find all blocked irreversible reactions by solving one single LP problem:
%      min sum(z_pos + z_neg)
%      s.t.   Sv = 0
%             lb <= v <= ub
%             v_j + tol*z_pos_j >= tol   for each reaction j with lb_j >= 0
%             v_j - tol*z_neg_j <= -tol  for each reaction j with ub_j <= 0
%
% USAGE:
%    [blockedIrrRxns, fluxes] = findBlockedIrrRxns(model, tol, parameters)
%
% INPUT:
%    model:           COBRA model
%
% OPTIONAL INPUTL
%    tol:             tolerance for zeros (default feasTol*10, use default if the input is smaller)
%    parameters:      COBRA and solver-specific parameters, as a input structure or parameter/value inputs
%
% OUTPUTS:
%    blockedIrrRxns:  cell array of blocked irreversible reactions
%    sol:             solution structure from solveCobraLP
%    tol:             tolerance for zeros used (might be different from the input)

if nargin < 2
    tol = 0;
end

[~, cobraParams, solverVarargin] = parseCobraVarargin(varargin, {}, {}, {}, {'LP'});
% if tol < feasTol * 10, v, z_pos, z_neg = 0 may be feasible due to tolerance
tol = max([tol, cobraParams.LP.feasTol * 10]);

LP = struct();
rxnFwdOnly = find(model.lb >= 0);
rxnRevOnly = find(model.ub <= 0);
[nF, nR] = deal(numel(rxnFwdOnly), numel(rxnRevOnly));
[m, n] = size(model.S);
LP.A = [model.S,                        sparse(m, nF + nR); ...  % Sv = 0
    sparse(1:nF, rxnFwdOnly, 1, nF, n), sparse(1:nF, 1:nF, tol, nF, nF + nR); ...  % v + tol*z_pos >= tol
    sparse(1:nR, rxnRevOnly, 1, nR, n), sparse(1:nR, (nF + 1):(nF + nR), -tol, nR, nF + nR)];  % v - tol*z_neg <= -tol
LP.b = [model.b; tol * ones(nF, 1); -tol * ones(nR, 1)];
LP.c = [zeros(n, 1); ones(nF + nR, 1)];
LP.lb = [model.lb; zeros(nF + nR, 1)];
LP.ub = [model.ub; ones(nF + nR, 1)];
LP.csense = [repmat('E', m, 1); repmat('G', nF, 1); repmat('L', nR, 1)];
LP.osense = 1;

sol = solveCobraLP(LP, solverVarargin.LP{:});

if sol.stat ~= 1
    warning('The model is infeasible')
    blockedIrrRxns = {};
    return
end

blockedIrrRxns = model.rxns((abs(sol.full(1:n)) < tol * (1 - cobraParams.LP.optTol)) & (model.lb >= 0 | model.ub <= 0));


    