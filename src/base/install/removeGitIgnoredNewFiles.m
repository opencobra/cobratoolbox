function removeGitIgnoredNewFiles(directory, oldcontent)
% Removes all files that are in the specified directory but not part of
% the oldcontent if they match any file indicated by the gitignored files
% of the COBRA Toolbox .gitignore file.
%
% USAGE:
%     removeGitIgnoredNewFiles(directory, content)
%
% INPUT:
%     directory: The directory which should be checked for changing files.
%     content:   Absolute file names of the original conten in a cell array. 
%

currentDir = cd(directory);

% get the new Content of the folder.
newContent = getFilesInDir('gitFileType','ignored');

% get all .log files that were present only after initCobraToolbox was called.
newIgnoredFiles = setdiff(newContent, oldcontent);

% by adding the folder, we already have the correct path.
if ~isempty(newIgnoredFiles)
    delete(newIgnoredFiles{:});
end

cd(currentDir);
end