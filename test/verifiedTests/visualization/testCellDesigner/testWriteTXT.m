% The COBRAToolbox: testWriteTXT.m
%
% Purpose:
%     - writeTXT should write a text file for the online PD map with a header row
%       'name color' and one row '<reaction name> <colour>' per row of para, using red when
%       para has no colour column, removing the CellDesigner prefix 'FF' from 8-digit colour
%       codes and adding '#' where it is missing, and return the lines written.
%       The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): no assertion about the function is made. Once the defects below are
%       fixed, the test should write, in a temporary folder, a one-column para (default
%       colour), '#RRGGBB' codes with and without 'FF' inside, 'FFRRGGBB' codes, codes without
%       '#' or 'FF' (no header row) and an empty colour, and compare the files and the returned
%       text; lines 23-27 (uiputfile, fname_out omitted) stay exempt (GUI).
%
% Function under test:
%     src/visualization/cellDesigner/writeTXT.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; files would be written in a temporary folder.
%
% Coverage exemptions:
%     every line - writeTXT is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A one-column para stops with an error at the default colour
%       SEVERITY: error
%       TRIGGER: writeTXT({'R1'; 'R2'}, '<folder>/c.txt')
%       OBSERVED: (R2025a, 2026-11-15) prints r = 2 and c = 1, then 'Colon operands must be real
%         scalars.' at line 60: the default '#FF0000FF' (line 39) contains 'FF' twice, so st
%         is [2 8]; the output file is left open
%       EXPECTED: the header row and one row per reaction with the default colour (red, as
%         the comment of line 39 says)
%       LINES: 39, 57-60
%     - DEFECT: A colour code without '#' or 'FF' in the first row stops with an error
%       SEVERITY: error
%       TRIGGER: writeTXT({'R1', '00AA00'}, '<folder>/a.txt')
%       OBSERVED: (R2025a, 2026-11-15) 'Index in position 1 is invalid. Array indices must be
%         positive integers or logical values.' at line 52: the branch without header row
%         sets s = 1, so the loop reads para{0, 1}
%       EXPECTED: one row per reaction ('R1 00AA00' or 'R1 #00AA00')
%       LINES: 43-52
%     - DEFECT: A '#RRGGBB' colour containing 'FF' is truncated
%       SEVERITY: wrong-result
%       TRIGGER: text = writeTXT({'R1', '#00FF00'}, '<folder>/b.txt')
%       OBSERVED: (R2025a, 2026-11-15) text = {'name color'; 'R1 #00'}: the 'FF' inside the
%         colour is taken for the CellDesigner prefix and everything up to it is removed
%       EXPECTED: {'name color'; 'R1 #00FF00'}
%       LINES: 57-60
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWriteTXT'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
