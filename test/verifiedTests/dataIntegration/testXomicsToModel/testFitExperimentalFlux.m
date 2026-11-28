% The COBRAToolbox: testFitExperimentalFlux.m
%
% Purpose:
%     - fitExperimentalFlux fits a steady-state flux vector v to experimental fluxes vExp
%       (NaN where there is no information), relaxing the lower bounds by p and the upper
%       bounds by q, with a weighted zero-, one- or two-norm objective on the relaxations and
%       on the deviations dv, and returns the objective value obj. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): the
%       objective value obj of the methods zeroOne and oneTwo is NaN whenever vExp holds a NaN,
%       so no assertion about the function is made.
%
% Function under test:
%     src/dataIntegration/XomicsToModel/metabolomics/fitExperimentalFlux.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP (cardinality optimisation) and QP solvers on a toy model would be needed.
%
% Coverage exemptions:
%     every line - fitExperimentalFlux is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The objective value of the methods zeroOne and oneTwo is NaN when vExp holds a NaN
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'R1'; 'R2'}, {'r1'; 'r2'}, {' -> A'; 'A -> '});
%         model.lb = [6; 0]; model.ub = [10; 2]; model.c = [0; 0]; [v, p, q, dv, obj] =
%         fitExperimentalFlux(model, [NaN; NaN], [1; 1], [1; 1], [1; 1], struct('method',
%         'oneTwo')) (the same with method 'zeroOne')
%       OBSERVED: (R2025a, 2026-11-25, gurobi) oneTwo: v = [4; 4], p = [2; 0], q = [0; 2] and
%         obj = NaN; zeroOne: v = [6; 6], p = [0; 0], q = [0; 4] and obj = NaN. dv is NaN for
%         every reaction without an experimental flux (line 394), and the objective adds
%         norm(dv, 1) (lines 401 and 403), which is NaN
%       EXPECTED: a finite objective value; vExp is documented as "NaN if no info", and the
%         fitted problem itself (lines 141 and 156) leaves those reactions out
%       LINES: 394, 401, 403
%     - DEFECT: An infeasible cardinality fit stops with a MATLAB error instead of the function's message
%       SEVERITY: cosmetic
%       TRIGGER: the model of the first entry, fitExperimentalFlux(model, [NaN; NaN], [Inf;
%         Inf], [Inf; Inf], [1; 1], struct('method', 'zero')) (infinite weights forbid every
%         relaxation, lines 289-294)
%       OBSERVED: (R2025a, 2026-11-25, gurobi) MATLAB:nonExistentField "Unrecognized field
%         name "xyz"." at line 347; with the default method 'two' the same input ends with the
%         error fitExperimentalFlux:infeasibleFit of line 384 after two retries
%       EXPECTED: the error fitExperimentalFlux:infeasibleFit of line 384, as for method 'two'
%       LINES: 345-347
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFitExperimentalFlux'));
cd(fileDir);

% declare the requirements of this test; nothing that calls fitExperimentalFlux runs while
% it is quarantined, so no solver is required yet
prepareTest();

% change the directory
cd(currentDir)
