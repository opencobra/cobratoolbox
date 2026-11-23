% The COBRAToolbox: testFindNeighborRxns.m
%
% Purpose:
%     - findNeighborRxns returns the reactions that share a metabolite (other than the common
%       metabolites such as atp, adp, h, h2o, pi, ppi) with the given reactions, the genes of
%       those reactions and the shared metabolites, per metabolite or as one list, and for
%       neighbourhoods of higher order. Quarantined: no behaviour of findNeighborRxns is
%       asserted until the defect below is fixed.
%
% Function under test:
%     src/analysis/exploration/findNeighborRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation on a hand-built model, no solver.
%
% Coverage exemptions:
%     every line - findNeighborRxns is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: withComp is not passed to the recursive call, so common metabolites count as
%         edges from the second order on
%       SEVERITY: wrong-result
%       TRIGGER: model = struct('rxns', {{'R1'; 'R2'; 'R3'}}, 'mets', {{'a[c]'; 'b[c]';
%         'atp[c]'; 'adp[c]'}}, 'S', sparse([-1 0 0; 1 -1 0; -1 0 -1; 1 0 1]), 'genes',
%         {{'g1'}}, 'rules', {{'x(1)'; ''; ''}}); findNeighborRxns(model, 'R2', true, 2,
%         {'atp[c]', 'adp[c]'}, true)
%       OBSERVED: (R2025a, 2026-11-23) {'R1'; 'R2'; 'R3'}: line 150 calls findNeighborRxns
%         without withComp, so the recursion appends the compartment again ('atp[c][c]'),
%         finds no common metabolite and links R1 to R3 through atp[c] and adp[c]; the same
%         call with order 1 returns {'R1'}, and with commonMets {'atp', 'adp'} and withComp
%         false (default) order 2 returns {'R1'; 'R2'}
%       EXPECTED: {'R1'; 'R2'}, as for the equivalent call with withComp false: atp[c] and
%         adp[c] "should not count as edges between reactions" at any order
%       LINES: 149-150
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindNeighborRxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
