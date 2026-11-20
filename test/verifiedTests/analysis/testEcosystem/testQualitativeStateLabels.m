% The COBRAToolbox: testQualitativeStateLabels.m
%
% Purpose:
%     - qualitativeStateLabels(qualStates) converts qualitative flux state codes into their
%       labels (-3 '-', -2 '--', -1 '-0', 0 '0', 1 '0+', 2 '++', 3 '+', 4 '-+', 5 'err',
%       100 'var', NaN 'NaN'), keeping the size of the input. This test checks the documented
%       example, every code of the documented table, the shape of matrix and empty inputs, the
%       label of a number that is not a code (characterised: 'NaN', the label every entry
%       starts with), and the documented error.
%
% Function under test:
%     src/analysis/ecosystem/qualitativeStateLabels.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built codes.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testQualitativeStateLabels'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% documented example (labels are text: exact comparisons throughout)

assert(isequal(qualitativeStateLabels([-1 0 4 NaN]), {'-0', '0', '-+', 'NaN'}));

%% every code of the documented table, as a column

codes = [-3; -2; -1; 0; 1; 2; 3; 4; 5; 100; NaN];
expected = {'-'; '--'; '-0'; '0'; '0+'; '++'; '+'; '-+'; 'err'; 'var'; 'NaN'};
assert(isequal(qualitativeStateLabels(codes), expected));

%% the size of the input is kept: matrix and empty input

labels = qualitativeStateLabels([2 3; 100 -3; NaN 5]);
assert(isequal(labels, {'++', '+'; 'var', '-'; 'NaN', 'err'}));
labels = qualitativeStateLabels(zeros(0, 3));
assert(iscell(labels) && isequal(size(labels), [0, 3]));

%% a number that is not a state code keeps the initial label 'NaN'

assert(isequal(qualitativeStateLabels([6 0.5 -4]), {'NaN', 'NaN', 'NaN'}));

%% errors: missing or non-numeric input

message = 'qualStates must be a numeric array.';
assert(verifyCobraFunctionError('qualitativeStateLabels', 'testMessage', message));
assert(verifyCobraFunctionError('qualitativeStateLabels', 'inputs', {{-1, 0}}, 'testMessage', message));
assert(verifyCobraFunctionError('qualitativeStateLabels', 'inputs', {'0'}, 'testMessage', message));

% change the directory
cd(currentDir)
