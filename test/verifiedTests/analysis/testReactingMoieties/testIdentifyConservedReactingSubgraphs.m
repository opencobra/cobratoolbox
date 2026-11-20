% The COBRAToolbox: testIdentifyConservedReactingSubgraphs.m
%
% Purpose:
%     - identifyConservedReactingSubgraphs splits a bond transition multigraph into the bonds
%       broken and formed by the reactions of a model, the reacting bond subgraph (the weakly
%       connected components that hold a reaction node) and the conserved bond subgraph, and
%       the atom transition multigraph into reacting and conserved atom subgraphs. A test would
%       check these on hand-built digraphs whose subgraphs are known by construction.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       the reacting atom subgraph is wrong when a conserved component comes before the
%       reacting one in the node order of dBTM (defect below), so this file makes no assertion
%       about the function.
%
% Function under test:
%     src/analysis/topology/reactingMoieties/identifyConservedReactingSubgraphs.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - graph manipulation on hand-built digraphs, no solver.
%
% Coverage exemptions:
%     every line - identifyConservedReactingSubgraphs is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: reaction nodes are removed from RBG with their node indices in dBTM
%       SEVERITY: wrong-result
%       TRIGGER: dBTM with nodes 1 (A bond, atoms 5-6, conserved, no edge), 2 (A bond, atoms
%       1-2), 3 (reaction R1), 4 (B bond, atoms 3-4), edges 2->3 (HeadMet A, TailMet R1) and
%       3->4 (HeadMet R1, TailMet B); dATM with atoms 1-6; model.rxns = {'R1'}
%       OBSERVED: MATLAB R2025a: RAG holds atoms 1-2 only and CAG holds atoms 3-6; line 105
%       calls rmnode(RBG, reactionNodes) with reactionNodes = 3, an index into dBTM (line 63),
%       which in RBG (nodes 2-4 of dBTM) is the B bond, so the reaction node stays and the
%       reacting B bond is dropped
%       EXPECTED: RAG holds the atoms of every reacting bond (1-4) and CAG the others (5-6), as
%       for the same graph with the conserved node listed last
%       LINES: 63, 105-114
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIdentifyConservedReactingSubgraphs'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
