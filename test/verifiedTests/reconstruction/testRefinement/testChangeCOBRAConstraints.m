% The COBRAToolbox: testChangeCOBRAConstraints.m
%
% Purpose:
%     changeCOBRAConstraints changes the coefficients (C, D), right hand side d, sense dsense and
%     name of an existing constraint of model.ctrs. The function is QUARANTINED (Constitution
%     III-Defects, quarantine in back-fill campaigns): the documented index form of constraintID
%     stops with an error (defect below), so no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/refinement/changeCOBRAConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation without a solver; a test would use a createModel model with
%     constraints added by addCOBRAConstraints and variables added by addCOBRAVariables.
%
% Coverage exemptions:
%     every line - changeCOBRAConstraints is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented constraint index cannot be used as constraintID
%       SEVERITY: error
%       TRIGGER: model = createModel({'R1','R2','EX_A','EX_C'}, {'R1','R2','EX_A','EX_C'}, {'A -> B','B <=> C','A <=> ','C -> '}); model = addCOBRAConstraints(model, {'R1','R2'}, 5, 'c', [1 1], 'dsense', 'L'); changeCOBRAConstraints(model, 1, 'd', 7)
%       OBSERVED: error "The value of 'constraintID' is invalid. It must satisfy the function: @(x)ischar(x)&&any(ismember(model.ctrs,x))." (the validator accepts only a char ID, so the numeric path after line 75 is never used)
%       EXPECTED: model.d(1) = 7 (INPUTS: "constraintID: The ID of the constraint (or the index in the ctrs field)")
%       LINES: 52
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testChangeCOBRAConstraints'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
