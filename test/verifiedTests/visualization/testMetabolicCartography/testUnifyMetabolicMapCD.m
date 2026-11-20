% The COBRAToolbox: testUnifyMetabolicMapCD.m
%
% Purpose:
%     - unifyMetabolicMapCD sets, for every reaction of a CellDesigner map (one per
%       .rxnName entry), .rxnColor to 'FFDCDCDC' (grey) and .rxnWidth to 1, and every
%       .molColor entry to 'FFFFFFFF' (white); all other fields are kept. Expected values
%       follow from the documentation.
%
% Function under test:
%     src/visualization/metabolicCartography/unifyMetabolicMapCD.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built map structure.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testUnifyMetabolicMapCD'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a coloured map of three reactions and two molecules
map.rxnName = {'HEX1'; 'PGI'; 'PFK'};
map.rxnColor = {'FFFF0000'; 'FF00FF00'; 'FF0000FF'};
map.rxnWidth = {5; 8; 2.5};
map.molName = {'glc_D'; 'g6p'};
map.molColor = {'FFFF0000'; 'FF00FF00'};

%% every reaction becomes grey of width 1 and every molecule white

map2 = unifyMetabolicMapCD(map);
assert(isequal(map2.rxnColor, repmat({'FFDCDCDC'}, 3, 1)));
% widths are integers stored in a cell, so exact comparison
assert(isequal(map2.rxnWidth, {1; 1; 1}));
assert(isequal(map2.molColor, repmat({'FFFFFFFF'}, 2, 1)));
% the other fields are copied unchanged
assert(isequal(map2.rxnName, map.rxnName));
assert(isequal(map2.molName, map.molName));

%% the reaction loop is bounded by .rxnName: missing colour/width entries are created

% a map whose colour and width lists are shorter than the reaction list gets one entry
% per reaction, as a column
mapShort.rxnName = {'HEX1'; 'PGI'};
mapShort.rxnColor = {'FFFF0000'};
mapShort.rxnWidth = {5};
mapShort.molColor = {};
map3 = unifyMetabolicMapCD(mapShort);
assert(isequal(map3.rxnColor, {'FFDCDCDC'; 'FFDCDCDC'}));
assert(isequal(map3.rxnWidth, {1; 1}));
% no molecule: the molecule list stays empty
assert(isempty(map3.molColor));

% change the directory
cd(currentDir)
