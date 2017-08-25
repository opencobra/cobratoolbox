function y0 = consistentPotentials(model, printLevel)
% Find a consistent set of potentials for each metabolite in a biochemical
% network, given the directions specified by the bounds on each reaction
% i.e. find y0, such that :math:`S^T y_0 < 0` for a forward reaction and the opposite
% for reverse.
%
% USAGE:
%
%    y0 = consistentPotentials(model, printLevel)
%
% INPUTS:
%    model:         structure with fields:
%
%                     * .S
%                     * .lb
%                     * .ub
%    printLevel:    verbose level
%
% OUTPUT:
%    y0:            consistent set of chemical potentials

if ~isfield(model,'SIntRxnBool')
    %finds the reactions in the model which export/import from the model
    %boundary i.e. mass unbalanced reactions
    %e.g. Exchange reactions
    %     Demand reactions
    %     Sink reactions
    model = findSExRxnInd(model);
end
model.SIntRxnBool(strcmp('Biomass_Ecoli_core_w/GAM',model.rxns))=0;
model.SIntRxnBool(strcmp('ATPM',model.rxns))=0;

if ~exist('printLevel')
    printLevel=0;
end


[nMet,nRxn]=size(model.S);

QPproblem.csense(1:nRxn,1)='E';
QPproblem.csense(model.lb>=0)='G';
QPproblem.csense(model.ub<=0)='L';
bool=false(nRxn,1);
bool(strfind(QPproblem.csense','E'))=1;
bool2=~bool & model.SIntRxnBool;
QPproblem.csense=QPproblem.csense(bool2);

%matrices
QPproblem.A=-model.S(:,bool2)';
QPproblem.b=zeros(nRxn,1);
QPproblem.b=QPproblem.b(bool2,:);

%objective
QPproblem.F=diag(sparse(ones(nMet,1)));
QPproblem.c=zeros(nMet,1);
QPproblem.osense=1;

%simple bounds
QPproblem.lb=-inf*ones(nMet,1);
QPproblem.ub=inf*ones(nMet,1);

if 1
%normalisation
QPproblem.A=[QPproblem.A;ones(1,nMet)];
QPproblem.b=[QPproblem.b;1];%add all potentials to one
QPproblem.csense=[QPproblem.csense ;'E'];
end

%INPUT
% QPproblem Structure containing the following fields describing the QP
% problem to be solved
%  A      LHS matrix
%  b      RHS vector
%  F      F matrix for quadratic objective (must be positive definite)
%  c      Objective coeff vector
%  lb     Lower bound vector
%  ub     Upper bound vector
%  osense Objective sense (-1 max, +1 min)
%  csense Constraint senses, a string containting the constraint sense for
%         each row in A ('E', equality, 'G' greater than, 'L' less than).

%solveCobraQP Solve constraint-based QP problems
%
% solution = solveCobraQP(QPproblem,parameters)
%
% % Solves problems of the type
%
%      min   0.5 x' * F * x + osense * c' * x
%      s/t   lb <= x <= ub
%            A * x  <=/=/>= b
solution = solveCobraQP(QPproblem,'printLevel',printLevel);

%OUTPUT
% solution  Structure containing the following fields describing a QP
%           solution
%  full     Full QP solution vector
%  obj      Objective value
%  solver   Solver used to solve QP problem
%  stat     Solver status in standardized form (see below)
%  origStat Original status returned by the specific solver
%  time     Solve time in seconds
%
%  stat     Solver status in standardized form
%           1   Optimal solution
%           2   Unbounded solution
%           0   Infeasible
%           -1  No solution reported (timelimit, numerical problem etc)

y0=solution.full;
