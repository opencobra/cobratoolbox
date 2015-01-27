function V = LP7( J, model, epsilon )
% V = LP7( J, model, epsilon )
%
% CPLEX implementation of LP-7 for input set J (see FASTCORE paper)
% Maximizes the number of feasible fluxes in J whose value is at least epsilon
% = maximizing card(V)
%
%INPUT
% J         indicies of the reactions for which card(v) is maximized
% model     cobra model structure containing the fields
%   S         m x n stoichiometric matrix
%   lb        n x 1 flux lower bound
%   ub        n x 1 flux upper bound
%   rxns      n x 1 cell array of reaction abbreviations
%
% epsilon   flux threshold
%
%OUTPUT
% V         optimal steady state flux vector
%
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg
%
% Ronan Fleming      17/10/14 Commenting of inputs/outputs/code
% Ronan Fleming      02/12/14 solveCobraLP compatible

nj = numel(J);
[m,n] = size(model.S);

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

if 0
    %quiet
    options = cplexoptimset('cplex');
    %options = cplexoptimset(options,'diagnostics','off');
    options.output.clonelog=0;
    options.workdir='~/tmp';
    x = cplexlp(f,Aineq,bineq,Aeq,beq,lb,ub,options);
    if exist('clone1.log','file')
        delete('clone1.log')
    end
else
    LPproblem.A=[Aeq;Aineq];
    LPproblem.b=[beq;bineq];
    LPproblem.lb=lb;
    LPproblem.ub=ub;
    LPproblem.c=f;
    LPproblem.osense=1;%minimize
    LPproblem.csense(1:size(LPproblem.A,1))='E';
    LPproblem.csense(size(Aeq,1)+1:size(LPproblem.A,1))='L';
    solution = solveCobraLP(LPproblem);   
    x=solution.full;
end

if ~isempty(x)
    V = x(1:n);
else
    V=nan(n,1);  
end
save V