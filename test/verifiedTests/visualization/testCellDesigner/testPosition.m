% The COBRAToolbox: testPosition.m
%
% Purpose:
%     - position should return the value of the attribute str_ID in an XML line (a cell with
%       one string) and the first and last index of that value in the line.
%       The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): no assertion about the function is made. Once the defect below is fixed,
%       the test should check the value and indices of the width and color attributes of a
%       '<celldesigner:line width=... color=...>' line (the use made by writeCD, writeXML and
%       repairXML), of the first and last attribute of a line, and of an attribute whose name
%       also occurs inside another attribute name (id in metaid).
%
% Function under test:
%     src/visualization/cellDesigner/position.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-written XML lines.
%
% Coverage exemptions:
%     every line - position is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An attribute name that occurs more than once in the line stops the function
%       SEVERITY: error
%       TRIGGER: position({'<reaction metaid="re1" id="re2">'}, 'id') (id also occurs inside
%         metaid)
%       OBSERVED: (R2025a, 2026-11-15) prints 'p_st = 19 28' and fails with 'Colon operands
%         must be real scalars.' at line 25: every match of strfind is kept, so p_st is a
%         vector (older MATLAB releases took the first element of a colon operand and would
%         return the value of metaid, 're1')
%       EXPECTED: the value of the attribute id, 're2'
%       LINES: 21-25, 33, 37
%     - DEFECT: Debug output of the start index, the rest of the line and the end index
%       SEVERITY: cosmetic
%       TRIGGER: any call, e.g. position({'<celldesigner:line width="1.0" color="ff000000"/>'},
%         'color')
%       OBSERVED: (R2025a, 2026-11-15) 'p_st = 39', 'ff000000"/>' and '46' are printed before
%         the value 'ff000000' is returned
%       EXPECTED: no output
%       LINES: 23, 27, 34
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPosition'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
