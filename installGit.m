global CBTDIR

% define the root path of The COBRA Toolbox
CBTDIR = fileparts(which('initCobraToolbox'));
addpath(genpath(CBTDIR))

% initialize variables
baseVersion = '2.13.3';
installedVersion = [];
installedVersionNum = 0;
archstr = computer('arch');
archBit = archstr(end-1:end);

% define the name of the temporary folder
tmpFolder = '.tmp';  
    
% determine the installed version
pathVersion = getsysenvironvar('Path');
index1 = strfind(pathVersion, [tmpFolder filesep 'PortableGit-']);
index2 = strfind(pathVersion, [filesep 'mingw' archBit filesep 'bin']);
catchLength = length([tmpFolder filesep 'PortableGit-']);
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
pathPortableGit = [CBTDIR filesep tmpFolder filesep 'PortableGit-' installedVersion];
    
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
        installGitBash(latestVersion, 1);
        fprintf('Done.\n');
    else
        fprintf(' > gitBash is up-to-date.\n\n');
    end
elseif exist(pathPortableGit, 'dir') ~= 7
    % retrieve and install the portable git bash and associated tools
    fprintf(' > gitBash is not yet installed. Installing ...\n');
    installGitBash(installedVersion, 0);
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


