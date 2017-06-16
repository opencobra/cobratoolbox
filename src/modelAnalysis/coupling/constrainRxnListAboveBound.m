function modelConstrained = constrainRxnListAboveBound(model, rxnList, c, d, csense)
% Constrains one (weighted) sum of fluxes to be above a lower bound.
% Appends to existing inequality constraints if they are present
%
% USAGE:
%
%    modelConstrained = constrainRxnListAboveBound(model, rxnList, c, d, csense)
%
% INPUTS:
%    model:               model structure
%    rxnList:             cell array of reaction names
%
% OPTIONAL INPUTS:
%    C:                   `k x n` matrix in `C*v>=d`
%    d:                   `n x 1` vector `C*v >= d`
%    csense:              `k x 1` constraint sense
%
% OUTPUT:
%    modelConstrained:    constrained model
%
% EXAMPLE:
%
%    rxnList = {'PCHOLP_hs_f', 'PLA2_2_f', 'SMS_f','PCHOLP_hs_b', 'PLA2_2_b', 'SMS_b'};
%    C = [1, 1, 1, 1, 1, 1];
%    d = 10;
%    csense = 'G';
%    modelConstrained = constrainRxnListAboveBound(modelIrrev, rxnList, C, d, csense);

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
nC=length(model.C);
if ~exist('c', 'var')
    modelConstrained.C(nC+1,rxnInd)=1;
else
    c=columnVector(c)';
    for j=1:length(rxnInd)
        modelConstrained.C(nC+1,rxnInd(j))=c(j);
    end
end

%add the rhs
modelConstrained.d(nC+1)=d;

nCsense=length(modelConstrained.csense);
if exist('csense', 'var')
    if isfield(model,'csense')
        modelConstrained.csense(nCsense+1,1)=csense;
    else
        modelConstrained.csense(1:nMet,1)='E';
        modelConstrained.csense(nCsense+1,1)=csense;
    end
else
    if isfield(modelConstrained,'csense')
        modelConstrained.csense(nCsense+1,1)='G';
    else
        modelConstrained.csense(1:nMet,1)='E';
        modelConstrained.csense(nCsense+1,1)='G';
    end
end
