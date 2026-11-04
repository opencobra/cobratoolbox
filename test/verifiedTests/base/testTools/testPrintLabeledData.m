% The COBRAToolbox: testPrintLabeledData.m
%
% Purpose:
%     - Tests the printLabeledData function
%
% Function under test:
%     src/analysis/exploration/printLabeledData.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; labels and data are written by hand.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Sorting on a data column other than the first is silently ignored
%       SEVERITY: wrong-result
%       TRIGGER: sortCol greater than 1, for example printLabeledData({'a';'b'}, [1 9; 2 3], 0, 2)
%       OBSERVED: the rows keep their input order, because `case sortCol > 0` of the switch
%         compares sortCol with the logical value true, which only equals 1
%       EXPECTED: the rows are sorted on the requested data column, as documented for sortCol
%       LINES: 81
%
% Author:
%     - Original file: Lemmer El Assal
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintLabeledData'));
cd(fileDir);

% this test needs no solver, toolbox or particular operating system
prepareTest();

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
text1 = regexprep(text1,'[^a-zA-Z0-9]','');
text2 = regexprep(text2,'[^a-zA-Z0-9]','');
assert(strcmp(text1, text2));

data = [2, NaN, NaN; 2, NaN, NaN; 2, NaN, NaN];
printLabeledData(labels, data, nonzeroFlag, sortCol, fileName, headerRow, sortMode);

labels = {'row1'; 'row2'};
sortCol = 0;
data = [1, 9, 4; 4, 7, 8];
printLabeledData(labels, data, nonzeroFlag, sortCol, fileName, headerRow, sortMode);

% remove the generated file
delete(fileName)

%% an empty file name prints on the screen and an empty header prints no header row
printed = evalc('printLabeledData(labels, data, 0, -1, '''', [])');
assert(contains(printed, 'row1') && contains(printed, 'row2'));
assert(~contains(printed, 'col1'));
assert(~exist(fileName, 'file'));

%% sorting on the first data column follows the sort mode (ascending by default)
printed = evalc('printLabeledData({''low''; ''high''}, [1; 5], 0, 1, [], [], ''descend'')');
assert(strfind(printed, 'high') < strfind(printed, 'low'));
printed = evalc('printLabeledData({''high''; ''low''}, [5; 1], 0, 1)');
assert(strfind(printed, 'low') < strfind(printed, 'high'));

% change the directory
cd(currentDir)
