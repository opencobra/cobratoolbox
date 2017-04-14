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

data = [2, NaN, NaN; 2, NaN, NaN; 2, NaN, NaN];
printLabeledData(labels, data, nonzeroFlag, sortCol, fileName, headerRow, sortMode);

labels = {'row1'; 'row2'};
sortCol = 0;
data = [1, 9, 4; 4, 7, 8];
printLabeledData(labels, data, nonzeroFlag, sortCol, fileName, headerRow, sortMode);

% remove the generated file
delete(fileName)

% change the directory
cd(currentDir)
