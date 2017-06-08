function [model] = moveRxn(model, startspot, endspot)
% The function moves a reaction from one spot in the network to another,
% useful for placing important reactions at the beginning of the network to
% easier follow certain reactions.
%
% USAGE:
%
%    [model] = moveRxn(model, startspot, endspot)
%
% INPUTS:
%    model:        COBRA model structure
%    startspot:    The reaction number to move
%    endspot:      The spot where the reaction is moving to
%
% OUTPUTS:
%    model:        COBRA toolbox model structure with moved reaction
%
% .. Authors:
%            - Aarash Bordbar 09/21/09
%            - Thomas Pfau June 2017 (Made function capture all associated
%              fields)

if startspot == endspot
    return
end

if startspot > endspot
    option = 1;
else
    option = 0;
end

oldModel = model;

fields = getRelevantModelFields(model,'rxns');
rxnSize = numel(model.rxns);
for i = 1:numel(fields)
    
    if size(model.(fields{i}),1) == rxnSize
        oldval = oldModel.(fields{i})(startspot,:);    
        if option == 1
            model.(fields{i})(endspot+1:startspot,:) = oldModel.(fields{i})(endspot:startspot-1,:);
            model.(fields{i})(endspot,:) = oldval;
        else
            model.(fields{i})(startspot:endspot-1,:) = oldModel.(fields{i})(startspot+1:endspot,:);
            model.(fields{i})(endspot,:) = oldval;
        end
    elseif size(model.(fields{i}),2) == rxnSize
        oldval = oldModel.(fields{i})(:,startspot);    
        if option == 1
            model.(fields{i})(:,endspot+1:startspot) = oldModel.(fields{i})(:,endspot:startspot-1);
            model.(fields{i})(:,endspot) = oldval;
        else
            model.(fields{i})(:,startspot:endspot-1) = oldModel.(fields{i})(:,startspot+1:endspot);
            model.(fields{i})(:,endspot) = oldval;
        end
        
    end
end

end
