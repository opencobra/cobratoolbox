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
sdiet='EUAverageDiet'
cobrajl=0
newFVA = 0;
%END OF REQUIRED INPUT VARIABLES

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

fprintf('Well done! Pipeline successfully activated and ready to run!')
%%
%PIPELINE LAUNCHER -> Please don't modify this section !
parpool(nwok)
MgPipe
%%
%Don't change inputs 
newFVA = 0;

%Decide what to do with these inputs 
dietpath='Y:\Federico\PD\'; %path from where to read the diet 
hostnam='Recon3'; %name that the host cell will have
dietnam = 'Diet4pipe'; %name of the diet (csv file name without extension)
dietcomp = '[d]'; %name of the diet compartment
fwok = 1; %number of cores dedicated of paralellisation of fastFVA 
comobj={'EX_microbeBiomass[fe]'}; % comunity objective function
reid = '[fe]'; % identifier for set of reactions of which to run FVA (default fecal Exchanges)
modbuild = 1; %if part 2.1 (pan model construction)needs to be excecuted (=1) or not (=0)  (default = 0) 
storvec = 0 % if to save files separately (0) or in one big vector (1)
setspec=1
changeCobraSolver('tomlab_cplex','LP');
setuptype = 2 % 1 = comp + host ; 2 = comp no host ; 3 = no comp harvey compatible

pdiet=0 %if personalised diet is available (disabled for default)
cobrajl=0
dietT='Rich'
fileNameDiets='Rugby-fluxes.xlsx'

fprintf('Well done! Pipeline successfully activated and ready to run!')



