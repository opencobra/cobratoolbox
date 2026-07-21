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
%       - Adaption to not ignore the general cobra solver by Thomas Pfau.

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


% Route the LP through the COBRA solver abstraction so swiftcore honours
% changeCobraSolver (feature 015-solver-spine-hardening). The problem was
% assembled above in Gurobi-style fields; translate them to the solveCobraLP
% interface (b/c/osense/csense) and solve with the configured LP solver.
problem.b = problem.rhs;
problem.c = problem.obj;
problem.osense = 1;   % minimise, matching the former gurobi/linprog paths
problem.sense(problem.sense == '=') = 'E';
problem.sense(problem.sense == '>') = 'G';
problem.csense = problem.sense;
solution = solveCobraLP(problem);
result.x = solution.full;
result.objval = solution.obj;
result.status = solution.stat;
if result.status == 1
    flux = result.x(1:n);
else
    warning('Optimization was stopped with status %d\n', result.status);
end
end