% The COBRAToolbox: testSelectEcosystemReactions.m
%
% Purpose:
%     - selectEcosystemReactions restricts the reactions used for clustering (rxn2cluster) of an
%       ecosystem structure to a subset given as reaction IDs or as a logical vector over
%       rxn2cluster, keeps the matching columns of qualVectors and fvaResults when these exist,
%       and resets the clustering (clusters, k). This test selects reactions both ways, in a
%       different order, without qualitative results, and checks every error the function
%       raises. Expected values are the columns of the hand-built input that remain.
%
% Function under test:
%     src/analysis/ecosystem/selectEcosystemReactions.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; the ecosystem structure is hand-built with the fields the
%     function reads (rxn2cluster, qualVectors, fvaResults).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSelectEcosystemReactions'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% four reactions, two qualitative vectors (rows = grid points), FVA results with two bounds
eco = struct();
eco.rxn2cluster = {'org1_EX_A'; 'org1_R1'; 'org2_EX_A'; 'org2_R1'};
eco.qualVectors = [1 0 -1 2; 0 1 1 -2];
eco.fvaResults = cat(3, [1 2 3 4; 5 6 7 8], [10 20 30 40; 50 60 70 80]);
eco.clusters = [1; 2];
eco.k = 2;

%% reactions given as IDs: the columns follow the order of the list

ecoOut = selectEcosystemReactions(eco, {'org2_EX_A', 'org1_EX_A'});
% exact: the kept entries are copies of the input columns 3 and 1
assert(isequal(ecoOut.rxn2cluster, {'org2_EX_A'; 'org1_EX_A'}));
assert(isequal(ecoOut.qualVectors, eco.qualVectors(:, [3 1])));
assert(isequal(ecoOut.fvaResults, eco.fvaResults(:, [3 1], :)));
assert(isempty(ecoOut.clusters) && isempty(ecoOut.k));

% a single ID given as a character vector or a string
ecoOut = selectEcosystemReactions(eco, 'org1_R1');
assert(isequal(ecoOut.rxn2cluster, {'org1_R1'}));
assert(isequal(ecoOut.qualVectors, [0; 1]));
assert(isequal(selectEcosystemReactions(eco, "org1_R1"), ecoOut));

%% reactions given as a logical vector over rxn2cluster (the documented exchange example)

isExchange = contains(eco.rxn2cluster, 'EX_');
ecoOut = selectEcosystemReactions(eco, isExchange);
assert(isequal(ecoOut.rxn2cluster, {'org1_EX_A'; 'org2_EX_A'}));
assert(isequal(ecoOut.qualVectors, eco.qualVectors(:, [1 3])));
assert(isequal(ecoOut.fvaResults, eco.fvaResults(:, [1 3], :)));

%% no qualitative results: only the reaction list changes, clusters and k are created

ecoList = struct('rxn2cluster', {eco.rxn2cluster});
ecoOut = selectEcosystemReactions(ecoList, {'org1_R1'});
assert(isequal(ecoOut.rxn2cluster, {'org1_R1'}));
assert(~isfield(ecoOut, 'qualVectors') && ~isfield(ecoOut, 'fvaResults'));
assert(isfield(ecoOut, 'clusters') && isempty(ecoOut.clusters));
assert(isfield(ecoOut, 'k') && isempty(ecoOut.k));

% empty qualVectors and fvaResults stay empty
ecoList.qualVectors = [];
ecoList.fvaResults = [];
ecoOut = selectEcosystemReactions(ecoList, {'org1_R1'});
assert(isempty(ecoOut.qualVectors) && isempty(ecoOut.fvaResults));

%% errors for missing or invalid inputs

assert(verifyCobraFunctionError('selectEcosystemReactions', 'inputs', {eco}, ...
    'testMessage', 'eco and rxnList must be provided.'));
assert(verifyCobraFunctionError('selectEcosystemReactions', 'inputs', {1, {'org1_R1'}}, ...
    'testMessage', 'eco must be an ecosystem structure.'));
assert(verifyCobraFunctionError('selectEcosystemReactions', 'inputs', {struct('k', 1), {'org1_R1'}}, ...
    'testMessage', 'eco must be an ecosystem structure.'));
assert(verifyCobraFunctionError('selectEcosystemReactions', 'inputs', {eco, true(3, 1)}, ...
    'testMessage', 'A logical rxnList must have one element per reaction in eco.rxn2cluster.'));
assert(verifyCobraFunctionError('selectEcosystemReactions', 'inputs', {eco, {'org1_R1', 'R9', 'R8'}}, ...
    'testMessage', 'Reactions not found in eco.rxn2cluster: R9, R8'));

% change the directory
cd(currentDir)
