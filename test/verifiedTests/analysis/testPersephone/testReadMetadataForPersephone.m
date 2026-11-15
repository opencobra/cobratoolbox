% The COBRAToolbox: testReadMetadataForPersephone.m
%
% Purpose:
%     - readMetadataForPersephone reads a metadata file (CSV or XLSX) into a table with the
%       variable names preserved as written and the first column (sample IDs) read as
%       string, and removes a second header line of units (first cell 'unit' or 'units', any
%       case). The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the units are not stored in VariableUnits as the header documents
%       (defect below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/persephone/readMetadataForPersephone.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-written files in a temporary
%     folder.
%
% Coverage exemptions:
%     every line - readMetadataForPersephone is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The units line is dropped instead of being stored in VariableUnits
%       SEVERITY: wrong-result
%       TRIGGER: a metadata file whose second line starts with units, e.g. the lines
%         'ID,Age' / 'units,years' / 'S1,30' / 'S2,40'
%       OBSERVED: the units line is not in the table (when a numeric column has text in
%         that line the reader already skips it; otherwise line 54 removes it), but
%         metadata.Properties.VariableUnits is an empty 0x0 cell array (MATLAB R2025a); the
%         units of numeric columns are lost
%       EXPECTED: the units kept in the VariableUnits property of the table, as the header
%         (DESCRIPTION and OUTPUTS) states
%       LINES: 52-55
%     - DEFECT: All warnings are switched on after the call
%       SEVERITY: cosmetic
%       TRIGGER: any call, e.g. readMetadataForPersephone('metadata.csv')
%       OBSERVED: warning('off') and warning('on') replace the warning state of the caller;
%         the state had 11 entries before the call and one ('all', 'on') after it, so the
%         warnings that MATLAB disables by default are enabled
%       EXPECTED: the warning state of the caller restored after reading
%       LINES: 39, 43
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadMetadataForPersephone'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
