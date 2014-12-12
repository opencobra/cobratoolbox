function V = LP9( K, P, model, epsilon )
%
% V = LP9( K, P, model, epsilon )
%
% CPLEX implementation of LP-9 for input sets K, P (see FASTCORE paper)

% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg


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
Ip = sparse(np,n); Ip(sub2ind(size(Ip),(1:np)',P(:))) = 1;
Ik = sparse(nk,n); Ik(sub2ind(size(Ik),(1:nk)',K(:))) = 1;
Aineq = sparse([[Ip, -speye(np)]; ...
                [-Ip, -speye(np)]; ...
                [-Ik, sparse(nk,np)]]);
bineq = [zeros(2*np,1); -ones(nk,1)*epsilon*scalingfactor];

% bounds
lb = [model.lb; zeros(np,1)] * scalingfactor;
ub = [model.ub; max(abs(model.ub(P)),abs(model.lb(P)))] * scalingfactor;

%quiet
options = cplexoptimset('cplex');
options = cplexoptimset(options,'diagnostics','off');
options.output.clonelog=0;
options.workdir='~/tmp';

x = cplexlp(f,Aineq,bineq,Aeq,beq,lb,ub,options);
delete('clone1.log')

V = x(1:n);
