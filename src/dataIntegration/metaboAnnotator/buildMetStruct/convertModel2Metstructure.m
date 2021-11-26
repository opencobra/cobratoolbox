function [metabolite_structure] = convertModel2Metstructure(model)
% This function converts the metabolite information present in a metabolic
% reconstruction (contained in a model structure) into a metabolite
% structure to make the reconstruction amenable to the metaboAnnotator
% extension.
%
% INPUT
% model                 model structure
% 
% OUTPUT 
% metabolite_structure  metabolite structure
%
% Ines Thiele, 2020/2021

F = fieldnames(model);
metabolite_structure = struct();

% load translation table between metabolite structure and COBRA model
% fields
translateMetStr2COBRAmodel;

for i = 1 : length(model.mets)
    met = strcat('VMH_',model.mets{i});
    % remove compartment from met abbr
    [tok,rem] = strtok(met,'[');
    if ~isfield(metabolite_structure,tok) % check that metabolite has not yet been added to the structure
        tok_ori = tok;
        tok = regexprep(tok,'-','_');
        metabolite_structure.(tok) = struct();
           metabolite_structure.(tok).VMHId = regexprep(tok,'VMH_','');
           metabolite_structure.(tok).originalID = model.mets{i};
        for j = 1 : size(translation,1)
            if isfield(model,translation{j,2})
                try
                    model.(translation{j,2}){i} = strrep(model.(translation{j,2}){i},'CHEBI:','');
                    model.(translation{j,2}){i} = strrep(model.(translation{j,2}){i},'META:','');
                    metabolite_structure.(tok).(translation{j,1}) = model.(translation{j,2}){i};
                catch
                    metabolite_structure.(tok).(translation{j,1}) = model.(translation{j,2})(i);
                end
                 metabolite_structure.(tok).([translation{j,1},'_source']) = model.modelID;
            end
        end
    end
end

% add the remaining fields to the metabolite structure
metabolite_structure= addField2MetStructure(metabolite_structure);
% clean up known, potential issues with the input data
[metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure);
% check for known, potentially remaining issues with the metabolite IDs