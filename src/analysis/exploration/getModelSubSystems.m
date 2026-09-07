function [subSystems]  = getModelSubSystems(model)
% Get unique set of subSystems present in a model
%
% USAGE:
%
%    [subSystems]  = getModelSubSystems(model)
%
% INPUT:
%    model:                 A COBRA model struct with at least the
%                           subSystems fields, including:
%
%                             * .subSystems - `n x 1` subsystem assignments
%
% OUTPUT:
%    subSystems:            A Cell Array of strings containing all
%                           subSystems in the model
%
% USAGE:
%    Get all subSystems present in the model.
%    [subSystems]  = getModelSubSystems(model)
%
% .. Author: - Thomas Pfau Nov 2017
%            - Farid Zare March 2024  nested cells compatibility

if isfield(model, 'subSystems')
    % Flatten every reaction's subsystem assignment into one list: a char
    % entry contributes its single name, a cell entry (one name or many)
    % contributes each of its names. This single path already handles all
    % three legacy shapes (flat char, flat cell, nested cell) correctly.
    subSystemVec = {};
    for i = 1:numel(model.subSystems)
        if ischar(model.subSystems{i})
            subList = model.subSystems(i);
        else
            subList = model.subSystems{i};
        end
        % turn it into a vertical vector if it is not
        subList = columnVector(subList);
        subSystemVec = [subSystemVec; subList];
    end
    subSystems = unique(subSystemVec);
else
    subSystems = {};
end

% Remove empty elements from sub-system name list
nonEmptyIndices = ~cellfun('isempty', subSystems);
subSystems = subSystems(nonEmptyIndices);
