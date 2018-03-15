function files = getFilesInDir(varargin)
% List all files in the supplied (git tracked) Directory with their absolute path name
% based on the git ls-file command. This command will never list git
% specific files (i.e. files in .git folders or the git specific attribute
% files e.g. .gitignore)
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
%                                (Default: 'all')   
%                  restrictToPattern - give a regexp pattern to filter the
%                                      files, this option is ignored if
%                                      empty. (Default: '', i.e. ignored)
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

gitFileTypes = {'tracked','all','untracked','ignored'};
parser = inputParser();
parser.addParamValue('dirToList',pwd,@(x) exist(x,'file') == 7);
parser.addParamValue('gitTypeFlag','all',@(x) ischar(x) && any(strcmpi(x,gitFileTypes)));
parser.addParamValue('restrictToPattern','',@(x) ischar(x));

parser.parse(varargin{:});

%get the absolute path of the files that are listed

currentDir = cd(parser.Results.dirToList);
absPath = pwd;
%get all files in the directory.
gitType = lower(parser.Results.gitTypeFlag);
switch gitType
    case 'all'
        [~, trackedfiles] = system('git ls-files');
        trackedfiles = strsplit(trackedfiles, '\n');
        [~, untrackedfiles] = system('git ls-files -o');
        untrackedfiles = strsplit(untrackedfiles, '\n');
        files = [trackedfiles,untrackedfiles];
    case 'tracked'
        [~, files] = system('git ls-files');
        files = strsplit(files, '\n');
    case 'untracked'
        %Files, which are not tracked but are not ignored.
        [~, files] = system('git ls-files -o -exclude-standard');
        files = strsplit(files, '\n');
    case 'ignored'
        [~, files] = system('git ls-files -o -i --exclude-standard');        
        files = strsplit(files, '\n');
end

files = strcat(absPath, files);

%Filter according to the restriction pattern.
if ~isempty(parser.Results.restrictToPattern)
    files = files(cellfun(@(x) ~isempty(regexp(x,parser.Results.restrictToPattern)), files));
end

cd(currentDir);
