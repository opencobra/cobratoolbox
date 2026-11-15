% The COBRAToolbox: testEstimateMoietyFormulas.m
%
% Purpose:
%     - estimateMoietyFormulas(L, E, elements) estimates the elemental composition of each
%       moiety as round(L \ E), drops the electron column 'e', sorts the elements
%       alphabetically and writes one formula per moiety (element symbol followed by its count,
%       count 1 omitted). The test builds E = L*M0 from hand-chosen moiety compositions M0 and
%       a full-column-rank L, so L \ E = M0 exactly and the formulas follow by hand; it checks
%       the electron column and unsorted elements, rounding of a perturbed E, multi-digit counts
%       and a moiety made only of electrons.
%
% Function under test:
%     src/analysis/topology/conservedMoieties/estimateMoietyFormulas.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built matrices.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: M is not the r x p matrix the documentation describes
%       SEVERITY: cosmetic
%       TRIGGER: [f, M] = estimateMoietyFormulas([1 0; 1 1; 0 1], [2 4 1 0; 4 6 1 1; 2 2 0 1],
%         {'e', 'H', 'C', 'O'})
%       OBSERVED: M = [1 4 0; 0 2 1] (R2025a, 2026-11-15): the electron column is removed and
%         the columns are sorted to C, H, O (lines 26 and 29), so M is r x 3 and its columns no
%         longer follow the input elements
%       EXPECTED: OUTPUT: "M: An r x p estimated elemental matrix for moieties" (here 2 x 4 in
%         the order e, H, C, O), or a documentation that says M follows the sorted elements
%         without 'e'
%       LINES: 26, 29
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testEstimateMoietyFormulas'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% three metabolites built from two moieties: met1 = CH4, met2 = CH4 + H2O, met3 = H2O
moietyMatrix = [1 0; 1 1; 0 1];
moietyComposition = [1 4 0; 0 2 1];   % columns C, H, O
elementalMatrix = moietyMatrix * moietyComposition;

%% sorted elements without electrons: M is the moiety composition, formulas by hand

[moietyFormulas, M] = estimateMoietyFormulas(moietyMatrix, elementalMatrix, {'C', 'H', 'O'});
% L has full column rank and E = L*M0, so L \ E = M0 and the rounded M is exact; here the
% elements are already sorted and contain no electron, so M has the documented r x p layout
assert(isequal(M, moietyComposition));
% a count of 1 is omitted (C in CH4, O in H2O)
assert(isequal(moietyFormulas, {'CH4'; 'H2O'}));

%% electron column and unsorted elements: the electron is dropped, symbols sorted

% the electron counts (first column) are arbitrary and must not appear in the formulas;
% elements are given as a column cell array to check that their orientation is irrelevant
elementalMatrixWithElectrons = [[2; 4; 2], elementalMatrix(:, [2 1 3])];
moietyFormulas = estimateMoietyFormulas(moietyMatrix, elementalMatrixWithElectrons, ...
    {'e'; 'H'; 'C'; 'O'});
% only the formulas are checked: the layout of M is the cosmetic defect in the header
assert(isequal(moietyFormulas, {'CH4'; 'H2O'}));

%% rounding of a perturbed elemental matrix and multi-digit counts

% glucose (C6H12O6) and phosphate (O4P) moieties; each entry of E is perturbed by at most
% 0.1. L \ E = pinv(L)*E here, and the rows of pinv(L) = [2 1 -1; -1 1 2]/3 have 1-norm 4/3,
% so the estimate is off by at most 0.14 < 0.5 and rounding recovers the integer composition
largeComposition = [6 12 6 0; 0 0 4 1];   % columns C, H, O, P
rng(20261115);
perturbation = 0.2 * (rand(3, 4) - 0.5);
[moietyFormulas, M] = estimateMoietyFormulas(moietyMatrix, ...
    moietyMatrix * largeComposition + perturbation, {'C', 'H', 'O', 'P'});
assert(isequal(M, largeComposition));
assert(isequal(moietyFormulas, {'C6H12O6'; 'O4P'}));

%% a moiety made only of electrons has an empty formula

% one moiety in two metabolites, carrying only an electron: after removing the electron
% column no element is left, so the formula is the empty string
moietyFormulas = estimateMoietyFormulas([1; 1], [0 0 1; 0 0 1], {'C', 'H', 'e'});
assert(numel(moietyFormulas) == 1 && isempty(moietyFormulas{1}) && ischar(moietyFormulas{1}));

% change the directory
cd(currentDir)
