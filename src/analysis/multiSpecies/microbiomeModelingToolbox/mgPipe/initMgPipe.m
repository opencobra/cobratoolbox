function [init, modPath, toolboxPath, resPath, dietFilePath, abunFilePath, indInfoFilePath, objre, figForm, numWorkers, autoFix, compMod, rDiet, extSolve, fvaType, autorun] = initMgPipe(modPath, toolboxPath, resPath, dietFilePath, abunFilePath, indInfoFilePath, objre, figForm, numWorkers, autoFix, compMod, rDiet, extSolve, fvaType, autorun, printLevel)
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
%    toolboxPath:            char with path of directory where the toolbox is saved
%    resPath:                char with path of directory where results are saved
%    dietFilePath:           char with path of directory where the diet is saved
%    abunFilePath:           char with path and name of file from which to retrieve abundance information
%    indInfoFilePath:        char indicating, if stratification criteria are available, full path and name to related documentation(default: no)
%    objre:                  char with reaction name of objective function of organisms
%    figForm:                format to use for saving figures
%    numWorkers:             boolean indicating the number of cores to use for parallelization
%    autoFix:                double indicating if to try to automatically fix inconsistencies
%    compMod:                boolean indicating if outputs in open format should be produced for each section (default: `false`)
%    rDiet:                  boolean indicating if to enable also rich diet simulations (default: `false`)
%    extSolve:               boolean indicating if to save the constrained models to solve them externally (default: `false`)
%    fvaType:                boolean indicating which function to use for flux variability (default: `true`)
%    autorun:                boolean used to enable /disable autorun behavior (please set to `true`) (default: `false`)
%    printLevel:             verbose level (default: 1)
%
% OUTPUTS:
%    init:                   status of initialization
%    modPath:                char with path of directory where models are stored
%    toolboxPath:            char with path of directory where the toolbox is saved
%    resPath:                char with path of directory where results are saved
%    dietFilePath:           char with path of directory where the diet is saved
%    abunFilePath:           char with path and name of file from which to retrieve abundance information
%    indInfoFilePath:        char indicating, if stratification criteria are available, full path and name to related documentation(default: no)
%    objre:                  char with reaction name of objective function of organisms
%    figForm:                format to use for saving figures
%    numWorkers:             boolean indicating the number of cores to use for parallelization
%    autoFix:                double indicating if to try to automatically fix inconsistencies
%    compMod:                boolean indicating if outputs in open format should be produced for each section (1=T)
%    patStat:                boolean indicating if documentation on health status is available
%    rDiet:                  boolean indicating if to enable also rich diet simulations
%    extSolve:               boolean indicating if to save the constrained models to solve them externally
%    fvaType:                boolean indicating which function to use for flux variability
%    autorun:                boolean used to enable /disable autorun behavior (please set to 1)
%
% .. Author: Federico Baldini 2018

global CBTDIR

init = false;

% check for mandatory variables
if ~exist('modPath', 'var') || ~exist(modPath, 'dir')
    error('modPath is not defined. Please set the path of the model directory.');
else
    if ~exist(modPath, 'dir')
        error(['modPath (' modPath ') does not exist.']);
    end
end
if ~exist('abunFilePath', 'var') || ~exist(abunFilePath, 'file')
    error('abunFilePath is not set. Please set the absolute path to the abundance file.');
end


% check for optional inputs
if ~exist('toolboxPath', 'var') || ~exist(toolboxPath, 'dir')
    toolboxPath = CBTDIR;
end
if ~exist('resPath', 'var') || ~exist(resPath, 'dir')
    resPath = [CBTDIR filesep '.tmp'];
    warning(['The path to the results has been set to ' resPath]);
    mkdir(resPath);
end
if ~exist('dietFilePath', 'var')|| ~exist(strcat(dietFilePath,'.txt'), 'file')
    dietFilePath=[CBTDIR filesep 'papers' filesep '2018_microbiomeModelingToolbox' filesep 'resources' filesep 'AverageEuropeanDiet'];
    warning(['The path to the results has been set to ' dietFilePath]);
end
if ~exist('indInfoFilePath', 'var')||~exist(indInfoFilePath, 'file')
    patStat = 0;
else
    patStat = 1;
end
if ~exist('indInfoFilePath', 'var')
   indInfoFilePath='nostrat';
end

% adding a filesep at the end of the path
if ~strcmpi(resPath(end), filesep)
    resPath = [resPath filesep];
end
if ~strcmpi(modPath(end), filesep)
    modPath = [modPath filesep];
end

if ~exist('objre', 'var')
   objre = {'EX_biomass(e)'};
   warning(['The default objective (objre) has been set to ' objre{1}]);
end
if ~exist('figForm', 'var')
    figForm = '-depsc';
end
if ~exist('numWorkers', 'var')
    numWorkers = 2;
end
if ~exist('autoFix', 'var')
    autoFix = true;
end
if ~exist('compMod', 'var')
    compMod = false;
end
if ~exist('patStat', 'var')
    patStat = false;
end
if ~exist('rDiet', 'var')
    rDiet = false;
end
if ~exist('extSolve', 'var')
    extSolve = false;
end
if ~exist('fvaType', 'var')
    fvaType = false;
end
if ~exist('autorun', 'var')
    autorun = false;
end
if ~exist('printLevel', 'var')
    printLevel = 1;
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
if compMod && printLevel > 0
    warning('Compatibility mode activated. Output will also be saved in .csv format. Computations might take longer.')
end
if patStat < 1 && printLevel > 0
    warning('Individuals health status not declared. Analysis will ignore that.')
end

% output messages
if printLevel > 0
    fprintf(' > Models will be read from: %s\n', modPath);
    fprintf(' > Results will be stored in: %s\n', resPath);
    fprintf(' > Microbiome Toolbox pipeline initialized successfully.\n');
end

init = true;

if init && autorun
    mgPipe
elseif init && ~autorun
    if printLevel > 0
        warning('autorun function was disabled. You are now running in manual / debug mode. If this is not what you wanted, change back to ?autorun?=1. Please note that the usage of manual mode is strongly discouraged and should be used only for debugging purposes.')
    end
    if usejava('desktop')
        edit('mgPipe.m');
    end
end
end
