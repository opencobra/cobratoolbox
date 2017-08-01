global CBTDIR

% define the root path of The COBRA Toolbox
CBTDIR = fileparts(which('initCobraToolbox'));
addpath(genpath(CBTDIR))

% initialize variables
baseVersion = '2.13.3';
installedVersion = [];
installedVersionNum = 0;

% determine the installed version
pathVersion = getsysenvironvar('Path');
index1 = strfind(pathVersion, '.tmp\PortableGit-');
index2 = strfind(pathVersion, '\mingw64\bin');
catchLength = length('.tmp\PortableGit-');
index1 = index1 + catchLength;
if  ~isempty(index2) && ~isempty(index1)
    if index2(end) > index1(end)
        installedVersion = pathVersion(index1(end):index1(end) + index2(end) - index1(end) - 1);
        installedVersionNum = str2num(strrep(installedVersion, '.', ''));
    end
end

% define a minimal version to be installed should there
if isempty(installedVersion)
    installedVersion = baseVersion;
end

% define the path to portable gitBash
pathPortableGit = [CBTDIR filesep '.tmp' filesep 'PortableGit-' installedVersion];

% check if mingw64 is already in the path
if ~isempty(installedVersion) && exist(pathPortableGit, 'dir') == 7
    fprintf(' > gitBash is installed.\n');

    % if a version already exists, get the latest
    [status, response] = system('curl https://api.github.com/repos/git-for-windows/git/releases/latest');

    % find the index of occurrence
    index1 = strfind(response, 'git/releases/tag/v');
    index2 = strfind(response, '.windows.1');
    catchLength = length('git/releases/tag/v');
    index1 = index1 + catchLength;
    latestVersion = [];
    if  ~isempty(index2) && ~isempty(index1)
        if index2(1) > index1(1)
            latestVersion = response(index1(1):index2(1) - 1);
        end
    end

    % if the latest version cannot be retrieved, set the latest version to the base version
    if isempty(latestVersion)
        latestVersion = baseVersion;
    end

    % convert the string to a number
    latestVersionNum = str2num(strrep(latestVersion, '.', ''));

    % test here if the latest version is up-to-date
    if latestVersionNum > installedVersionNum
        fprintf([' > gitBash is not up-to-date. Updating to version ', latestVersion, ' ...\n']);

        % retrieve and install the portable git bash and associated tools
        retrieveAndInstall(latestVersion);
        fprintf('Done.\n');
    else
        fprintf(' > gitBash is up-to-date.\n\n');
    end
elseif exist(pathPortableGit, 'dir') ~= 7
    % retrieve and install the portable git bash and associated tools
    fprintf(' > gitBash is not yet installed. Installing ...\n');
    retrieveAndInstall(installedVersion);
    fprintf('Done.\n');
else
    fprintf(' > gitBash is installed and up-to-date.\n\n');
end

% set the path if already installed
setenv('Path', [getenv('Path') ';' getsysenvironvar('Path')]);

% test if curl and git exist
system('curl --version');

% test if curl and git exist
system('git --version');

function retrieveAndInstall(gitBashVersion)

    global CBTDIR

    % save the current directory
    currentDir = pwd;

    % change to temporary directory
    cd([CBTDIR filesep '.tmp']);

    % define URL of PortableGit
    urlPortableGit = ['https://github.com/git-for-windows/git/releases/download/v' gitBashVersion '.windows.1/PortableGit-' gitBashVersion '-64-bit.7z.exe'];
    fileNamePortableGit = ['PortableGit-' gitBashVersion '.exe'];
    fileNamePortableGitwoVersion = 'PortableGit.exe';

    % download the file
    if exist(fileNamePortableGit, 'file') ~= 2 && exist(fileNamePortableGitwoVersion, 'file') ~= 2
        fprintf(' > Downloading gitBash archive (this may take a while) ...');
        urlwrite(urlPortableGit, fileNamePortableGit);
        fprintf(' > Done.\n');
    end

    % if the archive exists and does not have a version number, append the version number
    if exist(fileNamePortableGitwoVersion, 'file') == 2
        movefile(fileNamePortableGitwoVersion, fileNamePortableGit)
    end

    % define the path to portable gitBash
    pathPortableGit = [CBTDIR filesep '.tmp' filesep 'PortableGit-' gitBashVersion];

    % remove the folder of PortableGit
    if exist(pathPortableGit, 'file') == 7
        try
            rmpath(genpath(pathPortableGit));
            rmdir(pathPortableGit, 's');
            fprintf([' > gitBash folder (', pathPortableGit ,') removed.\n']);
        catch
            fprintf([' > gitBash folder (', pathPortableGit ,') could not be removed.\n']);
        end
    end

    % extract the archive and set the paths
    if exist(fileNamePortableGit, 'file') == 2

        % extract the archive
        fprintf(' > Extracting the gitBash archive (this may take a while) ...');
        system([fileNamePortableGit ' -y']);
        fprintf(' > Done.\n');

        % rename the folder
        movefile('PortableGit', ['PortableGit-' gitBashVersion])

        % remove the downloaded file
        try
            delete(fileNamePortableGit);
            fprintf([' > gitBash archive (', fileNamePortableGit, ') removed.\n']);
        catch
            fprintf([' > gitBash archive (', fileNamePortableGit, ') could not be removed.\n']);
        end

        % define the system path
        pathPortableGitFragments = {};
        pathPortableGitFragments{1} = [pathPortableGit filesep 'mingw64' filesep 'bin'];
        pathPortableGitFragments{2} = [pathPortableGit filesep 'cmd'];
        pathPortableGitFragments{3} = [pathPortableGit filesep 'bin'];
        pathPortableGitFragments{4} = [pathPortableGit filesep 'usr' filesep 'bin'];

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
        fprintf(' > All paths set.\n');
    else
        error('Portable gitBash cannot be downloaded. Check your internet connection.');
    end

    % jump back to the old directory
    cd(currentDir);
end

function uninstallGitBash()
end

