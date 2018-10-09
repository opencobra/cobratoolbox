function [fieldNames,firstDim,secondDim] = getMultiDimensionFields(fieldDefinitions)
% Get those fields which have multiple dimensions depending on another
% field from the definitions
%
% USAGE:
%    [fieldNames,firstDim,secondDim] = getMultiDimensionFields(fieldDefinitions)
%
% INPUT:
%    fieldDefinitions:      Field Definitilons as obtained from
%                           getDefinedFieldProperties();
%
% OUTPUTS:
%    fieldNames:            The names of the multi-dimensional fields
%    firstDim:              the referenced field in the first dimension
%    secondDim:             the referenced field in the second dimension
%
%

relfieldDefs = fieldDefinitions(cellfun(@ischar, fieldDefinitions(:,2)) & cellfun(@ischar, fieldDefinitions(:,3)),:);
[fieldNames,firstDim,secondDim] = deal(relfieldDefs(:,1),relfieldDefs(:,2),relfieldDefs(:,3));