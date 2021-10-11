function [netSecretionFluxes, netUptakeFluxes, Y, modelStats, summary, statistics, modelsOK] = mgPipe(modPath, abunFilePath, computeProfiles, resPath, dietFilePath, infoFilePath, hostPath, hostBiomassRxn, hostBiomassRxnFlux, objre, saveConstrModels, figForm, numWorkers, rDiet, pDiet, includeHumanMets, lowerBMBound, repeatSim, adaptMedium,removeBlockedRxns)
% mgPipe is a MATLAB based pipeline to integrate microbial abundances
% (coming from metagenomic data) with constraint based modeling, creating
% individuals' personalized models.
% The pipeline is divided in 3 parts:
% [PART 1] Analysis of individuals' specific microbes abundances are computed.
% [PART 2]: 1 Constructing a global metabolic model (setup) containing all the
% microbes listed in the study. 2 Building individuals' specific models
% integrating abundance data retrieved from metagenomics. For each organism,
% reactions are coupled to the objective function.
% [PART 3] Simulations under different diet regimes.
%
% USAGE:
%       [netSecretionFluxes, netUptakeFluxes, Y, modelStats,summary, statistics, modelsWithErrors] = mgPipe(modPath, abunFilePath, computeProfiles, resPath, dietFilePath, infoFilePath, hostPath, hostBiomassRxn, hostBiomassRxnFlux, objre, saveConstrModels, figForm, numWorkers, rDiet, pDiet, includeHumanMets, lowerBMBound, repeatSim, adaptMedium)
%
% INPUTS:
%    modPath:                char with path of directory where models are stored
%    abunFilePath:           char with path and name of file from which to retrieve abundance information
%    computeProfiles:        boolean defining whether flux variability analysis to
%                            compute the metabolic profiles should be performed.
%    resPath:                char with path of directory where results are saved
%    dietFilePath:           char with path of directory where the diet is saved
%    infoFilePath:           char with path to stratification criteria if available
%    hostPath:               char with path to host model, e.g., Recon3D (default: empty)
%    hostBiomassRxn:         char with name of biomass reaction in host (default: empty)
%    hostBiomassRxnFlux:     double with the desired flux through the host
%                            biomass reaction (default: zero)
%    objre:                  char with reaction name of objective function
%    saveConstrModels:       boolean indicating if models with imposed
%                            constraints are saved externally
%    figForm:                format to use for saving figures
%    numWorkers:             integer indicating the number of cores to use for parallelization
%    rDiet:                  boolean indicating if to enable also rich diet simulations (default: 'false')
%    pDiet:                  boolean indicating if to enable also personalized diet simulations (default: 'false')
%    includeHumanMets:       boolean indicating if human-derived metabolites
%                            present in the gut should be provided to the models (default: true)
%    lowerBMBound:           lower bound on community biomass (default=0.4)
%    repeatSim:              boolean defining if simulations should be repeated and previous results
%                            overwritten (default=false)
%    adaptMedium:            boolean indicating if the medium should be adapted through the
%                            adaptVMHDietToAGORA function or used as is (default=true)
%    removeBlockedRxns:      Remove reactions blocked on the input diet to
%                            reduce computation time (default=false)
%
% OUTPUTS:
%    init:                   status of initialization
%    netSecretionFluxes:     Net secretion fluxes by microbiome community models
%    netUptakeFluxes:        Net uptake fluxes by microbiome community models
%    Y:                      Classical multidimensional scaling
%    modelStats:             Reaction and metabolite numbers for each model
%    summary:                Table with average, median, minimal, and maximal
%                            reactions and metabolites
%    statistics:             If info file with stratification is provided, will
%                            determine if there is a significant difference.
%    modelsOK:               Boolean indicating if the created microbiome models
%                            passed verifyModel. If true, all models passed.
%
% AUTHORS:
%   - Federico Baldini, 2017-2018
%   - Almut Heinken, 07/20: converted to function
%   - Almut Heinken, 01/21: added option for creation of each personalized model separately

%% PIPELINE: [PART 1]
% If PART1 was already
% computed: if the associated file is already present in the results folder its
% execution is skipped else its execution starts

[mapP]=detectOutput(resPath,'mapInfo.mat');

if ~isempty(mapP)
    s= 'mapping file found: loading from resPath and skipping [PART1] analysis';
    disp(s)
    load(strcat(resPath,'mapInfo.mat'))
end

