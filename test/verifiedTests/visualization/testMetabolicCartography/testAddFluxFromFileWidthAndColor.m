% The COBRAToolbox: testAddFluxFromFileWidthAndColor.m
%
% Purpose:
%     - addFluxFromFileWidthAndColor reads reaction IDs and fluxes from a CSV file (header
%       row first) and sets the line width of the map reactions from the flux relative to
%       the largest absolute flux (bands 0, (0, 0.2], (0.2, 0.5], (0.5, 0.8], (0.8, 1] give
%       1, 2, 5, 8, 10; reactions without flux data get 1), colours reactions with positive
%       flux in red and negative flux in indigo shades (darker for wider lines), zero-flux
%       reactions in light grey, and colours the molecules of each reaction carrying flux
%       (all other molecules white). Expected widths and colours are derived by hand from
%       the documented bands and shade lists. CSV files are written to a tempname folder.
%
% Function under test:
%     src/visualization/metabolicCartography/addFluxFromFileWidthAndColor.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built map and CSV files.
%
% Coverage exemptions:
%     Line 47: unreachable. readtable is called without 'TextType', so a text column is
%     always read as a cell array of char, never as a string array.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Numeric reaction IDs of different lengths do not match the map
%       SEVERITY: limitation
%       TRIGGER: CSV file 'rxnID,flux' / '1,5' / '10,10'; map.rxnName = {'1'; '10'} (aliases
%         a -> b, b -> c); [map2, flux2, fluxMap] = addFluxFromFileWidthAndColor(map, csvFile)
%       OBSERVED: MATLAB R2025a: flux2 = {' 1', 5, 5; '10', 10, 10} (cellstr(num2str([1; 10]))
%         keeps the leading blank of ' 1'), so map reaction '1' is not matched: fluxMap
%         = {'1', 1; '10', 10} and its colour is unchanged.
%       EXPECTED: reaction '1' gets width 5 and colour 'FFff8787', and flux2 lists it as '1'
%       LINES: 45
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddFluxFromFileWidthAndColor'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% CSV files are written to a temporary folder removed at the end
tempFolder = tempname;
mkdir(tempFolder);

% shades of the function (lightest to darkest) and the zero-flux and molecule colours
redShades = {'FFffc9c9', 'FFff8787', 'FFfa5252', 'FFc92a2a'};
indigoShades = {'FFbac8ff', 'FF748ffc', 'FF4c6ef5', 'FF364fc7'};
lightGray = 'FFD3D3D3';
white = 'FFFFFFFF';

% a map of seven reactions on molecules a..h; R2 has the secondary reactant g and the
% secondary product h; every reaction starts black
%   R1: a -> b, R2: b + g -> c + h, R3: c -> d, R4: d -> e, R5: e -> f, R6: f -> a, R7: g -> h
map.rxnName = {'R1'; 'R2'; 'R3'; 'R4'; 'R5'; 'R6'; 'R7'};
map.molAlias = {'a'; 'b'; 'c'; 'd'; 'e'; 'f'; 'g'; 'h'};
map.rxnBaseReactantAlias = {{'a'}; {'b'}; {'c'}; {'d'}; {'e'}; {'f'}; {'g'}};
map.rxnReactantAlias = {{}; {'g'}; {}; {}; {}; {}; {}};
map.rxnBaseProductAlias = {{'b'}; {'c'}; {'d'}; {'e'}; {'f'}; {'a'}; {'h'}};
map.rxnProductAlias = {{}; {'h'}; {}; {}; {}; {}; {}};
map.rxnColor = repmat({'FF000000'}, 7, 1);
map.molColor = repmat({'FF000000'}, 8, 1);

%% widths, colours and listed fluxes from a CSV file with text reaction IDs

% R6 has no flux data and RX is not in the map
csvFile = fullfile(tempFolder, 'fluxes.csv');
fileId = fopen(csvFile, 'w');
fprintf(fileId, 'rxnID,flux\nR1,10\nR2,-5\nR3,1\nR4,0\nRX,3\nR5,-9\nR7,7\n');
fclose(fileId);
[newMap, flux2, fluxMap] = addFluxFromFileWidthAndColor(map, csvFile);

% relative fluxes 1.0, 0.5, 0.1, 0.3, 0.9, 0.7 -> widths 10, 5, 2, 5, 10, 8 (zero flux omitted)
assert(isequal(flux2, {'R1', 10, 10; 'R2', -5, 5; 'R3', 1, 2; 'RX', 3, 5; 'R5', -9, 10; 'R7', 7, 8}));
% map widths: zero flux (R4) and no flux data (R6) give 1
assert(isequal(fluxMap, {'R1', 10; 'R2', 5; 'R3', 2; 'R4', 1; 'R5', 10; 'R6', 1; 'R7', 8}));
assert(isequal(newMap.rxnWidth, {10; 5; 2; 1; 10; 1; 8}));
% colours: shade index of widths 2, 5, 8, 10 is 1, 2, 3, 4; red for positive, indigo for
% negative flux; R4 (zero flux) grey; R6 keeps its colour
assert(isequal(newMap.rxnColor, {redShades{4}; indigoShades{2}; redShades{1}; lightGray; ...
    indigoShades{4}; 'FF000000'; redShades{3}}));
% molecules take the colour of their reactions in file order (R1, R2, R3, R5, R7), so a later
% reaction overrides a shared molecule; base and secondary species are both coloured
assert(isequal(newMap.molColor, {redShades{4}; indigoShades{2}; redShades{1}; redShades{1}; ...
    indigoShades{4}; indigoShades{4}; redShades{3}; redShades{3}}));

%% all fluxes zero: nothing listed, all widths 1, all listed reactions grey, molecules white

fileId = fopen(csvFile, 'w');
fprintf(fileId, 'rxnID,flux\nR1,0\nR2,0\n');
fclose(fileId);
[newMap, flux2, fluxMap] = addFluxFromFileWidthAndColor(map, csvFile);
assert(isempty(flux2));
assert(isequal(fluxMap(:, 2), num2cell(ones(7, 1))));
assert(isequal(newMap.rxnColor, [{lightGray; lightGray}; repmat({'FF000000'}, 5, 1)]));
assert(isequal(newMap.molColor, repmat({white}, 8, 1)));

%% numeric reaction IDs (all of one length) are converted to text and matched

% fluxes 4 and -2: widths 10 and 5
numericMap = map;
numericMap.rxnName = {'1'; '2'; '3'; '4'; '5'; '6'; '7'};
fileId = fopen(csvFile, 'w');
fprintf(fileId, 'rxnID,flux\n1,4\n2,-2\n');
fclose(fileId);
[newMap, flux2, fluxMap] = addFluxFromFileWidthAndColor(numericMap, csvFile);
assert(isequal(flux2, {'1', 4, 10; '2', -2, 5}));
assert(isequal(fluxMap(1:3, 2), {10; 5; 1}));
assert(isequal(newMap.rxnColor(1:2), {redShades{4}; indigoShades{2}}));

% remove the temporary folder
rmdir(tempFolder, 's');

% change the directory
cd(currentDir)
