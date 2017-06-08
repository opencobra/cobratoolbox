function model = removeRelevantModelFields(model, indicesToRemove, type, varargin)
% 
% USAGE:
%    model = removeRelevantModelFields(model, indicesToRemove, type, varargin)
%
% INPUTS:
%
%    model:              the model to update
%    indicesToRemove:    indices which should eb removed (either a logical array or double indices)
%    type:               the Type of field to update one of 
%                        ('rxns','mets','comps','genes')
%
% OPTIONAL INPUTS:
%    varargin:        Additional Options as 'ParameterName', Value pairs. Options are:
%                     - 'fieldSize', the original size of the field (if
%                       mets was already adjusted, this size will be used
%                       to determine matching fields.
%                     - 'excludeFields', fields which should not be
%                       adjusted but kkept how they are.
%
% OUTPUT:
%
%    modelNew:         the model in which all fields associated with the
%                      given type have the entries indicated removed. The
%                      initial check is for the size of the field, if
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

        
        