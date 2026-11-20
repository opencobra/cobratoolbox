function [status, result] = lrsSpecifyRows(fileNameIn)
% Read the number of rows of data in an lrs input file and replace the
% `*****` placeholder with the actual number of rows
%
% USAGE:
%
%    [status, result] = lrsSpecifyRows(fileNameIn)
%
% INPUT:
%    fileNameIn:    name (or full path) of the lrs `.ine`/`.ext` file to edit in place
%
% OUTPUTS:
%    status:        0 (the file was edited)
%    result:        empty character array
%
% NOTE:
%
%    The file is read, edited and written back in MATLAB: every `*****` is replaced
%    by the number of data rows, leftmost and without overlap, and all other bytes are
%    kept. (Feature 20261120-144501-lrsspecifyrows-without-sed, November 2026,
%    Constitution Principle XI. Before, GNU `sed -i` did the replacement, which failed
%    with the BSD sed of macOS and on Windows, and `status`/`result` were those of the
%    sed call.)

if ~contains(fileNameIn,filesep)
    fileNameIn = [pwd filesep fileNameIn];
end

% opening for reading and writing checks that the file can be edited in place
fid = fopen(fileNameIn,'r+');
if fid<0
    error('Could not open lrs output file.');
end
fileText = fread(fid, Inf, '*char')';
fclose(fid);

% count the lines from "begin" to "end", as fgetl would read them
fileLines = strsplit(fileText, newline, 'CollapseDelimiters', false);
countRows = 0;
foundEnd = false;
for i = 1:numel(fileLines)
    tline = fileLines{i};
    if countRows ~=0
        countRows = countRows + 1;
    end
    if strcmp(tline, 'begin')
        countRows = 1;
    elseif strcmp(tline, 'end')
        foundEnd = true;
        break
    end
end
if ~foundEnd
    error('Could not read lrs output file.');
end
nRows = countRows -3;

% replace the placeholder by the number of rows and write the file back
fileText = regexprep(fileText, '\*\*\*\*\*', int2str(nRows));
fid = fopen(fileNameIn, 'w');
fwrite(fid, fileText);
fclose(fid);

status = 0;
result = '';

end
