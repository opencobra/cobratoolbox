% The COBRAToolbox: testVisualizeNormalizedRxnPresence.m
%
% Purpose:
%     - visualizeNormalizedRxnPresence reads every .xml file of a folder as a CellDesigner map
%       (transformXML2Map), marks a reaction as present in a map when its line colour is
%       'FFFF4500' (ORANGERED, as visualizeReconstructionsOnMap writes it), returns a table
%       with one logical column per map file, and writes 'normalisedReactionHeatmap.xml' into
%       the folder: the first map with all colours reset (unifyMetabolicMapCD) and each
%       reaction coloured and widened by its presence fraction with a colour scheme of rows
%       {fraction, colour, width}. Where the Parallel Computing Toolbox is licensed the maps
%       are read in a parallel pool that the function opens and closes.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T027/T028) showed that a custom colour scheme in
%       the documented format stops with an index error, that a second call on the same folder
%       counts the previous heatmap as a map, and that colour codes written in lower case are
%       not counted, so this file makes no assertion about the function. The wave 13 version
%       of this test (git history) checked the presence table and the heatmap of four
%       hand-written maps with the default and a custom scheme and is the starting point once
%       the defects are fixed; it deleted the heatmap before its second call, which hid the
%       second defect.
%
% Function under test:
%     src/visualization/metabolicCartography/visualizeNormalizedRxnPresence.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written CellDesigner files in a tempname folder.
%
% Coverage exemptions:
%     every line - visualizeNormalizedRxnPresence is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, independent review T027/T028). Before the
%     quarantine the test exempted lines 111, 113, 117, 120 (the sequential loop, reached only
%     without the Parallel Computing Toolbox).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A custom colour scheme in the documented format stops with an index error
%       SEVERITY: error
%       TRIGGER: visualizeNormalizedRxnPresence(mapDir, {1, 'aaaaaa', 10; 0.5, 'bbbbbb', 5}, 1)
%         on a folder of four maps with a reaction present in none of them (fraction 0), or any
%         scheme whose last row's fraction is above a reaction's fraction
%       OBSERVED: (R2025a, 2026-11-17) error 'Index in position 1 exceeds array bounds. Index
%         must not exceed 2.' at line 150, where the range test of the last row reads the
%         fraction of the next row; the heatmap is not written
%       EXPECTED: a colour for every reaction: setColours is documented (lines 28-32) as rows
%         {fraction, colour, line width} with an example list, without the requirement of a
%         final row of fraction 0
%       LINES: 150
%     - DEFECT: A second call on the same folder counts the previous heatmap as a map
%       SEVERITY: wrong-result
%       TRIGGER: rxnPrsTable = visualizeNormalizedRxnPresence(mapDir, [], 1) called twice on a
%         folder of four maps (R1 present in all four, R2 in three, R3 in one, R4 in none)
%       OBSERVED: (R2025a, 2026-11-17) the first call gives the columns m1.xml-m4.xml and the
%         heatmap colours FFfbcaf3, FFf6a077, FF103f60, FFD3D3D3 (widths 10, 8, 3, 1); the
%         second call adds the column normalisedReactionHeatmap.xml (written by the first call
%         into mapDir, lines 169-170, and read as a map, line 67), divides by 5 (line 134) and
%         gives FFf6a077, FF99882c, FF103f60, FFD3D3D3 (widths 8, 7, 3, 1): R1, present in
%         every map, gets 0.8 instead of 1
%       EXPECTED: the presence "normalized over the total amount of maps used" (lines 7-8),
%         the same heatmap on every call; the documented output location is the input folder
%       LINES: 67, 134, 169-170
%     - DEFECT: Reaction colours written in lower case are not counted as present
%       SEVERITY: wrong-result
%       TRIGGER: a map in the folder whose present reactions have the line colour 'ffff4500'
%         (lower case, as CellDesigner writes colours when it saves a map: the CellDesigner
%         files of tutorials/visualization/metabolicCartography/data use 'ff000000') instead
%         of 'FFFF4500'
%       OBSERVED: (R2025a, 2026-11-17) a folder with one such map (R1 and R2 'ffff4500') gives
%         the presence [false false false false]: strcmp with 'FFFF4500' is case-sensitive
%       EXPECTED: the reactions of that colour counted as present, as hexadecimal colour codes
%         are case-insensitive and the function "extracts reactions with a specific colour"
%         (lines 2-3)
%       LINES: 101, 117
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Converted to the quarantine layout after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testVisualizeNormalizedRxnPresence'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
