% The COBRAToolbox: testCreateMoietyGraph.m
%
% Purpose:
%     - createMoietyGraph builds, for each isomorphism class of arm.L, the inclusion rate of
%       each metabolite carrying that moiety, sorts the metabolites by it and joins, as a
%       cycle, the moiety instances on all paths of the moiety transition graph arm.MTG from
%       each instance of the least included metabolite to the most included one, labelling
%       the edges with metabolites and their inclusion rates (Weight). Quarantined: no
%       behaviour of createMoietyGraph is asserted until the defect below is fixed.
%
% Function under test:
%     src/analysis/topology/reactingMoieties/createMoietyGraph.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built bond graph and atomically resolved model, no solver.
%
% Coverage exemptions:
%     every line - createMoietyGraph is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Edge weights are shifted when a metabolite lies off the cycle
%       SEVERITY: wrong-result
%       TRIGGER: model.mets = {'A';'B';'C'}; BG = graph([], [], [], 7);
%         BG.Nodes.mets = {'A';'A';'B';'C';'C';'C';'C'}; arm.L = sparse([2 1 4]);
%         arm.I2A = sparse(ones(1,7)); arm.ATG = graph([], [], [], 7);
%         arm.ATG.Nodes.MoietyIndex = (1:7)'; arm.MTG = graph([1 3], [2 2], [], 3) with
%         Nodes.IsomorphismClass = [1;1;1], Nodes.mets = {'A';'B';'C'},
%         Nodes.MoietyIndex = [1;2;3]; G = createMoietyGraph(model, BG, arm)
%       OBSERVED: inclusion rates are C 0.25, A 0.5, B 1; A is not on the path from C to B, and
%         G.Edges lists two edges (2,3) with mets C and B and Weight 0.25 and 0.5: B carries
%         the rate of A. Line 66 filters inclusionOrder first, so line 67 builds its mask from
%         the already filtered list and keeps the first entries of A instead of the matching
%         ones; both stay filtered for the next starting node
%       EXPECTED: B with its own inclusion rate 1 (A and inclusionOrder filtered with the same
%         mask, from the unfiltered lists for every starting node)
%       LINES: 66-67
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateMoietyGraph'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
