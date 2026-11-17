% The COBRAToolbox: testAddKeyToKnownHostsCT.m
%
% Purpose:
%     - addKeyToKnownHostsCT(hostName) checks that ssh-keyscan is installed, creates
%       ~/.ssh/known_hosts if needed, and appends the host key fetched by ssh-keyscan unless the
%       host (default github.com) is already listed; it returns true, and stops with an error
%       when ssh-keyscan is missing or no key could be fetched.
%     - Once the error defect below is fixed, the test should run in a sandbox: HOME pointing to
%       a tempname folder and PATH starting with a fake ssh-keyscan written by the test (the
%       usage message with status 1 without a host, nothing for an unreachable host, a key on
%       stdout and a comment on stderr otherwise) and a broken one (status 127), so that the
%       real ~/.ssh folder and the network are never touched; and check: the default host with
%       no .ssh folder (folder and file created, key added), a known host left alone, the
%       default host for no input, '', "" and ' ', a named host appended, an unreachable host
%       (error, no entry) and a missing ssh-keyscan (error). The globals gitConf and gitCmd
%       (never set by the toolbox) are set to hand-built values to reach both message forms of
%       printMsg and restored afterwards. Line 38 (Windows) stays exempt.
%       Quarantined: no behaviour of addKeyToKnownHostsCT is asserted until the error defect
%       below is fixed; this file only opens the test.
%
% Function under test:
%     src/base/ci/addKeyToKnownHostsCT.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; ssh-keyscan is replaced by a test double (needs a Unix shell
%     for the fake ssh-keyscan, touch and grep).
%
% Coverage exemptions:
%     every line - addKeyToKnownHostsCT is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented host name ' ' does not select github.com and the call fails
%       SEVERITY: error
%       TRIGGER: addKeyToKnownHostsCT(' ') with ssh-keyscan installed (reproduced with HOME in a
%         tempname folder and a fake ssh-keyscan first on PATH)
%       OBSERVED: (R2025a, 2026-11-17) with gitCmd set: error ">> [addKeyToKnownHostsCT]  could
%         not be added to the known hosts file in ~/.ssh/known_hosts"; with gitCmd empty: "Dot
%         indexing is not supported for variables of this type."; known_hosts stays empty. Lines
%         26-31 replace only an empty name, so ' ' is passed on: grep "^  " finds nothing and
%         'ssh-keyscan   >> known_hosts' runs without a host (usage message, status 1)
%       EXPECTED: github.com is checked and added, as for no input or '' (the help text: "If not
%         provided or empty or ' ' then it checks for the host: github.com"); true is returned
%       LINES: 26-31, 52-63
%     - DEFECT: The error messages fail with a dot-indexing error when gitCmd is not set
%       SEVERITY: cosmetic
%       TRIGGER: with the global gitCmd empty (no toolbox function sets it) and a fake ssh-keyscan
%         that prints nothing for the host: addKeyToKnownHostsCT('unreachable.invalid'); likewise
%         with an ssh-keyscan that does not print its usage message
%       OBSERVED: (R2025a, 2026-11-15) the call stops with "Dot indexing is not supported for
%         variables of this type." instead of its own message
%       EXPECTED: the error "... unreachable.invalid could not be added to the known hosts file in
%         ~/.ssh/known_hosts" (or "... ssh-keyscan is not installed."), without depending on
%         gitCmd
%       LINES: 63, 72
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15; quarantined
%       after independent review, 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddKeyToKnownHostsCT'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
