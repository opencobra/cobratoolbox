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

% retrieve the models first
retrieveModels;

% set a default solver
changeCobraSolver('glpk');
fprintf('Default solver is set to GLPK\n');

eval(tutorialName);

end
