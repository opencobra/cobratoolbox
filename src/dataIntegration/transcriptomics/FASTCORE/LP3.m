function [V, basis] = LP3(J, model, LPproblem, basis)
% CPLEX implementation of LP-3 for input set J (see FASTCORE paper)
%
% USAGE:
%
%    [V, basis] = LP3(J, model, basis)
%
% .. Authors:
%       - Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013 LCSB / LSRU, University of Luxembourg
%       - Ronan Fleming      02/12/14 solveCobraLP compatible

[m,n] = size(model.S);
[m2,n2] = size(LPproblem.A);
%


% objective
f = zeros(n2,1);
f(J) = -1;

% equalities
Aeq = LPproblem.A;
beq = LPproblem.b;

% bounds
lb = LPproblem.lb;
ub = LPproblem.ub;

basis=[];

% options = cplexoptimset('cplex');
% options = cplexoptimset(options,'diagnostics','off');
% options.output.clonelog=0;
% options.workdir='~/tmp';
% x = cplexlp(f',[],[],Aeq,beq,lb,ub,options);
% if exist('clone1.log','file')
%     delete('clone1.log')
% end
% if exist('clone2.log','file')
%     delete('clone2.log')
% end


LP3problem.A=Aeq;
LP3problem.b=beq;
LP3problem.lb=lb;
LP3problem.ub=ub;
LP3problem.c=f;
LP3problem.osense=1;%minimise
LP3problem.csense = LPproblem.csense;
if ~exist('basis','var') && 0 %cant reuse basis without size change
    solution = solveCobraLP(LP3problem);
else
    if ~isempty(basis)
        LP3problem.basis=basis;
        solution = solveCobraLP(LP3problem);
    else
        solution = solveCobraLP(LP3problem);
    end
end
if isfield(solution,'basis')
    basis=solution.basis;
else
    basis=[];
end
x=solution.full(1:n);

V = x;
