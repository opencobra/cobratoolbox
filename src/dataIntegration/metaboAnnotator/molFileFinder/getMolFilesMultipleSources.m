function [metabolite_structure,molCollectionReport] = getMolFilesMultipleSources(metabolite_structure, molFileDirectory,startSearch,endSearch,source)
% This function obtains mol files from differnt resources. For details
% please check 'obtainMetStructures.m'.
%
% INPUT
% metabolite_structure  metabolite structure
% molFileDirectory      Folder where mol files should be deposited
% startSearch           specify where the search should start in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
% endSearch             specify where the search should end in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
% source                specify where you want to obtain the mol file from
%                       (default: all resources), options:
%                       1.- 'inchi' (requires openBabel)
%                       2.- 'smiles' (requires openBabel)
%                       3.- 'kegg' (https://www.genome.jp/)
%                       4.- 'hmdb' (https://hmdb.ca/)
%                       5.- 'pubchem' (https://pubchem.ncbi.nlm.nih.gov/)
%                       6.- 'chebi' (https://www.ebi.ac.uk/)
%
% OUTPUT
% metabolite_structure  updated metabolite_structure
%
%
% Ines Thiele, 09/2021

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
    dirN = [molFileDirectory filesep 'metabolites' filesep location{j} filesep];
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
        for i=3:length(filenames)
            copyfile(filenames(i).name,[molFileDirectory])
        end
        
    end
end

cd(currentPath)
try
    rmdir([molFileDirectory filesep 'metabolites'],'s');
end