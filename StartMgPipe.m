%This script creates the variables through which the required parameters 
%and files are inputted to the metagenomic pipeline (MgPipe). Input 
%variables should be changed by the user according to what specified in the 
%documentation. Running this script will automatically launch the pipeline. 

% Federico Baldini, 2017-2018


%REQUIRED INPUT VARIABLES
modPath='\'; %path to microbiota models
dietFilePath='AverageEuropeanDiet'; %path to and name of the text file with dietary information
% path to and name of the csv file with abundance information
abunFilePath='normCoverageReduced.csv';
resPath='\'; %path to results directory 
objre={'EX_biomass(e)'}; %name of objective function of organisms
figForm = '-depsc' %the output is vectorized picture, change to '-dpng' for .png
numWorkers = 3; %number of cores dedicated for parallelization 
autoFix = 1 %autofix for names mismatch
compMod = 0; % if outputs in open formats should be produced for each section (1=T)
patStat = 0; %if documentations on patient health status is provided (0 not 1 yes)
rDiet = 0 %to enable also rich diet simulations 
extSolve = 0 
fvaType = 0;
%END OF REQUIRED INPUT VARIABLES

%%
%PIPELINE LAUNCHER -> Please don't modify this section !
autorun = 1
if autorun==1
    parpool(numWorkers)
    disp('Well done! Pipeline successfully activated and running!')
    MgPipe
else
    warning('autorun function was disabled. You are now running in manual / debug mode. If this is not what you wanted, change back to ‘autorun’=1. Please note that the usage of manual mode is strongly discouraged and should be used only for debugging purposes.')
    edit('MgPipe.m')
end


