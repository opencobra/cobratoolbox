% The COBRAToolbox: testThermoQP.m
%
% Purpose:
%     - thermoQP computes an approximately thermodynamically feasible flux vector by
%       minimising the Euclidean norm of the fluxes weighted by the inverse conductances q,
%       subject to S*v = dxdt (and C*v <= d) and the flux bounds. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): every call
%       stops with an error, so no assertion about the function is made.
%
% Function under test:
%     src/dataIntegration/XomicsToModel/thermoKernel/thermoQP/thermoQP.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - a QP solver and a toy model would be needed.
%
% Coverage exemptions:
%     every line - thermoQP is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The QP solve passes an invalid parameter name, so every call stops
%       SEVERITY: error
%       TRIGGER: model = createModel({'R1'; 'R2'; 'R3'}, {'r1'; 'r2'; 'r3'}, {' -> A';
%         'A -> B'; 'B -> '}); model.lb = [0; 0; 0]; model.ub = [10; 10; 10]; model.c = [0; 0;
%         1]; thermoQP(model, [1; 1; 1], struct('fbaOptimal', false)) (also with fbaOptimal
%         true, SConsistentRxnBool and osenseStr 'max')
%       OBSERVED: (R2025a, 2026-11-25, gurobi) "All parameters have to be valid matlab field
%         names. param.printLevel is not a valid field name" from parseSolverParameters, called
%         by solveCobraQP(QPproblem, 'param.printLevel', 0) at line 237
%       EXPECTED: the QP solution in sol (fields f, v, y, w, s, stat), as the help documents
%       LINES: 237
%     - DEFECT: An omitted param, or a param without the field fbaOptimal, stops with an error
%       SEVERITY: error
%       TRIGGER: thermoQP(model, [1; 1; 1]) with the model of the first entry (param is an
%         optional input; lines 54-56 replace an omitted param by struct())
%       OBSERVED: (R2025a, 2026-11-25) "Unrecognized field name "fbaOptimal"." at line 194
%       EXPECTED: a default for param.fbaOptimal, as for the omitted param
%       LINES: 54-56, 194
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testThermoQP'));
cd(fileDir);

% declare the requirements of this test; nothing that calls thermoQP runs while it is
% quarantined, so no solver is required yet
prepareTest();

% change the directory
cd(currentDir)
