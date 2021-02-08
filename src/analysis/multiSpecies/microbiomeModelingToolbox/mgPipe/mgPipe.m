function [netSecretionFluxes, netUptakeFluxes, Y] = mgPipe(modPath, abunFilePath, computeProfiles, resPath, dietFilePath, infoFilePath, hostPath, hostBiomassRxn, hostBiomassRxnFlux, objre, buildSetupAll, saveConstrModels, figForm, numWorkers, rDiet, pDiet, includeHumanMets, lowerBMBound, repeatSim, adaptMedium)

%MgPipe is a MATLAB based pipeline to integrate microbial abundances
%(coming from metagenomic data) with constraint based modeling, creating
%individuals' personalized models.
%The pipeline is divided in 3 parts:
%[PART 1] Analysis of individuals' specific microbes abundances are computed.
%[PART 2]: 1 Constructing a global metabolic model (setup) containing all the
%microbes listed in the study. 2 Building individuals' specific models
%integrating abundance data retrieved from metagenomics. For each organism,
%reactions are coupled to the objective function.
%[PART 3] Simulations under different diet regimes.
%MgPipe was created (and tested) for AGORA 1.0 please first download AGORA
%version 1.0 from https://www.vmh.life/#downloadview and place the mat files
%into a folder.
%
% USAGE:
%       [netSecretionFluxes, netUptakeFluxes, Y, constrModelsPath] = mgPipe(modPath, abunFilePath, computeProfiles, resPath, dietFilePath, infoFilePath, hostPath, hostBiomassRxn, hostBiomassRxnFlux, objre, buildSetupAll, saveConstrModels, figForm, numWorkers, rDiet, pDiet, includeHumanMets, lowerBMBound, repeatSim, adaptMedium)
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
%    objre:                  char with reaction name of objective function of microbeNames
%    buildSetupAll:       	 boolean indicating the strategy that should be used to
%                            build personalized models: if true, build a global setup model 
%                            containing all organisms in at least model (default), false: create
%                            models one by one (recommended for more than ~500 organisms total)
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
%    adaptMedium:            boolean indicating if the medium should be
%                            adapted through the adaptVMHDietToAGORA
%                            function or used as is (default=true)                  
%
% OUTPUTS:
%    init:                   status of initialization
%    netSecretionFluxes:     Net secretion fluxes by microbiome community models
%    netUptakeFluxes:        Net uptake fluxes by microbiome community models
%    Y:                      Classical multidimensional scaling
%
% AUTHORS:
%   - Federico Baldini, 2017-2018
%   - Almut Heinken, 07/20: converted to function
%   - Almut Heinken, 01/21: added option for creation of each personalized model separately

%% PIPELINE: [PART 1]
% The number of microbeNames, their names, the number of samples and their identifiers
% are automatically detected from the input file.

