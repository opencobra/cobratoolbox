% The COBRAToolbox: testBuildGrRules.m
%
% Purpose:
%     - Test the buildGrRules function to ensure it correctly reconstructs
%       GPR rules from the parsed cell array format.
%
% Authors:
%     - Initial version: Farid Zare, April 2025
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
% Function under test:
%     src/base/buildGrRules.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Coverage exemptions:
%     Line 71: unreachable. It needs a rule without any term, but a rule whose cells are all empty
%     already returned at line 38, and every other rule keeps at least one non-empty term.
%

global CBTDIR

% Save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));
testPath = pwd;

% Define test cases for parsedGPR:

% Test Case 1: Nested structure with duplicates
% Expected: duplicate genes removed within a complex and duplicate complexes removed.
parsedGPR{1} = { {'geneA', 'geneB', 'geneA'}, {'geneC'}, {'geneA', 'geneB'} };
expectedRule1 = '(geneA and geneB) or (geneC)';

% Test Case 2: Flat structure (non-nested)
parsedGPR{2} = {'geneD', 'geneE', 'geneD'};
expectedRule2 = '(geneD and geneE)';

% Test Case 3: Empty rule
parsedGPR{3} = {};
expectedRule3 = '';

% Test Case 4: Nested structure with an empty complex
% Expected: the empty complex is dropped and the others are kept.
parsedGPR{4} = { {'geneF'}, {}, {'geneG', 'geneH'} };
expectedRule4 = '(geneF) or (geneG and geneH)';

% Run the function under test
fprintf(' -- Running testBuildGrRules: ... ');
rulesOut = buildGrRules(parsedGPR);

% Verify outputs using assert statements
assert(isequal(rulesOut{1}, expectedRule1), ...
    'Test failed: Output for Test Case 1 does not match the expected rule.');
assert(isequal(rulesOut{2}, expectedRule2), ...
    'Test failed: Output for Test Case 2 does not match the expected rule.');
assert(isequal(rulesOut{3}, expectedRule3), ...
    'Test failed: Output for Test Case 3 should be an empty string.');
assert(isequal(rulesOut{4}, expectedRule4), ...
    'Test failed: Output for Test Case 4 does not match the expected rule.');

fprintf('Done\n');

% Change back to the original directory
cd(currentDir);
