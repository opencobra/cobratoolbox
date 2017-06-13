function modelConstrained=constrainRxnListAboveBound(model,rxnList,c,d,csense)
%
% Constrains a (weighted) sum of absolute fluxes to be above a lower bound.
%
%
% INPUTS:
%    model:         model structure
%    rxnList:       cell array of reaction names
%
% OPTONAL INPUTS:
%    C:             k x n matrix in C*v>=d
%    d:             n x 1 vector C*v>=d
%    csense:        k x 1 constraint sense
%
% OUTPUT:
%    modelConstrained:  constrained model

[nMet,nRxn]=size(model.S);

% Identify the indices of these reactions in the new model
rxnInd = findRxnIDs(model, rxnList);

modelConstrained=model;
C=sparse(1,nRxn);
if ~exist('c', 'var')
    modelConstrained.C(1,rxnInd)=1;
else
    c=columnVector(c)';
    for j=1:length(rxnInd)
        modelConstrained.C(1,rxnInd(j))=c(j);
    end
end

if exist('d','var')
    modelConstrained.d=d;
else
    modelConstrained.d=0;
end

if exist('csense', 'var')
    if isfield(model,'csense')
        modelConstrained.csense(nMet+1,1)=csense;
    else
        modelConstrained.csense(1:nMet,1)='E';
        modelConstrained.csense(nMet+1,1)=csense;
    end
else
    if isfield(modelConstrained,'csense')
        modelConstrained.csense(nMet+1,1)='G';
    else
        modelConstrained.csense(1:nMet,1)='E';
        modelConstrained.csense(nMet+1,1)='G';
    end
end