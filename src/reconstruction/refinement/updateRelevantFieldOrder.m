function model = updateRelevantFieldOrder(model,type,newOrder)
% update the fields relevant to this type to the given new Order
% USAGE:
%     matchingFields = getRelevantModelFields(model, type, newOrder)
%
% INPUTS:
%
%    model:              the model to update
%    type:               the Type of field to update one of 
%                        ('rxns','mets','comps','genes')
%    newOrder:           The new Order. must be of the same size as the
%                        requested model.(type) field.
%
% OUTPUT:
%
%    model:              The model with all field associated with type
%                        reordered
%
% .. Authors: 
%                   - Thomas Pfau June 2017

parser = inputParser();
parser.addRequired('model',@isstruct);
parser.addRequired('type',@(x) any(ismember(x,{'rxns','mets','comps','genes','proteins'})));
parser.addRequired('newOrder',@(x) isnumeric(x) && all(ismember(newOrder,1:numel(model.(type)))));

parser.parse(model,type,newOrder);

[fields,dimensions] = getRelevantModelFields(model,type);

for i = 1:numel(fields)
    %For now, we will only handle 2 dimensional arrays
    if dimensions(i) == 1
        model.(fields{i})(:,:) = model.(fields{i})(newOrder,:);
    elseif dimensions(i) == 2
        model.(fields{i})(:,:) = model.(fields{i})(:,newOrder);
    end
end 

if strcmp(type,'genes')
    %hte gene positions changed, so we have to rebuild the rules field.
    model = generateRules(model);
end

    