function V = LP9weighted(W, K, P, model, LPproblem, epsilon)

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