% The COBRAToolbox: testParseGPR.m
%
% Purpose:
%     - parseGPR converts a gene-reaction rule text (and/or/&/|) into a rule string over the positions of the genes, extending the gene list with new genes.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/parseGPR.m
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
fileDir = fileparts(which('testParseGPR'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% a rule with known and new genes

currentGenes = {'g1'; 'g9'};
[ruleString, totalGeneList, newGeneList] = parseGPR('(g1 and g2) or g3', currentGenes);
% g1 is gene 1; g2 and g3 are new and appended (sorted) after the current genes -> 3 and 4
assert(strcmp(ruleString, '( x(1) & x(3) ) | x(4)'));
assert(isequal(totalGeneList, {'g1'; 'g9'; 'g2'; 'g3'}));
assert(isequal(newGeneList, {'g2'; 'g3'}));

%% a rule with only known genes, repeated genes and upper-case AND

[ruleString, totalGeneList, newGeneList] = parseGPR('g1 AND g1', {'g1'; 'g2'});
assert(strcmp(ruleString, 'x(1) & x(1)'));
assert(isequal(totalGeneList, {'g1'; 'g2'}));
assert(isempty(newGeneList));

[ruleString, ~, newGeneList] = parseGPR('g2 | (g1 & g3)', {'g1'; 'g2'});
assert(strcmp(ruleString, 'x(2) | ( x(1) & x(3) )'));
assert(isequal(newGeneList, {'g3'}));

%% empty rule, or a rule with only brackets: empty rule string, genes unchanged

[ruleString, totalGeneList, newGeneList] = parseGPR('', {'g1'});
assert(isempty(ruleString) && isequal(totalGeneList, {'g1'}) && isempty(newGeneList));
[ruleString, totalGeneList, newGeneList] = parseGPR('( )', {'g1'});
assert(isempty(ruleString) && isequal(totalGeneList, {'g1'}) && isempty(newGeneList));

%% pre-parsed rule with given gene positions

% the genes are looked up in the current list and numbered with the given positions
[ruleString, totalGeneList, newGeneList] = parseGPR('g2 | (g1)', {'g1'; 'g2'}, true, [5; 6]);
assert(strcmp(ruleString, 'x(6) | ( x(5) )'));
assert(isequal(totalGeneList, {'g1'; 'g2'}));
assert(isempty(newGeneList));

% change the directory
cd(currentDir)
