% The COBRAToolbox: testGetIgnoredFiles.m
%
% Purpose:
%     - getIgnoredFiles(ignorepatterns, filterpatterns) reads CBTDIR/.gitignore and returns,
%       as a 1 x n cell array in file order, every trimmed line that is not empty, not a
%       comment ('#'), matches none of ignorepatterns and matches at least one of
%       filterpatterns (default: every line). The test points the global CBTDIR to a
%       temporary folder holding a hand-written .gitignore, so the expected lists are read off
%       that file by hand. CBTDIR is restored at the end.
%
% Function under test:
%     src/base/install/getIgnoredFiles.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a hand-written .gitignore in a temporary folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
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
fileDir = fileparts(which('testGetIgnoredFiles'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a fake toolbox root with a .gitignore that has comments (one indented), an empty line, a
% line of blanks, and entries with surrounding blanks
savedCBTDIR = CBTDIR;
fakeRoot = tempname;
mkdir(fakeRoot);
fid = fopen([fakeRoot filesep '.gitignore'], 'w');
fprintf(fid, '# autosave files\n*.asv\n\n   \n  build/  \n   # indented comment\n*.mex*\ndocs/_build\n');
fclose(fid);
CBTDIR = fakeRoot;

%% default: every entry, trimmed, in file order; comments and empty lines are dropped

% strings are compared exactly
assert(isequal(getIgnoredFiles(), {'*.asv', 'build/', '*.mex*', 'docs/_build'}));

%% ignorepatterns remove the matching entries (the comment and empty-line rules still apply)

assert(isequal(getIgnoredFiles({'^docs', 'asv$'}), {'build/', '*.mex*'}));

%% filterpatterns keep only the matching entries

assert(isequal(getIgnoredFiles({'^docs'}, {'mex', 'build'}), {'build/', '*.mex*'}));

%% nothing left: an empty cell array

ignoredFiles = getIgnoredFiles({}, {'nomatch'});
assert(iscell(ignoredFiles) && isempty(ignoredFiles));

% restore the toolbox root and remove the fake one
CBTDIR = savedCBTDIR;
rmdir(fakeRoot, 's');

% change the directory
cd(currentDir)
