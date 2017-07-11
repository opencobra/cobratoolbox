function [matchingFields,dimensions] = getModelFieldsForType(model, type, varargin)
% Get the fields in the model which are associated with the given type.
% USAGE:
%     matchingFields = getModelFieldsForType(model, type, varargin)
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
%    dimensions:       The dimension associated with the given type in the
%                      given field. matchingField(X) is matching to type in
%                      dimenion(X)
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
dimensions = [];
if fieldSize == 1
    %This is special. We will only check the first dimension in this
    %instance, and we will check the field properties of S and
    %rxnGeneMat, Also, we will ONLY return defined fields...
    if isfield(model, 'rxnGeneMat') 
        if (strcmp(type,'genes') && size(model.rxnGeneMat,2) == 1) 
            possibleFields{end+1} = 'rxnGeneMat';
            dimensions(end+1,1) = 2;
        end
        if (strcmp(type,'rxns') && size(model.rxnGeneMat,1) == 1)
            possibleFields{end+1} = 'rxnGeneMat';
            dimensions(end+1,1) = 1;
        end
    end
    if isfield(model, 'S') 
        if (strcmp(type,'mets') && size(model.S,1) == 1) 
            possibleFields{end+1} = 'S';
            dimensions(end+1,1) = 1;
        end
        if (strcmp(type,'rxns') && size(model.S,2) == 1)
            possibleFields{end+1} = 'S';
            dimensions(end+1,1) = 2;
        end        
    end
    modelFields = setdiff(modelFields,{'S','rxnGeneMat'});
    for i = 1:numel(modelFields)
        if size(model.(modelFields{i}),1) == fieldSize
            possibleFields{end+1,1} = modelFields{i};
            dimensions(end+1,1) = 1;
        end
    end
    %This is a New empty model, we only look at defined fields.
    fields = getDefinedFieldProperties();
    fields = fields(cellfun(@(x) isequal(x,type),fields(:,3)) | cellfun(@(x) isequal(x,type),fields(:,2)),1);
    posFields = ismember(possibleFields,fields);
    possibleFields = possibleFields(posFields);
    dimensions = dimensions(posFields);
else
    for i = 1:numel(modelFields)
        matchingsizes = size(model.(modelFields{i})) == fieldSize;
        if any(matchingsizes) && ~(sum(matchingsizes) > 1) %A size > 1 should only happen if we have conflicting field sizes...
            possibleFields{end+1,1} = modelFields{i};            
            dimensions(end+1,1) = find(matchingsizes);
        end
        
    end
end

if sameSizeExists
    %we restrict the possibleFields to those which start with the
    %indicator, along with those fields, which are part of the defined
    %fileds.
    
    fields = getDefinedFieldProperties();
    firstdim = cellfun(@(x) isequal(x,type),fields(:,2));
    seconddim = cellfun(@(x) isequal(x,type),fields(:,3));
    fields = fields( firstdim | seconddim ,1);
    definedFieldDims = ones(numel(fields),1);
    definedFieldDims(seconddim) = 2;
    definedPossibles = ismember(fields,possibleFields);
    %Reduce the fields to those which match the size AND are defined.
    definedFieldDims = definedFieldDims(definedPossibles);    
    fields = fields(definedPossibles);        
    %Now check the relevant field positions in the possible fields, i.e.
    %those starting with the respective id (e.g. rxn).
    relevantPossibles = cellfun(@(x) strncmp(x,type,length(type)-1),possibleFields);    
    dimensions = dimensions(relevantPossibles);
    possibleFields = possibleFields(relevantPossibles);            
    %Now, remove those fields which are in both sets from the fields and
    %definedFieldDims and concatenate the results.
    duplicates = ismember(fields,possibleFields);
    fields = fields(~duplicates);
    definedFieldDims = definedFieldDims(~duplicates);
    dimensions = [dimensions;definedFieldDims];
    possibleFields = [possibleFields; fields];
end

matchingFields = possibleFields;