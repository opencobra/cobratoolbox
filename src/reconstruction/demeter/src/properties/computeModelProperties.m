function propertiesFolder = computeModelProperties(refinedFolder, infoFilePath, reconVersion, varargin)
% Part of the DEMETER pipeline. This function analyzes and plots various  
% properties of the refined and optionally the draft reconstructions. Note 
% that this may be time-consuming.
%
% USAGE:
%
%    propertiesFolder = computeModelProperties(refinedFolder, infoFilePath, reconVersion, varargin)
%
% REQUIRED INPUTS
% refinedFolder            Folder with refined COBRA models to analyze
% infoFilePath             File with information on reconstructions to refine
% reconVersion             Name of the refined reconstruction resource
%                          (default: "Reconstructions")
% OPTIONAL INPUTS
% numWorkers               Number of workers in parallel pool (default: 2)
% translatedDraftsFolder   Folder with draft COBRA models with translated
%                          nomenclature and stored as mat files
% customFeatures           Features other than taxonomy to cluster microbes
%                          by. Need to be a table header in the file with 
%                          information on reconstructions.
%
% .. Authors:
%       - Almut Heinken, 06/2020

% Define default input parameters if not specified
parser = inputParser();
parser.addRequired('refinedFolder', @ischar);
parser.addRequired('infoFilePath', @ischar);
parser.addRequired('reconVersion', @ischar);
parser.addParameter('propertiesFolder', [pwd filesep 'modelProperties'], @ischar);
parser.addParameter('numWorkers', 2, @isnumeric);
parser.addParameter('translatedDraftsFolder', '', @ischar);
parser.addParameter('customFeatures', '', @iscellstr);

parser.parse(refinedFolder, infoFilePath, reconVersion, varargin{:});

refinedFolder = parser.Results.refinedFolder;
infoFilePath = parser.Results.infoFilePath;
propertiesFolder = parser.Results.propertiesFolder;
numWorkers = parser.Results.numWorkers;
translatedDraftsFolder = parser.Results.translatedDraftsFolder;
reconVersion = parser.Results.reconVersion;
customFeatures = parser.Results.customFeatures;

mkdir(propertiesFolder)

currentDir=pwd;

dInfo = dir(refinedFolder);
modelList={dInfo.name};
modelList=modelList';
modelList(~(contains(modelList(:,1),{'.mat','.sbml','.xml'})),:)=[];

if length(modelList)>1

    if ~isempty(translatedDraftsFolder)
        % save results for refined and draft in two different folders
        mkdir([propertiesFolder filesep 'Draft'])

        % analyze and cluster draft reconstructions for comparison
        printReconstructionContent(translatedDraftsFolder,[propertiesFolder filesep 'Draft'],[reconVersion '_draft'],numWorkers)
        getReactionMetabolitePresence(translatedDraftsFolder,[propertiesFolder filesep 'Draft'],[reconVersion '_draft'],numWorkers)
        computeUptakeSecretion(translatedDraftsFolder,[propertiesFolder filesep 'Draft'],[reconVersion '_draft'],{},numWorkers)
        computeInternalMetaboliteProduction(translatedDraftsFolder,[propertiesFolder filesep 'Draft'],[reconVersion '_draft'],{},numWorkers)
        try
            producetSNEPlots([propertiesFolder filesep 'Draft'],infoFilePath,[reconVersion '_draft'],customFeatures)
        end
        rankFeaturesByIncidence([propertiesFolder filesep 'Draft'],[reconVersion '_draft'])
    end

    % get basic statistics on draft and refined reconstructions and metabolite
    % and reaction content of all refined reconstructions
    compareDraftRefinedVersions(translatedDraftsFolder,refinedFolder,propertiesFolder,reconVersion,numWorkers)

    % get stochiometric and flux consistency for both draft and refined
    % reconstructions
    computeStochiometricFluxConsistency(translatedDraftsFolder,refinedFolder,propertiesFolder,reconVersion, numWorkers)

    mkdir([propertiesFolder filesep 'Refined'])
    
    % analyze and cluster refined reconstructions
    printReconstructionContent(refinedFolder,[propertiesFolder filesep 'Refined'],[reconVersion '_refined'],numWorkers)
    getReactionMetabolitePresence(refinedFolder,[propertiesFolder filesep 'Refined'],[reconVersion '_refined'],numWorkers)
    getSubsystemPresence([propertiesFolder filesep 'Refined'],[reconVersion '_refined'])
    computeUptakeSecretion(refinedFolder,[propertiesFolder filesep 'Refined'],[reconVersion '_refined'],{},numWorkers)
    computeInternalMetaboliteProduction(refinedFolder,[propertiesFolder filesep 'Refined'],[reconVersion '_refined'],{},numWorkers)
    producetSNEPlots([propertiesFolder filesep 'Refined'],infoFilePath,[reconVersion '_refined'],customFeatures)
    rankFeaturesByIncidence([propertiesFolder filesep 'Refined'],[reconVersion '_refined'])
    
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

cd(currentDir)

end