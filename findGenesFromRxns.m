function [geneList]=findGenesFromRxns(model,reactions)
%findGenesFromRxns make a gene list of the genes that correspond to the 
%selected reactions
%
% [geneList]=findGenesFromRxns(model,reactions)
% 
%INPUTS
% model         COBRA model structure
% reactions     Reactions to find the corresponding genes for
%
%OUTPUT
% geneList      List of genes corresponding to reactions
% Markus Herrgard (7/3/06)

rxnInd = findRxnIDs(model, reactions);
RxnNotInModel = find(rxnInd==0);
if ~isempty(RxnNotInModel)
    for i = 1:length(RxnNotInModel)
        display(cat(2,'The reaction "', reactions{RxnNotInModel(i)},'" is not in your model!'));
        
    end
end
rxnInd(RxnNotInModel) = [];
reactions(RxnNotInModel) = [];
for i = 1:length(rxnInd)
    geneList{i} = model.genes(find(model.rxnGeneMat(rxnInd(i),:)));
end

geneList = columnVector(geneList);
