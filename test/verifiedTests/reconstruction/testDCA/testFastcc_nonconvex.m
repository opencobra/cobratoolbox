% The COBRAToolbox: testFastcc_nonconvex.m
%
% Purpose:
%     - fastcc_nonconvex(model, epsilon, printLevel, modeFlag) is a FASTCC variant that tests the
%       flux consistency of a model: LP7 finds the consistent irreversible reactions, then a
%       DC programming loop (DCA) maximises the number of remaining reactions with a flux of at
%       least epsilon, falling back to one LP per reaction; it returns the consistent reactions
%       A and, with modeFlag 1, the flux modes V. Quarantined: no behaviour of fastcc_nonconvex
%       is asserted until the defect below is fixed.
%
% Function under test:
%     src/reconstruction/modelGeneration/fluxConsistency/DCA/fastcc_nonconvex.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves LPs on a hand-built network.
%
% Coverage exemptions:
%     every line - fastcc_nonconvex is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call stops with an error because LP7 is called with the wrong arguments
%       SEVERITY: error
%       TRIGGER: model = struct('S', sparse([1 -1 0; 0 1 -1]), 'lb', zeros(3, 1), 'ub', 10 *
%         ones(3, 1), 'rxns', {{'R1'; 'R2'; 'R3'}}); fastcc_nonconvex(model, 1e-4, 0) (any
%         model, epsilon, printLevel and modeFlag)
%       OBSERVED: (R2025a, gurobi, 2026-11-23) error "Dot indexing is not supported for
%         variables of this type." in LP7 line 38: line 61 calls LP7(J, model, epsilon), but
%         LP7's signature is LP7(J, model, LPproblem, epsilon, basis), so epsilon is taken as
%         the LP problem structure and LP7 reads epsilon.A
%       EXPECTED: A, the n x 1 indicator of the flux consistent reactions (here all three
%         reactions of the chain), as the help text says
%       LINES: 61
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFastcc_nonconvex'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so nothing calls it
% and no solver is declared; the call is the standard opening of a COBRA test and the place
% where the requirements are added when the defects are fixed
prepareTest();

% change the directory
cd(currentDir)
