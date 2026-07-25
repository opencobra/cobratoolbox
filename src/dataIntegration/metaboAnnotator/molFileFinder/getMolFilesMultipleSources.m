function [metabolite_structure, molCollectionReport] = getMolFilesMultipleSources(metabolite_structure, molFileDirectory, startSearch, endSearch, source)
% Obtains mol files from different resources for a metabolite structure
%
% For details please check obtainMetStructures.m.
%
% USAGE:
%
%    [metabolite_structure, molCollectionReport] = getMolFilesMultipleSources(metabolite_structure, molFileDirectory, startSearch, endSearch, source)
%
% INPUTS:
%    metabolite_structure:    Metabolite structure
%    molFileDirectory:        Folder where the mol files should be deposited
%
% OPTIONAL INPUTS:
%    startSearch:             Numeric index where the search starts in the
%                             metabolite structure (default: 1)
%    endSearch:               Numeric index where the search ends in the
%                             metabolite structure (default: all metabolites)
%    source:                  Resource to obtain the mol file from (default:
%                             all resources): 'inchi' or 'smiles' (require Open
%                             Babel), 'kegg', 'hmdb', 'pubchem', or 'chebi'
%
% OUTPUTS:
%    metabolite_structure:    Updated metabolite structure
%    molCollectionReport:     Report of the mol file collection process
%
% .. Author: - Ines Thiele, 09/2021

annotationSource = 'Obtained using obtainMetStructures.m';
annotationType = 'automatic';

[VMH2IDmappingAll,VMH2IDmappingPresent,VMH2IDmappingMissing]=getIDfromMetStructure(metabolite_structure,'VMHId');

% note current path;
currentPath = pwd;

F = fieldnames(metabolite_structure);
modelFake = struct;
cnt = 1;
if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(F);
end
if ~exist('source','var')
    source = 'all';
end
for i = startSearch : endSearch
    % only include those metabolites that do not have any mol files
    if length(find(isnan(metabolite_structure.(F{i}).hasmolfile)))>0 || isempty(metabolite_structure.(F{i}).hasmolfile)
        modelFake.mets{cnt,1} = metabolite_structure.(F{i}).VMHId;
        if length(find(isnan(metabolite_structure.(F{i}).smile)))==0 && ~isempty(metabolite_structure.(F{i}).smile)
            modelFake.metSmiles{cnt,1} = metabolite_structure.(F{i}).smile;
        else
            modelFake.metSmiles{cnt,1} = '';
            
        end
        if length(find(isnan(metabolite_structure.(F{i}).inchiString)))==0 && ~isempty(metabolite_structure.(F{i}).inchiString)
            modelFake.metInChIString{cnt,1} = metabolite_structure.(F{i}).inchiString;
        else
            modelFake.metInChIString{cnt,1} = '';
        end
        if length(find(isnan(metabolite_structure.(F{i}).cheBIId)))==0 && ~isempty(metabolite_structure.(F{i}).cheBIId)
            modelFake.metCHEBIID{cnt,1} = metabolite_structure.(F{i}).cheBIId;
        else
            modelFake.metCHEBIID{cnt,1} = '';
        end
        if length(find(isnan(metabolite_structure.(F{i}).keggId)))==0 && ~isempty(metabolite_structure.(F{i}).keggId)
            modelFake.metKEGGID{cnt,1} = metabolite_structure.(F{i}).keggId;
        else
            modelFake.metKEGGID{cnt,1} = '';
        end
        if length(find(isnan(metabolite_structure.(F{i}).hmdb)))==0 && ~isempty(metabolite_structure.(F{i}).hmdb)
            modelFake.metHMDBID{cnt,1} = metabolite_structure.(F{i}).hmdb;
        else
            modelFake.metHMDBID{cnt,1} = '';
            
        end
        if length(find(isnan(metabolite_structure.(F{i}).inchiString)))==0 && ~isempty(metabolite_structure.(F{i}).inchiString)
            modelFake.metPubChemID{cnt,1} = metabolite_structure.(F{i}).pubChemId;
        else
            modelFake.metPubChemID{cnt,1} = '';
        end
        cnt = cnt +1;
    end
end
if ~isempty(fieldnames(modelFake))
    if strcmp(source,'all')
        molCollectionReport = obtainMetStructures(modelFake, modelFake.mets,molFileDirectory);
    else
        if ischar(source)
            source = cellstr(source);
        end
        molCollectionReport = obtainMetStructures(modelFake, modelFake.mets,molFileDirectory,source);
    end
else
    molCollectionReport = '';
end
% retrieve the generated mol files
% add mol file info to the metabolite_structure

% possible locations based on obtainMetStructures.m
location = {'chebi'
    'hmdb'
    'kegg'
    'pubchem'
    };
for j = 1 : length(location)
    dirN = [currentPath filesep 'metabolites' filesep location{j} filesep];
    if isdir(dirN)
        files = dir(dirN);
        for i = 1 : size(files,1)
            name = files(i).name;
            name = regexprep(name,'.mol','');
            match = find(ismember(VMH2IDmappingAll(:,2),name));
            if ~isempty(match)
                metabolite_structure.(VMH2IDmappingAll{match,1}).hasmolfile = '1';
                metabolite_structure.(VMH2IDmappingAll{match,1}).hasmolfile_source =  [annotationSource,'(',location{j},')',':',annotationType,':',datestr(now)];
            end
        end
        % copy files to molFileDirectory and remove the temporary folder
        cd(dirN)
        filenames=dir;
%         for i=3:length(filenames)
%            % copyfile(filenames(i).name,[currentPath filesep molFileDirectory] )
%             copyfile(filenames(i).name,[molFileDirectory] );
%         end
        
    end
end

 cd(currentPath)
% try
%     rmdir([molFileDirectory filesep 'metabolites'],'s');
% end