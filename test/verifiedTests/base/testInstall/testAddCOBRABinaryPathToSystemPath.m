% The COBRAToolbox: testAddCOBRABinaryPathToSystemPath.m
%
% Purpose:
%     - addCOBRABinaryPathToSystemPath() appends CBTDIR/binary/<arch>/bin and all its
%       subfolders to the system PATH, and CBTDIR/binary/<arch>/lib and all its subfolders to
%       LD_LIBRARY_PATH (Unix). The test points the global CBTDIR to a temporary folder with a
%       hand-built binary tree (files and nested folders), so the expected values are the
%       folders the test creates: the original value, then ':' and the top folder, then its
%       subfolders (files are not added). PATH, LD_LIBRARY_PATH and CBTDIR are restored.
%
% Function under test:
%     src/base/install/addCOBRABinaryPathToSystemPath.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a temporary folder stands in for the toolbox root.
%     Declares needsUnix because the assertions check the Unix variables PATH and
%     LD_LIBRARY_PATH.
%
% Coverage exemptions:
%     Line 25: Windows branch of ispc (Path variable); the test needs a Unix system
%     (OS-specific branch).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddCOBRABinaryPathToSystemPath'));
cd(fileDir);

% the assertions check the Unix environment variables PATH and LD_LIBRARY_PATH
prepareTest('needsUnix', true);

% save the state the function changes
savedCBTDIR = CBTDIR;
origPath = getenv('PATH');
origLdPath = getenv('LD_LIBRARY_PATH');

% a fake toolbox root: bin with a nested subfolder and a file, lib with one subfolder and a file
fakeRoot = tempname;
arch = computer('arch');
binaryDir = [fakeRoot filesep 'binary' filesep arch filesep 'bin'];
libDir = [fakeRoot filesep 'binary' filesep arch filesep 'lib'];
mkdir([binaryDir filesep 'toolA' filesep 'nested']);
mkdir([binaryDir filesep 'toolB']);
mkdir([libDir filesep 'libSub']);
fid = fopen([binaryDir filesep 'program'], 'w');
fclose(fid);
fid = fopen([libDir filesep 'libdummy.so'], 'w');
fclose(fid);

CBTDIR = fakeRoot;

%% the bin tree is appended to PATH and the lib tree to LD_LIBRARY_PATH

addCOBRABinaryPathToSystemPath();
newPath = getenv('PATH');
newLdPath = getenv('LD_LIBRARY_PATH');

% the original values are kept in front, followed by ':' and the added folders
assert(strncmp(newPath, [origPath ':'], numel(origPath) + 1));
assert(strncmp(newLdPath, [origLdPath ':'], numel(origLdPath) + 1));
addedBin = strsplit(newPath(numel(origPath) + 2:end), ':');
addedLib = strsplit(newLdPath(numel(origLdPath) + 2:end), ':');

% the top folder comes first; the subfolders follow (all levels), files are not added; the
% order of the subfolders is that of the directory listing, so they are compared as sets
assert(strcmp(addedBin{1}, binaryDir));
expectedBinSub = {[binaryDir filesep 'toolA'], [binaryDir filesep 'toolA' filesep 'nested'], ...
                  [binaryDir filesep 'toolB']};
assert(numel(addedBin) == 4);
assert(isequal(sort(addedBin(2:end)), sort(expectedBinSub)));
assert(isequal(addedLib, {libDir, [libDir filesep 'libSub']}));

%% a second call appends the same folders again (no check for duplicates)

addCOBRABinaryPathToSystemPath();
assert(strcmp(getenv('PATH'), [newPath ':' strjoin(addedBin, ':')]));
assert(strcmp(getenv('LD_LIBRARY_PATH'), [newLdPath ':' strjoin(addedLib, ':')]));

% restore the environment and the toolbox root, remove the fake tree
setenv('PATH', origPath);
setenv('LD_LIBRARY_PATH', origLdPath);
CBTDIR = savedCBTDIR;
rmdir(fakeRoot, 's');

% change the directory
cd(currentDir)
