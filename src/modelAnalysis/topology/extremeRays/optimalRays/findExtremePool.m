function [x, output] = findExtremePool(fbaModel, obj, printLevel)
% find an extreme ray in the left nullspace of the stoichiometric matrix

A    = fbaModel.S';
[n, m] = size(A);

if nargin < 2
    obj = rand(m,1);
end
if nargin < 3
    printLevel = 0;
end

% % old interface to gurobi
% % Set required model components
% model.A     = sparse([A; ones(1,m)]);
% model.obj   = obj;
% model.sense = '=';
% model.rhs   = [zeros(n,1); 1];
% %model.lb    = zeros(m,1);
% 
% % Set optional model components
% model.modelsense = 'max';
% 
% %set parameters
% params.outputflag=printLevel;
% 
% % Find extreme ray using Gurobi 5.0
% result = gurobi(model,params);
% 
% x = result.x;
% 
% % Create output structure
% output.objval = result.objval;
% output.vbasis = result.vbasis;
% output.cbasis = result.cbasis;

LPProblem.A=sparse([A; ones(1,m)]);
LPProblem.b=[zeros(n,1); 1];
LPProblem.c=obj;
LPProblem.lb=-100*ones(size(LPProblem.A,2),1);
LPProblem.ub= 100*ones(size(LPProblem.A,2),1);
LPProblem.osense=-1;
LPProblem.csense(1:size(LPProblem.A,1),1)='E';
output = solveCobraLP(LPProblem);
x=output.full; 
