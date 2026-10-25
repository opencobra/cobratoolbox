% The COBRAToolbox: testFindRxnMatch.m
%
% Purpose:
%     - findRxnMatch collects, for one reaction of the compared model, its description and the
%     descriptions of the best matching reactions of the template model, in tables used by the
%     reaction comparison window; both models are passed through global variables.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/findRxnMatch.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The separators between joined metabolites lose their blank
%       SEVERITY: cosmetic
%       TRIGGER: a reaction with several reactants or products, or the score and index of a match
%       OBSERVED: the pieces are joined with strcat and the separator ; followed by a blank, but
%         strcat removes the trailing blank of character arguments, so the lists read a;b and the
%         score reads 0.9;2
%       EXPECTED: the separators written in the code: a; b and 0.9; 2
%       LINES: 37, 41-47, 91
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindRxnMatch'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the function reads the models from the global variables CMODEL and TMODEL; clear them at the end
global CMODEL TMODEL
cleanup = onCleanup(@() clear('global', 'CMODEL', 'TMODEL'));

% compared model: one reaction a + b -> c
cmodel.rxns = {'cr1'};
cmodel.rxnNames = {'compared reaction'};
cmodel.rxnEquations = {'a + b -> c'};
cmodel.rxnECNumbers = {'1.1.1.1'};
cmodel.rxnKEGGID = {'R00001'};
cmodel.rxnSEEDID = {'rxn00001'};
cmodel.subSystems = {'sub1'};
cmodel.mets = {'a'; 'b'; 'c'};
cmodel.metNames = {'A'; 'B'; 'C'};
cmodel.metFormulas = {'CH4'; 'H2O'; 'CH4O'};
cmodel.metCharge = [0; 0; 1];
cmodel.metKEGGID = {'C1'; 'C2'; 'C3'};
cmodel.S = [-1; -2; 1];
cmodel.metNums = [0 0 2 0 1];

% template model: two reactions; the first is a + b -> c, the second is b -> a + c
tmodel.rxns = {'tr1'; 'tr2'};
tmodel.rxnNames = {'template one'; 'template two'};
tmodel.rxnEquations = {'a + b -> c'; 'b -> a + c'};
tmodel.rxnECNumbers = {'2.2.2.2'; '3.3.3.3'};
tmodel.rxnKEGGID = {'R10'; 'R20'};
tmodel.rxnSEEDID = {'rxn10'; 'rxn20'};
tmodel.subSystems = {'subA'; 'subB'};
tmodel.mets = {'a'; 'b'; 'c'};
tmodel.metNames = {'A'; 'B'; 'C'};
tmodel.metFormulas = {'CH4'; 'H2O'; 'CH4O'};
tmodel.metCharge = [0; 0; 1];
tmodel.metKEGGID = {'C1'; 'C2'; 'C3'};
tmodel.S = [-1 1; -1 -1; 1 1];
tmodel.metNums = [0 0 2 0 1; 0 0 1 0 2];
scoreTotal = [0.5 0.9];

%% description of the compared reaction

global CMODEL TMODEL
CMODEL = cmodel;
TMODEL = tmodel;
data = findRxnMatch(1, 2, scoreTotal);
assert(isequal(data.cRxnTable, {'1'; 'cr1'; 'compared reaction'; 'a + b -> c'; '1.1.1.1'; 'R00001'; 'rxn00001'; 'sub1'}));
% reactants (number, ids, names, stoichiometries, formulas, charges, KEGG ids), then products
assert(isequal(data.cMetTable(1:7), {'2'; 'a;b'; 'A;B'; '1;2'; 'CH4;H2O'; '0;0'; 'C1;C2'}));
assert(isequal(data.cMetTable(8:14), {'1'; 'c'; 'C'; '1'; 'CH4O'; '1'; 'C3'}));

%% best matches of the template model, best score first

global CMODEL TMODEL
CMODEL = cmodel;
TMODEL = tmodel;
data = findRxnMatch(1, 2, scoreTotal);
assert(isequal(size(data.tRxnTable), [8 2]) && isequal(size(data.tMetTable), [14 2]));
% the second template reaction scores 0.9 and comes first
assert(strcmp(data.tRxnTable{1, 1}, '0.9;2') && strcmp(data.tRxnTable{1, 2}, '0.5;1'));
assert(strcmp(data.tRxnTable{2, 1}, 'tr2') && strcmp(data.tRxnTable{2, 2}, 'tr1'));
assert(strcmp(data.tRxnTable{8, 1}, 'subB'));
% reactants and products of the first match (tr2: b -> a + c)
assert(strcmp(data.tMetTable{2, 1}, 'b') && strcmp(data.tMetTable{9, 1}, 'a;c'));
assert(strcmp(data.tMetTable{8, 1}, '2'));

%% a template match with two reactants and a compared reaction with two products

global CMODEL TMODEL
CMODEL = cmodel;
TMODEL = tmodel;
CMODEL.S = [-1; 1; 1];
CMODEL.metNums = [0 0 1 0 2];
% the template reaction scoring second is a + b -> c
data = findRxnMatch(1, 2, scoreTotal);
assert(strcmp(data.tMetTable{2, 2}, 'a;b') && strcmp(data.tMetTable{4, 2}, '1;1'));
assert(strcmp(data.cMetTable{9}, 'b;c') && strcmp(data.cMetTable{11}, '1;1'));
assert(strcmp(data.cMetTable{2}, 'a'));

%% only the best match

global CMODEL TMODEL
CMODEL = cmodel;
TMODEL = tmodel;
data = findRxnMatch(1, 1, scoreTotal);
assert(isequal(size(data.tRxnTable), [8 1]));

%% a compared reaction without reactants and a template reaction without products

global CMODEL TMODEL
CMODEL = cmodel;
TMODEL = tmodel;
CMODEL.S = [0; 0; 1];
TMODEL.metNums(2, 5) = 0;
TMODEL.S(:, 2) = [0; -1; 0];
data = findRxnMatch(1, 2, scoreTotal);
assert(all(cellfun(@isempty, data.cMetTable(2:7))));
% the first match has no product block
assert(all(cellfun(@isempty, data.tMetTable(8:14, 1))));

% change the directory
cd(currentDir)
