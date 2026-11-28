% The COBRAToolbox: testTripleSL.m
%
% Purpose:
%     - tripleSL (Fast-SL) returns the single lethal reactions (through singleSL), the
%       double lethal reaction pairs and the triple lethal reaction triplets of a model,
%       searching only reactions that carry flux in minimal-norm optimal flux distributions,
%       skipping the reactions of eliList (by default the ATP maintenance reaction atpm) and
%       removing triplets that contain a double lethal pair. Quarantined: no behaviour of
%       tripleSL is asserted until the defects below are fixed.
%
% Function under test:
%     src/analysis/deletion/Syntheticlethals/Fast-SL/tripleSL.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP (minimal-norm FBA and FBA) on a toy model.
%
% Coverage exemptions:
%     every line - tripleSL is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A model without an ATPM reaction stops with an error when eliList is not given
%       SEVERITY: error
%       TRIGGER: tripleSL(model) on the toy model EX_A ( -> A, ub 10), R1, R2, R3 (each
%         A -> B), BIO (B -> , objective), which has no reaction named atpm ('ATPM')
%       OBSERVED: (R2025a, gurobi, 2026-11-25) MATLAB:UndefinedFunction "Unrecognized function
%         or variable 'Jnz_copy'." at line 71: the default eliList is empty, and Jnz_copy is
%         only assigned inside the branch for a non-empty eliList (lines 64-67)
%       EXPECTED: the analysis of every reaction that carries flux (eliList is optional), as
%         singleSL and doubleSL do for the same model
%       LINES: 64-67, 71
%     - DEFECT: Triple lethal reaction sets are dropped when there is no double lethal pair
%       SEVERITY: wrong-result
%       TRIGGER: [Jsl, Jdl, Jtl] = tripleSL(model, [], {'EX_A'}) on the toy model above, or
%         tripleSL(model) on the same model with ATPM (A -> , lb 1) added
%       OBSERVED: (R2025a, gurobi, 2026-11-25) Jsl = {'BIO'} (with ATPM: {'EX_A', 'BIO'}),
%         Jdl and Jtl empty. The filter of lines 222-235 keeps a triplet only if max(g) < 2;
%         with no double lethal pair g = zeros(1, 0), max(g) is empty and the condition is
%         false for every triplet
%       EXPECTED: Jtl = {'R1', 'R2', 'R3'}: knocking out the three parallel routes gives
%         growth 0, while every single or double knock-out leaves a route with growth 10
%         (9 with ATPM)
%       LINES: 222-235
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTripleSL'));
cd(fileDir);

% declare the requirements of this test; nothing that calls tripleSL runs while it is
% quarantined, so no solver is required yet
prepareTest();

% change the directory
cd(currentDir)
