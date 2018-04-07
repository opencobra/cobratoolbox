function status = removeTempFiles(directory, oldcontent, varargin)
% Removes all files that are in the specified directory but not part of
% the oldcontent. By default only removes those files which match files
% mentioned in the COBRA .gitignore file.
%
% USAGE:
%    status = removeTempFiles(directory, oldcontent, varargin)
%
% INPUT:
%    directory: The directory which should be checked for changing files.
%    content:   Absolute file names of the original conten in a cell array.
%
% OPTIONAL INPUT:
%    varargin:  Additional options as `ParameterName`, value
%               pairs with the following options:
%
%                - `COBRAGitIgnoredOnly`: only remove files which are listed by the COBRA gitignore file (default: true)
%                - `checkSubFolders`: check subFolder (default: true)
%
% OUTPUT:
%
%    status:    status of the deletion (`true` if successful)

parser = inputParser();
parser.addParamValue('COBRAGitIgnoredOnly',true,@(x) islogical(x) || isnumeric(x) && (x == 0 || x == 1));
parser.addParamValue('checkSubFolders',true,@(x) islogical(x) || isnumeric(x) && (x == 0 || x == 1));

parser.parse(varargin{:});
cobraGitIgnoredOnly = parser.Results.COBRAGitIgnoredOnly;
checkSubFolders = parser.Results.checkSubFolders;

currentDir = cd(directory);

if cobraGitIgnoredOnly
    gitTypeFlag = 'ignoredByCOBRA';
else
    gitTypeFlag = 'all';
end

% get the new Content of the folder.
newContent = getFilesInDir('type',gitTypeFlag,'checkSubFolders',checkSubFolders);

% get all .log files that were present only after initCobraToolbox was called.
newIgnoredFiles = setdiff(newContent, oldcontent);

% get the warning status
cwarn = warning();
%Turn off the warnings, to avoid warnings being shown for this
warning off
warning('PlaceHolder') %create a placeholder to test if the delete call throws a warning.
lwarn = lastwarn;

% by adding the folder, we already have the correct path.
if ~isempty(newIgnoredFiles)
    delete(newIgnoredFiles{:});
end
newlwarn = lastwarn;
%Restore the warning settings
warning(cwarn)

%Set the status
if strcmpi(lwarn,newlwarn)
    status = true;
else
    status = false;
end

cd(currentDir);

end
