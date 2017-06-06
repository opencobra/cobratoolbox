function model = updateRelevantModelFields(model, type, varargin)

PossibleTypes = {'rxns','mets','comps','genes'}';


parser = inputParser();
parser.addRequired('model',@(x) isfield(x,type));
parser.addRequired('type',@(x) any(ismember(PossibleTypes,x)));
parser.addParameter('originalSize',numel(model.(type))-1,@isnumeric);
parser.addParameter('targetSize',numel(model.(type)),@isnumeric);
parser.addParameter('excludeFields',{},@iscell);

parser.parse(model,type,varargin{:});


originalSize = parser.Results.originalSize;
targetSize = parser.Results.targetSize;
excludeFields = parser.Results.excludeFields;

fields = getRelevantModelFields(model, type, originalSize);

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

        
        