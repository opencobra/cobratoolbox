function [x, output] = findExtremePool(fbaModel, obj, printLevel)
% Finds an extreme ray in the left nullspace of the stoichiometric matrix
%
% USAGE:
%
%    [x, output] = findExtremePool(fbaModel, obj, printLevel)
%
% INPUT:
%    fbaModel:       FBA type model
%
% OPTIONAL INPUT:
%    obj:            default = random vector with size depending on `fbaModel.S`
%    printLevel:     argument for `solveCobraLP` function, default = 0
%
% OUTPUTS:
%    x:              `x = output.full`
%    output:         `output = solveCobraLP(LPProblem)`
A    = fbaModel.S';
[n, m] = size(A);

if nargin < 2
    obj = rand(m,1);
end
if nargin < 3
    printLevel = 0;
end


LPProblem.A=sparse([A; ones(1,m)]);
LPProblem.b=[zeros(n,1); 1];
LPProblem.c=obj;
LPProblem.lb=-100*ones(size(LPProblem.A,2),1);
LPProblem.ub= 100*ones(size(LPProblem.A,2),1);
LPProblem.osense=-1;
LPProblem.csense(1:size(LPProblem.A,1),1)='E';
output = solveCobraLP(LPProblem, 'printLevel', printLevel);
x=output.full;
