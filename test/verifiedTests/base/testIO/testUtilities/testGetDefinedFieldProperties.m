% The COBRAToolbox: testGetDefinedFieldProperties.m
%
% Purpose:
%     - getDefinedFieldProperties reads the definition of the COBRA model fields
%       (src/base/io/definitions/COBRA_structure_fields.tab) and returns, depending on the
%       options, the programmatic properties of each field (8 columns), the human-readable
%       descriptions (4 columns) or the database relations (6 columns), each cached in a
%       persistent variable. This test checks the three tables, the cache, the selection of
%       specific fields (in the requested order) and the error for incompatible options.
%     - Expected values come from the definition file itself, read independently here with
%       fileread and a tab split (row counts, field order, evaluators, database id and
%       qualifier combinations), and from hand-picked rows of that file (S, mets, osenseStr,
%       metKEGGID, geneEntrezID) whose conversions follow from the documentation.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the severity audit T009a raised the two defects below (a documented input
%       that fails when used, a documented option without effect), so this file makes no
%       assertion about the function. The checks described above are those of the wave 02
%       version of this test (git history), to be restored once the defects are fixed.
%
% Function under test:
%     src/base/io/utilities/getDefinedFieldProperties.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; the only input is the definition file shipped with the
%     toolbox.
%
% Coverage exemptions:
%     every line - getDefinedFieldProperties is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a). Before the quarantine the
%     test exempted lines 174, 175, 177, 178 (inside the `if 0 %debug` block, dead code) and
%     line 193 (the error of the first defect).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A requested field without definition raises an error instead of being left out
%       SEVERITY: error
%       TRIGGER: getDefinedFieldProperties('SpecificFields', {'lb', 'notAField'})
%       OBSERVED: error "The following requesteds fields have no Specifications: notAField"
%       EXPECTED: the documented OUTPUTS: "if fields without definitions are requested, they
%                 will not be contained in the result" (i.e. only the row of lb); a documented
%                 input that fails when used (severity audit T009a)
%       LINES: 192-194
%     - DEFECT: SpecificFields is ignored together with Descriptions or DataBaseFields
%       SEVERITY: unusable-option
%       TRIGGER: getDefinedFieldProperties('Descriptions', true, 'SpecificFields', {'lb'})
%       OBSERVED: all 82 description rows are returned
%       EXPECTED: only the row of lb (SpecificFields: "only obtain definitions for a specific
%                 set of fields", documented with no restriction on combining it with the other
%                 options); both branches return before the selection of lines 190-196, so the
%                 documented option has no effect when used (severity audit T009a)
%       LINES: 102-103, 135-136
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.
%     - Converted to the quarantine layout after the severity audit 2026-11-15 (T009a).

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetDefinedFieldProperties'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
