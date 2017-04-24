function modelOut=removeTrivialStoichiometry(model)
% Removes metabolites and reactions corresponding to zero rows and columns
%
% USAGE:
%
%    modelOut=removeTrivialStoichiometry(model)
%
% INPUT:
%    model: Model with metabolites and reactions to remove
%
% OUTPUT:
%    modelOut: Obtained model with removed metabolites and reactions

zeroColBool = ~any(model.S,1)'; %find cols that are all zero
model = removeRxns(model,model.rxns(zeroColBool));


%find rows that are all zero
zeroRowBool = ~any(model.S,2);

removeRxnFlag=1;
modelOut = removeMetabolites(model,model.mets(zeroRowBool),removeRxnFlag);
