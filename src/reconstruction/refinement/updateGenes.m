function [modelNew] = updateGenes(model)
% Updates model.genes in a new model, based on model.grRules.
%
% USAGE:
%
%    [modelNew] = updateGenes(model);
%
% INPUTS:
%    model:              COBRA model structure
%
% OUTPUT:
%    modelNew:           COBRA model structure with corrected genes
%
% .. Authors:
%       - written by Diana El Assal 30/06/2017 

grRules = model.grRules;
[~,n] = size(model.S);
modelNew = model;
genes = {''};
for i = 1:n
    if length(grRules{i}) > 0
        tmp = grRules{i};
        tmp = strrep(tmp,'and','');
        tmp = strrep(tmp,'or','');
        tmp = strrep(tmp,'(','');
        tmp = strrep(tmp,')','');
        tmp = splitString(tmp,' ');
        genes{end+1, 1} = tmp{:,1};
    end
end
genes = unique(genes(cellfun('isclass',genes,'char')));
modelNew.genes = genes(~cellfun('isempty',genes));


