% The COBRAToolbox: testAddKeyToKnownHostsCT.m
%
% Purpose:
%     - addKeyToKnownHostsCT(hostName) checks that ssh-keyscan is installed, creates
%       ~/.ssh/known_hosts if needed, and appends the host key fetched by ssh-keyscan unless the
%       host (default github.com) is already listed; it returns true, and stops with an error
%       when ssh-keyscan is missing or no key could be fetched. The whole test runs in a sandbox:
%       HOME points to a temporary folder and PATH starts with a fake ssh-keyscan written by the
%       test, so the real ~/.ssh folder and the network are never touched. The messages are
%       printed through the globals gitConf and gitCmd (never set by the toolbox); the test sets
%       them to hand-built values to reach both message forms, and restores them.
%
% Function under test:
%     src/base/ci/addKeyToKnownHostsCT.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; ssh-keyscan is replaced by a test double (needs a Unix shell
%     for the fake ssh-keyscan, touch and grep).
%
% Coverage exemptions:
%     Line 38: Windows branch of ispc, the test needs a Unix system (OS-specific branch).
%
% Known defects documented (NOT tested, NOT fixed here):
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
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddKeyToKnownHostsCT'));
cd(fileDir);

% needs a POSIX shell for the fake ssh-keyscan, touch and grep
prepareTest('needsUnix', true);

% the function declares the globals gitConf and gitCmd: save them (or note that they do not
% exist) so that they can be restored at the end
globalsBefore = who('global');
global gitConf gitCmd
gitConfBefore = gitConf;
gitCmdBefore = gitCmd;

% save the environment so it can be restored regardless of the test outcome
origHome = getenv('HOME');
origPath = getenv('PATH');

% folders of the sandbox: a home folder and the two variants of ssh-keyscan
sandboxDir = tempname;
sandboxHome = [sandboxDir, filesep, 'home'];
fakeBin = [sandboxDir, filesep, 'bin'];
brokenBin = [sandboxDir, filesep, 'brokenBin'];
mkdir(sandboxHome);
mkdir(fakeBin);
mkdir(brokenBin);

% a working ssh-keyscan: the usage message and status 1 without a host, nothing for an
% unreachable host, and a key on stdout plus a comment on stderr for every other host
fakeKeyscan = [fakeBin, filesep, 'ssh-keyscan'];
fid = fopen(fakeKeyscan, 'w');
fprintf(fid, '#!/bin/sh\n');
fprintf(fid, 'if [ $# -eq 0 ]; then\n  echo "usage: ssh-keyscan [host]" >&2\n  exit 1\nfi\n');
fprintf(fid, 'case "$1" in\n  *.invalid) exit 0 ;;\nesac\n');
fprintf(fid, 'echo "# $1:22 SSH-2.0-fake" >&2\n');
fprintf(fid, 'echo "$1 ssh-ed25519 AAAAfakeKey"\n');
fclose(fid);

% a broken ssh-keyscan: it answers as a shell does when the command does not exist
brokenKeyscan = [brokenBin, filesep, 'ssh-keyscan'];
fid = fopen(brokenKeyscan, 'w');
fprintf(fid, '#!/bin/sh\necho "ssh-keyscan: command not found" >&2\nexit 127\n');
fclose(fid);
system(['chmod +x ', fakeKeyscan, ' ', brokenKeyscan]);

khFile = [sandboxHome, filesep, '.ssh', filesep, 'known_hosts'];

try
    setenv('HOME', sandboxHome);
    setenv('PATH', [fakeBin, pathsep, origPath]);

    % nothing below may run outside the sandbox
    assert(strcmp(getenv('HOME'), sandboxHome));
    [~, keyscanPath] = system('which ssh-keyscan');
    assert(strcmp(strtrim(keyscanPath), fakeKeyscan));

    %% default host, no .ssh folder: the folder and file are created and the key is added

    % gitConf and gitCmd empty: the message is printed without them
    gitConf = [];
    gitCmd = [];
    assert(addKeyToKnownHostsCT());
    assert(exist(khFile, 'file') == 2);
    knownHosts = strsplit(strtrim(fileread(khFile)), newline);
    assert(numel(knownHosts) == 1);
    assert(strcmp(knownHosts{1}, 'github.com ssh-ed25519 AAAAfakeKey'));

    %% a known host is left alone: true, and the file does not grow

    % hand-built gitConf and gitCmd: the message is printed with them (printLevel 1) or not at
    % all (printLevel 0)
    gitCmd = struct('lead', '>>', 'success', ' ok', 'trail', '\n');
    gitConf = struct('printLevel', 1);
    assert(addKeyToKnownHostsCT('github.com'));
    gitConf.printLevel = 0;
    % an empty host name means github.com, both as '' and as an empty string ""
    assert(addKeyToKnownHostsCT(''));
    assert(addKeyToKnownHostsCT(""));
    assert(strcmp(strtrim(fileread(khFile)), 'github.com ssh-ed25519 AAAAfakeKey'));

    %% a host given by name is appended after the existing entries

    assert(addKeyToKnownHostsCT('example.org'));
    knownHosts = strsplit(strtrim(fileread(khFile)), newline);
    assert(isequal(knownHosts, {'github.com ssh-ed25519 AAAAfakeKey', 'example.org ssh-ed25519 AAAAfakeKey'}));

    %% a host whose key cannot be fetched is an error, and no entry is written for it

    assert(verifyCobraFunctionError('addKeyToKnownHostsCT', 'inputs', {'unreachable.invalid'}, ...
        'testMessage', ['>> [addKeyToKnownHostsCT]unreachable.invalid could not be added to the ' ...
        'known hosts file in ~/.ssh/known_hosts']));
    assert(numel(strsplit(strtrim(fileread(khFile)), newline)) == 2);

    %% without a usable ssh-keyscan the function stops

    setenv('PATH', [brokenBin, pathsep, origPath]);
    assert(verifyCobraFunctionError('addKeyToKnownHostsCT', 'inputs', {'github.com'}, ...
        'testMessage', '>> [addKeyToKnownHostsCT] ssh-keyscan is not installed.'));
catch ME
    % restore the environment and the globals before reporting the failure
    setenv('HOME', origHome);
    setenv('PATH', origPath);
    gitConf = gitConfBefore;
    gitCmd = gitCmdBefore;
    rmdir(sandboxDir, 's');
    rethrow(ME);
end

% restore the environment and remove the sandbox
setenv('HOME', origHome);
setenv('PATH', origPath);
rmdir(sandboxDir, 's');

% restore gitConf and gitCmd, or remove them when they did not exist before the test
gitConf = gitConfBefore;
gitCmd = gitCmdBefore;
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clear('global', newGlobals{k});
end

% change the directory
cd(currentDir)
