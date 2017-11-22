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

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReconMap'));
cd(fileDir);

% load the ecoli core model
model = getDistributedModel('ecoli_core_model.mat');

% Get the minerva structure
load('minerva.mat');

[status_curl, result_curl] = system(['curl -s -k --head https://vmh.uni.lu/MapViewer/']);

% check if the URL exists
if status_curl == 0 && ~isempty(strfind(result_curl, '200 OK'))
    % Set the user to testing user
    oldLogin = minerva.login;
    oldPassword = minerva.password;
    
    minerva.login = 'cobratoolbox-test';
    minerva.password = 'test';

    % FBA solution for flux distribution
    changeCobraSolver('glpk', 'LP');
    FBAsolution = optimizeCbModel(model, 'max');

    % Send the flux distribution to MINERVA
    response = buildFluxDistLayout(minerva, model, FBAsolution, 'Test - Flux distribution 1');

    % 2 Correct responses, either successful or layout exists already (the
    % latter will happen all the time)
    assert(~isempty(regexp(response, 'Overlay generated successfully!')) | ~isempty(regexp(response, 'ERROR. Layout with given identifier ("Pyruvate metabolism") already exists.')));

    % Send the subsystem layout to MINERVA
    response = generateSubsytemsLayout(minerva, model, 'Pyruvate metabolism', '#6617B5');

    % Same as before - two possible correct responses
    assert(~isempty(regexp(response, 'Overlay generated successfully!')) | ~isempty(regexp(response, 'ERROR. Layout with given identifier ("Pyruvate metabolism") already exists.')));
    
    
    minerva.login = oldLogin;
    minerva.password = oldPassword;
else
    error('The remote repository cannot be reached. Please check your internet connection.');
end

% change the directory
cd(currentDir)
