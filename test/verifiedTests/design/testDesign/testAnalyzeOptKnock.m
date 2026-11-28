% The COBRAToolbox: testAnalyzeOptKnock.m
%
% Purpose:
%     - analyzeOptKnock(model, deletions, target, biomassRxn, geneDelFlag) knocks out reactions
%       (or genes, with deleteModelGenes), maximises growth, fixes the lower bound of biomassRxn
%       to that optimum, returns the minimum and maximum flux of target there and classifies
%       the strain ('not growth coupled', 'non unique', 'growth coupled non unique', 'growth
%       coupled'); with the global CBT_QP_SOLVER set it solves with minNorm. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): an
%       infeasible strain stops it with a solver error, and the objective value is used as the
%       biomass flux, so an objective coefficient other than 1 gives wrong rates and type; no
%       assertion about the function is made.
%
% Function under test:
%     src/design/analyzeOptKnock.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - three LPs (or QPs) on a hand-built model; a test would declare
%     prepareTest('needsLP', true, 'needsQP', true) and loop over the solvers (gurobi on the
%     reference machine).
%
% Coverage exemptions:
%     every line - analyzeOptKnock is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An infeasible knock-out strain stops the function with a solver error
%       SEVERITY: error
%       TRIGGER: model = createModel({'EX_A'; 'R1'; 'R2'; 'R5'; 'EX_D'; 'BIO'; 'ATPM'; 'EX_P';
%         'EX_Q'}, {'EX_A'; 'R1'; 'R2'; 'R5'; 'EX_D'; 'BIO'; 'ATPM'; 'EX_P'; 'EX_Q'}, {'A <=> ';
%         'A -> B'; 'A -> B + P'; 'D -> P'; 'D <=> '; 'B -> '; 'B -> '; 'P <=> '; 'Q <=> '},
%         'lowerBoundList', [-10 0 0 0 -5 0 1 0 0], 'upperBoundList', 1000 * ones(1, 9));
%         model = changeObjective(model, 'BIO'); analyzeOptKnock(model, {'R1'; 'R2'}, 'EX_P')
%       OBSERVED: (R2025a, gurobi, 2026-11-25) "Gurobi error 10003: Element 0 of a double array
%         is Nan." from solveCobraLP, with and without CBT_QP_SOLVER: without R1 and R2 no B is
%         made and ATPM needs 1, so the growth LP is infeasible, FBAsol1.f is NaN and line 56
%         puts NaN into the lower bound of BIO; the solve status is never checked
%       EXPECTED: the strain reported as not viable (for example maxGrowth NaN or 0 and type
%         'not growth coupled') without a solver error
%       LINES: 51-56
%     - DEFECT: The objective value is used as the biomass flux
%       SEVERITY: wrong-result
%       TRIGGER: model as above with model.c(6) = 2; analyzeOptKnock(model, {'R1'}, 'EX_P')
%         and analyzeOptKnock(model, {'R1'}, 'EX_P', 'BIO')
%       OBSERVED: (R2025a, gurobi, 2026-11-25) with the default biomassRxn, line 34 selects
%         model.c == 1, which matches no reaction, so no growth rate is fixed: 'growth coupled
%         non unique', maxGrowth 18, maxProd 15, minProd 1; with biomassRxn 'BIO', line 56 sets
%         its lower bound to the objective value 18, above the largest biomass flux 9, so both
%         LPs are infeasible: 'growth coupled', maxProd NaN, minProd NaN
%       EXPECTED: the result for model.c(6) = 1 ('growth coupled non unique', 9, 15, 10): with
%         R1 knocked out, maximal biomass flux 9 needs EX_P >= 10 through R2 and D adds up to 5
%       LINES: 34, 56, 69-77
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAnalyzeOptKnock'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and not called, so no
% solver is needed; the call is the standard opening of a COBRA test and the place where the
% requirement (an LP solver) is added when the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
