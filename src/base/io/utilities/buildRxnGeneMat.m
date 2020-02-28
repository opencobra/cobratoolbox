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


if ~isfield(model,'rules')
    %If rules does not exist, we need to create it. This will either happen
    %by generating it from grRules or initializing it as empty.
    if isfield(model,'grRules')
        model = generateRules(model);
    else
        %Empty rules field.
        model.rules = repmat({''},size(model.rxns,1),1);
    end    
end

model.rxnGeneMat = false(numel(model.rxns), numel(model.genes));
if isfield(model,'rules')
    for i = 1:numel(model.rxns)
        if ~isempty(model.rules{i})
            genes = regexp(model.rules{i},'(?<ids>[0-9]+)','names');
            genepos = cellfun(@str2num , {genes.ids});
            model.rxnGeneMat(i,genepos) = true;
        end
    end
end
