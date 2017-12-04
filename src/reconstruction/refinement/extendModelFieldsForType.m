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
%                        ('rxns','mets','comps','genes')
%
% OPTIONAL INPUTS:
%    varargin:        Additional Options as 'ParameterName', Value pairs. Options are:
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


PossibleTypes = {'rxns','mets','comps','genes'}';


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

fields = getModelFieldsForType(model, type, originalSize);

fields = setdiff(fields,excludeFields);

fieldDefinitions = getDefinedFieldProperties('SpecificFields',fields);
%fields, dependent on two dimensions (different) should always be handled
%separately. Currently, those are: S and rxnGeneMat.
fields = setdiff(fields,{'S','rxnGeneMat'});
fields = [intersect(PossibleTypes,fields);setdiff(fields,PossibleTypes)];
for field = 1:numel(fields)
    fieldPos = ismember(fieldDefinitions(:,1),fields{field});
    if any(fieldPos)        
        %If we have a definition for this field, use the default value.
        if iscell(model.(fields{field}))
            for i = (originalSize+1):targetSize                
                eval(['model.(fields{field}){i,1} = ' fieldDefinitions{fieldPos,5} ';']);
            end
        elseif isnumeric(model.(fields{field})) || ischar(model.(fields{field}))            
                model.(fields{field})((originalSize+1):targetSize,1) = fieldDefinitions{fieldPos,5};
        elseif islogical(model.(fields{field}))
                model.(fields{field})(originalSize+1:targetSize,1) = logical(fieldDefinitions{fieldPos,5});
        end
    else        
        %We don't have definitions. we will assume, that cell arrays are
        %annotations (i.e. default ''), number defaults are NaN -> this most likely will notify wrong things
        %and that we don't have additional char arrays. logicals are 0 by
        %default.
        if iscell(model.(fields{field}))
                model.(fields{field})(originalSize+1:targetSize,1) = {''};
        elseif isnumeric(model.(fields{field})) 
                model.(fields{field})(originalSize+1:targetSize,1) = NaN;
        elseif islogical(model.(fields{field}))
                model.(fields{field})(originalSize+1:targetSize,1) = false;
        end
    end
end

end

        
        