% The COBRAToolbox: testUpdateGitBash.m
%
% Purpose:
%     - updateGitBash updates PortableGit (git bash) on Windows and raises an error on any
%       other operating system, as its documentation says. The test checks that error with the
%       default and with the explicit fetchAndCheckOnly argument. The Windows branch queries the
%       GitHub API with curl and downloads and installs software, so it is not run.
%
% Function under test:
%     src/base/install/updateGitBash.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; declares needsUnix because on Windows the function would
%     contact GitHub and download and install PortableGit.
%
% Coverage exemptions:
%     Lines 21-83: Windows-only branch (ispc), which reads the installed version with
%     getGitBashVersion, queries https://api.github.com with curl and installs or updates
%     PortableGit through installGitBash or portableGitSetup (needs the internet); not run on
%     the Unix systems this test runs on.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testUpdateGitBash'));
cd(fileDir);

% declare the requirements of this test: a Unix system (Linux or macOS), on which the function
% stops with an error instead of contacting GitHub and installing PortableGit
prepareTest('needsUnix', true);

% updateGitBash declares the globals CBTDIR and gitBashVersion; remember which globals exist
% so that the ones it creates are removed at the end
globalsBefore = who('global');

%% default call (fetchAndCheckOnly omitted): the documented error on a Unix system

assert(verifyCobraFunctionError('updateGitBash', ...
    'testMessage', 'gitBash can only be installed on Windows.'));

%% explicit fetchAndCheckOnly: the same error, raised before anything is fetched or checked

assert(verifyCobraFunctionError('updateGitBash', 'inputs', {true}, ...
    'testMessage', 'gitBash can only be installed on Windows.'));
assert(verifyCobraFunctionError('updateGitBash', 'inputs', {false}, ...
    'testMessage', 'gitBash can only be installed on Windows.'));

% remove the globals the function created
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clear('global', newGlobals{:});
end

% change the directory
cd(currentDir)
