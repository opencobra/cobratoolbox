% The COBRAToolbox: testMinosCleanUp.m
%
% Purpose:
%     - minosCleanUp deletes every file of the MINOS working folder tmpPath except lp1.spc,
%       lp2.spc, qrunfba and runfba, and deletes <modelName>.txt from dataDirectory. The test
%       builds both folders in a tempname folder and checks what is removed and what is kept,
%       and that a missing data file raises no error. The MINOS solver itself is not needed.
%
% Function under test:
%     src/base/solvers/minos/minosCleanUp.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - no model, no solver; hand-built files in a tempname folder.
%
% Coverage exemptions:
%     Line 50: unreachable by any text input - the catch runs only if exist or delete throws,
%     and for a text path neither does (delete reports a folder or a protected file with a
%     warning; observed: a folder named <modelName>.txt is left in place without an error).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMinosCleanUp'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

rootDir = tempname;
tmpPath = fullfile(rootDir, 'MINOS');
dataDirectory = fullfile(rootDir, 'data');
mkdir(tmpPath);
mkdir(dataDirectory);

%% run files removed, the four spec/run files and other data files kept

keepFiles = {'lp1.spc', 'lp2.spc', 'qrunfba', 'runfba'};
removeFiles = {'fort.9', 'fort.10', 'toy.out', 'lp3.spc'};
allFiles = [keepFiles, removeFiles];
for k = 1:numel(allFiles)
    fclose(fopen(fullfile(tmpPath, allFiles{k}), 'w'));
end
fclose(fopen(fullfile(dataDirectory, 'toy.txt'), 'w'));
fclose(fopen(fullfile(dataDirectory, 'other.txt'), 'w'));

minosCleanUp(tmpPath, dataDirectory, 'toy');

listing = dir(tmpPath);
remaining = setdiff({listing.name}, {'.', '..'});
assert(isequal(sort(remaining), sort(keepFiles)));
% only <modelName>.txt is removed from the data folder
assert(~isfile(fullfile(dataDirectory, 'toy.txt')));
assert(isfile(fullfile(dataDirectory, 'other.txt')));

%% a second run: nothing left to delete and no data file, no error

minosCleanUp(tmpPath, dataDirectory, 'toy');
listing = dir(tmpPath);
assert(isequal(sort(setdiff({listing.name}, {'.', '..'})), sort(keepFiles)));

% remove the temporary folder and change the directory
rmdir(rootDir, 's');
cd(currentDir)
