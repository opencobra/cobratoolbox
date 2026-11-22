% The COBRAToolbox: testPriorityKeqMeasurement.m
%
% Purpose:
%     - priorityKeqMeasurement finds, round by round, the internal reactions in which exactly
%       one metabolite lacks an equilibrium-constant (Keq) standard Gibbs energy of formation,
%       lists those reactions in order of priority (priorityKeq) with the number of
%       metabolites still unknown after each round (numNonKeqMet), and plots both series. A
%       test would check both outputs for a hand-built chain of reactions.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): every call that reaches the plot stops with an error (first defect below),
%       so this file makes no assertion about the function.
%
% Function under test:
%     src/analysis/thermo/experimentalDesign/priorityKeqMeasurement.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built thermodynamic model fields, a figure, no solver.
%
% Coverage exemptions:
%     every line - priorityKeqMeasurement is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The plot fails on an invalid line style, so no call returns
%       SEVERITY: error
%       TRIGGER: priorityKeqMeasurement(modelT) with modelT.S = [-1 0 0; 1 -1 0; 0 1 0; -1 0 1],
%       mets {'a[c]'; 'b[c]'; 'c[c]'; 'h[c]'}, rxns {'R1'; 'R2'; 'EX'}, SIntRxnBool = [true;
%       true; false], dGft0Source 'Keq' for a[c] and 'GC' for the others, officialName and
%       equation set
%       OBSERVED: the two rounds are printed, then "Error setting property 'LineStyle' of class
%       'Line': '.' is not a valid value." at line 173 (MATLAB R2025a); line 174 sets '*' in the
%       same way
%       EXPECTED: the outputs priorityKeq and numNonKeqMet (here [2 1 0]) and the figure
%       LINES: 173-174
%     - DEFECT: A model whose metabolites all have Keq data fails
%       SEVERITY: error
%       TRIGGER: the model above with dGft0Source 'Keq' for every metabolite
%       OBSERVED: "Unrecognized function or variable 'measuredMetRxnRatio'." at line 172 (MATLAB
%       R2025a): the while loop of line 66 is skipped, so measuredMetRxnRatio and priorityKeq are
%       never assigned
%       EXPECTED: nothing left to measure (empty priorityKeq, numNonKeqMet = 0)
%       LINES: 66, 172
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPriorityKeqMeasurement'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
