% The COBRAToolbox: testRemoveDuplicateNames.m
%
% Purpose:
%     - removeDuplicateNames removes repeated parts from names written as "part1|part2|..." and orders the remaining parts from shortest to longest.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/removeDuplicateNames.m
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
fileDir = fileparts(which('testRemoveDuplicateNames'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% repeated parts are removed and parts are ordered by length

infoList = {'a|b|a'; 'xx|y|xx|y'; 'single'; 'bbb|a'; 'long|s|long'};
cleaned = removeDuplicateNames(infoList);
assert(isequal(cleaned, {'a|b'; 'y|xx'; 'single'; 'a|bbb'; 's|long'}));

%% an empty name stays empty

cleaned = removeDuplicateNames({''});
assert(isempty(cleaned{1}));

% change the directory
cd(currentDir)
