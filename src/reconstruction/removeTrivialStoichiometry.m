function modelOut=removeTrivialStoichiometry(model)
%remove metabolites and reactions corresponding to zero rows and columns


%find cols that are all zero
zeroColBool = ~any(model.S,1)';
model = removeRxns(model,model.rxns(zeroColBool));


%find rows that are all zero
zeroRowBool = ~any(model.S,2);

removeRxnFlag=1;
modelOut = removeMetabolites(model,model.mets(zeroRowBool),removeRxnFlag);

