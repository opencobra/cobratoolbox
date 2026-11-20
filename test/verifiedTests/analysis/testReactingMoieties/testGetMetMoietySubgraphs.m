% The COBRAToolbox: testGetMetMoietySubgraphs.m
%
% Purpose:
%     - getMetMoietySubgraphs(model, BG, arm) returns the subgraphs of the bond graph BG on the
%       atoms of each isomorphism class (rows of arm.I2A equal to 1), of each moiety instance
%       (atoms with that arm.ATG.Nodes.MoietyIndex) and of each metabolite (BG.Nodes.mets),
%       and stops when a moiety or metabolite subgraph has no node. The test hand-builds a
%       five-atom bond graph with two bonds, two isomorphism classes and three moiety
%       instances, and checks every subgraph (nodes, metabolites, edges) against the atoms
%       chosen by hand, plus the two errors.
%
% Function under test:
%     src/analysis/topology/reactingMoieties/getMetMoietySubgraphs.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built model fields, bond graph and atomically resolved model; no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetMetMoietySubgraphs'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% five atoms: atoms 1 and 2 in A (bonded), 3 and 4 in B (bonded), 5 in C
model.mets = {'A'; 'B'; 'C'};
BG = graph([1 3], [2 4], [], 5);
BG.Nodes.mets = {'A'; 'A'; 'B'; 'B'; 'C'};
% isomorphism class 1 = atoms 1 and 3, class 2 = atoms 2, 4 and 5
arm.L = sparse([1 1 0; 1 1 1]);
arm.I2A = sparse([1 0 1 0 0; 0 1 0 1 1]);
% moiety instances: 1 = atoms 1, 2; 2 = atoms 3, 4; 3 = atom 5
arm.ATG = graph([1 3], [2 4], [], 5);
arm.ATG.Nodes.MoietyIndex = [1; 1; 2; 2; 3];
arm.MTG = graph([], [], [], 3);

%% the three kinds of subgraphs

[MG, moietyMG, moietyInstanceG] = getMetMoietySubgraphs(model, BG, arm);
% one subgraph per isomorphism class (rows of L), per moiety instance and per metabolite
assert(isequal(size(moietyMG), [2 1]) && isequal(size(moietyInstanceG), [3 1]) && isequal(size(MG), [3 1]));
% class subgraphs: atoms of different metabolites, no bond between them
assert(isequal(moietyMG{1}.Nodes.mets, {'A'; 'B'}) && numedges(moietyMG{1}) == 0);
assert(isequal(moietyMG{2}.Nodes.mets, {'A'; 'B'; 'C'}) && numedges(moietyMG{2}) == 0);
% moiety instance subgraphs: the two bonded pairs and the single atom
assert(isequal(moietyInstanceG{1}.Nodes.mets, {'A'; 'A'}) && numedges(moietyInstanceG{1}) == 1);
assert(isequal(moietyInstanceG{2}.Nodes.mets, {'B'; 'B'}) && numedges(moietyInstanceG{2}) == 1);
assert(isequal(moietyInstanceG{3}.Nodes.mets, {'C'}) && numedges(moietyInstanceG{3}) == 0);
% metabolite subgraphs: here they coincide with the moiety instances
assert(isequal(MG{1}.Nodes.mets, {'A'; 'A'}) && numedges(MG{1}) == 1);
assert(isequal(MG{2}.Nodes.mets, {'B'; 'B'}) && numedges(MG{2}) == 1);
assert(isequal(MG{3}.Nodes.mets, {'C'}) && numedges(MG{3}) == 0);

%% errors: an isomorphism class without atoms, a metabolite without atoms

armEmptyClass = arm;
armEmptyClass.L = sparse([1 1 0; 1 1 1; 0 0 0]);
armEmptyClass.I2A = sparse([1 0 1 0 0; 0 1 0 1 1; 0 0 0 0 0]);
assert(verifyCobraFunctionError('getMetMoietySubgraphs', 'inputs', {model, BG, armEmptyClass}, ...
    'testMessage', 'Moiety subgraph should contain nodes.'));
modelExtraMet = model;
modelExtraMet.mets = {'A'; 'B'; 'C'; 'D'};
assert(verifyCobraFunctionError('getMetMoietySubgraphs', 'inputs', {modelExtraMet, BG, arm}, ...
    'testMessage', 'Metabolite subgraph should contain nodes.'));

% change the directory
cd(currentDir)
