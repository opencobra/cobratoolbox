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
    if strcmp(solver, 'gurobi') % gurobi
        params.outputflag = 0;
        result = gurobi(model, params);
        if ~strcmp(result.status, 'OPTIMAL')
            warning('Optimization is unstable!');
            fprintf('Optimization returned status: %s\n', result.status);
        end
    elseif strcmp(solver, 'linprog') % linprog
        problem.f = model.obj;
        problem.Aineq = model.A(rev == 0, :);
        problem.bineq = model.rhs(rev == 0);
        problem.Aeq = model.A(rev ~= 0, :);
        problem.beq = model.rhs(rev ~= 0);
        problem.lb = model.lb;
        problem.ub = model.ub;
        problem.solver = 'linprog';
        problem.options = optimset('Display', 'off');
        [result.x, result.objval, result.status, ~] = linprog(problem);
        if result.status ~= 1
            warning('Optimization is unstable!');
            fprintf('Optimization returned status: %d\n', result.status);
        end
    elseif strcmp(solver, 'cplex') % cplex
        problem.f = model.obj;
        problem.Aineq = model.A(rev == 0, :);
        problem.bineq = model.rhs(rev == 0);
        problem.Aeq = model.A(rev ~= 0, :);
        problem.beq = model.rhs(rev ~= 0);
        problem.lb = model.lb;
        problem.ub = model.ub;
        [result.x, result.objval, result.status] = cplexlp(problem);
        if result.status ~= 1
            warning('Optimization is unstable!');
            fprintf('Optimization returned status: %d\n', result.status);
        end
    else % COBRA
        model.b = model.rhs;
        model.c = model.obj;
        model.osense = 1;
        model.sense(model.sense == '=') = 'E';
        model.sense(model.sense == '<') = 'L';
        model.csense = model.sense;
        solution = solveCobraLP(model, 'solver', solver);
        result.x = solution.full;
        result.objval = solution.obj;
        result.status = solution.stat;
        if result.status ~= 1
            warning('Optimization is unstable!');
            fprintf('Optimization returned status: %d\n', result.status);
        end
    end
end