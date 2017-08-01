global CBTDIR

% define the root path of The COBRA Toolbox
CBTDIR = fileparts(which('initCobraToolbox'));

addpath(genpath(CBTDIR))

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
baseVersion = '2.13.3';
if isempty(installedVersion)
    installedVersion = baseVersion;
end

% define the path to portable gitBash
pathPortableGit = [CBTDIR filesep '.tmp' filesep 'PortableGit-' installedVersion];
    
% check if mingw64 is already in the path
if ~isempty(installedVersion) && exist(pathPortableGit, 'file') == 7
    fprintf(' > gitBash is installed.\n');
    
    % if a version already exists, get the latest
    [status, response] = system('curl https://api.github.com/repos/git-for-windows/git/releases/latest');

    % find the index of occurrence
    index1 = strfind(response, 'git/releases/tag/v');
    index2 = strfind(response, '.windows.');
    catchLength = length('git/releases/tag/v');
    index1 = index1 + catchLength;
    latestVersion = [];
    if  ~isempty(index2) && ~isempty(index1)
        if index2(1) > index1(1)
            latestVersion = response(index1(1):index2(1) - 1);
        end
    end
    if isempty(latestVersion)
        latestVersion = baseVersion;
    end
    latestVersionNum = str2num(strrep(latestVersion, '.', ''));
    
    % test here if the latest version is up-to-date
    if latestVersionNum > installedVersionNum
        % retrieve and install the portable git bash and associated tools
        fprintf(' > gitBash is not up-to-date. Updating ... ');
        retrieveAndInstall(latestVersion);
        fprintf('Done.\n');
    else
        fprintf(' > gitBash is up-to-date.\n\n');
    end
elseif exist(pathPortableGit, 'file') ~= 7
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
% mode: cleanInstall or update

    global CBTDIR

    % save the current directory
    currentDir = pwd;

    % change to temporary directory
    cd([CBTDIR filesep '.tmp']);
    
    % define URL of PortableGit
    urlPortableGit = ['https://github.com/git-for-windows/git/releases/download/v' gitBashVersion '.windows.1/PortableGit-' gitBashVersion '-64-bit.7z.exe'];
    fileNamePortableGit = ['PortableGit-' gitBashVersion '.exe'];

    % define the path to portable gitBash
    pathPortableGit = [CBTDIR filesep '.tmp' filesep 'PortableGit-' gitBashVersion];
    
    % download the file
    if exist(fileNamePortableGit, 'file') ~= 2
        urlwrite(urlPortableGit, fileNamePortableGit);
        fprintf(' > GitBash downloaded.\n');
    end
    
    if exist(pathPortableGit, 'file') == 7
        try
        rmpath(genpath(pathPortableGit));
        rmdir(pathPortableGit, 's');
        fprintf(' > GitBash folder removed.\n');
        catch
        end
    end

    % extract the archive
    if exist(fileNamePortableGit, 'file') == 2
        
        % extract the archive
        system([fileNamePortableGit ' -y']);
        
        % rename the folder
        movefile('PortableGit', ['PortableGit-' gitBashVersion])
        
        % remove the downloaded file
        rmpath(fileNamePortableGit);
        delete(fileNamePortableGit);
        fprintf(' > GitBash compressed archive removed.\n');
        
        % define the system path
        %C:\Users\laurent.heirendt\Desktop\cobratoolbox\.tmp\PortableGit-2.13.3\cmd;C:\Users\laurent.heirendt\Desktop\cobratoolbox\.tmp\PortableGit-2.13.3\bin;C:\Users\laurent.heirendt\Desktop\cobratoolbox\.tmp\PortableGit-2.13.3\usr\bin;C:\Users\laurent.heirendt\Desktop\cobratoolbox\.tmp\PortableGit-2.13.3\mingw64\bin
        %add runtime
        pathPortableGitBin1 = [pathPortableGit filesep 'mingw64' filesep 'bin'];
        pathPortableGitBin2 = [pathPortableGit filesep 'cmd'];
        pathPortableGitBin3 = [pathPortableGit filesep 'bin'];
        pathPortableGitBin4 = [pathPortableGit filesep 'user' filesep 'bin'];
       
        % set the path machine wide
        setsysenvironvar('Path', [pathPortableGitBin1 ';' pathPortableGitBin2 ';' pathPortableGitBin3 ';' pathPortableGitBin4 ';' getsysenvironvar('Path')]);

        % set the path for the current session
        setenv('Path', [pathPortableGitBin1 ';' pathPortableGitBin2 ';' pathPortableGitBin3 ';' pathPortableGitBin4 ';' getenv('Path') ]);
        
        % add the path to the MATLABPATH
        addpath(genpath(pathPortableGit));
        fprintf(' > All paths set.\n');
    else
        error('Portable git-bash cannot be downloaded. Check your internet connection.');
    end

    % jump back to the old directory
    cd(currentDir);
end