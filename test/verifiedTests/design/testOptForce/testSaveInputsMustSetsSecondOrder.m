% The COBRAToolbox: testSaveInputsMustSetsSecondOrder.m
%
% Purpose:
%     - saveInputsMustSetsSecondOrder(model, minFluxesW, maxFluxesW, constrOpt, excludedRxns,
%       inputFolder) writes the inputs of the second order Must set searches (findMustUU,
%       findMustLL, findMustUL) to inputFolder: one .mat file per input (model.mat,
%       minFluxesW.mat, maxFluxesW.mat, constrOpt.mat, excludedRxns.mat), each holding one
%       variable of the same name, creating the folder if it does not exist and returning to
%       the current folder. It stops with an error when fewer than six inputs are given or when
%       model, minFluxesW, maxFluxesW or inputFolder is empty. The test writes the inputs of a
%       two-reaction model built with createModel into a new nested folder and into an existing
%       folder (both under tempname) and checks the list of files and that every file holds
%       exactly the input given (expected values are the inputs themselves), plus the five
%       errors.
%
% Function under test:
%     src/design/optForce/saveInputsMustSetsSecondOrder.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - file writing of a small model built with createModel; no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: the error messages for empty inputs name the first order function
%       SEVERITY: cosmetic
%       TRIGGER: saveInputsMustSetsSecondOrder with an empty model, minFluxesW, maxFluxesW or
%         inputFolder
%       OBSERVED: the messages end with "when running saveInputsMustFirstOrder"
%       EXPECTED: messages naming saveInputsMustSetsSecondOrder
%       LINES: 69, 72, 75, 78
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Help text of saveInputsMustSetsSecondOrder corrected to match the code (feature 20261120-151023-doc-matches-code), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSaveInputsMustSetsSecondOrder'));
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
excludedRxns = {'R2'};
expectedFiles = sort({'constrOpt.mat'; 'excludedRxns.mat'; 'maxFluxesW.mat'; 'minFluxesW.mat'; 'model.mat'});

workDir = tempname;
mkdir(workDir);

%% a new (nested) folder is created and holds one file per input

% the folder does not exist yet, so the function creates it (mkdir makes the parents too)
inputFolder = fullfile(workDir, 'level1', 'inputsSecondOrder');
saveInputsMustSetsSecondOrder(model, minFluxesW, maxFluxesW, constrOpt, excludedRxns, inputFolder);
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
savedExcluded = load(fullfile(inputFolder, 'excludedRxns.mat'));
assert(isequal(fieldnames(savedExcluded), {'excludedRxns'}) && isequal(savedExcluded.excludedRxns, excludedRxns));

%% an existing folder is used as it is, and empty constrOpt and excludedRxns are saved

% constrOpt and excludedRxns are not checked for emptiness, so empty values are written
existingFolder = fullfile(workDir, 'existing');
mkdir(existingFolder);
saveInputsMustSetsSecondOrder(model, minFluxesW, maxFluxesW, [], {}, existingFolder);
assert(strcmp(pwd, fileDir));
writtenFiles = dir(fullfile(existingFolder, '*.mat'));
assert(isequal(sort({writtenFiles.name}'), expectedFiles));
savedConstr = load(fullfile(existingFolder, 'constrOpt.mat'));
assert(isequal(fieldnames(savedConstr), {'constrOpt'}) && isempty(savedConstr.constrOpt));
savedExcluded = load(fullfile(existingFolder, 'excludedRxns.mat'));
assert(iscell(savedExcluded.excludedRxns) && isempty(savedExcluded.excludedRxns));
savedMax = load(fullfile(existingFolder, 'maxFluxesW.mat'));
assert(isequal(savedMax.maxFluxesW, maxFluxesW));

%% errors: too few inputs and empty required inputs

% fewer than six inputs (excludedRxns is required although its help text gives a default)
assert(verifyCobraFunctionError('saveInputsMustSetsSecondOrder', 'inputs', ...
    {model, minFluxesW, maxFluxesW, constrOpt, excludedRxns}, ...
    'testMessage', 'OptForce: All inputs must be specified when running saveInputsMustSecondOrder'));
% each required input empty in turn; nothing is written in these cases
errorFolder = fullfile(workDir, 'notCreated');
assert(verifyCobraFunctionError('saveInputsMustSetsSecondOrder', 'inputs', ...
    {[], minFluxesW, maxFluxesW, constrOpt, excludedRxns, errorFolder}, ...
    'testMessage', 'OptForce: model must be specified when running saveInputsMustFirstOrder'));
assert(verifyCobraFunctionError('saveInputsMustSetsSecondOrder', 'inputs', ...
    {model, [], maxFluxesW, constrOpt, excludedRxns, errorFolder}, ...
    'testMessage', 'OptForce: minFluxesW must be specified when running saveInputsMustFirstOrder'));
assert(verifyCobraFunctionError('saveInputsMustSetsSecondOrder', 'inputs', ...
    {model, minFluxesW, [], constrOpt, excludedRxns, errorFolder}, ...
    'testMessage', 'OptForce: maxFluxesW must be specified when running saveInputsMustFirstOrder'));
assert(verifyCobraFunctionError('saveInputsMustSetsSecondOrder', 'inputs', ...
    {model, minFluxesW, maxFluxesW, constrOpt, excludedRxns, ''}, ...
    'testMessage', 'OptForce: inputFolder must be specified when running saveInputsMustFirstOrder'));
assert(~exist(errorFolder, 'dir'));

% remove the temporary folder
rmdir(workDir, 's');

% change the directory
cd(currentDir)
