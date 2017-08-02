function portableGitSetup(gitBashVersion, removeFlag)
% removeFlag:
% 0: install, don't remove anything
% 1: install, remove every old version
% 2: don't install, remove every old version

    global CBTDIR
    
    if nargin < 2
        removeFlag = 0;
    end
    
    if ispc
        % define the name of the temporary folder
        tmpFolder = '.tmp';

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
            urlwrite(urlPortableGit, fileNamePortableGit);
            fprintf('Done.\n');
        end

        % if the archive exists and does not have a version number, append the version number
        if exist(fileNamePortableGitwoVersion, 'file') == 2 && removeFlag < 2
            movefile(fileNamePortableGitwoVersion, fileNamePortableGit)
        end

        % remove a previous version
        if removeFlag > 0
            % remove the folder of PortableGit
            if exist(pathPortableGit, 'dir') == 7

                try
                    % remove the path from the MATLAB path
                    rmpath(genpath(pathPortableGit));

                    % remove all subfolders
                    rmdir(pathPortableGit, 's');

                    % remove root directory
                    rmdir(pathPortableGit);
                    rmdir(['PortableGit-' gitBashVersion]);

                    fprintf([' > gitBash folder (', strrep(pathPortableGit, '\', '\\'), ') removed.\n']);
                catch
                   % fprintf([' > gitBash folder (', strrep(pathPortableGit, '\', '\\'), ') could not be removed.\n']);
                end
            end

            % unset the paths
            for i = 1:length(pathPortableGitFragments)   
                % global machine path
                oldMachinePath = getsysenvironvar('Path');
                newMachinePath = strrep(oldMachinePath, [pathPortableGitFragments{i} ';'], '');
                setsysenvironvar('Path', newMachinePath);

                % session path
                oldSessionPath = getenv('Path');
                newSessionPath = strrep(oldSessionPath, [pathPortableGitFragments{i} ';'], '');
                setenv('Path', newSessionPath);
            end
        end

        % extract the archive and set the paths
        if removeFlag < 2
            if exist(fileNamePortableGit, 'file') == 2 

                % extract the archive
                fprintf(' > Extracting the gitBash archive (this may take a while) ...');
                system([fileNamePortableGit ' -y']);
                fprintf(' Done.\n');

                % rename the folder
                if removeFlag > 0
                    try
                        rmdir(pathPortableGit, 's'); %remove if empty
                    catch
                        fprintf([' > gitBash folder (', strrep(pathPortableGit, '\', '\\'), ') could not be removed before moving.\n']);
                    end
                end
                movefile('PortableGit', ['PortableGit-' gitBashVersion])

                % remove the downloaded file
                try
                    delete(fileNamePortableGit);
                    fprintf([' > gitBash archive (', fileNamePortableGit, ') removed.\n']);
                catch
                    fprintf([' > gitBash archive (', fileNamePortableGit, ') could not be removed.\n']);
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
        end

        % jump back to the old directory
        cd(currentDir);
    else
        error('gitBash can only be installed on Windows.');
    end
end