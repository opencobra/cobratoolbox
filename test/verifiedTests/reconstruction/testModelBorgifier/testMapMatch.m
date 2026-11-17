% The COBRAToolbox: testMapMatch.m
%
% Purpose:
%     - mapMatch compares the local network topology of a compared model (Cmodel) and a
%       template model (Tmodel). Without seed metabolites ('noSeed') it scores each pair of
%       reactions by the difference in the number of metabolites and, for their
%       metabolites, the average of the minimum difference in the number of reactions; with
%       seed metabolite pairs it propagates match scores alternately between metabolites and
%       reactions. The function is QUARANTINED (Constitution III-Defects, quarantine in
%       back-fill campaigns): for a compared reaction with a single metabolite, the minimum
%       is taken over the template metabolites instead of over the compared metabolites, so
%       no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/mapMatch.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; a test would use hand-built stoichiometric
%     matrices.
%
% Coverage exemptions:
%     every line - mapMatch is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: 'noSeed' score of a single-metabolite compared reaction uses the minimum over the template metabolites
%       SEVERITY: wrong-result
%       TRIGGER: C.mets = {'c1'; 'c2'}; C.rxns = {'R1'; 'R2'}; C.S = sparse([1 -1; 0 1]);
%         T.mets = {'t1'; 't2'; 't3'}; T.rxns = {'Q1'; 'Q2'}; T.S = sparse([-1 1; 1 0; 1 0]);
%         T.Models.m1.mets = true(3, 1); rmatch = mapMatch(C, T, 'noSeed')
%       OBSERVED: rmatch(1, 1) = 1. The differences in reaction counts between c1 and t1,
%         t2, t3 are [0 1 1]; line 81 takes min(diffNumRxns(s1(:, ir1), s2(:, ir2))), which
%         for one compared metabolite (a 1 x 3 row) is the minimum over the template
%         metabolites (0) instead of the per-template-metabolite minimum over the compared
%         metabolites that the same line computes for two or more compared metabolites;
%         0 * |3 - 1| gives 1 / (0 + 1) = 1 (R2025a, 2026-11-15)
%       EXPECTED: mean([0 1 1]) = 2/3, times the metabolite-count difference 2, gives
%         rmatch(1, 1) = 1 / (4/3 + 1) = 3/7, the value of the documented "average of the
%         minimum difference" computed as for reactions with several metabolites
%         (min(..., [], 1))
%       LINES: 81
%     - DEFECT: The help names the third input seedMats and does not document the 'noSeed' form
%       SEVERITY: cosmetic
%       TRIGGER: help mapMatch; and the C, T of the entry above with [rmatch, mmatch] =
%         mapMatch(C, T, 'noSeed')
%       OBSERVED: (R2025a, 2026-11-17) the INPUTS section (line 12) describes "seedMats" while
%         the signature and USAGE use seedMets; the help never mentions 'noSeed', the only form
%         compareCbModels uses (its line 336). The call returns rmatch = [1 1; 1 1] and mmatch
%         = zeros(2, 3): in the noSeed branch (lines 57-90) mmatch is never computed, and any
%         other character argument (for example 'xyz') returns both outputs as zeros without
%         a message. No call fails because of the help
%       EXPECTED: the help names the input seedMets and documents 'noSeed' (topology score
%         only, mmatch not computed)
%       LINES: 1, 7, 12-14, 57-58
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMapMatch'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
