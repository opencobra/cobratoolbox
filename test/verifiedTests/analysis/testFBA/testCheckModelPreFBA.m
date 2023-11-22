%test checkModelPreFBA(model,param)
if ~exist('model','var')
    load 'Recon3DModel_301.mat'
end
printLevel=0;

model = findSExRxnInd(model,[],printLevel-1);

N = model.S(:,model.SIntRxnBool);

%Recon3DModel_301, with open external reactions, is flux and 
%stoichiometrically consistent, so check should be positive
isConsistent = checkModelPreFBA(model,param);

assert(isConsistent)
