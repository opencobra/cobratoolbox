function flux = core(model, blocked, weights, solver)
% core finds a feasible flux distribution to unblock a given list of blocked 
% reactions and is utilized in swiftcore
%
% USAGE:
%
%    flux = core(S, rev, blocked, weights, solver)
%
% INPUTS:
%    model:        the metabolic network with fields:
%                    * .S - the associated sparse stoichiometric matrix
%                    * .rev - the 0-1 indicator vector of the reversible reactions
%                    * .rxns - the cell array of reaction abbreviations
%                    * .mets - the cell array of metabolite abbreviations
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
    
    S = model.S;
    rev = model.rev;
    [m, n] = size(S);
    dense = zeros(n, 1);
    dense(blocked == 1) = normrnd(0, 1, [sum(blocked), 1]);
    k = sum(weights ~= 0 & rev == 1);
    l = sum(weights ~= 0 & rev == 0);
    problem.obj = [dense; weights(weights~=0&rev==1); weights(weights~=0&rev==0)];
    temp1 = speye(n);
    temp2 = speye(k+l);
    problem.A = [S, sparse(m,k+l); ...
        temp1(weights~=0 & rev==1, :), temp2(rev(weights~=0)==1, :); ...
        -temp1(weights~=0, :), temp2];
    problem.sense = repmat('=', m+2*k+l, 1);
    problem.sense(m+1:m+2*k+l) = '>';
    problem.rhs = zeros(m+2*k+l, 1);
    problem.lb = -Inf(n, 1);
    problem.lb(blocked == 1) = model.lb(blocked == 1);
    problem.lb(weights ~= 0 & rev == 0) = 0;
    if ~any(blocked)
        problem.lb(weights == 0 & rev == 0) = 1;
    end
    problem.lb = [problem.lb; -Inf(k+l, 1)];
    problem.ub = Inf(n, 1);
    problem.ub(blocked == 1) = model.ub(blocked == 1);
    problem.ub = [problem.ub; Inf(k+l, 1)];
    if strcmp(solver, 'gurobi') % gurobi
        params.outputflag = 0;
        result = gurobi(problem, params);
        if strcmp(result.status, 'OPTIMAL')
            flux = result.x(1:n);
        else
            warning('Optimization was stopped with status %s\n', result.status);
        end
    elseif strcmp(solver, 'linprog') % linprog
        problem.f = problem.obj;
        problem.Aineq = -problem.A(m+1:m+2*k, :);
        problem.bineq = problem.rhs(m+1:m+2*k);
        problem.Aeq = problem.A(1:m, :);
        problem.beq = problem.rhs(1:m);
        problem.lb = problem.lb;
        problem.ub = problem.ub;
        problem.solver = 'linprog';
        problem.options = optimset('Display', 'off');
        [result.x, result.objval, result.status, ~] = linprog(problem);
        if result.status == 1
            flux = result.x(1:n);
        else
            warning('Optimization was stopped with status %d\n', result.status);
        end
    elseif strcmp(solver, 'cplex') % cplex
        problem.f = problem.obj;
        problem.Aineq = -problem.A(m+1:m+2*k, :);
        problem.bineq = problem.rhs(m+1:m+2*k);
        problem.Aeq = problem.A(1:m, :);
        problem.beq = problem.rhs(1:m);
        problem.lb = problem.lb;
        problem.ub = problem.ub;
        [result.x, result.objval, result.status] = cplexlp(problem);
        if result.status == 1
            flux = result.x(1:n);
        else
            warning('Optimization was stopped with status %d\n', result.status);
        end
    else % COBRA
        problem.b = problem.rhs;
        problem.c = problem.obj;
        problem.osense = 1;
        problem.sense(problem.sense == '=') = 'E';
        problem.sense(problem.sense == '>') = 'G';
        problem.csense = problem.sense;
        solution = solveCobraLP(problem, 'solver', solver);
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