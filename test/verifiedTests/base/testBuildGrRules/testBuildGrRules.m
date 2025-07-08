% The COBRAToolbox: testBuildGrRules.m
%
% Purpose:
%     - Test the buildGrRules function to ensure it correctly reconstructs
%       GPR rules from the parsed cell array format.
%
% Authors:
%     - Initial version: Farid Zare, April 2025
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

fprintf('Done\n');

% Change back to the original directory
cd(currentDir);
