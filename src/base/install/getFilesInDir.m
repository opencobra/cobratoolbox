function files = getFilesInDir(varargin)
% List all files in the supplied (git tracked) Directory with their absolute path name
% based on the git ls-file command. If the directory is not git controlled, the
% type is assumed to be 'all' and all files (except for .git files
% will be returned).
%
% USAGE:
%    files = getFilesInDir(varargin)
%
% OPTIONAL INPUTS:
%    varargin:     Options as 'ParameterName' value pairs with the following options:
%
%                   - `dirToList`: the directory to list the files for (default: the current working directory)
%                   - `type`: Git type of files to return
%
%                      - `tracked`: Only tracked files
%                      - `ignored`: Only `git` ignored files excluding files that are tracked but ignored (specified in .gitignore). If the folder is not controlled by git, `all` will be used.
%                      - `untracked`: anything that is not ignored and not tracked (new files)
%                      - `all`: all files except for the git specific files (e.g. .git, .gitignore etc).
%                      - `ignoredByCOBRA`: use the COBRA Toolbox .gitignore file. Only return those files that match patterns specified there. Slower than `ignored` since all files have to be manually checked against the expressions specified in the .gitignore file, but available on all folders (default: `all`)
%                   - `restrictToPattern` - give a regexp pattern to filter the files, this option is ignored if empty (default: '', i.e. ignored)
%                   - `checkSubFolders - check the subfolders of the current directory (default: `true`)
%                   - `printLevel`
%
%                      - `0`: No print out (default)
%                      - `1`: print Information
%
%
% OUTPUTS:
%    files:         A Cell Array of files with absolute file pathes.
%                   present in this folder matching the options choosen.
%
% EXAMPLES:
%
%    % get all m files in the source folder:
%    files = getFilesInDir('dirToList', [CBTDIR filesep 'src'], 'restrictToPattern', '\.m$');
%
%    % Get the git tracked files in the test Directory.
%    files = getFilesInDir('dirToList', [CBTDIR filesep 'test'], 'type', 'tracked');
%
%    % get all git tracked files  which start with "MyFile" in the current directory
%    files = getFilesInDir('type', 'tracked', 'restrictToPattern', '^MyFile');
%
%    % get only the gitIgnored files in the current folder
%    files = getFilesInDir('type', 'ignored');

persistent COBRAIgnored

if isempty(COBRAIgnored)
    COBRAIgnored = regexptranslate('wildcard',getIgnoredFiles());
end

gitFileTypes = {'tracked','all','untracked','ignored','ignoredByCOBRA'};
parser = inputParser();
parser.addParamValue('dirToList',pwd,@(x) exist(x,'file') == 7);
parser.addParamValue('type','all',@(x) ischar(x) && any(strcmpi(x,gitFileTypes)));
parser.addParamValue('restrictToPattern','',@(x) ischar(x));
parser.addParamValue('checkSubFolders','',@(x) islogical(x) || (isnumeric(x) && x == 0 || x == 1));
parser.addParamValue('printLevel',0,@(x) isnumeric(x));

parser.parse(varargin{:});

printLevel = parser.Results.printLevel;

%get the absolute path of the files that are listed
currentDir = cd(parser.Results.dirToList);

%get the absolute path to the folder to be listed.
absPath = pwd;

%get the type of files to obtain.
selectedType = lower(parser.Results.type);

%test, whether the folder is git controlled
[gitStatus,~] = system('git status');
if gitStatus ~= 0 && ~strcmpi(selectedType,'ignoredbycobra')
    selectedType = 'all';
end
if gitStatus == 0 && strcmpi(selectedType,'ignoredbycobra')
    [~,repos] = system('git remote -v');
    if any(cellfun(@(x) ~isempty(strfind(x,'cobratoolbox.git')),strsplit(repos,'\n')))
        %So, we are on a COBRA repo. lets just use the ignored option
        selectedType = 'ignored';
    end
end

if gitStatus == 0 && printLevel > 0 && strcmp(selectedType,'ignored')
    [~,folder] = system('git rev-parse --show-toplevel');
    fprintf('Using the .gitignore files as specified in the repository under:\n%s\n',folder);
end


switch selectedType
    case 'all'
        if gitStatus == 0
            [status, trackedfiles] = system('git ls-files');
            [status, untrackedfiles] = system('git ls-files -o');
            trackedfiles = strsplit(strtrim(trackedfiles), '\n');
            untrackedfiles = strsplit(strtrim(untrackedfiles), '\n');
            files = [trackedfiles,untrackedfiles];
        else
           if parser.Results.checkSubFolders
               rdircall = ['**' filesep '*'];
           else
               rdircall = ['*'];
           end
           files = rdir(rdircall);
           files = {files.name}'; %Need to transpose to give consistent results.
        end

    case 'tracked'
        [status, files] = system('git ls-files');
        files = strsplit(strtrim(files), '\n');
    case 'untracked'
        %Files, which are not tracked but are not ignored.
        [status, files] = system('git ls-files -o --exclude-standard');
        files = strsplit(strtrim(files), '\n');
    case 'ignored'
        [~, files] = system('git ls-files -o -i --exclude-standard');
        files = strsplit(strtrim(files), '\n');
    case 'ignoredbycobra'
        if gitStatus == 0
            [status, trackedfiles] = system('git ls-files');
            [status, untrackedfiles] = system('git ls-files -o');
            trackedfiles = strsplit(strtrim(trackedfiles), '\n');
            untrackedfiles = strsplit(strtrim(untrackedfiles), '\n');
            files = [trackedfiles,untrackedfiles];
        else
           files = rdir(['**' filesep '*']);
           files = {files.name}'; %Need to transpose to give consistent results.
        end
        matching = false(size(files));
        for i = 1:numel(COBRAIgnored)
            matching = matching | ~cellfun(@(x) isempty(regexp(x,COBRAIgnored{i},'ONCE')),files);
        end
        files = files(matching);

end
if ~parser.Results.checkSubFolders
    files = files(cellfun(@(x) isempty(regexp(x,regexptranslate('escape',filesep))),files));
end

files = strcat(absPath, filesep, files);

%Filter according to the restriction pattern.
if ~isempty(parser.Results.restrictToPattern)
    files = files(cellfun(@(x) ~isempty(regexp(x,parser.Results.restrictToPattern)), files));
end

cd(currentDir);
end



