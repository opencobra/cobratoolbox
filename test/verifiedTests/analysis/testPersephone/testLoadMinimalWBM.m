% The COBRAToolbox: testLoadMinimalWBM.m
%
% Purpose:
%     - loadMinimalWBM loads from a .mat file only the fields of a whole-body model that FBA
%       needs (ID, S, ub, lb, rxns, mets, c, d, csense, dsense, osenseStr, C, plus sex and
%       SetupInfo) and falls back to loading the whole file, un-nesting a single variable,
%       when a required field is missing. This test writes a small stand-in model (the
%       fields of a WBM, two metabolites and three reactions, plus two fields FBA does not
%       need) in the three layouts a WBM file can have and checks what is returned: the
%       fields as variables (minimal load without the extra fields, char and string path),
%       the model nested in one variable (full load and un-nesting), and the fields as
%       variables with C missing (full load returned as it is, extra fields included). No
%       whole-body model is downloaded or loaded.
%
% Function under test:
%     src/analysis/persephone/loadMinimalWBM.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a hand-built stand-in model written to temporary .mat files, no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Extended after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLoadMinimalWBM'));
cd(fileDir);

% declare the requirements of this test: a Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system
prepareTest();

%% stand-in whole-body model with the fields loadMinimalWBM looks for

wbm = struct();
wbm.ID = 'toyWBM';
wbm.S = sparse([1 -1 0; 0 1 -1]);
wbm.lb = [0; 0; 0];
wbm.ub = [10; 10; 10];
wbm.rxns = {'R1'; 'R2'; 'R3'};
wbm.mets = {'A'; 'B'};
wbm.c = [0; 0; 1];
wbm.d = 0;
wbm.csense = ['E'; 'E'];
wbm.dsense = 'L';
wbm.osenseStr = 'max';
wbm.C = sparse([1 1 0]);
wbm.sex = 'male';
wbm.SetupInfo = struct('diet', 'EUAverageDiet');

% the files are written to a temporary folder that is removed at the end
workDir = tempname;
mkdir(workDir);

% the stored files also hold fields that FBA does not need (rxnNames, metNames): the minimal
% load must leave them out, the full load must return them
wbmFile = wbm;
wbmFile.rxnNames = {'reaction 1'; 'reaction 2'; 'reaction 3'};
wbmFile.metNames = {'metabolite A'; 'metabolite B'};

%% fields stored as variables: the minimal load returns only the requested fields

minimalFile = fullfile(workDir, 'minimal.mat');
save(minimalFile, '-struct', 'wbmFile');
model = loadMinimalWBM(minimalFile);
% the 14 requested fields come back with their values (field order is not part of the
% contract); the two extra fields of the file are not loaded
assert(~isfield(model, 'rxnNames') && ~isfield(model, 'metNames'));
assert(isequal(sort(fieldnames(model)), sort(fieldnames(wbm))));
assert(isequal(orderfields(model), orderfields(wbm)));
assert(issparse(model.S) && isequal(model.S, wbm.S));

% a string path is documented as well
modelFromString = loadMinimalWBM(string(minimalFile));
assert(isequal(modelFromString, model));

%% the model nested in a single variable: full load and un-nesting

% the first load finds none of the requested variables (MATLAB warns for each of them), so
% the whole file is loaded and its single variable is returned, the extra fields included
nestedFile = fullfile(workDir, 'nested.mat');
save(nestedFile, 'wbmFile');
model = loadMinimalWBM(nestedFile);
assert(isfield(model, 'rxnNames') && isfield(model, 'metNames'));
assert(isequal(model, wbmFile));

%% fields stored as variables but one required field missing: the full load as it is

wbmNoC = rmfield(wbmFile, 'C');
partialFile = fullfile(workDir, 'partial.mat');
save(partialFile, '-struct', 'wbmNoC');
model = loadMinimalWBM(partialFile);
% the file holds several variables, so nothing is un-nested; C stays absent and the fields
% that the minimal load leaves out (rxnNames, metNames) are now returned
assert(~isfield(model, 'C'));
assert(isfield(model, 'rxnNames') && isfield(model, 'metNames'));
assert(isequal(sort(fieldnames(model)), sort(fieldnames(wbmNoC))));
assert(isequal(orderfields(model), orderfields(wbmNoC)));

% remove the temporary files and change the directory
rmdir(workDir, 's');
cd(currentDir)
