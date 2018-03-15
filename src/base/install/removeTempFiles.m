function removeTempFiles(directory, oldcontent, varargin)
% Removes all files that are in the specified directory but not part of
% the oldcontent. By default only removes those files which match files
% mentioned in the COBRA .gitignore file.
% USAGE:
%    removeTempFiles(directory, oldcontent, varargin)
%
% INPUT:
%    directory: The directory which should be checked for changing files.
%    content:   Absolute file names of the original conten in a cell array. 
% 
% OPTIONAL INPUT:
%    varargin:             Additional Options as 'ParameterName', value
%                          pairs with the following options:
%                          COBRAGitIgnoredOnly - Whether to only remove files which are listed by
%                                                the COBRA gitignore file.
%                                                (Default: true)
%                          checkSubFolders -     Whether to check subFolder (Default: true)
%

parser = inputParser();
parser.addParamValue('COBRAGitIgnoredOnly',true,@(x) islogical(x) || isnumeric(x) && (x == 0 || x == 1));
parser.addParamValue('checkSubFolders',true,@(x) islogical(x) || isnumeric(x) && (x == 0 || x == 1));

parser.parse(varargin{:});
COBRAGitIgnoredOnly = parser.Results.COBRAGitIgnoredOnly;
checkSubFolders = parser.Results.checkSubFolders;

currentDir = cd(directory);

if COBRAGitIgnoredOnly
    gitTypeFlag = 'COBRAIgnored';
else
    gitTypeFlag = 'all';
end

% get the new Content of the folder.
newContent = getFilesInDir('gitTypeFlag',gitTypeFlag,'checkSubFolders',checkSubFolders);

% get all .log files that were present only after initCobraToolbox was called.
newIgnoredFiles = setdiff(newContent, oldcontent);

% by adding the folder, we already have the correct path.
if ~isempty(newIgnoredFiles)
    delete(newIgnoredFiles{:});
end

cd(currentDir);
end