function modelConstrained = constrainRxnListAboveBound(model, rxnList, c, d, ineqSense)
% Constrains one (weighted) sum of fluxes to be above a lower bound.
% Appends to existing inequality constraints if they are present
%
% USAGE:
%
%    modelConstrained = constrainRxnListAboveBound(model, rxnList, c, d, ineqSense)
%
% INPUTS:
%    model:               model structure
%    rxnList:             cell array of reaction names
%
% OPTIONAL INPUTS:
%    c:                   `k x 1` vector :math:`c*v \geq d`
%    d:                   `n x 1` vector :math:`c*v \geq d`
%    ineqSense:           `k x 1` inequality sense {'L','G'}
%
% OUTPUT:
%    modelConstrained:    constrained model:
%
%                           * S - Stoichiometric matrix
%                           * b - Right hand side = dx/dt
%                           * C - Inequality constraint matrix
%                           * d - Inequality constraint right hand side
%                             :math:`[S; C] * v {=, \leq, \geq } [dxdt, d]`  

% EXAMPLE:
%
%    rxnList = {'PCHOLP_hs_f', 'PLA2_2_f', 'SMS_f','PCHOLP_hs_b', 'PLA2_2_b', 'SMS_b'};
%    c = [1, 1, 1, 1, 1, 1];
%    d = 10;
%    ineqSense = 'G';
%    modelConstrained = constrainRxnListAboveBound(modelIrrev, rxnList, C, d, ineqSense);

[nMet,nRxn]=size(model.S);

if ~isfield(model,'C')
    model.C=[];
end
if ~isfield(model,'d')
    model.d=[];
end

% Identify the indices of these reactions in the new model
rxnInd = findRxnIDs(model, rxnList);

modelConstrained=model;
nC=size(modelConstrained.C,1);
modelConstrained.C(nC+1, 1:nRxn) = 0;

if ~exist('c', 'var')
    modelConstrained.C(nC+1,rxnInd)=1;
else
    c=columnVector(c)';
    for j=1:length(rxnInd)
        modelConstrained.C(nC+1,rxnInd(j))=c(j);
    end
end

%add the rhs
modelConstrained.d(nC+1,1)=d;

nCsense=length(modelConstrained.csense);
if ~exist('ineqSense', 'var')
    ineqSense='G';
else
    if ~any(strcmp(ineqSense,{'L','G'}))
        error('Inequality sense (ineqSense) must be either less than (''L'') or greater than (''G'')')
    end
end
if isfield(model,'csense')
    %append the inequality sense to the existing constraint sense
    modelConstrained.csense(nCsense+1,1)=ineqSense;
else
    %assume the existing constraint sense is all equalities
    %for S*v = dxdt
    modelConstrained.csense(1:nMet,1)='E';
end

%append the inequality sense to the end of the csense
modelConstrained.csense(nCsense+1,1)=ineqSense;
