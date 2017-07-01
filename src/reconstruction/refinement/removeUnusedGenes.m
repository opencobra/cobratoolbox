function modelNew = removeUnusedGenes(model)
% Updates the rules, genes, and rxnGeneMat fields based on the grRules field for
% reactions in the model.
%
% USAGE:
%
%    modelNew = removeUnusedGenes(model)
%
% INPUTS:
%		 model:    COBRA structure
%
% OUTPUT:
%		 modelNew:    COBRA model structure with updated gene field reflecting only
%                  content present in the model
%
% .. Authors:
%           - Sjoerd Opdam - 6/24/2014    
%           - Thomas Pfau - June 2016 - updated to catch all fields.
	genes=unique(model.genes);
    if length(model.genes) ~= length(genes)
        disp('Some genes have identical IDs')
    end
    %update the rxnGeneMatField;    
    model = buildRxnGeneMat(model);
    genesToRemove = sum(model.rxnGeneMat) == 0;
    model = removeFieldEntriesForType(model,genesToRemove,'genes',numel(model.genes));
    modelNew=model;    
end
