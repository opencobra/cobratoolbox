function [neighborRxns,neighborGenes,mets] = findNeighborRxns(model,rxn)
%findNeighborRxns Identifies the reactions and the corresponding genes 
%that are adjacent (having a common metabolite) to a reaction of interest.
%Useful for characterizing the network around an orphan reaction.
%
% [neighborRxns,neighborGenes,mets] = findNeighborRxns(model,rxn)
%
%INPUTS
% model         COBRA model structure
% rxn           the target reaction (only 1 for now)
%
%OUTPUTS
% neighborRxns  the neighboring rxns in the network, (having common
%               metabolites)
% neighborGenes the genes associated with the neighbor rxns
% mets          the metabolites in the target reaction
%
% Jeff Orth
% 10/11/09

%get the metabolites in the rxn
metIndex = find(model.S(:,findRxnIDs(model,rxn)));

% exclude common mets (atp, adp, h, h2o, pi) ** make this an input option
iAtpC = findMetIDs(model,'atp[c]');
iAtpP = findMetIDs(model,'atp[p]');
iAdpC = findMetIDs(model,'adp[c]');
iAdpP = findMetIDs(model,'adp[p]');
iHC = findMetIDs(model,'h[c]');
iHP = findMetIDs(model,'h[p]');
iH2oC = findMetIDs(model,'h2o[c]');
iH2oP = findMetIDs(model,'h2o[p]');
iPiC = findMetIDs(model,'pi[c]');
iPiP = findMetIDs(model,'pi[p]');
metIndex = setdiff(metIndex,[iAtpC,iAtpP,iAdpC,iAdpP,iHC,iHP,iH2oC,iH2oP,iPiC,iPiP]);

%get the rxns for each met
nRxnIndexs = {};
for i = 1:length(metIndex)
    nRxnIndexs{i} = find(model.S(metIndex(i),:));
end 

% remove target rxn from list
for i = 1:length(metIndex);
    nRxnIndexs{i} = setdiff(nRxnIndexs{i},findRxnIDs(model,rxn));
end

neighborRxns = {};
for i = 1:length(metIndex)
    neighborRxns{i} = model.rxns(nRxnIndexs{i});
end

%get genes for each rxn
neighborGenes = {};
for i = 1:length(metIndex)
    neighborGenes{i} = model.grRules(nRxnIndexs{i});
end

mets = model.mets(metIndex);


