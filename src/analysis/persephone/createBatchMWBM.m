function [modelStats, summaryStats, dietInfo, dietGrowthStats] = createBatchMWBM(mgpipePath, mWBMPath, metadataPath, varargin)
% This function creates personalised host-microbiome WBM models (mWBMs) by joining
% microbiome community models with unpersonalised WBM models in a 
% sex-specific manner. The models are parameterised on a predefined diet.
%
% USAGE:
%       [modelStats, summaryStats, dietInfo, dietGrowthStats] = createBatchMWBM(mgpipePath, mWBMPath, metadataPath)
%
% INPUTS
% mgpipePath:                   Path to microbiome community models created by the
%                               microbiome modelling toolbox.
% mWBMPath                      Path to directory where the HM models are
%                               saved
%
% OPTIONAL INPUTS
% Diet                          Diet option: 'EUAverageDiet' (default)
% numWorkersCreation                    Number of cores used for parallelisation.
%                               Default = 4.
% checkFeasibility              Flag (true/false) to run the
%                               ensureHMfeasibility.m function and check if 
%                               the generated models can grow on the diet. 
%                               Default = true.
% wbmDirectory                  Path to directory with user defined WBMs.
%                               This function supports one user adapted male and one user adapted female
%                               WBM or personalised germ free WBMs for each sample with a microbiome
%                               community model. Default is empty. If wbmDirectory is empty,
%                               Harvey/Harvetta version 1.04c are used.
%
% OUTPUTS
% modelStats                    Table with summary statistics on the generated WBMs:
%                               gender, number of reactions, metabolites,constrainsts, 
%                               and taxa.
% summaryStats                  Table with the mean and SD of the model
%                               statistics in the modelStats variable.
% dietInfo                      Table with diet growth information.
%                               models can grow on the given diet. 
% dietGrowthStats               Table with statistics on 
%
% Authors:  Tim Hensen, 2023, 2024

% Define default parameters if not defined
parser = inputParser();
parser.addRequired('mgpipePath', @ischar);
parser.addRequired('mWBMPath', @ischar);
parser.addRequired('metadataPath', @ischar);

parser.addParameter('Diet', 'EUAverageDiet', @ischar);
parser.addParameter('numWorkersCreation', 4, @isnumeric);
parser.addParameter('numWorkersOptimisation', 2, @isnumeric);
parser.addParameter('checkFeasibility', true, @islogical);
parser.addParameter('wbmDirectory', '', @ischar);
parser.addParameter('solver', 'gurobi', @ischar);
parser.addParameter('maleUnpersonalisedWBMpath', 'Harvey_1_03d', @ischar);
parser.addParameter('femaleUnpersonalisedWBMpath', 'Harvetta_1_03d', @ischar);

% Parse required and optional inputs
parser.parse(mgpipePath, mWBMPath, metadataPath, varargin{:});

mgpipePath = parser.Results.mgpipePath;
mWBMPath = parser.Results.mWBMPath;

Diet = parser.Results.Diet;
checkFeasibility = parser.Results.checkFeasibility;
wbmDirectory = parser.Results.wbmDirectory;
numWorkersCreation = parser.Results.numWorkersCreation;
numWorkersOptimisation = parser.Results.numWorkersOptimisation;
solver = parser.Results.solver;
maleUnpersonalisedWBMpath = parser.Results.maleUnpersonalisedWBMpath;
femaleUnpersonalisedWBMpath = parser.Results.femaleUnpersonalisedWBMpath;

%%% Step 1: Obtain paths to microbiome community models %%%
disp('GenerateMWBMs -- STEP 1: Obtain paths to microbiome community models')

% Get microbiome paths
mDir = what(mgpipePath);
microbiomePaths = string(append(mDir.path, filesep, mDir.mat));

% Only load the models that contain microbiota_model_ in the file name
microbiomePaths = microbiomePaths(contains(microbiomePaths, 'microbiota_model_'));

% Obtain sample IDs from file names
microbiomeSamples = string(erase(mDir.mat,'.mat'));
microbiomeSamples = microbiomeSamples(contains(microbiomeSamples, 'microbiota_model_'));

% Remove microbiota_model_diet_ or microbiota_model_samp_ 
microbiomeSamples = regexprep(microbiomeSamples,'microbiota_model_diet_|microbiota_model_samp_','');


%%% Step 2: Remove paths for samples for which mWBMs have already been created %%%
disp('GenerateMWBMs -- STEP 2: Remove paths for samples for which mWBMs have already been created')

% Find the already generated mWBMs.
generatedMWBMs = what(mWBMPath).mat;
generatedMWBMs = extractBetween(generatedMWBMs,'WBM_','.mat');

