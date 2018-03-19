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
%version 1.0 from https://vmh.uni.lu/#downloadview and place the mat files 
%into a folder.

% Federico Baldini, 2017-2018

%% PIPELINE: [PART 1]
% The number of organisms, their names, the number of samples and their identifiers 
% are automatically detected from the input file. 

[patNumb,sampName,strains]=getIndividualSizeName(abunFilePath)
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
% Loading models 
models=loadUncModels(modPath,strains,objre);
% Computing genetic information
[reac,micRea,binOrg,patOrg,reacPat,reacNumb,reacSet,reacTab,reacAbun,reacNumber]=getMappingInfo(models,abunFilePath,patNumb);
writetable(cell2table(reacAbun),strcat(resPath,'reactions.csv'));

% Plotting genetic information
[PCoA]=plotMappingInfo(resPath,patOrg,reacPat,reacTab,reacNumber,patStat,figForm); 

if compMod==1
   mkdir(strcat(resPath,'compfile'))
   csvwrite(strcat(resPath,'compfile/reacTab.csv'),reacTab)
   writetable(cell2table(reacSet),strcat(resPath,'compfile/reacset.csv'))
   csvwrite(strcat(resPath,'compfile/reacNumb.csv'),reacNumb)
   csvwrite(strcat(resPath,'compfile/ReacPat.csv'),reacPat)
   csvwrite(strcat(resPath,'compfile/PCoA_tab.csv'),Y)
end

%Save all the created variables
save(strcat(resPath,'mapInfo.mat'))
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
   setup=fastSetupCreator(models, strains, {})
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

[createdModels]=createPersonalizedModel(abunFilePath,resPath,setup,sampName,strains,patNumb)
%% PIPELINE: [PART 3]
% 
% In this phase, for each microbiota model, a diet, in the form of set constraints 
% to the exchanges reactions of the diet compartment, is integrated. Flux Variability 
% analysis for all the exchange reactions of the diet and fecal compartment is 
% also computed and saved in a file called "simRes".

[ID,fvaCt,nsCt,presol,inFesMat]=microbiotaModelSimulator(resPath,setup,sampName,dietFilePath,rDiet,0,extSolve,patNumb,fvaType)

% Finally, NMPCs (net maximal production capability) are computed in a metabolite 
% resolved manner and saved in a comma delimited file in the results folder. NMPCs 
% indicate the maximal production of each metabolite and are computing summing 
% the maximal secretion flux with the maximal uptake flux. Similarity of metabolic 
% profiles (using the different NMPCs as features) between individuals are also 
% evaluated with classical multidimensional scaling. 

[Fsp,Y]= mgSimResCollect(resPath,ID,rDiet,0,patNumb,patStat,fvaCt,figForm);

