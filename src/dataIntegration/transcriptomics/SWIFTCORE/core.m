function flux = core(S, rev, blocked, weights, solver)
% core finds a feasible flux distribution to unblock a given list of blocked 
% reactions and is utilized in swiftcore
%
% USAGE:
%
%    flux = core(S, rev, blocked, weights, solver)
%
% INPUTS:
%    S:            the associated sparse stoichiometric matrix
%    rev:          the 0-1 vector with 1's corresponding to the reversible reactions
%    blocked:      the 0-1 vector with 1's corresponding to the blocked reactions
%    weights:      weight vector for the penalties associated with each reaction
%    solver:       the LP solver to be used; the currently available options are
%                  'gurobi', 'linprog', and 'cplex' with the default value of 
%                  'linprog'. It fallbacks to the COBRA LP solver interface if 
%                   another supported solver is called.
%
% OUTPUT:
%    flux:    a feasible flux distribution
%
% .. Authors:
%       - Mojtaba Tefagh, Stephen P. Boyd, 2019, Stanford University

    [m, n] = size(S);
    dense = zeros(n, 1);
    dense(blocked == 1) = normrnd(0, 1, [sum(blocked), 1]);
    k = sum(weights ~= 0 & rev == 1);
    l = sum(weights ~= 0 & rev == 0);
    model.obj = [dense; weights(weights~=0&rev==1); weights(weights~=0&rev==0)];
    temp1 = speye(n);
    temp2 = speye(k+l);
    model.A = [S, sparse(m,k+l); ...
        temp1(weights~=0 & rev==1, :), temp2(rev(weights~=0)==1, :); ...
        -temp1(weights~=0,:), temp2];
    model.sense = repmat('=', m+2*k+l, 1);
    model.sense(m+1:m+2*k+l) = '>';
    model.rhs = zeros(m+2*k+l, 1);
    model.lb = -Inf(n, 1);
    model.lb(blocked == 1) = -1;
    model.lb(weights ~= 0 & rev == 0) = 0;
    if ~any(blocked)
        model.lb(weights == 0 & rev == 0) = 1;
    end
    model.lb = [model.lb; -Inf(k+l, 1)];
    model.ub = Inf(n, 1);
    model.ub(blocked == 1) = 1;
    model.ub = [model.ub; Inf(k+l, 1)];
    if strcmp(solver, 'gurobi') % gurobi
        params.outputflag = 0;
        result = gurobi(model, params);
        if strcmp(result.status, 'OPTIMAL')
            flux = result.x(1:n);
        else
            warning('Optimization was stopped with status %s\n', result.status);
        end
    elseif strcmp(solver, 'linprog') % linprog
        problem.f = model.obj;
        problem.Aineq = -model.A(m+1:m+2*k, :);
        problem.bineq = model.rhs(m+1:m+2*k);
        problem.Aeq = model.A(1:m, :);
        problem.beq = model.rhs(1:m);
        problem.lb = model.lb;
        problem.ub = model.ub;
        problem.solver = 'linprog';
        problem.options = optimset('Display', 'off');
        [result.x, result.objval, result.status, ~] = linprog(problem);
        if result.status == 1
            flux = result.x(1:n);
        else
            warning('Optimization was stopped with status %d\n', result.status);
        end
    elseif strcmp(solver, 'cplex') % cplex
        problem.f = model.obj;
        problem.Aineq = -model.A(m+1:m+2*k, :);
        problem.bineq = model.rhs(m+1:m+2*k);
        problem.Aeq = model.A(1:m, :);
        problem.beq = model.rhs(1:m);
        problem.lb = model.lb;
        problem.ub = model.ub;
        [result.x, result.objval, result.status] = cplexlp(problem);
        if result.status == 1
            flux = result.x(1:n);
        else
            warning('Optimization was stopped with status %d\n', result.status);
        end
    else % COBRA
        model.b = model.rhs;
        model.c = model.obj;
        model.osense = 1;
        model.sense(model.sense == '=') = 'E';
        model.sense(model.sense == '>') = 'G';
        model.csense = model.sense;
        solution = solveCobraLP(model, 'solver', solver);
        result.x = solution.full;
        result.objval = solution.obj;
        result.status = solution.stat;
        if result.status == 1
            flux = result.x(1:n);
        else
            warning('Optimization was stopped with status %d\n', result.status);
        end
    end
end