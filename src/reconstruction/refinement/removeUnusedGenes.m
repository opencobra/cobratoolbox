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

modelNew=model;
if ~isfield(model,'genes')
    %This is VERY odd and should not happen, but lets see            
    modelNew.genes = {};
    warning('Model did not contain a genes field. Building it along with the rules field');
    res = warning();
    warning('off','all')
    modelNew = generateRules(modelNew);   
    warning(res)
end


if ~isfield(modelNew,'rules')
    modelNew = generateRules(modelNew);
end

if ~isfield(modelNew,'rxnGeneMat')
    %If it doesn't exist, we generate the rxnGeneMat field.
    modelNew = buildRxnGeneMat(modelNew);
end

genesToRemove = sum(modelNew.rxnGeneMat) == 0;
modelNew = removeFieldEntriesForType(modelNew,genesToRemove,'genes',numel(modelNew.genes));


end
