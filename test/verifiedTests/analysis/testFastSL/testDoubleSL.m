% The COBRAToolbox: testDoubleSL.m
%
% Purpose:
%     - doubleSL (Fast-SL) returns the single lethal reactions (through singleSL) and the
%       double lethal reaction pairs of a model, searching only pairs of reactions that
%       carry flux in minimal-norm optimal flux distributions and skipping the reactions of
%       eliList (by default the ATP maintenance reaction atpm). Quarantined: no behaviour of
%       doubleSL is asserted until the defect below is fixed.
%
% Function under test:
%     src/analysis/deletion/Syntheticlethals/Fast-SL/doubleSL.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP (minimal-norm FBA and FBA) on a toy model.
%
% Coverage exemptions:
%     every line - doubleSL is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented atpm input is ignored
%       SEVERITY: unusable-option
%       TRIGGER: doubleSL(model, [], [], 'BIO') on the six-reaction toy model of
%         testSingleSL.m: EX_A ( -> A, ub 10), R1 (A -> B), R2 (A -> C, ub 5), R3 (C -> B),
%         BIO (B -> , objective), ATPM (A -> , lb 1)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) Jsl = {'EX_A', 'BIO'}, the same as
%         doubleSL(model); singleSL(model, [], [], 'BIO') returns {'EX_A'}. The default
%         eliList is built from the literal 'ATPM' and atpm is never read, so a maintenance
%         reaction with another identifier cannot be excluded through atpm
%       EXPECTED: BIO excluded from the analysis (Jsl = {'EX_A'}), as the help says atpm is
%         the ATPM reaction id when it is not 'ATPM' and as singleSL and tripleSL do
%       LINES: 38-44
%     - DEFECT: The outputs are reaction identifiers, not the documented indices
%       SEVERITY: cosmetic
%       TRIGGER: [Jsl, Jdl] = doubleSL(model) on the toy model above
%       OBSERVED: (R2025a, gurobi, 2026-11-25) Jsl = {'EX_A', 'BIO'} and Jdl = {'R1', 'R2';
%         'R1', 'R3'}: cell arrays of reaction identifiers
%       EXPECTED: the help (OUTPUTS) describes Jsl and Jdl as indices of reactions
%       LINES: 123-124
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDoubleSL'));
cd(fileDir);

% declare the requirements of this test; nothing that calls doubleSL runs while it is
% quarantined, so no solver is required yet
prepareTest();

% change the directory
cd(currentDir)
