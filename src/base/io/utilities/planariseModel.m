function [modelPlane, replicateMetBool, metData, rxnData] = planariseModel(model, replicateMetBool)
% Converts model into a form that is suitable for display as a planar hypergraph
%
% USAGE:
%
%    [modelPlane, replicateMetBool, metData, rxnData] = planariseModel(model, replicateMetBool)
%
% INPUTS:
%    model:               model structure
%    replicateMetBool:    `met` x 1 boolean vector of metabolites to be replicated for each reaction
%
% OUTPUTS:
%    modelPlane:          structure with fields:
%
%                           * .S - matrix
%                           * .mets - metabolites
%                           * .origMets - original metabolites
%    replicateMetBool:    as in input
%    metData:             data of metabolites
%    rxnData:             data of reactions

metColor='Salmon';
rxnColor='PaleBlue';

[nMet,nRxn]=size(model.S);

Shat=model.S;
Shat(Shat~=0)=1;
degree=sum(Shat,2);

if ~exist('replicateMetBool','var')
    replicateMetBool=degree>3;
end

nReplicateMets=nnz(replicateMetBool);
nRowsForReplicateMets=sum(degree(replicateMetBool));

%same reactions
modelPlane.rxns=model.rxns;


%same non-duplicate mets
modelPlane.mets=model.mets(~replicateMetBool);

%same stoichiometry for reactions except for replicate metabolites
modelPlane.S=sparse(nMet+nRowsForReplicateMets-nReplicateMets,nRxn);
modelPlane.S(1:nMet-nReplicateMets,:)=model.S(~replicateMetBool,:);

for m=1:nMet
    if replicateMetBool(m)
        for n=1:nRxn
            if Shat(m,n)
                %name the new metabolite after the reaction it is involved in
                ind=length(modelPlane.mets);
                modelPlane.origMets{ind+1}=model.mets{m};
                modelPlane.mets{ind+1}=[model.mets{m} '_' model.rxns{n}];
                modelPlane.S(ind+1,n)=model.S(m,n);
            end
        end
    end
end

metData=cell(size(modelPlane.S,1),1);
for m=1:size(modelPlane.S,1)
    metData{m}=metColor;
end

rxnData=cell(size(modelPlane.S,2),1);
for n=1:size(modelPlane.S,2)
    rxnData{n}=rxnColor;
end