[mapP]=detectOutput(resPath,'mapInfo.mat');
if isempty(mapP)
    % check if AGORA models are in path
    if ~exist('modPath', 'var') || ~exist(modPath, 'dir')
        error('modPath is not defined. Please set the path of the model directory.');
    else
        if ~exist(modPath, 'dir')
            error(['modPath (' modPath ') does not exist.']);
        end
    end
    
    abundance = table2cell(readtable(abunFilePath));
    
    % The number of microbeNames, their names, the number of samples and their identifiers
    % are automatically detected from the input file.
    [sampNames,microbeNames,exMets]=getIndividualSizeName(abunFilePath,modPath);
    
    % remove rows of organisms that are not present in any sample
    if contains(version,'(R202') % for Matlab R2020a and newer
        microbeNames(sum(cell2mat(abundance(:,2:end)),2)<0.0000001,:)=[];
        abundance(sum(cell2mat(abundance(:,2:end)),2)<0.0000001,:)=[];
    else
        microbeNames(sum(str2double(abundance(:,2:end)),2)<0.0000001,:)=[];
        abundance(sum(str2double(abundance(:,2:end)),2)<0.0000001,:)=[];
    end
    
    % Extracellular spaces simulating the lumen are built and stored for
    % each microbe.
    [activeExMets,modelStoragePath,couplingMatrix]=buildModelStorage(microbeNames,modPath, numWorkers, removeBlockedRxns);
    
    % Computing reaction presence
    ReactionPresence=calculateReactionPresence(abunFilePath, modPath, {});
    writetable(cell2table(ReactionPresence),[resPath filesep 'ReactionPresence.csv'], 'WriteVariableNames', false);

    % Computing reaction abundance
    ReactionAbundance = fastCalculateReactionAbundance(abunFilePath, modPath, {}, numWorkers);
    writetable(cell2table(ReactionAbundance'),[resPath filesep 'ReactionAbundance.csv'], 'WriteVariableNames', false);
    
    % Computing subsystem abundance
    subsystemAbundance = calculateSubsystemAbundance([resPath filesep 'ReactionAbundance.csv']);
    writetable(cell2table(subsystemAbundance),[resPath filesep 'SubsystemAbundance.csv'], 'WriteVariableNames', false);

    % plot subsystem abundance
    data=cell2mat(subsystemAbundance(2:end,2:end));
    xlabels=subsystemAbundance(1,2:end);
    ylabels=subsystemAbundance(2:end,1);
    figure;
    imagesc(data)
    colormap('hot')
    colorbar
    if length(xlabels)<30
        set(gca,'xtick',1:length(xlabels));
        xticklabels(xlabels);
        xtickangle(90)
    end
    
    if length(xlabels)<30
        set(gca,'xtick',1:length(xlabels));
        xticklabels(xlabels);
        xtickangle(90)
    end
    set(gca,'ytick',1:length(ylabels));
    yticklabels(ylabels);
    ax=gca;
    
    if length(ylabels)<50
        ax.YAxis.FontSize = 8;
    else
        ax.YAxis.FontSize = 6;
    end
    
    set(gca,'TickLabelInterpreter', 'none');
    title('Relative reaction abundances summarized by subsystem')
    print(strcat(resPath, 'Subsystem_abundances'), figForm)
    
    % save mapping info
    save([resPath filesep 'mapInfo.mat'], 'mapP', 'exMets', 'activeExMets', 'sampNames', 'microbeNames', 'couplingMatrix', 'modelStoragePath','abundance','-v7.3')
end

%end of trigger for Autoload
%% PIPELINE: [PART 2.1]

% Now we detect from the content of the results folder If PART2 was already
% computed: if the associated file is already present in the results folder its
% execution is skipped else its execution starts

% If desired, a model of the host (e.g., Recon3D) can also be joined with
% the microbiome models.
if ~isempty(hostPath)
    % workaround for models that give an error in readCbModel
    try
        host = readCbModel(hostPath);
    catch
        warning('Host model could not be read through readCbModel. Consider running verifyModel.')
        modelStruct=load(hostPath);
        getfn=fieldnames(modelStruct);
        host=modelStruct.(getfn{1});
    end
else
    host = {};
end

if ~isempty(host)
    [mapP]=detectOutput(resPath,'Setup_host_allbacs.mat');
else
    [mapP]=detectOutput(resPath,'Setup_allbacs.mat');
end

if isempty(mapP)
    modbuild = 1;
else
    modbuild = 0;
    s= 'global setup file found: loading from resPath and skipping [PART2.1] analysis';
    disp(s)
end
%end of trigger for Autoload

% A  model joining all the reconstructions contained in the study
% will be created in this section. This model will be later used, integrating
% abundances coming from the metagenomic sequencing, to derive the different microbiota
% models. The result of this section will be automatically saved in the results
% folder.

%% PIPELINE: [PART 2]
% Now we will create the different microbiota models integrating the given abundances.
% Coupling constraints and personalized "cumulative biomass" objective functions
% are also added. Models that are already existent will not be recreated, and
% new microbiota models will be saved in the results folder.

% set parallel pool
if numWorkers > 1
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end

% create a separate setup model for each sample
% define what counts as zero abundance
tol=0.0000001;

clear('microbeNames','activeExMets','abundance')

if length(sampNames)>50
    steps=50;
else
    steps=length(sampNames);
end
% proceed in batches for improved effiency
cnt=1;
modelsWithErrors={};

for j=1:steps:length(sampNames)
    if length(sampNames)-j>=steps-1
        endPnt=steps-1;
    else
        endPnt=length(sampNames)-j;
    end
    getErrors={};
    
    parfor i=j:j+endPnt
        % Each personalized model will be created separately.
        % get the list of models for each sample and remove the ones not in
        % this sample
        
        % check if model already exists
        if ~isempty(host)
            mId = strcat('host_microbiota_model_samp_', sampNames{i,1}, '.mat');
        else
            mId = strcat('microbiota_model_samp_', sampNames{i,1}, '.mat');
        end
        if ~isfile(mId)
            
            mappingData=load([resPath filesep 'mapInfo.mat'])
            microbeNamesSample = mappingData.microbeNames;
            couplingMatrixSample = mappingData.couplingMatrix;
            abunRed=mappingData.abundance(:,i+1);
            abunRed=[mappingData.abundance(:,1),abunRed];
            
            microbeNamesSample(cell2mat(abunRed(:,2)) < tol,:)=[];
            couplingMatrixSample(cell2mat(abunRed(:,2)) < tol,:)=[];
            abunRed(cell2mat(abunRed(:,2)) < tol,:)=[];
            setupModel = fastSetupCreator(exMets, modelStoragePath, microbeNamesSample, host, objre);
            
            % create personalized models for the batch
            createdModel=createPersonalizedModel(abunRed,resPath,setupModel,sampNames(i,1),microbeNamesSample,couplingMatrixSample,host,hostBiomassRxn);
            results=verifyModel(createdModel{1});
            getErrors{i} = results;
        end
    end
    for i=j:j+endPnt
        if length(getErrors) >= i
            if ~isempty(getErrors{i})
                modelsWithErrors{cnt,1} = sampNames{i,1};
                cnt=cnt+1;
            end
        end
    end
end

if isempty(modelsWithErrors)
    modelsOK = true;
else
    modelsOK = false;
end

%% PIPELINE: [PART 3]
%
% In this phase, for each microbiota model, a diet, in the form of set constraints
% to the exchanges reactions of the diet compartment, is integrated. Flux Variability
% analysis for all the exchange reactions of the diet and fecal compartment is
% also computed and saved in a file called "simRes".

load([resPath filesep 'mapInfo.mat'])
if computeProfiles || saveConstrModels
    [exchanges, netProduction, netUptake, presol, inFesMat] = microbiotaModelSimulator(resPath, activeExMets, sampNames, dietFilePath, hostPath, hostBiomassRxn, hostBiomassRxnFlux, numWorkers, rDiet, pDiet, saveConstrModels, computeProfiles, includeHumanMets, lowerBMBound, repeatSim, adaptMedium);
    % Finally, NMPCs (net maximal production capability) are computed in a metabolite
    % resolved manner and saved in a comma delimited file in the results folder. NMPCs
    % indicate the maximal production of each metabolite and are computing summing
    % the maximal secretion flux with the maximal uptake flux. Similarity of metabolic
    % profiles (using the different NMPCs as features) between individuals are also
    % evaluated with classical multidimensional scaling.
end

if computeProfiles
    [netSecretionFluxes, netUptakeFluxes, Y] = mgSimResCollect(resPath, sampNames, exchanges, rDiet, pDiet, infoFilePath, netProduction, netUptake, figForm);
else
    netSecretionFluxes={};
    netUptakeFluxes={};
    Y=[];
    delete('simRes.mat','intRes.mat')  
end
if isdir([resPath filesep 'modelStorage'])
    rmdir([resPath filesep 'modelStorage'],'s')
end

% get stats on microbiome models-number of reactions and metabolites
for i=1:length(sampNames)
    modelNames{i}=['microbiota_model_samp_' sampNames{i}];
end

close all

if ~isempty(infoFilePath)
    [modelStats,summary,statistics]=retrieveModelStats(resPath, modelNames, numWorkers, infoFilePath);
else
    [modelStats,summary,statistics]=retrieveModelStats(resPath, modelNames, numWorkers);
end
writetable(cell2table(modelStats),[resPath filesep 'ModelStatistics.csv'], 'WriteVariableNames', false);
writetable(cell2table(summary),[resPath filesep 'ModelStatsSummary.csv'], 'WriteVariableNames', false);
if ~isempty(statistics)
    writetable(cell2table(statistics),[resPath filesep 'ModelStatsStratification.csv'], 'WriteVariableNames', false);
end

end
