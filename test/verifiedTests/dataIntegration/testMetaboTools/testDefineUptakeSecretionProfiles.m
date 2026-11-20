% The COBRAToolbox: testDefineUptakeSecretionProfiles.m
%
% Purpose:
%     - defineUptakeSecretionProfiles computes for every exchange the slope of each condition
%       relative to its control (TP2/TP1) and their ratio, calls uptake below 1 - tol and
%       secretion above 1 + tol, and removes or adds exchanges as specified. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): the
%       documented essAA_excl flag (0 or 1, default 0) always stops the call, and fewer than
%       four exchanges stop it as well, so no assertion about the function is made.
%
% Function under test:
%     src/dataIntegration/metabotools/defineUptakeSecretionProfiles.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built intensity matrices would suffice.
%
% Coverage exemptions:
%     every line - defineUptakeSecretionProfiles is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented essAA_excl flag and its default stop the call
%       SEVERITY: error
%       TRIGGER: A = ones(5, 4); defineUptakeSecretionProfiles(A, A, {'EX_a'; 'EX_b'; 'EX_c';
%         'EX_d'; 'EX_e'}, 0.05) (default essAA_excl = 0), or the same call with essAA_excl
%         0 or 1
%       OBSERVED: Input A of class cell and input B of class double must be cell arrays of
%         character vectors, unless one is a character vector. (ismember, called at line 89;
%         R2025a, 2026-11-15). The flag is passed to ismember as the list of exchanges to
%         remove; only a cell array of exchange names (as the MetaboTools tutorial passes)
%         works.
%       EXPECTED: with 0 nothing removed; with 1 the nine essential amino acid exchanges of
%         the help removed from the secretion profiles
%       LINES: 45-47, 87-92
%     - DEFECT: Fewer than four exchanges stop the call with an index error
%       SEVERITY: error
%       TRIGGER: defineUptakeSecretionProfiles(ones(3, 4), ones(3, 4), {'EX_a'; 'EX_b'; 'EX_c'},
%         0.05, {'EX_x'})
%       OBSERVED: Index in position 1 exceeds array bounds. Index must not exceed 3. (line 57;
%         R2025a, 2026-11-15): the loop runs to length(input_A), which is 4 for a 3 x 4 matrix
%       EXPECTED: the profiles of the three exchanges (one row per exchange)
%       LINES: 55
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDefineUptakeSecretionProfiles'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
