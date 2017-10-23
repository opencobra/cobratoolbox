function runTutorial(tutorialName)
% Runs the given tutorial after initialising The COBRA Toolbox.
%
% USAGE:
%
%    runTutorial(tutorialName)
%
% INPUT:
%    tutorialName:       string containing the name of the tutorial to be run
%
% .. Author: Sylvain Arreckx, June 2017

global WAITBAR_TYPE;
global ENV_VARS;
WAITBAR_TYPE = 0;  % Mute progress bars
ENV_VARS.printLevel = 0;  % Mute initCobraToolbox

addpath(pwd)  % include the root folder

% run the official initialisation script
initCobraToolbox

% set a default solver
changeCobraSolver('glpk');
fprintf('Default solver is set to GLPK\n');

try
    eval(tutorialName);

    % ensure that we ALWAYS call exit
    exit;
catch ME
    getReport(ME, 'extended')
    exit(1);
end
