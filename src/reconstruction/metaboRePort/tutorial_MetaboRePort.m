%% MetaboRePort:

% Set path to the cobratoolbox
global CBTDIR

currentDir = pwd;
% Set root directory
root = '/Users/ines/Dropbox/MY PAPERS/SUBMITTED/Submitted/150k/metaboReports/APOLLOreconstructions';

% user defined path
folder = [root filesep 'refinedReconstructions']; % Set path to folder with reconstructions

% Make folder to save the updated reconstructions
updatedReconstructPath = [root filesep 'updatedReconstructions'];
if exist(updatedReconstructPath,'dir')~=7
    mkdir(updatedReconstructPath)
end

% Make folder to save the updated reconstructions as sbml files
annotatedSBMLreconstructions = [root filesep 'annotatedSBMLreconstructions'];
if exist(annotatedSBMLreconstructions,'dir')~=7
    mkdir(annotatedSBMLreconstructions)
end

% Make folder to where the reports are saved 
reportDir = [root filesep 'reports'];
if exist(reportDir,'dir')~=7
    mkdir(reportDir)
end

% Load rBioNet metabolite structure information
metstructPath = [CBTDIR filesep 'tutorials' filesep 'dataIntegration' filesep...
 'metaboAnnotator' filesep 'data' filesep 'met_strc_rBioNet_new.mat'];

% Ensure that the name of the rBioNet metabolite structure is metabolite_structure_rBioNet 
metabolite_structure_rBioNet = load(metstructPath);
metabolite_structure_rBioNet = metabolite_structure_rBioNet.metabolite_structure_rBioNet;

% Get reconstructions and reconstruction paths
directory = what(folder);
modelPaths = append(directory.path, filesep, directory.mat);
modelList = modelPaths;
 modelList(~contains(modelList(:,1),'.mat'),:)=[];
 

% Preallocate ScoresOverall table for speed
if ~exist(ScoresOverall,'var')
ScoresOverall = cell(length(modelList),2);
end

tic;
for i = 1 : 100%length(modelList)
    disp(i)
    % Load model 
    model = load(modelPaths{i});
    model = model.(string(fieldnames(model))); % ensure that the name of the loaded model is "model".
    
    %[modelProp1,ScoresOverall1] = generateMemoteLikeScore(model);
    % Populate and further annotate model with metabolite info
    [modelUpdated] = populateModelMetStr(model, metabolite_structure_rBioNet,1);
    [modelUpdated] = annotateSBOTerms(modelUpdated);
    
    if any(contains(fieldnames(modelUpdated), {'metInChIString'}))
        modelUpdated = rmfield(modelUpdated,'metInChIString'); % wrongly in microbe models
    end
    
    [modelUpdated] = populateModelwithRxnIDs(modelUpdated);

    [modelProp2,ScoresOverall2] = generateMetaboScore(modelUpdated);
    
    chdir(strcat(updatedReconstructPath, filesep));
    fileName = regexprep(modelList{i},folder,'');% replace folder name if present
    fileName = regexprep(fileName,'\/','');% replace folder name if present
    fileName = regexprep(fileName,'.mat','');
    modelName = strcat('model_',fileName);
    modelProperties.(modelName).ScoresOverall = ScoresOverall2;
    modelProperties.(modelName).modelUpdated = modelUpdated;
    modelProperties.(modelName).modelProp2 = modelProp2;
    ScoresOverall{i,1} = regexprep(fileName,'.mat','');
    ScoresOverall{i,2} = num2str(ScoresOverall2);
    
    if mod(i,10) % Save every ten models
        save('MetaboRePorts.mat','modelProperties','ScoresOverall');
    end
    
    % save updated mat file
    model = modelUpdated;
    if ~contains(fileName,'.mat')
    save(strcat(fileName, '.mat'),'model');
    else
    save(fileName,'model');
    end
    chdir(currentDir)

    % generate sbml file
    % remove description from model structure as this causes issues
    if any(contains(fieldnames(modelUpdated), {'description'}))
        modelUpdated = rmfield(modelUpdated,'description');
    end
    
    % Set sbml path
    sbmlPath = char(strcat(annotatedSBMLreconstructions, filesep, 'Annotated_',fileName));
    % Save model
    outmodel = writeCbModel(modelUpdated, 'format','sbml', 'fileName', sbmlPath);
    
% Generate a generateMetaboReport for each reconstruction
evalc('generateMetaboReport(modelProperties,reportDir)');
end
toc;