% The COBRAToolbox: testLiftRows.m
%
% Purpose:
%     - liftRows is the helper of liftCouplingConstraints that replaces each coupling row with a
%       coefficient of magnitude >= BIG by a chain of dum dummy variables and rows whose
%       coefficients are all stp = qty^(1/(dum+1)), with dum = max(floor(log(qty)/log(BIG)), 1),
%       and names the new rows and variables LIFT<k>_<id>. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): a matrix without a large
%       coefficient stops with an error when outputs are requested, so no assertion about the
%       function is made.
%
% Function under test:
%     src/base/solvers/rescale/liftRows.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built coupling rows such as
%     [1 -1e6] with BIG = 1000 (expected lifted matrix [1 0 -100 0; 0 0 1 -100; 0 -100 0 1]).
%
% Coverage exemptions:
%     every line - liftRows is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A well-scaled matrix stops with an error instead of being returned
%       SEVERITY: error
%       TRIGGER: [Clifted, newcon] = liftRows([1 -1], 'L', 1000, log(1000), 0, {'c1'}, {'r1'; 'r2'})
%       OBSERVED: the function prints "Model.C is well scaled. Nothing to do." and returns
%         before any output is set, so the call stops with Output argument "Clifted" (and
%         possibly others) not assigned a value (MATLAB:unassignedOutputs; R2025a, 2026-11-15).
%         liftCouplingConstraints(model, 1000, 0) with model.C = [1, -10], model.d = 0,
%         model.dsense = 'L' stops with the same error at its line 386
%       EXPECTED: C returned unchanged with no new rows or variables (newcon, ctrs_new and evars
%         empty, ndum = nEvars = 0), as the printed message says there is nothing to do
%       LINES: 44-47
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLiftRows'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
