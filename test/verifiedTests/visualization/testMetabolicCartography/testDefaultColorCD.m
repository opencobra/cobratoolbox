% The COBRAToolbox: testDefaultColorCD.m
%
% Purpose:
%     - defaultColorCD(map) sets the colour of every reaction line of a CellDesigner map
%       structure to black ('ff000000') and its width to 1, and, for a map with the complete
%       structure (fields rxnReactantLineColor, rxnProductLineColor and their widths, as
%       written by transformFullXML2Map), also the secondary reactant and product lines. The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       the secondary lines are coloured with Colors(color), a function that does not exist,
%       so every map with the complete structure and at least one secondary line raises an
%       error; no assertion about the function is made.
%
% Function under test:
%     src/visualization/metabolicCartography/defaultColorCD.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-built map structure.
%
% Coverage exemptions:
%     every line - defaultColorCD is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Secondary reaction lines are coloured with the undefined function Colors
%       SEVERITY: error
%       TRIGGER: map.rxnName = {'R1'}; map.rxnColor = {'ffff0000'}; map.rxnWidth = {'3.0'};
%         map.rxnReactantLineColor = {{'ffff0000'}}; map.rxnReactantLineWidth = {{'3.0'}};
%         map.rxnProductLineColor = {''}; map.rxnProductLineWidth = {''}; defaultColorCD(map)
%       OBSERVED: (R2025a, 2026-11-15) error "Undefined function 'Colors' for input arguments
%         of type 'char'." raised by defaultColorCD line 36 (line 42 for product lines); a map
%         without the four line fields is returned with rxnColor {'ff000000'} and rxnWidth {1}
%       EXPECTED: the secondary reactant and product lines set to 'ff000000' with width 1, as
%         the header and the comment of the function say
%       LINES: 36, 42
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDefaultColorCD'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