[sampNames,microbeNames]=getIndividualSizeName(abunFilePath);
%%
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

    % Computing genetic information
    [reac,exMets,micRea,binOrg,patOrg,reacPat,reacNumb,reacSet,reacTab,reacAbun,reacNumber]=getMappingInfo(modPath,microbeNames,abunFilePath);
    writetable(cell2table(reacAbun,'VariableNames',['Reactions';sampNames]'),strcat(resPath,'reactions.csv'));
    
      %Create tables and save all the created variables
    reacTab=[array2table(reac),array2table(reacTab,'VariableNames',sampNames')],[resPath 'compfile' filesep 'ReacTab.csv'];
    reacSet=cell2table(reacSet,'VariableNames',sampNames');
    reacPat=[array2table(microbeNames),array2table(reacPat,'VariableNames',sampNames')];
end

% Plotting genetic information
[PCoA]=plotMappingInfo(resPath,patOrg,reacPat,reacTab,reacNumber,infoFilePath,figForm,sampNames,microbeNames);

save([resPath filesep 'mapInfo.mat'],'binOrg', 'mapP', 'exMets', 'micRea', 'patOrg', 'PCoA', 'reac', 'reacAbun', 'reacNumb', 'reacNumber', 'reacPat', 'reacSet', 'reacTab', 'sampNames', 'microbeNames')

%end of trigger for Autoload
%% PIPELINE: [PART 2.1]

% Now we detect from the content of the results folder If PART2 was already
% computed: if the associated file is already present in the results folder its
% execution is skipped else its execution starts

[mapP]=detectOutput(resPath,'Setup_allbacs.mat');

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

% If desired, a model of the host (e.g., Recon3D) can also be joined with
% the microbiome models.
if ~isempty(hostPath)
    % host = readCbModel(hostPath);
    modelStruct=load(hostPath);
    getfn=fieldnames(modelStruct);
    host=modelStruct.(getfn{1});
else
    host = {};
end

%% PIPELINE: [PART 2]
% Now we will create the different microbiota models integrating the given abundances.
% Coupling constraints and personalized "cumulative biomass" objective functions
% are also added. Models that are already existent will not be recreated, and
% new microbiota models will be saved in the results folder.

abundance = table2cell(readtable(abunFilePath));

% if there is 500 reconstruction total or less, use fast setup creator to
% carve each personalized model from one large setup model.
if buildSetupAll
    if modbuild == 1
        setup=fastSetupCreator(modPath, microbeNames, host, objre, numWorkers);
        setup.name='Global reconstruction with lumen / fecal compartments no host';
        setup.recon=0;
        save(strcat(resPath,'Setup_allbacs.mat'), 'setup')
    end
    
    if modbuild==0
        load(strcat(resPath,'Setup_allbacs.mat'))
    end
    
    [createdModels]=createPersonalizedModel(abundance,resPath,setup,sampNames,microbeNames,host,hostBiomassRxn);
    
else
    % create a separate setup model for each sample
    % define what counts as zero abundance
    tol=0.0000001;
    
    for i=1:length(sampNames)
        % Here, we will not be starting from one joined model containing all
        % reconstructions. Instead, each personalized model will be created separately.)
        % get the list of models for each sample and remove the ones not in
        % this sample
        
        % retrieving current model ID
        if ~isempty(host)
            mId = [resPath filesep 'host_microbiota_model_samp_', sampNames{k,1}, '.mat'];
        else
            mId = [resPath filesep 'microbiota_model_samp_', sampNames{k,1}, '.mat'];
        end
        
        % if the model doesn't exist yet
        mapP = detectOutput(resPath, mId);
        if isempty(mapP) 
            microbeNamesSample = microbeNames;
            abunRed=abundance(:,i+1);
            abunRed=[abundance(:,1),abunRed];
            microbeNamesSample(cell2mat(abunRed(:,2)) < tol,:)=[];
            abunRed(cell2mat(abunRed(:,2)) < tol,:)=[];
            setupModel = fastSetupCreator(modPath, microbeNamesSample, host, objre, numWorkers);
            createdModel=createPersonalizedModel(abunRed,resPath,setupModel,sampNames(i,1),microbeNamesSample,host,hostBiomassRxn);
        end
    end
end

%% PIPELINE: [PART 3]
%
% In this phase, for each microbiota model, a diet, in the form of set constraints
% to the exchanges reactions of the diet compartment, is integrated. Flux Variability
% analysis for all the exchange reactions of the diet and fecal compartment is
% also computed and saved in a file called "simRes".

[exchanges, fvaCt, nsCt, presol, inFesMat] = microbiotaModelSimulator(resPath, exMets, sampNames, dietFilePath, hostPath, hostBiomassRxn, hostBiomassRxnFlux, numWorkers, rDiet, pDiet, saveConstrModels, computeProfiles, includeHumanMets, lowerBMBound, repeatSim, adaptMedium);
% Finally, NMPCs (net maximal production capability) are computed in a metabolite
% resolved manner and saved in a comma delimited file in the results folder. NMPCs
% indicate the maximal production of each metabolite and are computing summing
% the maximal secretion flux with the maximal uptake flux. Similarity of metabolic
% profiles (using the different NMPCs as features) between individuals are also
% evaluated with classical multidimensional scaling.

[netSecretionFluxes, netUptakeFluxes, Y] = mgSimResCollect(resPath, sampNames, exchanges, rDiet, pDiet, infoFilePath, fvaCt, nsCt, figForm);
end
