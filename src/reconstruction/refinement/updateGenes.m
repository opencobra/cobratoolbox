function [modelNew] = updateGenes(model)
% Updates model.genes in a new model, based on model.grRules.
%
% USAGE:
%
%    [modelNew] = updateGenes(model);
%
% INPUT:
%    model:              COBRA model structure
%
% OUTPUT:
%    modelNew:           COBRA model structure with corrected genes
%
% Note - the gene order will be changed to sorted. You should probably use
%        buildRxnGeneMat to make sure the order matches in all relevant
%        fields.
%
% .. Authors:
%       - written by Diana El Assal 30/06/2017
%       - fixed by Uri David Akavia 16/07/2017

grRules = model.grRules;
modelNew = model;

genes = replace(grRules, {'and', 'AND', 'or', 'OR', '(', ')'}, '');
genes = splitString(genes, ' ');
genes = [genes{:}]';

genes = unique(genes(cellfun('isclass', genes, 'char')));
modelNew.genes = genes(~cellfun('isempty', genes));  % Not sure this is necessary anymore, but it won't hurt.
