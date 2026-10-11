% The COBRAToolbox: testMakeColorGradient.m
%
% Purpose:
%     - makeColorGradient returns a list of hexadecimal colours that go in equal steps from one colour to another.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/visualization/maps/ReconMap/makeColorGradient.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     If a colour channel (red, green or blue) is the same in both colours, that channel is set to 0 in every step instead of keeping its value (for example #ff0000 to #ff0000 gives black). Such colour pairs are documented and NOT tested; the pairs below differ in every channel.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMakeColorGradient'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% black to white in 5 steps

gradient = makeColorGradient('#000000', '#ffffff', 5);
% steps of 63.75 per channel, rounded
assert(isequal(string(gradient), ["#000000", "#404040", "#808080", "#bfbfbf", "#ffffff"]));

%% white to black in 3 steps

gradient = makeColorGradient('#ffffff', '#000000', 3);
assert(isequal(string(gradient), ["#ffffff", "#808080", "#000000"]));

%% two colours: the two end colours

gradient = makeColorGradient('#102030', '#304050', 2);
assert(isequal(string(gradient), ["#102030", "#304050"]));

% change the directory
cd(currentDir)
