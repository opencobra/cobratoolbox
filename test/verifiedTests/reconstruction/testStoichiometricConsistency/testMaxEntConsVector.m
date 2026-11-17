% The COBRAToolbox: testMaxEntConsVector.m
%
% Purpose:
%     - maxEntConsVector(SInt, printLevel) computes a maximum entropy conservation vector m of
%       the stoichiometric matrix SInt with pdco: minimise
%       1e-6*sum(m.*log(m) - m) + 0.5*1e-8*norm(m)^2 + 0.5*norm(SInt'*m)^2 subject to m >= 0,
%       and returns bool = m > 0. The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): its hard-coded entropy weight equals pdco's default
%       optimality tolerance, so the returned vector is not the maximum entropy conservation
%       vector the documentation promises; no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/modelGeneration/stoichConsistency/maxEntConsVector.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - convex nonlinear optimisation with pdco; a test would declare
%     prepareTest('requiredSolvers', {'pdco'}) and use hand-built 2-by-1 and 2-by-2 matrices.
%
% Coverage exemptions:
%     every line - maxEntConsVector is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The entropy maximiser is resolved only to the pdco optimality tolerance
%       SEVERITY: wrong-result
%       TRIGGER: [m, bool] = maxEntConsVector(sparse([-1; 1]), 0)
%       OBSERVED: (R2025a, pdco5, 2026-11-17) m = [1.2284; 1.2284]; pdco reports Converged:
%         the entropy term is weighted by alpha = 1e-6, the size of pdco's default OptTol
%         (1e-6), so alpha*log(m) = 2e-7 is accepted as zero. For sparse([1; 1]) m = 4.0e-4
%         per entry where the minimiser is about 6e-6
%       EXPECTED: m = [0.9901; 0.9901], the root of 1e-6*log(x) + 1e-8*x = 0 (stationarity of
%         the objective along the conservation law m(1) = m(2))
%       LINES: 34, 51
%     - DEFECT: printLevel is ignored and pdco always prints its iteration log
%       SEVERITY: cosmetic
%       TRIGGER: maxEntConsVector(sparse([-1; 1]), 0)
%       OBSERVED: (R2025a, pdco5, 2026-11-17) the pdco banner, iteration table and
%         distribution of x are printed although printLevel = 0
%       EXPECTED: no output for printLevel = 0 (options.Print = printLevel - 1 is commented out)
%       LINES: 34
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMaxEntConsVector'));
cd(fileDir);

% the function is quarantined: no requirement is declared and nothing calls it. When the
% defect is fixed, the test declares prepareTest('requiredSolvers', {'pdco'})
prepareTest();

% change the directory
cd(currentDir)
