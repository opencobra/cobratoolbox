% The COBRAToolbox: testFindRxnsActiveWithGenes.m
%
% Purpose:
%     - findRxnsActiveWithGenes lists the reactions whose gene-reaction rule evaluates to true when
%     the given genes are present and all other genes are absent; reactions without a rule are
%     ignored.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/exploration/findRxnsActiveWithGenes.m
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
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindRxnsActiveWithGenes'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% four reactions; the rules are evaluated on a vector x with one entry per model gene
model.genes = {'g1'; 'g2'; 'g3'};
model.rxns = {'a'; 'b'; 'c'; 'd'};
model.rules = {'x(1) & x(2)'; 'x(1) | x(3)'; ''; '~x(2)'};

%% genes that satisfy an AND rule and an OR rule

% g1 and g2 present: a (g1 & g2) and b (g1 | g3) are true; d (~g2) is false; c has no rule
reactions = findRxnsActiveWithGenes(model, {'g1', 'g2'});
assert(isequal(reactions, {'a', 'b'}));

%% a single gene

% only g3 present: a is false, b is true, d (not g2) is true
reactions = findRxnsActiveWithGenes(model, {'g3'});
assert(isequal(reactions, {'b', 'd'}));

%% genes that are not in the model are ignored

reactions = findRxnsActiveWithGenes(model, {'g3', 'notAGene'});
assert(isequal(reactions, {'b', 'd'}));

%% no genes: only rules that are true when all genes are absent

reactions = findRxnsActiveWithGenes(model, {});
assert(isequal(reactions, {'d'}));

% change the directory
cd(currentDir)
