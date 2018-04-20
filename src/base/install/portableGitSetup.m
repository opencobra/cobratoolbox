function portableGitSetup(gitBashVersion, removeFlag)
% This function downloads the latest version of PortableGit on Windows (archive), extracts the folder
% and moves the contents to the hidden .tmp folder in a folder called `PortableGit-a.bc.c`
% This function can only be run on Windows, and throws an error when run on a UNIX system.
%
% USAGE:
%     portableGitSetup(gitBashVersion, removeFlag)
%
% INPUT:
%     removeFlag:       Flag to remove old versions from the path or not
%
%                           - 0: install, don't remove anything
%                           - 1: install, remove paths in registry
%                           - 2: don't install gitBash, remove .exe file and paths in registry
%                           - 3: don't install gitBash, remove everything including unpacked archives (to be implemented)
%
% .. The folders of PortableGit in .tmp should not be removed in a MATLAB live session
%    as they may be linked to the MATLAB thread.

    global CBTDIR

    if nargin < 2
        removeFlag = 0;
    end

    if ispc
        % define the name of the temporary folder
        tmpFolder = '.tmp';

        % create .tmp if not already present
        if ~exist(tmpFolder, 'dir')
            mkdir(tmpFolder);
        end

        % determine architecture
        archstr = computer('arch');
        archBit = archstr(end-1:end);

        % save the current directory
        currentDir = pwd;

        % change to temporary directory
        cd([CBTDIR filesep tmpFolder]);

        % define the path to portable gitBash
        pathPortableGit = [CBTDIR filesep tmpFolder filesep 'PortableGit-' gitBashVersion];

        % define the system path
        pathPortableGitFragments = {};
        pathPortableGitFragments{1} = [pathPortableGit filesep 'mingw' archBit filesep 'bin'];
        pathPortableGitFragments{2} = [pathPortableGit filesep 'cmd'];
        pathPortableGitFragments{3} = [pathPortableGit filesep 'bin'];
        pathPortableGitFragments{4} = [pathPortableGit filesep 'usr' filesep 'bin'];

        % define URL of PortableGit
        urlPortableGit = ['https://github.com/git-for-windows/git/releases/download/v' gitBashVersion '.windows.1/PortableGit-' gitBashVersion '-' archBit '-bit.7z.exe'];
        fileNamePortableGit = ['PortableGit-' gitBashVersion '.exe'];
        fileNamePortableGitwoVersion = 'PortableGit.exe';

        % download the file
        if exist(fileNamePortableGit, 'file') ~= 2 && exist(fileNamePortableGitwoVersion, 'file') ~= 2 && removeFlag < 2
            fprintf(' > Downloading gitBash archive (this may take a while) ... ');
            websave(fileNamePortableGit, urlPortableGit);
            fprintf('Done.\n');
        end

        % if the archive exists and does not have a version number, append the version number
        if exist(fileNamePortableGitwoVersion, 'file') == 2 && removeFlag < 2
            movefile(fileNamePortableGitwoVersion, fileNamePortableGit)
        end

        % remove a previous version by unsetting eventual paths
        if removeFlag >= 1
            % unset the paths
            for i = 1:length(pathPortableGitFragments)
                % global machine path
                oldMachinePath = getsysenvironvar('Path');
                if  ~isempty(oldMachinePath)
                    newMachinePath = strrep(oldMachinePath, [pathPortableGitFragments{i} ';'], '');
                    setsysenvironvar('Path', newMachinePath);
                end

                % session path
                oldSessionPath = getenv('Path');
                newSessionPath = strrep(oldSessionPath, [pathPortableGitFragments{i} ';'], '');
                setenv('Path', newSessionPath);
            end
        end

        % extract the archive and set the paths
        if exist(fileNamePortableGit, 'file') == 2

            if removeFlag <= 2
                % extract the archive
                fprintf(' > Extracting the gitBash archive (this may take a while) ...');
                system([fileNamePortableGit ' -y']);
                fprintf(' Done.\n');

                try
                    movefile('PortableGit', ['PortableGit-' gitBashVersion], 'f')
                catch
                    fprintf([' > gitBash folder (', strrep(pathPortableGit, '\', '\\'), ') could not be renamed.\n']);
                end
            end

            % remove the downloaded file
            if removeFlag >= 2
                try
                    delete(fileNamePortableGit);
                    fprintf([' > gitBash archive (', fileNamePortableGit, ') removed.\n']);
                catch
                    fprintf([' > gitBash archive (', fileNamePortableGit, ') could not be removed.\n']);
                end
            end

            % set the path machine wide
            for i = 1:length(pathPortableGitFragments)
                if isempty(strfind(getsysenvironvar('Path'), pathPortableGitFragments{i}))
                    setsysenvironvar('Path', [pathPortableGitFragments{i} ';' getsysenvironvar('Path')]);
                end
                if isempty(strfind(getenv('Path'), pathPortableGitFragments{i}))
                    setenv('Path', [pathPortableGitFragments{i} ';' getenv('Path') ]);
                end
            end

            % add the path to the MATLABPATH
            addpath(genpath(pathPortableGit));

            % print a success message
            fprintf(' > gitBash successfully installed.\n');
        else
            error('Portable gitBash cannot be downloaded. Check your internet connection.');
        end

        % jump back to the old directory
        cd(currentDir);
    else
        error('gitBash can only be installed on Windows.');
    end
end
