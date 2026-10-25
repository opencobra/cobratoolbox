% The COBRAToolbox: testEvalObj.m
%
% Purpose:
%     - evalObj evaluates the value of the sparse-LP (cardinality) approximation objective for a vector x, for each supported approximation function.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/cardOpt/sparseLP/evalObj.m
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
fileDir = fileparts(which('testEvalObj'));
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

% tolerance for floating-point comparisons: sums of three elementary functions, so
% rounding is far below 1e-12; expected values were worked out from the published formulas
tol = 1e-12;

% for each approximation the expected value is the sum over the entries of x of
%   cappedL1: min(1, theta|x|)         exp: 1 - exp(-theta|x|)
%   log: log(1+theta|x|)/log(1+theta)  lp-: 1 - (1+theta|x|)^pNeg
%   lp+: (|x|+epsilonP)^(1/pPos)       l1: |x|
%   SCAD: piecewise (2 theta|x|/(alpha+1); (-theta^2 x^2 + 2 alpha theta |x| - 1)/(alpha^2-1); 1)

obj = evalObj(x, theta, pNeg, pPos, epsilonP, alpha, 'cappedL1');
assert(abs(obj - 2.5) < tol);

obj = evalObj(x, theta, pNeg, pPos, epsilonP, alpha, 'exp');
assert(abs(obj - 2.2398184181620198) < tol);

obj = evalObj(x, theta, pNeg, pPos, epsilonP, alpha, 'log');
assert(abs(obj - 2.8340437671464693) < tol);

obj = evalObj(x, theta, pNeg, pPos, epsilonP, alpha, 'SCAD');
assert(abs(obj - 2.125) < tol);

obj = evalObj(x, theta, pNeg, pPos, epsilonP, alpha, 'lp-');
assert(abs(obj - 1.8000000000000003) < tol);

obj = evalObj(x, theta, pNeg, pPos, epsilonP, alpha, 'lp+');
assert(abs(obj - 3.089554501099057) < tol);

obj = evalObj(x, theta, pNeg, pPos, epsilonP, alpha, 'l1');
assert(abs(obj - 3.25) < tol);

%% an unknown approximation is rejected

assert(verifyCobraFunctionError('evalObj', 'inputs', {x, theta, pNeg, pPos, epsilonP, alpha, 'unknown'}, ...
    'testMessage', 'Approximation is not valid'));

% change the directory
cd(currentDir)
