function runTutorial(tutorialName)

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
    changeCobraSolver('glpk');
    fprintf('Default solver is set to GLPK\n');

    eval(tutorialName);

    % reset the path.
    cd(currentDir)

    % ensure that we ALWAYS call exit
    exit(exitCode);
catch
    exit(1);
end

end
