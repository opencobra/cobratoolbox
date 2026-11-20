% The COBRAToolbox: testDQQCleanup.m
%
% Purpose:
%     - DQQCleanup removes the temporary output of the DQQ solver from tmpPath (the folders
%       results and MPS, and the files fort.* and *.sol, but not folders with these names) and
%       changes back to originalDirectory. The test builds such a folder in a tempname folder
%       and checks what is removed, what is kept and the current folder afterwards, and that
%       missing folders do not raise an error. The DQQ solver itself is not needed.
%
% Function under test:
%     src/base/solvers/minos/DQQCleanup.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built files in a tempname folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: fort.* and *.sol files are kept when the results folder is missing
%       SEVERITY: limitation
%       TRIGGER: DQQCleanup(tmpPath, originalDirectory) with fort.81 and a.sol in tmpPath and
%         no folder tmpPath/results
%       OBSERVED: rmdir of the missing results folder raises an error that the first try block
%         catches, so the deletion of the fort.* and *.sol files (lines 19-30) is skipped and
%         the files stay in tmpPath
%       EXPECTED: the temporary solver output removed (help text: fort.* and *.sol output files
%         to be deleted)
%       LINES: 18-30
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDQQCleanup'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

tmpPath = tempname;
mkdir(tmpPath);

%% full cleanup: folders and output files removed, other entries kept

mkdir(fullfile(tmpPath, 'results'));
fclose(fopen(fullfile(tmpPath, 'results', 'out.txt'), 'w'));
mkdir(fullfile(tmpPath, 'MPS'));
fclose(fopen(fullfile(tmpPath, 'MPS', 'model.mps'), 'w'));
fclose(fopen(fullfile(tmpPath, 'fort.9'), 'w'));
fclose(fopen(fullfile(tmpPath, 'fort.81'), 'w'));
fclose(fopen(fullfile(tmpPath, 'a.sol'), 'w'));
fclose(fopen(fullfile(tmpPath, 'keep.txt'), 'w'));
% folders whose names match the patterns are not deleted (only files are)
mkdir(fullfile(tmpPath, 'fort.dir'));
mkdir(fullfile(tmpPath, 'b.sol'));

% call from inside tmpPath, as the solver does, and ask to return to the test folder
cd(tmpPath);
DQQCleanup(tmpPath, fileDir);

% the current folder is originalDirectory again
assert(strcmp(pwd, fileDir));
% the two folders and the three output files are removed
assert(~exist(fullfile(tmpPath, 'results'), 'dir'));
assert(~exist(fullfile(tmpPath, 'MPS'), 'dir'));
assert(~exist(fullfile(tmpPath, 'fort.9'), 'file'));
assert(~exist(fullfile(tmpPath, 'fort.81'), 'file'));
assert(~exist(fullfile(tmpPath, 'a.sol'), 'file'));
% the other file and the folders named like output files are kept
assert(exist(fullfile(tmpPath, 'keep.txt'), 'file') == 2);
assert(exist(fullfile(tmpPath, 'fort.dir'), 'dir') == 7);
assert(exist(fullfile(tmpPath, 'b.sol'), 'dir') == 7);

%% missing folders raise no error and the directory is still restored

% tmpPath has neither results nor MPS now; both rmdir calls fail and are caught. The fort.*
% and *.sol files are not checked here (defect above)
emptyPath = fullfile(tmpPath, 'empty');
mkdir(emptyPath);
cd(emptyPath);
DQQCleanup(emptyPath, fileDir);
assert(strcmp(pwd, fileDir));
assert(exist(emptyPath, 'dir') == 7);

% remove the temporary folder
rmdir(tmpPath, 's');

% change the directory
cd(currentDir)
