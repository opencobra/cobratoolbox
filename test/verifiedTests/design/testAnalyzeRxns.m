% The COBRAToolbox: testAnalyzeRxns.m
%
% Purpose:
%     - analyzeRxns lists the reactions used by the strains that produce a given product, and how many producing strains use each reaction.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/design/analyzeRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found. Console noise: the function shows a progress bar (showprogress); it is not suppressed (Constitution VII-A).
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAnalyzeRxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% three strains: the text lists the products of the strain, the cell lists its reactions
listProducts = {'ac, et'; 'et'; 'ac'};
listReactions = {{'R1', 'R2'}; {'R3'}; {'R1', 'R4'}};

%% a product made by strains 1 and 3 ("ac" at the start of the product text)

[allReactions, reactionCount] = analyzeRxns('ac', listProducts, listReactions);
% reactions of the producing strains, each listed once with the number of strains using it
assert(isequal(allReactions, {'R1', 'R2', 'R4'}));
assert(isequal(reactionCount, [2 1 1]));

%% a reaction used more than once is counted every time it appears

[allReactions, reactionCount] = analyzeRxns('et', {'et'; 'et'; 'et'}, {{'R1', 'R1', 'R2'}; {'R2'}; {'R1'}});
assert(isequal(allReactions, {'R1', 'R2'}));
assert(isequal(reactionCount, [3 2]));

%% only strains whose product text starts with the product are used

[allReactions, reactionCount] = analyzeRxns('et', {'ac, et'; 'et'}, {{'R1', 'R2'}; {'R2'}});
% only the second strain starts with "et"
assert(isequal(allReactions, {'R2'}));
assert(isequal(reactionCount, 1));

%% a product that no strain makes gives empty results

[allReactions, reactionCount] = analyzeRxns('zz', listProducts, listReactions);
assert(isempty(allReactions) && isempty(reactionCount));

% change the directory
cd(currentDir)
