function ignoredFiles = getIgnoredFiles()
% Get all files/patterns which are ignored by git in the COBRA Toolbox directory..
% USAGE:
%
%    ignoreFiles = getIgnoredFiles()
%
% OUTPUTS:
%
%    ignoredFiles:      All files (and patterns) indicated as ignored in
%                       the gitignore file.
%
% Authors:      Original Code: Laurent Heirandt
%               Move to function: Thomas Pfau, Jan 2018


global CBTDIR

fid = fopen([CBTDIR filesep '.gitignore']);

% initialise
counter = 1;
ignoredFiles = {};

% loop through the file names of the .gitignore file
while ~feof(fid)
    lineOfFile = strtrim(char(fgetl(fid)));
    
    % only retain the lines that end with .txt and .m and are not comments and point to files in the /src folder
    if length(lineOfFile) > 4
        if ~strcmp(lineOfFile(1), '#') && strcmp(lineOfFile(1:4), 'src/') && (strcmp(lineOfFile(end - 3:end), '.txt') || strcmp(lineOfFile(end - 1:end), '.m'))
            ignoredFiles{counter} = lineOfFile;
            counter = counter + 1;
        end
    end
end

% close the .gitignore file
fclose(fid);