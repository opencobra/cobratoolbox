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
fileDir = fileparts(which('testPrintLabeledData'));
cd(fileDir);

labels = {'row1'; 'row2'; 'row3'};
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
labels = {'row1'; 'row2'};
sortCol = 0;
data = [1, 9, 4; 4, 7, 8];
printLabeledData(string(labels), data, nonzeroFlag, sortCol, fileName, headerRow, sortMode);

data = [2, NaN, NaN; 3, NaN, NaN];
printLabeledData(string(labels), data, nonzeroFlag, sortCol, fileName, headerRow, sortMode);

% remove the generated file
if exist(fileName, 'file') == 2
    delete (fileName)
end

% change the directory
cd(currentDir)
