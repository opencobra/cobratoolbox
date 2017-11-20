function [model2] = generateRules(model)
% If a model does not have a model.rules field but has a model.grRules
% field, can be regenerated using this script
%
% USAGE:
%
%    [model2] = generateRules(model)
%
% INPUT:
%    model:     with model.grRules
%
% OUTPUT:
%    model2:    same model but with model.rules added
%
% .. Author: -  Aarash Bordar 11/17/2010
%            -  Uri David Akavia 6-Aug-2017, bug fixes and speedup
%            -  Diana El Assal 30/8/2017

grRules = model.grRules;
genes = model.genes;
model2 = model;

for i = 1:length(grRules)
    [rule,~,newGenes] = parseGPR(model2.grRules{i},model2.genes);
    if ~isempty(newGenes)
        warning('Found the following genes not present in the original model:\n%s\nAdding them to the model.',strjoin(newGenes,'\n'));
        model2.genes = [model2.genes ; newGenes];
    end
    model2.rules{i,1} = rule;
end
end

