function modelNew=removeUnusedGenes(model)
%removeUnusedGenes updates the rules, genes, and rxnGeneMat fields based on the grRules field for
%reactions in the model.
%
% modelNew = removeUnusedGenes(model)
%
%INPUTS
% model             COBRA structure
%
%OUTPUT
% model             COBRA model structure with updated gene field reflecting only
%					content present in the model
%
% Sjoerd Opdam - 6/24/2014    
	genes=unique(model.genes);
    if length(model.genes) ~= length(genes)
        disp('Some genes have identical IDs')
    end
    model.rules=[];
    model.rxnGeneMat=[];
    model.genes=[];
    warning off all
    for m=1:numel(model.rxns)
        model = changeGeneAssociation(model,model.rxns{m,1},model.grRules{m,1},genes,genes);
    end
    warning on all
    modelNew=model;
end