function [metabolite_structure] = createNewMetEntryFromArray(metInput,source,populate,molFileDirectory,metab_rBioNet_online,rxn_rBioNet_online,metabolite_structure_rBioNet)
%[metabolite_structure, VMH_existance,rBioNet_existance] = createNewMetEntryFromArray(metInput,source,populate,molFileDirectory)
% This function takes a list of metabolites (as specified below) and 1.
% checks whether the metabolite abbr are new to VMH and/or rBioNet (both as
% in the online versions). Then, it obtained the inchi string from the
% provided HMDB as well as the mol file. Using, ChemAxonn it determine the
% most abundant pseudoisomer at ph 7. Then, it uses BridgeDB to obtain
% further ID's.
%
% INPUT
% metInput              Cell array containing the metabolites
%                       The information provided must be as follows:
%                       metList={
%                       'VMH ID' 'metabolite_name' 'HMDB' 'inchistring' 'neutral_formula' 'charged_formula' 'charge'
%                       'cot' 'Cotinine' 'HMDB0001046'  '' '' '' ''
%                       'coto' 'Cotinine n-oxide' 'HMDB0001411'  '' '' '' ''
% source                source of the information contained in metArray
%                       (e.g., 'Manually assembled by IT')
% populate              Populate new metabolite information based on the
%                       provided HMDB Id's. If no HMDB Id's are provided, please use other
%                       functions in the metaboAnnotator for population.
%                       (Default:true; false).
% molFileDirectory      Specify directory where the mol files should be
%                       deposited. (Default: 'current path'/molFiles).
%
% OUTPUT
% updatedMetList        updated metList
% VMH_existance         Lists whether the abbreviation exists in VMH (online),
%                       as a reaction (2nd entry) or as a metabolite (3rd entry)
% rBioNet_existance     Lists whether the abbreviation exists in rBioNet (as deposited in cobra toolbox online),
%                       as a reaction (2nd entry) or as a metabolite (3rd entry)
%
% Ines Thiele, 09/2021

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

