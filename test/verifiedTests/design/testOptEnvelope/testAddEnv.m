% The COBRAToolbox: testAddEnv.m
%
% Purpose:
%     - addEnv(origModel, biomass, desiredProduct, KnockOuts, colour, prodMol, subUptake,
%       molarSum) knocks out reactions or genes, takes 100 points between the minimum and the
%       maximum of the model objective, fixes the biomass reaction to each of them, computes the
%       minimum and maximum of desiredProduct and plots both edges of the production envelope
%       into the current figure (optionally as yields), returning the line of the maximum edge.
%       The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): with a zero objective range a requested output is never assigned, an
%       infeasible strain stops it with a solver error, and the range of the objective is used
%       as the range of the biomass flux; no assertion about the function is made.
%
% Function under test:
%     src/design/optEnvelope/addEnv.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - about 200 LPs on a hand-built model and an invisible figure; a test would declare
%     prepareTest('needsLP', true) and loop over the LP solvers (gurobi on the reference
%     machine).
%
% Coverage exemptions:
%     every line - addEnv is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The output line is not assigned when the objective range is zero
%       SEVERITY: error
%       TRIGGER: model = createModel({'EX_A'; 'R1'; 'R2'; 'R5'; 'EX_D'; 'BIO'; 'ATPM'; 'EX_P';
%         'EX_Q'}, {'EX_A'; 'R1'; 'R2'; 'R5'; 'EX_D'; 'BIO'; 'ATPM'; 'EX_P'; 'EX_Q'}, {'A <=> ';
%         'A -> B'; 'A -> B + P'; 'D -> P'; 'D <=> '; 'B -> '; 'B -> '; 'P <=> '; 'Q <=> '},
%         'lowerBoundList', [-10 0 0 0 -5 0 0 0 0], 'upperBoundList', 1000 * ones(1, 9));
%         model = changeObjective(model, 'BIO'); figure('Visible', 'off');
%         ln = addEnv(model, 'BIO', 'EX_P', {'R1', 'R2'})
%       OBSERVED: (R2025a, gurobi, 2026-11-25) "Output argument "line" (and possibly others)
%         not assigned a value in the execution with "addEnv" function.": the knock-outs leave
%         no growth, all 100 points are 0 and line 99 returns before line is set
%       EXPECTED: an empty line (or no plot) returned for a strain without growth, as the
%         early return intends; optEnvelope always requests the output
%       LINES: 98-99
%     - DEFECT: An infeasible knock-out strain stops the function with a solver error
%       SEVERITY: error
%       TRIGGER: the model above with ATPM lower bound 1 ('lowerBoundList', [-10 0 0 0 -5 0 1 0
%         0]); figure('Visible', 'off'); ln = addEnv(model, 'BIO', 'EX_P', {'R1', 'R2'})
%       OBSERVED: (R2025a, gurobi, 2026-11-25) "Gurobi error 10003: Element 0 of a double array
%         is Nan." from solveCobraLP: both LPs of lines 95-96 are infeasible (f = NaN), so the
%         100 points are NaN, nnz(NaN) is not 0 and line 104 puts NaN into the bounds of BIO
%       EXPECTED: the same handling as a strain without growth (no envelope drawn)
%       LINES: 95-99, 104
%     - DEFECT: The range of the model objective is used as the range of the biomass flux
%       SEVERITY: wrong-result
%       TRIGGER: the model with ATPM lower bound 1; m = changeObjective(model, 'EX_P');
%         figure('Visible', 'off'); ln = addEnv(m, 'BIO', 'EX_P', {'R1'}); and the same with
%         model.c(6) = 2 instead of the new objective
%       OBSERVED: (R2025a, gurobi, 2026-11-25) with objective EX_P, ln.XData runs from 1 to 15
%         (the range of EX_P) and 43 of the 100 points of ln.YData are NaN; with model.c(6) = 2
%         it runs from 0 to 18 and 50 points are NaN. Lines 95-97 take the range from the
%         objective, not from the biomass argument; with objective BIO and coefficient 1
%         XData runs from 0 to 9 and YData is 15 at both ends
%       EXPECTED: the envelope over the feasible range of the biomass reaction (0 to 9), the
%         reaction the caller names in biomass, whatever the model objective
%       LINES: 95-97, 105-116
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddEnv'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and not called, so no
% solver is needed; the call is the standard opening of a COBRA test and the place where the
% requirement (an LP solver) is added when the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
