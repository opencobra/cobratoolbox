function model = buildRxnGeneMat(model)
% Build the rxnGeneMat based on the given models rules field
%
% USAGE:
%
%    model = buildRxnGeneMat(model)
%
% INPUT:
%    model:     Model to build the rxnGeneMat. Must have the rules field,
%               otherwise the rxnGeneMat is empty
%
% OUTPUT:
%    model: 	The Model including a rxnGeneMat field.
%
% .. Authors: - written by ?
%             Diana El Assal 30/6/2017 - updates

% First, update the genes in the model
if ~isempty(model.genes)
    model = updateGenes(model);
end

%Then, update the gene rules of the model
if ~isempty(model.grRules)
    model = generateRules(model);
end

%Finally, update the rxnGeneMat
model.rxnGeneMat = false(numel(model.rxns, numel(model.genes)));
if isfield(model,'rules')
    for i = 1:numel(model.rxns)
        if ~isempty(model.rules{i})
            genes = regexp(model.rules{i},'(?<ids>[0-9]+)','names');
            genepos = cellfun(@str2num , {genes.ids});
            model.rxnGeneMat(i,genepos) = true;
        end
    end
end
