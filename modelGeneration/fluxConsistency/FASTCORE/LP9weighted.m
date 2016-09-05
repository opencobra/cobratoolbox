function V = LP9weighted( W, K, P, model, epsilon )

% W are n x 1 nonnegative weights (NOTE: it penalizes high weights)

scalingfactor = 1e5;

V = [];
if isempty(P) || isempty(K)
    return;
end

np = numel(P);
nk = numel(K);
[m,n] = size(model.S);

% x = [v;z]

% objective
f = [zeros(1,n), ones(1,np)];

% equalities
Aeq = [model.S, sparse(m,np)];
beq = zeros(m,1);

% inequalities
Ip = sparse((1:np)',P(:),W(P),np,n);
Ik = sparse((1:nk)',K(:),1,nk,n);
Aineq = [[Ip, -speye(np)]; ...
         [-Ip, -speye(np)]; ...
         [-Ik, sparse(nk,np)]];
bineq = [zeros(2*np,1); -ones(nk,1)*epsilon*scalingfactor];

% bounds
lb = [model.lb; zeros(np,1)] * scalingfactor;
ub = [model.ub; max(abs(model.ub(P)),abs(model.lb(P)))] * scalingfactor;

x = cplexlp(f,Aineq,bineq,Aeq,beq,lb,ub);
%fval = f*x

V = x(1:n);
