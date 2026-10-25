% The COBRAToolbox: testUpdateObj.m
%
% Purpose:
%     - updateObj returns the linearised objective coefficients [-x_bar; slope] used in the next iteration of the sparse-LP (cardinality) algorithm, for each supported approximation function.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/cardOpt/sparseLP/updateObj.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testUpdateObj'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% parameters shared by all approximations, and a test vector that falls into the three
% pieces of the SCAD function (|x| <= 1/theta, 1/theta < |x| < alpha/theta, |x| >= alpha/theta)
x = [0.25; 1; -2];
theta = 2;        % steepness
pNeg = -1;        % exponent of the 'lp-' approximation
pPos = 2;         % exponent of the 'lp+' approximation
epsilonP = 0.1;   % offset of the 'lp+' approximation
alpha = 3;        % SCAD parameter

% tolerance for floating-point comparisons: elementary functions of three numbers, so
% rounding is far below 1e-12; expected vectors were worked out from the published formulas
tol = 1e-12;

% the result has 2n entries: the first n are -x_bar (the gradient part, one per entry of x)
% and the last n are the constant slope of the approximation

c = updateObj(x, theta, pNeg, pPos, epsilonP, alpha, 'cappedL1');
assert(norm(c - [-0.0; -2.0; 2.0; 2.0; 2.0; 2.0]) < tol);

c = updateObj(x, theta, pNeg, pPos, epsilonP, alpha, 'exp');
assert(norm(c - [-0.7869386805747332; -1.7293294335267746; 1.9633687222225316; 2.0; 2.0; 2.0]) < tol);

c = updateObj(x, theta, pNeg, pPos, epsilonP, alpha, 'log');
assert(norm(c - [-0.6068261510845583; -1.2136523021691166; 1.4563827626029398; 1.8204784532536746; 1.8204784532536746; 1.8204784532536746]) < tol);

c = updateObj(x, theta, pNeg, pPos, epsilonP, alpha, 'SCAD');
assert(norm(c - [0.0; -1.5; 1.0; 1.0; 1.0; 1.0]) < tol);

c = updateObj(x, theta, pNeg, pPos, epsilonP, alpha, 'lp-');
assert(norm(c - [-1.1111111111111112; -1.7777777777777777; 1.92; 2.0; 2.0; 2.0]) < tol);

c = updateObj(x, theta, pNeg, pPos, epsilonP, alpha, 'lp+');
assert(norm(c - [0.12499999999999999; 0.5; -1.0; 0.05; 0.05; 0.05]) < tol);

c = updateObj(x, theta, pNeg, pPos, epsilonP, alpha, 'l1');
assert(norm(c - [0.0; 0.0; 0.0; 1.0; 1.0; 1.0]) < tol);

%% an unknown approximation is rejected

assert(verifyCobraFunctionError('updateObj', 'inputs', {x, theta, pNeg, pPos, epsilonP, alpha, 'unknown'}, ...
    'testMessage', 'Approximation is not valid'));

% change the directory
cd(currentDir)
