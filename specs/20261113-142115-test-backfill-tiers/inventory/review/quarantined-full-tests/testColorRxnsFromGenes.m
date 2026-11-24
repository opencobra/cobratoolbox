% The COBRAToolbox: testColorRxnsFromGenes.m
%
% Purpose:
%     - colorRxnsFromGenes finds the reactions of the genes given as Entrez IDs (model gene
%       IDs are compared without their '.x' transcript suffix), and sets the colour
%       (createColorsMap code) and the line width of those reactions on a CellDesigner map
%       structure; when the map has reactant and product line fields, the non-empty secondary
%       lines of those reactions get the same colour and width. This test checks the default
%       colour and width, a chosen colour and width, a map with and without secondary-line
%       fields (with empty line lists), a gene ID that is a prefix of another ('10' and
%       '100'), and a reaction absent from the map. Expected values are written by hand; the
%       colour codes are those of createColorsMap ('RED' = 'FFFF0000', 'BLUE' = 'FF0000FF').
%
% Function under test:
%     src/visualization/metabolicCartography/colorRxnsFromGenes.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model and map manipulation on hand-built structures, no solver, no figure.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testColorRxnsFromGenes'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% model genes carry transcript suffixes; gene i = model.genes{i}:
%   R1: 10.1   R2: 20.2 or 100.1   R3: 30   R4: no rule   R5: 10.1 (not on the map)
model = struct();
model.rxns = {'R1'; 'R2'; 'R3'; 'R4'; 'R5'};
model.genes = {'10.1'; '20.2'; '100.1'; '30'};
model.rules = {'x(1)'; 'x(2) | x(3)'; 'x(4)'; ''; 'x(1)'};

% a map with reaction names only (no secondary-line fields); R5 is not on it, R9 is not in
% the model
mapSimple = struct();
mapSimple.rxnName = {'R1'; 'R2'; 'R3'; 'R9'};

%% default colour and width on a map without secondary lines

% Entrez ID '10' matches '10.1' (suffix removed) but not '100.1': reactions R1 and R5; only
% R1 is on the map, so only entry 1 is set ('RED', width 8). Widths are integers, so exact
% equality is used.
newMap = colorRxnsFromGenes(mapSimple, model, {'10'});
assert(isequal(newMap.rxnName, mapSimple.rxnName));
assert(isequal(newMap.rxnColor, {'FFFF0000'}));
assert(isequal(newMap.rxnWidth, {8}));
% no secondary-line fields are added
assert(~isfield(newMap, 'rxnReactantLineColor'));

%% chosen colour and width on a map with secondary lines

% IDs '100' (R2 through 100.1) and '30' (R3): entries 2 and 3 get 'BLUE' and width 3, entry
% 1 keeps its colour. Secondary lines: R2 has no reactant line and one product line, R3
% one reactant line and no product line; only the non-empty lists are recoloured.
mapFull = mapSimple;
mapFull.rxnColor = {'FF000000'; 'FF000000'; 'FF000000'; 'FF000000'};
mapFull.rxnWidth = {1; 1; 1; 1};
mapFull.rxnReactantLineColor = {{'FF000001'; 'FF000002'}; {}; {'FF000003'}; {'FF000004'}};
mapFull.rxnReactantLineWidth = {{1; 1}; {}; {1}; {1}};
mapFull.rxnProductLineColor = {{'FF000005'}; {'FF000006'}; {}; {'FF000007'}};
mapFull.rxnProductLineWidth = {{1}; {1}; {}; {1}};
newMap = colorRxnsFromGenes(mapFull, model, {'100', '30'}, 'BLUE', 3);
assert(isequal(newMap.rxnColor, {'FF000000'; 'FF0000FF'; 'FF0000FF'; 'FF000000'}));
assert(isequal(newMap.rxnWidth, {1; 3; 3; 1}));
% R2: reactant lines stay empty, its product line is recoloured
assert(isempty(newMap.rxnReactantLineColor{2}));
assert(isequal(newMap.rxnProductLineColor{2}, {'FF0000FF'}));
assert(isequal(newMap.rxnProductLineWidth{2}, {3}));
% R3: its reactant line is recoloured, product lines stay empty
assert(isequal(newMap.rxnReactantLineColor{3}, {'FF0000FF'}));
assert(isequal(newMap.rxnReactantLineWidth{3}, {3}));
assert(isempty(newMap.rxnProductLineColor{3}));
% R1 and R9 are not selected: their lines are unchanged
assert(isequal(newMap.rxnReactantLineColor([1 4]), mapFull.rxnReactantLineColor([1 4])));
assert(isequal(newMap.rxnProductLineColor([1 4]), mapFull.rxnProductLineColor([1 4])));

%% a given colour with the default width, and an existing rxnGeneMat

% the given matrix is used as is: it links gene 10.1 to R1 and R3, so both are coloured
% ('GREEN' = 'FF008000') with the default width 8; both reactant lines of R1 are changed
modelMat = model;
modelMat.rxnGeneMat = sparse([1 0 0 0; 0 1 1 0; 1 0 0 1; 0 0 0 0; 1 0 0 0]);
newMap = colorRxnsFromGenes(mapFull, modelMat, {'10'}, 'GREEN');
assert(isequal(newMap.rxnColor, {'FF008000'; 'FF000000'; 'FF008000'; 'FF000000'}));
assert(isequal(newMap.rxnWidth, {8; 1; 8; 1}));
assert(isequal(newMap.rxnReactantLineColor{1}, {'FF008000'; 'FF008000'}));
assert(isequal(newMap.rxnReactantLineWidth{1}, {8; 8}));
assert(isequal(newMap.rxnProductLineColor{1}, {'FF008000'}));

% change the directory
cd(currentDir)
