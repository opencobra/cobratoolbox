%This script creates the variables through which the required parameters 
%and files are inputted to the metagenomic pipeline (MgPipe). Input 
%variables should be changed by the user according to what specified in the 
%documentation. Running this script will automatically launch the pipeline. 

% Federico Baldini, 2017-2018


%REQUIRED INPUT VARIABLES

% path to microbe models
modPath='YOUR_PATH_TO_AGORA\';
% path to where the Microbiome Modeling Toolbox is located
toolboxPath='YOUR_PATH_TO_Microbiome_Modeling_Toolbox\'
% path where to save results
resPath='YOUR PATH TO RESULT FOLDER\' ;
% path to and name of the file with dietary information.
dietFilePath=strcat(toolboxPath,'DietImplementation/AverageEuropeanDiet');
% path to and name of the file with abundance information.
abunFilePath=strcat(toolboxPath,'Resources/normCoverage.csv');
% name of objective function of organisms
objre={'EX_biomass(e)'};
%the output is vectorized picture, change to '-dpng' for .png
figForm = '-depsc'
% number of cores dedicated for parallelization 
numWorkers = 3;
% autofix for names mismatch
autoFix = 1 
% if outputs in open formats should be produced for each section (1=T)
compMod = 0; 
% if documentations on patient health status is provided (0 not 1 yes)
patStat = 0; 
% to enable also rich diet simulations 
rDiet = 0; 
% if if to use an external solver and save models with diet
extSolve = 0; 
% the type of FVA function to use to solve
fvaType = 1; 
% To tourn off the autorun to be able to manually execute each part of the pipeline.
autorun=1; 
%END OF REQUIRED INPUT VARIABLES

%%
%PIPELINE LAUNCHER 
[init,modPath,toolboxPath,resPath,dietFilePath,abunFilePath,objre,figForm,numWorkers,autoFix,compMod,patStat,rDiet,extSolve,fvaType,autorun]= initMgPipe(modPath, toolboxPath, resPath, dietFilePath, abunFilePath, objre, figForm, numWorkers, autoFix, compMod, patStat, rDiet,extSolve,fvaType,autorun);


