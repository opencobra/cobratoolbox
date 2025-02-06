function [init, netSecretionFluxes, netUptakeFluxes, Y, modelStats, summary, statistics, modelsOK] = initMgPipe(modPath, abunFilePath, computeProfiles, varargin)
% This function initializes the mgPipe pipeline and sets the optional input 
% variables if not defined.
%
% USAGE
%       [init, netSecretionFluxes, netUptakeFluxes, Y, modelStats, summary, statistics, modelsOK] = initMgPipe(modPath, abunFilePath, computeProfiles, varargin)
%
% INPUTS:
%    modPath:                char with path of directory where models are stored
%    abunFilePath:           char with path and name of file from which to retrieve abundance information
%    computeProfiles:        boolean defining whether flux variability analysis to 
%                            compute the metabolic profiles should be performed.
% solver:                    String, indicates which solver is to be used
%                            for solving WBMs. OPTIONAL, defaults to GLPK.
%                            It is highly recommended to use gurobi or cplex
%   
% OPTIONAL INPUTS:
%    resPath:                char with path of directory where results are saved
%    dietFilePath:           char with path of directory where the diet is saved.
%                            Can also be a character array with a separate diet for
%                            each individual, in that case, size(dietFilePath,1) 
%                            needs to equal the length of samples, and the first 
%                            row needs to be sample names and the second row needs to 
%                            be the respective files with diet information.
%    infoFilePath:           char with path to stratification criteria if available
%    biomasses:              Cell array containing names of biomass objective functions
%                            of models to join. Needs to be the same length as 
%                            the length of models in the abundance file.
%    hostPath:               char with path to host model, e.g., Recon3D (default: empty)
%    hostBiomassRxn:         char with name of biomass reaction in host (default: empty)
%    hostBiomassRxnFlux:     double with the desired upper bound on flux through the host
%                            biomass reaction (default: 1)
%    numWorkers:             integer indicating the number of cores to use for parallelization
%    rDiet:                  boolean indicating if to enable also rich diet simulations (default: 'false')
%    pDiet:                  boolean indicating if to enable also personalized diet simulations (default: 'false')
%    lowerBMBound:           lower bound on community biomass (default=0.4)
%    upperBMBound:           upper bound on community biomass (default=1)
%    includeHumanMets:       boolean indicating if human-derived metabolites
%                            present in the gut should be provided to the models (default: true)
%    adaptMedium:            boolean indicating if the medium should be adapted through the
%                            adaptVMHDietToAGORA function or used as is (default=true)
%    pruneModels:            boolean indicating whether reactions that do not carry flux on the
%                            input diet should be removed from the microbe models. 
%                            Recommended for large datasets (default = false)
%
%
% OUTPUTS:
%    init:                   status of initialization
%    netSecretionFluxes:     Net secretion fluxes by microbiome community models
%    netUptakeFluxes:        Net uptake fluxes by microbiome community models
%    Y:                      Classical multidimensional scaling
%    modelStats:             Reaction and metabolite numbers for each model
%    summary:                Table with average, median, minimal, and maximal
%                            reactions and metabolites
%    statistics:             If info file with stratification is provided, will
%                            determine if there is a significant difference.
%    modelsOK:               Boolean indicating if the created microbiome models
%                            passed verifyModel. If true, all models passed.
%
% .. Author: Federico Baldini 2018
%               - Almut Heinken 02/2020: removed unnecessary outputs
%               - Almut Heinken 08/2020: added extra inputs and changed to
%                                        varargin input
%               - Almut Heinken 02/2021: added option for creation of each 
%                                        personalized model separately and
%                                        output of model stats
%               - Almut Heinken 03/2021: inserted error message if 
%                                        abundances are not normalized.
%               - Almut Heinken 12/2022: Added an optional input to manually 
%                                        define biomass objective functions 
%                                        for non-AGORA reconstructions     


