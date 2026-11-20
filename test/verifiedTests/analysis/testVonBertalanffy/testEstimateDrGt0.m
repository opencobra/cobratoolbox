% The COBRAToolbox: testEstimateDrGt0.m
%
% Purpose:
%     - estimateDrGt0(model, confidenceLevel) computes DrG0 = S'*DfG0 and DrGt0 = S'*DfGt0
%       (NaN for exchange reactions), adds the pH and electrical potential terms of transport
%       reactions, and derives DrGt0Min/Max, DrGtMin/Max and DrGtMean from the uncertainty and
%       the concentration bounds. The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): a model carrying the gas constant in model.R stops
%       with an undefined variable; no assertion about the function is made.
%
% Function under test:
%     src/analysis/thermo/vonBertalanffy/estimateDrGt0.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - no solver; a test would hand-build a two- or three-compartment model and derive
%     every reaction Gibbs energy by hand.
%
% Coverage exemptions:
%     every line - estimateDrGt0 is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: a model with the field R (gas constant) stops with an undefined variable
%       SEVERITY: error
%       TRIGGER: model = struct('S', sparse([-1; 1]), 'mets', {{'a[c]'; 'b[c]'}}, 'metFormulas',
%         {{'C'; 'C'}}, 'metCharges', [0; 0], 'compartments', {{'c'}}, 'ph', 7, 'chi', 0,
%         'concMin', [1e-5; 1e-5], 'concMax', [1e-2; 1e-2], 'DfG0', [1; 2], 'DfGt0', [1; 2],
%         'DfGtMin', [0; 1], 'DfGtMax', [2; 3], 'SIntRxnBool', true, 'DrG0_Uncertainty', 1,
%         'DrGt0_Uncertainty', 1, 'lb', -10, 'ub', 10, 'R', 8.3144621e-3); estimateDrGt0(model)
%       OBSERVED: "Unrecognized function or variable 'gasConstant'." at line 118 (R2025a,
%         2026-11-16): lines 58-60 define gasConstant only when model has no field R and no
%         branch takes it from model.R; without the field the same model runs
%       EXPECTED: the gas constant is taken from model.R (or the constant is defined in every
%         case), as the isfield test on line 58 intends; setupThermoModel documents that a
%         model may carry R
%       LINES: 58-60, 118
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testEstimateDrGt0'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so nothing is run;
% the call is the standard opening of a COBRA test
prepareTest();

% change the directory
cd(currentDir)
