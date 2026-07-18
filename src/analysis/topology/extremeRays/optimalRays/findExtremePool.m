function [x, sol] = findExtremePool(model, obj, printLevel, positive, internal)
% Finds an extreme ray, x, in the left nullspace of the stoichiometric matrix
%
% USAGE:
%
%    [x, sol] = findExtremePool(model, obj, printLevel, positive, internal)
%
% INPUT:
%    model:          COBRA model structure with fields:
%
%                      * .S - `m x n` stoichiometric matrix
%                      * .SConsistentRxnBool - `n x 1` boolean of stoichiometrically consistent reactions (used when `internal` is true)
%
% OPTIONAL INPUTS:
%    obj:            objective coefficient vector (default = random vector sized on `model.S`)
%    printLevel:     verbosity passed to `solveCobraLP` (default = 0)
%    positive:       if true, restrict the ray to non-negative coefficients (default = 0)
%    internal:       if true, restrict `model.S` to `model.SConsistentRxnBool` (default = 0)
%
% OUTPUTS:
%    x:              extreme ray from the left nullspace (`x = sol.full`, entries below `epsilon` set to zero)
%    sol:            solution structure returned by `solveCobraLP(LPProblem)`
%
% .. Author: - Ronan Fleming, 2026


if ~exist('printLevel','var')
    printLevel = 0;
end
if ~exist('positive','var')
    positive = 0;
end
if ~exist('internal','var')
    internal = 0;
end
if ~exist('epsilon','var')
    feasTol = getCobraSolverParams('LP', 'feasTol');
    epsilon=feasTol*10;
end

if internal
    A = model.S(:,model.SConsistentRxnBool)';
else
    A = model.S';
end

[n, m] = size(A);

if ~exist('obj','var')
    obj = rand(m,1);
end

LPProblem.A=sparse([A; ones(1,m)]);
LPProblem.b=[zeros(n,1); 1];
LPProblem.c=obj;
if positive
    LPProblem.lb=zeros(size(LPProblem.A,2),1);
else
    LPProblem.lb=-100*ones(size(LPProblem.A,2),1);
end
LPProblem.ub= 100*ones(size(LPProblem.A,2),1);
LPProblem.osense=-1;
LPProblem.csense(1:size(LPProblem.A,1),1)='E';
sol = solveCobraLP(LPProblem, 'printLevel', printLevel);
x=sol.full;
x(abs(x)<epsilon)=0;
