% The COBRAToolbox: testFindRxnsInActiveWithGenes.m
%
% Purpose:
%     - findRxnsInActiveWithGenes lists the reactions whose gene-reaction rule is false when the
%     given genes are absent and all other genes are present, so that the genes show evidence of the
%     reaction being off; reactions without a rule are ignored.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/exploration/findRxnsInActiveWithGenes.m
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
fileDir = fileparts(which('testFindRxnsInActiveWithGenes'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% four reactions; the rules are evaluated on a vector x with one entry per model gene
model.genes = {'g1'; 'g2'; 'g3'};
model.rxns = {'a'; 'b'; 'c'; 'd'};
model.rules = {'x(1) & x(2)'; 'x(1) | x(3)'; ''; '~x(2)'};

%% absent genes that switch an AND rule off

% g1 and g2 absent (g3 present): a is false, b (g1 | g3) is true, d (~g2) is true
reactions = findRxnsInActiveWithGenes(model, {'g1', 'g2'});
assert(isequal(reactions, {'a'}));

%% a single absent gene

% g3 absent (g1 and g2 present): a and b are true, d (~g2) is false
reactions = findRxnsInActiveWithGenes(model, {'g3'});
assert(isequal(reactions, {'d'}));

%% genes that are not in the model are ignored

reactions = findRxnsInActiveWithGenes(model, {'g3', 'notAGene'});
assert(isequal(reactions, {'d'}));

%% no absent genes: every gene is present, so only the negated rule is off

% with x all ones the rule ~x(2) of d is false, the others are true
reactions = findRxnsInActiveWithGenes(model, {});
assert(isequal(reactions, {'d'}));

% change the directory
cd(currentDir)
