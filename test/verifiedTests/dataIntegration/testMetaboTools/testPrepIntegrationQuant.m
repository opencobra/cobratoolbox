% The COBRAToolbox: testPrepIntegrationQuant.m
%
% Purpose:
%     - prepIntegrationQuant(model, metData, exchanges, samples, test_max, test_min,
%       outputPath, tol, variation) tests with one FBA per exchange and direction whether the
%       model can secrete (bounds [test_min, test_max]) and take up (bounds [-test_max,
%       -test_min]) each metabolite, removes the impossible ones from every sample of metData
%       and saves one uptake/secretion profile per sample (<sample name>.mat in outputPath).
%       The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): an exchange whose forced secretion or uptake makes the LP infeasible is
%       kept as possible, and a sample without secretion stops the function with an error; no
%       assertion about the function is made.
%
% Function under test:
%     src/dataIntegration/metabotools/prepIntegrationQuant.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - two LPs per exchange on a hand-built model; a test would declare
%     prepareTest('needsLP', true) and loop over the LP solvers (gurobi on the reference
%     machine).
%
% Coverage exemptions:
%     every line - prepIntegrationQuant is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An exchange whose forced secretion or uptake is infeasible is kept as possible
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'EX_A'; 'R1'; 'R2'; 'R5'; 'EX_D'; 'BIO'; 'ATPM'; 'EX_P';
%         'EX_Q'}, {'EX_A'; 'R1'; 'R2'; 'R5'; 'EX_D'; 'BIO'; 'ATPM'; 'EX_P'; 'EX_Q'}, {'A <=> ';
%         'A -> B'; 'A -> B + P'; 'D -> P'; 'D <=> '; 'B -> '; 'B -> '; 'P <=> '; 'Q <=> '},
%         'lowerBoundList', [-10 0 0 0 -5 0 1 0 0], 'upperBoundList', 1000 * ones(1, 9));
%         model = changeObjective(model, 'BIO'); outDir = tempname; mkdir(outDir);
%         prepIntegrationQuant(model, [2 -1; 3 1; -1 -2], {'EX_P'; 'EX_Q'; 'EX_D'}, {'s1';
%         's2'}, 500, 1e-5, outDir)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) Q has no producer, so forcing EX_Q >= 1e-5 is
%         infeasible: FBA_all_secreted(2, :) = [NaN 0]; likewise the uptake of EX_P (lb 0) gives
%         FBA_all_uptake(1, :) = [NaN 0]. Lines 77 and 101 test FBA.f == 0, NaN == 0 is false,
%         so neither is listed as not possible: s1.mat holds secretion = {'EX_P'; 'EX_Q'} and
%         s2.mat holds uptake = {'EX_P'; 'EX_D'}
%       EXPECTED: EX_Q in Secretion_not_possible and EX_P in Uptake_not_possible, so that s1
%         secretes only EX_P and s2 takes up only EX_D, as the help text says (exchanges the
%         model cannot realise are removed from each sample)
%       LINES: 65-68, 77, 89-92, 101
%     - DEFECT: A sample with no secretion stops the function with an error
%       SEVERITY: error
%       TRIGGER: model and outDir as above; prepIntegrationQuant(model, [-1; -1; -2],
%         {'EX_P'; 'EX_Q'; 'EX_D'}, {'s3'}, 500, 1e-5, outDir)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) "Variable 'secr_value' not found." at line 156:
%         lines 148-152 create an empty uptake_value when a sample has no uptake, but nothing
%         creates secr_value when a sample has no secretion (for the first sample secretion
%         even keeps the last exchange name set at line 94)
%       EXPECTED: a saved profile with empty secretion and secr_value, as for a sample without
%         uptake
%       LINES: 133, 148-152, 156
%     - DEFECT: A single exchange reaction stops the function with an error
%       SEVERITY: error
%       TRIGGER: model and outDir as above; prepIntegrationQuant(model, 2, {'EX_P'}, {'s4'},
%         500, 1e-5, outDir)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) "Index in position 1 exceeds array bounds. Index
%         must not exceed 1." at line 77: the loops of lines 76 and 100 run to
%         length(FBA_all_secreted) of an n x 2 matrix, which is 2 when n = 1
%       EXPECTED: one profile saved for the sample (a vector of one exchange is allowed by the
%         help text); the loops should run to size(FBA_all_secreted, 1)
%       LINES: 76-77, 100-101
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrepIntegrationQuant'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and not called, so no
% solver is needed; the call is the standard opening of a COBRA test and the place where the
% requirement (an LP solver) is added when the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
