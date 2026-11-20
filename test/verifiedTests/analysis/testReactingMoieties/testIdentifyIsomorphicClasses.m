% The COBRAToolbox: testIdentifyIsomorphicClasses.m
%
% Purpose:
%     - identifyIsomorphicClasses(CBSubgraphs, sanityChecks) groups subgraphs into isomorphism
%       classes (edge variable 'mets' compared) through classifySubgraphIsomorphism and, when
%       sanityChecks is true, checks the members after the first of each class. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): the check
%       compares the atom indices of a subgraph's nodes with the subgraph's position, so it
%       raises an error for every class with two or more members; no assertion about the
%       function is made.
%
% Function under test:
%     src/analysis/topology/reactingMoieties/identifyIsomorphicClasses.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built graphs.
%
% Coverage exemptions:
%     every line - identifyIsomorphicClasses is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: sanityChecks = true raises an error for any class with two or more members
%       SEVERITY: unusable-option
%       TRIGGER: e = @(m) table([1 2], {m}, 'VariableNames', {'EndNodes', 'mets'});
%         n = @(i) table(i, 'VariableNames', {'AtomIndex'});
%         g = {graph(e('m1'), n([1; 2])); graph(e('m1'), n([3; 4])); graph(e('m2'), n([5; 6]))};
%         identifyIsomorphicClasses(g, 1)
%       OBSERVED: error 'Inconsistent mapping of atoms to connected components.' (R2025a,
%         2026-11-15); with sanityChecks = 0 the classes are {[1 2], 3}, firsts [1; 3] and
%         class indices [1; 1; 2]. Line 33 tests CBSubgraphs{j}.Nodes.AtomIndex ~= j, i.e.
%         atom ids against the subgraph index, which can only pass if every node of subgraph j
%         has AtomIndex j. The code this was ported from
%         (conservedMoieties/old/identifyConservedMoietiesLegacyInterface.m, line 453) tests
%         atoms2component(subgraphs{j}.Nodes.AtomIndex) ~= j. identifyConservedReactingMoieties
%         passes options.sanityChecks (default 1), and testConservedReactingMoieties.m records
%         sanityChecks = 1 as a known crash in this path
%       EXPECTED: the same classes as with sanityChecks = 0 and no error, since each subgraph
%         is its own connected component (INPUTS: "sanityChecks: boolean flag to enable
%         additional consistency checks")
%       LINES: 33-34
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIdentifyIsomorphicClasses'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
