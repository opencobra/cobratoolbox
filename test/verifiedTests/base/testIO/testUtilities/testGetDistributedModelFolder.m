% The COBRAToolbox: testGetDistributedModelFolder.m
%
% Purpose:
%     - getDistributedModelFolder returns the folder of a model distributed for testing:
%       test/models/mat for a .mat file, test/models/xml for an .xml file, test/models for any
%       other extension, and warns when the file is not there. Expected folders are built
%       from CBTDIR and the documented layout; the existing files are ecoli_core_model.mat,
%       ecoli_core_model.xml and the README.md of test/models.
%
% Function under test:
%     src/base/io/utilities/getDistributedModelFolder.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - look-up of a distributed model folder, no model loaded, no solver.
%
% Coverage exemptions:
%     Lines 21-23: need an empty CBTDIR, which makes the function run initCobraToolbox; that
%     resets the path and solver state of the running test session, so it is not run here.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: the warning shows a literal \n
%       SEVERITY: cosmetic
%       TRIGGER: getDistributedModelFolder('noSuch.mat')
%       OBSERVED: MATLAB R2025a: "Requested Model not present in the model directory.\n This is
%       either due to ..." - warning is called with the message only, so the escape sequence
%       is not interpreted
%       EXPECTED: a line break in the warning text
%       LINES: 37
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetDistributedModelFolder'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

global CBTDIR
modelsFolder = [CBTDIR filesep 'test' filesep 'models'];

%% a .mat model is in test/models/mat, an .xml model in test/models/xml

assert(isequal(getDistributedModelFolder('ecoli_core_model.mat'), [modelsFolder filesep 'mat']));
assert(isequal(getDistributedModelFolder('ecoli_core_model.xml'), [modelsFolder filesep 'xml']));

%% any other extension is looked up in test/models itself

assert(isequal(getDistributedModelFolder('README.md'), modelsFolder));

%% a model that is not there: the folder is still returned, with a warning

lastwarn('');
modelDir = getDistributedModelFolder('noSuchModel.mat');
assert(isequal(modelDir, [modelsFolder filesep 'mat']));
% only the text before the defective escape sequence is checked
assert(startsWith(lastwarn(), 'Requested Model not present in the model directory.'));

% change the directory
cd(currentDir)
