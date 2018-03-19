function files = getFilesInDir(varargin)
% List all files in the supplied (git tracked) Directory with their absolute path name
% based on the git ls-file command. If the directory is not git controlled, the
% gitTypeFlag is assumed to be 'all' and all files (except for .git files
% will be returned).
%
% USAGE:
%    files = getFilesInDir(varargin)
%
% OPTIONAL INPUTS:
%    varargin:     Options as 'ParameterName',Value pairs. Available
%                  options are:
%                  dirToList -  the directory to list the files for, 
%                               (Default: The current working directory)
%                  gitTypeFlag - Git type of files to return
%                                'tracked' - Only tracked files
%                                'ignored' - Only git ignored files
%                                            including files that are tracked but
%                                            ignored (specified in .gitignore)
%                                'untracked' - anything that is not ignored
%                                              and not tracked. (new files)
%                                'all'  - all files except for the git
%                                         specific files (e.g. .git, .gitignore etc).                               
%                                'COBRAIgnored' - use the COBRA gitIgnore
%                                                 file to determine the
%                                                 ignored files.
%                                (Default: 'all')   
%                  restrictToPattern - give a regexp pattern to filter the
%                                      files, this option is ignored if
%                                      empty. (Default: '', i.e. ignored)
%                  checkSubFolders - check the subfolders of the current
%                                    directory. (Default: true)
% 
% EXAMPLES:
%    Get all m files in the source folder:
%    files = getFilesInDir('dirToList', [CBTDIR filesep 'src'], 'restrictToPattern', '\.m$');
%    Get the git tracked files in the test Directory.
%    files = getFilesInDir('dirToList', [CBTDIR filesep 'test'], 'gitTypeFlag', 'tracked');
%    Get all git tracked files  which start with "MyFile" in the current directory
%    files = getFilesInDir('gitTypeFlag', 'tracked', 'restrictToPattern', '^MyFile');
%    Get only the gitIgnored files in the current folder
%    files = getFilesInDir('gitTypeFlag', 'ignored');

persistent COBRAIgnored

if isempty(COBRAIgnored)
    COBRAIgnored = regexptranslate('wildcard',getIgnoredFiles());
end

gitFileTypes = {'tracked','all','untracked','ignored','COBRAIgnored'};
parser = inputParser();
parser.addParamValue('dirToList',pwd,@(x) exist(x,'file') == 7);
parser.addParamValue('gitTypeFlag','all',@(x) ischar(x) && any(strcmpi(x,gitFileTypes)));
parser.addParamValue('restrictToPattern','',@(x) ischar(x));
parser.addParamValue('checkSubFolders','',@(x) islogical(x) || (isnumeric(x) && x == 0 || x == 1));

parser.parse(varargin{:});

%get the absolute path of the files that are listed

currentDir = cd(parser.Results.dirToList);
absPath = pwd;
%get all files in the directory.
gitType = lower(parser.Results.gitTypeFlag);

%test, whether the folder is git controlled
[gitStatus,~] = system('git status');
if gitStatus ~= 0 && ~strcmpi(gitType,'cobraignored')
    gitType = 'all';
end
if gitStatus == 0 && strcmpi(gitType,'cobraignored')
    [~,repos] = system('git remote -v');
    if any(cellfun(@(x) ~isempty(strfind(x,'cobratoolbox.git')),strsplit(repos,'\n')))
        %So, we are on a COBRA repo. lets just use the ignored option
        gitType = 'ignored';
    end
end

switch gitType
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
               rdircall = ['*']
           end
           files = rdir(rdircall); 
           files = {files.name}'; %Need to transpose to give consistent results.
        end
            
    case 'tracked'
        [status, files] = system('git ls-files');
        files = strsplit(strtrim(files), '\n');
    case 'untracked'
        %Files, which are not tracked but are not ignored.
        [status, files] = system('git ls-files -o -exclude-standard');
        files = strsplit(strtrim(files), '\n');
    case 'ignored'
        [~, files] = system('git ls-files -o -i --exclude-standard');        
        files = strsplit(strtrim(files), '\n');
    case 'cobraignored'
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
            matching = matching | ~ceyou are not on a llfun(@(x) isempty(regexp(x,COBRAIgnored{i},'ONCE')),files);
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



