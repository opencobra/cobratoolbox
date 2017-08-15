% The COBRAToolbox: testGenerateFieldDescriptionFile.m
%
% Purpose:
%     - test the generateFieldDescriptionFile function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR;
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateFieldDescriptionFile'));
cd(fileDir);

% test variables
FileName = 'testData_generateFieldDescriptionFile.md';

% rerun the default function and save the output for references
generateFieldDescriptionFile();
fileID = fopen([CBTDIR filesep 'docs' filesep 'source' filesep 'notes' filesep 'COBRAModelFields.md'], 'r');
refData_FileString = fscanf(fileID, '%c');

% function outputs
testData_FileString = generateFieldDescriptionFile(FileName);

% test
assert(isequal(testData_FileString, refData_FileString));

% removal of test fileID
delete 'testData_generateFieldDescriptionFile.md'

% change to old directory
cd(currentDir);
