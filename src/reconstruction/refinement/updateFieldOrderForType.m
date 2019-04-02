function model = updateFieldOrderForType(model,type,newOrder)
% Reorder the fields associated with the provided type to the new order. 
% USAGE:
%     matchingFields = updateFieldOrderForType(model, type, newOrder)
%
% INPUTS:
%
%    model:              the model to update
%    type:               the Type of field to update one of 
%                        the fields returned by `getCobraTypeFields()`
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
parser.addRequired('type',@(x) any(ismember(x,getCobraTypeFields)));
parser.addRequired('newOrder',@(x) isnumeric(x) && all(ismember(newOrder,1:numel(model.(type)))));

parser.parse(model,type,newOrder);

[fields,dimensions] = getModelFieldsForType(model,type);

for i = 1:numel(fields)
    %For now, we will only handle 2 dimensional arrays
    if dimensions(i) == 1
        model.(fields{i})(:,:) = model.(fields{i})(newOrder,:);
    elseif dimensions(i) == 2
        model.(fields{i})(:,:) = model.(fields{i})(:,newOrder);
    end
end 

if strcmp(type,'genes')
    %the gene positions changed, so we have to rebuild the rules field.
    
    if isfield(model,'rules')        
        for i = 1:numel(model.genes)       
            if i ~= newOrder(i)
                %replace by new with an indicator that this is new.
                model.rules = strrep(model.rules,['x(' num2str(newOrder(i)) ')'],['x(' num2str(i) '$)']);
            end
        end
        %remove the indicator.
        model.rules = strrep(model.rules,'$','');
    end
end

    