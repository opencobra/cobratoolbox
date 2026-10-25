% The COBRAToolbox: testGPRparser.m
%
% Purpose:
%     - GPRparser parses the gene-reaction rules of a model into sets of genes (the alternatives of
%     the rule), optionally in conjunctive normal form; reactions without a rule get an empty entry.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/transcriptomics/preprocessing/GPRparser.m
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
fileDir = fileparts(which('testGPRparser'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.rxns = {'r1'; 'r2'; 'r3'};
model.genes = {'g1'; 'g2'; 'g3'};
model.rules = {'x(1) & x(2)'; 'x(1) | x(3)'; ''};

%% sets of genes of each rule

parsedGPR = GPRparser(model);
assert(isequal(size(parsedGPR), [3 1]));
% an and-rule is one set of two genes
assert(isequal(parsedGPR{1}, {{'g1'; 'g2'}}));
% an or-rule gives one set per alternative
assert(isequal(parsedGPR{2}, {{'g1'}, {'g3'}}));
% a reaction without a rule
assert(isequal(parsedGPR{3}, {''}));

%% conjunctive normal form

parsedCNF = GPRparser(model, true);
assert(isequal(size(parsedCNF), [3 1]));
% the and-rule gives one set per gene, the or-rule one set holding both genes
assert(isequal(parsedCNF{1}, {{'g1'}, {'g2'}}));
assert(isequal(parsedCNF{2}, {{'g1'; 'g3'}}));
assert(isequal(parsedCNF{3}, {''}));

% change the directory
cd(currentDir)
