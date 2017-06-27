function [updatedModel] = updateMetNames(referenceModel, modelToUpdate)
% Updates model.metNames in a new model, using metNames of a reference
% model.
%
% USAGE:
%
%    [updatedModel] = updateMetNames(referenceModel, modelToUpdate)
%
% INPUTS:
%    referenceModel:     COBRA model structure with correct model.metNames
%    modelToUpdate:      COBRA model structure that needs to have its
%                        model.metNames updated 
%
% OUTPUT:
%    updatedModel:       COBRA model structure with corrected metNames
%
% .. Authors:
%       - written by Diana El Assal 27/06/2017

metsReference = strtok(referenceModel.mets, '[');
metsReference = metsReference(~cellfun('isempty',metsReference));
metsReference = [metsReference, referenceModel.metNames];

metsUpdate = strtok(modelToUpdate.mets, '[');
metsUpdate = metsUpdate(~cellfun('isempty',metsUpdate));

[ia, ib] = ismember(metsUpdate, metsReference(:,1));

updatedModel = modelToUpdate;
updatedModel.metNames = {};
for i = 1:length(updatedModel.mets);
    if ~ia(i) == 0;
        updatedModel.metNames{i,1} = metsReference{ib(i),2};
    else
        updatedModel.metNames{i} = '';
    end
end
 