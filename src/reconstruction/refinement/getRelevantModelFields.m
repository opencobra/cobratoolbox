function matchingFields = getRelevantModelFields(model, type, varargin)
% get fields which are associated with the given type.
% USAGE:
%     matchingFields = getRelevantModelFields(model, type, varargin)
%
% INPUTS:
%
%    model:              the model to update
%    type:               the Type of field to update one of 
%                        ('rxns','mets','comps','genes')
%
% OPTIONAL INPUTS:
%    varargin:        Additional Options as 'ParameterName', Value pairs. Options are:
%                     - 'fieldSize', the original size of the field (if
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
%
% .. Authors: 
%                   - Thomas Pfau June 2017, adapted to merge all fields.



PossibleTypes = {'rxns','mets','comps','genes'};

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


%Collect all fields of the given size
possibleFields = {};
if fieldSize == 1
    %This is special. We will only check the first dimension in this
    %instance, and we will check the field properties of S and
    %rxnGeneMat, Also, we will ONLY return defined fields...
    if isfield(model, 'rxnGeneMat') && ((strcmp(type,'genes') && size(model.rxnGeneMat,2) == 1) || strcmp(type,'rxns') && size(model.rxnGeneMat,1) == 1)
        possibleFields{end+1} = 'rxnGeneMat';
    end
    if isfield(model, 'S') && ((strcmp(type,'mets') && size(model.S,1) == 1) || strcmp(type,'rxns') && size(model.S,2) == 1)
        possibleFields{end+1} = 'S';
    end
    modelFields = setdiff(modelFields,{'S','rxnGeneMat'});
    for i = 1:numel(modelFields)
        if size(model.(modelFields{i}),1) == fieldSize
            possibleFields{end+1,1} = modelFields{i};
        end
    end
    fields = getDefinedFieldProperties();
    fields = fields(cellfun(@(x) isequal(x,type),fields(:,3)) | cellfun(@(x) isequal(x,type),fields(:,2)),1);
    possibleFields = intersect(possibleFields,fields);
else
    for i = 1:numel(modelFields)
        if any(size(model.(modelFields{i})) == fieldSize)
            possibleFields{end+1,1} = modelFields{i};
        end
    end
end

if sameSizeExists
    %we restrict the possibleFields to those which start with the
    %indicator, along with those fields, which are part of the defined
    %fileds.
    
    fields = getDefinedFieldProperties();
    fields = fields(cellfun(@(x) isequal(x,type),fields(:,3)) | cellfun(@(x) isequal(x,type),fields(:,2)),1);
    fields = intersect(possibleFields,fields);
    
    possibleFields = possibleFields(cellfun(@(x) strncmp(x,type,length(type)-1),possibleFields));    
    possibleFields = union(fields,possibleFields);
end

matchingFields = possibleFields;