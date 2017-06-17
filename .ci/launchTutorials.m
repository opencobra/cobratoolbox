% include the root folder and all subfolders
addpath(genpath(pwd))

% run the official initialisation script
initCobraToolbox

if ~isempty(strfind(getenv('HOME'), 'jenkins'))
    WAITBAR_TYPE = 0;
else
    WAITBAR_TYPE = 1;
end

% define a success exit code
exitCode = 0;
currentDir = pwd;
try
    % retrieve the models first
    retrieveModels;

    % run an example of sparseLP
    changeCobraSolver('glpk')
    % tutorial_sparseFBA;

    tutorial_IO;

    tutorial_modelManipulation;
    tutorial_modelCreation;

    tutorial_numCharact;

    tutorial_metabotoolsI;
    tutorial_metabotoolsII;

    tutorial_uniformSampling;

    % reset the path.
    cd(currentDir)

    % ensure that we ALWAYS call exit
    exit(exitCode);
catch
    exit(1);
end
