% The COBRAToolbox: testPrintLabeledData.m
%
% Purpose:
%     - Tests the printLabeledData function
%
% Author:
%     - Original file: Lemmer El Assal

% define the path to The COBRA Toolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

cd([CBTDIR, filesep, 'test', filesep, 'serialTests', filesep, 'testTools'])

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
fullFileNamePath = [CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testTools', filesep, fileName];
if exist(fullFileNamePath, 'file') == 2
    system(['rm ', fullFileNamePath]);
else
    warning(['The file', fullFileNamePath, ' does not exist and could not be deleted.']);
end

% change the directory
cd(CBTDIR)
