% The COBRAToolbox: testAddKeyToKnownHosts.m
%
% Purpose:
%     - test if a key can be added to known hosts.
%       The whole test runs in a sandbox: HOME points to a temporary folder and PATH starts with
%       a fake ssh-keyscan written by the test, so the real ~/.ssh folder and the network are
%       never touched. ssh-keygen is deliberately not called: it ignores HOME and would edit the
%       real known_hosts file; a sandbox that starts empty needs no key removed.
%
% Function under test:
%     src/base/install/addKeyToKnownHosts.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; ssh-keyscan is replaced by a test double.
%
% Coverage exemptions:
%     Line 29: Windows branch of ispc, the test needs a Unix system (OS-specific branch).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Laurent Heirendt, February 2018
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% save the current path
currentDir = pwd;

% needs a POSIX shell for the fake ssh-keyscan, touch and grep
prepareTest('needsUnix', true);

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
fprintf(fid, 'case "$1" in\n  *.invalid|github123.co) exit 0 ;;\nesac\n');
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

    %% the default site is added to a home folder without a .ssh folder
    assert(addKeyToKnownHosts());
    assert(exist(khFile, 'file') == 2);
    knownHosts = strsplit(strtrim(fileread(khFile)), newline);
    assert(numel(knownHosts) == 1);
    assert(startsWith(knownHosts{1}, 'github.com '));

    %% a known site is left alone: the function succeeds and the file does not grow
    assert(addKeyToKnownHosts('github.com'));
    assert(strcmp(strtrim(fileread(khFile)), knownHosts{1}));

    %% a site given by name is appended after the existing entries
    assert(addKeyToKnownHosts('example.org'));
    knownHosts = strsplit(strtrim(fileread(khFile)), newline);
    assert(numel(knownHosts) == 2);
    assert(startsWith(knownHosts{2}, 'example.org '));

    %% a site whose key cannot be fetched is an error, and no entry is written for it
    errorMessage = '';
    try
        addKeyToKnownHosts('unreachable.invalid');
    catch ME_add
        errorMessage = ME_add.message;
    end
    assert(contains(errorMessage, 'unreachable.invalid could not be added to the known hosts file'));
    assert(numel(strsplit(strtrim(fileread(khFile)), newline)) == 2);

    %% addKeyToKnownHostsCT: an unknown host fails (it has no key)
    assert(verifyCobraFunctionError('addKeyToKnownHostsCT', 'inputs', {'github123.co'}));

    %% addKeyToKnownHostsCT: the key is added to an empty known hosts file
    delete(khFile);

    % run the function to add the github.com key
    statusAddKey = addKeyToKnownHostsCT();

    % check if the key has been added succesfully
    assert(statusAddKey);

    % verify that the key has been added to the known hosts file
    [~, result_grep] = system(['grep "^github.com " ', khFile]);

    % test whether the resulting string is not empty (site has been found)
    assert(~strcmp(result_grep, ''))

    % test if the host is already known
    assert(addKeyToKnownHostsCT('github.com'));

    %% without a usable ssh-keyscan the function stops and points to the installation guide
    setenv('PATH', [brokenBin, pathsep, origPath]);
    errorMessage = '';
    try
        addKeyToKnownHosts();
    catch ME_add
        errorMessage = ME_add.message;
    end
    assert(contains(errorMessage, 'ssh-keyscan is not installed'));
catch ME
    % restore the environment before reporting the failure
    setenv('HOME', origHome);
    setenv('PATH', origPath);
    rmdir(sandboxDir, 's');
    rethrow(ME);
end

% restore the environment and remove the sandbox
setenv('HOME', origHome);
setenv('PATH', origPath);
rmdir(sandboxDir, 's');

% change the directory
cd(currentDir)