% Remove sex information
generatedMWBMs = strrep(generatedMWBMs,'_female','');
generatedMWBMs = strrep(generatedMWBMs,'_male','');

% Find samples to be removed
[microbiomeSamples,toCreate]=setdiff(microbiomeSamples,generatedMWBMs,'stable');

% Update list of mWBMs to be created 
microbiomePaths = microbiomePaths(toCreate);

% Do not create mu(i)WBMs if all already have been created
createMWBMs = true;
if isempty(microbiomePaths)
    createMWBMs = false;
end

if createMWBMs == true

    %%% Step 3: Remove samples for which mWBMs have already been created %%%
    disp('GenerateMWBMs -- STEP 3: Remove samples for which mWBMs have already been created')
    
    % Check if iWBMs have already been created and are present in the
    % wbmDirectory path.
    useiWBMs = false;
    iWBMpresence = what(wbmDirectory).mat;
    if ~isempty(iWBMpresence)
        if any(contains(iWBMpresence,'iWBM'))
            useiWBMs = true;
        end
    end
    
    if useiWBMs == true % Find paths to iWBMs
        % Find paths to iWBMs
        iWBMpaths = fullfile(what(wbmDirectory).path, what(wbmDirectory).mat);

    end
    
    
    %%% Step 4: Pair microbiome models with metadata and find sex information
    %%%
    disp('GenerateMWBMs -- Step 4: Pair microbiome models with metadata and find sex information')
    
    % Read the metadata file
    metadata = readMetadataForPersephone(metadataPath);
    metadata.ID = string(metadata.ID);
    
    % Find the intersect and equalise sample orders
    [~,ia,ib]=intersect(metadata.ID,microbiomeSamples,'stable');
    metadata = metadata(ia,:);
    microbiomePaths = microbiomePaths(ib);
    microbiomeSamples = microbiomeSamples(ib);
    % Check if mWBMs can be created and update createMWBMs accordingly
    if isempty(microbiomePaths)
        createMWBMs = false;
    end
end

if createMWBMs == true
    %%% Step 5a: Generate mWBMs using unpersonalised WBMs %%%
   
    
    % initialise parallel pool
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkersCreation)
    end
    
    % Set environment before entering the parfor loop.
    environment = getEnvironment();
    
    if useiWBMs == false % Create mWBMs from unpersonalised WBMs
     disp('GenerateMWBMs -- Step 5: Generate mWBMs using unpersonalised WBMs')
        % Ensure the sex indication is in lower case
        mdlSex = lower(string(metadata.Sex));
    
        % Load male and female unpersonalised germ free WBMs
        % Note that loading the male or female WBM might not be necessary if
        % only one sex is present in the microbiome samples. However, for
        % simplicity of the code, such a check is not included. 
        male = loadPSCMfile(maleUnpersonalisedWBMpath); 
        female = loadPSCMfile(femaleUnpersonalisedWBMpath);
    
        parfor i=1:length(microbiomePaths)
            restoreEnvironment(environment)
        
            % Load microbiota model
            microbiota_model=load(microbiomePaths(i));
            microbiota_model=microbiota_model.(string(fieldnames(microbiota_model)));
        
            % Create host-microbiome model
            switch mdlSex(i)
                case "male"
                    createMWBM(microbiota_model, male, Diet, mWBMPath);
                case "female"
                    createMWBM(microbiota_model, female, Diet, mWBMPath);
            end
        end
    end
    
    
    %%% Step 5b: Generate muiWBMs using iWBMs %%%
    
    
    if useiWBMs == true % Create muiWBMs from iWBMs
    disp('GenerateMWBMs -- Step 5: Generate muiWBMs using iWBMs')
        % Make sure that each iWBM is paired with their corresponding
        % microbiota model
        iWBMnames = what(wbmDirectory).mat;
        iWBMnames = replace(iWBMnames, {'iWBM_','miWBM_','iWBM','miWBM','.mat'},'');
        %iWBMnames = extractAfter(iWBMnames,'iWBM','.mat');
        %iWBMnames = extractAfter(iWBMnames,'_','.mat');
        % Find the intersection between the iWBM and microbiome samples and
        % reorder the name arrays.
        [~,ia,ib] = intersect(iWBMnames,microbiomeSamples,'stable');
        iWBMpaths = iWBMpaths(ia);
        microbiomePaths = microbiomePaths(ib);
    
        parfor i=1:length(microbiomePaths)
            restoreEnvironment(environment)
        
            % Load microbiota model
            microbiota_model=load(microbiomePaths(i));
            microbiota_model=microbiota_model.(string(fieldnames(microbiota_model)));
        
            % Load WBM
            WBM = load(iWBMpaths{i});
            
            if ~length(fieldnames(WBM))>1
                WBM=WBM.(string(fieldnames(WBM)));
            end
            % Create host-microbiome model
            createMWBM(microbiota_model, WBM, Diet, mWBMPath);
        end
    end

