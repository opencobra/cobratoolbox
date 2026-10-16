% The COBRAToolbox: testSetField.m
%
% Purpose:
%     - setField copies into a template structure the values of the fields (or object properties) of
%     another structure that share a name with a template field.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/sampling/BarrierRound/utils/setField.m
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
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetField'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% only fields present in both structures are copied

template = struct('a', 1, 'b', 2);
result = setField(template, struct('b', 20, 'c', 30));
% a keeps its value, b is overwritten, c is not added
assert(isequal(result, struct('a', 1, 'b', 20)));

%% no common field leaves the template unchanged

result = setField(template, struct('z', 9));
assert(isequal(result, template));

%% properties of an object are copied as well

% a containers.Map has the property Count
map = containers.Map({'k1', 'k2'}, {1, 2});
result = setField(struct('Count', 0, 'other', 5), map);
assert(result.Count == 2 && result.other == 5);

% change the directory
cd(currentDir)
