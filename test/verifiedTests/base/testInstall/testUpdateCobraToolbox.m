% The COBRAToolbox: testUpdateCobraToolbox.m
%
% Purpose:
%     - updateCobraToolbox reads the last commit and the current branch with git, and, in a
%       clone of opencobra/cobratoolbox on a branch, fetches origin, counts the commits by which
%       the local master and develop branches are ahead of or behind origin, and reports
%       whether an update is available (fetchAndCheckOnly = true) or offers to reset both
%       branches to origin (interactive input). In any other clone (a fork, a detached HEAD)
%       it prints that the fork cannot be updated and swaps the path of the sibling fork-*
%       folders next to the toolbox for the toolbox's own submodule folders.
%     - Once the defect below is fixed, the test should stand in for git with a small
%       executable named git, put first on PATH in a temporary folder, that answers each git
%       command from a file written by the test and logs the commands it receives (so no git
%       command reaches the network or the repository), and check: the messages for new
%       commits, for an up-to-date clone, for local commits ahead, for a failed fetch, for
%       missing master or develop branches, for a working tree with changes, for a failed
%       count (the warning of lines 157-158), for a fork (with fork-* folders in a temporary
%       folder and a stand-in initCobraToolbox, the path restored afterwards) and for a failed
%       rev-list or rev-parse (warning of line 202, 'detached HEAD'). Lines 20 (Windows),
%       99-140 (interactive input) and 163 (MATLAB desktop) stay exempt.
%       Quarantined: no behaviour of updateCobraToolbox is asserted until the error defect
%       below is fixed; this file only opens the test.
%
% Function under test:
%     src/base/install/updateCobraToolbox.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; git is replaced by a stand-in executable.
%
% Coverage exemptions:
%     every line - updateCobraToolbox is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A commit count that git cannot compute stops the function with an undefined
%         variable instead of the intended warning
%       SEVERITY: error
%       TRIGGER: updateCobraToolbox(true) in a clone whose remote.origin.url contains
%         opencobra/cobratoolbox, on a branch, with a local master branch, where
%         'git rev-list --left-right --count master...origin/master' fails (for example when
%         origin/master was never fetched); reproduced with a stand-in git executable first on
%         PATH (fetch and show-ref succeed, that rev-list exits with status 128)
%       OBSERVED: (R2025a, 2026-11-15) "Unrecognized function or variable
%         'commitsAheadBehindMaster'." at line 85: the counts are assigned only when rev-list
%         succeeds (lines 56-58). With the master count 0/0 and a failing develop count the
%         error is "Unrecognized function or variable 'commitsAheadBehindDevelop'." (line 85);
%         the warning of lines 157-158 is reached only when master is ahead, because || stops
%         before the develop count is read
%       EXPECTED: the message of line 157 and the warning 'Eventual changes of the <master>
%         branch of The COBRA Toolbox could not be counted.' (lines 157-158)
%       LINES: 56-58, 73-75, 85, 157-158
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testUpdateCobraToolbox'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
