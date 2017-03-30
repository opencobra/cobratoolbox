% The COBRAToolbox: testPrintLabeledData.m
%
% Purpose:
%     - Tests the printLabeledData function
%
% Author:
%     - Original file: Lemmer El Assal

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which(mfilename)));

labels = {'row1', 'row2', 'row3'};
data = ones(3);
nonzeroFlag = 1;
sortCol = -1;
fileName = 'testData_printLabeledData.txt';
headerRow = {'col1', 'col2', 'col3'};
sortMode = 'descend';

printLabeledData(labels, data);
printLabeledData(labels, data, nonzeroFlag, sortCol, fileName, headerRow, sortMode);

text1 = fileread('refData_printLabeledData.txt');
text2 = fileread(fileName);
assert(strcmp(text1, text2));

% remove the generated file
fullFileNamePath = [fileparts(which(mfilename)), filesep, fileName];
if exist(fullFileNamePath, 'file') == 2
    delete(fullFileNamePath);
end

% change the directory
cd(currentDir)
