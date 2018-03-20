function [init,modPath,toolboxPath,resPath,dietFilePath,abunFilePath,objre,figForm,solver,numWorkers,autoFix,compMod,patStat,rDiet,extSolve,fvaType,autorun]= initMgPipe(modPath, toolboxPath, resPath, dietFilePath, abunFilePath, objre, figForm, solver, numWorkers, autoFix, compMod, patStat, rDiet,extSolve,fvaType,autorun)
% This function is called from the MgPipe driver `StartMgPipe` takes care of saving some variables
% in the environment (in case that the function is called without a driver), does some checks on the
% inputs, and automatically launches MgPipe. As matter of fact, if all the inputs are properly inserted
% in the function it can replace the driver.
%
% INPUTS:
%    modPath:                char with path of directory where models are stored
%    toolboxPath:            char with path of directory where the toolbox is saved
%    resPath:                char with path of directory where results are saved
%    dietFilePath:           char with path of directory where the diet is saved
%    abunFilePath:           char with path and name of file from which to retrieve abundance information
%    objre:                  char with reaction name of objective function of organisms
%    figForm:                format to use for saving figures
%    numWorkers:             logical indicating the number of cores to use for parallelization
%    autoFix:                double indicating if to try to automatically fix inconsistencies
%    compMod:                logical indicating if outputs in open format should be produced for each section (1=T)
%    patStat:                logical indicating if documentation on health status is available
%    rDiet:                  logical indicating if to enable also rich diet simulations
%    extSolve:               logical indicating if to save the constrained models to solve them externally
%    fvaType:                logical indicating which function to use for flux variability
%    autorun:                logical used to enable /disable autorun behavior (please set to 1)
%
% OUTPUTS:
%    init:                   status of initialization
%    modPath:                char with path of directory where models are stored
%    toolboxPath:            char with path of directory where the toolbox is saved
%    resPath:                char with path of directory where results are saved
%    dietFilePath:           char with path of directory where the diet is saved
%    abunFilePath:           char with path and name of file from which to retrieve abundance information
%    objre:                  char with reaction name of objective function of organisms
%    figForm:                format to use for saving figures
%    numWorkers:             logical indicating the number of cores to use for parallelization
%    autoFix:                double indicating if to try to automatically fix inconsistencies
%    compMod:                logical indicating if outputs in open format should be produced for each section (1=T)
%    patStat:                logical indicating if documentation on health status is available
%    rDiet:                  logical indicating if to enable also rich diet simulations
%    extSolve:               logical indicating if to save the constrained models to solve them externally
%    fvaType:                logical indicating which function to use for flux variability
%    autorun:                logical used to enable /disable autorun behavior (please set to 1)
%
% .. Author: Federico Baldini 2018

init=0;

% Here we go on with the warning section and the autorun
if autorun==1
    if numWorkers >= 2
        poolobj=gcp('nocreate');
        if isempty(poolobj)
            parpool(numWorkers)
        end
    end
    disp('Well done! Pipeline successfully activated and running!')
    MgPipe
else
    if numWorkers >= 2
        poolobj=gcp('nocreate');
        if isempty(poolobj)
            parpool(numWorkers)
        end
    end
    warning('autorun function was disabled. You are now running in manual / debug mode. If this is not what you wanted, change back to ?autorun?=1. Please note that the usage of manual mode is strongly discouraged and should be used only for debugging purposes.')
    edit('MgPipe.m')
end
if compMod == 1
    warning('compatibility mode activated. Output will also be saved in .csv / .sbml format. Time of computations will be affected.')
else
    warning('pipeline output will be saved in .mat format. Please enable compomod option if you wish to activate compatibility mode.')
end

if numWorkers<2
   warning('apparently you disabled parallel mode to enable sequential one. Computations might become very slow. Please modify numWorkers option.')
end
if patStat==0
    disp('Individuals health status not declared. Analysis will ignore that.')
end

init = 1;

end
