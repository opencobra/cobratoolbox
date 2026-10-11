% The COBRAToolbox: testReaction2sparse.m
%
% Purpose:
%     - reaction2sparse converts a KEGG reaction string (compound IDs C#####) into a sparse stoichiometric row vector indexed by compound number.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/thermo/componentContribution/reaction2sparse.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects / quirks pinned (NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReaction2sparse'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% coefficients with and without an explicit multiplier

% left side: substrates get negative coefficients; right side: products get positive ones.
% 'C00001' has no multiplier (coefficient 1), '2 C00002' has one
reactionVector = reaction2sparse('C00001 + 2 C00002 = C00003');
assert(issparse(reactionVector));
assert(isequal(size(reactionVector), [1 3]));
assert(isequal(full(reactionVector), [-1 -2 1]));

%% the same compound appearing more than once accumulates its coefficients

% C00002 occurs twice as a substrate (-1 and -1); C00001 only appears on the product side
% with coefficient 3, after a larger index was already set
reactionVector = reaction2sparse('C00002 + C00002 = C00003 + 3 C00001');
assert(isequal(full(reactionVector), [3 -2 1]));

%% single substrate and product, no multipliers

% compounds that do not take part get the value 0 (C00002 is skipped)
reactionVector = reaction2sparse('C00003 = C00001');
assert(isequal(full(reactionVector), [1 0 -1]));

% change the directory
cd(currentDir)
