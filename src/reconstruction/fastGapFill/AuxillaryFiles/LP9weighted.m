function V = LP9weighted(W, K, P, model, LPproblem, epsilon)
% Solves a weighted variant of the `LP9` problem from the FASTCORE algorithm
% (Vlassis et al., 2013): given an existing LP problem, minimizes the
% weighted L1 norm of the flux through the candidate reactions `P` subject
% to the flux through the core reactions `K` being at least `epsilon`.
%
% USAGE:
%
%    V = LP9weighted(W, K, P, model, LPproblem, epsilon)
%
% INPUTS:
%    W:            `n x 1` nonnegative weight vector (penalizes reactions
%                  in `P` with a higher weight more strongly)
%    K:            Indices of the core reactions required to carry a flux
%                  of at least `epsilon`
%    P:            Indices of the candidate reactions whose weighted flux
%                  magnitude (`W(P) .* v(P)`) is minimized
%    model:        Model structure, with field:
%
%                    * .S - `m x n` stoichiometric matrix (only its size is used)
%    LPproblem:    LP problem structure to extend, with fields:
%
%                    * .A - `m2 x n2` linear constraint matrix
%                    * .b - `m2 x 1` right hand side vector for `A*x = b`
%                    * .lb - `n2 x 1` lower bound vector
%                    * .ub - `n2 x 1` upper bound vector
%                    * .csense - `m2 x 1` character array of constraint senses
%                      (`E`, `G`, or `L`)
%    epsilon:      Minimum required flux through the reactions in `K`
%
% OUTPUT:
%    V:            `n x 1` flux vector solving the weighted LP9 problem,
%                  restricted to the first `n` variables, or an `n x 1`
%                  vector of `NaN` if no solution vector was returned

scalingfactor = 1e5;
% W are n x 1 nonnegative weights (NOTE: it penalizes high weights)

V = [];
if isempty(P) || isempty(K)
    return;
end

np = numel(P);
nk = numel(K);
[m,n] = size(model.S);
[m2,n2] = size(LPproblem.A);

% x = [v;z]

% objective
f = [zeros(1,n2), ones(1,np)];

% equalities
Aeq = [LPproblem.A, sparse(m2,np)];
beq = LPproblem.b;

% inequalities
Ip = sparse((1:np)',P(:),W(P),np,n2);
Ik = sparse((1:nk)',K(:),1,nk,n2);
Aineq = [[Ip, -speye(np)]; ...
         [-Ip, -speye(np)]; ...
         [-Ik, sparse(nk,np)]];
bineq = [zeros(2*np,1); -ones(nk,1)*epsilon*scalingfactor];

% bounds
lb = [LPproblem.lb; zeros(np,1)] * scalingfactor;
ub = [LPproblem.ub; max(abs(LPproblem.ub(P)),abs(LPproblem.lb(P)))] * scalingfactor;

LP9problem.A=[Aeq;Aineq];
LP9problem.b=[beq;bineq];
LP9problem.lb=lb;
LP9problem.ub=ub;
LP9problem.c=columnVector(f);
LP9problem.osense=1;%minimise
LP9problem.csense = [LPproblem.csense; repmat('L',2*np + nk,1)];

solution = solveCobraLP(LP9problem);

if solution.stat~=1
    fprintf('\n%s%s\n',num2str(solution.stat),' = sol.stat')
    fprintf('%s%s\n',num2str(solution.origStat),' = sol.origStat')
    warning('LP solution may not be optimal')
end

x=solution.full;

if ~isempty(x)
    V = x(1:n);
else
    V=ones(n,1)*NaN;
end