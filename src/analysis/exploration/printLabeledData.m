function printLabeledData(labels, data, nonzeroFlag, sortCol, fileName, headerRow, sortMode)
% Print a matrix of data with labels
%
% USAGE:
%
%    printLabeledData(labels, data, nonzeroFlag, sortCol, fileName, headerRow, sortMode)
%
% INPUTS:
%    labels:         Row labels
%    data:           Data matrix/vector
%    nonzeroFlag:    Only print nonzero rows (opt)
%    sortCol:        Column used for sorting (-1, none; 0, labels; >0, data columns; opt)
%    fileName:       Name of output file (opt)
%    headerRow:      Header (opt)
%    sortMode:       Sort mode, 'ascend' or 'descend' (opt, default 'ascend')
%
% .. Authors: Markus Herrgard 6/9/06

tol = 1e-9;




[n, m] = size(data);

if (nargin < 3)
    nonzeroFlag = false;
end
if (nargin < 4)
    sortCol = -1;
end
if (nargin < 5)
    printToFileFlag = false;
else
    if (isempty(fileName))
        printToFileFlag = false;
    else
        printToFileFlag = true;
    end
end
if (nargin < 6)
    printHeaderFlag = false;
else
    if (isempty(headerRow))
        printHeaderFlag = false;
    else
        printHeaderFlag = true;
    end
end
if (nargin < 7)
    sortMode = 'ascend';
end



if (printToFileFlag)
    if (~isempty(fileName))
        fid = fopen(fileName, 'w');
    end
    format = '%g\t';
    stringHeaderFormat = '%-s\t';
    stringRowFormat = '%s\t';
else
    fid = 1;
    format = '%12.4g';
    stringHeaderFormat = '%-20s\t'; %Keep a definite separation between header and data
    stringRowFormat = '%20s';
end

if (printHeaderFlag)
    fprintf(fid,stringHeaderFormat,''); %print the header
    for i = 1:length(headerRow)
        fprintf(fid, stringRowFormat, headerRow{i});
    end
    fprintf(fid, '\n');
end

if (sortCol == 0)
    [tmp, sortInd] = sort(labels);
    labels = labels(sortInd, :);
    data = data(sortInd, :);
elseif(sortCol > 0)
    [tmp, sortInd] = sort(data(:, sortCol), 1, sortMode);
    data = data(sortInd, :);
    labels = labels(sortInd, :);
end

data=full(data); %so it will print

[n, nLab] = size(labels);

for i = 1:n
    if ~(nonzeroFlag & ((sum(abs(data(i, :))) < tol) | all(isnan(data(i, :)))))  % Print only nonzeros
        for j = 1:nLab
            fprintf(fid, stringHeaderFormat, labels{i, j});
        end
        for j = 1:m
            if (~isnan(data(i, j)))
                fprintf(fid, format, data(i, j));
            else
                fprintf(fid, stringRowFormat, 'NA');
            end
        end
        fprintf(fid, '\n');
    end
end

if (printToFileFlag)
    fclose(fid);
end
