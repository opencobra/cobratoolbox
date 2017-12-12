function [model] = generateRules(model)
% If a model does not have a model.rules field but has a model.grRules
% field, can be regenerated using this script
%
% USAGE:
%
%    [model] = generateRules(model)
%
% INPUT:
%    model:     COBRA model with model.grRules
%
% OUTPUT:
%    model:     same model but with model.rules added
%
% .. Author: -  Aarash Bordar 11/17/2010
%            -  Uri David Akavia 6-Aug-2017, bug fixes and speedup
%            -  Diana El Assal 30/8/2017

% preparse all model.grRules
preParsedGrRules = preparseGPR(model.grRules);

% determine the number of rules
nRules = length(model.grRules);

% allocate the model.rules field
model.rules = cell(nRules, 1);

% loop through all the grRules
for i = 1:nRules
    if ~isempty(preParsedGrRules{i})
        [rule,~,newGenes] = parseGPR(preParsedGrRules{i}, model.genes, newGenes);
        if ~isempty(newGenes)
            warning('Found the following genes not present in the original model:\n%s\nAdding them to the model.',strjoin(newGenes,'\n'));
            model.genes = [model.genes ; newGenes];
        end
        model.rules{i, 1} = rule;
    else
        model.rules{i, 1} = '';
    end
end

end


