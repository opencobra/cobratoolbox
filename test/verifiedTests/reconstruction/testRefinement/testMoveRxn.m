% The COBRAToolbox: testMoveRxn.m
%
% Purpose:
%     - moveRxn(model, startspot, endspot) moves reaction startspot to position endspot and
%       shifts the reactions in between, in every reaction-indexed field. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): it ignores
%       the dimension that getModelFieldsForType returns for each field and permutes the first
%       dimension of every field whose row count equals the number of reactions, so in a model
%       with as many metabolites (or constraints) as reactions the rows of S (or C) are moved
%       instead of its columns, and a reaction x reaction field is moved in one dimension only;
%       no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/refinement/moveRxn.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a small hand-built model (createModel), no solver.
%
% Coverage exemptions:
%     every line - moveRxn is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Reaction-indexed fields are permuted along the wrong dimension when another dimension has the same size
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'R1','R2','R3'}, {'R1','R2','R3'}, {'A -> B','B -> C','C -> '});
%         model2 = moveRxn(model, 1, 3) (3 metabolites, 3 reactions: S is square); likewise a model
%         with 3 constraints (C 3 x 3) or a custom 3 x 3 field rxnPair
%       OBSERVED: (R2025a, 2026-11-23) model2.rxns = {'R2','R3','R1'} but model2.S equals
%         model.S([2 3 1],:) (metabolite rows moved, columns left in place, so each column of S no
%         longer belongs to its reaction); model2.C equals model.C([2 3 1],:); a custom 3 x 3
%         rxnPair equals rxnPair([2 3 1],:) (columns not moved). Line 42 tests size(field,1)
%         first and never uses the dimensions output of getModelFieldsForType, which gives
%         dimension 2 for S and C
%       EXPECTED: model2.S equals model.S(:,[2 3 1]) and model2.C equals model.C(:,[2 3 1]), as for
%         a non-square S; a reaction x reaction field moved in both dimensions
%       LINES: 38, 42-50
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMoveRxn'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
