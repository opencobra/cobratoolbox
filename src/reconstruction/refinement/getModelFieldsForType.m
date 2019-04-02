function [matchingFields,dimensions] = getModelFieldsForType(model, type, varargin)
% Get the fields in the model which are associated with the given type.
% USAGE:
%     matchingFields = getModelFieldsForType(model, type, fieldSize)
%
% INPUTS:
%
%    model:              the model to update
%    type:               the Type of field to update one of 
%                        ('rxns','mets','comps','genes','ctrs','evars')
%
% OPTIONAL INPUTS:
%    fieldSize:         the original size of the field (if
%                       mets was already adjusted, this size will be used
%                       to determine matching fields.
%   
% OUTPUT:
%
%    matchingfields:   A cell array of fields associated with the
%                      given type. The initial check is for the size of the field, if
%                      multiple base fields have the same size, it is
%                      assumed, that fields named e.g. rxnXYZ are
%                      associated with rxns, and only those fields are
%                      adapted along with fields which are specified in the
%                      Model FieldDefinitions.
%    dimensions:       The dimension associated with the given type in the
%                      given field. matchingField(X) is matching to type in
%                      dimenion(X)
% .. Authors: 
%                   - Thomas Pfau June 2017, adapted to merge all fields.



PossibleTypes = getCobraTypeFields();

parser = inputParser();
parser.addRequired('model',@(x) isfield(x,type));
parser.addRequired('type',@(x) any(ismember(PossibleTypes,x)));
parser.addOptional('fieldSize',numel(model.(type)),@isnumeric)

parser.parse(model,type,varargin{:});

fieldSize = parser.Results.fieldSize;

%There are a few predefined fields which are NOT associated with one of the
%possible fields. 

%First, we retrieve all defined fields.


distinctfields = setdiff(PossibleTypes,type);


sameSizeExists = false;
for i = 1:numel(distinctfields)
    if isfield(model,distinctfields{i}) && (numel(model.(distinctfields{i})) == fieldSize)
        sameSizeExists = true;
        break;
    end
end

modelFields = fieldnames(model);
definedFields = getDefinedFieldProperties();

%Collect all fields of the given size
possibleFields = {};
dimensions = [];
if fieldSize == 1 || fieldSize == 0
    %This is special. We will only check the first dimension in this
    %instance, and we will check the field properties of S and
    %rxnGeneMat, Also, we will ONLY return defined fields, or fields with a clear starting ID...
    [multiDimFields,firstDim,secondDim] = getMultiDimensionFields(definedFields);
    for i = 1:numel(multiDimFields)
        cMultiDimField = multiDimFields{i};
        if isfield(model, cMultiDimField) 
            if (strcmp(type, firstDim{i}) && size(model.(cMultiDimField),1) == fieldSize) 
                possibleFields{end+1,1} = cMultiDimField;
                dimensions(end+1,1) = 1;
            end
            if (strcmp(type, secondDim{i}) && size(model.(cMultiDimField),2) == fieldSize) 
                possibleFields{end+1,1} = cMultiDimField;
                dimensions(end+1,1) = 2;
            end
        end
    end    
    modelFields = setdiff(modelFields,multiDimFields);
    for i = 1:numel(modelFields)
        if size(model.(modelFields{i}),1) == fieldSize
            possibleFields{end+1,1} = modelFields{i};
            dimensions(end+1,1) = 1;
        end        
    end
    %This is a New empty model, we only look at defined fields.
    fields = definedFields;
    fields = fields(cellfun(@(x) isequal(x,type),fields(:,3)) | cellfun(@(x) isequal(x,type),fields(:,2)),1);    
    %modelFields with the "correct" startingID
    relModelFields = modelFields(cellfun(@(x) strncmp(x,type,length(type-1)),modelFields)); %Remove the s from the type for this
    fields = columnVector(union(fields,relModelFields));    
    posFields = ismember(possibleFields,fields);
    possibleFields = possibleFields(posFields);
    dimensions = dimensions(posFields);
else
    knownfields = definedFields;
    firstdim = cellfun(@(x,y) isequal(x,type) && isfield(model,y) && (size(model.(y),1) == fieldSize),knownfields(:,2), knownfields(:,1));
    seconddim = cellfun(@(x,y) isequal(x,type) && isfield(model,y) && (size(model.(y),2) == fieldSize),knownfields(:,3), knownfields(:,1));
    %Remove the known fields.
    unknownModelFields = setdiff(modelFields,knownfields(:,1));
    %And get all matching fields
    knownMatchingFields = knownfields((firstdim|seconddim),1);
    %Only look at known fields which are defined, or undefined fields
    modelFields = union(unknownModelFields,knownMatchingFields);
    for i = 1:numel(modelFields)
        matchingsizes = size(model.(modelFields{i})) == fieldSize;        
        if any(matchingsizes) && ~(sum(matchingsizes) > 1) %A size > 1 should only happen if we have conflicting field sizes...
            possibleFields{end+1,1} = modelFields{i};            
            dimensions(end+1,1) = find(matchingsizes);                    
        elseif sum(matchingsizes) > 1 
            %Now we have a problem. We have multiple dimensions that could fit
            %to the found element. 
            %if there is an element of the same size, we will have to
            %resort to using the defined properties (i.e. we will add it
            %with a dimension of -1 (that we can replace by the definition
            %later)
            if sameSizeExists                
                possibleFields{end+1,1} = modelFields{i};                
                dimensions(end+1,1) = -1;
            else
                %Otherwise, we add both dimensions, as it seems like this
                %is a type x type field.
                cdmins = find(matchingsizes);
                for dim = 1:numel(cdmins)
                    possibleFields{end+1,1} = modelFields{i};
                    dimensions(end+1,1) = cdmins(dim);
                end
            end
        end
        
    end
end

if sameSizeExists    
    %we restrict the possibleFields to those which start with the
    %indicator, along with those fields, which are part of the defined
    %fields.    
    fields = definedFields;
    firstdim = cellfun(@(x,y) isequal(x,type) && isfield(model,y) && (size(model.(y),1) == fieldSize),fields(:,2), fields(:,1));
    seconddim = cellfun(@(x,y) isequal(x,type) && isfield(model,y) && (size(model.(y),2) == fieldSize),fields(:,3), fields(:,1));        
    definedFieldDims = ones(numel(fields(:,1)),1);
    definedFieldDims(seconddim) = 2;    
    fields = fields( firstdim | seconddim ,1);
    definedFieldDims = definedFieldDims(firstdim | seconddim);
    definedPossibles = ismember(fields,possibleFields);    
    %Reduce the fields to those which match the size AND are defined.
    definedFieldDims = definedFieldDims(definedPossibles);    
    fields = fields(definedPossibles);        
    %Now, check again the if the sizes fit...
    actualFieldDimsMatch = arrayfun(@(x) size(model.(fields{x}),definedFieldDims(x)) == fieldSize, 1:numel(fields));
    definedFieldDims = definedFieldDims(actualFieldDimsMatch);
    fields = fields(actualFieldDimsMatch);        
    %Now check the relevant field positions in the possible fields, i.e.
    %those starting with the respective id (e.g. rxn).
    %However, we should only include those which are not defined.
    %i.e. everything with field... and not defined.
    undefinedFields = ~(ismember(possibleFields,definedFields(:,1))) & cellfun(@(x) strncmp(x,type,length(type)-1),possibleFields);
    undefDims = dimensions(undefinedFields);
    undefpossibleFieldNames = possibleFields(undefinedFields);        
    dimensions = [definedFieldDims;undefDims];
    possibleFields = [fields; undefpossibleFieldNames];
    %Now, we also need to take care of rxnGeneMat and S, otherwise we could
    %end up in a critical spot.
    
end

matchingFields = possibleFields;
end
    
