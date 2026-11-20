% The COBRAToolbox: testGetDirectorySize.m
%
% Purpose:
%     - getDirectorySize adds up the sizes in bytes of all files in a folder and, recursively,
%       in its subfolders, and raises an error for a path that is not a folder. The test
%       writes files of known sizes (fwrite of a known number of bytes) into a temporary
%       folder tree; expected sizes are the numbers of bytes written (hand derivation).
%
% Function under test:
%     src/analysis/persephone/additionalFunctions/getDirectorySize.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written files in a temporary folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetDirectorySize'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% temporary folder tree: root (10 + 25 bytes), root/sub (7 bytes), root/sub/deeper (3 bytes)
% and an empty folder root/empty
sandboxDir = tempname;
mkdir(fullfile(sandboxDir, 'sub', 'deeper'));
mkdir(fullfile(sandboxDir, 'empty'));
fileList = {fullfile(sandboxDir, 'a.txt'), 10; fullfile(sandboxDir, 'b.bin'), 25; ...
    fullfile(sandboxDir, 'sub', 'c.txt'), 7; fullfile(sandboxDir, 'sub', 'deeper', 'd.txt'), 3};
for i = 1:size(fileList, 1)
    fid = fopen(fileList{i, 1}, 'w');
    fwrite(fid, repmat('x', 1, fileList{i, 2}));
    fclose(fid);
end

%% an empty folder has size zero (only the '.' and '..' entries are listed and skipped)

assert(getDirectorySize(fullfile(sandboxDir, 'empty')) == 0);

%% files directly in a folder: the sum of their sizes

% sizes are integer byte counts, so the comparison is exact
assert(getDirectorySize(fullfile(sandboxDir, 'sub', 'deeper')) == 3);

%% subfolders are added recursively

assert(getDirectorySize(fullfile(sandboxDir, 'sub')) == 7 + 3);
assert(getDirectorySize(sandboxDir) == 10 + 25 + 7 + 3);
% a string path is accepted as well as a character array
assert(getDirectorySize(string(sandboxDir)) == 45);

%% a path that is not a folder raises an error

assert(verifyCobraFunctionError('getDirectorySize', 'inputs', {fullfile(sandboxDir, 'missing')}));
% a file is not a folder either
assert(verifyCobraFunctionError('getDirectorySize', 'inputs', fileList(1, 1)));

% remove the temporary files
rmdir(sandboxDir, 's');

% change the directory
cd(currentDir)