% Define default input parameters if not specified
parser = inputParser();
parser.addRequired('modPath', @ischar);
parser.addRequired('abunFilePath', @ischar);
parser.addRequired('computeProfiles', @islogical);
parser.addParameter('solver', '',@ischar);
parser.addParameter('resPath', [pwd filesep 'Results'], @ischar);
parser.addParameter('dietFilePath', @ischar);
parser.addParameter('infoFilePath', '', @ischar);
parser.addParameter('biomasses', {}, @iscell);
parser.addParameter('hostPath', '', @ischar);
parser.addParameter('hostBiomassRxn', '', @ischar);
parser.addParameter('hostBiomassRxnFlux', 1, @isnumeric);
parser.addParameter('numWorkers', 4, @isnumeric);
parser.addParameter('rDiet', false, @islogical);
parser.addParameter('pDiet', false, @islogical);
parser.addParameter('lowerBMBound', 0.4, @isnumeric);
parser.addParameter('upperBMBound', 1, @isnumeric);
parser.addParameter('includeHumanMets', true, @islogical);
parser.addParameter('adaptMedium', true, @islogical);
parser.addParameter('pruneModels', false, @islogical);

parser.parse(modPath, abunFilePath, computeProfiles, varargin{:});

modPath = parser.Results.modPath;
abunFilePath = parser.Results.abunFilePath;
computeProfiles = parser.Results.computeProfiles;
solver = parser.Results.solver;
resPath = parser.Results.resPath;
dietFilePath = parser.Results.dietFilePath;
infoFilePath = parser.Results.infoFilePath;
biomasses = parser.Results.biomasses;
hostPath = parser.Results.hostPath;
hostBiomassRxn = parser.Results.hostBiomassRxn;
hostBiomassRxnFlux = parser.Results.hostBiomassRxnFlux;
numWorkers = parser.Results.numWorkers;
rDiet = parser.Results.rDiet;
pDiet = parser.Results.pDiet;
lowerBMBound = parser.Results.lowerBMBound;
upperBMBound = parser.Results.upperBMBound;
includeHumanMets = parser.Results.includeHumanMets;
adaptMedium = parser.Results.adaptMedium;
pruneModels = parser.Results.pruneModels;

% check if the solver is defined by the user
if ~isempty(solver)
    changeCobraSolver(solver, 'LP')
else
    % otherwise use the default solver (*note: glpk takes excessive time
    % running microbiotaModelSimulator: it is recommeneded to skip this
    % step if you don't have a different solver and manually apply the diet
    % instead using setDietConstraints -Anna Sheehy Jan 2025
    global CBT_LP_SOLVER
    if isempty(CBT_LP_SOLVER)
        initCobraToolbox
    end
end

% set parallel pool
if numWorkers > 1
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end
    
% set optional variables
mkdir(resPath);

currentDir=pwd;

if ~contains(dietFilePath,'.txt')
   dietFilePath=[dietFilePath '.txt']; 
end

if exist(dietFilePath)==0
    error('Path to file with dietary information is incorrect!');
end

% test if abundances are normalized
abundance = readInputTableForPipeline(abunFilePath);
if contains(version,'(R202') % for Matlab R2020a and newer
	totalAbun=sum(cell2mat(abundance(2:end,2:end)),1);
else
	totalAbun=sum(str2double(abundance(2:end,2:end)),1);
end

if any(totalAbun > 1.05)
    error('Abundances are not normalized. Please run the function normalizeCoverage!')
end

if any(~isnan(str2double(abundance(1,2:end))))
    error('Some samples names are numeric. Please change to characters to avoid problems in the pipeline.')
end

% test if biomasses input, if provided, is correct
if ~isempty(biomasses)
    if length(biomasses) ~= size(abundance,1)-1
        error('Length of biomasses input is not equal to the number of models in the abundance file!')
    end
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

% define file type for images
figForm = '-depsc';

% Check for installation of parallel Toolbox
try
   ver('parallel')
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

[netSecretionFluxes, netUptakeFluxes, Y, modelStats, summary, statistics, modelsOK] = mgPipe(modPath, abunFilePath, computeProfiles, resPath, dietFilePath, infoFilePath, biomasses, hostPath, hostBiomassRxn, hostBiomassRxnFlux, figForm, numWorkers, rDiet, pDiet, lowerBMBound, upperBMBound, includeHumanMets, adaptMedium, pruneModels, solver);

cd(currentDir)

end