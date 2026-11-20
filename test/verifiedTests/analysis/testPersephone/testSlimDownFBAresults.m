% The COBRAToolbox: testSlimDownFBAresults.m
%
% Purpose:
%     - slimDownFBAresults copies every .mat file of a folder of FBA results into the folder
%       <folder>_SLIM, keeping only the variables rxns, ID, sex, f, stat, speciesBIO,
%       shadowPriceBIO and relAbundances (those present), and returns the new file paths.
%       This test checks the new folder, the returned paths, the kept and dropped variables
%       (with and without the microbiome variables), that other files are ignored, a second
%       run into an existing folder and an empty input folder.
%     - Expected values are the hand-built variables saved by the test.
%
% Function under test:
%     src/analysis/persephone/additionalFunctions/slimDownFBAresults.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; small hand-built .mat files in a temporary folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The call leaves every MATLAB warning switched on
%       SEVERITY: cosmetic
%       TRIGGER: w = warning; slimDownFBAresults(folder); w2 = warning
%       OBSERVED: in a fresh MATLAB session 6 warnings are off before the call and 0 after
%         it: line 35 switches all warnings off and line 44 switches all of them on instead
%         of restoring the previous state
%       EXPECTED: the warning state of the caller is restored
%       LINES: 35, 44
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSlimDownFBAresults'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the function changes the global warning state (defect above); it is saved here and
% restored at the end
warningStateBefore = warning;

% temporary folder with two FBA result files and a file that is not a .mat file
tmpDir = tempname;
mkdir(tmpDir);
fbaDir = fullfile(tmpDir, 'fbaResults');
mkdir(fbaDir);
withMicrobiome = struct('rxns', {{'R1'; 'R2'}}, 'ID', 'sample1', 'sex', 'male', 'f', [1.5; -2], ...
    'stat', [1; 1], 'speciesBIO', {{'bug1'; 'bug2'}}, 'shadowPriceBIO', [0.1 0.2], ...
    'relAbundances', [0.4; 0.6], 'fluxes', magic(3), 'model', 'large field');
save(fullfile(fbaDir, 'sample1.mat'), '-struct', 'withMicrobiome');
withoutMicrobiome = struct('rxns', {{'R1'}}, 'ID', 'sample2', 'sex', 'female', 'f', 3, ...
    'stat', 1, 'fluxes', [1 2]);
save(fullfile(fbaDir, 'sample2.mat'), '-struct', 'withoutMicrobiome');
fid = fopen(fullfile(fbaDir, 'notes.txt'), 'w');
fprintf(fid, 'not a result\n');
fclose(fid);

keptNames = {'rxns', 'ID', 'sex', 'f', 'stat', 'speciesBIO', 'shadowPriceBIO', 'relAbundances'};
slimDir = [fbaDir '_SLIM'];

%% slimmed copies: new folder, returned paths, kept and dropped variables

smallPaths = slimDownFBAresults(fbaDir);
assert(exist(slimDir, 'dir') == 7);
% one path per .mat file (the .txt file is ignored), as a string array
expectedPaths = string({fullfile(slimDir, 'sample1.mat'); fullfile(slimDir, 'sample2.mat')});
assert(isstring(smallPaths) && numel(smallPaths) == 2);
assert(isequal(sort(smallPaths(:)), expectedPaths));
slimListing = dir(slimDir);
assert(isequal(sort({slimListing.name}), {'.', '..', 'sample1.mat', 'sample2.mat'}));
% the file with microbiome data keeps the eight listed variables, unchanged
slim1 = load(fullfile(slimDir, 'sample1.mat'));
assert(isequal(sort(fieldnames(slim1)), sort(keptNames')));
for k = 1:numel(keptNames)
    assert(isequal(slim1.(keptNames{k}), withMicrobiome.(keptNames{k})));
end
% the file without microbiome data keeps the five variables it has
slim2 = load(fullfile(slimDir, 'sample2.mat'));
assert(isequal(sort(fieldnames(slim2)), sort({'rxns'; 'ID'; 'sex'; 'f'; 'stat'})));
assert(isequal(slim2.f, 3) && strcmp(slim2.sex, 'female') && isequal(slim2.rxns, {'R1'}));
% the input files are not changed
assert(isequal(sort(fieldnames(load(fullfile(fbaDir, 'sample1.mat')))), sort(fieldnames(withMicrobiome))));

%% second run: the existing _SLIM folder is reused and the files are overwritten

withoutMicrobiome.f = 4;
save(fullfile(fbaDir, 'sample2.mat'), '-struct', 'withoutMicrobiome');
smallPaths = slimDownFBAresults(fbaDir);
assert(isequal(sort(smallPaths(:)), expectedPaths));
slim2 = load(fullfile(slimDir, 'sample2.mat'));
assert(isequal(slim2.f, 4));

%% a folder without .mat files: the _SLIM folder is created and no path is returned

emptyDir = fullfile(tmpDir, 'emptyResults');
mkdir(emptyDir);
smallPaths = slimDownFBAresults(emptyDir);
assert(isempty(smallPaths));
assert(exist([emptyDir '_SLIM'], 'dir') == 7);

% remove the temporary files, restore the warning state and the directory
rmdir(tmpDir, 's');
warning(warningStateBefore);
cd(currentDir)
