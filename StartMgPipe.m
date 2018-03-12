%This script creates the variables through which the required parameters 
%and files are inputted to the metagenomic pipeline (MgPipe). Input 
%variables should be changed by the user according to what specified in the 
%documentation. Running this script will automatically launch the pipeline. 

% Federico Baldini, 2017-2018


%REQUIRED INPUT VARIABLES

%path to microbiota models
modPath='\';
%path to and name of the text file with dietary information
dietFilePath='AverageEuropeanDiet'; 
% path to and name of the csv file with abundance information
abunFilePath='normCoverageReduced.csv';
%path to results directory 
resPath='\'; 
%name of objective function of organisms
objre={'EX_biomass(e)'};
%the output is vectorized picture, change to '-dpng' for .png
figForm = '-depsc' 
%number of cores dedicated for parallelization 
numWorkers = 3;
%autofix for names mismatch
autoFix = 1 
% if outputs in open formats should be produced for each section (1=T)
compMod = 0; 
%if documentations on patient health status is provided (0 not 1 yes)
patStat = 0;
%to enable also rich diet simulations 
rDiet = 0 
extSolve = 0 
fvaType = 0;
%END OF REQUIRED INPUT VARIABLES

%%
%PIPELINE LAUNCHER 
[init,modPath,toolboxPath,resPath,dietFilePath,abunFilePath,objre,figForm,solver,numWorkers,autoFix,compMod,patStat,rDiet,extSolve,fvaType,autorun]= initMgPipe(modPath, toolboxPath, resPath, dietFilePath, abunFilePath, objre, figForm, solver, numWorkers, autoFix, compMod, patStat, rDiet,extSolve,fvaType,autorun);


