% The COBRAToolbox: testGenerateStructFunction.m
%
% Purpose:
%     - generateStructFunction writes a script <structName>_init.m to the current directory
%       with one assignment per numeric or char field of a struct (numeric values through
%       mat2str, char values between quotes) and skips all other fields. This test checks the
%       exact text written for numeric, char, empty and skipped fields, that running the
%       generated script recreates the written fields, and that a struct without fields gives
%       an empty script. Expected texts are derived from the documented format of each line
%       ("<structName>.<field> = <value>;") and from mat2str, not from a run of the function.
%     - The generated files are written to a tempname folder that the test removes.
%
% Function under test:
%     src/base/utilities/generateStructFunction.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built structs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A char value with a quote gives a script that cannot run
%       SEVERITY: limitation
%       TRIGGER: generateStructFunction(struct('f', 'it''s'), 'myStruct')
%       OBSERVED: the line myStruct.f = 'it's'; is written without doubling the quote, and
%         running the script stops with "Invalid expression. Check for missing multiplication
%         operator, missing or unbalanced delimiters, or other syntax error." (R2025a,
%         2026-11-15)
%       EXPECTED: the quote doubled (myStruct.f = 'it''s';), so that the value is recreated
%       LINES: 33
%     - DEFECT: A char matrix with more than one row is written column by column
%       SEVERITY: limitation
%       TRIGGER: generateStructFunction(struct('h', ['ab'; 'cd']), 'myStruct')
%       OBSERVED: the line myStruct.h = 'acbd'; is written (fprintf reads the matrix in column
%         order), so the script recreates a different 1 x 4 value (R2025a, 2026-11-15)
%       EXPECTED: the 2 x 2 char matrix recreated, for example through mat2str
%       LINES: 33
%     - DEFECT: Numeric values lose their class and digits beyond the 15th
%       SEVERITY: limitation
%       TRIGGER: generateStructFunction(struct('d', pi, 'e', int8(5)), 'myStruct')
%       OBSERVED: the lines myStruct.d = 3.14159265358979; and myStruct.e = 5; are written
%         (mat2str with its default precision of 15 digits and without the 'class' option), so
%         the script recreates pi - 3.2e-15 and a double 5 (R2025a, 2026-11-15)
%       EXPECTED: the values recreated as they were (mat2str(val, 17, 'class'))
%       LINES: 30
%     - DEFECT: A numeric array with more than two dimensions stops with an error and leaves the file open
%       SEVERITY: limitation
%       TRIGGER: generateStructFunction(struct('z', ones(2, 2, 2)), 'nd')
%       OBSERVED: "Input matrix must be 2-D." (MATLAB:mat2str:TwoDInput, line 30; R2025a,
%         2026-11-15); the file nd_init.m opened at line 24 stays open (openedFiles lists it)
%       EXPECTED: the field written (for example through reshape) or skipped, and the file closed
%       LINES: 24, 30, 36
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateStructFunction'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the generated scripts are written to the current directory: work in a temporary folder
workDir = tempname;
mkdir(workDir);
filesBefore = openedFiles;
cd(workDir);

%% numeric and char fields are written in field order, other fields are skipped

% a numeric matrix, a row vector with a negative and a decimal entry, a char row, an empty
% numeric and an empty char field are written; a cell, a nested struct and a logical field
% (logical is not numeric) are skipped
inputStruct = struct('matrixField', [1 2; 3 4], 'cellField', {{1, 'a'}}, ...
    'vectorField', [-3 0.5 0.001], 'textField', 'some text', 'structField', struct('a', 1), ...
    'logicalField', true, 'emptyField', [], 'emptyText', '');
generateStructFunction(inputStruct, 'genA');

% the exact text: one line per written field, "<name>.<field> = <value>;", values as mat2str
% writes them ([1 2;3 4], [-3 0.5 0.001], [] for an empty matrix) and char values in quotes
expectedText = sprintf(['genA.matrixField = [1 2;3 4];\n', ...
    'genA.vectorField = [-3 0.5 0.001];\n', ...
    'genA.textField = ''some text'';\n', ...
    'genA.emptyField = [];\n', ...
    'genA.emptyText = '''';\n']);
assert(isfile(fullfile(workDir, 'genA_init.m')));
assert(strcmp(fileread(fullfile(workDir, 'genA_init.m')), expectedText));

% running the generated script recreates exactly the written fields (values that mat2str
% writes with all their digits, so equality is exact) and nothing else
run(fullfile(workDir, 'genA_init.m'));
assert(isequal(sort(fieldnames(genA)), sort({'matrixField'; 'vectorField'; 'textField'; 'emptyField'; 'emptyText'})));
assert(isequal(genA.matrixField, inputStruct.matrixField));
assert(isequal(genA.vectorField, inputStruct.vectorField));
assert(strcmp(genA.textField, inputStruct.textField));
assert(isempty(genA.emptyField) && isnumeric(genA.emptyField));
assert(isempty(genA.emptyText) && ischar(genA.emptyText));

%% a struct with only skipped fields or without fields gives an empty script

% the file is created and closed, but no line is written
generateStructFunction(struct('cellField', {{1}}), 'genB');
assert(isfile(fullfile(workDir, 'genB_init.m')));
assert(isempty(fileread(fullfile(workDir, 'genB_init.m'))));
generateStructFunction(struct(), 'genC');
assert(isempty(fileread(fullfile(workDir, 'genC_init.m'))));

% no file is left open by the calls above
assert(isequal(openedFiles, filesBefore));

%% clean up: remove the temporary folder and return to the original directory
cd(fileDir);
rmdir(workDir, 's');
clear genA

% change the directory
cd(currentDir)
