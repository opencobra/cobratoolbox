function keyAdded = addKeyToKnownHosts2(hostName)
% Checks if the public key to hostName exists
% If the public key of the hostName does not exist,
% adds the public key to the known hosts
%
% USAGE:
%
%   keyAdded = addKeyToKnownHosts(hostName)
%
% OPTIONAL INPUT:
%   hostName:       Name of the host. If not provided or empty or ' ' then 
%                   it checks for the host: github.com
%
% OUTPUT:
%   keyAdded:       Boolean (true if key has been added successfully or exists)
%
% .. Author:
%      - Laurent Heirendt

    global gitCmd

    % set default arguments
    if ~exist('hostName', 'var')
        hostName = 'github.com';
    end
    if isempty(hostName)
        hostName = 'github.com';
    end
    if isequal(hostName,'')
        hostName = 'github.com';
    end

    % add github.com as a known host
    [status_keyscan, result_keyscan] = system('ssh-keyscan');

    % user directory
    if ispc
        homeDir = getenv('userprofile');
    else
        homeDir = getenv('HOME');
    end

    if status_keyscan == 1 && contains(result_keyscan, 'usage:')

        % try to create the directory
        [status_createDir, ~, ~] = mkdir([homeDir filesep '.ssh']);

        % touch the file first
        system(['touch ', homeDir, filesep, '.ssh', filesep, 'known_hosts']);

        % read the known hosts file
        [~, result_grep] = system(['grep "^' hostName ' " ', homeDir, filesep, '.ssh', filesep, 'known_hosts']);

        if strcmp(result_grep, '')
            [status_kh, result_kh] = system(['ssh-keyscan ' hostName ' >> ', homeDir, filesep, '.ssh', filesep, 'known_hosts']);

            if status_kh == 0 && contains(result_kh, ['# ' hostName])
                fprintf('%s\n',[hostName ' has been added to the known hosts']);
                printMsg(mfilename, [hostName, ' has been added to the known hosts']);
                keyAdded = true;
            else
                fprintf(result_kh);
                error([gitCmd.lead, ' [', mfilename, ']', hostName, ' could not be added to the known hosts file in ~/.ssh/known_hosts']);
            end
        else
            fprintf('%s\n',[hostName ' is already a known host.']);
            printMsg(mfilename, [hostName, ' is already a known host.']);
            keyAdded = true;
        end
    else
        fprintf(result_keyscan);
        error([gitCmd.lead, ' [', mfilename, ']', ' ssh-keyscan is not installed.']);
    end
end
function printMsg(fileName, msg, endMsg)
% Print a message
%
% USAGE:
%
%    printMsg(fileName, msg, endMsg)
%
% INPUT:
%    fileName:       Name of the file from which the message is issued
%    msg:            Message as string
%    endMsg:         End of message, generally a new line character
%
% .. Author:

    global gitConf
    global gitCmd

    % define the message
    if ~isempty(gitConf) && ~isempty(gitCmd)
        % define the end of the message
        if nargin < 3
            endMsg = [gitCmd.success, gitCmd.trail];
        end

        if gitConf.printLevel > 0
            fprintf([gitCmd.lead, ' [', fileName, '] ', msg, endMsg]);
        end
    else
        fprintf([' [', fileName, '] ', msg]);
    end
end
