function [model] = populateModelMetStr(model, metabolite_structure, replaceAllHits)
% Populates a COBRA model with information from the metabolite structure
%
% Populates the model structure with the metabolite information contained in
% the metabolite structure, mapping metabolite-structure fields onto the
% corresponding COBRA model metabolite annotation fields.
%
% USAGE:
%
%    [model] = populateModelMetStr(model, metabolite_structure, replaceAllHits)
%
% INPUTS:
%    model:                   COBRA model structure with the fields:
%
%                               * .mets - metabolite identifiers, matched
%                                 against the metabolite structure
%                               * .metSBOTerms - SBO term per metabolite
%                               * .metChEBIID - ChEBI identifiers
%                               * .metPubChemID - PubChem identifiers
%                               * .metKEGGID - KEGG identifiers
%                               * .metHMDBID - HMDB identifiers
%                               * .metSEEDID - SEED identifiers
%                               * .metInchiKey - InChIKey per metabolite
%                               * .metReactomeID - Reactome identifiers
%                               * .metMetaNetXID - MetaNetX identifiers
%                               * .metBioCycID - BioCyc identifiers
%                               * .metBiGGID - BiGG identifiers
%                               * .metInchiString - InChI string per metabolite
%                               * .metLIPIDMAPSID - LIPID MAPS identifiers
%                               * .metSmile - SMILES string per metabolite
%    metabolite_structure:    metabolite structure
%
% OPTIONAL INPUT:
%    replaceAllHits:          replace existing entries (default: false)
%
% OUTPUT:
%    model:                   updated model structure
%
% .. Author: - Ines Thiele, 10/2021

if ~exist('replaceAllHits','var')
    replaceAllHits = 0;
end

if ~exist('replaceAllHits','var')
    replaceAllHits = 0;
end


F = fieldnames(metabolite_structure);
fields =fieldnames( metabolite_structure.(F{1}));
% load translation table between metabolite structure and COBRA model
% fields
translateMetStr2COBRAmodel;

for i = 1 : length(F)
    if isfield(metabolite_structure.(F{i}),'originalID')
        oriID =  metabolite_structure.(F{i}).originalID;
        % remove [] if present
        [tok,rem] = strtok(oriID,'[');
        % find metabolite in mets
        potHits = model.mets(contains(model.mets,tok));
    else
        % use VMHId
        potHits = model.mets(contains(model.mets,metabolite_structure.(F{i}).VMHId));
        tok = metabolite_structure.(F{i}).VMHId;
    end
    for j = 1 :length(potHits)
        [tokHit,rem] = strtok(potHits{j},'[');
        % check for perfect match now
        if  strcmp(tokHit,tok)
            hit = find(ismember(model.mets,potHits{j}));
            % now assign the new IDs
            for k = 1 : size(translation,1)
                
                if ~isempty(find(strcmp(fields,translation{k,1})))% check that translation field is part of F
                    % if a field is not present - add field
                    if ~isfield(model,translation{k,2})
                        model.(translation{k,2}) = [];
                    end
                    try % works  for non-numeric entries
                        if replaceAllHits == 1
                            model.(translation{k,2}){hit} = metabolite_structure.(F{i}).(translation{k,1});
                        elseif replaceAllHits ==0
                            if length(model.(translation{k,2}))>=hit
                                if isempty(model.(translation{k,2}){hit}) || length(find(isnan(model.(translation{k,2}){hit})))>0
                                    model.(translation{k,2}){hit} = metabolite_structure.(F{i}).(translation{k,1}) ;
                                end
                            else
                                model.(translation{k,2}){hit} = metabolite_structure.(F{i}).(translation{k,1}) ;
                                
                            end
                        end
                    catch % works  for numeric entries
                        try
                            if replaceAllHits == 1
                                model.(translation{k,2})(hit) = str2num(metabolite_structure.(F{i}).(translation{k,1}));
                            elseif   replaceAllHits == 0
                                if length(model.(translation{k,2}))>=hit
                                    if isempty(model.(translation{k,2})(hit)) %|| length(find(isnan(model.(translation{k,2})(hit))))>0
                                        model.(translation{k,2})(hit) = str2num(metabolite_structure.(F{i}).(translation{k,1})) ;
                                    end
                                else
                                    model.(translation{k,2})(hit) = str2num(metabolite_structure.(F{i}).(translation{k,1})) ;
                                end
                            end
                        catch
                            if replaceAllHits == 1
                                model.(translation{k,2})(hit) = (metabolite_structure.(F{i}).(translation{k,1}));
                            elseif   replaceAllHits == 0
                                if length(model.(translation{k,2}))>=hit
                                    if isempty(model.(translation{k,2})(hit)) %|| length(find(isnan(model.(translation{k,2})(hit))))>0
                                        model.(translation{k,2})(hit) = (metabolite_structure.(F{i}).(translation{k,1})) ;
                                    end
                                else
                                    model.(translation{k,2})(hit) = (metabolite_structure.(F{i}).(translation{k,1})) ;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
