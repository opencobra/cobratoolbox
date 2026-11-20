% The COBRAToolbox: testGetGitBashVersion.m
%
% Purpose:
%     - getGitBashVersion() reads the version of the portable gitBash from the Windows Path
%       variable and, outside Windows, raises the documented error "gitBash can only be
%       installed on Windows.". The test checks that error. The function declares the global
%       gitBashVersion, so the globals are compared before and after and any new one is
%       cleared.
%
% Function under test:
%     src/base/install/getGitBashVersion.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver. Declares needsUnix: on Windows the function reads the
%     system Path of the machine, which a test cannot set up.
%
% Coverage exemptions:
%     Lines 19-20, 23-31, 36-37: Windows branch of ispc (reads the Windows system Path
%     with getsysenvironvar); the test needs a Unix system (OS-specific branch).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetGitBashVersion'));
cd(fileDir);

% the documented behaviour outside Windows is an error; the Windows branch needs the system
% Path of a Windows machine
prepareTest('needsUnix', true);

% the function declares the global gitBashVersion: note the globals before the call
globalsBefore = who('global');

%% outside Windows the function raises the documented error

assert(verifyCobraFunctionError('getGitBashVersion', ...
    'testMessage', 'gitBash can only be installed on Windows.'));
assert(verifyCobraFunctionError('getGitBashVersion', 'outputArgCount', 2, ...
    'testMessage', 'gitBash can only be installed on Windows.'));

% remove the globals the call created
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clear('global', newGlobals{k});
end

% change the directory
cd(currentDir)
