function model = removeRelevantModelFields(model, indicesToRemove, type, varargin)

PossibleTypes = {'rxns','mets','comps','genes'};


parser = inputParser();
parser.addRequired('model',@(x) isfield(x,type));
parser.addRequired('indicesToRemove',@(x) islogical(x) || isnumeric(x));
parser.addRequired('type',@(x) any(ismember(PossibleTypes,x)));
parser.addRequired('fieldSize',@isnumeric);

parser.addParameter('excludeFields',{},@iscell);

parser.parse(model,indicesToRemove,type,varargin{:});


fieldSize = parser.Results.fieldSize;
excludeFields = parser.Results.excludeFields;


if isnumeric(indicesToRemove)
    res = false(fieldSize,1);
    res(indicesToRemove) = 1;
    indicesToRemove = res;
end

fields = getRelevantModelFields(model, type, fieldSize);

fields = setdiff(fields,excludeFields);

for i = 1:numel(fields)
    %Lets assume, that we only have 2 dimensional fields.
    if size(model.(fields{i}),1) == fieldSize
        model.(fields{i}) = model.(fields{i})(~indicesToRemove,:);
    end
    if size(model.(fields{i}),2) == fieldSize
        model.(fields{i}) = model.(fields{i})(:,~indicesToRemove);
    end
end

        
        