function ignoredFiles = getIgnoredFiles(ignorepatterns, filterpatterns)
% Get all files/patterns which are ignored by git in the COBRA Toolbox directory..
% USAGE:
%
%    ignoreFiles = getIgnoredFiles()
%
% OPTIONAL INPUTS:
%    ignorePatterns:    A cell array of regexp patterns indicating files
%                       which are not to be listed
%    filterpatterns:    A cell array of regexp patterns identifying those
%                       files which should be returned after ignoring.
%
% OUTPUTS:
%    ignoredFiles:      All files (and patterns) indicated as ignored in
%                       the gitignore file.
%
% .. Authors: - Original Code: Laurent Heirandt
%          - Move to function: Thomas Pfau, Jan 2018


global CBTDIR

fid = fopen([CBTDIR filesep '.gitignore']);
emptyAndCommentLines = {'^#','^$'};
if ~exist('ignorepatterns','var')
    ignorepatterns = emptyAndCommentLines;
else
    ignorepatterns = union(ignorepatterns,emptyAndCommentLines);
end

if ~exist('filterpatterns','var')
    filterpatterns = {'.*'};
end

% initialise
counter = 1;
ignoredFiles = {};


% loop through the file names of the .gitignore file
while ~feof(fid)
    lineOfFile = strtrim(char(fgetl(fid)));
    %remove lines that match any ignore pattern and do not match any
    %filterpattern
    if ~any(~cellfun(@(x) isempty(regexp(lineOfFile,x,'ONCE')),ignorepatterns))
        if any(~cellfun(@(x) isempty(regexp(lineOfFile,x,'ONCE')),filterpatterns))
            ignoredFiles{counter} = lineOfFile;
            counter = counter + 1;
        end
    end
end

% close the .gitignore file
fclose(fid);
