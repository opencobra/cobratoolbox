function raw = descFileRead(fileName)
% This function provides the same raw output as tdfread from the 
% statistics toolbox, making sure, that we don't need that as a
% prerequesite
%
% USAGE:
%
%    [raw] = descFileRead(fileName)
%
% INPUT:
%    fileName:             The filename of a tab delimited data file. The
%                          first row of the file will be considered to be headers (with spaces
%                          being replaced by '_'.
%
% OUTPUTS:
%    raw:                  A struct with one field per header and a char
%                          array of all data listed in the column.
%
% .. Author: - Thomas Pfau Oct 2017

f = fopen(fileName);

%Get the headers
header = fgetl(f);
headers = strrep(strsplit(header,'\t','CollapseDelimiters',false),' ','_');

%Read the data
cline = fgetl(f);
%Initialize the data array.
data = cell(2*length(headers),1);
data(:) = {''};
%Walk through the lines
currentLine = 1;
while cline ~= -1
    %Keep empty entries.
    cdata = strsplit(cline,'\t','CollapseDelimiters',false);
    for i = 1:length(cdata)
        cdataElem = cdata{i};
        exData = data{2*i};
        exData(currentLine,1:length(cdataElem)) = cdataElem;
        data{2*i} = exData;
    end
    currentLine = currentLine + 1;
    cline = fgetl(f);
end
%Distribute the headers.
[data{1:2:end}] = deal(headers{:});

raw = struct(data{:});
    
fclose(f);