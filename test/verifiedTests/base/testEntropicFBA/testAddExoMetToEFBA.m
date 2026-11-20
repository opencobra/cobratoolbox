% The COBRAToolbox: testAddExoMetToEFBA.m
%
% Purpose:
%     - addExoMetToEFBA adds the quadratic penalty matrix .H and the target vector .h that fit
%       the fluxes of an entropic FBA problem to exometabolomic data, with one of three
%       weighting schemes, and relaxes the bounds of the fitted reactions. Quarantined: no
%       behaviour of addExoMetToEFBA is asserted until the defect below is fixed.
%
% Function under test:
%     src/base/solvers/entropicFBA/addExoMetToEFBA.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation on a createModel toy model, no solver.
%
% Coverage exemptions:
%     every line - addExoMetToEFBA is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Data for a reaction not in the model, or duplicate data, stop with an error
%       SEVERITY: error
%       TRIGGER: addExoMetToEFBA(model, exoMet) with exoMet.rxns = {'EX_a'; 'EX_zz'} where
%         EX_zz is not in model.rxns (or with exoMet.rxns = {'EX_a'; 'EX_a'})
%       OBSERVED: error "Unrecognized function or variable 'printLevel'." - lines 69 and 75
%         read the undefined variable printLevel instead of param.printLevel
%       EXPECTED: the unmatched (or duplicate) entries ignored and the penalty built from the
%         matched data, as the help text says (exoMet.rxns "matched against model.rxns") and
%         as lines 68-77 and 82 intend
%       LINES: 69, 75
%     - DEFECT: The default relaxBounds reads model fields that are not documented as required
%       SEVERITY: error
%       TRIGGER: model = struct('S', [1 -1 0; 0 1 -1], 'rxns', {{'EX_a'; 'R1'; 'EX_b'}})
%         (the documented fields; also with model.lb and model.ub added); exoMet =
%         struct('rxns', {{'EX_a'}}, 'mean', -1, 'SD', 0.1); addExoMetToEFBA(model, exoMet)
%       OBSERVED: (R2025a, 2026-11-17) Unrecognized field name "lb_preconstrainRxns". (line
%         123); lines 123-124 read model.lb_preconstrainRxns and model.ub_preconstrainRxns,
%         which only metabolomicsTomodel sets; with param.relaxBounds = 0 the same call returns
%         h = [-1; NaN; NaN] and diag(H) = [5000; 0; 0]
%       EXPECTED: the documented call (model with .S and .rxns, default param) returns the model
%         with .H, .h and the relaxed bounds, or INPUTS list .lb_preconstrainRxns and
%         .ub_preconstrainRxns as required while relaxBounds is true
%       LINES: 121-124
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddExoMetToEFBA'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
