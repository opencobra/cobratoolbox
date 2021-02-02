function [extractedSubset,subsetFolder] = extractReconstructionResourceSubset(modelFolder, infoFilePath, subHeader, subFeature, subsetFolder)
% Extracts a subset of a reconstruction resource (e.g., AGORA) that shares
% a certain feature (e.g., belonging to a particular taxon. Requires
% providing a table containing the information based on which the subset
% should be extracted.
%
% USAGE:
%
%    [extractedSubset,subsetFolder] = extractReconstructionResourceSubset(modelPath, infoFilePath, subHeader, subFeature, subsetFolder)
%
% REQUIRED INPUTS
% modelFolder        Path to folder with reconstruction resource from which
%                    the subset should be retrieved
% infoFilePath       Path to text or spreadsheet file with information on
%                    each reconstruction in the resource
%                    (e.g., 'AGORA_infoFile.xslx')
% subHeader          Name of column header in the information table which
%                    contains the feature by which the subset should be
%                    extracted (e.g., 'Phylum')
% subFeature         Name of the feature by which the subset should be 
%                    extracted (e.g., 'Bacteroidetes')
%
% OPTIONAL INPUTS
% subsetFolder       Path to folder in which the subset of reconstructions
%                    should be saved (Default: 'extractedModels')
%
% OUTPUTS
% extractedSubset    List of IDs of reconstructions in the extracted subset
% subsetFolder       Path to folder in which the subset of reconstructions
%                    is located
%
% .. Authors:
%       - Almut Heinken, 01/2021

% load the file with reconstruction resource information
infoFile = readtable(infoFilePath, 'ReadVariableNames', false);
infoFile = table2cell(infoFile);

% get the subset of reconstruction IDs
featCol=find(strcmp(infoFile(1,:),subHeader));
if isempty(featCol)
    error('subHeader not found in file with reconstruction resource information!')
end

% get the subset of reconstructions to extract
extractedSubset = infoFile(find(strcmp(infoFile(:,featCol),subFeature)),1);
if isempty(extractedSubset)
    error('Non instances of subFeature found in file with reconstruction resource information!')
end

if nargin <5
    subsetFolder = [pwd filesep 'extractedModels'];
end
mkdir(subsetFolder)

for i=1:length(extractedSubset)
    if isfile([modelFolder filesep extractedSubset{i} '.mat'])
        model = readCbModel([modelFolder filesep extractedSubset{i} '.mat']);
    elseif isfile([modelFolder filesep extractedSubset{i} '.xml'])
        model = readCbModel([modelFolder filesep extractedSubset{i} '.xml']);
    elseif isfile([modelFolder filesep extractedSubset{i} '.sbml'])
        model = readCbModel([modelFolder filesep extractedSubset{i} '.sbml']);
    end
    save([subsetFolder filesep extractedSubset{i}],'model');
end

end