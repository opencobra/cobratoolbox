% The COBRAToolbox: testConfigureSetupThermoModelInputs.m
%
% Purpose:
%     - configureSetupThermoModelInputs normalises identifiers, derives metCompartments, and sets
%       temperature, compartment pH, ionic strength and potential, concentration bounds and the
%       confidence level of a model before setupThermoModel. A test would check every configured
%       field against a hand-built createModel model.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       the optional concMinDefault and concMaxDefault are never used and a model that already has
%       concentration bounds stops with an error unless they are passed (defects below), so this
%       file makes no assertion about the function.
%
% Function under test:
%     src/analysis/thermo/vonBertalanffy/configureSetupThermoModelInputs.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a hand-built createModel model, no solver.
%
% Coverage exemptions:
%     every line - configureSetupThermoModelInputs is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A model with concMin or concMax fails unless concMinDefault and concMaxDefault are
%       passed
%       SEVERITY: error
%       TRIGGER: model = createModel({'r1'}, {'r1'}, {'A[c] -> B[c]'}) with metFormulas {'C';
%       'C'}, metCharges [0; 0], concMin [1e-6; 1e-6], concMax [1e-3; 1e-3];
%       configureSetupThermoModelInputs(model)
%       OBSERVED: 'Not enough input arguments.' at line 188 (MATLAB R2025a): lines 63-68 default
%       variables named concMin and concMax instead of concMinDefault and concMaxDefault; passing
%       concMinDefault = [] raises the error of line 189 'concMinDefault must not be set if
%       concentrations are provided', the opposite of its message
%       EXPECTED: all optional inputs are empty by default (header); the model's bounds are kept
%       and an error is raised only when a default is set together with model bounds
%       LINES: 63-68, 188-190, 203-205
%     - DEFECT: concMinDefault and concMaxDefault are ignored
%       SEVERITY: unusable-option
%       TRIGGER: the model above without concMin and concMax;
%       configureSetupThermoModelInputs(model, [], [], [], [], [], 1e-6, 1e-3)
%       OBSERVED: model.concMin = [1e-5; 1e-5] and model.concMax = [1e-2; 1e-2] (MATLAB R2025a):
%       lines 192 and 207 overwrite the inputs with 1e-5 and 1e-2; lines 193-194 and 208-209 can
%       never run
%       EXPECTED: model.concMin = [1e-6; 1e-6] and model.concMax = [1e-3; 1e-3] (the documented
%       default bounds)
%       LINES: 192-197, 207-212
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConfigureSetupThermoModelInputs'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
