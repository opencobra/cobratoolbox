% The COBRAToolbox: testLsqr.m
%
% Purpose:
%     - lsqr(m, n, aprodname, b, damp, atol, btol, conlim, itnlim, show, covindex, userstop)
%       is the toolbox copy of M. A. Saunders' LSQR: it solves A*x = b, min ||b - A*x|| or the
%       damped problem for an m x n matrix A given as a function handle
%       aprodname(mode, m, n, x). This file tests the TOOLBOX file
%       src/analysis/subspaces/lsqr/lsqr.m, which shadows MATLAB's own lsqr
%       (toolbox/matlab/sparfun/lsqr.m, signature lsqr(A, b, ...)) once the COBRA Toolbox is on
%       the path (which('-all', 'lsqr') lists the toolbox file first). The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): when A'*b = 0
%       (b = 0, or b orthogonal to the range of A) it returns before r1norm and r2norm are set,
%       so a call that asks for four or more outputs raises an error; no assertion about the
%       function is made.
%
% Function under test:
%     src/analysis/subspaces/lsqr/lsqr.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would pass a hand-built matrix through an anonymous
%     aprod handle.
%
% Coverage exemptions:
%     every line - lsqr is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: r1norm and r2norm are not assigned when A'*b = 0
%       SEVERITY: error
%       TRIGGER: aprod = @(mode, m, n, x) lsqraprod(mode, m, n, x, 0, 0); [x, istop, itn, r1norm] = lsqr(4, 3, aprod, zeros(4, 1), 0, 1e-12, 1e-12, 1e8, 10, 0)
%       OBSERVED: 'Output argument "r1norm" (and possibly others) not assigned a value in the
%         execution with "lsqr" function.' (R2025a, 2026-11-15; also with A = [1 0; 0 2; 0 0] and
%         b = [0; 0; 5], which is orthogonal to range(A)); the early return of line 143
%         (arnorm = alfa*beta = 0) comes before r1norm and r2norm are set on lines 147-148.
%         With two outputs the call returns x = 0, istop = 0.
%       EXPECTED: x = 0 (the documented message "The exact solution is x = 0" for b = 0, and
%         the least-squares solution for b orthogonal to range(A)) with r1norm = norm(b),
%         r2norm = r1norm, as OUTPUTS document
%       LINES: 143, 147-148
%     - DEFECT: The x = 0 message is printed even when show = 0
%       SEVERITY: cosmetic
%       TRIGGER: x = lsqr(4, 3, aprod, zeros(4, 1), 0, 1e-12, 1e-12, 1e8, 10, 0) with the aprod above
%       OBSERVED: 'The exact solution is  x = 0' printed (disp without the show test)
%       EXPECTED: no output when show = 0 ("0 - suppresses output")
%       LINES: 143
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLsqr'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
