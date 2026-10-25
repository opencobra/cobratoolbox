% The COBRAToolbox: testConvertIrrevFluxDistribution.m
%
% Purpose:
%     - convertIrrevFluxDistribution converts a flux distribution of an irreversible (split) model back to the reversible model: a forward and a backward flux are combined into forward minus backward.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/refinement/convertIrrevFluxDistribution.m
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
fileDir = fileparts(which('testConvertIrrevFluxDistribution'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% forward/backward pairs are combined, other fluxes are kept

% reactions 1 and 2 are a forward/backward pair (matchRev points to the partner), 3 and 4 are alone
fluxIrreversible = [5; 2; 3; 4];
matchReverse = [2; 1; 0; 0];
fluxReversible = convertIrrevFluxDistribution(fluxIrreversible, matchReverse);
% 5 - 2 = 3 for the pair, then 3 and 4 unchanged; the result is a column
assert(isequal(fluxReversible, [3; 3; 4]));

%% no pairs: the flux distribution is returned as a column

assert(isequal(convertIrrevFluxDistribution([1; 2], [0; 0]), [1; 2]));

%% only a pair

assert(isequal(convertIrrevFluxDistribution([5; 2], [2; 1]), 3));

% change the directory
cd(currentDir)
