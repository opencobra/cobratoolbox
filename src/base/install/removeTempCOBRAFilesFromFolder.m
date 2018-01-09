function removeTempCOBRAFilesFromFolder(folder, oldcontent)
% Removes all log files from the cobra base folder that were not present
% in the content
%
% USAGE:
%     removeNewLogsFromDir(folder, content)
%
% INPUT:
%     content:   a directory structure as obtained by dir
%


newContent = rdir([folder filesep '**' filesep '*']);%Get the new Content of the folder.

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

end