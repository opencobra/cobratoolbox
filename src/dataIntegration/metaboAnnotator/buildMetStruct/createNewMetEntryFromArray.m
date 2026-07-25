function [metabolite_structure] = createNewMetEntryFromArray(metInput, source, populate, molFileDirectory, metab_rBioNet_online, rxn_rBioNet_online, metabolite_structure_rBioNet)
% Creates and populates a metabolite structure from a list of metabolites
%
% Takes a list of metabolites (as specified below) and (1) checks whether the
% metabolite abbreviations are new to the VMH and/or rBioNet (in the online
% versions), then obtains the inchiString from the provided HMDB IDs and mol
% files, determines the most abundant pseudoisomer at pH 7, and uses BridgeDB
% to obtain further identifiers.
%
% USAGE:
%
%    [metabolite_structure] = createNewMetEntryFromArray(metInput, source, populate, molFileDirectory, metab_rBioNet_online, rxn_rBioNet_online, metabolite_structure_rBioNet)
%
% INPUTS:
%    metInput:                        cell array (or table) containing the
%                                     metabolites. The information provided must
%                                     be as follows:
%                                     metList = {
%                                     'VMH ID' 'metabolite_name' 'HMDB' 'inchistring' 'neutral_formula' 'charged_formula' 'charge'
%                                     'cot' 'Cotinine' 'HMDB0001046'  '' '' '' ''
%                                     'coto' 'Cotinine n-oxide' 'HMDB0001411'  '' '' '' ''
%                                     If a table is provided, its
%                                     `.Properties.VariableNames` are used as the
%                                     column headers.
%    source:                          source of the information contained in the
%                                     input (e.g. 'Manually assembled by IT')
%
% OPTIONAL INPUTS:
%    populate:                        populate new metabolite information based
%                                     on the provided HMDB IDs; 'true' or 'false'
%                                     (default: 'true')
%    molFileDirectory:                directory where the mol files are deposited
%                                     (default: 'current path'/molFiles)
%    metab_rBioNet_online:            rBioNet metabolite database; loaded from
%                                     disk if not provided
%    rxn_rBioNet_online:              rBioNet reaction database; loaded from disk
%                                     if not provided
%    metabolite_structure_rBioNet:    rBioNet metabolite structure; loaded from
%                                     met_strc_rBioNet if not provided
%
% OUTPUT:
%    metabolite_structure:            metabolite structure containing the new
%                                     metabolites
%
% .. Author: - Ines Thiele, 09/2021

if ~exist('populate','var')
    populate = 'true';
end

if ~exist('metabolite_structure_rBioNet','var')
    load met_strc_rBioNet;
end
if ~exist('metab_rBioNet_online','var') ||  ~exist('rxn_rBioNet_online','var')
    load('data/rxn.mat');
    load('data/metab.mat');
    metab_rBioNet_online = metab;
    rxn_rBioNet_online = rxn;
end

if ~exist('molFileDirectory','var')
    molFileDirectory = [pwd filesep 'molFiles'];
end
mkdir(molFileDirectory);

if istable(metInput)
    met = table2cell(metInput);
    % add headers to met
    H = metInput.Properties.VariableNames;
    met = [H;met];
else
    % rename variable
    met = metInput;
end


annotationSource = 'Calculated using metaboAnnotator and inchiString obtained from HMDB';
annotationType = 'automatic';

%% check that these metabolite abbr do not exist in VMH or rBioNetDB
%[VMH_existance,rBioNet_existance] = checkAbbrExists(met(:,1),metab_rBioNet_online,rxn_rBioNet_online,metabolite_structure_rBioNet);
% only check for met abbr existance
% if ~isempty(find(contains(VMH_existance(:,3),'1')))
%     % abbr exist in VMH
%     error('Abbrevation exists already in the VMH');
% else
%     fprintf('All metabolite abbreviations are new to the VMH.\n');
% end
% if ~isempty(find(contains(rBioNet_existance(:,3),'1')))
%     % abbr exist in VMH
%     error('Abbrevation exists already in rBioNet');
% else
%     fprintf('All metabolite abbreviations are new to rBioNet.\n ');
% end

%Check that the cell array does not contain duplicated VMH IDs.
%[listDuplicates] = check4DuplicatesInList(met(:,1));


% Only add to new metabolite structure if VMH IDs are unique
% % % if isempty(find(contains(VMH_existance(:,3),'1'))) &&  isempty(find(contains(rBioNet_existance(:,3),'1'))) && isempty(listDuplicates)
% % %   [metabolite_structure] =createNewMetaboliteStructure(met,source);
% % % else
% % %     metabolite_structure= struct();
% % % end

[metabolite_structure] =createNewMetaboliteStructure(met,source);

if ~isempty(metabolite_structure) && strcmp(populate,'true')
    F = fieldnames(metabolite_structure);
    for i = 1 : size(F,1)
        % check that hmdb id is defined
        if ~isempty(metabolite_structure.(F{i}).hmdb) && length(find(isnan(metabolite_structure.(F{i}).hmdb)))==0 && isempty(strfind(metabolite_structure.(F{i}).hmdb,';')) % do not continue when multiple hmdb ids are present
            % get inchistring only if there is no inchistring for the metabolite
            % defined
            if (isempty(metabolite_structure.(F{i}).inchiString) || isnan(metabolite_structure.(F{i}).inchiString))
                % input into this function is the HMDB ID
                [inchiString] = getInchiStringFromHMDB( metabolite_structure.(F{i}).hmdb);
                if ~isempty(inchiString)
                    metabolite_structure.(F{i}).inchiString = inchiString;
                    metabolite_structure.(F{i}).inchiString_source = ['HMDB',':',annotationType,':', datestr(now)]
                end
            end
            % get mol files for each entry
            if isempty(metabolite_structure.(F{i}).hasmolfile) || isnan(metabolite_structure.(F{i}).hasmolfile)...
                    || strcmp(metabolite_structure.(F{i}).hasmolfile,'0')
%                getMolFileFromHMDB(metabolite_structure.(F{i}).VMHId, metabolite_structure.(F{i}).hmdb,molFileDirectory);
            [metabolite_structure,molCollectionReport] = getMolFilesMultipleSources(metabolite_structure, molFileDirectory,i,i,'hmdb');
            end
        end
        if  ~isempty(metabolite_structure.(F{i}).inchiString) && length(find(isnan(metabolite_structure.(F{i}).inchiString)))==0
            % compute charged formula for each entry
            inchiString = metabolite_structure.(F{i}).inchiString;
            [metFormulaNeutral,metFormulaCharged,metCharge] = getInchiString2ChargedFormula({metabolite_structure.(F{i}).VMHId},cellstr(inchiString));
            metabolite_structure.(F{i}).chargedFormula = metFormulaCharged;
            metabolite_structure.(F{i}).chargedFormula_source = [annotationSource,':',annotationType,':',datestr(now)];
            metabolite_structure.(F{i}).neutralFormula = metFormulaNeutral;
            metabolite_structure.(F{i}).neutralFormula_source = [annotationSource,':',annotationType,':',datestr(now)];
            metabolite_structure.(F{i}).charge = metCharge;
            metabolite_structure.(F{i}).charge_source = [annotationSource,':',annotationType,':',datestr(now)];
        end
    end
    
end

