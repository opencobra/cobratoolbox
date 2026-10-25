% The COBRAToolbox: testColText.m
%
% Purpose:
%     - colText wraps a text in HTML that displays it in a given colour.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/colText.m
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
fileDir = fileparts(which('testColText'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% html wrapper

assert(strcmp(colText('abc', 'red'), '<html><font color="red">abc</font></html>'));

%% empty text and a colour code

assert(strcmp(colText('', '#00FF00'), '<html><font color="#00FF00"></font></html>'));

% change the directory
cd(currentDir)
