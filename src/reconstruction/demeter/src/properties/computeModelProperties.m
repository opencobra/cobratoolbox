function computeModelProperties(translatedDraftsFolder, refinedFolder, varargin)
% This function analyzes and plots properties of the refined and the draft
% reconstructions if there is more than one. Note that this may be time-consuming.
%
% USAGE:
%
%    computeModelProperties(translatedDraftsFolder, refinedFolder, varargin)
%
% .. Authors:
%       - Almut Heinken, 06/2020

% Define default input parameters if not specified
parser = inputParser();
parser.addRequired('translatedDraftsFolder', @ischar);
parser.addRequired('refinedFolder', @ischar);
parser.addParameter('propertiesFolder', [pwd filesep 'modelProperties'], @ischar);
parser.addParameter('infoFilePath', 'AGORA2_infoFile.xlsx', @ischar);
parser.addParameter('numWorkers', 0, @isnumeric);
parser.addParameter('reconVersion', 'Reconstructions', @ischar);
parser.addParameter('customFeatures', '', @iscellstr);
parser.addParameter('analyzeDrafts', false, @islogical);

parser.parse(translatedDraftsFolder, refinedFolder, varargin{:});

translatedDraftsFolder = parser.Results.translatedDraftsFolder;
refinedFolder = parser.Results.refinedFolder;
propertiesFolder = parser.Results.propertiesFolder;
infoFilePath = parser.Results.infoFilePath;
numWorkers = parser.Results.numWorkers;
reconVersion = parser.Results.reconVersion;
customFeatures = parser.Results.customFeatures;
analyzeDrafts = parser.Results.analyzeDrafts;

mkdir([pwd filesep 'modelProperties'])

dInfo = dir(refinedFolder);
modelList={dInfo.name};
modelList=modelList';
modelList(~contains(modelList(:,1),'.mat'),:)=[];

if length(modelList)>1
    
    if isempty(propertiesFolder)
        % create a folder in the current path
        mkdir('refinedModelProperties')
        propertiesFolder = [pwd filesep 'refinedModelProperties'];
    end
    
    % get basic statistics on draft and refined reconstructions and metabolite
    % and reaction content of all refined reconstructions
    printReconstructionFeatures(translatedDraftsFolder,refinedFolder,propertiesFolder,reconVersion,numWorkers)
    
    if analyzeDrafts
        % analyze and cluster draft reconstructions for comparison
        getReactionMetabolitePresence(translatedDraftsFolder,propertiesFolder,[reconVersion '_draft'])
        computeUptakeSecretion(translatedDraftsFolder,propertiesFolder,[reconVersion '_draft'],{},numWorkers)
        computeInternalMetaboliteProduction(translatedDraftsFolder,propertiesFolder,[reconVersion '_draft'],{},numWorkers)
        producetSNEPlots(propertiesFolder,infoFilePath,[reconVersion '_draft'],customFeatures)
    end
    
    % analyze and cluster refined reconstructions
    getReactionMetabolitePresence(refinedFolder,propertiesFolder,[reconVersion '_refined'])
    computeUptakeSecretion(refinedFolder,propertiesFolder,[reconVersion '_refined'],{},numWorkers)
    computeInternalMetaboliteProduction(refinedFolder,propertiesFolder,[reconVersion '_refined'],{},numWorkers)
    producetSNEPlots(propertiesFolder,infoFilePath,[reconVersion '_refined'],customFeatures)
    rankFeaturesByIncidence(propertiesFolder,[reconVersion '_refined'])
    plotMetaboliteProducersConsumers(propertiesFolder,infoFilePath,[reconVersion '_refined'])
    
    % get stochiometric and flux consistency for both draft and refined
    % reconstructions
    computeStochiometricFluxConsistency(translatedDraftsFolder,refinedFolder,propertiesFolder,reconVersion, numWorkers)
    
    % delete files that are no longer needed
    dInfo = dir(fullfile(propertiesFolder, '**/*.*'));  %get list of files and folders in any subfolder
    dInfo = dInfo(~[dInfo.isdir]);
    files={dInfo.name};
    files=files';
    folders={dInfo.folder};
    folders=folders';
    % remove any files that are not matfiles
    delInd=find(~contains(files(:,1),'mat'));
    files(delInd,:)=[];
    folders(delInd,:)=[];
    % remove files that should be kept
    delInd=find(contains(files(:,1),'Consistency'));
    files(delInd,:)=[];
    folders(delInd,:)=[];
    
    for i=1:length(files)
        delete([folders{i} filesep files{i}]);
    end
    
    % delete files that are no longer needed
    dInfo = dir(fullfile(propertiesFolder, '**/*.*'));  %get list of files and folders in any subfolder
    dInfo = dInfo(~[dInfo.isdir]);
    files={dInfo.name};
    files=files';
    folders={dInfo.folder};
    folders=folders';
    % remove any files that are not matfiles
    delInd=find(~contains(files(:,1),'Tmp_images'));
    files(delInd,:)=[];
    folders(delInd,:)=[];
    
    for i=1:length(files)
        delete([folders{i} filesep files{i}]);
    end
    
end

end