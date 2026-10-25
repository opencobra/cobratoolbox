% The COBRAToolbox: testPrintHyperlink.m
%
% Purpose:
%     - printHyperlink builds (and by default prints) a clickable MATLAB command-window link <a
%     href="matlab: command">word</a>, with the word padded to a minimum width.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/exploration/surfNetSubfunctions/printHyperlink.m
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
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintHyperlink'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% link text, default width, no printing

link = printHyperlink('disp(1)', 'word', [], false);
assert(strcmp(link, '<a href="matlab: disp(1)">word</a>'));
% a width of 0 does not pad either
assert(strcmp(printHyperlink('disp(1)', 'word', 0, false), link));

%% the word is right-aligned in a minimum width

assert(strcmp(printHyperlink('cmd', 'word', 8, false), '<a href="matlab: cmd">    word</a>'));
% a word longer than the width is not cut
assert(strcmp(printHyperlink('cmd', 'word', 2, false), '<a href="matlab: cmd">word</a>'));

%% by default the link is printed to the command window and returned

printedText = evalc('returnedLink = printHyperlink(''cmd'', ''w'');');
assert(strcmp(printedText, '<a href="matlab: cmd">w</a>'));
assert(strcmp(returnedLink, '<a href="matlab: cmd">w</a>'));

% change the directory
cd(currentDir)
