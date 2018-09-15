% The COBRAToolbox: testReconMap.m
%
% Purpose:
%     - tests the functionality of ReconMap to submit a minerva layout.
%       This is done using a test account, that only has 1 layout available
%       the responsewill always be that a layout with that name already exists.
%
% Authors:
%     - Original file: Alberto Noronha 21/03/2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReconMap'));
cd(fileDir);

% load the ecoli core model
model = getDistributedModel('ecoli_core_model.mat');

% Get the minerva structure
load('minerva.mat');

prepareTest('needsWebAddress','https://www.vmh.life/minerva/')

% check if the URL exists
% Set the user to testing user
oldLogin = minerva.login;
oldPassword = minerva.password;

minerva.login = 'cobratoolbox-test';
minerva.password = 'test';
minerva.googleLicenseConsent = 'true';

% FBA solution for flux distribution
changeCobraSolver('glpk', 'LP');
FBAsolution = optimizeCbModel(model, 'max');

% Send the flux distribution to MINERVA
response = buildFluxDistLayout(minerva, model, FBAsolution, 'Test - Flux distribution 1');

% 2 Correct responses, either successful or layout exists already
assert(~isempty(regexp(response, strcat('"creator":"', minerva.login, '"'))) | ~isempty(regexp(response, 'ERROR. Layout with given identifier ("Pyruvate metabolism") already exists.')));

% Send the subsystem layout to MINERVA
response = generateSubsytemsLayout(minerva, model, 'Pyruvate metabolism', '#6617B5');

% Same as before - two possible correct responses
assert(~isempty(regexp(response, strcat('"creator":"', minerva.login, '"'))) | ~isempty(regexp(response, 'ERROR. Layout with given identifier ("Pyruvate metabolism") already exists.')));


minerva.login = oldLogin;
minerva.password = oldPassword;

% change the directory
cd(currentDir)
