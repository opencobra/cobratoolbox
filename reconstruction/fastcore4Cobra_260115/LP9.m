function V = LP9( K, P, model, epsilon )
% V = LP9( K, P, model, epsilon )
%
% CPLEX implementation of LP-9 for input sets K, P (see FASTCORE paper)
% Minimizes the number of additional reactions from the set of
% penalized reactions P that are required for set K to carry a flux
%
%INPUT
% K         indicies of the reaction for which card(v) is maximized 
% P         indicies of penalized reactions
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

scalingfactor = 1e5;

V = [];
if isempty(P) || isempty(K)    
    return;
end

np = numel(P);
nk = numel(K);
[m,n] = size(model.S);

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

if 0
    %quiet
    options = cplexoptimset('cplex');
    options = cplexoptimset(options,'diagnostics','off');
    options.output.clonelog=0;
    options.workdir='~/tmp';
    x = cplexlp(f,Aineq,bineq,Aeq,beq,lb,ub,options);
    if exist('clone1.log','file')
        delete('clone1.log')
    end
    save s
else
    LPproblem.A=[Aeq;Aineq];
    LPproblem.b=[beq;bineq];
    LPproblem.lb=lb;
    LPproblem.ub=ub;
    LPproblem.c=f;
    LPproblem.osense=1;%minimise
    LPproblem.csense(1:size(LPproblem.A,1))='E';
    LPproblem.csense(size(Aeq,1)+1:size(LPproblem.A,1))='L';
    solution = solveCobraLP(LPproblem);
    x=solution.full;
end

V = x(1:n);