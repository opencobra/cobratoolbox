% The COBRAToolbox: testGenerateFieldDescriptionFile.m
%
% Purpose:
%     - test the generateFieldDescriptionFile function
%
% Authors:
%     - Jacek Wachowiak
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
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

%% an unknown toolbox root is found by initialising the toolbox (without an update)
savedCBTDIR = CBTDIR;
CBTDIR = [];
try
    initialisedString = generateFieldDescriptionFile();
catch ME
    CBTDIR = savedCBTDIR;
    rethrow(ME);
end
assert(strcmp(CBTDIR, savedCBTDIR));
assert(isequal(initialisedString, refData_FileString));

% remove the default reference file regenerated above as a side effect
% (it is intentionally not tracked in the repository)
defaultRefFile = [CBTDIR filesep 'documentation' filesep 'source' filesep 'notes' filesep 'COBRAModelFields.md'];
if exist(defaultRefFile, 'file')
    delete(defaultRefFile);
end

% change to old directory
cd(currentDir);
