% The COBRAToolbox: testPrintCouplingConstraints.m
%
% Purpose:
%     - printCouplingConstraints builds (printLevel > 0) and displays a table of the coupling
%       constraints of a model (fields C, ctrs, d, dsense), one row per constraint with its
%       formula rxn1 - rxn2 >= d, and (printLevel > 1) one row per coupled reaction with its
%       reaction formula. Quarantined: no behaviour of printCouplingConstraints is asserted
%       until the defect below is fixed. The opening below still calls prepareTest() because it
%       is the standard opening of every COBRA test.
%
% Function under test:
%     src/analysis/exploration/printCouplingConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-ups, no solver; a test would use a hand-built three-reaction model
%     with two coupling constraints (the smallest model that reaches every branch).
%
% Coverage exemptions:
%     every line - printCouplingConstraints is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented output is not assigned with the default printLevel, so a call requesting it stops
%       SEVERITY: error
%       TRIGGER: coupledRxnReport = printCouplingConstraints(model), or with printLevel 0, on a
%         model with a field C, for example the three-reaction model (rxns R1, R2, R3; S =
%         [-1 1 0; 0 -1 1]) with C = [1 -2 0; -1 0 1], d = [0; 1], dsense = ['G'; 'L'] and
%         ctrs = {'c1'; 'c2'}
%       OBSERVED: MATLAB R2025a: Output argument "coupledRxnReport" (and possibly others) not
%         assigned a value in the execution with "printCouplingConstraints" function. The
%         report is only built inside if printLevel > 0 (line 34) and the else branch of line
%         87 only covers a model without C. Without an output the same call returns silently;
%         with printLevel 1 the same model gives the two-row table (c1 'R1 - R2 >= 0', c2
%         '- R1 + R3 <= 1'), with printLevel 2 the six-row table with the reaction formulas,
%         and a model without C gives [] for every printLevel
%       EXPECTED: the summary report of the USAGE line, coupledRxnReport =
%         printCouplingConstraints(model, printLevel) with "Default = 0", for every printLevel,
%         with only the display gated behind printLevel > 0 as the documentation says
%       LINES: 34, 85
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintCouplingConstraints'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
