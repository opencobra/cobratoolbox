% The COBRAToolbox: testFindMustL.m
%
% Purpose:
%     - findMustL(model, minFluxesW, maxFluxesW, ...) runs the second step of OptForce: it
%       solves a bilevel MILP repeatedly to find the reactions of the MustL set (reactions whose
%       maximum flux in the mutant, model plus the fixed fluxes of constrOpt, lies below their
%       minimum flux in the wild type) and returns them with their positions, optionally writing
%       a report, the inputs and the set with its flux ranges to files. The function is
%       quarantined for the defect below: this file asserts nothing about it.
%
% Function under test:
%     src/design/optForce/findMustL.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves MILPs and LPs (quarantined: no solver is used here).
%
% Coverage exemptions:
%     every line - findMustL is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The minimum mutant flux written for each MustL reaction ignores constrOpt
%       SEVERITY: wrong-result
%       TRIGGER: any call with constrOpt that finds a set and writes the info files; reproduction:
%         t = createModel({'EX_A','R1','R2','EX_B','EX_C'}, {'','','','',''}, {' -> A[c]','A[c] -> B[c]',
%         'A[c] -> C[c]','B[c] -> ','C[c] -> '}, 'lowerBoundList', zeros(1,5), 'upperBoundList',
%         10*ones(1,5), 'printLevel', 0); minW = [10; 0; 8; 0; 8]; maxW = [10; 2; 10; 2; 10];
%         constrOpt = struct('rxnList', {{'EX_A'; 'EX_B'}}, 'values', [10; 8]);
%         findMustL(t, minW, maxW, 'constrOpt', constrOpt, 'runID', 'L1', 'printLevel', 0)
%       OBSERVED: (R2025a, 2026-11-25, gurobi) the set {'R2'; 'EX_C'} (positions [3; 5]) is
%         correct, but MustLSet_Info.txt (and MustLSet_Info.xlsx) give "Min Flux in Mutant
%         strain" 0.0000 for R2 and EX_C, while the mutant fixes both at 2 (EX_A = 10,
%         EX_B = 8). Lines 297-299 minimise each reaction over the model without the constrOpt
%         fluxes
%       EXPECTED: the minimum flux of the reaction in the mutant (model with the constrOpt
%         fluxes), 2 here, as the column title and the help text (C4) say
%       LINES: 297-299, 331, 352
%     - DEFECT: The inputs are saved in a folder named InputsMustU
%       SEVERITY: cosmetic
%       TRIGGER: any call with keepInputs = 1 (the default)
%       OBSERVED: the run folder holds InputsMustU, the name used by findMustU
%       EXPECTED: a folder named after findMustL (InputsMustL)
%       LINES: 256
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindMustL'));
cd(fileDir);

% findMustL is quarantined: the standard opening only, no requirement is declared because
% nothing is solved
prepareTest();

% change the directory
cd(currentDir)
