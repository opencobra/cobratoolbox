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
load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');

% Get the minerva structure
load('minerva.mat');

[status_curl, result_curl] = system(['curl -s -k --head ', minerva.minervaURL]);

% check if the URL exists
if status_curl == 0 && ~isempty(strfind(result_curl, '200 OK'))
    % Set the user to testing user
    minerva.login = 'cobratoolbox-test';
    minerva.password = 'test';

    % FBA solution for flux distribution
    changeCobraSolver('glpk', 'LP');
    FBAsolution = optimizeCbModel(model, 'max');

    % Send the flux distribution to MINERVA
    response = buildFluxDistLayout(minerva, model, FBAsolution, 'Test - Flux distribution 1');

    % 2 Correct responses, either successful or layout exists already (the
    % latter will happen all the time)
    assert(~(strcmpi(response{1,2}, 'Overlay was sucessfully sent to ReconMap!') == 0 && strcmpi(response{1,2}, 'ERROR. Layout with given identifier ("Test - Flux distribution 1") already exists.') == 0));

    % Send the subsystem layout to MINERVA
    response = generateSubsytemsLayout(minerva, model, 'Pyruvate metabolism', '#6617B5');

    % Same as before - two possible correct responses
    assert(~(strcmpi(response{1,2}, 'Overlay was sucessfully sent to ReconMap!') == 0 && strcmpi(response{1,2}, 'ERROR. Layout with given identifier ("Pyruvate metabolism") already exists.') == 0));
else
    fprintf([' --> ', minerva.minervaURL, ' cannot be reached.\nPlease check your connection. Skipping test.\n\n']);
end

% change the directory
cd(currentDir)
