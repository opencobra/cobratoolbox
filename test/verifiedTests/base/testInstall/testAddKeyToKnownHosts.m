% The COBRAToolbox: testAddKeyToKnownHosts.m
%
% Purpose:
%     - test if a key can be added to known hosts
%
% Authors:
%     - original version: Laurent Heirendt, February 2018
%

global CBTDIR

% save the current path
currentDir = pwd;

% test for a failure of an unknown host
assert(verifyCobraFunctionError(@() addKeyToKnownHosts('github123.co')));

% find the keyscan
[status_keyscan, result_keyscan] = system('ssh-keyscan');

if status_keyscan == 1 && ~isempty(strfind(result_keyscan, 'usage:'))
    % remove the key first from the known hosts file
    [status, result] = system('ssh-keygen -R github.com');

    % run the function to add the github.com key
    statusAddKey = addKeyToKnownHosts();

    % check if the key has been added succesfully
    assert(statusAddKey);

    % user directory
    if ispc
        homeDir = getenv('userprofile');
    else
        homeDir = getenv('HOME');
    end

    % verify that the key has been added to the known hosts file
    [~, result_grep] = system(['grep "^github.com " ', homeDir, filesep, '.ssh', filesep, 'known_hosts']);

    % test whether the resulting string is not empty (site has been found)
    assert(~strcmp(result_grep, ''))

    % test if the host is already known
    assert(addKeyToKnownHosts('github.com'));

    % remove the old host file
    delete([homeDir filesep '.ssh' filesep 'known_hosts.old']);

    % print a success message
    fprintf(' > Test to add a key passed.\n');
end

% change the directory
cd(currentDir)
