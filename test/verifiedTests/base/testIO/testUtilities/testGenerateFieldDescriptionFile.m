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

% test variable
FileName = 'testData_generateFieldDescriptionFile.md';

% rerun the default function and use its returned string as reference
% (generateFieldDescriptionFile returns exactly what it writes; reading it back
% from disk depended on a reference file that is no longer committed)
refData_FileString = generateFieldDescriptionFile();

% function output
testData_FileString = generateFieldDescriptionFile(FileName);

% test
assert(isequal(testData_FileString, refData_FileString));

% removal of test file
delete 'testData_generateFieldDescriptionFile.md'

% remove the default reference file regenerated above as a side effect
% (it is intentionally not tracked in the repository)
defaultRefFile = [CBTDIR filesep 'documentation' filesep 'source' filesep 'notes' filesep 'COBRAModelFields.md'];
if exist(defaultRefFile, 'file')
    delete(defaultRefFile);
end

% change to old directory
cd(currentDir);