% add SBO term to all metabolites SBO:0000247 represents the term 'simple chemical'.
for i = 1 : length(model.mets)
    model.metSBOTerms{i} = 'SBO:0000247';
end
for k = 1 : size(translation,1)
    if isfield(model,translation{k,2})
        model.(translation{k,2}) = columnVector(model.(translation{k,2}));
    end
end

% Append CHEBI: in front of CHEBI Ids
for i = 1 : length(model.mets)
    if ~isnan( model.metChEBIID{i})
        model.metChEBIID{i} = strcat('CHEBI:',model.metChEBIID{i});
    end
end



% ensure uniform output
if isfield(model,'metPubChemID')
    model.metPubChemID = cellfun(@num2str, model.metPubChemID,'UniformOutput',false);
end
if isfield(model,'metKEGGID')
    model.metKEGGID = cellfun(@num2str, model.metKEGGID,'UniformOutput',false);
end

if isfield(model,'metChEBIID')
    model.metChEBIID = cellfun(@num2str, model.metChEBIID,'UniformOutput',false);
end

if isfield(model,'metHMDBID')
    model.metHMDBID = cellfun(@num2str, model.metHMDBID,'UniformOutput',false);
end
if isfield(model,'metSEEDID')
    model.metSEEDID = cellfun(@num2str, model.metSEEDID,'UniformOutput',false);
end
if isfield(model,'metInchiKey')
    model.metInchiKey = cellfun(@num2str, model.metInchiKey,'UniformOutput',false);
end
if isfield(model,'metReactomeID')
    model.metReactomeID = cellfun(@num2str, model.metReactomeID,'UniformOutput',false);
end
if isfield(model,'metMetaNetXID')
    model.metMetaNetXID = cellfun(@num2str, model.metMetaNetXID,'UniformOutput',false);
end
if isfield(model,'metBioCycID')
    model.metBioCycID = cellfun(@num2str, model.metBioCycID,'UniformOutput',false);
end
if isfield(model,'metBiGGID')
    model.metBiGGID = cellfun(@num2str, model.metBiGGID,'UniformOutput',false);
end
if isfield(model,'metInchiString')
    model.metInchiString = cellfun(@num2str, model.metInchiString,'UniformOutput',false);
end

if isfield(model,'metLIPIDMAPSID')
    model.metLIPIDMAPSID = cellfun(@num2str, model.metLIPIDMAPSID,'UniformOutput',false);
    model.metLIPIDMAPSID  =  model.metLIPIDMAPSID (cellfun('isclass',  model.metLIPIDMAPSID , 'char'));
end

if isfield(model,'metSmile')
    model.metSmile = cellfun(@num2str, model.metSmile,'UniformOutput',false);
    model.metSmile  =  model.metSmile (cellfun('isclass',  model.metSmile , 'char'));
end