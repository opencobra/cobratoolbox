% The COBRAToolbox: testPreparseGPR.m
%
% Purpose:
%     - preparseGPR normalises gene-reaction rules (brackets to parentheses, and/or to &/|, spacing) and lists the genes of each rule.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/preparseGPR.m
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
fileDir = fileparts(which('testPreparseGPR'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% a cell array of rules

rules = {'(a AND b) OR c'; '[d and e] or {f}'; 'x'};
[preParsedRules, genes] = preparseGPR(rules);
% other brackets become parentheses, AND/OR (any case) become & and |, with single spaces
assert(isequal(preParsedRules, {'(a & b) | c'; '(d & e) | (f)'; 'x'}));
% the genes of each rule are listed as a row (sorted, unique)
assert(isequal(genes{1}, {'a', 'b', 'c'}));
assert(isequal(genes{2}, {'d', 'e', 'f'}));
assert(isequal(genes{3}, {'x'}));

%% a rule given as text

preParsedRule = preparseGPR('a and b or c');
assert(strcmp(preParsedRule, 'a & b | c'));

%% a rule wrapped in a cell inside the cell array is unwrapped

preParsedRules = preparseGPR({{'a or b'}; 'c'});
assert(isequal(preParsedRules, {'a | b'; 'c'}));

%% an entry that is neither text nor a cell -> error

assert(verifyCobraFunctionError('preparseGPR', 'inputs', {{5}}, 'testMessage', 'grRules 1 is not a character array'));

% change the directory
cd(currentDir)
