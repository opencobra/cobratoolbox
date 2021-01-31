function propertiesFolder = computeModelProperties(modelFolder, infoFilePath, reconVersion, varargin)
% Part of the DEMETER pipeline. This function analyzes and plots various  
% properties of the refined and optionally the draft reconstructions. Note 
% that this may be time-consuming.
%
% USAGE:
%
%    propertiesFolder = computeModelProperties(modelFolder, infoFilePath, reconVersion, varargin)
%
% REQUIRED INPUTS
% modelFolder              Folder with COBRA models to analyze (draft or
%                          refined models)
% infoFilePath             File with information on reconstructions to refine
% reconVersion             Name of the refined reconstruction resource
%                          (default: "Reconstructions")
% OPTIONAL INPUTS
% numWorkers               Number of workers in parallel pool (default: 2)
% customFeatures           Features other than taxonomy to cluster microbes
%                          by. Need to be a table header in the file with 
%                          information on reconstructions.
% translatedDraftsFolder   Folder with draft COBRA models with translated
%                          nomenclature and stored as mat files
%
% .. Authors:
%       - Almut Heinken, 06/2020

% Define default input parameters if not specified
parser = inputParser();
parser.addRequired('modelFolder', @ischar);
parser.addRequired('infoFilePath', @ischar);
parser.addRequired('reconVersion', @ischar);
parser.addParameter('propertiesFolder', [pwd filesep 'modelProperties'], @ischar);
parser.addParameter('numWorkers', 2, @isnumeric);
parser.addParameter('customFeatures', '', @iscellstr);
parser.addParameter('translatedDraftsFolder', '', @ischar);

parser.parse(modelFolder, infoFilePath, reconVersion, varargin{:});

modelFolder = parser.Results.modelFolder;
infoFilePath = parser.Results.infoFilePath;
propertiesFolder = parser.Results.propertiesFolder;
numWorkers = parser.Results.numWorkers;
reconVersion = parser.Results.reconVersion;
customFeatures = parser.Results.customFeatures;
translatedDraftsFolder = parser.Results.translatedDraftsFolder;

mkdir(propertiesFolder)

dInfo = dir(modelFolder);
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
        producetSNEPlots([propertiesFolder filesep 'Draft'],infoFilePath,[reconVersion '_draft'],customFeatures)
        rankFeaturesByIncidence([propertiesFolder filesep 'Draft'],[reconVersion '_draft'])
        plotMetaboliteProducersConsumers([propertiesFolder filesep 'Draft'],infoFilePath,[reconVersion '_draft'])
        
        % get basic statistics on draft and refined reconstructions and metabolite
        % and reaction content of all refined reconstructions
        compareDraftRefinedVersions(translatedDraftsFolder,modelFolder,propertiesFolder,reconVersion,numWorkers)
        
        % get stochiometric and flux consistency for both draft and refined
        % reconstructions
        computeStochiometricFluxConsistency(translatedDraftsFolder,modelFolder,propertiesFolder,reconVersion, numWorkers)
    end
    
    mkdir([propertiesFolder filesep 'Refined'])
    
    % analyze and cluster refined reconstructions
    printReconstructionContent(modelFolder,[propertiesFolder filesep 'Refined'],[reconVersion '_refined'],numWorkers)
    getReactionMetabolitePresence(modelFolder,[propertiesFolder filesep 'Refined'],[reconVersion '_refined'],numWorkers)
    getSubsystemPresence([propertiesFolder filesep 'Refined'],[reconVersion '_refined'])
    computeUptakeSecretion(modelFolder,[propertiesFolder filesep 'Refined'],[reconVersion '_refined'],{},numWorkers)
    computeInternalMetaboliteProduction(modelFolder,[propertiesFolder filesep 'Refined'],[reconVersion '_refined'],{},numWorkers)
    producetSNEPlots([propertiesFolder filesep 'Refined'],infoFilePath,[reconVersion '_refined'],customFeatures)
    rankFeaturesByIncidence([propertiesFolder filesep 'Refined'],[reconVersion '_refined'])
    plotMetaboliteProducersConsumers([propertiesFolder filesep 'Refined'],infoFilePath,[reconVersion '_refined'])
    
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