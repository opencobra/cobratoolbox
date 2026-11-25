% The COBRAToolbox: testFindMustU.m
%
% Purpose:
%     - findMustU(model, minFluxesW, maxFluxesW, ...) runs the second step of OptForce: it
%       solves a bilevel MILP repeatedly to find the reactions of the MustU set (reactions whose
%       minimum flux in the mutant, model plus the fixed fluxes of constrOpt, lies above their
%       maximum flux in the wild type) and returns them with their positions, optionally writing
%       a report, the inputs and the set with its flux ranges to files. The function is
%       quarantined for the defect below: this file asserts nothing about it.
%
% Function under test:
%     src/design/optForce/findMustU.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves MILPs and LPs (quarantined: no solver is used here).
%
% Coverage exemptions:
%     every line - findMustU is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The maximum mutant flux written for each MustU reaction ignores constrOpt
%       SEVERITY: wrong-result
%       TRIGGER: any call with constrOpt that finds a set and writes the info files; reproduction:
%         t = createModel({'EX_A','R1','R2','EX_B','EX_C'}, {'','','','',''}, {' -> A[c]','A[c] -> B[c]',
%         'A[c] -> C[c]','B[c] -> ','C[c] -> '}, 'lowerBoundList', zeros(1,5), 'upperBoundList',
%         10*ones(1,5), 'printLevel', 0); minW = [10; 0; 8; 0; 8]; maxW = [10; 2; 10; 2; 10];
%         constrOpt = struct('rxnList', {{'EX_A'; 'EX_B'}}, 'values', [10; 8]);
%         findMustU(t, minW, maxW, 'constrOpt', constrOpt, 'runID', 'U1', 'printLevel', 0)
%       OBSERVED: (R2025a, 2026-11-25, gurobi) the set {'R1'} (position 2) is correct, but
%         MustUSet_Info.txt (and MustUSet_Info.xlsx) give "Max Flux in Mutant strain" 10.0000
%         for R1, while the mutant fixes it at 8 (EX_A = 10, EX_B = 8). Lines 290-292 maximise
%         the reaction over the model without the constrOpt fluxes
%       EXPECTED: the maximum flux of the reaction in the mutant (model with the constrOpt
%         fluxes), 8 here, as the column title and the help text (C5) say
%       LINES: 290-292, 324, 345
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindMustU'));
cd(fileDir);

% findMustU is quarantined: the standard opening only, no requirement is declared because
% nothing is solved
prepareTest();

% change the directory
cd(currentDir)
