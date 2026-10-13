% The COBRAToolbox: testAddFluxWidthAndColor.m
%
% Purpose:
%     - addFluxWidthAndColor sets line widths and colours of the reactions of a metabolic map from
%     flux values: width by the flux relative to the largest flux (1, 2, 5, 8, 10), red for positive
%     and blue for negative flux, grey for zero flux, and the molecules on a reaction take its
%     colour.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/visualization/metabolicCartography/addFluxWidthAndColor.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Map reactions without flux data get no colour entry
%       SEVERITY: limitation
%       TRIGGER: a map with reactions that are not in the list of reaction IDs given with the fluxes
%       OBSERVED: rxnColor is filled only for reactions with flux data (zero or non-zero), so it can
%         be shorter than rxnName and the other map reactions have no colour entry
%       EXPECTED: a default colour for every map reaction
%       LINES: 102-105, 133
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddFluxWidthAndColor'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a small map: 5 reactions in a chain a -> b -> c -> d -> e -> f, 6 molecules
map.rxnName = {'R1'; 'R2'; 'R3'; 'R4'; 'R5'};
map.molAlias = {'a'; 'b'; 'c'; 'd'; 'e'; 'f'};
map.rxnBaseReactantAlias = {{'a'}; {'b'}; {'c'}; {'d'}; {'e'}};
map.rxnReactantAlias = repmat({cell(0, 1)}, 5, 1);
map.rxnBaseProductAlias = {{'b'}; {'c'}; {'d'}; {'e'}; {'f'}};
map.rxnProductAlias = repmat({cell(0, 1)}, 5, 1);

% fluxes of R1..R4 (R5 has no flux data) and of RX, which is not in the map
reactionIDs = {'R1'; 'R2'; 'R3'; 'R4'; 'RX'};
fluxValues = [10; -5; 1; 0; 3];

[newMap, nonZeroFlux, fluxMap] = addFluxWidthAndColor(map, reactionIDs, fluxValues);

%% widths: flux relative to the largest absolute flux, in the bands 0.2, 0.5, 0.8 and 1

% 10/10 = 1.0 -> width 10; 5/10 = 0.5 -> width 5; 1/10 = 0.1 -> width 2; 3/10 = 0.3 -> width 5 (RX)
assert(isequal(nonZeroFlux, {'R1', 10, 10; 'R2', -5, 5; 'R3', 1, 2; 'RX', 3, 5}));
% the map widths: zero flux and reactions without flux data get width 1
assert(isequal(fluxMap, {'R1', 10; 'R2', 5; 'R3', 2; 'R4', 1; 'R5', 1}));

%% colours: red for positive and blue for negative flux (darker for wider lines), grey for zero flux

% R1: width 10 -> darkest red; R2: width 5 -> second blue; R3: width 2 -> lightest red; R4: zero flux -> grey
assert(isequal(newMap.rxnColor(1:4)', {'FFc92a2a', 'FF748ffc', 'FFffc9c9', 'FFD3D3D3'}));

%% molecules take the colour of their reactions (a later reaction overrides a shared molecule)

% a: R1 red; b: R1 red then R2 blue; c: R2 blue then R3 light red; d: R3 light red;
% e, f: only reactions with zero or no flux -> white
assert(isequal(newMap.molColor', {'FFc92a2a', 'FF748ffc', 'FFffc9c9', 'FFffc9c9', 'FFFFFFFF', 'FFFFFFFF'}));

%% all fluxes zero: nothing is listed, all widths are 1

[newMap, nonZeroFlux] = addFluxWidthAndColor(map, {'R1'; 'R2'; 'R3'}, [0; 0; 0]);
assert(isempty(nonZeroFlux));
assert(isequal(cell2mat(newMap.rxnWidth), ones(5, 1)));

%% reaction IDs as strings

[stringMap, stringFlux] = addFluxWidthAndColor(map, string({'R1'; 'R2'}), [2; -2]);
assert(isequal(stringFlux, {'R1', 2, 10; 'R2', -2, 10}));
assert(isequal(stringMap.rxnColor', {'FFc92a2a', 'FF364fc7'}));       % darkest red and darkest blue

%% reaction IDs as numbers (converted to text)

numberMap = map;
numberMap.rxnName = {'1'; '2'; '3'; '4'; '5'};
[~, numberFlux] = addFluxWidthAndColor(numberMap, [1; 2], [4; -1]);
% 4/4 = 1 -> width 10; 1/4 = 0.25 -> width 5
assert(isequal(numberFlux, {'1', 4, 10; '2', -1, 5}));

% change the directory
cd(currentDir)
