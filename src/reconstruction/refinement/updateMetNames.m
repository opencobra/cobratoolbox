function [updatedModel] = updateMetNames(originalModel, modelToUpdate)
% Updates model.metNames in a new model, using metNames of an original
% model.
%
% USAGE:
%
%    [updatedModel] = updateMetNames(originalModel, modelToUpdate)
%
% INPUTS:
%    originalModel:      COBRA model structure with correct model.metNames
%    modelToUpdate:      COBRA model structure that needs to have its
%                        model.metNames updated 
%
% OUTPUT:
%    updatedModel:       COBRA model structure with corrected metNames
%
% .. Authors:
%       - written by Diana El Assal 27/06/2017

indMets = findMetIDs(originalModel, modelToUpdate.mets);
updatedModel = modelToUpdate;
updatedModel.metNames = [];
for i = 1:length(indMets);
    metID = indMets(i);
    if ~metID==0;
        updatedModel.metNames{i,1} = originalModel.metNames(metID);
    else
        updatedModel.metNames{i,1} = [];
    end
end
