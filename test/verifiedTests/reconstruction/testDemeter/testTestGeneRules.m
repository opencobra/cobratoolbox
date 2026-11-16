% The COBRAToolbox: testTestGeneRules.m
%
% Purpose:
%     - testGeneRules(model) is a DEMETER test-suite function (its name starts with "test";
%       this file tests it). It returns, as a 1 x k cell array, the indices of the entries
%       of model.rules that verifyRuleSyntax cannot evaluate (rules in computable form
%       x(i) | x(j) & ...); an empty rule counts as correct. With no incorrect rule the
%       output is the empty cell {}.
%     - Expected indices follow by hand from the syntax of each rule.
%
% Function under test:
%     src/reconstruction/demeter/suite/tests/testGeneRules.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a hand-built model structure holding only rules, no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTestGeneRules'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% all rules correct: no index is returned

model = struct();
model.rules = {'x(1) | x(2)'; ''; '(x(1) & x(2)) | x(3)'};
incorrectGeneRules = testGeneRules(model);
assert(iscell(incorrectGeneRules) && isempty(incorrectGeneRules));

%% incorrect rules are listed by their index, in order

% 3: unbalanced parenthesis; 5: a gene name instead of x(i); 6: the word 'and' instead of &
model.rules = {'x(1) | x(2)'; ''; '(x(1) & x(2)'; 'x(3)'; 'gene1'; 'x(1) and x(2)'};
incorrectGeneRules = testGeneRules(model);
assert(isequal(incorrectGeneRules, {3, 5, 6}));

%% a model without reactions has no incorrect rule

model.rules = cell(0, 1);
incorrectGeneRules = testGeneRules(model);
assert(iscell(incorrectGeneRules) && isempty(incorrectGeneRules));

% change the directory
cd(currentDir)
