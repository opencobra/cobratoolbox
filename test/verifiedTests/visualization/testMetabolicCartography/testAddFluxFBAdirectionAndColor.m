% The COBRAToolbox: testAddFluxFBAdirectionAndColor.m
%
% Purpose:
%     - addFluxFBAdirectionAndColor draws an FBA flux vector on a CellDesigner map: each map
%       reaction gets a width from its absolute flux relative to the largest absolute flux
%       (ratio 1 -> 8, (0.8, 1) -> 6, (0.5, 0.8] -> 5, (0.2, 0.5] -> 4, (1e-3, 0.2] -> 3,
%       below 1e-3 -> 1; reactions not in the model -> 1); reactions without flux become
%       LIGHTGRAY, all molecules WHITE, reactions with negative flux and their (base and
%       secondary) reactants TOMATO, then reactions with positive flux and their (base and
%       secondary) products DARKTURQUOISE. It also returns the reactions with non-zero flux
%       (ID, flux, width) and the map reactions with their widths. Expected values are worked
%       out by hand from the flux vector; colour codes are those of createColorsMap.
%
% Function under test:
%     src/visualization/metabolicCartography/addFluxFBAdirectionAndColor.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation on a hand-built map and model (rxns only); a hand-made flux
%     vector stands for the FBA solution, so no solver is used.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A flux vector of zeros gives NaN widths
%       SEVERITY: limitation
%       TRIGGER: fbaSolution.v = zeros(n, 1) for a model whose reactions are in the map
%       OBSERVED: (R2025a, 2026-11-16, same computation in addFluxFBA) every width is NaN
%         (0 / 0 at line 53)
%       EXPECTED: width 1 for every reaction without flux
%       LINES: 53
%     - DEFECT: A flux of exactly 1e-3 of the largest flux keeps width 0.001
%       SEVERITY: cosmetic
%       TRIGGER: fbaSolution.v = [1e-3; 1] for map reactions R1 and R2
%       OBSERVED: (R2025a, 2026-11-16, same computation in addFluxFBA) R1 width 1.0000e-03:
%         the bands of lines 60-61 are > 1e-3 and < 1e-3, so the ratio 1e-3 is in neither
%       EXPECTED: width 1 or 3
%       LINES: 60-61
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddFluxFBAdirectionAndColor'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% colour codes (createColorsMap)
tomato = 'FFFF6347';
darkTurquoise = 'FF00CED1';
lightGray = 'FFD3D3D3';
white = 'FFFFFFFF';

% a map of four reactions and eight molecules a..h:
%   R1: a + b -> c        (negative flux)
%   R2: c -> d + e + b    (positive flux; b is also a secondary reactant of R1)
%   R3: f -> g            (zero flux)
%   R4: h -> a            (not in the model)
map.rxnName = {'R1'; 'R2'; 'R3'; 'R4'};
map.rxnBaseReactantAlias = {{'a'}; {'c'}; {'f'}; {'h'}};
map.rxnReactantAlias = {{'b'}; cell(0, 1); cell(0, 1); cell(0, 1)};
map.rxnBaseProductAlias = {{'c'}; {'d'}; {'g'}; {'a'}};
map.rxnProductAlias = {cell(0, 1); {'e'; 'b'}; cell(0, 1); cell(0, 1)};
map.rxnWidth = {1; 1; 1; 1};
map.rxnColor = {'X'; 'X'; 'X'; 'X'};
map.molAlias = {'a'; 'b'; 'c'; 'd'; 'e'; 'f'; 'g'; 'h'};
map.molColor = repmat({'X'}, 8, 1);

% model reactions and fluxes; R5, R6 and R7 are not in the map. |v| / 10 gives the ratios
% 1, 0.4, 0, 0.1, 0.9 and 0.6
model.rxns = {'R1'; 'R2'; 'R3'; 'R5'; 'R6'; 'R7'};
fbaSolution.v = [-10; 4; 0; 1; 9; 6];

[newMap, flux2, fluxMap] = addFluxFBAdirectionAndColor(map, model, fbaSolution);

%% widths of the reactions with non-zero flux, in model order

% ratio 1 -> 8, 0.4 -> 4, 0.1 -> 3, 0.9 -> 6, 0.6 -> 5 (exact: the widths are constants)
assert(isequal(flux2, {'R1', -10, 8; 'R2', 4, 4; 'R5', 1, 3; 'R6', 9, 6; 'R7', 6, 5}));

%% widths of the map reactions

% R3 has zero flux (ratio 0 -> 1); R4 is not in the model -> 1
assert(isequal(newMap.rxnWidth, {8; 4; 1; 1}));
assert(isequal(fluxMap, {'R1', 8; 'R2', 4; 'R3', 1; 'R4', 1}));

%% reaction colours: negative TOMATO, positive DARKTURQUOISE, zero LIGHTGRAY, others unchanged

assert(isequal(newMap.rxnColor, {tomato; darkTurquoise; lightGray; 'X'}));

%% molecule colours

% a (base reactant of R1) and b (secondary reactant of R1) TOMATO, but b is also a secondary
% product of R2 and the positive pass comes last -> DARKTURQUOISE; c is a product of the
% negative R1 and a reactant of the positive R2 -> stays WHITE; d (base product) and e
% (secondary product) of R2 -> DARKTURQUOISE; f, g (zero flux) and h (R4) -> WHITE
assert(isequal(newMap.molColor, {tomato; darkTurquoise; white; darkTurquoise; darkTurquoise; white; white; white}));

%% unchanged fields

assert(isequal(newMap.rxnName, map.rxnName));
assert(isequal(newMap.molAlias, map.molAlias));

% change the directory
cd(currentDir)
