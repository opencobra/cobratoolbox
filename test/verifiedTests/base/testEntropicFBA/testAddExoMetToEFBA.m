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
