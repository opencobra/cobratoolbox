% The COBRAToolbox: testCalculateEPSILON.m
%
% Purpose:
%     - calculateEPSILON gives, for each reaction (row of a matrix of sampled fluxes, one
%       column per sample), the smallest flux change counted as significant by rMTA:
%       epsilon = tinv(0.95, n - 1) * std(row) / sqrt(n), raised to 'minimum' and set to 0
%       for reactions with rxnFBS == 0, or (option 'unique_epsilon') one common value, the
%       epsilon below which 70% of the changed reactions lie. This test checks both modes,
%       the 'minimum' option, case-insensitive option names and the input errors.
%     - Expected values are derived by hand: row standard deviations of small integer
%       samples (sqrt(5/3), sqrt(1/3), 0, sqrt(20/3)) and the Student t quantile
%       tinv(0.95, 3) = 2.3533634348018264 (SciPy stats.t.ppf(0.95, 3); standard t tables
%       give 2.353).
%
% Function under test:
%     src/analysis/rMTA/calculateEPSILON.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built matrices.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: 'unique_epsilon' stops with an error when no reaction changes
%       SEVERITY: limitation
%       TRIGGER: calculateEPSILON([1 2 3 4; 0 0 1 1], [0; 0], 'unique_epsilon', true)
%       OBSERVED: error 'Array indices must be positive integers or logical values.'
%         (calculateEPSILON:51): int64(0 * 0.7) = 0 is used as an index
%       EXPECTED: epsilon = [0; 0] (no reaction is changed)
%       LINES: 51
%     - DEFECT: The documented codes of rxnFBS do not match the code
%       SEVERITY: cosmetic
%       TRIGGER: reading the help of calculateEPSILON
%       OBSERVED: the help lists "Forward, Backward and Unchanged (+1;0;-1)", i.e. 0 for a
%         backward change, while the code (and rMTA) treat rxnFBS == 0 as unchanged and -1 as
%         backward
%       EXPECTED: Forward, Backward and Unchanged (+1;-1;0)
%       LINES: 15-17
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalculateEPSILON'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% four reactions, four samples each; row standard deviations sqrt(5/3), sqrt(1/3), 0 and
% sqrt(20/3)
samples = [1 2 3 4; 0 0 1 1; 2 2 2 2; 1 3 5 7];
tQuantile = 2.3533634348018264;
rowStd = sqrt([5/3; 1/3; 0; 20/3]);
rawEpsilon = tQuantile * rowStd / sqrt(4);
% the t quantile comes from cobraTinv (numerical inversion), so values agree to rounding;
% 1e-10 is far below the smallest difference between the expected values
tol = 1e-10;

%% default: one epsilon per reaction, raised to the minimum 1e-3, 0 where rxnFBS == 0

rxnFBS = [1; 0; -1; 1];
epsilon = calculateEPSILON(samples, rxnFBS);
% reaction 2 is unchanged (0), reaction 3 has zero spread and is raised to 1e-3
assert(isequal(size(epsilon), [4, 1]));
assert(max(abs(epsilon - [rawEpsilon(1); 0; 1e-3; rawEpsilon(4)])) < tol);
% explicit unique_epsilon = false gives the same result
assert(max(abs(calculateEPSILON(samples, rxnFBS, 'unique_epsilon', false) - epsilon)) < tol);

%% option 'minimum' (case-insensitive name): every changed reaction gets at least the minimum

epsilon = calculateEPSILON(samples, rxnFBS, 'Minimum', 2);
% rawEpsilon(1) = 1.519 is raised to 2, rawEpsilon(4) = 3.038 is kept
assert(max(abs(epsilon - [2; 0; 2; rawEpsilon(4)])) < tol);
epsilon = calculateEPSILON(samples, rxnFBS, 'minimum', 0.5);
assert(max(abs(epsilon - [rawEpsilon(1); 0; 0.5; rawEpsilon(4)])) < tol);

%% unique epsilon: the value at position round(0.7 * k) of the k sorted changed epsilons

% all four reactions changed: sorted epsilons [0, 0.679, 1.519, 3.038], position
% round(2.8) = 3 gives rawEpsilon(1) for every reaction (no minimum is applied)
epsilon = calculateEPSILON(samples, [1; 1; -1; 1], 'unique_epsilon', true);
assert(max(abs(epsilon - rawEpsilon(1) * ones(4, 1))) < tol);
% reaction 2 unchanged: sorted [0, 1.519, 3.038], position round(2.1) = 2; 0 for reaction 2
epsilon = calculateEPSILON(samples, rxnFBS, 'UNIQUE_EPSILON', true);
assert(max(abs(epsilon - [rawEpsilon(1); 0; rawEpsilon(1); rawEpsilon(1)])) < tol);
% one changed reaction with zero spread: position round(0.7) = 1 gives 0 for all reactions;
% the minimum is not applied in this mode
epsilon = calculateEPSILON(samples, [0; 0; 1; 0], 'unique_epsilon', true, 'minimum', 1);
assert(isequal(epsilon, zeros(4, 1)));

%% input errors raised by the input parser

% samples and rxnFBS must be numeric, minimum a numeric scalar, options must be known
assert(verifyCobraFunctionError('calculateEPSILON', 'inputs', {'samples', rxnFBS}));
assert(verifyCobraFunctionError('calculateEPSILON', 'inputs', {samples, {1, 0, -1, 1}}));
assert(verifyCobraFunctionError('calculateEPSILON', 'inputs', {samples, rxnFBS, 'minimum', [1 2]}));
assert(verifyCobraFunctionError('calculateEPSILON', 'inputs', {samples, rxnFBS, 'tolerance', 1}));

% change the directory
cd(currentDir)
