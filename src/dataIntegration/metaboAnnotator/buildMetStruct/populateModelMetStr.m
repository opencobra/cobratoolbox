function [model] = populateModelMetStr(model, metabolite_structure)
% This function populates the model structure with information contained in
% the metabolite structure
%
% INPUT
% model                     model structure
% metabolite_structure      metabolite structure
%
% OUTPUT
% model                     updated model structure
%
%
% Ines Thiele 10/2021

F = fieldnames(metabolite_structure);

% load translation table between metabolite structure and COBRA model
% fields
translateMetStr2COBRAmodel;

for i = 1 : length(F)
    oriID =  metabolite_structure.(F{i}).originalID;
    % remove [] if present
    [tok,rem] = strtok(oriID,'[');
    % find metabolite in mets
    potHits = model.mets(contains(model.mets,tok));
    for j = 1 :length(potHits)
        [tokHit,rem] = strtok(potHits{j},'[');
        % check for perfect match now
        if  strcmp(tokHit,tok)
            hit = find(ismember(model.mets,potHits{j}));
            % now assign the new IDs
            for k = 1 : size(translation,1)
                if isfield(model,translation{k,2})
                    try % works  for non-numeric entries
                        if isempty(model.(translation{k,2}){hit}) || length(find(isnan(model.(translation{k,2}){hit})))>0
                            model.(translation{k,2}){hit} = metabolite_structure.(F{i}).(translation{k,1}) ;
                        end
                    catch % works  for numeric entries
                        if isempty(model.(translation{k,2})(hit)) %|| length(find(isnan(model.(translation{k,2})(hit))))>0
                            model.(translation{k,2})(hit) = str2num(metabolite_structure.(F{i}).(translation{k,1})) ;
                        end
                    end
                end
            end
        end
    end
end