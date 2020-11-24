function [v, basis] = LP3(J, model, LPproblem, basis)
% Implementation of LP-3 for input set J (see FASTCORE paper)
%
% USAGE:
%
%    [v, basis] = LP3(J, model, basis)
%

% .. Authors
%       - Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013 LCSB / LSRU, University of Luxembourg
%       - Ronan Fleming      02/12/14 solveCobraLP compatible
%       - 2020 Ronan Fleming, Cv<=d compatible

[m,n] = size(model.S);
[m2,n2] = size(LPproblem.A);
%

%reactions irreversible in the reverse direction
Ir = model.ub<=0;
%flip direction of reactions irreversible in the reverse direction
LPproblem.A(:,Ir) = -LPproblem.A(:,Ir);
tmp = LPproblem.ub(Ir);
LPproblem.ub(Ir) = -LPproblem.lb(Ir);
LPproblem.lb(Ir) = -tmp;

% objective
f = zeros(n2,1);
f(J) = -1;

% S*v = b and C *v<= d if present
Aeq = LPproblem.A;
beq = LPproblem.b;

% bounds
lb = LPproblem.lb;
ub = LPproblem.ub;

basis=[];

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
v=solution.full(1:n);

%flip back the direction of reactions irreversible in the reverse direction
v(Ir)=-v(Ir);


