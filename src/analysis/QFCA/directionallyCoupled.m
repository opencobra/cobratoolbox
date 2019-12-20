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
            fprintf('Optimization returned status: %s\n', result.status);
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
            fprintf('Optimization returned status: %s\n', result.status);
        end
    end
    certificate = result.x(1:m);
    result = result.x(m+1:end);
end