function [init, netSecretionFluxes, netUptakeFluxes, Y] = initMgPipe(modPath, abunFilePath, varargin)
% This function is called from the MgPipe driver `StartMgPipe` takes care of saving some variables
% in the environment (in case that the function is called without a driver), does some checks on the
% inputs, and automatically launches MgPipe. As matter of fact, if all the inputs are properly inserted
% in the function it can replace the driver.
%
% INPUTS:
%    modPath:                char with path of directory where models are stored
%    abunFilePath:           char with path and name of file from which to retrieve abundance information
%
% OPTIONAL INPUTS:
%    resPath:                char with path of directory where results are saved
%    dietFilePath:           char with path of directory where the diet is saved
%    infoFilePath:           char with path to stratification criteria if available
%    hostPath:               char with path to host model, e.g., Recon3D (default: empty)
%    hostBiomassRxn:         char with name of biomass reaction in host (default: empty)
%    objre:                  char with reaction name of objective function of organisms
%    buildSetupAll:       	 boolean indicating the strategy that should be used to
%                            build personalized models: if true, build a global setup model 
%                            containing all organisms in at least model (default), false: create
%                            models one by one (recommended for more than ~500 organisms total)
%    saveConstrModels:       boolean indicating if models with imposed
%                            constraints are saved externally
%    numWorkers:             integer indicating the number of cores to use for parallelization
%    rDiet:                  boolean indicating if to enable also rich diet simulations (default: 'false')
%    pDiet:                  boolean indicating if to enable also personalized diet simulations (default: 'false')
%    fvaType:                boolean indicating which function to use for flux variability. true=fastFVa, false=fluxVariability (default: 'true')
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
% .. Author: Federico Baldini 2018
%               - Almut Heinken 02/2020: removed unnecessary outputs
%               - Almut Heinken 08/2020: added extra inputs and changed to
%                                        varargin input
%               - Almut Heinken 01/2021: added option for creation of each 
%                                        personalized model separately


% Define default input parameters if not specified
parser = inputParser();
parser.addRequired('modPath', @ischar);
parser.addRequired('abunFilePath', @ischar);
parser.addParameter('resPath', [pwd filesep 'Results'], @ischar);
parser.addParameter('dietFilePath', 'AverageEuropeanDiet', @ischar);
parser.addParameter('infoFilePath', '', @ischar);
parser.addParameter('hostPath', '', @ischar);
parser.addParameter('hostBiomassRxn', '', @ischar);
parser.addParameter('objre', '', @ischar);
parser.addParameter('buildSetupAll', true, @islogical);
parser.addParameter('saveConstrModels', false, @islogical);
parser.addParameter('numWorkers', 2, @isnumeric);
parser.addParameter('rDiet', false, @islogical);
parser.addParameter('pDiet', false, @islogical);
parser.addParameter('fvaType', true, @islogical);
parser.addParameter('includeHumanMets', true, @islogical);
parser.addParameter('lowerBMBound', 0.4, @isnumeric);
parser.addParameter('repeatSim', false, @islogical);
parser.addParameter('adaptMedium', true, @islogical);

parser.parse(modPath, abunFilePath, varargin{:});

modPath = parser.Results.modPath;
abunFilePath = parser.Results.abunFilePath;
resPath = parser.Results.resPath;
dietFilePath = parser.Results.dietFilePath;
infoFilePath = parser.Results.infoFilePath;
hostPath = parser.Results.hostPath;
hostBiomassRxn = parser.Results.hostBiomassRxn;
objre = parser.Results.objre;
buildSetupAll = parser.Results.buildSetupAll;
saveConstrModels = parser.Results.saveConstrModels;
numWorkers = parser.Results.numWorkers;
rDiet = parser.Results.rDiet;
pDiet = parser.Results.pDiet;
fvaType = parser.Results.fvaType;
includeHumanMets = parser.Results.includeHumanMets;
lowerBMBound = parser.Results.lowerBMBound;
repeatSim = parser.Results.repeatSim;
adaptMedium = parser.Results.adaptMedium;

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end

% set parallel pool
if numWorkers > 1
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end

global CBTDIR

% set optional variables
mkdir(resPath);
    
if ~contains(dietFilePath,'.txt')
   dietFilePath=[dietFilePath '.txt']; 
end
if exist(dietFilePath)==0
    error('Path to file with dietary information is incorrect!');
end

if strcmp(infoFilePath, '')
    patStat = false;
else
    patStat = true;
end

% adding a filesep at the end of the path
if ~strcmpi(resPath(end), filesep)
    resPath = [resPath filesep];
end

if isempty(objre)
   objre = {'EX_biomass(e)'};
   warning(['The default objective (objre) has been set to ' objre{1}]);
else
    objre=cellstr(objre);
end

% define file type for images
figForm = '-depsc';

% Check for installation of parallel Toolbox
try
   version = ver('distcomp');
catch
   error('Sequential mode not available for this application. Please install Parallel Computing Toolbox');
end

if numWorkers > 1
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
else
    error('You disabled parallel mode to enable sequential one. Sequential mode is not available for this application. Please specify a higher number of workers modifying numWorkers option.')
end

if patStat == false
    warning('Individuals health status not declared. Analysis will ignore that.')
end

% output messages
fprintf(' > Models will be read from: %s\n', modPath);
fprintf(' > Results will be stored in: %s\n', resPath);
fprintf(' > Microbiome Toolbox pipeline initialized successfully.\n');

init = true;

[netSecretionFluxes, netUptakeFluxes, Y] = mgPipe(modPath, abunFilePath, resPath, dietFilePath, infoFilePath, hostPath, hostBiomassRxn, objre, buildSetupAll, saveConstrModels, figForm, numWorkers, rDiet, pDiet, fvaType, includeHumanMets, lowerBMBound, repeatSim, adaptMedium);

end
