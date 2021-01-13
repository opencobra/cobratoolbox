function computeModelProperties(modelFolder, infoFilePath, varargin)
% This function analyzes and plots properties of the refined and the draft
% reconstructions if there is more than one. Note that this may be time-consuming.
%
% USAGE:
%
%    computeModelProperties(modelFolder, infoFilePath, varargin)
%
% .. Authors:
%       - Almut Heinken, 06/2020

% Define default input parameters if not specified
parser = inputParser();
parser.addRequired('modelFolder', @ischar);
parser.addRequired('infoFilePath', @ischar);
parser.addParameter('propertiesFolder', [pwd filesep 'modelProperties'], @ischar);
parser.addParameter('numWorkers', 0, @isnumeric);
parser.addParameter('reconVersion', 'Reconstructions', @ischar);
parser.addParameter('customFeatures', '', @iscellstr);
parser.addParameter('draftFolder', '', @ischar);

parser.parse(modelFolder, infoFilePath, varargin{:});

modelFolder = parser.Results.modelFolder;
infoFilePath = parser.Results.infoFilePath;
propertiesFolder = parser.Results.propertiesFolder;
numWorkers = parser.Results.numWorkers;
reconVersion = parser.Results.reconVersion;
customFeatures = parser.Results.customFeatures;
draftFolder = parser.Results.draftFolder;

mkdir(propertiesFolder)

dInfo = dir(modelFolder);
modelList={dInfo.name};
modelList=modelList';
modelList(~(contains(modelList(:,1),{'.mat','.sbml','.xml'})),:)=[];

if length(modelList)>1
    
    if ~isempty(draftFolder)
        % save results for refined and draft in two different folders
        mkdir([propertiesFolder filesep 'Draft'])
   
        % analyze and cluster draft reconstructions for comparison
        printReconstructionContent(draftFolder,[propertiesFolder filesep 'Draft'],[reconVersion '_draft'],numWorkers)
        getReactionMetabolitePresence(draftFolder,[propertiesFolder filesep 'Draft'],[reconVersion '_draft'])
        computeUptakeSecretion(draftFolder,[propertiesFolder filesep 'Draft'],[reconVersion '_draft'],{},numWorkers)
        computeInternalMetaboliteProduction(draftFolder,[propertiesFolder filesep 'Draft'],[reconVersion '_draft'],{},numWorkers)
        producetSNEPlots([propertiesFolder filesep 'Draft'],infoFilePath,[reconVersion '_draft'],customFeatures)
        rankFeaturesByIncidence([propertiesFolder filesep 'Draft'],[reconVersion '_draft'])
        plotMetaboliteProducersConsumers([propertiesFolder filesep 'Draft'],infoFilePath,[reconVersion '_draft'])
        
        mkdir([propertiesFolder filesep 'Refined'])
        
        % analyze and cluster refined reconstructions
        printReconstructionContent(modelFolder,[propertiesFolder filesep 'Refined'],[reconVersion '_refined'],numWorkers)
        getReactionMetabolitePresence(modelFolder,[propertiesFolder filesep 'Refined'],[reconVersion '_refined'])
        getSubsystemPresence([propertiesFolder filesep 'Refined'],[reconVersion '_refined'])
        computeUptakeSecretion(modelFolder,[propertiesFolder filesep 'Refined'],[reconVersion '_refined'],{},numWorkers)
        computeInternalMetaboliteProduction(modelFolder,[propertiesFolder filesep 'Refined'],[reconVersion '_refined'],{},numWorkers)
        producetSNEPlots([propertiesFolder filesep 'Refined'],infoFilePath,[reconVersion '_refined'],customFeatures)
        rankFeaturesByIncidence([propertiesFolder filesep 'Refined'],[reconVersion '_refined'])
        plotMetaboliteProducersConsumers([propertiesFolder filesep 'Refined'],infoFilePath,[reconVersion '_refined'])
        
        % get basic statistics on draft and refined reconstructions and metabolite
        % and reaction content of all refined reconstructions
        compareDraftRefinedVersions(draftFolder,modelFolder,propertiesFolder,reconVersion,numWorkers)
        
        % get stochiometric and flux consistency for both draft and refined
        % reconstructions
        computeStochiometricFluxConsistency(draftFolder,modelFolder,propertiesFolder,reconVersion, numWorkers)
    end
    
    % analyze and cluster reconstructions
    printReconstructionContent(modelFolder,propertiesFolder,reconVersion,numWorkers)
    getReactionMetabolitePresence(modelFolder,propertiesFolder,reconVersion)
    getSubsystemPresence(propertiesFolder,reconVersion)
    computeUptakeSecretion(modelFolder,propertiesFolder,reconVersion,{},numWorkers)
    computeInternalMetaboliteProduction(modelFolder,propertiesFolder,reconVersion,{},numWorkers)
    producetSNEPlots(propertiesFolder,infoFilePath,reconVersion,customFeatures)
    rankFeaturesByIncidence(propertiesFolder,reconVersion)
    plotMetaboliteProducersConsumers(propertiesFolder,infoFilePath,reconVersion)
      
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