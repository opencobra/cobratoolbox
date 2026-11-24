% The COBRAToolbox: testFindGenesFromRxns.m
%
% Purpose:
%     - findGenesFromRxns returns, for each given reaction, the genes linked to it in
%       rxnGeneMat (built from the rules when absent), as a column cell array with one cell of
%       gene names per reaction found in the model; reactions not in the model are reported
%       on the console and dropped. This test checks a hand-built model with single-gene, AND
%       and OR rules, a reaction without genes, a missing reaction, a character input, a given
%       rxnGeneMat, and gene names that are prefixes of others (g1 and g10). Expected lists
%       are written by hand from the rules.
%
% Function under test:
%     src/analysis/exploration/findGenesFromRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation (reaction-gene lookup) on a hand-built model, no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindGenesFromRxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% hand-built model, gene i = model.genes{i}:
%   R1: g1   R2: g1 and g2   R3: g1 or g10   R4: g10   R5: no rule
model = struct();
model.rxns = {'R1'; 'R2'; 'R3'; 'R4'; 'R5'};
model.genes = {'g1'; 'g2'; 'g10'};
model.rules = {'x(1)'; 'x(1) & x(2)'; 'x(1) | x(3)'; 'x(3)'; ''};

%% several reactions: one cell of genes per reaction, in the order given

% genes are listed in the order of model.genes; g10 is not returned for R1 although its
% name starts with 'g1'; R5 has no rule and gets an empty list
geneList = findGenesFromRxns(model, {'R3', 'R1', 'R4', 'R5'});
assert(isequal(size(geneList), [4 1]));
assert(isequal(geneList{1}, {'g1'; 'g10'}));
assert(isequal(geneList{2}, {'g1'}));
assert(isequal(geneList{3}, {'g10'}));
assert(isempty(geneList{4}) && iscell(geneList{4}));

%% a reaction that is not in the model is dropped (and reported on the console)

% the message 'The reaction "Rx" is not in your model!' is printed; the remaining reactions
% keep their order
geneList = findGenesFromRxns(model, {'R2', 'Rx', 'R4'});
assert(isequal(size(geneList), [2 1]));
assert(isequal(geneList{1}, {'g1'; 'g2'}));
assert(isequal(geneList{2}, {'g10'}));

% only missing reactions: an empty cell array
geneList = findGenesFromRxns(model, {'Rx'});
assert(isempty(geneList) && iscell(geneList));

%% a single reaction given as a character vector

geneList = findGenesFromRxns(model, 'R2');
assert(isequal(geneList, {{'g1'; 'g2'}}));

%% an existing rxnGeneMat is used as given

% the matrix links g2 to R5 although R5 has no rule: the lookup reads the matrix, not the
% rules, so it is not rebuilt
modelMat = model;
modelMat.rxnGeneMat = sparse([1 0 0; 1 1 0; 1 0 1; 0 0 1; 0 1 0]);
geneList = findGenesFromRxns(modelMat, {'R5', 'R3'});
assert(isequal(geneList{1}, {'g2'}));
assert(isequal(geneList{2}, {'g1'; 'g10'}));

% change the directory
cd(currentDir)
