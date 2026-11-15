% The COBRAToolbox: testGetFilesInDir.m
%
% Purpose:
%     - getFilesInDir lists the files of a folder with their absolute paths, using git ls-files
%       for git-controlled folders (types tracked, untracked, ignored, all, ignoredByCOBRA) and
%       rdir otherwise, optionally without subfolders and filtered by a regular expression. The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       for documented inputs it returns the folder itself as a file, omits the files of
%       subfolders under the documented default, and lists folders as files, so no assertion
%       about the function is made.
%
% Function under test:
%     src/base/install/getFilesInDir.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model and no solver; a test would use hand-built folders in a tempname folder
%     (some made git repositories with git init, no network).
%
% Coverage exemptions:
%     every line - getFilesInDir is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An empty git listing returns the folder itself as a file
%       SEVERITY: wrong-result
%       TRIGGER: d = tempname; mkdir(d); system(['cd ' d ' && git init -q .']);
%         getFilesInDir('dirToList', d, 'type', 'tracked') (likewise type untracked in a
%         repository without untracked files, and type all in an empty repository)
%       OBSERVED: (R2025a, 2026-11-15) a 1 x 1 cell {[d '/']} for tracked and two copies of
%         [d '/'] for all: strsplit(strtrim(''), '\n') gives {''}, which is then prefixed with
%         the folder path
%       EXPECTED: an empty cell array, since no file matches
%       LINES: 98-100, 113, 117, 120, 150
%     - DEFECT: The default checkSubFolders omits subfolders in folders not under git
%       SEVERITY: wrong-result
%       TRIGGER: a folder d outside any git repository holding a.txt and sub/b.txt;
%         getFilesInDir('dirToList', d)
%       OBSERVED: (R2025a, 2026-11-15) {[d '/sub'], [d '/a.txt']}: the default of
%         checkSubFolders is '' (false in the if at line 102), so rdir lists only the top level;
%         with checkSubFolders = true the list also holds [d '/sub/b.txt']; in a git
%         repository the same default lists the files of subfolders
%       EXPECTED: the files of the subfolders as well, as the documented default true says
%       LINES: 58, 102-106
%     - DEFECT: Folders are listed as files in folders not under git
%       SEVERITY: wrong-result
%       TRIGGER: same folder as above; getFilesInDir('dirToList', d, 'checkSubFolders', true)
%       OBSERVED: (R2025a, 2026-11-15) {[d '/sub'], [d '/a.txt'], [d '/sub/b.txt']}: rdir
%         returns folders too, and they are kept
%       EXPECTED: only files, {[d '/a.txt'], [d '/sub/b.txt']}, as in a git repository
%       LINES: 107-108, 129-130
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetFilesInDir'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
