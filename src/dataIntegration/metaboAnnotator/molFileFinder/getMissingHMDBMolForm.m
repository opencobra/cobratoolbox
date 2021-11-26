function [metabolite_structure] = getMissingHMDBMolForm(metabolite_structure,molFileDirectory,retrievePotHMDB,startSearch,endSearch)
% This function uses getMolFileFromHMDB.m to obtain mol files for those
% metabolite structure entries that have hmdb id's specified. It also has
% the option find novel hmdb entries by querying hmdb for the metabolite
% names. Only perfect matches are considered. See retrievePotHitsHMDB.m for
% more details.
%
% INPUT
% metabolite_structure  metabolite structure
% molFileDirectory      directory where mol files should be stored
% retrievePotHMDB       default: true (attention: this could be time
%                       consuming)
% startSearch           specify where the search should start in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
% endSearch             specify where the search should end in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
%
% OUTPUT
% metabolite_structure  updated metabolite structure
%
% Ines Thiele 09/21

if ~exist('retrievePotHMDB','var')
    retrievePotHMDB = 1;
end
annotationSource = 'HMDB';
annotationType = 'automatic';

if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(F);
end
%% obtain inchiString, charged formula, mol files for each metabolite
F = fieldnames(metabolite_structure);
for i = startSearch : endSearch
    if retrievePotHMDB == 1
        if isempty(metabolite_structure.(F{i}).hmdb) || ~isempty(find(isnan(metabolite_structure.(F{i}).hmdb)))
            % try to find the hmdb entry based on name
            met = metabolite_structure.(F{i}).metNames;
            hmdb =retrievePotHitsHMDB(met);
            if ~isempty(hmdb)
                metabolite_structure.(F{i}).hmdb = hmdb;
                metabolite_structure.(F{i}).hmdb_source = ['Metabolite searched in HMDB by name',':',annotationType,':',datestr(now)];
            end
        end
    end
    % check that hmdb id is defined
    if ~isempty(metabolite_structure.(F{i}).hmdb) && length(find(isnan(metabolite_structure.(F{i}).hmdb)))==0
        % get inchistring only if there is no inchistring for the metabolite
        % defined
        %         if (isempty(metabolite_structure.(F{i}).inchiString)) || length(find(isnan(metabolite_structure.(F{i}).inchiString)))> 0
        %             % input into this function is the HMDB ID
        %             [inchiString] = getInchiStringFromHMDB( metabolite_structure.(F{i}).hmdb);
        %             if ~isempty(inchiString)
        %                 metabolite_structure.(F{i}).inchiString = inchiString;
        %                 metabolite_structure.(F{i}).inchiString_source = [annotationSource,':',annotationType,':',datestr(now)];
        %             end
        %         end
        % get mol files for each entry
        if isempty(metabolite_structure.(F{i}).hasmolfile) || length(find(isnan(metabolite_structure.(F{i}).hasmolfile)))>0 ...
                || strcmp(metabolite_structure.(F{i}).hasmolfile,'0')
            %             [outFile] = getMolFileFromHMDB(metabolite_structure.(F{i}).VMHId, metabolite_structure.(F{i}).hmdb,molFileDirectory);
            %             if ~isempty(outFile)
            %                 metabolite_structure.(F{i}).hasmolfile = num2str(1);
            %                 metabolite_structure.(F{i}).hasmolfile_source = [annotationSource,':',annotationType,':',datestr(now)];
            %
            [metabolite_structure,molCollectionReport] = getMolFilesMultipleSources(metabolite_structure, molFileDirectory,i,i,'hmdb');
            [metabolite_structure,IDsAdded,InchiKeyList,InchiStringList] = generateInchiFromMol(metabolite_structure,molFileDirectory, 1, 1,1,i,i);
            % end
        end
        
    end
end
[metabolite_structure] = addMetFormulaCharge(metabolite_structure,startSearch,endSearch);