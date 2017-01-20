function [V, basis] = LP3(J, model, basis)
% CPLEX implementation of LP-3 for input set J (see FASTCORE paper)

% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg
%
% Ronan Fleming      02/12/14 solveCobraLP compatible

[m,n] = size(model.S);

%


% objective
f = zeros(n,1);
f(J) = -1;

% equalities
Aeq = model.S;
beq = zeros(m,1);

% bounds
lb = model.lb;
ub = model.ub;

basis=[];
 
%quiet
if 0
    options = cplexoptimset('cplex');
    options = cplexoptimset(options,'diagnostics','off');
    options.output.clonelog=0;
    options.workdir='~/tmp';
    x = cplexlp(f',[],[],Aeq,beq,lb,ub,options);
    if exist('clone1.log','file')
        delete('clone1.log')
    end
    if exist('clone2.log','file')
        delete('clone2.log')
    end

else
    LPproblem.A=Aeq;
    LPproblem.b=beq;
    LPproblem.lb=lb;
    LPproblem.ub=ub;
    LPproblem.c=f;
    LPproblem.osense=1;%minimise
    LPproblem.csense(1:size(LPproblem.A,1))='E';
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
    x=solution.full;
end

V = x;