function [] = installGitBash()
% Wraps the installer for PortableGit and checks for available updates
% THis function can only be run on Windows, and throws an error when run on a UNIX system.
%
% USAGE:
%     installGitBash()
%

    global CBTDIR
    global gitBashVersion

    if ispc
        % initialize variables
        archstr = computer('arch');
        archBit = archstr(end-1:end);

        % define the name of the temporary folder
        tmpFolder = '.tmp';

        % create .tmp if not already present
        if ~exist(tmpFolder, 'dir')
            mkdir(tmpFolder);
        end

        [installedVersion, ~] = getGitBashVersion();

        % define the path to portable gitBash
        pathPortableGit = [CBTDIR filesep tmpFolder filesep 'PortableGit-' installedVersion];

        % check if mingw64 is already in the path
        if ~isempty(installedVersion) && exist(pathPortableGit, 'dir') == 7
            fprintf(' > gitBash is installed.\n');
        else
            % retrieve and install the portable git bash and associated tools

            portableGitSetup(gitBashVersion, 0);

            % set the path if already installed
            setenv('Path', [getenv('Path') ';' getsysenvironvar('Path')]);
        end
    else
        error('gitBash can only be installed on Windows.');
    end
end
