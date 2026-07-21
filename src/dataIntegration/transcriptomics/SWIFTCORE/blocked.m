function result = blocked(S, rev, solver)
% blocked finds all the irreversible blocked reactions and is utilized in swiftcc
%
% USAGE:
%
%    result = blocked(S, rev, solver)
%   
% INPUTS:
%    S:         the associated sparse stoichiometric matrix
%    rev:       the 0-1 vector with 1's corresponding to the reversible reactions
%    solver:    the LP solver to be used; the currently available options are
%               'gurobi', 'linprog', and 'cplex' with the default value of 
%               'linprog'. It fallbacks to the COBRA LP solver interface if 
%               another supported solver is called.
%
% OUTPUT:
%    result:    the result returned by the LP solver; among the last n entries, 
%               all the -1 entries are blocked, and the other entries are zero.
%               The first m entries are its fictitious metabolite certificate.
%
% .. Authors:
%       - Mojtaba Tefagh, Stephen P. Boyd, 2019, Stanford University

    [m, n] = size(S);
    irev = m + find(rev == 0);
    model.obj = zeros(m+n, 1);
    model.obj(irev) = 1;
    model.A = [S.', -speye(n)];
    model.sense = repmat('=', n, 1);
    model.sense(rev == 0) = '<';
    model.rhs = zeros(n, 1);
    model.lb = [-Inf(m, 1); zeros(n, 1)];
    model.lb(irev) = -1;
    model.ub = [Inf(m, 1); zeros(n, 1)];
    % Route the LP through the COBRA solver abstraction so swiftcc honours
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
end