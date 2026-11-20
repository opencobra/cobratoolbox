% The COBRAToolbox: testPrintFunctionIO.m
%
% Purpose:
%     - printFunctionIO(functionName, derivedInputNames, printLevel) reads the source of a
%       function and lists the input and output variables, with the struct fields referenced in
%       the source, and prints a help-header skeleton. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): the variable names are matched as
%       substrings without a word boundary, so fields of other variables are reported as fields
%       of an input, and the second and later output names keep the leading space of the
%       signature, so their fields are missed; no assertion about the function is made.
%
% Function under test:
%     src/base/codeConsistency/printFunctionIO.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write small target functions into a tempname
%     folder on the MATLAB path.
%
% Coverage exemptions:
%     every line - printFunctionIO is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Fields of a variable whose name ends with an input name are listed as fields of the input
%       SEVERITY: wrong-result
%       TRIGGER: a function file probeIoTarget.m on the path with the lines
%         "function [a, b] = probeIoTarget(model, x)", "submodel.rxns = 1;", "b.field = 2;",
%         "a = x.y;", "end", then [inputs, outputs] = printFunctionIO('probeIoTarget', {}, 0)
%       OBSERVED: (R2025a, 2026-11-15) inputs = {'model.rxns'; 'x.y'}: the pattern
%         pattern('model') + '.' + alphanumerics matches inside "submodel.rxns"
%       EXPECTED: inputs = {'model'; 'x.y'} - the source references no field of the input model
%       LINES: 71-72
%     - DEFECT: Fields of the second and later outputs are missed when the reference starts a line
%       SEVERITY: wrong-result
%       TRIGGER: the same call as above (signature "[a, b]" with a space after the comma, the
%         layout the openCOBRA style guide requires, and "b.field = 2;" at the start of a line)
%       OBSERVED: (R2025a, 2026-11-15) outputs = {'a'; 'b'}: split at line 115 keeps ' b' with its
%         leading space and the search pattern at line 131 then needs a space before "b."
%       EXPECTED: outputs = {'a'; 'b.field'}
%       LINES: 115, 131-132
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintFunctionIO'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
