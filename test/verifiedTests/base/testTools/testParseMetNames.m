% The COBRAToolbox: testParseMetNames.m
%
% Purpose:
%     - parseMetNames splits metabolite names of the form name[c] or name(c) into the base name and the one-character compartment symbol, and returns the unique values of both.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/parseMetNames.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects / quirks pinned (NOT fixed here):
%     None found. (Only a single-character compartment symbol is recognised; longer ones fall through to the last pattern and give an empty compartment, which is documented here as current behaviour.)
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testParseMetNames'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% square-bracket notation

[baseMetNames, compSymbols, uniqueMetNames, uniqueCompSymbols] = parseMetNames({'atp[c]'; 'adp[m]'; 'atp[m]'});
assert(isequal(baseMetNames, {'atp'; 'adp'; 'atp'}));
assert(isequal(compSymbols, {'c'; 'm'; 'm'}));
% unique values are sorted
assert(isequal(uniqueMetNames, {'adp'; 'atp'}));
assert(isequal(uniqueCompSymbols, {'c'; 'm'}));

%% a single name given as text is accepted

[baseMetNames, compSymbols] = parseMetNames('atp[c]');
assert(isequal(baseMetNames, {'atp'}) && isequal(compSymbols, {'c'}));

%% round-bracket notation (used when the square-bracket pattern does not match)

[baseMetNames, compSymbols] = parseMetNames({'atp(c)'; 'adp(m)'});
assert(isequal(baseMetNames, {'atp'; 'adp'}));
assert(isequal(compSymbols, {'c'; 'm'}));

%% names that match neither pattern for every entry: the whole text is the base name

% mixed notations, no brackets, or a compartment symbol longer than one character
[baseMetNames, compSymbols] = parseMetNames({'atp[c]'; 'adp(m)'});
assert(isequal(baseMetNames, {'atp[c]'; 'adp(m)'}));
assert(all(cellfun(@isempty, compSymbols)));

[baseMetNames, compSymbols] = parseMetNames({'atp c'; 'adp'});
assert(isequal(baseMetNames, {'atp c'; 'adp'}));
assert(all(cellfun(@isempty, compSymbols)));

% change the directory
cd(currentDir)
