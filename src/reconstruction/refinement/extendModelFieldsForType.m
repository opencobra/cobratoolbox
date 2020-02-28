function model = extendModelFieldsForType(model, type, varargin)
% Extend all existing fields relevant for the given type to the size of the
% field of the given type, or a specified size.
% USAGE:
%     model = extendModelFieldsForType(model, type, varargin)
%
% INPUTS:
%
%    model:              the model to update
%    type:               the Type of field to update one of 
%                        ('rxns','mets','comps','genes','evars','ctrs')
%
% OPTIONAL INPUTS:
%    varargin:        Additional Options as 'ParameterName', Value pairs. Options are:
%
%                     - 'originalSize', the original size of the field,
%                       this is used to determine fields which have to be
%                       adjusted (default length of field type - 1).
%                     - 'targetSize', the target size to which the field
%                       should be extended. Default values will be used as
%                       defined in the ModelFieldDefinitions to fill empty
%                       entries (default length of field type).
%                     - 'excludeFields', fields that should be ignored
%                       during update.
% OUTPUT:
%
%    model:            A model with the requested fields associated to the
%                      given type updated. Associated fields are determined
%                      by size, and if multiple base fields have the same
%                      size, the Model Field definition along with checks
%                      for field Names (e.g. rxnXYZ is associated with
%                      rxns) is used. Added values are either default
%                      values (if defined in the ModelFieldDefinitions), or
%                      {''} for cell arrays, NaN for numeric arrays and
%                      false for logical arrays. Char Arrays will be
%                      ignored.
%
% .. Authors: 
%                   - Thomas Pfau June 2017, adapted to merge all fields.


PossibleTypes = {'rxns','mets','comps','genes','evars','ctrs'}';


parser = inputParser();
parser.addRequired('model',@(x) isfield(x,type));
parser.addRequired('type',@(x) any(ismember(PossibleTypes,x)));
parser.addParamValue('originalSize',numel(model.(type))-1,@isnumeric);
parser.addParamValue('targetSize',numel(model.(type)),@isnumeric);
parser.addParamValue('excludeFields',{},@iscell);

parser.parse(model,type,varargin{:});


originalSize = parser.Results.originalSize;
targetSize = parser.Results.targetSize;
excludeFields = parser.Results.excludeFields;

[originalFields,dimensions] = getModelFieldsForType(model, type, originalSize);
fields = originalFields;
fields = setdiff(fields,excludeFields);

fieldDefinitions = getDefinedFieldProperties();
%fields, dependent on two dimensions (different) should always be handled
%separately. Currently, those are: S and rxnGeneMat.
%fields = setdiff(fields,{'S','rxnGeneMat'});

fields = [intersect(PossibleTypes,fields);setdiff(fields,PossibleTypes)];
[Pres,Pos] = ismember(fields,originalFields);
dimensions = dimensions(Pos(Pres));

for field = 1:numel(fields)
    cfield = fields{field,1};
    cfieldDef = fieldDefinitions(ismember(fieldDefinitions(:,1),cfield),:);
    cdim = dimensions(field);
    if isempty(cfieldDef)
        %this indicates, that no clear field Definition exists. So lets
        %make some assumptions:
        fieldType = 'numeric';
        defaultValue = 0;
        if ischar(model.(cfield))
            fieldType = 'char';
            defaultValue = ' ';
        end
        if iscell(model.(cfield))
            fieldType = 'cell';
            defaultValue = ''''''; %Assume this to be an empty string
        end
        if isnumeric(model.(cfield))
            fieldType = 'numeric';
            defaultValue = 0;
        end
        if islogical(model.(cfield))
            fieldType = 'sparselogical';
            defaultvalue = false;
        end  
        if istable(model.(cfield))
            % this is impossible as we don't know how to extend it...
            if cdim ~= 1
                error('Requested the extension of a table field (%s) in the second dimension. This is impossible, as the type of the new Variable and its name are unknown',cfield);
            end
            fieldType = 'table';
            defaultValue = getDefaultTableRow(model.(cfield));
        end
    else
        fieldType = cfieldDef{7};
        defaultValue = cfieldDef{5};
    end
    fieldDims = size(model.(cfield));    
    %Matlab will screw up multi-dimensional arrays when the are of size 1
    %or zero in a dimension... So for now, we only handle two dimensional
    %arrays.
    %We need to handle completely empty arrays differently.
    if(all(fieldDims == 0))
        %This can only ever happen with numeric, logical or character fields!
        %However, it is only relevant for numeric fields...
        if isnumeric(model.(cfield))
            if issparse(model.(cfield))
                if cdim == 1
                    model.(cfield) = sparse(targetSize,0);
                else
                    model.(cfield) = sparse(0,targetSize);
                end
            else
                if cdim == 1
                    model.(cfield) = zeros(targetSize,0);
                else
                    model.(cfield) = zeros(0,targetSize);
                end
            end
            continue;
        end
    end
    switch fieldType
        case 'cell'
            newValues = cell(0,1);
            for i = originalSize+1:targetSize
                eval(['currentvalue = ' defaultValue ';']);
                newValues{end+1,1} = currentvalue;
            end
            model.(cfield) = extendIndicesInDimenion(model.(cfield),cdim,newValues, targetSize-originalSize);
        case 'sparselogical'            
            model.(cfield) = extendIndicesInDimenion(model.(cfield),cdim,logical(defaultValue), targetSize-originalSize);                        
        case {'numeric','char','table','sparse'}
            model.(cfield) = extendIndicesInDimenion(model.(cfield),cdim,defaultValue, targetSize-originalSize);

    end
end
end