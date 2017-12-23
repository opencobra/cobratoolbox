function [subSystems]  = getModelSubSystems(model)
% Get all subSystems present in a model
%
% USAGE:
%
%    [subSystems]  = getModelSubSystems(model)
%
% INPUT:
%    model:                 A COBRA model struct with at least the
%                           subSystems fields
%
% OUTPUT:
%    subSystems:            A Cell Array of strings containing all
%                           subSystems in the model
%
% USAGE:
%    %Get all subSystems present in the model.
%    [subSystems]  = getModelSubSystems(model)
%
% .. Author: - Thomas Pfau Nov 2017

if isfield(model, 'subSystems')
    orderedSubs = cellfun(@(x) columnVector(x),model.subSystems,'UniformOUtput',false);
    subSystems = setdiff(vertcat(orderedSubs{:}),'');
    if isempty(subSystems)
        subSystems = {};
    end
else
    subSystems = {};
end