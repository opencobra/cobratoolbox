function updatedStruct = updateStructData(origStruct,updateStruct)
% Update the struct in origStruct with the data from updateStruct
% USAGE:
%    updatedStruct = updateStruct(origStruct,updateStruct)
% INPUTS:
%    origStruct:        The original Struct
%    updateStruct:      The struct to update the information in origStruct.
%
% OUTPUT:
%    updatedStruct:     The struct with the information from origStruct
%                       updated by the info from updateStruct

updateFieldNames = fieldnames(updateStruct);
updatedStruct = origStruct;
for i = 1:numel(updateFieldNames)
    if ~isfield(updatedStruct,updateFieldNames{i}) || ~isstruct(updateStruct.(updateFieldNames{i}))
        updatedStruct.(updateFieldNames{i}) = updateStruct.(updateFieldNames{i});
    else
        if isstruct(origStruct.(updateFieldNames{i}))
            updatedStruct.(updateFieldNames{i}) = updateStructData(origStruct.(updateFieldNames{i}),updateStruct.(updateFieldNames{i}));
        end
    end
end
        
            