% The COBRAToolbox: testConvertVMHIDName.m
%
% Purpose:
%     - convertVMHIDName converts VMH metabolite IDs (also exchange, demand and organ
%       reaction IDs such as DM_glc_D[bc]) to metabolite names, metabolite names to VMH
%       IDs, and suggests database names for names that are not found; either conversion
%       is skipped with the flag 0. The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): the documented skip flag for the IDs raises an
%       error (defects below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/persephone/additionalFunctions/convertVMHIDName.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-written metabolite database in
%     a temporary folder (as testLoadVMHDatabase does).
%
% Coverage exemptions:
%     every line - convertVMHIDName is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The skip flag 0 for VMHIDs raises an error
%       SEVERITY: error
%       TRIGGER: convertVMHIDName(false, 0, 0) or convertVMHIDName({'ATP'}, 0, 0)
%       OBSERVED: prints 'VMH IDs provided, finding corresponding names from VMH', then
%         MATLAB:cellRefFromNonCell, Brace indexing is not supported for variables of this
%         type. (line 52; MATLAB R2025a): exist('VMHIDs', 'var') is true for any passed
%         value, and the skip branch tests the undefined name VMHIDS
%       EXPECTED: the conversion of IDs to names skipped, as the header documents for the
%         flag 0
%       LINES: 38, 50-53, 97
%     - DEFECT: similarMets is never assigned from the suggestions
%       SEVERITY: error
%       TRIGGER: [ids, names, similar] = convertVMHIDName({'ATP', 'lactate'}, {'atp'}, 1)
%       OBSERVED: MATLAB:unassignedOutputs, Output argument "similarMets" (and possibly
%         others) not assigned a value: line 179 tests ischar('similarMets'), the literal
%         text, which is always true
%       EXPECTED: similarMets holds the suggestions for the names not found
%       LINES: 179-181
%     - DEFECT: Names of unknown IDs are dropped, so names and IDs do not line up
%       SEVERITY: wrong-result
%       TRIGGER: [ids, names] = convertVMHIDName(false, {'atp', 'notAnId', 'h2o'}, 0)
%       OBSERVED: names = {'ATP'; 'Water'}, two names for three IDs (intersect with
%         'stable' on line 72 drops the unknown ID and duplicates)
%       EXPECTED: one entry per ID, in the order of the IDs (empty for an unknown ID)
%       LINES: 72-73
%     - DEFECT: The numeric skip flag 0 for metNames raises an error
%       SEVERITY: error
%       TRIGGER: convertVMHIDName(0, {'atp'}, 0)
%       OBSERVED: the numeric 0 is not logical, so it is treated as a list of names
%         (line 107) and brace indexing fails on line 129: MATLAB:cellRefFromNonCell,
%         Brace indexing is not supported for variables of this type.
%       EXPECTED: 0 skips the conversion, as the header says (false works)
%       LINES: 107, 183
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertVMHIDName'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
