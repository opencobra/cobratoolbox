% include the root folder and all subfolders
addpath(genpath(pwd))

% run the official initialisation script
initCobraToolbox

% Mute progress bars and initCobraToolbox
global WAITBAR_TYPE;
global ENV_VARS;
WAITBAR_TYPE = 0;
ENV_VARS.printLevel = 0;

% define a success exit code
exitCode = 0;
currentDir = pwd;
try
    % retrieve the models first
    retrieveModels;

    % run an example of sparseLP
    changeCobraSolver('glpk')
    % tutorial_sparseFBA;

    tutorials = {'tutorial_IO', ...
                 'tutorial_modelManipulation', ...
                 'tutorial_modelCreation', ...
                 'tutorial_numCharact', ...
                 'tutorial_metabotoolsI', ...
                 'tutorial_metabotoolsII', ...
                 'tutorial_uniformSampling'};

    for k = 1:length(tutorials)
        tutorial = tutorials{k};
        fprintf('Starting %s  (WAITBAR_TYPE:%d)\n', tutorial, WAITBAR_TYPE);
        eval(tutorial);
        fprintf('%s is done!\n\n\n\n\n', tutorial);
    end
    % reset the path.
    cd(currentDir)

    % ensure that we ALWAYS call exit
    exit(exitCode);
catch
    exit(1);
end
