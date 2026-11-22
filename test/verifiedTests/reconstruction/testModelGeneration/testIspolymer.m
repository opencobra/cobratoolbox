% The COBRAToolbox: testIspolymer.m
%
% Purpose:
%     - ispolymer returns true when a chemical formula holds a polymer group (X, R, FULLR,
%       FULLR2 or FULLR3), counted with numAtomsOfElementInFormula. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): every call
%       stops with an error, so no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/modelGeneration/massBalance/ispolymer.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would pass hand-written formulae.
%
% Coverage exemptions:
%     every line - ispolymer is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every formula stops with an error because the group name FULLR2 contains a digit
%       SEVERITY: error
%       TRIGGER: ispolymer('C6H12O6'), ispolymer('C6H10O5X') or ispolymer('CH2R')
%       OBSERVED: "Element must not contain numbers" from numAtomsOfElementInFormula (line 28),
%         which rejects any element name with a digit before it translates FULLR2 and FULLR3;
%         line 17 passes 'FULLR2' in the fourth turn of the loop for every formula (MATLAB
%         prints 'FULLR2' before the error, R2025a, 2026-11-15)
%       EXPECTED: false for 'C6H12O6' and true for 'C6H10O5X' and 'CH2R'
%       LINES: 14, 17
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIspolymer'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
