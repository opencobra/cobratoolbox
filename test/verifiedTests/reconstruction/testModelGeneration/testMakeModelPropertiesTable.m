% The COBRAToolbox: testMakeModelPropertiesTable.m
%
% Purpose:
%     - makeModelPropertiesTable turns the results of checkModelProperties (one structure per
%       model, results in field .model) into a table with one row per property and one column
%       per model, optionally ordered and labelled by model metadata and written to a file. The
%       function is quarantined for the defect below: the field balancedRxnBool, which the code
%       treats as optional, stops every call that does not provide it. This file only opens the
%       test; it asserts nothing about the function.
%
% Function under test:
%     src/reconstruction/modelGeneration/modelProperties/makeModelPropertiesTable.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - the input is a structure of model results (S and Boolean property vectors); no
%     solver.
%
% Coverage exemptions:
%     every line - makeModelPropertiesTable is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A results model without balancedRxnBool stops with an error
%       SEVERITY: error
%       TRIGGER: modelResults.model with fields S, rankS, modelID and the Boolean vectors that
%         checkModelProperties sets (SIntRxnBool, SConsistentRxnBool, ..., SIntMetBool) but no
%         balancedRxnBool; makeModelPropertiesTable(modelResults)
%       OBSERVED: (R2025a, 2026-11-16) error "Unrecognized field name "balancedRxnBool"." at
%         line 194, after line 184 found the field absent and wrote NaN. checkModelProperties
%         never sets balancedRxnBool, so every documented input (output of checkModelProperties)
%         stops here; with the field added by hand the table of 33 rows is returned
%       EXPECTED: the row of line 194 is NaN (or skipped) when balancedRxnBool is absent, as
%         lines 184-188 do for the row before it
%       LINES: 194
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMakeModelPropertiesTable'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
