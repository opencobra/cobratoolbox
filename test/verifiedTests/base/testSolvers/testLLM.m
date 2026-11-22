% The COBRAToolbox: testLLM.m
%
% Purpose:
%     - LLM solves a system of nonlinear equations h(x) = 0 by minimising psi(x) = 1/2
%       ||h(x)||^2 with the local Levenberg-Marquardt method: one step dk = -(J*J + mu_k*I) \
%       grad per iteration, mu_k = max(lambda*||h||^eta + (1 - lambda)*||grad||^eta, 1e-8). It
%       is called by optimizeVKmodel0, whose test (testOptimizeVKmodel0) runs it on a kinetic
%       model of ecoli_core_model. The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): the documented option flag_psi_error stops with an
%       error and the documented error history x_error (and Time) is misaligned, so no assertion
%       about the function is made. Without these options it converges on the hand-built model
%       of the defects below (Status "a solution is found.", Niter = 5, Nmap = 5, psi_best =
%       5.5e-21; R2025a, 2026-11-15).
%
% Function under test:
%     src/base/solvers/varKin/levMarMethods/LLM.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no COBRA model and no COBRA solver; a test would use a hand-built two-reaction
%     kinetic model (F = eye(2), R = [0 1; 1 0], kin = 0) and the toolbox's own iterations.
%
% Coverage exemptions:
%     every line - LLM is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The option flag_psi_error cannot be used
%       SEVERITY: unusable-option
%       TRIGGER: options.flag_psi_error = 1 with options.psi_opt = 0, for example with
%         F = [1 0; 0 1], R = [0 1; 1 0], opt = struct('FR', [F, R], 'FR_RF', [F - R, R - F],
%         'k', zeros(4, 1)), mapp = @(varargin) Rate_function1(opt, varargin{:}),
%         lin_sym_solver = @(varargin) lin_sym_solver_mldivide(varargin{:}), x0 = [0.5; -0.3],
%         options = struct('MaxNumIter', 50, 'lambda', 1, 'xi_k', 1, 'adaptive', 0)
%       OBSERVED: the first iteration stops with "Unrecognized function or variable 'psi_opt'."
%         (MATLAB:UndefinedFunction, line 183; R2025a, 2026-11-15); options.psi_opt is never
%         read and psi0 is never set
%       EXPECTED: out.psi_error, the relative error (psi_k - psi_opt)/(psi_0 - psi_opt) of each
%         iteration
%       LINES: 109-111, 182-184, 216-218
%     - DEFECT: x_error and Time have a spurious zero in position 2
%       SEVERITY: wrong-result
%       TRIGGER: options.flag_x_error = 1, options.x_opt = [1; 1], options.flag_time = 1,
%         options.MaxNumIter = 4, options.Stopping_Crit = 3 (same model and start as above)
%       OBSERVED: out.Niter = 4, out.x_error = [0.9849 0 1.02 1.024 1.024] and
%         out.Time = [0 0 4.9e-05 0.00212 0.00262]: Niter starts at 1 and is incremented before
%         x_error(Niter + 1) and Time(Niter + 1) are written, so element 2 is never assigned
%         and the vectors hold one entry more than the points x0, x_2, ..., x_Niter
%       EXPECTED: one entry per point (x0 and each iterate), x_error(k) the relative error of
%         the k-th point and Time(k) its time
%       LINES: 120, 153, 173-180
%     - DEFECT: The display format is switched to longG and the status is printed
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: format longG at the start changes the display format of the session after the
%         call, and the line Status without semicolon prints the termination reason
%       EXPECTED: the display format left unchanged and output gated by a print level
%       LINES: 61, 201
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLLM'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
