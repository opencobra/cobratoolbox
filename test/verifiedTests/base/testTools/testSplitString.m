% The COBRAToolbox: testSplitString.m
%
% Purpose:
%     - testSplitString tests the functionality of splitString()
%       and checks solution against a known solution.
%
% Authors:
%     - Lemmer El Assal February 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSplitString'));
cd(fileDir);

ref_fields = {'Some'; 'Strings'; 'Delimited'};

testString1 = 'Some Strings Delimited';
testString2 = 'Some|Strings|Delimited';
fields1 = splitString(testString1);
fields2 = splitString(testString2, '\|');

assert(isequal(ref_fields, fields1));
assert(isequal(ref_fields, fields2));

% cell array of strings
cellArr = {'String 1', 'testString 2'};

fields = splitString(cellArr, ' ');

assert(isequal(strcmp(fields{1}, {'String', '1'}), [true true]));
assert(isequal(strcmp(fields{2}, {'testString', '2'}), [true true]));

% test if the delimiter is not found
fields = splitString(testString2, ' ');
assert(strcmp(testString2, fields{1}) == 1)

% change the directory
cd(currentDir)
