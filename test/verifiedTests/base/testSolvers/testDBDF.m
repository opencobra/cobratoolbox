% The COBRAToolbox: testDBDF.m
%
% Purpose:
%     - DBDF (double backtracking derivative-free algorithm, Algorithm 3 of Aragon Artacho and
%       Fleming 2015) minimises psi(x) = 1/2 ||f(x)||^2 for a duplomonotone mapping f given as
%       a function handle, with a backtracking line search that also reduces alpha. The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       the documented option flag_psi_error stops with an error and the documented error
%       history x_error is misaligned, so no assertion about the function is made.
%
% Function under test:
%     src/base/solvers/varKin/derFreeMethods/DBDF.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no COBRA model and no COBRA solver; a test would use a hand-built two-reaction
%     kinetic model (F = eye(2), R = [0 1; 1 0], kin = 0).
%
% Coverage exemptions:
%     every line - DBDF is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The option flag_psi_error cannot be used
%       SEVERITY: unusable-option
%       TRIGGER: options.flag_psi_error = 1 with options.psi_opt = 0, for example with
%         F = [1 0; 0 1], R = [0 1; 1 0], kin = zeros(4, 1), x0 = [0.5; -0.3] and
%         mapp = @(x) [F - R, R - F] * exp(kin + [F, R]' * x)
%       OBSERVED: the first iteration stops with "Unrecognized function or variable 'psi_opt'."
%         (MATLAB:UndefinedFunction, line 159; R2025a, 2026-11-15); options.psi_opt is never
%         read and psi0 is never set
%       EXPECTED: out.psi_error, the relative error (psi_k - psi_opt)/(psi_0 - psi_opt) of each
%         iteration
%       LINES: 93-95, 158-160, 190-192
%     - DEFECT: x_error and Time have a spurious zero in position 2
%       SEVERITY: wrong-result
%       TRIGGER: options.flag_x_error = 1, options.x_opt = [1; 1], options.flag_time = 1,
%         options.MaxNumIter = 3, options.Stopping_Crit = 2 (same model as above)
%       OBSERVED: (R2025a, 2026-11-15) out.Niter = 3, out.x_error = [0.9849 0 0.9016 0.9]
%         and out.Time = [0 0 0.000214 0.00115]: Niter starts at 1 and is incremented before
%         x_error(Niter + 1) and Time(Niter + 1) are written, so element 2 is never assigned
%       EXPECTED: one entry per point (x0 and each iterate), x_error(k) the relative error of
%         the k-th point
%       LINES: 149-156, 187-189, 193-195
%     - DEFECT: The display format is switched to longG and the status is printed
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: format longG at the start changes the display format of the session after the
%         call, and the line Status without semicolon prints the termination reason
%       EXPECTED: the display format left unchanged and output gated by a print level
%       LINES: 55, 176
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDBDF'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
