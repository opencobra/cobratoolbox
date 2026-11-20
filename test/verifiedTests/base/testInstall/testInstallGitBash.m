% The COBRAToolbox: testInstallGitBash.m
%
% Purpose:
%     - installGitBash installs PortableGit (git bash) on Windows and raises an error on any
%       other operating system, as its documentation says. The test checks that error. The
%       Windows branch downloads and installs software, so it is not run.
%
% Function under test:
%     src/base/install/installGitBash.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; declares needsUnix because on Windows the function would
%     download and install PortableGit.
%
% Coverage exemptions:
%     Lines 14-35: Windows-only branch (ispc), which downloads and installs PortableGit through
%     portableGitSetup (needs the internet); not run on the Unix systems this test runs on.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testInstallGitBash'));
cd(fileDir);

% declare the requirements of this test: a Unix system (Linux or macOS), on which the function
% stops with an error instead of downloading PortableGit
prepareTest('needsUnix', true);

% installGitBash declares the globals CBTDIR and gitBashVersion; remember which globals exist
% so that the ones it creates are removed at the end
globalsBefore = who('global');

%% on a Unix system the function raises its documented error and installs nothing

tmpFolder = fullfile(fileDir, '.tmp');
tmpFolderExisted = exist(tmpFolder, 'dir') == 7;
assert(verifyCobraFunctionError('installGitBash', ...
    'testMessage', 'gitBash can only be installed on Windows.'));
% the error is raised before the Windows branch, which would create the .tmp folder
assert((exist(tmpFolder, 'dir') == 7) == tmpFolderExisted);

% remove the globals the function created
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clear('global', newGlobals{:});
end

% change the directory
cd(currentDir)
