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
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the severity audit T009a raised the four defects below (documented inputs
%       whose values are not recreated, or that fail when used), so this file makes no
%       assertion about the function. The checks described above are those of the wave 08
%       version of this test (git history), to be restored once the defects are fixed.
%
% Function under test:
%     src/base/utilities/generateStructFunction.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built structs.
%
% Coverage exemptions:
%     every line - generateStructFunction is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a). Before the quarantine the
%     test reached every executable line.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A char value with a quote gives a script that cannot run
%       SEVERITY: wrong-result
%       TRIGGER: generateStructFunction(struct('f', 'it''s'), 'myStruct')
%       OBSERVED: the line myStruct.f = 'it's'; is written without doubling the quote, and
%         running the script stops with "Invalid expression. Check for missing multiplication
%         operator, missing or unbalanced delimiters, or other syntax error." (R2025a,
%         2026-11-15)
%       EXPECTED: the quote doubled (myStruct.f = 'it''s';), so that the value is recreated;
%         the header promises that "running the generated file recreates those field values"
%         (severity audit T009a)
%       LINES: 33
%     - DEFECT: A char matrix with more than one row is written column by column
%       SEVERITY: wrong-result
%       TRIGGER: generateStructFunction(struct('h', ['ab'; 'cd']), 'myStruct')
%       OBSERVED: the line myStruct.h = 'acbd'; is written (fprintf reads the matrix in column
%         order), so the script recreates a different 1 x 4 value (R2025a, 2026-11-15)
%       EXPECTED: the 2 x 2 char matrix recreated, for example through mat2str; the header
%         promises that "running the generated file recreates those field values" (severity
%         audit T009a)
%       LINES: 33
%     - DEFECT: Numeric values lose their class and digits beyond the 15th
%       SEVERITY: wrong-result
%       TRIGGER: generateStructFunction(struct('d', pi, 'e', int8(5)), 'myStruct')
%       OBSERVED: the lines myStruct.d = 3.14159265358979; and myStruct.e = 5; are written
%         (mat2str with its default precision of 15 digits and without the 'class' option), so
%         the script recreates pi - 3.2e-15 and a double 5 (R2025a, 2026-11-15)
%       EXPECTED: the values recreated as they were (mat2str(val, 17, 'class')); the header
%         promises that "running the generated file recreates those field values" (severity
%         audit T009a, borderline: precision)
%       LINES: 30
%     - DEFECT: A numeric array with more than two dimensions stops with an error and leaves the file open
%       SEVERITY: error
%       TRIGGER: generateStructFunction(struct('z', ones(2, 2, 2)), 'nd')
%       OBSERVED: "Input matrix must be 2-D." (MATLAB:mat2str:TwoDInput, line 30; R2025a,
%         2026-11-15); the file nd_init.m opened at line 24 stays open (openedFiles lists it)
%       EXPECTED: the field written (for example through reshape) or skipped, and the file closed;
%         S is documented as a "struct whose numeric and char fields are written out", so a
%         numeric field with three dimensions is a documented input that fails when used
%         (severity audit T009a)
%       LINES: 24, 30, 36
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Converted to the quarantine layout after the severity audit 2026-11-15 (T009a).

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateStructFunction'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
