% The COBRAToolbox: testMakeModelPropertiesTable.m
%
% Purpose:
%     - makeModelPropertiesTable turns the results of checkModelProperties (a structure array,
%       one element per model, the checked model in field .model) into a table with one row
%       per property and one column per model, optionally ordered and labelled by model
%       metadata, loaded from resultsDirectory/resultsFileName when modelResults is empty, and
%       written to a tab-delimited file.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns) for the first defect below (a documented input that fails when used), so
%       this file makes no assertion about the function. The full test written for the
%       independent review (T021), with hand-derived values for all 33 rows, is kept in
%       specs/20261113-142115-test-backfill-tiers/inventory/review/testMakeModelPropertiesTable.full.m.txt
%       and is to be restored once the defect is fixed.
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
%     20261113-142115-test-backfill-tiers, independent review T021). The full test exempted
%     line 187 (skipped input of the limitation) and the "if 0" blocks 167-171, 252-298,
%     309-313, 318-340, 378-382, 428-480 (dead code).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A results directory given without a trailing separator cannot be loaded
%       SEVERITY: error
%       TRIGGER: modelResults saved as FRresults.mat in a folder d; makeModelPropertiesTable([],
%         [], d, 'FRresults') with d not ending in a file separator (for example d = tempname)
%       OBSERVED: (R2025a, 2026-11-17) error "Unable to find file or directory
%         '<d>FRresults'." at line 37: the directory and the file name are joined without a
%         separator ([resultsDirectory resultsFileName])
%       EXPECTED: the results in d/FRresults.mat are loaded ("resultsDirectory: directory where
%         output of checkModelProperties has been saved"; a directory name without a trailing
%         separator is a valid reading), for example with fullfile
%       LINES: 37
%     - DEFECT: A results model without balancedRxnBool stops with an error
%       SEVERITY: limitation
%       TRIGGER: modelResults(k).model without the field balancedRxnBool, which is not an
%         output of checkModelProperties (for example a structure built by hand);
%         makeModelPropertiesTable(modelResults)
%       OBSERVED: (R2025a, 2026-11-17) error "Unrecognized field name "balancedRxnBool"." at
%         line 194, after lines 184-188 found the field absent and wrote NaN. The documented
%         input, the output of checkModelProperties, always has the field: checkModelProperties
%         (lines 202-205) calls findStoichConsistentSubset with massBalanceCheck = 1, and every
%         path of findStoichConsistentSubset lines 181-224 either sets model.balancedRxnBool or
%         stops with "No model.metFormulas"
%       EXPECTED: the row of line 194 is NaN (or skipped) when balancedRxnBool is absent, as
%         lines 184-188 do for the row before it
%       LINES: 187, 194
%     - DEFECT: The progress message of each model column prints nothing
%       SEVERITY: cosmetic
%       TRIGGER: any call with at least one model, makeModelPropertiesTable(modelResults)
%       OBSERVED: (R2025a, 2026-11-17) line 62 calls fprintf('%\n', modelID); the format "%\n"
%         is not a valid conversion, so nothing is printed (no modelID, no newline)
%       EXPECTED: the modelID of each model column, one per line ('%s\n')
%       LINES: 62
%
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Rewritten as a full test and then converted to the quarantine layout after the
%       independent review (T021), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMakeModelPropertiesTable'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
