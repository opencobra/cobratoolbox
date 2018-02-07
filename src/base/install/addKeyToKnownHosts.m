function keyAdded = addKeyToKnownHosts(siteName)
% Checks if the public key to `site.ext` exists
% If the public key of the `site.ext` does not exist,
% adds the public key to the known hosts
%
% USAGE:
%
%   keyAdded = addKeyToKnownHosts()
%
% INPUT:
%   siteName:   Name of the site for which the public key shall be added
%               (default: `github.com`)
%
% OUTPUT:
%   keyAdded:   Boolean (true if key has been added successfully or exists)
%
% .. Author:
%      - Laurent Heirendt

    % set the default site name
    if ~exist('siteName', 'var')
        siteName = 'github.com';
    end

    % find the keyscan
    [status_keyscan, result_keyscan] = system('ssh-keyscan');

    % user directory
    if ispc
        homeDir = getenv('userprofile');
    else
        homeDir = getenv('HOME');
    end

    if status_keyscan == 1 && ~isempty(strfind(result_keyscan, 'usage:'))

        % try to create the directory
        [status_createDir, ~, ~] = mkdir([homeDir filesep '.ssh']);

        % touch the file first
        system(['touch ', homeDir, filesep, '.ssh', filesep, 'known_hosts']);

        % read the known hosts file
        [~, result_grep] = system(['grep "^', siteName, ' " ', homeDir, filesep, '.ssh', filesep, 'known_hosts']);

        if strcmp(result_grep, '')
            [status_kh, result_kh] = system(['ssh-keyscan ', siteName, ' >> ', homeDir, filesep, '.ssh', filesep, 'known_hosts']);

            if status_kh == 0 && ~isempty(strfind(result_kh, ['# ', siteName]))
                fprintf([' > ', siteName, ' has been added to the known hosts.\n']);
                keyAdded = true;
            else
                fprintf(result_kh);
                error([' > ', siteName, ' could not be added to the known hosts file in ~/.ssh/known_hosts. \n']);
            end
        else
            fprintf([' > ', siteName, ' is already a known host.\n']);
            keyAdded = true;
        end
    else
        fprintf(result_keyscan);
        error(' > ssh-keyscan is not installed. Please follow the installation instructions here: https://opencobra.github.io/cobratoolbox/stable/installation.html');
    end
end
