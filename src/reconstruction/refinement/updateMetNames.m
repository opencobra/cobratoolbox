function [updatedModel] = updateMetNames(referenceModel, modelToUpdate, wipeExisting)
% Updates model.metNames in a new model, using metNames of a reference
% model.
%
% USAGE:
%
%    [updatedModel] = updateMetNames(referenceModel, modelToUpdate, wipeExisting);
%
% INPUTS:
%    referenceModel:     COBRA model structure with correct model.metNames
%    modelToUpdate:      COBRA model structure that needs to have its
%                        model.metNames updated 
% OPTIONAL INPUTS:
%    wipeExisting:       true: remove all existing model.metNames in
%                        modelToUpdate, especially when model.metNames is
%                        wrong.
%
% OUTPUT:
%    updatedModel:       COBRA model structure with corrected metNames
%
% .. Authors:
%       - written by Diana El Assal & Thomas Pfau 27/06/2017

if ~exist('wipeExistening','var')
  wipeExisting = false;
end

%remove the compartment info
metsReference = regexprep(referenceModel.mets,'\[[^]\]$','');
metsUpdate = regexprep(modelToUpdate.mets,'\[[^]\]$','');
updatedModel = modelToUpdate;
[metsToUpdate,positionsToUpdateFrom] = ismember(metsUpdate,metsReference);

%reset metNames field in modelToUpdate (if requested), or initialize if not existing
if wipeExisting || ~isfield(updatedModel,'metNames') || ~(length(updatedModel.metNames) == length(updatedModel.mets))
  updatedModel.metNames = cell(size(updatedModel.mets));
  updatedModel.metNames(~metsToUpdate) = {''}; % init metabolites not present in the second model.
end

updatedModel.metNames(metsToUpdate) = referenceModel.metNames(positionsToUpdateFrom(metsToUpdate));
