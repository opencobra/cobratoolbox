function [x, output] = findExtremePathway(fbaModel, obj)
% FindExtremeRay : Find an extreme ray
%
%   $Revision: 0.1 $  $Date: 2011/05/01 $
%   
  
A    = fbaModel.S;
[nmet,nrxn] = size(A);

% Convert model to conic form
if ~isfield(fbaModel, 'revRxns')
    if isfield(fbaModel, 'ub') && isfield(fbaModel, 'lb')
        revRxns = fbaModel.lb < 0 & fbaModel.ub > 0;
    else
        error('missing fields: revRxns or ub and lb\n');
    end
else
    revRxns = logical(fbaModel.revRxns);
end
A = [A, -A(:,revRxns)];
[~, n] = size(A);

if nargin < 2
    obj = rand(n,1);
end

% Set required model components
model.A     = sparse([A; ones(1,n)]);
model.obj   = obj;
model.sense = '=';
model.rhs   = [zeros(nmet,1); 1];

% Set optional model components
model.modelsense = 'max';
  
result = gurobi(model);  % Find extreme ray using Gurobi 5.0

x = result.x(1:nrxn);
x(revRxns) = x(revRxns) - result.x(nrxn+1:end);

% Create output structure
output.objval = result.objval;
output.vbasis = result.vbasis;
output.cbasis = result.cbasis;

