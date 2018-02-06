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
%     content:   The directory structure obtained by rdir called in the
%                directory indicated (i.e. cd(directory); content =
%                rdir(['**' filesep '*'])
%


currentDir = cd(directory);

newContent = rdir(['**' filesep '*']);%Get the new Content of the folder.

%Get all .log files that were present only after initCobraToolbox was
%called.
diffContent = setdiff({newContent.name},{oldcontent.name});

%Get all Files that are ignored by git. Those are temporary files which
%should be cleaned up.
ignoredFiles = regexptranslate('wildcard',getIgnoredFiles());

matching = false(size(diffContent));

for i = 1:numel(ignoredFiles)
    matching = matching | ~cellfun(@(x) isempty(regexp(x,ignoredFiles{i},'ONCE')),diffContent);
end

LogFiles = diffContent(matching);
%By adding the folder, we already have the correct path.
if ~isempty(LogFiles)
    delete(LogFiles{:});
end

cd(currentDir);
end