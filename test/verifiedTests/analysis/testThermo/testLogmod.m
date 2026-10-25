% The COBRAToolbox: testLogmod.m
%
% Purpose:
%     - logmod computes the (signed) logarithmic modulus sign(x)*log(1+|x|) in base e, 2 or 10.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/thermo/utilities/logmod.m
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
fileDir = fileparts(which('testLogmod'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons: logarithms of small integers, rounding only
tol = 1e-12;
x = [-2 0 3];

%% signed modulus (default), natural logarithm

assert(norm(logmod(x) - [-log(3), 0, log(4)]) < tol);
% the defaults are base e and signed
assert(isequal(logmod(x), logmod(x, exp(1), 1)));

%% signed modulus in base 2 and base 10

assert(norm(logmod(x, 2) - [-log2(3), 0, log2(4)]) < tol);
assert(norm(logmod(x, 10) - [-log10(3), 0, log10(4)]) < tol);

%% unsigned modulus: log(1+|x|), always non-negative

assert(norm(logmod(x, exp(1), 0) - [log(3), 0, log(4)]) < tol);
assert(norm(logmod(x, 2, 0) - [log2(3), 0, log2(4)]) < tol);
assert(norm(logmod(x, 10, 0) - [log10(3), 0, log10(4)]) < tol);

%% unsupported base -> error (signed and unsigned)

assert(verifyCobraFunctionError('logmod', 'inputs', {x, 3, 1}, 'testMessage', 'base not recognised'));
assert(verifyCobraFunctionError('logmod', 'inputs', {x, 3, 0}, 'testMessage', 'base not recognised'));

% change the directory
cd(currentDir)
