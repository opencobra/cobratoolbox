function V = LP7( J, model, epsilon )
%
% V = LP7( J, model, epsilon )
%
% CPLEX implementation of LP-7 for input set J (see FASTCORE paper)

% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg

nj = numel(J);
[m,n] = size(model.S);

% x = [v;z]

% objective
f = -[zeros(1,n), ones(1,nj)];

% equalities
Aeq = [model.S, sparse(m,nj)];
beq = zeros(m,1);

% inequalities
Ij = sparse(nj,n); 
Ij(sub2ind(size(Ij),(1:nj)',J(:))) = -1;
Aineq = sparse([Ij, speye(nj)]);
bineq = zeros(nj,1);

% bounds
lb = [model.lb; zeros(nj,1)];
ub = [model.ub; ones(nj,1)*epsilon];

x = cplexlp(f,Aineq,bineq,Aeq,beq,lb,ub);

V = x(1:n);
