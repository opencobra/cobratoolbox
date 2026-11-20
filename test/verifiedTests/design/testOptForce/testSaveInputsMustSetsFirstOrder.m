% The COBRAToolbox: testSaveInputsMustSetsFirstOrder.m
%
% Purpose:
%     - saveInputsMustSetsFirstOrder(model, minFluxesW, maxFluxesW, constrOpt, inputFolder)
%       writes the inputs of the first order Must set searches (findMustU, findMustL) to
%       inputFolder: one .mat file per input (model.mat, minFluxesW.mat, maxFluxesW.mat,
%       constrOpt.mat), each holding one variable of the same name, creating the folder if it
%       does not exist and returning to the current folder. It stops with an error when fewer
%       than five inputs are given or when model, minFluxesW, maxFluxesW or inputFolder is
%       empty. The test writes the inputs of a two-reaction model built with createModel into
%       a new nested folder and into an existing folder (both under tempname) and checks the
%       list of files and that every file holds exactly the input given (expected values are
%       the inputs themselves), plus the five errors.
%
% Function under test:
%     src/design/optForce/saveInputsMustSetsFirstOrder.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - file writing of a small model built with createModel; no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Help text of saveInputsMustSetsFirstOrder corrected to match the code (feature 20261120-151023-doc-matches-code), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSaveInputsMustSetsFirstOrder'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a two-reaction model and wild-type flux ranges of matching length
model = createModel({'R1'; 'R2'}, {'first'; 'second'}, {'a -> b'; 'b <=> '}, 'printLevel', 0);
minFluxesW = [0; -5];
maxFluxesW = [10; 0];
constrOpt = struct('rxnList', {{'R1'}}, 'values', 1);
expectedFiles = sort({'constrOpt.mat'; 'maxFluxesW.mat'; 'minFluxesW.mat'; 'model.mat'});

workDir = tempname;
mkdir(workDir);

%% a new (nested) folder is created and holds one file per input

% the folder does not exist yet, so the function creates it (mkdir makes the parents too)
inputFolder = fullfile(workDir, 'level1', 'inputsFirstOrder');
saveInputsMustSetsFirstOrder(model, minFluxesW, maxFluxesW, constrOpt, inputFolder);
% the function changes to inputFolder to save and must return to the folder it started in
assert(strcmp(pwd, fileDir));
writtenFiles = dir(fullfile(inputFolder, '*.mat'));
assert(isequal(sort({writtenFiles.name}'), expectedFiles));
% each file holds exactly one variable named like the file, equal to the input given
% (isequal: saving and loading a .mat file is lossless)
savedModel = load(fullfile(inputFolder, 'model.mat'));
assert(isequal(fieldnames(savedModel), {'model'}) && isequal(savedModel.model, model));
savedMin = load(fullfile(inputFolder, 'minFluxesW.mat'));
assert(isequal(fieldnames(savedMin), {'minFluxesW'}) && isequal(savedMin.minFluxesW, minFluxesW));
savedMax = load(fullfile(inputFolder, 'maxFluxesW.mat'));
assert(isequal(fieldnames(savedMax), {'maxFluxesW'}) && isequal(savedMax.maxFluxesW, maxFluxesW));
savedConstr = load(fullfile(inputFolder, 'constrOpt.mat'));
assert(isequal(fieldnames(savedConstr), {'constrOpt'}) && isequal(savedConstr.constrOpt, constrOpt));

%% an existing folder is used as it is, and an empty constrOpt is saved as well

% constrOpt is not checked for emptiness, so an empty value is written to constrOpt.mat
existingFolder = fullfile(workDir, 'existing');
mkdir(existingFolder);
saveInputsMustSetsFirstOrder(model, minFluxesW, maxFluxesW, [], existingFolder);
assert(strcmp(pwd, fileDir));
writtenFiles = dir(fullfile(existingFolder, '*.mat'));
assert(isequal(sort({writtenFiles.name}'), expectedFiles));
savedConstr = load(fullfile(existingFolder, 'constrOpt.mat'));
assert(isequal(fieldnames(savedConstr), {'constrOpt'}) && isempty(savedConstr.constrOpt));
savedMin = load(fullfile(existingFolder, 'minFluxesW.mat'));
assert(isequal(savedMin.minFluxesW, minFluxesW));

%% errors: too few inputs and empty required inputs

% fewer than five inputs
assert(verifyCobraFunctionError('saveInputsMustSetsFirstOrder', 'inputs', ...
    {model, minFluxesW, maxFluxesW, constrOpt}, ...
    'testMessage', 'OptForce: All inputs must be specified when running saveInputsMustFirstOrder'));
% each required input empty in turn; nothing is written in these cases
errorFolder = fullfile(workDir, 'notCreated');
assert(verifyCobraFunctionError('saveInputsMustSetsFirstOrder', 'inputs', ...
    {[], minFluxesW, maxFluxesW, constrOpt, errorFolder}, ...
    'testMessage', 'OptForce: model must be specified when running saveInputsMustFirstOrder'));
assert(verifyCobraFunctionError('saveInputsMustSetsFirstOrder', 'inputs', ...
    {model, [], maxFluxesW, constrOpt, errorFolder}, ...
    'testMessage', 'OptForce: minFluxesW must be specified when running saveInputsMustFirstOrder'));
assert(verifyCobraFunctionError('saveInputsMustSetsFirstOrder', 'inputs', ...
    {model, minFluxesW, [], constrOpt, errorFolder}, ...
    'testMessage', 'OptForce: maxFluxesW must be specified when running saveInputsMustFirstOrder'));
assert(verifyCobraFunctionError('saveInputsMustSetsFirstOrder', 'inputs', ...
    {model, minFluxesW, maxFluxesW, constrOpt, ''}, ...
    'testMessage', 'OptForce: inputFolder must be specified when running saveInputsMustFirstOrder'));
assert(~exist(errorFolder, 'dir'));

% remove the temporary folder
rmdir(workDir, 's');

% change the directory
cd(currentDir)