else
    disp('mWBMs have already been created for each microbiome community model')
end



if checkFeasibility
    %%% Step 6: Ensure that all models are feasible on the diet and find missing
    % diet components if needed %%%

    disp('GenerateMWBMs -- Step 6: Ensure that all models are feasible on the diet and find missing diet components if needed')
    [dietInfo, dietGrowthStats] = ensureWBMfeasibility(mWBMPath, 'Diet', Diet, 'solver', solver, 'numWorkers', numWorkersOptimisation);

else
    dietInfo = {};
    dietGrowthStats = {};
end

%%% Step 7: Get WBM summary statistics %%% 
disp('GenerateMWBMs -- Step 7: Get WBM summary statistics')
[modelStats, summaryStats] = getMicrobiomeWBMstats(mWBMPath, numWorkersCreation);

end


function [modelStats, summaryStats, wbmStatPath] = getMicrobiomeWBMstats(mWBMPath, numWorkersCreation)
% This function loads data from the generated microbiome-WBMs and calculates the
% number of reactions, metabolites, constraints, and unique taxa per WBM.
% Mean averages + SD are also obtained for each statistic. 
%
% INPUTS: 
% mWBMPath                   Path to directory where the HM models are
%                               saved. 
% numWorkersCreation                    Number of cores used for parallelisation.
%                               Default = 4.
% 
% OUTPUTS
% modelStats                    Table with summary statistics on the generated WBMs:
%                               gender, number of reactions, metabolites,constrainsts, 
%                               and taxa.
% summaryStats                  Table with the mean and SD of the model
%                               statistics in the modelStats variable.
% wbmStatPath                   Path to WBM statistics excel file.
%
% Author: Tim Hensen, July 2024

if nargin < 2
    numWorkersCreation = 4;
end

% Generate path to WBM results
wbmStatPath = [mWBMPath filesep 'WBM_stats.xlsx'];

% Get paths to models
paths = string(append(what(mWBMPath).path, filesep, what(mWBMPath).mat));

% Set parellel pool
if numWorkersCreation > 1
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkersCreation)
    end
end

% Preallocate variables for WBM statistics
IDs = string(zeros(length(paths),1));
Sex = string(zeros(length(paths),1));
numRxns = nan(length(paths),1);
numMets = nan(length(paths),1);
numConstraints = nan(length(paths),1);
numTaxa = nan(length(paths),1);

parfor i=1:length(paths)

    % load data from WBM
    data = load(paths(i),'rxns','mets','ctrs','ID','sex');

    % Get data
    IDs(i) = string(data.ID);
    Sex(i) = string(data.sex);
    numRxns(i) = length(data.rxns);
    numMets(i) = length(data.mets);
    numConstraints(i) = length(data.ctrs);
    numTaxa(i) = sum(contains(data.rxns,'biomassPan'));
end

% Organise data to table
modelStats = table(IDs, Sex, numRxns, numMets, numConstraints, numTaxa);
modelStats.Properties.VariableNames = {'ID','sex','Reactions','Metabolites','Constraints','Taxa'};

% Save table
writetable(modelStats, wbmStatPath,'Sheet','Data')

% Obtain summary statistics for male and female models separately

femaleRows = matches(modelStats.sex,'female');

% Obtain summary statistics
summaryStats = zeros(4,4);
% Calculate mean values for female samples 
summaryStats(:,1) = table2array(varfun(@mean,modelStats(femaleRows,3:end)))';
% Calculate SD values for female samples 
summaryStats(:,2) = table2array(varfun(@std,modelStats(femaleRows,3:end)))';
% Calculate mean values for male samples 
summaryStats(:,3) = table2array(varfun(@mean,modelStats(~femaleRows,3:end)))';
% Calculate SD values for male samples 
summaryStats(:,4) = table2array(varfun(@std,modelStats(~femaleRows,3:end)))';

% Convert to table
summaryStats = array2table(summaryStats,...
    "RowNames",modelStats.Properties.VariableNames(3:end)',...
    "VariableNames",{'Mean female samples','SD female samples','Mean male samples','SD male samples'});

% Add sheet to table with WBM statistics
writetable(summaryStats,wbmStatPath,'Sheet','Statistics','WriteRowNames',true);
end