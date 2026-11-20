% The COBRAToolbox: testAddColour.m
%
% Purpose:
%     - addColour should set the colour of the reaction links of the listed reactions in a
%       parsed CellDesigner structure (parseCD), looking each listed ID up in r_info.ID and
%       mapping it to the reaction field (column 1), either to the html colour given in the
%       second column of listRxn_Color or, otherwise, to a colour of the chosen palette that
%       depends on the link width, and return the reactions and colours assigned.
%       The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): no assertion about the function is made. Once the defects below are
%       fixed, the test should use a hand-built parsed structure with three reactions (widths
%       0, 2 and 5, one ID per column of r_info.ID, one reaction in the last row), and check
%       the colour of each width band for every palette, the given html colours, an ID that is
%       not a reaction (lines 120-130) and both outputs.
%
% Function under test:
%     src/visualization/cellDesigner/addColour.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built parsed structure.
%
% Coverage exemptions:
%     every line - addColour is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A reaction listed by an ID in the last row of r_info.ID is not coloured
%       SEVERITY: wrong-result
%       TRIGGER: parsed.r_info.ID = {'re1', 're1', 'HEX1'; 're2', 're2', 'PGI'}, fields re1 and
%         re2 with width {'2.0'} and {5} and color cells, then [ref, list] = addColour(parsed,
%         {'PGI'})
%       OBSERVED: (R2025a, 2026-11-15) prints 'PGI' and 'error ! the listRxn{1}', re2.color is
%         unchanged, and the call fails with 'Output argument "listRxnColour" (and possibly
%         others) not assigned a value in the execution with "addColour" function.' The same
%         call with {'HEX1'} (first row) maps to re1 and colours it 'ffdef595'. The strict
%         comparisons id < m, id > rr*m and id < (rr+1)*m skip the last row of every column
%         (and every row when r_info.ID has one row)
%       EXPECTED: re2 coloured like any other row ('ff81c828' for width 5 in palette 2) and
%         listed in the second output
%       LINES: 110-118
%     - DEFECT: The html colours of the second column of listRxn_Color are ignored
%       SEVERITY: wrong-result
%       TRIGGER: the structure above, then [ref, list] = addColour(parsed, {'re1', '#123456'})
%       OBSERVED: (R2025a, 2026-11-15) re1.color becomes {'ffdef595', 'ffdef595'} (the palette
%         colour for width 2) and list = {'re1', '#ffdef595'}; length(size(listRxn_Color)) is
%         never below 2, so p is always 0 and the given colour is never read
%       EXPECTED: re1 coloured '123456' as the help text documents for the second column
%       LINES: 38-45, 179-180
%     - DEFECT: The second output is not assigned when no listed link has a non-zero width
%       SEVERITY: error
%       TRIGGER: the structure above with re1.width = {'0'}, then [ref, list] =
%         addColour(parsed, {'re1'})
%       OBSERVED: (R2025a, 2026-11-15) 'Output argument "listRxnColour" (and possibly others)
%         not assigned a value in the execution with "addColour" function.'; with one output
%         re1 is coloured 'ffaed5fc'
%       EXPECTED: an empty list of newly coloured reactions
%       LINES: 173-177
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddColour'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
