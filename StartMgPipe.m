%This script creates the variables through which the required parameters 
%and files are inputted to the metagenomic pipeline (MgPipe). Input 
%variables should be changed by the user according to what specified in the 
%documentation. Running this script will automatically launch the pipeline. 

% Federico Baldini, 2017-2018


%REQUIRED INPUT VARIABLES
modPath='Y:\Federico\Eldermet\191017\models\'; %path to microbiota models
infoPath='Y:\Federico\HMP\Run_Almut_17_03_31_with10_new_strains\'; %path to the aboundance files
resPath='Y:\Federico\HMP\Run_Almut_17_03_31_with10_new_strains\'; %path to results directory 
patnumb = 149; %number of individuals to process (<=total individuals in the study) 
nwok = 3; %number of cores dedicated for parallelisation 
compmod = 0; % if outputs in open formats should be produced for each section (1=T)
patstat = 0; %if documentations on patient health status is provided (0 not 1 yes)
autofix=1 %autofix for names mismatch
figform = '-depsc' %the output is vectorised picture, change to '-dpng' for .png
objre={'EX_biomass(e)'}; %name of objective function of organism
rdiet=0 %to enable rich simulations also 
sdiet='EUAverageDiet' %diet type
cobrajl=0 
newFVA = 0;
%END OF REQUIRED INPUT VARIABLES

%%
%Start warning section
if compmod == 1
    warning('compatibility mode activated. Output will also be saved in .csv / .sbml format. Time of computations will be affected.')    
else
    warning('pipeline output will be saved in .mat format. Please enable compomod option if you wish to activate compatibility mode.')
end

if nwok<2
   warning('apparently you disabled parallel mode to enable sequential one. Computations might become very slow. Please modify nwok option.')
end
if patstat==0
    disp('Individuals health status not declared. Analysis will ignore that.')
end
%end of warning section

%PIPELINE LAUNCHER -> Please don't modify this section !
autorun = 1
if autorun==1
    parpool(nwok)
    disp('Well done! Pipeline successfully activated and running!')
    MgPipe
else
    warning('autorun function was disabled. You are now running in manual / debug mode. If this is not what you wanted change back to ‘autorun’=1. Please note that the usage in manual mode is strongly discouraged and should be used only for debugging pourposes.')
    edit('MgPipe.m')
end

%%



