function [x, output] = findExtremePathway(fbaModel, obj)
% FindExtremeRay : Find an extreme ray
%
%   $Revision: 0.1 $  $Date: 2011/05/01 $
%   
  

A    = fbaModel.S;
[nmet,nrxn] = size(A);

% Convert model to conic form
if isfield(fbaModel, 'ub') && isfield(fbaModel, 'lb')
    revRxns = fbaModel.lb < 0 & fbaModel.ub > 0;
else
    error('missing fields: revRxns or ub and lb\n');
end

A = [A, -A(:,revRxns)];
[~, n] = size(A);

if nargin < 2
    obj = rand(n,1);
end

% Set required model components
LPProblem = struct();
LPProblem.A = sparse([A; ones(1,n)]);
LPProblem.c   = obj;
LPProblem.csense = repmat('E',nmet+1,1);
LPProblem.b   = [zeros(nmet,1); 1];
% Set optional model components
LPProblem.osense= -1;
LPProblem.lb = 0* ones(n,1);
LPProblem.ub = inf* ones(n,1);
 
result = solveCobraLP(LPProblem);  % Find extreme ray (be aware, that this can easily be a loop of a reversible reaction. 

x = result.full(1:nrxn);
x(revRxns) = x(revRxns) - result.full(nrxn+1:end);

output.objval = result.obj;

