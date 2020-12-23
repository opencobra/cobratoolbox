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
%    indInfoFilePath:        char indicating, if stratification criteria are available, full path and name to related documentation(default: no)
%    objre:                  char with reaction name of objective function of organisms
%    figForm:                format to use for saving figures
%    numWorkers:             integer indicating the number of cores to use for parallelization
%    autoFix:                double indicating if to try to automatically fix inconsistencies
%    compMod:                boolean indicating if outputs in open format should be produced for each section (default: `false`)
%    rDiet:                  boolean indicating if to enable also rich diet simulations (default: 'false')
%    pDiet:                  boolean indicating if to enable also personalized diet simulations (default: 'false')
%    extSolve:               boolean indicating if to save the constrained models to solve them externally (default: `false`)
%    fvaType:                boolean indicating which function to use for flux variability. true=fastFVa, false=fluxVariability (default: 'true')
%    printLevel:             verbose level (default: true)
%    includeHumanMets:       boolean indicating if human-derived metabolites
%                            present in the gut should be provided to the models (default: true)
%    lowerBMBound:           lower bound on community biomass (default=0.4)
%    repeatSim:              boolean defining if simulations should be repeated and previous results
%                            overwritten (default=false)
%    adaptMedium             boolean indicating if the medium should be
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
%
% Define default input parameters if not specified
parser = inputParser();
parser.addRequired('modPath', @ischar);
parser.addRequired('abunFilePath', @ischar);
parser.addParameter('resPath', '', @ischar);
parser.addParameter('dietFilePath', '', @ischar);
parser.addParameter('indInfoFilePath', 'nostrat', @ischar);
parser.addParameter('objre', '', @ischar);
parser.addParameter('figForm', '-depsc', @ischar);
parser.addParameter('numWorkers', 2, @isnumeric);
parser.addParameter('autoFix', true, @islogical);
parser.addParameter('compMod', false, @islogical);
parser.addParameter('rDiet', false, @islogical);
parser.addParameter('pDiet', false, @islogical);
parser.addParameter('extSolve', false, @islogical);
parser.addParameter('fvaType', true, @islogical);
parser.addParameter('printLevel', true, @islogical);
parser.addParameter('includeHumanMets', true, @islogical);
parser.addParameter('lowerBMBound', 0.4, @isnumeric);
parser.addParameter('repeatSim', false, @islogical);
parser.addParameter('adaptMedium', true, @islogical);

parser.parse(modPath, abunFilePath, varargin{:});

modPath = parser.Results.modPath;
abunFilePath = parser.Results.abunFilePath;
resPath = parser.Results.resPath;
dietFilePath = parser.Results.dietFilePath;
indInfoFilePath = parser.Results.indInfoFilePath;
objre = parser.Results.objre;
figForm = parser.Results.figForm;
numWorkers = parser.Results.numWorkers;
autoFix = parser.Results.autoFix;
compMod = parser.Results.compMod;
rDiet = parser.Results.rDiet;
pDiet = parser.Results.pDiet;
extSolve = parser.Results.extSolve;
fvaType = parser.Results.fvaType;
printLevel = parser.Results.printLevel;
includeHumanMets = parser.Results.includeHumanMets;
lowerBMBound = parser.Results.lowerBMBound;
repeatSim = parser.Results.repeatSim;
adaptMedium = parser.Results.adaptMedium;

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end

global CBTDIR

% set optional variables
if ~exist('resPath', 'var') || ~exist(resPath, 'dir')
    resPath = [CBTDIR filesep '.tmp'];
    warning(['The path to the results has been set to ' resPath]);
    mkdir(resPath);
end
if ~exist('dietFilePath', 'var')|| ~exist(strcat(dietFilePath,'.txt'), 'file')
    dietFilePath=[CBTDIR filesep 'papers' filesep '2018_microbiomeModelingToolbox' filesep 'resources' filesep 'AverageEuropeanDiet'];
    warning(['The path to the results has been set to ' dietFilePath]);
end

if strcmp('indInfoFilePath', 'nostrat')
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

% Here we go on with the warning section and the autorun
if compMod && printLevel
    warning('Compatibility mode activated. Output will also be saved in .csv format. Computations might take longer.')
end
if patStat == false && printLevel
    warning('Individuals health status not declared. Analysis will ignore that.')
end

% output messages
if printLevel
    fprintf(' > Models will be read from: %s\n', modPath);
    fprintf(' > Results will be stored in: %s\n', resPath);
    fprintf(' > Microbiome Toolbox pipeline initialized successfully.\n');
end

init = true;

[netSecretionFluxes, netUptakeFluxes, Y] = mgPipe(modPath, resPath, dietFilePath, abunFilePath, indInfoFilePath, objre, figForm, autoFix, compMod, rDiet, pDiet, extSolve, fvaType, includeHumanMets, lowerBMBound, repeatSim, adaptMedium);

end
