% The COBRAToolbox: testChangeCOBRAVariable.m
%
% Purpose:
%     changeCOBRAVariable changes the bounds, objective coefficient or name of an existing
%     variable of model.evars. The function is QUARANTINED (Constitution III-Defects, quarantine in
%     back-fill campaigns): the documented index form of variableID and the documented option Name
%     stop with an error (defects below), so no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/refinement/changeCOBRAVariable.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation without a solver; a test would use a createModel model with
%     a variable added by addCOBRAVariables.
%
% Coverage exemptions:
%     every line - changeCOBRAVariable is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented variable index cannot be used as variableID
%       SEVERITY: error
%       TRIGGER: model = createModel({'R1','R2','EX_A','EX_C'}, {'R1','R2','EX_A','EX_C'}, {'A -> B','B <=> C','A <=> ','C -> '}); model = addCOBRAVariables(model, {'v1'}, 'lb', 0, 'ub', 3); changeCOBRAVariable(model, 1, 'lb', 1)
%       OBSERVED: error "The value of 'variableID' is invalid. It must satisfy the function: @(x)ischar(x)&&any(ismember(model.evars,x))."
%       EXPECTED: model.evarlb(1) = 1 (INPUTS: "variableID: The ID of the variable (or the index in the evars field)")
%       LINES: 32
%     - DEFECT: The documented option Name stops with an error
%       SEVERITY: unusable-option
%       TRIGGER: same model as above; changeCOBRAVariable(model, 'v1', 'Name', 'newName')
%       OBSERVED: error "Unrecognized field name "evarName"." (the option name is appended to 'evar', but addCOBRAVariables stores the names in evarNames)
%       EXPECTED: model.evarNames{1} = 'newName' (OPTIONAL INPUTS: "Name: The new, descriptive name of the variable.")
%       LINES: 51-54
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testChangeCOBRAVariable'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
