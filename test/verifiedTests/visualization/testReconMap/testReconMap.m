% The COBRAToolbox: testReconMap.m
%
% Purpose:
%     - tests the functionality of ReconMap to submit a minerva layout.
%       This is done using a test account, that only has 1 layout available
%       the responsewill always be that a layout with that name already exists.
%     - The test is skipped (missing requirement) when the MINERVA server at
%       vmh.life is unreachable, or when it refuses the test account ("Access
%       denied" in its reply to the first upload).
%
% Authors:
%     - Original file: Alberto Noronha 21/03/2017
%     - Skip on refused test account: feature 20261026-220121-fix-ci-test-failures, October 2026
%

global CBT_MISSING_REQUIREMENTS_ERROR_ID

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

% Send the flux distribution to MINERVA. The server's own reply is only printed (the
% returned response is generic), so the console is captured with diary (not evalc, so
% that the reply still reaches the console) to recognise a refused test account.
previousDiaryFile = get(0, 'DiaryFile');
previousDiaryState = get(0, 'Diary');
diary('off');
captureFile = [tempname '.txt'];
diary(captureFile);
response = buildFluxDistLayout(minerva, model, FBAsolution, 'Test - Flux distribution 1');
diary('off');
set(0, 'DiaryFile', previousDiaryFile);
if strcmp(previousDiaryState, 'on')
    diary('on');
end
serverReply = fileread(captureFile);
delete(captureFile);
if ~strcmp(response, 'Overlay generated successfully.') && ...
        (contains(serverReply, 'Access denied') || contains(serverReply, 'Access is denied'))
    minerva.login = oldLogin;
    minerva.password = oldPassword;
    cd(currentDir)
    replyLines = strtrim(splitlines(serverReply));
    replyLine = replyLines{find(contains(replyLines, 'Access'), 1)};
    error(CBT_MISSING_REQUIREMENTS_ERROR_ID, ...
        'The vmh.life MINERVA server refused the test account %s: %s', 'cobratoolbox-test', replyLine);
end

% 2 Correct responses, either successful or layout exists already
%assert(~isempty(regexp(response, strcat('"creator":"', minerva.login, '"'))) | ~isempty(regexp(response, 'ERROR. Layout with given identifier ("Pyruvate metabolism") already exists.')));
assert(strcmp(response,'Overlay generated successfully.'));

% Send the subsystem layout to MINERVA
response = generateSubsytemsLayout(minerva, model, 'Pyruvate metabolism', '#6617B5');

% Same as before - two possible correct responses
%assert(~isempty(regexp(response, strcat('"creator":"', minerva.login, '"'))) | ~isempty(regexp(response, 'ERROR. Layout with given identifier ("Pyruvate metabolism") already exists.')));
assert(strcmp(response,'Overlay generated successfully.'));

minerva.login = oldLogin;
minerva.password = oldPassword;

% change the directory
cd(currentDir)
