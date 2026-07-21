function [certificate, result] = directionallyCoupled(S, rev, i, solver)
% directionallyCoupled finds all the directionally coupled reactions to i
%
% USAGE:
%
%    [certificate, result] = directionallyCoupled(S, rev, i, solver)
%   
% INPUTS:
%    S:         the associated sparse stoichiometric matrix
%    rev:       the 0-1 vector with 1's corresponding to the reversible reactions
%    i:         the index of reaction to which others are directionally coupled
%    solver:    the LP solver to be used; the currently available options are
%               'gurobi', 'linprog', and otherwise the default COBRA LP solver
%
% OUTPUTS:
%    certificate:    the fictitious metabolite for the positive certificate;
%                    S.'*certificate will be the corresponding directional 
%                    coupling equation
%    result:         the result returned by the LP solver; all the -1 entries
%                    are directionally coupled to reaction i and the other 
%                    entries except i are zero
%
% .. Authors:
%       - Mojtaba Tefagh, Stephen P. Boyd, 2019, Stanford University

    [m, n] = size(S);
    irevIndex = [m+1:m+i-1, m+i+1:m+n];
    irevIndex = irevIndex(rev([1:i-1, i+1:n]) == 0);
    model.obj = zeros(m+n, 1);
    model.obj(irevIndex) = 1;
    model.A = [S.', -speye(n)];
    model.sense = repmat('=', n, 1);
    model.sense(rev == 0) = '<';
    model.rhs = zeros(n, 1);
    model.lb = [-Inf(m, 1); zeros(n, 1)];
    model.lb(m+i) = -Inf;
    model.lb(irevIndex) = -1;
    model.ub = [Inf(m, 1); zeros(n, 1)];
    model.ub(m+i) = Inf;
    % Route the LP through the COBRA solver abstraction so QFCA honours
    % changeCobraSolver (feature 015-solver-spine-hardening). The problem was
    % assembled above in Gurobi-style fields; translate them to the
    % solveCobraLP interface (b/c/osense/csense) and solve.
    model.b = model.rhs;
    model.c = model.obj;
    model.osense = 1;   % minimise, matching the former gurobi/linprog paths
    model.sense(model.sense == '=') = 'E';
    model.sense(model.sense == '<') = 'L';
    model.csense = model.sense;
    if isempty(solver) || any(strcmp(solver, {'gurobi', 'linprog', 'cplex'}))
        % legacy fast-path names (or none): use the configured COBRA LP solver
        solution = solveCobraLP(model);
    else
        % an explicit COBRA solver name was requested
        solution = solveCobraLP(model, 'solver', solver);
    end
    result.x = solution.full;
    result.objval = solution.obj;
    result.status = solution.stat;
    if result.status ~= 1
        warning('Optimization is unstable!');
        fprintf('Optimization returned status: %d\n', result.status);
    end
    certificate = result.x(1:m);
    result = result.x(m+1:end);
end