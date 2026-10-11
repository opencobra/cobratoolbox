% The COBRAToolbox: testHyperlink.m
%
% Purpose:
%     - hyperlink returns a clickable HTML link when MATLAB runs with its desktop, and plain text (optionally with surrounding text) otherwise.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/hyperlink.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 29 of hyperlink.m (the HTML link) is only reached when MATLAB runs with its desktop (usejava("desktop") true). On headless/CI runs (matlab -batch) it is uncovered; the test adapts its expectation to the environment so it passes in both.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testHyperlink'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

url = 'http://example.org';
withDesktop = usejava('desktop');

%% link text defaults to the URL

linkDefault = hyperlink(url);
if withDesktop
    assert(strcmp(linkDefault, ['<a href="' url '">' url '</a>']));
else
    assert(strcmp(linkDefault, url));
end

%% explicit link text

linkWithText = hyperlink(url, 'the site');
if withDesktop
    assert(strcmp(linkWithText, ['<a href="' url '">the site</a>']));
else
    assert(strcmp(linkWithText, url));
end

%% surrounding text (used only when no HTML is available)

linkWithSurroundings = hyperlink(url, 'the site', '[', ']');
if withDesktop
    assert(strcmp(linkWithSurroundings, ['<a href="' url '">the site</a>']));
else
    % text before and after the URL, e.g. brackets, is added to the plain URL
    assert(strcmp(linkWithSurroundings, ['[' url ']']));
end

% only the text before the URL
linkWithPrefix = hyperlink(url, 'the site', '[');
if ~withDesktop
    assert(strcmp(linkWithPrefix, ['[' url]));
end

% change the directory
cd(currentDir)
