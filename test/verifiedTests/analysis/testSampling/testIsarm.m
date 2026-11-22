% The COBRAToolbox: testIsarm.m
%
% Purpose:
%     - isarm returns true when MATLAB runs on an Apple silicon (ARM) processor and false
%       otherwise: off macOS it returns false without calling any program; on macOS it reads
%       the processor name with 'sysctl -n machdep.cpu.brand_string'. The test checks the
%       result against the operating system and, on macOS, against the architecture that
%       MATLAB reports (computer('arch') is 'maca64' for native Apple silicon MATLAB).
%
% Function under test:
%     src/analysis/sampling/BarrierRound/utils/isarm.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, no input.
%
% Coverage exemptions:
%     Lines 14-15: macOS only (the branch that runs sysctl); the reference machine runs Linux.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIsarm'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% the result is a logical scalar

isArmProcessor = isarm();
assert(islogical(isArmProcessor) && isscalar(isArmProcessor));

%% off macOS the result is false; on native Apple silicon MATLAB it is true

if ~ismac()
    assert(~isArmProcessor);
elseif strcmp(computer('arch'), 'maca64')
    % native Apple silicon MATLAB runs only on an Apple processor
    assert(isArmProcessor);
end

% change the directory
cd(currentDir)
