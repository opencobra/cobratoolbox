function [netSecretionFluxes, netUptakeFluxes, Y] = mgPipe(modPath, resPath, dietFilePath, abunFilePath, indInfoFilePath, objre, figForm, autoFix, compMod, rDiet, pDiet, extSolve, fvaType, includeHumanMets, lowerBMBound, repeatSim, adaptMedium)
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
% [netSecretionFluxes, netUptakeFluxes, Y] = mgPipe(modPath, resPath, dietFilePath, abunFilePath, indInfoFilePath, objre, figForm, autoFix, compMod, rDiet, pDiet, extSolve, fvaType, includeHumanMets, lowerBMBound, repeatSim, adaptMedium)
%
% AUTHORS:
%   - Federico Baldini, 2017-2018
%   - Almut Heinken, 07/20: converted to function

%% PIPELINE: [PART 1]
% The number of organisms, their names, the number of samples and their identifiers
% are automatically detected from the input file.

[patNumb,sampName,strains]=getIndividualSizeName(abunFilePath);
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

[mapP]=detectOutput(resPath,'mapInfo.mat')
if isempty(mapP)
    % check if AGORA models are in path
    if ~exist('modPath', 'var') || ~exist(modPath, 'dir')
        error('modPath is not defined. Please set the path of the model directory.');
    else
        if ~exist(modPath, 'dir')
            error(['modPath (' modPath ') does not exist.']);
        end
    end
    % adding a filesep at the end of the path
    if ~strcmpi(modPath(end), filesep)
        modPath = [modPath filesep];
    end
% Loading models
models=loadUncModels(modPath,strains,objre);
% Computing genetic information
[reac,micRea,binOrg,patOrg,reacPat,reacNumb,reacSet,reacTab,reacAbun,reacNumber]=getMappingInfo(models,abunFilePath,patNumb);
writetable(cell2table(reacAbun,'VariableNames',['Reactions';sampName]'),strcat(resPath,'reactions.csv'));

% Plotting genetic information
[PCoA]=plotMappingInfo(resPath,patOrg,reacPat,reacTab,reacNumber,indInfoFilePath,figForm,sampName,strains);

if compMod==1
   mkdir(strcat(resPath,'compfile'))
   writetable([array2table(reac),array2table(reacTab,'VariableNames',sampName')],[resPath 'compfile' filesep 'ReacTab.csv'])
   writetable(cell2table(reacSet,'VariableNames',sampName'),[resPath 'compfile' filesep 'reacSet.csv'])
   writetable([array2table(strains),array2table(reacPat,'VariableNames',sampName')],[resPath 'compfile' filesep 'ReacPat.csv'])
   csvwrite(strcat(resPath,'compfile/PCoA_tab.csv'),PCoA)
end

%Create tables and save all the created variables
reacTab=[array2table(reac),array2table(reacTab,'VariableNames',sampName')],[resPath 'compfile' filesep 'ReacTab.csv'];
reacSet=cell2table(reacSet,'VariableNames',sampName');
reacPat=[array2table(strains),array2table(reacPat,'VariableNames',sampName')];

 
save([resPath filesep 'mapInfo.mat'],'binOrg', 'compMod',  'mapP', 'micRea', 'models', 'patNumb', 'patOrg', 'PCoA', 'reac', 'reacAbun', 'reacNumb', 'reacNumber', 'reacPat', 'reacSet', 'reacTab', 'sampName', 'strains')
end
%end of trigger for Autoload
%% PIPELINE: [PART 2.1]
% Checking consistence of inputs: if autofix == 0 halts execution with error
% msg if inconsistences are detected, otherwise it really tries hard to fix the
% problem and continues execution when possible.

[autoStat,fixVec,strains]=checkNomenConsist(strains,autoFix);

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

if modbuild == 1
   setup=fastSetupCreator(models, strains, {},objre)
   setup.name='Global reconstruction with lumen / fecal compartments no host';
   setup.recon=0;
   save(strcat(resPath,'Setup_allbacs.mat'), 'setup')
end

if modbuild==0
load(strcat(resPath,'Setup_allbacs.mat'))
end
%% PIPELINE: [PART 2.2]
% Now we will create the different microbiota models integrating the given abundances.
% Coupling constraints and personalized "cumulative biomass" objective functions
% are also added. Models that are already existent will not be recreated, and
% new microbiota models will be saved in the results folder.

[createdModels]=createPersonalizedModel(abunFilePath,resPath,setup,sampName,strains,patNumb);
%% PIPELINE: [PART 3]
%
% In this phase, for each microbiota model, a diet, in the form of set constraints
% to the exchanges reactions of the diet compartment, is integrated. Flux Variability
% analysis for all the exchange reactions of the diet and fecal compartment is
% also computed and saved in a file called "simRes".

[ID, fvaCt, nsCt, presol, inFesMat] = microbiotaModelSimulator(resPath, setup, sampName, dietFilePath, rDiet, pDiet, extSolve, patNumb, fvaType, includeHumanMets, lowerBMBound,repeatSim,adaptMedium);
% Finally, NMPCs (net maximal production capability) are computed in a metabolite
% resolved manner and saved in a comma delimited file in the results folder. NMPCs
% indicate the maximal production of each metabolite and are computing summing
% the maximal secretion flux with the maximal uptake flux. Similarity of metabolic
% profiles (using the different NMPCs as features) between individuals are also
% evaluated with classical multidimensional scaling.

[netSecretionFluxes, netUptakeFluxes, Y] = mgSimResCollect(resPath, ID, sampName, rDiet, pDiet, patNumb, indInfoFilePath, fvaCt, nsCt, figForm);
end
