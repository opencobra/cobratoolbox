% The COBRAToolbox: testVerifyRuleSyntax.m
%
% Purpose:
%     - Characterization test that PINS the current behaviour of verifyRuleSyntax,
%       which reports whether a gene-reaction rule string (already converted to
%       MATLAB form, e.g. '(x(1) | x(2)) & x(3)') is syntactically valid by
%       evaluating it. The function previously had no test (feature
%       025-tier1-test-pilot). It asserts EXISTING behaviour (Constitution
%       Principle III, characterization mode) and must not change verifyRuleSyntax.
%
% Function under test:
%     src/reconstruction/modelGeneration/modelVerification/verifyRuleSyntax.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-written rule strings. Never
%     skipped.
%
% Persistent state:
%     verifyRuleSyntax keeps a persistent logical vector x (10000 entries) that the
%     rules are evaluated against, and regrows it when a rule uses a larger index.
%     To make every case independent of the order of the cases, the function is
%     cleared (clear verifyRuleSyntax) before each call.
%
% Coverage exemptions:
%     None. Every executable line of verifyRuleSyntax is reached below, including
%     the regrow-and-retry branch.
%
% Authors:
%     - Generated for feature 025-tier1-test-pilot, 2026-10-06.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testVerifyRuleSyntax'));
cd(fileDir);

%% an empty rule is valid

clear verifyRuleSyntax;
assert(verifyRuleSyntax('') == true);

%% valid rules evaluate without error

% a combination of OR and AND with parentheses
clear verifyRuleSyntax;
assert(verifyRuleSyntax('(x(1) | x(2)) & x(3)') == true);

% a single gene
clear verifyRuleSyntax;
assert(verifyRuleSyntax('x(5)') == true);

%% invalid rules are reported as false

% '&&&' is not a MATLAB operator (the first evaluation fails, the retry fails too)
clear verifyRuleSyntax;
assert(verifyRuleSyntax('x(1) &&& x(2)') == false);

% an unbalanced parenthesis: the retry regrows x using the digit found in the rule
% ('1') but the rule is still not valid MATLAB, so the retry fails as well
clear verifyRuleSyntax;
assert(verifyRuleSyntax('1 & (') == false);

%% an index beyond the initial capacity triggers the regrow-and-retry branch

% x starts with 10000 entries, so x(20000) fails the first evaluation. The function
% then reads the largest index in the rule, regrows x to that size and evaluates
% again, which succeeds -> the rule is valid.
clear verifyRuleSyntax;
assert(verifyRuleSyntax('x(20000) | x(1)') == true);

%% results do not depend on the order of the cases

% after the large rule above (x has now grown) a small rule is still valid
assert(verifyRuleSyntax('x(1) & x(2)') == true);
% and an invalid rule is still invalid
assert(verifyRuleSyntax('x(1) &&& x(2)') == false);

% leave no persistent state behind for other tests
clear verifyRuleSyntax;

% change the directory
cd(currentDir)
