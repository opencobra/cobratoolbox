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


newContent = dir(folder);%Get the Content of the CBTDIR

%Get all .log files that were present only after initCobraToolbox was
%called.
diffContent = setdiff({newContent.name},{oldcontent.name});
matching = cellfun(@(x) ~isempty(regexp(x,'\.log$','ONCE')),diffContent);
LogFiles = diffContent(matching);
%Attach the CBTDirectory to delete the right files.
LogFiles = strcat(folder, filesep, LogFiles);
if ~isempty(LogFiles)
    delete(LogFiles{:});
end
end