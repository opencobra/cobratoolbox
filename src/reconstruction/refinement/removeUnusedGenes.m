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

if ~isfield(model,'genes')
    %This should not happen, but well, we can generate the genes field from
    %the grRules field, if that exists.
    model = updateGenes(model);
end

if ~isfield(model,'rules')
    model = generateRules(model);
end

if ~isfield(model,'rxnGeneMat')
    %If it doesn't exist, we generate the rxnGeneMat field.
    model = buildRxnGeneMat(model);
end

genesToRemove = sum(model.rxnGeneMat) == 0;
model = removeFieldEntriesForType(model,genesToRemove,'genes',numel(model.genes));
modelNew=model;

end
