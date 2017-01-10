function [V, basis] = LP7( J, model, epsilon, basis)
% CPLEX implementation of LP-7 for input set J (see FASTCORE paper)
% Maximises the number of feasible fluxes in J whose value is at least
% epsion
%
%INPUT
% J         indicies of irreversible reactions
% model
% epsilon   tolerance
%
%OUTPUT
% V         optimal steady state flux vector


% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg
%
% Ronan Fleming      17/10/14 Commenting of inputs/outputs/code
% Ronan Fleming      02/12/14 solveCobraLP compatible

nj = numel(J);
[m,n] = size(model.S);

% x = [v;z]

% objective
f = -[zeros(n,1); ones(nj,1)];

% equalities
Aeq = [model.S, sparse(m,nj)];
beq = zeros(m,1);

% inequalities
Ij = sparse(nj,n); 
Ij(sub2ind(size(Ij),(1:nj)',J(:))) = -1;
% Ij(sub2ind(size(Ij),(1:nj)',J(:))) = -1/epsilon;
Aineq = sparse([Ij, speye(nj)]);
bineq = zeros(nj,1);

% bounds
lb = [model.lb; -inf*ones(nj,1)];
ub = [model.ub; ones(nj,1)*epsilon];
% ub = [model.ub; ones(nj,1)];

basis=[];
 
if 0
    %quiet
    options = cplexoptimset('cplex');
    options = cplexoptimset(options,'diagnostics','off');
    options.output.clonelog=0;
    options.workdir='~/tmp';
    x = cplexlp(f',Aineq,bineq,Aeq,beq,lb,ub,options);
    if exist('clone1.log','file')
        delete('clone1.log')
    end
    if exist('clone2.log','file')
        delete('clone2.log')
    end

else
    LPproblem.A=[Aeq;Aineq];
    LPproblem.b=[beq;bineq];
    LPproblem.lb=lb;
    LPproblem.ub=ub;
    LPproblem.c=f;
    LPproblem.osense=1;%minimise
    LPproblem.csense(1:size(LPproblem.A,1))='E';
    LPproblem.csense(size(Aeq,1)+1:size(LPproblem.A,1))='L';
    if ~exist('basis','var') && 0 %cant reuse basis without size change
        solution = solveCobraLP(LPproblem);
    else
        if ~isempty(basis)
            LPproblem.basis=basis;
            solution = solveCobraLP(LPproblem);
        else
            solution = solveCobraLP(LPproblem);
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
end

if ~isempty(x)
    V = x(1:n);
else
    V=nan(n,1);
end


