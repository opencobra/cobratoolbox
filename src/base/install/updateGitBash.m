function updateGitBash(fetchAndCheckOnly)
% On windows, this function updates the already existing version of gitBash.
% This function can only be run on Windows, and throws an error when run on a UNIX system.
%
% USAGE:
%     updateGitBash(fetchAndCheckOnly)
%
% INPUT:
%     fetchAndCheckOnly: if set to `true`, gitBash is not updated, but only a check is made (default: `false`)
%

    global CBTDIR
    global gitBashVersion

    if nargin < 1
        fetchAndCheckOnly = false;
    end

    if ispc
        % define the name of the temporary folder
        tmpFolder = '.tmp';

        [installedVersion, installedVersionNum] = getGitBashVersion();

        % define the path to portable gitBash
        pathPortableGit = [CBTDIR filesep tmpFolder filesep 'PortableGit-' installedVersion];

        % check if mingw64 is already in the path
        if ~isempty(installedVersion) && exist(pathPortableGit, 'dir') == 7
            fprintf([' > gitBash is installed (version: ', installedVersion, ').\n']);

            % if a version already exists, get the latest
            [status, response] = system('curl https://api.github.com/repos/git-for-windows/git/releases/latest');

            latestVersion = [];

            % find the index of occurrence
            if status == 0 && ~isempty(response)
                index1 = strfind(response, 'git/releases/tag/v');
                index2 = strfind(response, '.windows.1');
                catchLength = length('git/releases/tag/v');
                index1 = index1 + catchLength;

                if  ~isempty(index2) && ~isempty(index1)
                    if index2(1) > index1(1)
                        latestVersion = response(index1(1):index2(1) - 1);
                    end
                end
            end

            % if the latest version cannot be retrieved, set the latest version to the base version
            if isempty(latestVersion)
                latestVersion = gitBashVersion;
            end

            % convert the string to a number
            latestVersionNum = str2num(strrep(latestVersion, '.', ''));

            % test here if the latest version is up-to-date
            if latestVersionNum > installedVersionNum
                fprintf([' > gitBash is not up-to-date (version: ', installedVersion, '). Version ', latestVersion, ' is available.\n']);

                % retrieve and install the portable git bash and associated tools
                if ~fetchAndCheckOnly
                    fprintf([' > Updating to version ', latestVersion, '.\n']);
                    portableGitSetup(latestVersion, 1);
                end
            else
                fprintf([' > gitBash is up-to-date (version: ', installedVersion, ').\n']);
            end
        else
            % check if git is properly installed
            [status_gitVersion, result_gitVersion] = system('git --version');

            if status_gitVersion ~= 0 || isempty(strfind(result_gitVersion, 'git version'))
                fprintf(' > gitBash is not installed.\n');
            end

            % install gitBash
            if ~fetchAndCheckOnly
                installGitBash();
            end
        end
    else
        error('gitBash can only be installed on Windows.');
    end
end
