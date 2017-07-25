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
%       - fixed by Uri David Akavia 16/07/2017

grRules = model.grRules;
[~,n] = size(model.S);
modelNew = model;
genes = cell(0);
for i = 1:n
    if ~isempty(grRules{i})
        tmp = grRules{i};
        tmp = strrep(tmp,'and','');
        tmp = strrep(tmp, 'AND', '');
        tmp = strrep(tmp,'or','');
        tmp = strrep(tmp, 'OR', '');
        tmp = strrep(tmp,'(','');
        tmp = strrep(tmp,')','');
        tmp = splitString(tmp,' ');
        genes = [genes; tmp];
    end
end
genes = unique(genes(cellfun('isclass',genes,'char')));
modelNew.genes = genes(~cellfun('isempty',genes)); % Not sure this is necessary anymore, but it won't hurt.