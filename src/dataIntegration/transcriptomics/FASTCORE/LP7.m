function [V, basis] = LP7( J, model, LPproblem, epsilon, basis)
% CPLEX implementation of LP-7 for input set J (see FASTCORE paper).
% Maximises the number of feasible fluxes in J whose value is at least epsilon
%
% USAGE:
%
%    [V, basis] = LP7( J, model, epsilon, basis)
%
% INPUTS:
%    J:         indicies of irreversible reactions
%    model:     model
%    LPproblem: LP problem
%    epsilon:   tolerance
%
% OUTPUTS:
%    V:         optimal steady state flux vector
%    basis:     basis
%
% .. Authors:
%       - Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013 LCSB / LSRU, University of Luxembourg
%       - Ronan Fleming 17/10/14 Commenting of inputs/outputs/code
%       - Ronan Fleming 02/12/14 solveCobraLP compatible
%       - Thomas Pfau Sep 2018 Handling additional Constraints/variables.

nj = numel(J);
[m,n] = size(model.S);
[m2,n2] = size(LPproblem.A);

% objective
f = -[zeros(n2,1); ones(nj,1)];

% equalities
Aeq = [LPproblem.A, sparse(m2,nj)];
beq = LPproblem.b;

% inequalities
Ij = sparse(nj,n2);
Ij(sub2ind(size(Ij),(1:nj)',J(:))) = -1;
Aineq = sparse([Ij, speye(nj)]);
bineq = zeros(nj,1);

% bounds
lb = [LPproblem.lb; -inf*ones(nj,1)];
ub = [LPproblem.ub; ones(nj,1)*epsilon];

basis=[];

% Set up LP problem
LP7problem.A=[Aeq;Aineq];
LP7problem.b=[beq;bineq];
LP7problem.lb=lb;
LP7problem.ub=ub;
LP7problem.c=f;
LP7problem.osense=1;%minimise
LP7problem.csense = [LPproblem.csense; repmat('L',nj,1)];

if ~exist('basis','var') && 0 %cant reuse basis without size change
    solution = solveCobraLP(LP7problem);
else
    if ~isempty(basis)
        LP7problem.basis=basis;
        solution = solveCobraLP(LP7problem);
    else
        solution = solveCobraLP(LP7problem);
    end
end

if isfield(solution,'basis')
    basis=solution.basis;
else
    basis=[];
end

if solution.stat~=1
    fprintf('%s%s\n',num2str(solution.stat),' = solution.stat')
    fprintf('%s%s\n',num2str(solution.origStat),' = solution.origStat')
    warning('LP solution may not be optimal')
end

x=solution.full;

if ~isempty(x)
    V = x(1:n);
else
    V=nan(n,1);
end

